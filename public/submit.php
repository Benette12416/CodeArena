<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/judge0.php';
require_once __DIR__ . '/../app/learning_paths.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function submit_fail(string $message, int $status = 400): never {
    http_response_code($status);
    echo json_encode(['error' => $message], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

$user = current_user();
if (!$user) submit_fail('Please sign in again before submitting.', 401);
if (($user['role'] ?? '') !== 'student') submit_fail('Only student accounts can submit exercise solutions.', 403);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') submit_fail('POST required.', 405);
verify_csrf();

$exerciseId = (int)($_POST['exercise_id'] ?? 0);
$pathId = max(0, (int)($_POST['path_id'] ?? 0));
$language = (string)($_POST['language'] ?? '');
$source = (string)($_POST['source_code'] ?? '');
if (trim($source) === '') submit_fail('Write some code before submitting.');
if (strlen($source) > 100000) submit_fail('Source code is too large (100 KB maximum).');
if (!in_array($language, ['c', 'cpp', 'java', 'python', 'php', 'ruby'], true)) {
    submit_fail('Unsupported language. HTML/CSS is preview-only.');
}

$exerciseStmt = $pdo->prepare('SELECT * FROM exercises WHERE id = ? AND (is_published = 1 OR EXISTS (SELECT 1 FROM attempts ax WHERE ax.exercise_id = exercises.id AND ax.user_id = ? AND ax.started_explicitly = 1))');
$exerciseStmt->execute([$exerciseId, (int)$user['id']]);
$exercise = $exerciseStmt->fetch();
if (!$exercise) submit_fail('Exercise not found.', 404);

if ($pathId > 0) {
    $pathGate = ca_assert_learning_path_step_unlocked($pdo, (int)$user['id'], $pathId, $exerciseId);
    if (!$pathGate['ok']) submit_fail($pathGate['reason'], 403);
} else {
    $linkedPathId = ca_find_published_path_for_exercise($pdo, $exerciseId);
    if ($linkedPathId !== null) submit_fail('This challenge is part of a learning path. Open it from Learning Paths so the required step order is enforced.', 403);
}

$accessContext = student_exercise_access_context($pdo, (int)$user['id'], $exerciseId);
if (!$accessContext['allowed']) submit_fail('You are not enrolled in a classroom assigned this exercise, or its deadline has passed.', 403);
if (!$accessContext['restricted']) submit_fail('This challenge is Practice Mode only. Start a classroom assignment to create an official submission.', 403);
if (!empty($accessContext['due_at']) && strtotime((string)$accessContext['due_at']) <= time()) {
    submit_fail('The assignment deadline has passed. Your submission was not accepted.', 410);
}

$attemptStmt = $pdo->prepare('SELECT * FROM attempts WHERE user_id = ? AND exercise_id = ?');
$attemptStmt->execute([(int)$user['id'], $exerciseId]);
$attempt = $attemptStmt->fetch();
if (!$attempt || (int)($attempt['started_explicitly'] ?? 0) !== 1) submit_fail('Click Start Exercise before submitting code.', 409);
try { [$attempt, $attemptSnapshot] = ensure_attempt_exercise_version($pdo, $attempt, $exerciseId, (int)$exercise['created_by']); $exercise = array_merge($exercise, $attemptSnapshot['exercise']); }
catch (Throwable $versionError) { error_log('CodeArena submit version snapshot failed: '.$versionError->getMessage()); submit_fail('The version for this attempt is unavailable. No grade was saved.', 500); }
if ($pathId > 0 && preg_match('/^ca-(python|cpp|c|java|php|ruby)-path-/', (string)($exercise['slug'] ?? ''), $expectedLanguageMatch)) {
    $expectedLanguage = $expectedLanguageMatch[1];
    if ($language !== $expectedLanguage) submit_fail('This learning path must be completed using ' . strtoupper($expectedLanguage === 'cpp' ? 'C++' : $expectedLanguage) . '. Select the language assigned to this path.', 403);
}
$serverDeadline = strtotime((string)$attempt['deadline_at']);
if (!empty($accessContext['due_at'])) $serverDeadline = min($serverDeadline, strtotime((string)$accessContext['due_at']));
if (($attempt['status'] ?? '') !== 'in_progress' || $serverDeadline <= time()) {
    $pdo->prepare("UPDATE attempts SET status = 'expired' WHERE id = ? AND status = 'in_progress'")->execute([(int)$attempt['id']]);
    submit_fail('Time limit expired. Your submission was not accepted.', 410);
}

$submitTimes = $_SESSION['_codearena_submits'] ?? [];
if (!is_array($submitTimes)) $submitTimes = [];
$submitTimes = array_values(array_filter($submitTimes, static fn($t) => is_int($t) && $t > time() - 60));
if (count($submitTimes) >= 8) submit_fail('Submission limit reached. Wait a minute before submitting again.', 429);
$submitTimes[] = time(); $_SESSION['_codearena_submits'] = $submitTimes;

$tests = array_map(static fn(array $case): array => ['stdin'=>(string)$case['stdin'], 'expected_output'=>(string)$case['expected_output'], 'is_sample'=>(int)$case['is_sample']], $attemptSnapshot['test_cases']);
if (!$tests) submit_fail('This exercise has no test cases yet. Ask the teacher to add test cases.');

$results = [];
$passed = 0;
$total = count($tests);
$sampleNumber = 0;
try {
    $jobs = array_map(static fn(array $test): array => ['language'=>$language,'source_code'=>$source,'stdin'=>(string)$test['stdin']], $tests);
    $runs = judge0_execute_batch($config['judge0'] ?? [], $jobs);
    foreach ($tests as $index => $test) {
        $sample = (int)$test['is_sample'] === 1;
        if ($sample) $sampleNumber++;
        $run = $runs[$index];
        $status = (string)($run['status']['description'] ?? 'Unknown');
        $stdout = (string)($run['stdout'] ?? '');
        $stderr = (string)($run['stderr'] ?? '');
        $compileOutput = (string)($run['compile_output'] ?? '');
        $isPassed = $status === 'Accepted' && normalize_output($stdout) === normalize_output((string)$test['expected_output']);
        if ($isPassed) $passed++;
        $verdict = $isPassed ? 'Accepted' : ($status === 'Accepted' ? 'Wrong Answer' : $status);

        // Keep hidden tests hidden: only samples include input, expected output, and actual output.
        $results[] = [
            'number' => $index + 1,
            'is_sample' => $sample,
            'sample_number' => $sample ? $sampleNumber : null,
            'passed' => $isPassed,
            'status' => $status,
            'verdict' => $verdict,
            'input' => $sample ? (string)$test['stdin'] : null,
            'expected_output' => $sample ? (string)$test['expected_output'] : null,
            'actual_output' => $sample ? $stdout : null,
            'error_output' => $sample ? trim($compileOutput . ($compileOutput !== '' && $stderr !== '' ? "\n" : '') . $stderr) : null,
            'time' => isset($run['time']) ? (string)$run['time'] : null,
            'memory' => isset($run['memory']) ? (int)$run['memory'] : null,
        ];
    }
} catch (Throwable $error) {
    error_log('CodeArena grading execution failed: ' . $error->getMessage());
    submit_fail('The code execution service is currently unavailable. Check the Judge0 connection and try again.', 502);
}

$score = (int)floor(((int)$exercise['points']) * $passed / $total);
// Persist a minimal result summary. Hidden test input/output is never stored in this result JSON.
$savedResults = array_map(static fn(array $test): array => [
    'number' => $test['number'],
    'is_sample' => $test['is_sample'],
    'passed' => $test['passed'],
    'status' => $test['status'],
    'verdict' => $test['verdict'],
], $results);

$pdo->beginTransaction();
try {
    // Lock the attempt again after judging so concurrent submissions cannot save after a perfect score.
    $lockStmt = $pdo->prepare('SELECT status, best_score, deadline_at FROM attempts WHERE id = ? AND user_id = ? FOR UPDATE');
    $lockStmt->execute([(int)$attempt['id'], (int)$user['id']]);
    $lockedAttempt = $lockStmt->fetch();
    if (!$lockedAttempt || (string)$lockedAttempt['status'] !== 'in_progress') {
        $pdo->rollBack();
        submit_fail('This exercise attempt is already complete or no longer active. Refresh the page to see your result.', 409);
    }
    $lockedDeadline = strtotime((string)$lockedAttempt['deadline_at']);
    if ($lockedDeadline <= time() || (!empty($accessContext['due_at']) && strtotime((string)$accessContext['due_at']) <= time())) {
        $pdo->prepare("UPDATE attempts SET status = 'expired' WHERE id = ? AND status = 'in_progress'")->execute([(int)$attempt['id']]);
        $pdo->commit();
        submit_fail('The time limit expired before the results could be saved. Please review your attempt status.', 410);
    }

    $insert = $pdo->prepare('INSERT INTO submissions(user_id, exercise_id, exercise_version_id, language, source_code, score, passed_tests, total_tests, result_json) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $insert->execute([
        (int)$user['id'], $exerciseId, (int)$attempt['exercise_version_id'], $language, $source, $score, $passed, $total,
        json_encode($savedResults, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE),
    ]);
    $submissionId = (int)$pdo->lastInsertId();

    $pdo->prepare('UPDATE attempts SET best_score = GREATEST(best_score, ?) WHERE id = ?')->execute([$score, (int)$attempt['id']]);
    $bestScoreStmt = $pdo->prepare('SELECT best_score FROM attempts WHERE id = ?');
    $bestScoreStmt->execute([(int)$attempt['id']]);
    $bestScore = (int)$bestScoreStmt->fetchColumn();
    $isPerfect = $bestScore >= (int)$exercise['points'];
    if ($isPerfect) {
        $pdo->prepare("UPDATE attempts SET status = 'submitted', completed_at = COALESCE(completed_at, CURRENT_TIMESTAMP) WHERE id = ?")->execute([(int)$attempt['id']]);
    }

    $assignmentStmt = $pdo->prepare("SELECT ca.id FROM class_assignments ca
        JOIN classrooms c ON c.id = ca.classroom_id AND c.is_active = 1
        JOIN class_enrollments ce ON ce.classroom_id = ca.classroom_id AND ce.student_id = ? AND ce.enrollment_status = 'active'
        WHERE ca.exercise_id = ? AND ca.is_active = 1");
    $assignmentStmt->execute([(int)$user['id'], $exerciseId]);
    foreach ($assignmentStmt->fetchAll(PDO::FETCH_COLUMN) as $assignmentId) {
        sync_assignment_grade($pdo, (int)$assignmentId, (int)$user['id']);
    }
    $pdo->commit();
    audit_log($pdo, (int)$user['id'], 'submission_graded', 'submission', $submissionId, ['exercise_id'=>$exerciseId,'score'=>$score,'passed_tests'=>$passed,'total_tests'=>$total,'completed'=>$isPerfect]);
    award_student_badges($pdo, (int)$user['id']);
} catch (Throwable $error) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    submit_fail('Could not save the submission. Please try again.', 500);
}

$nextExerciseUrl = $isPerfect
    ? student_next_incomplete_exercise_url($pdo, (int)$user['id'], $exerciseId)
    : null;
$doneUrl = $isPerfect
    ? student_exercise_done_url($pdo, (int)$user['id'], $exerciseId)
    : null;
if ($isPerfect && $pathId > 0) {
    $pathReturnUrl = rtrim($config['base_url'], '/') . '/student-learning-paths.php?path_id=' . $pathId;
    $nextExerciseUrl = $pathReturnUrl;
    $doneUrl = $pathReturnUrl;
}

echo json_encode([
    'ok' => true,
    'submission_id' => $submissionId,
    'score' => $score,
    'best_score' => $bestScore,
    'max_score' => (int)$exercise['points'],
    'passed_tests' => $passed,
    'total_tests' => $total,
    'completed' => $isPerfect,
    'perfect_score' => $isPerfect,
    'done_url' => $doneUrl,
    'next_exercise_url' => $nextExerciseUrl,
    'path_mode' => $pathId > 0,
    'tests' => $results,
    'message' => $isPerfect
        ? 'Perfect score! Your attempt has been completed and the timer is stopped.'
        : 'Output is compared after normalizing line endings and trimming outer whitespace. Hidden test details remain private.',
], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
