<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit("Not found.\n"); }
$configPath = __DIR__ . '/../config/config.php';
$checks = [];
$add = static function(string $name, bool $ok, string $detail, bool $required = true) use (&$checks): void {
    $checks[] = ['name'=>$name,'ok'=>$ok,'detail'=>$detail,'required'=>$required];
};
$add('PHP version', PHP_VERSION_ID >= 80100, PHP_VERSION . ' (CodeArena requires PHP 8.1+)');
foreach (['pdo'=>'PDO','pdo_mysql'=>'PDO MySQL driver','curl'=>'cURL','mbstring'=>'mbstring'] as $ext=>$label) {
    $loaded = extension_loaded($ext);
    $add($label, $loaded, $loaded ? 'Enabled' : 'Extension missing; enable it in XAMPP PHP');
}
$root = dirname(__DIR__);
$requiredFiles = [
    'public/index.php','public/student-classrooms.php','public/student-progress.php','public/leaderboard.php',
    'public/exercise.php','public/run.php','public/submit.php','public/teacher.php','public/teacher-gradebook.php',
    'public/teacher-submission.php','public/teacher-monitoring.php','public/teacher-lessons.php','public/student-lessons.php','public/student-lesson.php','public/student-submissions.php','public/student-achievements.php','public/teacher-regrade.php','public/super-admin/users.php','public/super-admin/index.php',
    'public/super-admin/system-health.php','app/bootstrap.php','app/judge0.php','database/schema.sql','database/seeds/all_language_learning_paths_30.sql',
    'tools/check_project.sh','tools/health_check.php','tools/smoke_test.php',
    'tools/backup_database.sh','tools/restore_database.sh','tools/v23_smoke_test.php','database/migrations/010_lessons_feedback_school_workflows_achievements.sql','database/migrations/011_exercise_hints_and_regrade_history.sql','tests/REGRESSION_CHECKLIST.md','tests/ALL_PRIORITIES_V23.md','tests/DEPLOYMENT_CHECKLIST_V23.md'
];
foreach ($requiredFiles as $file) $add('File: ' . $file, is_file($root . '/' . $file), is_file($root . '/' . $file) ? 'Present' : 'Missing from the project folder');

