<?php
declare(strict_types=1);
require_once __DIR__ . '/../../app/bootstrap.php';
require_once __DIR__ . '/../../app/super_admin_layout.php';
require_once __DIR__ . '/../../app/judge0.php';
$user = require_role(['super_admin']);
header('Cache-Control: no-store, private');

$projectRoot = dirname(__DIR__, 2);
$featureGroups = [
    'Core coding and grading' => [
        'migration' => 'Fresh schema / core tables',
        'tables' => [
            'users' => ['id','name','email','role','password_hash','created_at'],
            'exercises' => ['id','title','description','hint_text','difficulty','time_limit_seconds','points','created_by','is_published'],
            'test_cases' => ['id','exercise_id','stdin','expected_output','is_sample','sort_order'],
            'attempts' => ['id','user_id','exercise_id','started_at','deadline_at','completed_at','best_score','status'],
            'submissions' => ['id','user_id','exercise_id','language','source_code','score','passed_tests','total_tests','result_json','created_at'],
        ],
    ],
    'Classrooms and gradebook' => [
        'migration' => 'Migration 003 · classroom management',
        'tables' => [
            'classrooms' => ['id','teacher_id','name','section','join_code','is_active','archived_at'],
            'class_enrollments' => ['classroom_id','student_id','enrollment_status','joined_at'],
            'class_assignments' => ['classroom_id','exercise_id','assigned_by','due_at','is_active'],
            'grade_records' => ['assignment_id','student_id','best_score','max_score','submission_count'],
        ],
    ],
    'Explicit exercise start' => [
        'migration' => 'Migration 004 · start gate',
        'tables' => ['attempts' => ['started_explicitly','completed_at','deadline_at','status']],
    ],
    'Exam monitoring and review' => [
        'migration' => 'Migrations 002 and 005 · monitoring and review workflow',
        'tables' => [
            'monitor_events' => ['attempt_id','user_id','exercise_id','event_type','created_at'],
            'monitor_reviews' => ['attempt_id','teacher_id','review_status','notes','reviewed_at'],
            'attempts' => ['monitoring_enabled','warning_threshold','retake_pending'],
        ],
    ],
    'Learning paths and practice' => [
        'migration' => 'Migration 006 · learning and practice tools',
        'tables' => [
            'learning_paths' => ['id','teacher_id','title','is_published'],
            'learning_path_items' => ['path_id','exercise_id','sort_order'],
            'practice_runs' => ['user_id','exercise_id','passed_samples','total_samples','all_samples_passed'],
            'exercises' => ['topic'],
        ],
    ],
    'Sequential learning-path progress' => [
        'migration' => 'Migration 009 · step locking and completion records',
        'tables' => [
            'learning_path_completions' => ['user_id','path_id','exercise_id','completion_type','passed_tests','total_tests','completed_at'],
            'practice_lesson_completions' => ['user_id','path_id','exercise_id','completed_at'],
        ],
    ],
    'Security and audit trail' => [
        'migration' => 'Migration 006 · login throttling and audit log',
        'tables' => [
            'auth_rate_limits' => ['identity_hash','failed_count','window_started_at','blocked_until'],
            'audit_logs' => ['actor_id','actor_role','action','entity_type','entity_id','details','created_at'],
        ],
    ],
    'Exercise version history' => [
        'migration' => 'Migration 007 · version snapshots',
        'tables' => [
            'exercise_versions' => ['exercise_id','version_number','snapshot_json','change_reason','created_by','created_at'],
            'attempts' => ['exercise_version_id'],
            'submissions' => ['exercise_version_id'],
        ],
    ],
    'Lessons, teacher feedback, and school workflows' => [
        'migration' => 'Migration 010 · lessons, feedback, announcements, deadlines, retakes, and badges',
        'tables' => [
            'users' => ['is_active'],
            'classrooms' => ['archived_at'],
            'attempts' => ['retake_pending'],
            'learning_lessons' => ['id','path_id','teacher_id','title','lesson_content','is_published'],
            'learning_lesson_completions' => ['user_id','lesson_id','completed_at'],
            'submission_feedback' => ['submission_id','teacher_id','feedback_text','feedback_type'],
            'class_announcements' => ['classroom_id','teacher_id','title','is_published'],
            'student_assignment_overrides' => ['assignment_id','student_id','extended_due_at','updated_by'],
            'attempt_retake_history' => ['attempt_id','teacher_id','previous_status','previous_best_score'],
            'badge_definitions' => ['id','slug','title'],
            'student_badges' => ['student_id','badge_id','awarded_at'],
        ],
    ],
    'Exercise hints and regrade archive' => [
        'migration' => 'Migration 011 · hints and regrade history',
        'tables' => [
            'exercises' => ['hint_text'],
            'submission_regrade_history' => ['submission_id','teacher_id','previous_version_id','new_version_id','previous_score','new_score','reason','regraded_at'],
        ],
    ],
];

