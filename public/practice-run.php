<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/judge0.php';
require_once __DIR__ . '/../app/learning_paths.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function practice_fail(string $message, int $status = 400): never
{
    http_response_code($status);
    echo json_encode(['ok' => false, 'error' => $message], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

$user = current_user();
if (!$user || ($user['role'] ?? '') !== 'student') practice_fail('Sign in with a student account to use Practice Mode.', 403);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') practice_fail('POST required.', 405);
verify_csrf();
$exerciseId = filter_var($_POST['exercise_id'] ?? null, FILTER_VALIDATE_INT);
$pathId = max(0, (int)($_POST['path_id'] ?? 0));
$language = (string)($_POST['language'] ?? 'python');
$source = (string)($_POST['source_code'] ?? '');
$mode = (string)($_POST['mode'] ?? 'custom');
$stdin = (string)($_POST['stdin'] ?? '');
if (!$exerciseId || !in_array($language, ['c', 'cpp', 'java', 'python', 'php', 'ruby'], true)) practice_fail('Choose a valid exercise and supported programming language.');
if (!in_array($mode, ['custom', 'samples', 'path'], true)) practice_fail('Invalid practice mode.');
if (trim($source) === '') practice_fail('Write some code first.');
if (strlen($source) > 100000) practice_fail('Source code is too large (100 KB maximum).');
if (strlen($stdin) > 20000) practice_fail('Standard input is too large (20 KB maximum).');

$stmt = $pdo->prepare("SELECT e.id,e.title,e.topic,e.slug,e.points FROM exercises e WHERE e.id=? AND e.is_published=1
    AND NOT EXISTS (SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1)");
$stmt->execute([(int)$exerciseId]);
$exercise = $stmt->fetch();
if (!$exercise) practice_fail('This challenge is not available in Practice Mode. Classroom-assigned exercises must be opened from My Classes.', 403);

if ($pathId > 0) {
    $gate = ca_assert_learning_path_step_unlocked($pdo, (int)$user['id'], $pathId, (int)$exerciseId);
    if (!$gate['ok']) practice_fail($gate['reason'], 403);
} else {
    $linkedPathId = ca_find_published_path_for_exercise($pdo, (int)$exerciseId);
    if ($linkedPathId !== null) practice_fail('This challenge is part of a learning path. Open it from Learning Paths to follow the required step order.', 403);
}
if ($mode === 'path' && $pathId < 1) practice_fail('Open a challenge from a learning path before checking step completion.', 403);
if ($mode === 'path' && str_starts_with((string)($exercise['slug'] ?? ''), 'ca-htmlcss-path-')) practice_fail('HTML/CSS projects use the preview and Mark project complete workflow.', 400);
if ($pathId > 0 && preg_match('/^ca-(python|cpp|c|java|php|ruby)-path-/', (string)($exercise['slug'] ?? ''), $expectedLanguageMatch)) {
    $expectedLanguage = $expectedLanguageMatch[1];
    if ($language !== $expectedLanguage) practice_fail('This learning path must be completed using ' . strtoupper($expectedLanguage === 'cpp' ? 'C++' : $expectedLanguage) . '. Select the language assigned to this path.', 403);
}
if ($mode === 'path' && (!function_exists('codearena_table_exists') || !codearena_table_exists($pdo, 'learning_path_completions'))) {
    practice_fail('Sequential completion is not installed yet. Ask the site administrator to apply database/migrations/009_sequential_learning_path_progress.sql once.', 503);
}

$now = time();
$runs = $_SESSION['_practice_runs'] ?? [];
if (!is_array($runs)) $runs = [];
$runs = array_values(array_filter($runs, static fn($v) => is_int($v) && $v > $now - 60));
if (count($runs) >= 12) practice_fail('Practice execution limit reached. Wait a minute before trying again.', 429);
$runs[] = $now;
$_SESSION['_practice_runs'] = $runs;

try {
    if ($mode === 'custom') {
        $result = judge0_execute($config['judge0'] ?? [], $language, $source, $stdin);
        echo json_encode([
            'ok' => true, 'mode' => 'custom', 'status' => (string)($result['status']['description'] ?? 'Unknown'),
            'stdout' => (string)($result['stdout'] ?? ''), 'stderr' => (string)($result['stderr'] ?? ''),
            'compile_output' => (string)($result['compile_output'] ?? ''), 'time' => isset($result['time']) ? (string)$result['time'] : null,
            'memory' => isset($result['memory']) ? (int)$result['memory'] : null,
            'message' => 'Practice run only. No official grade, attempt, or submission was changed.'
        ], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
        exit;
    }

    if ($mode === 'samples') {
        $testsStmt = $pdo->prepare('SELECT stdin,expected_output,is_sample FROM test_cases WHERE exercise_id=? AND is_sample=1 ORDER BY sort_order,id LIMIT 10');
    } else {
        // Path completion checks every configured public and hidden case. Hidden inputs and outputs never leave the server.
        $testsStmt = $pdo->prepare('SELECT stdin,expected_output,is_sample FROM test_cases WHERE exercise_id=? ORDER BY sort_order,id');
    }
    $testsStmt->execute([(int)$exerciseId]);
    $tests = $testsStmt->fetchAll();
    if (!$tests) practice_fail('This exercise has no test cases. Ask the teacher to add test cases before checking progress.');
    if (count($tests) > 100) practice_fail('This challenge has too many test cases for one request. Ask the teacher to reduce the test suite or split the challenge.', 413);

    $jobs = array_map(static fn(array $test): array => ['language' => $language, 'source_code' => $source, 'stdin' => (string)$test['stdin']], $tests);
    $runs = judge0_execute_batch($config['judge0'] ?? [], $jobs);
    $testResults = [];
    $passed = 0;
    $publicPassed = 0;
    $publicTotal = 0;
    $sampleNumber = 0;
    foreach ($tests as $index => $test) {
        $run = $runs[$index] ?? [];
        $status = (string)($run['status']['description'] ?? 'Unknown');
        $stdout = (string)($run['stdout'] ?? '');
        $isPassed = $status === 'Accepted' && normalize_output($stdout) === normalize_output((string)$test['expected_output']);
        if ($isPassed) $passed++;
        $isSample = (int)$test['is_sample'] === 1;
        if ($isSample) {
            $publicTotal++;
            if ($isPassed) $publicPassed++;
            $sampleNumber++;
            $testResults[] = [
                'number' => $mode === 'samples' ? $sampleNumber : $index + 1,
                'hidden' => false, 'passed' => $isPassed,
                'status' => $isPassed ? 'Accepted' : ($status === 'Accepted' ? 'Wrong Answer' : $status),
                'input' => (string)$test['stdin'], 'expected_output' => (string)$test['expected_output'], 'actual_output' => $stdout,
                'error_output' => trim((string)($run['compile_output'] ?? '') . ((string)($run['compile_output'] ?? '') !== '' && (string)($run['stderr'] ?? '') !== '' ? "\n" : '') . (string)($run['stderr'] ?? '')),
                'time' => isset($run['time']) ? (string)$run['time'] : null,
                'memory' => isset($run['memory']) ? (int)$run['memory'] : null,
            ];
        } elseif ($mode === 'path') {
            $testResults[] = [
                'number' => $index + 1, 'hidden' => true, 'passed' => $isPassed,
                'status' => $isPassed ? 'Passed' : 'Not passed',
            ];
        }
    }

    if ($mode === 'samples') {
        $allPublicPassed = $publicPassed === count($tests);
        $save = $pdo->prepare('INSERT INTO practice_runs(user_id,exercise_id,topic_snapshot,language,passed_samples,total_samples,all_samples_passed) VALUES(?,?,?,?,?,?,?)');
        $save->execute([(int)$user['id'], (int)$exerciseId, (string)($exercise['topic'] ?: 'Fundamentals'), $language, $publicPassed, count($tests), $allPublicPassed ? 1 : 0]);
        if (function_exists('audit_log')) audit_log($pdo, (int)$user['id'], 'practice_sample_check', 'exercise', (int)$exerciseId, ['passed_samples' => $publicPassed, 'total_samples' => count($tests), 'all_passed' => $allPublicPassed]);
        award_student_badges($pdo, (int)$user['id']);
        echo json_encode([
            'ok' => true, 'mode' => 'samples', 'passed_samples' => $publicPassed, 'total_samples' => count($tests),
            'all_samples_passed' => $allPublicPassed, 'tests' => $testResults,
            'message' => $allPublicPassed ? 'All public samples passed. This is practice progress only; the next learning-path step still requires all public and hidden tests.' : 'Some public samples did not pass yet. Adjust your code and try again; official grades are unchanged.'
        ], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
        exit;
    }

    $allTestsPassed = $passed === count($tests);
    if ($allTestsPassed) {
        $completion = $pdo->prepare("INSERT INTO learning_path_completions(user_id,path_id,exercise_id,completion_type,passed_tests,total_tests,completed_at)
            VALUES(?,?,?,'all_tests_passed',?,?,CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE completion_type=VALUES(completion_type),passed_tests=VALUES(passed_tests),total_tests=VALUES(total_tests),completed_at=VALUES(completed_at)");
        $completion->execute([(int)$user['id'], $pathId, (int)$exerciseId, $passed, count($tests)]);
        if (function_exists('audit_log')) audit_log($pdo, (int)$user['id'], 'learning_path_step_completed', 'exercise', (int)$exerciseId, ['path_id' => $pathId, 'passed_tests' => $passed, 'total_tests' => count($tests)]);
    }
    echo json_encode([
        'ok' => true, 'mode' => 'path', 'passed_tests' => $passed, 'total_tests' => count($tests),
        'all_tests_passed' => $allTestsPassed, 'completed' => $allTestsPassed, 'tests' => $testResults,
        'message' => $allTestsPassed
            ? 'Perfect! Every public and hidden test passed. This learning-path step is complete, and the next step is now unlocked.'
            : 'Not all tests passed yet. Public samples show their output; hidden tests show pass/fail only. Keep working until every test passes to unlock the next step.'
    ], JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
} catch (Throwable $error) {
    error_log('CodeArena practice execution failed: ' . $error->getMessage());
    practice_fail('The code execution service is currently unavailable. Check the Judge0 connection and try again.', 502);
}