$judgeConfig = [];
$pdo = null;
if (!is_file($configPath)) {
    $add('config/config.php', false, 'Copy config/config.example.php to config/config.php and configure it');
} else {
    $add('config/config.php', true, 'File exists; no configuration values are printed');
    if (extension_loaded('pdo') && extension_loaded('pdo_mysql')) {
        try {
            $config = require $configPath;
            $db = $config['db'] ?? [];
            $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=%s', $db['host'] ?? '127.0.0.1', $db['port'] ?? '3306', $db['name'] ?? 'codearena', $db['charset'] ?? 'utf8mb4');
            $pdo = new PDO($dsn, (string)($db['user'] ?? 'root'), (string)($db['pass'] ?? ''), [
                PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES=>false,
            ]);
            $add('MySQL connection', true, 'Connected to the configured database');
            $judgeConfig = $config['judge0'] ?? [];
            $tables = [
                'Core coding' => [
                    'users'=>['id','name','email','role','password_hash','created_at'],
                    'exercises'=>['id','title','description','hint_text','difficulty','time_limit_seconds','points','created_by','is_published'],
                    'test_cases'=>['id','exercise_id','stdin','expected_output','is_sample','sort_order'],
                    'attempts'=>['id','user_id','exercise_id','started_at','deadline_at','completed_at','best_score','status'],
                    'submissions'=>['id','user_id','exercise_id','language','source_code','score','passed_tests','total_tests','result_json','created_at'],
                ],
                'Classrooms' => [
                    'classrooms'=>['id','teacher_id','name','section','join_code','is_active','archived_at'],
                    'class_enrollments'=>['classroom_id','student_id','enrollment_status','joined_at'],
                    'class_assignments'=>['classroom_id','exercise_id','assigned_by','due_at','is_active'],
                    'grade_records'=>['assignment_id','student_id','best_score','max_score','submission_count'],
                ],
                'Exam monitoring' => [
                    'monitor_events'=>['attempt_id','user_id','exercise_id','event_type','created_at'],
                    'monitor_reviews'=>['attempt_id','teacher_id','review_status','notes','reviewed_at'],
                    'attempts'=>['monitoring_enabled','warning_threshold','started_explicitly','retake_pending'],
                ],
                'Learning and security' => [
                    'learning_paths'=>['id','teacher_id','title','is_published'],
                    'learning_path_items'=>['path_id','exercise_id','sort_order'],
                    'practice_runs'=>['user_id','exercise_id','passed_samples','total_samples','all_samples_passed'],
                    'auth_rate_limits'=>['identity_hash','failed_count','window_started_at','blocked_until'],
                    'audit_logs'=>['actor_id','actor_role','action','details','created_at'],
                ],
                'Exercise history' => [
                    'exercise_versions'=>['exercise_id','version_number','snapshot_json','change_reason','created_by','created_at'],
                    'attempts'=>['exercise_version_id'],
                    'submissions'=>['exercise_version_id'],
                ],
                'Lessons, feedback, and school workflows' => [
                    'users'=>['is_active'],
                    'classrooms'=>['archived_at'],
                    'attempts'=>['retake_pending'],
                    'learning_lessons'=>['id','path_id','teacher_id','title','lesson_content','is_published'],
                    'learning_lesson_completions'=>['user_id','lesson_id','completed_at'],
                    'submission_feedback'=>['submission_id','teacher_id','feedback_text','feedback_type'],
                    'class_announcements'=>['classroom_id','teacher_id','title','is_published'],
                    'student_assignment_overrides'=>['assignment_id','student_id','extended_due_at','updated_by'],
                    'attempt_retake_history'=>['attempt_id','teacher_id','previous_status','previous_best_score'],
                    'badge_definitions'=>['id','slug','title'],
                    'student_badges'=>['student_id','badge_id','awarded_at'],
                ],
                'Exercise hints and regrade archive' => [
                    'exercises'=>['hint_text'],
                    'submission_regrade_history'=>['submission_id','teacher_id','previous_version_id','new_version_id','previous_score','new_score','reason','regraded_at'],
                ],
            ];
            $tableStmt = $pdo->prepare('SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? LIMIT 1');
            $columnStmt = $pdo->prepare('SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? AND column_name=? LIMIT 1');
            foreach ($tables as $group=>$groupTables) {
                $missing = [];
                foreach ($groupTables as $table=>$columns) {
                    $tableStmt->execute([$table]);
                    if (!$tableStmt->fetchColumn()) { $missing[] = $table . ' table'; continue; }
                    foreach ($columns as $column) {
                        $columnStmt->execute([$table,$column]);
                        if (!$columnStmt->fetchColumn()) $missing[] = $table . '.' . $column;
                    }
                }
                $add('Schema group: ' . $group, !$missing, !$missing ? 'Required tables and columns present' : 'Missing: ' . implode(', ', $missing));
            }
            $judgeBase = trim((string)($judgeConfig['base_url'] ?? ''));
            $judgeParts = $judgeBase !== '' ? parse_url($judgeBase) : false;
            $judgeValid = is_array($judgeParts) && !empty($judgeParts['host']) && in_array(strtolower((string)($judgeParts['scheme'] ?? '')), ['http','https'], true) && filter_var($judgeBase, FILTER_VALIDATE_URL) !== false;
            $host = is_array($judgeParts) ? (string)($judgeParts['host'] ?? 'unknown host') : '';
            $add('Judge0 URL', $judgeValid, $judgeValid ? $host . ' configured (endpoint path and credentials hidden)' : 'Set a valid http(s) judge0.base_url in config/config.php');
            $languages = $judgeConfig['languages'] ?? [];
            $missingLanguages = [];
            foreach (['c','cpp','java','python','php','ruby'] as $language) if (!isset($languages[$language]) || !is_numeric($languages[$language]) || (int)$languages[$language] < 1) $missingLanguages[] = $language;
            $add('Judge0 language IDs', !$missingLanguages, !$missingLanguages ? 'IDs are configured; verify they match the selected provider' : 'Missing or invalid: ' . implode(', ', $missingLanguages));
            if (in_array('--judge0', $argv ?? [], true) && $judgeValid && extension_loaded('curl')) {
                require_once __DIR__ . '/../app/judge0.php';
                $response = judge0_http_json(rtrim($judgeBase,'/') . '/system_info', 'GET', judge0_request_headers($judgeConfig), null, 8);
                $http = (int)$response['http'];
                if ($response['body'] !== false && $http >= 200 && $http < 300) {
                    $add('Judge0 connectivity', true, 'Endpoint returned HTTP ' . $http);
                } elseif ($response['body'] !== false && in_array($http,[401,403],true)) {
                    $add('Judge0 connectivity', false, 'Host reachable but HTTP ' . $http . '; check provider authentication or route access');
                } elseif ($response['body'] !== false) {
                    $add('Judge0 connectivity', false, 'Host responded with HTTP ' . $http . '; check provider documentation and configured base URL');
                } else {
                    $error = preg_replace('/[\r\n\x00-\x1F]+/', ' ', (string)$response['error']);
                    $add('Judge0 connectivity', false, 'Connection failed' . ($error ? ': ' . substr($error,0,180) : '')); 
                }
            } elseif (in_array('--judge0', $argv ?? [], true)) {
                $add('Judge0 connectivity', false, !$judgeValid ? 'A valid Judge0 URL is not configured' : 'PHP cURL is not enabled');
            } else {
                $add('Judge0 connectivity', true, 'Not probed. Run with --judge0 to test the configured endpoint.', false);
            }
        } catch (Throwable $e) {
            $add('MySQL connection', false, 'Could not connect; check XAMPP MySQL and database settings in config/config.php');
        }
    }
}

$passed = 0;
$failedRequired = 0;
foreach ($checks as $check) {
    if ($check['ok']) $passed++;
    elseif ($check['required']) $failedRequired++;
    printf("[%s] %-34s %s\n", $check['ok'] ? 'OK' : ($check['required'] ? 'CHECK' : 'SKIP'), $check['name'], $check['detail']);
}
printf("\nHealth check: %d/%d checks passed; %d required checks need attention.\n", $passed, count($checks), $failedRequired);
if (in_array('--judge0', $argv ?? [], true)) echo "Connectivity check only. To verify compile/run/grading behavior, use the Super Admin System Health execution smoke test.\n";
exit($failedRequired === 0 ? 0 : 1);
