<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/judge0.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function run_fail(string $message, int $status = 400): never {
    http_response_code($status);
    echo json_encode(['error' => $message], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

$user = current_user();
if (!$user) run_fail('Please sign in again before running code.', 401);
if (($user['role'] ?? '') !== 'student') run_fail('Only student accounts can run exercise code.', 403);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') run_fail('POST required.', 405);
verify_csrf();

$exerciseId = (int)($_POST['exercise_id'] ?? 0);
$language = (string)($_POST['language'] ?? '');
$source = (string)($_POST['source_code'] ?? '');
$stdin = (string)($_POST['stdin'] ?? '');
if (!in_array($language, ['c', 'cpp', 'java', 'python', 'php', 'ruby'], true)) {
    run_fail('Unsupported language. HTML/CSS is preview-only in CodeArena.');
}
if (trim($source) === '') run_fail('Write some code before running it.');
if (strlen($source) > 100000) run_fail('Source code is too large (100 KB maximum).');
if (strlen($stdin) > 20000) run_fail('Standard input is too large (20 KB maximum).');

$exerciseStmt = $pdo->prepare('SELECT id FROM exercises WHERE id = ? AND (is_published = 1 OR EXISTS (SELECT 1 FROM attempts ax WHERE ax.exercise_id = exercises.id AND ax.user_id = ? AND ax.started_explicitly = 1))');
$exerciseStmt->execute([$exerciseId, (int)$user['id']]);
if (!$exerciseStmt->fetchColumn()) run_fail('Exercise not found.', 404);

$accessContext = student_exercise_access_context($pdo, (int)$user['id'], $exerciseId);
if (!$accessContext['allowed']) run_fail('You are not enrolled in a classroom assigned this exercise, or its deadline has passed.', 403);
if (!$accessContext['restricted']) run_fail('This challenge is Practice Mode only. Start a classroom assignment to create an official submission.', 403);
if (!empty($accessContext['due_at']) && strtotime((string)$accessContext['due_at']) <= time()) {
    run_fail('The assignment deadline has passed. Code can no longer be run for this attempt.', 410);
}
$attemptStmt = $pdo->prepare('SELECT * FROM attempts WHERE user_id = ? AND exercise_id = ?');
$attemptStmt->execute([(int)$user['id'], $exerciseId]);
$attempt = $attemptStmt->fetch();
if (!$attempt || (int)($attempt['started_explicitly'] ?? 0) !== 1) run_fail('Click Start Exercise before running code.', 409);
$deadline = strtotime((string)$attempt['deadline_at']);
if (!empty($accessContext['due_at'])) $deadline = min($deadline, strtotime((string)$accessContext['due_at']));
if (($attempt['status'] ?? '') !== 'in_progress' || $deadline <= time()) {
    $pdo->prepare("UPDATE attempts SET status = 'expired' WHERE id = ? AND status = 'in_progress'")->execute([(int)$attempt['id']]);
    run_fail('This attempt is complete or its time limit has expired. Running code was not accepted.', 410);
}

// A modest session rate limit helps prevent accidental rapid-fire requests to shared Judge0 services.
$now = time();
$recentRuns = $_SESSION['_codearena_runs'] ?? [];
if (!is_array($recentRuns)) $recentRuns = [];
$recentRuns = array_values(array_filter($recentRuns, static fn($timestamp) => is_int($timestamp) && $timestamp > $now - 60));
if (count($recentRuns) >= 12) run_fail('Run limit reached. Wait a minute before running more code.', 429);
$recentRuns[] = $now;
$_SESSION['_codearena_runs'] = $recentRuns;

try {
    $result = judge0_execute($config['judge0'] ?? [], $language, $source, $stdin);
} catch (Throwable $error) {
    error_log('CodeArena run execution failed: ' . $error->getMessage());
    run_fail('The code execution service is currently unavailable. Check the Judge0 connection and try again.', 502);
}

$status = (string)($result['status']['description'] ?? 'Unknown');
$stdout = (string)($result['stdout'] ?? '');
$stderr = (string)($result['stderr'] ?? '');
$compileOutput = (string)($result['compile_output'] ?? '');
echo json_encode([
    'ok' => true,
    'status' => $status,
    'stdout' => $stdout,
    'stderr' => $stderr,
    'compile_output' => $compileOutput,
    'time' => isset($result['time']) ? (string)$result['time'] : null,
    'memory' => isset($result['memory']) ? (int)$result['memory'] : null,
    'saved_submission' => false,
    'message' => 'Run completed. This run did not save a grade or create a submission record.',
], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