$checks = [];
$pushCheck = static function(string $group, string $label, string $state, string $detail) use (&$checks): void {
    $checks[] = ['group'=>$group, 'label'=>$label, 'state'=>$state, 'detail'=>$detail];
};
$tableExists = static function(string $table) use ($pdo): bool {
    try {
        $stmt = $pdo->prepare('SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ? LIMIT 1');
        $stmt->execute([$table]);
        return (bool)$stmt->fetchColumn();
    } catch (Throwable $ignored) { return false; }
};
$columnExists = static function(string $table, string $column) use ($pdo): bool {
    try {
        $stmt = $pdo->prepare('SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ? LIMIT 1');
        $stmt->execute([$table, $column]);
        return (bool)$stmt->fetchColumn();
    } catch (Throwable $ignored) { return false; }
};

$runtimeChecks = [
    ['PHP version', PHP_VERSION_ID >= 80100, PHP_VERSION_ID >= 80100 ? PHP_VERSION . ' · supported baseline' : PHP_VERSION . ' · PHP 8.1+ is recommended'],
    ['MySQL connection', true, 'Connected to the configured database; this page loads after the database connection succeeds'],
    ['PDO', extension_loaded('pdo'), extension_loaded('pdo') ? 'PDO extension enabled' : 'Enable PDO in the selected PHP runtime'],
    ['PDO MySQL', extension_loaded('pdo_mysql'), extension_loaded('pdo_mysql') ? 'Database driver enabled' : 'Enable pdo_mysql in XAMPP PHP'],
    ['cURL', extension_loaded('curl'), extension_loaded('curl') ? 'Available for Judge0 requests' : 'Enable the cURL extension to use Judge0'],
    ['mbstring', extension_loaded('mbstring'), extension_loaded('mbstring') ? 'Available for UTF-8 text handling' : 'Enable mbstring; application pages use multibyte text helpers'],
    ['Session cookie', !empty(session_get_cookie_params()['httponly']), !empty(session_get_cookie_params()['httponly']) ? 'HttpOnly is enabled' : 'Review session cookie settings'],
    ['HTTPS / local development', ((isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== '' && strtolower((string)$_SERVER['HTTPS']) !== 'off') || in_array(strtolower((string)($_SERVER['HTTP_HOST'] ?? 'localhost')), ['localhost','127.0.0.1','localhost:80','localhost:8080'], true)), 'Local XAMPP may use HTTP; use HTTPS before exposing CodeArena outside your computer'],
];
foreach ($runtimeChecks as [$label,$ok,$detail]) $pushCheck('Application runtime', $label, $ok ? 'ok' : 'bad', $detail);

foreach ($featureGroups as $group => $definition) {
    $missing = [];
    foreach ($definition['tables'] as $table => $columns) {
        if (!$tableExists($table)) {
            $missing[] = $table . ' (table)';
            continue;
        }
        foreach ($columns as $column) {
            if (!$columnExists($table, $column)) $missing[] = $table . '.' . $column;
        }
    }
    $state = !$missing ? 'ok' : 'warn';
    $detail = !$missing ? 'All required tables and columns are present.' : 'Missing: ' . implode(', ', $missing) . '. Check ' . $definition['migration'] . '.';
    $pushCheck('Database features', $group, $state, $detail);
}

$requiredFiles = [
    'public/index.php' => 'Public homepage',
    'public/student-classrooms.php' => 'Student classrooms',
    'public/student-progress.php' => 'Student progress',
    'public/leaderboard.php' => 'Leaderboard',
    'public/exercise.php' => 'Exercise workspace',
    'public/run.php' => 'Run Code endpoint',
    'public/submit.php' => 'Submit Answer endpoint',
    'public/teacher.php' => 'Teacher Studio',
    'public/teacher-gradebook.php' => 'Teacher gradebook',
    'public/teacher-submission.php' => 'Submission inspector',
    'public/teacher-monitoring.php' => 'Exam monitoring',
    'public/teacher-lessons.php' => 'Teacher lesson builder',
    'public/student-lessons.php' => 'Student lessons',
    'public/student-lesson.php' => 'Student lesson detail',
    'public/student-submissions.php' => 'Student submission history',
    'public/student-achievements.php' => 'Student achievements',
    'public/teacher-regrade.php' => 'Teacher regrade workflow',
    'public/super-admin/users.php' => 'Super Admin user management',
    'public/super-admin/index.php' => 'Super Admin control center',
    'public/super-admin/system-health.php' => 'System Health page',
    'database/schema.sql' => 'Fresh-install database schema',
    'database/seeds/all_language_learning_paths_30.sql' => 'Seven-language learning-path seed',
    'tools/check_project.sh' => 'Static check script',
    'tools/health_check.php' => 'CLI health check',
    'tools/backup_database.sh' => 'Database backup utility',
    'tools/restore_database.sh' => 'Database restore utility',
    'tools/.htaccess' => 'CLI tools web-access restriction',
    'config/.htaccess' => 'Config web-access restriction',
    'database/.htaccess' => 'Database files web-access restriction',
    'tests/REGRESSION_CHECKLIST.md' => 'Regression checklist',
    'tests/ALL_PRIORITIES_V23.md' => 'All-priorities regression checklist',
    'tests/DEPLOYMENT_CHECKLIST_V23.md' => 'Deployment readiness checklist',
    'database/migrations/010_lessons_feedback_school_workflows_achievements.sql' => 'Lesson and school-workflow migration',
    'database/migrations/011_exercise_hints_and_regrade_history.sql' => 'Hints and regrade-history migration',
    'tools/v23_smoke_test.php' => 'v23 database smoke test',
];
foreach ($requiredFiles as $relative => $label) {
    $ok = is_file($projectRoot . '/' . $relative);
    $pushCheck('Application files', $label, $ok ? 'ok' : 'bad', $ok ? 'File is present.' : 'Missing file: ' . $relative);
}

$judge = $config['judge0'] ?? [];
$judgeBase = trim((string)($judge['base_url'] ?? ''));
$judgeParts = $judgeBase !== '' ? parse_url($judgeBase) : false;
$judgeConfigured = is_array($judgeParts)
    && !empty($judgeParts['host'])
    && in_array(strtolower((string)($judgeParts['scheme'] ?? '')), ['http','https'], true)
    && filter_var($judgeBase, FILTER_VALIDATE_URL) !== false;
$hostOnly = is_array($judgeParts) ? (string)($judgeParts['host'] ?? 'unknown host') : 'not configured';
$pushCheck('Judge0 execution service', 'Endpoint URL', $judgeConfigured ? 'ok' : 'bad', $judgeConfigured ? $hostOnly . ' · endpoint configured; path and credentials hidden' : 'Set a valid http(s) judge0.base_url in config/config.php.');
$apiKey = trim((string)($judge['api_key'] ?? ''));
$keyLooksPlaceholder = in_array($apiKey, ['', 'PUT_YOUR_API_KEY_HERE', 'YOUR_API_KEY'], true);
$pushCheck('Judge0 execution service', 'Authentication configuration', $keyLooksPlaceholder ? 'warn' : 'ok', $keyLooksPlaceholder ? 'No non-placeholder API key is configured. This is acceptable only when your provider explicitly allows unauthenticated access.' : 'A configured key value is present; the key is never displayed.');
$langs = $judge['languages'] ?? [];
$requiredLangs = ['c','cpp','java','python','php','ruby'];
$missingLangs = [];
foreach ($requiredLangs as $lang) if (!isset($langs[$lang]) || !is_numeric($langs[$lang]) || (int)$langs[$lang] < 1) $missingLangs[] = $lang;
$pushCheck('Judge0 execution service', 'Language IDs', !$missingLangs ? 'ok' : 'warn', !$missingLangs ? 'IDs configured for C, C++, Java, Python, PHP, and Ruby. Verify IDs against your provider.' : 'Missing or invalid IDs: ' . implode(', ', $missingLangs) . '.');

$routeCount = count($requiredFiles);
$routesPresent = count(array_filter($checks, static fn(array $c): bool => $c['group'] === 'Application files' && $c['state'] === 'ok'));
$featureReady = count(array_filter($checks, static fn(array $c): bool => $c['group'] === 'Database features' && $c['state'] === 'ok'));
$featureTotal = count($featureGroups);
$studentCount = $teacherCount = $exerciseCount = $submissionCount = $activeAttemptCount = 0;
try {
    $studentCount = (int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='student'")->fetchColumn();
    $teacherCount = (int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='teacher'")->fetchColumn();
    $exerciseCount = (int)$pdo->query('SELECT COUNT(*) FROM exercises')->fetchColumn();
    $submissionCount = (int)$pdo->query('SELECT COUNT(*) FROM submissions')->fetchColumn();
    $activeAttemptCount = (int)$pdo->query("SELECT COUNT(*) FROM attempts WHERE status='in_progress' AND deadline_at >= NOW()")->fetchColumn();
} catch (Throwable $ignored) {
    // The feature checks will show any missing core table/column; do not leak raw DB errors.
}

$probeResult = null;
if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    verify_csrf();
    $action = (string)($_POST['health_action'] ?? '');
    if ($action === 'judge0_connectivity') {
        if (!$judgeConfigured) {
            $probeResult = ['state'=>'bad','title'=>'Judge0 endpoint test','detail'=>'No valid Judge0 endpoint is configured. Check config/config.php.'];
        } elseif (!extension_loaded('curl')) {
            $probeResult = ['state'=>'bad','title'=>'Judge0 endpoint test','detail'=>'PHP cURL is not enabled in the XAMPP runtime.'];
        } else {
            $response = judge0_http_json(rtrim($judgeBase, '/') . '/system_info', 'GET', judge0_request_headers($judge), null, 8);
            $http = (int)$response['http'];
            if ($response['body'] !== false && $http >= 200 && $http < 300) {
                $probeResult = ['state'=>'ok','title'=>'Judge0 endpoint test','detail'=>'Endpoint responded successfully with HTTP ' . $http . '. This confirms connectivity, not full code execution.'];
            } elseif ($response['body'] !== false && in_array($http, [401,403], true)) {
                $probeResult = ['state'=>'warn','title'=>'Judge0 endpoint test','detail'=>'The host is reachable but returned HTTP ' . $http . '. Check the provider authentication header, key, or endpoint access.'];
            } elseif ($response['body'] !== false && $http === 404) {
                $probeResult = ['state'=>'warn','title'=>'Judge0 endpoint test','detail'=>'The host is reachable but /system_info returned HTTP 404. This provider may not expose that route; test a code execution below.'];
            } elseif ($response['body'] !== false && $http === 429) {
                $probeResult = ['state'=>'warn','title'=>'Judge0 endpoint test','detail'=>'The endpoint is reachable but rate-limited (HTTP 429). Check provider limits and retry later.'];
            } elseif ($response['body'] !== false) {
                $probeResult = ['state'=>'warn','title'=>'Judge0 endpoint test','detail'=>'The host responded with HTTP ' . $http . '. Review the provider documentation and endpoint URL.'];
            } else {
                $curlError = preg_replace('/[\r\n\x00-\x1F]+/', ' ', (string)$response['error']);
                $probeResult = ['state'=>'bad','title'=>'Judge0 endpoint test','detail'=>'Connection failed' . ($curlError ? ': ' . substr($curlError, 0, 180) : '. Check DNS, internet access, and endpoint hostname.')];
            }
            audit_log($pdo, (int)$user['id'], 'system_health_judge0_connectivity', 'system_health', null, ['state'=>$probeResult['state'],'http_status'=>$http,'host'=>$hostOnly]);
        }
    } elseif ($action === 'judge0_execution') {
        if (!$judgeConfigured || !extension_loaded('curl')) {
            $probeResult = ['state'=>'bad','title'=>'Judge0 execution smoke test','detail'=>'Configure a valid Judge0 URL and enable PHP cURL before running this test.'];
        } elseif (!isset($langs['python']) || !is_numeric($langs['python']) || (int)$langs['python'] < 1) {
            $probeResult = ['state'=>'bad','title'=>'Judge0 execution smoke test','detail'=>'A valid Python language ID is missing from config/config.php.'];
        } else {
            try {
                $result = judge0_execute($judge, 'python', 'print("CODEARENA_HEALTH_OK")', '');
                $statusId = judge0_result_status_id($result);
                $stdout = normalize_output((string)($result['stdout'] ?? ''));
                $description = (string)($result['status']['description'] ?? 'Unknown status');
                $success = $statusId === 3 && $stdout === 'CODEARENA_HEALTH_OK';
                $probeResult = [
                    'state'=>$success ? 'ok' : 'bad',
                    'title'=>'Judge0 execution smoke test',
                    'detail'=>$success ? 'Python compiled and returned the expected marker. One test execution succeeded.' : 'Judge0 returned “' . substr($description,0,80) . '”. Expected an Accepted result and the standard test marker.',
                ];
                audit_log($pdo, (int)$user['id'], 'system_health_judge0_execution_test', 'system_health', null, ['success'=>$success,'status_id'=>$statusId]);
            } catch (Throwable $exception) {
                $message = preg_replace('/[\r\n\x00-\x1F]+/', ' ', $exception->getMessage());
                $probeResult = ['state'=>'bad','title'=>'Judge0 execution smoke test','detail'=>substr($message ?: 'Execution test failed. Review the endpoint settings and provider logs.', 0, 220)];
                audit_log($pdo, (int)$user['id'], 'system_health_judge0_execution_test', 'system_health', null, ['success'=>false,'error_class'=>get_class($exception)]);
            }
        }
    }
}

admin_header('System health', 'health');
?>
<section class="admin-page-intro health-intro">
  <div><p class="admin-kicker">PLATFORM RELIABILITY</p><h2>System health</h2><p>Check CodeArena's runtime, database feature groups, core routes, and Judge0 connection. Diagnostics never display API keys or database passwords.</p></div>
  <span class="directory-count">Updated <?= e(date('M j, Y · g:i A')) ?></span>
</section>
<?php if ($probeResult): ?><div class="health-probe-result <?= e($probeResult['state']) ?>" role="status"><span class="health-result-icon"><?= $probeResult['state']==='ok'?'✓':($probeResult['state']==='warn'?'!':'×') ?></span><div><strong><?= e($probeResult['title']) ?></strong><p><?= e($probeResult['detail']) ?></p></div></div><?php endif; ?>
<section class="stat-grid health-stat-grid">
  <article class="stat-card"><div class="stat-top"><span>Students</span><span class="stat-symbol student-symbol">♙</span></div><strong><?= number_format($studentCount) ?></strong><small>Registered learners</small><span class="stat-accent student-accent"></span></article>
  <article class="stat-card"><div class="stat-top"><span>Teachers</span><span class="stat-symbol teacher-symbol">⌘</span></div><strong><?= number_format($teacherCount) ?></strong><small>Teaching accounts</small><span class="stat-accent teacher-accent"></span></article>
  <article class="stat-card"><div class="stat-top"><span>Exercises</span><span class="stat-symbol exercise-symbol">&lt;/&gt;</span></div><strong><?= number_format($exerciseCount) ?></strong><small>Created challenges</small><span class="stat-accent exercise-accent"></span></article>
  <article class="stat-card"><div class="stat-top"><span>Active attempts</span><span class="stat-symbol submission-symbol">◷</span></div><strong><?= number_format($activeAttemptCount) ?></strong><small><?= number_format($submissionCount) ?> submissions stored</small><span class="stat-accent submission-accent"></span></article>
</section>
<section class="health-summary-grid">
  <article class="health-summary-card"><div class="health-summary-icon">⚙</div><div><span>Required project files</span><strong><?= $routesPresent ?>/<?= $routeCount ?> present</strong><small><?= $routesPresent === $routeCount ? 'Core pages, schema, seeds, and maintenance tools are available.' : 'One or more required project files are missing.' ?></small></div><span class="health-status <?= $routesPresent === $routeCount ? 'ok' : 'bad' ?>"><?= $routesPresent === $routeCount ? 'Ready' : 'Check' ?></span></article>
  <article class="health-summary-card"><div class="health-summary-icon database">▤</div><div><span>Database features</span><strong><?= $featureReady ?>/<?= $featureTotal ?> ready</strong><small>Feature readiness is based on required tables and columns.</small></div><span class="health-status <?= $featureReady === $featureTotal ? 'ok' : 'warn' ?>"><?= $featureReady === $featureTotal ? 'Ready' : 'Review' ?></span></article>
  <article class="health-summary-card"><div class="health-summary-icon runtime">◉</div><div><span>Server runtime</span><strong>PHP <?= e(PHP_VERSION) ?></strong><small>Checks PHP extensions used by CodeArena.</small></div><span class="health-status <?= count(array_filter($checks, static fn(array $c): bool => $c['group']==='Application runtime' && $c['state']==='bad'))===0 ? 'ok':'bad' ?>"><?= count(array_filter($checks, static fn(array $c): bool => $c['group']==='Application runtime' && $c['state']==='bad'))===0 ? 'Ready':'Check' ?></span></article>
</section>
<section class="health-two-col">
  <article class="admin-panel"><div class="admin-panel-head"><div><h3>Runtime checks</h3><p>PHP and extension availability</p></div></div><div class="health-check-list">
  <?php foreach (array_filter($checks, static fn(array $c): bool => $c['group']==='Application runtime') as $item): ?><div class="health-check-row"><span class="health-state-dot <?= e($item['state']) ?>"></span><div><strong><?= e($item['label']) ?></strong><p><?= e($item['detail']) ?></p></div><span class="health-status <?= e($item['state']) ?>"><?= $item['state']==='ok'?'Ready':'Check' ?></span></div><?php endforeach; ?>
  </div></article>
  <article class="admin-panel"><div class="admin-panel-head"><div><h3>Judge0 execution service</h3><p>Connection and real execution are tested only when you request them.</p></div></div><div class="health-judge0-body"><div class="health-endpoint-row"><span class="health-endpoint-icon">&lt;/&gt;</span><div><strong><?= $judgeConfigured ? e($hostOnly) : 'Endpoint not configured' ?></strong><small><?= $judgeConfigured ? 'Configured endpoint · credentials hidden' : 'Set judge0.base_url in config/config.php' ?></small></div></div><div class="health-language-list"><span>Language IDs</span><?php foreach ($requiredLangs as $lang): ?><span class="health-language-pill <?= isset($langs[$lang]) && is_numeric($langs[$lang]) && (int)$langs[$lang]>0 ? 'configured':'missing' ?>"><?= e(strtoupper($lang)) ?></span><?php endforeach; ?></div>
  <form method="post" class="health-probe-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="health_action" value="judge0_connectivity"><button class="admin-button" type="submit">Check endpoint</button></form>
  <form method="post" class="health-probe-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="health_action" value="judge0_execution"><button class="mini-admin-button" type="submit">Run Python execution test</button></form>
  <p class="health-small-note">The execution test submits one small Python program to Judge0 and may consume your provider quota. Run it only when needed.</p>
  </div></article>
</section>
<section class="admin-panel health-features-panel"><div class="admin-panel-head"><div><h3>Database feature readiness</h3><p>Missing items show which migration or schema group to review.</p></div><span class="directory-count"><?= $featureReady ?>/<?= $featureTotal ?> ready</span></div><div class="health-feature-grid">
<?php foreach ($featureGroups as $group=>$definition): $item = null; foreach ($checks as $candidate) if ($candidate['group']==='Database features' && $candidate['label']===$group) {$item=$candidate;break;} if (!$item) continue; ?><article class="health-feature-card"><div class="health-feature-head"><h4><?= e($group) ?></h4><span class="health-status <?= e($item['state']) ?>"><?= $item['state']==='ok'?'Ready':'Review' ?></span></div><p><?= e($item['detail']) ?></p></article><?php endforeach; ?>
</div></section>
<section class="health-two-col">
  <article class="admin-panel"><div class="admin-panel-head"><div><h3>Required project files</h3><p>These checks confirm important files exist, not that each route has been browser-tested.</p></div><span class="directory-count"><?= $routesPresent ?>/<?= $routeCount ?></span></div><div class="health-check-list">
  <?php foreach (array_filter($checks, static fn(array $c): bool => $c['group']==='Application files') as $item): ?><div class="health-check-row"><span class="health-state-dot <?= e($item['state']) ?>"></span><div><strong><?= e($item['label']) ?></strong><p><?= e($item['detail']) ?></p></div><span class="health-status <?= e($item['state']) ?>"><?= $item['state']==='ok'?'Present':'Missing' ?></span></div><?php endforeach; ?>
  </div></article>
  <article class="admin-panel"><div class="admin-panel-head"><div><h3>Backups and recovery</h3><p>Local maintenance tools for this XAMPP installation</p></div></div><div class="health-recovery-body"><div class="health-recovery-item"><span>1</span><div><strong>Back up the database</strong><code>./tools/backup_database.sh</code><p>Writes a SQL backup outside the web root by default.</p></div></div><div class="health-recovery-item"><span>2</span><div><strong>Validate a restore safely</strong><code>./tools/restore_database.sh "$HOME/CodeArenaBackups/backup.sql" codearena_restore_test</code><p>Restores into a new database and refuses to overwrite an existing target.</p></div></div><div class="health-recovery-note">Keep at least one backup on a separate drive or secure location. Test restore before any production upgrade.</div></div></article>
</section>
<?php admin_footer(); ?>
