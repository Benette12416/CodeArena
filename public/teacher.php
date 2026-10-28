<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$topicOptions = ['Fundamentals','Variables & Types','Conditionals','Loops','Functions','Arrays','Strings','Math','Algorithms','Object-Oriented Programming','Other'];

function teacher_exercise_redirect(int $exerciseId = 0): never {
    redirect('teacher.php' . ($exerciseId > 0 ? '#exercise-' . $exerciseId : '#challenge-builder'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');

    if ($action === 'update_monitoring') {
        $exerciseId = (int)($_POST['exercise_id'] ?? 0);
        $enabled = isset($_POST['monitoring_enabled']) ? 1 : 0;
        $threshold = max(1, min(10, (int)($_POST['warning_threshold'] ?? 3)));
        $owned = $pdo->prepare('SELECT id FROM exercises WHERE id = ? AND created_by = ?');
        $owned->execute([$exerciseId, (int)$user['id']]);
        if (!$owned->fetchColumn()) {
            flash('Exercise not found or you do not have permission to edit it.', 'error');
        } else {
            $stmt = $pdo->prepare('UPDATE exercises SET monitoring_enabled = ?, warning_threshold = ? WHERE id = ? AND created_by = ?');
            $stmt->execute([$enabled, $threshold, $exerciseId, (int)$user['id']]);
            store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Monitoring settings changed');
            audit_log($pdo, (int)$user['id'], 'monitoring_settings_changed', 'exercise', $exerciseId, ['enabled'=>(bool)$enabled,'threshold'=>$threshold]);
            flash('Exam monitoring settings saved. Changes apply to new attempts.', 'success');
        }
        teacher_exercise_redirect($exerciseId);
    }

    if ($action === 'create') {
        $title = trim((string)($_POST['title'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));
        $hintText = trim((string)($_POST['hint_text'] ?? ''));
        $difficulty = (string)($_POST['difficulty'] ?? 'Easy');
        $topic = trim((string)($_POST['topic'] ?? 'Fundamentals'));
        if (!in_array($topic, $topicOptions, true)) $topic = 'Fundamentals';
        $minutes = max(1, min(120, (int)($_POST['time_limit_minutes'] ?? 10)));
        $limitSeconds = $minutes * 60;
        $points = max(1, min(10000, (int)($_POST['points'] ?? 100)));
        $starter = (string)($_POST['starter_code'] ?? '');
        $input = (string)($_POST['stdin'] ?? '');
        $expected = (string)($_POST['expected_output'] ?? '');
        $monitoringEnabled = isset($_POST['monitoring_enabled']) ? 1 : 0;
        $warningThreshold = max(1, min(10, (int)($_POST['warning_threshold'] ?? 3)));

        if ($title === '' || $description === '' || mb_strlen($hintText) > 8000 || !in_array($difficulty, ['Easy', 'Medium', 'Hard'], true)) {
            flash('Enter a title, description, and valid difficulty.', 'error');
            teacher_exercise_redirect();
        }
        if (mb_strlen($title) > 180) {
            flash('Exercise titles must be 180 characters or fewer.', 'error');
            teacher_exercise_redirect();
        }

        $slug = slugify($title) . '-' . bin2hex(random_bytes(3));
        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare('INSERT INTO exercises(title, slug, description, hint_text, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)');
            $stmt->execute([$title, $slug, $description, $hintText !== '' ? $hintText : null, $difficulty, $topic, $limitSeconds, $points, $starter, isset($_POST['publish']) ? 1 : 0, $monitoringEnabled, $warningThreshold, (int)$user['id']]);
            $exerciseId = (int)$pdo->lastInsertId();
            if (trim($expected) !== '' || trim($input) !== '') {
                $test = $pdo->prepare('INSERT INTO test_cases(exercise_id, stdin, expected_output, is_sample, sort_order) VALUES(?,?,?,?,?)');
                $test->execute([$exerciseId, $input, $expected, isset($_POST['sample']) ? 1 : 0, 0]);
            }
            store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Exercise created');
            $pdo->commit();
            audit_log($pdo, (int)$user['id'], 'exercise_created', 'exercise', $exerciseId, ['topic' => $topic, 'published' => isset($_POST['publish'])]);
            flash('Exercise created. The time limit is saved as ' . $minutes . ' minute' . ($minutes === 1 ? '' : 's') . '.', 'success');
            teacher_exercise_redirect($exerciseId);
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            flash('Could not create the exercise. Check the form and database configuration.', 'error');
            teacher_exercise_redirect();
        }
    }

    if ($action === 'update_exercise') {
        $exerciseId = (int)($_POST['exercise_id'] ?? 0);
        $title = trim((string)($_POST['title'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));
        $hintText = trim((string)($_POST['hint_text'] ?? ''));
        $difficulty = (string)($_POST['difficulty'] ?? 'Easy');
        $topic = trim((string)($_POST['topic'] ?? 'Fundamentals'));
        if (!in_array($topic, $topicOptions, true)) $topic = 'Fundamentals';
        $minutes = max(1, min(120, (int)($_POST['time_limit_minutes'] ?? 10)));
        $limitSeconds = $minutes * 60;
        $points = max(1, min(10000, (int)($_POST['points'] ?? 100)));
        $starter = (string)($_POST['starter_code'] ?? '');
        $monitoringEnabled = isset($_POST['monitoring_enabled']) ? 1 : 0;
        $warningThreshold = max(1, min(10, (int)($_POST['warning_threshold'] ?? 3)));

        $owned = $pdo->prepare('SELECT id FROM exercises WHERE id = ? AND created_by = ?');
        $owned->execute([$exerciseId, (int)$user['id']]);
        if (!$owned->fetchColumn()) {
            flash('Exercise not found or you do not have permission to edit it.', 'error');
            teacher_exercise_redirect();
        }
        if ($title === '' || mb_strlen($title) > 180 || $description === '' || mb_strlen($hintText) > 8000 || !in_array($difficulty, ['Easy', 'Medium', 'Hard'], true)) {
            flash('Enter a title (180 characters maximum), description, and valid difficulty.', 'error');
            teacher_exercise_redirect($exerciseId);
        }

        $pdo->beginTransaction();
        try {
            $update = $pdo->prepare('UPDATE exercises SET title=?, description=?, hint_text=?, difficulty=?, topic=?, time_limit_seconds=?, points=?, starter_code=?, is_published=?, monitoring_enabled=?, warning_threshold=? WHERE id=? AND created_by=?');
            $update->execute([$title, $description, $hintText !== '' ? $hintText : null, $difficulty, $topic, $limitSeconds, $points, $starter, isset($_POST['publish']) ? 1 : 0, $monitoringEnabled, $warningThreshold, $exerciseId, (int)$user['id']]);

            // Each edit produces an immutable snapshot; active attempts continue using their original version.
            store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Exercise details edited');
            $pdo->commit();
            audit_log($pdo, (int)$user['id'], 'exercise_updated', 'exercise', $exerciseId, ['topic' => $topic, 'published' => isset($_POST['publish'])]);
            flash('Exercise updated successfully. The new time limit applies to new attempts; attempts already in progress keep their original deadline.', 'success');
            teacher_exercise_redirect($exerciseId);
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            flash('Could not update the exercise. Please review the fields and try again.', 'error');
            teacher_exercise_redirect($exerciseId);
        }
    }

    if ($action === 'restore_exercise_version') {
        $exerciseId = max(0, (int)($_POST['exercise_id'] ?? 0));
        $versionId = max(0, (int)($_POST['version_id'] ?? 0));
        $own = $pdo->prepare('SELECT id FROM exercises WHERE id=? AND created_by=?');
        $own->execute([$exerciseId, (int)$user['id']]);
        $versionStmt = $pdo->prepare('SELECT snapshot_json,version_number FROM exercise_versions WHERE id=? AND exercise_id=? AND created_by=?');
        $versionStmt->execute([$versionId, $exerciseId, (int)$user['id']]);
        $version = $versionStmt->fetch();
        if (!$own->fetchColumn() || !$version) { flash('Version not found or outside your teaching scope.', 'error'); teacher_exercise_redirect($exerciseId); }
        $snapshot = json_decode((string)$version['snapshot_json'], true);
        if (!is_array($snapshot) || !is_array($snapshot['exercise'] ?? null) || !is_array($snapshot['test_cases'] ?? null)) { flash('This version snapshot is invalid.', 'error'); teacher_exercise_redirect($exerciseId); }
        $v = $snapshot['exercise'];
        $pdo->beginTransaction();
        try {
            $upd = $pdo->prepare('UPDATE exercises SET title=?,description=?,hint_text=?,difficulty=?,topic=?,time_limit_seconds=?,points=?,starter_code=?,is_published=?,monitoring_enabled=?,warning_threshold=? WHERE id=? AND created_by=?');
            $upd->execute([(string)$v['title'],(string)$v['description'],(string)($v['hint_text'] ?? ''),(string)$v['difficulty'],(string)$v['topic'],(int)$v['time_limit_seconds'],(int)$v['points'],(string)($v['starter_code'] ?? ''),(int)$v['is_published'],(int)$v['monitoring_enabled'],(int)$v['warning_threshold'],$exerciseId,(int)$user['id']]);
            $pdo->prepare('DELETE FROM test_cases WHERE exercise_id=?')->execute([$exerciseId]);
            $ins = $pdo->prepare('INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) VALUES(?,?,?,?,?)');
            foreach ($snapshot['test_cases'] as $case) $ins->execute([$exerciseId,(string)($case['stdin']??''),(string)($case['expected_output']??''),(int)($case['is_sample']??0),(int)($case['sort_order']??0)]);
            store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Restored from version ' . (int)$version['version_number']);
            $pdo->commit();
            audit_log($pdo, (int)$user['id'], 'exercise_version_restored', 'exercise', $exerciseId, ['restored_version_id'=>$versionId,'restored_version_number'=>(int)$version['version_number']]);
            flash('Exercise restored from version ' . (int)$version['version_number'] . '. Existing student attempts remain pinned to their original snapshots.', 'success');
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            flash('Could not restore that version. No changes were saved.', 'error');
        }
        teacher_exercise_redirect($exerciseId);
    }

    if ($action === 'delete_exercise') {
        $exerciseId = max(0, (int)($_POST['exercise_id'] ?? 0));
        $owned = $pdo->prepare('SELECT title FROM exercises WHERE id = ? AND created_by = ?');
        $owned->execute([$exerciseId, (int)$user['id']]);
        $exerciseTitle = $owned->fetchColumn();
        if ($exerciseTitle === false) {
            flash('Exercise not found or you do not have permission to delete it.', 'error');
            teacher_exercise_redirect();
        }

        try {
            // The schema's foreign keys cascade to test cases, attempts, submissions,
            // monitoring events/reviews, classroom assignments, and assignment grade records.
            $delete = $pdo->prepare('DELETE FROM exercises WHERE id = ? AND created_by = ?');
            $delete->execute([$exerciseId, (int)$user['id']]);
            if ($delete->rowCount() !== 1) {
                flash('The exercise was not deleted. It may already have been removed.', 'error');
            } else {
                audit_log($pdo, (int)$user['id'], 'exercise_deleted', 'exercise', $exerciseId, ['title' => (string)$exerciseTitle]);
                flash('Exercise deleted permanently, including its test cases, assignments, attempts, submissions, grades, and monitoring history.', 'success');
            }
        } catch (Throwable $e) {
            flash('Could not delete this exercise. No changes were saved. Please check related database records and try again.', 'error');
        }
        teacher_exercise_redirect();
    }

    if (in_array($action, ['update_test_case', 'add_test_case', 'delete_test_case'], true)) {
        $exerciseId = (int)($_POST['exercise_id'] ?? 0);
        $owned = $pdo->prepare('SELECT id FROM exercises WHERE id = ? AND created_by = ?');
        $owned->execute([$exerciseId, (int)$user['id']]);
        if (!$owned->fetchColumn()) {
            flash('Exercise not found or you do not have permission to edit it.', 'error');
            teacher_exercise_redirect();
        }

        if ($action === 'update_test_case') {
            $testCaseId = (int)($_POST['test_case_id'] ?? 0);
            $testInput = (string)($_POST['test_stdin'] ?? '');
            $testExpected = (string)($_POST['test_expected_output'] ?? '');
            $testSample = isset($_POST['test_is_sample']) ? 1 : 0;
            $caseCheck = $pdo->prepare('SELECT id FROM test_cases WHERE id = ? AND exercise_id = ?');
            $caseCheck->execute([$testCaseId, $exerciseId]);
            if (!$caseCheck->fetchColumn()) {
                flash('Test case not found for this exercise.', 'error');
                teacher_exercise_redirect($exerciseId);
            }
            $saveCase = $pdo->prepare('UPDATE test_cases SET stdin = ?, expected_output = ?, is_sample = ? WHERE id = ? AND exercise_id = ?');
            $saveCase->execute([$testInput, $testExpected, $testSample, $testCaseId, $exerciseId]);
            store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Test case edited');
            audit_log($pdo, (int)$user['id'], 'exercise_test_case_updated', 'exercise', $exerciseId, ['test_case_id'=>$testCaseId]);
            flash('Test case updated. Hidden test input and expected output remain private to students.', 'success');
            teacher_exercise_redirect($exerciseId);
        }

        if ($action === 'add_test_case') {
            $testInput = (string)($_POST['test_stdin'] ?? '');
            $testExpected = (string)($_POST['test_expected_output'] ?? '');
            $testSample = isset($_POST['test_is_sample']) ? 1 : 0;
            $orderStmt = $pdo->prepare('SELECT COALESCE(MAX(sort_order), -1) + 1 FROM test_cases WHERE exercise_id = ?');
            $orderStmt->execute([$exerciseId]);
            $nextOrder = (int)$orderStmt->fetchColumn();
            $insertCase = $pdo->prepare('INSERT INTO test_cases(exercise_id, stdin, expected_output, is_sample, sort_order) VALUES(?,?,?,?,?)');
            $insertCase->execute([$exerciseId, $testInput, $testExpected, $testSample, $nextOrder]);
            store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Test case added');
            audit_log($pdo, (int)$user['id'], 'exercise_test_case_added', 'exercise', $exerciseId, ['sort_order'=>$nextOrder]);
            flash('New test case added to the exercise.', 'success');
            teacher_exercise_redirect($exerciseId);
        }

        if ($action === 'delete_test_case') {
            $testCaseId = (int)($_POST['test_case_id'] ?? 0);
            $countStmt = $pdo->prepare('SELECT COUNT(*) FROM test_cases WHERE exercise_id = ?');
            $countStmt->execute([$exerciseId]);
            $testCount = (int)$countStmt->fetchColumn();
            if ($testCount <= 1) {
                flash('Keep at least one test case for automatic grading. Edit this case or add another before deleting it.', 'error');
                teacher_exercise_redirect($exerciseId);
            }
            $deleteCase = $pdo->prepare('DELETE FROM test_cases WHERE id = ? AND exercise_id = ?');
            $deleteCase->execute([$testCaseId, $exerciseId]);
            if ($deleteCase->rowCount()) { store_exercise_version($pdo, $exerciseId, (int)$user['id'], 'Test case deleted'); audit_log($pdo, (int)$user['id'], 'exercise_test_case_deleted', 'exercise', $exerciseId, ['test_case_id'=>$testCaseId]); }
            flash($deleteCase->rowCount() ? 'Test case deleted.' : 'Test case not found.', $deleteCase->rowCount() ? 'success' : 'error');
            teacher_exercise_redirect($exerciseId);
        }
    }
}

$stmt = $pdo->prepare("SELECT e.*,
    (SELECT COUNT(*) FROM test_cases t WHERE t.exercise_id = e.id) AS test_count,
    (SELECT COUNT(*) FROM exercise_versions ev WHERE ev.exercise_id=e.id) AS version_count
    FROM exercises e WHERE e.created_by = ? ORDER BY e.created_at DESC");
$stmt->execute([(int)$user['id']]);
$rows = $stmt->fetchAll();
$totalExercises = count($rows);
$publishedExercises = count(array_filter($rows, static fn(array $row): bool => (int)$row['is_published'] === 1));
$draftExercises = $totalExercises - $publishedExercises;
$monitoredExercises = count(array_filter($rows, static fn(array $row): bool => (int)$row['monitoring_enabled'] === 1));
$classStmt = $pdo->prepare('SELECT COUNT(*) FROM classrooms WHERE teacher_id=?');
$classStmt->execute([(int)$user['id']]); $teacherClassCount = (int)$classStmt->fetchColumn();
$studentStmt = $pdo->prepare("SELECT COUNT(DISTINCT ce.student_id) FROM class_enrollments ce JOIN classrooms c ON c.id=ce.classroom_id WHERE c.teacher_id=? AND c.is_active=1 AND ce.enrollment_status='active'");
$studentStmt->execute([(int)$user['id']]); $teacherStudentCount = (int)$studentStmt->fetchColumn();
$assignmentStmt = $pdo->prepare("SELECT COUNT(*) FROM class_assignments ca JOIN classrooms c ON c.id=ca.classroom_id WHERE c.teacher_id=? AND ca.is_active=1");
$assignmentStmt->execute([(int)$user['id']]); $teacherAssignmentCount = (int)$assignmentStmt->fetchColumn();
$submissionStmt = $pdo->prepare('SELECT COUNT(*) FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE e.created_by=?');
$submissionStmt->execute([(int)$user['id']]); $teacherSubmissionCount = (int)$submissionStmt->fetchColumn();
$reviewStmt = $pdo->prepare("SELECT COUNT(*) FROM (SELECT a.id FROM attempts a JOIN exercises e ON e.id=a.exercise_id LEFT JOIN monitor_events me ON me.attempt_id=a.id WHERE e.created_by=? AND a.monitoring_enabled=1 GROUP BY a.id,a.warning_threshold HAVING COUNT(me.id)>=a.warning_threshold AND COUNT(me.id)>0) flagged_attempts");
$reviewStmt->execute([(int)$user['id']]); $teacherFlaggedCount = (int)$reviewStmt->fetchColumn();
$activityStmt = $pdo->prepare("SELECT s.id,s.score,s.passed_tests,s.total_tests,s.created_at,u.name AS student_name,e.title AS exercise_title,e.points AS max_points,ev.snapshot_json AS version_snapshot_json FROM submissions s JOIN exercises e ON e.id=s.exercise_id JOIN users u ON u.id=s.user_id LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id WHERE e.created_by=? ORDER BY s.created_at DESC LIMIT 6");
$activityStmt->execute([(int)$user['id']]); $teacherRecentActivity = $activityStmt->fetchAll();
foreach ($teacherRecentActivity as &$activityRow) { if (!empty($activityRow['version_snapshot_json'])) { $snap=json_decode((string)$activityRow['version_snapshot_json'],true); if (is_array($snap['exercise'] ?? null)) { $activityRow['exercise_title']=(string)($snap['exercise']['title'] ?? $activityRow['exercise_title']); $activityRow['max_points']=max(1,(int)($snap['exercise']['points'] ?? $activityRow['max_points'])); } } } unset($activityRow);
$testCasesByExercise = [];
if ($rows) {
    $exerciseIds = array_map(static fn(array $row): int => (int)$row['id'], $rows);
    $placeholders = implode(',', array_fill(0, count($exerciseIds), '?'));
    $caseStmt = $pdo->prepare("SELECT id, exercise_id, stdin, expected_output, is_sample, sort_order FROM test_cases WHERE exercise_id IN ($placeholders) ORDER BY exercise_id, sort_order, id");
    $caseStmt->execute($exerciseIds);
    foreach ($caseStmt->fetchAll() as $testCase) {
        $testCasesByExercise[(int)$testCase['exercise_id']][] = $testCase;
    }
}
page_header('Teacher Studio');
?>
<section class="teacher-welcome teacher-dashboard-hero-v19">
  <div class="teacher-dashboard-intro-v19">
    <p class="eyebrow">TEACHER STUDIO · OVERVIEW</p>
    <h1>Welcome back, <?= e(explode(' ', trim((string)$user['name']))[0] ?: 'teacher') ?>.</h1>
    <p class="muted">Your teaching workspace is ready. Create a challenge, assign it to a class, or review student results.</p>
    <div class="teacher-dashboard-actions-v19"><a class="button" href="#challenge-builder"><span aria-hidden="true">＋</span> Create exercise</a><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Manage classrooms</a></div>
    <div class="teacher-dashboard-assurance-v19"><span><i aria-hidden="true">✓</i> Drafts stay private</span><span><i aria-hidden="true">✓</i> Published work is student-ready</span></div>
  </div>
  <aside class="teacher-workflow-card teacher-workflow-card-v19" aria-label="Teacher workflow: create, assign, review">
    <div class="teacher-workflow-head"><span class="teacher-workflow-command" aria-hidden="true">⌘</span><div><span class="teacher-workflow-kicker">CREATE · ASSIGN · REVIEW</span><strong>Your teaching workflow</strong><small>Three simple steps, one organized workspace.</small></div></div>
    <div class="teacher-workflow-steps">
      <a class="teacher-workflow-step teacher-workflow-step-create" href="#challenge-builder"><span class="teacher-workflow-step-icon" aria-hidden="true">＋</span><span class="teacher-workflow-step-copy"><strong>CREATE</strong><small>Build and test a challenge</small></span><span class="teacher-workflow-step-arrow" aria-hidden="true">↗</span></a>
      <a class="teacher-workflow-step teacher-workflow-step-assign" href="<?= e($config['base_url']) ?>/teacher-classrooms.php"><span class="teacher-workflow-step-icon" aria-hidden="true">▦</span><span class="teacher-workflow-step-copy"><strong>ASSIGN</strong><small>Choose a class and deadline</small></span><span class="teacher-workflow-step-arrow" aria-hidden="true">↗</span></a>
      <a class="teacher-workflow-step teacher-workflow-step-review" href="<?= e($config['base_url']) ?>/teacher-submission.php"><span class="teacher-workflow-step-icon" aria-hidden="true">✓</span><span class="teacher-workflow-step-copy"><strong>REVIEW</strong><small>Inspect scores and submissions</small></span><span class="teacher-workflow-step-arrow" aria-hidden="true">↗</span></a>
    </div>
  </aside>
</section>
<nav class="teacher-studio-nav teacher-studio-nav-v19" aria-label="Teacher Studio sections"><a href="#studio-overview">Overview</a><a href="#challenge-builder">Create exercise</a><a href="#exercise-library">Content library</a><a href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Classrooms</a><a href="<?= e($config['base_url']) ?>/teacher-submission.php">Submissions</a><a href="<?= e($config['base_url']) ?>/teacher-analytics.php">Analytics</a><a href="<?= e($config['base_url']) ?>/teacher-learning-paths.php">Learning paths</a><a href="<?= e($config['base_url']) ?>/teacher-monitoring.php">Exam monitoring<?= $teacherFlaggedCount ? ' · '.$teacherFlaggedCount : '' ?></a></nav>
<div class="teacher-dashboard-section-heading-v19" id="studio-overview"><div><p class="eyebrow">YOUR TEACHING AT A GLANCE</p><h2>Workspace overview</h2><p class="muted">A live summary of the content, classes, and activity you manage.</p></div><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-analytics.php">View analytics ↗</a></div>
<div class="teacher-studio-stats teacher-studio-stats-v10 teacher-studio-stats-v19">
  <article class="panel teacher-stat-card-v19 stat-lavender-v19"><div class="teacher-stat-top-v19"><span class="teacher-stat-icon-v19" aria-hidden="true">{ }</span><span>Exercises</span></div><strong><?= $totalExercises ?></strong><small><?= $publishedExercises ?> published · <?= $draftExercises ?> drafts</small><a href="#exercise-library">Open content library <span aria-hidden="true">↗</span></a></article>
  <article class="panel teacher-stat-card-v19 stat-blue-v19"><div class="teacher-stat-top-v19"><span class="teacher-stat-icon-v19" aria-hidden="true">▦</span><span>Classrooms</span></div><strong><?= $teacherClassCount ?></strong><small>Classes you manage</small><a href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Manage classes <span aria-hidden="true">↗</span></a></article>
  <article class="panel teacher-stat-card-v19 stat-green-v19"><div class="teacher-stat-top-v19"><span class="teacher-stat-icon-v19" aria-hidden="true">♙</span><span>Students</span></div><strong><?= $teacherStudentCount ?></strong><small>Across active classes</small><a href="<?= e($config['base_url']) ?>/teacher-classrooms.php">View rosters <span aria-hidden="true">↗</span></a></article>
  <article class="panel teacher-stat-card-v19 stat-orange-v19"><div class="teacher-stat-top-v19"><span class="teacher-stat-icon-v19" aria-hidden="true">☷</span><span>Assignments</span></div><strong><?= $teacherAssignmentCount ?></strong><small>Active classroom assignments</small><a href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Manage assignments <span aria-hidden="true">↗</span></a></article>
  <article class="panel teacher-stat-card-v19 stat-indigo-v19"><div class="teacher-stat-top-v19"><span class="teacher-stat-icon-v19" aria-hidden="true">&lt;/&gt;</span><span>Submissions</span></div><strong><?= $teacherSubmissionCount ?></strong><small>Saved coding submissions</small><a href="<?= e($config['base_url']) ?>/teacher-submission.php">Review submissions <span aria-hidden="true">↗</span></a></article>
  <article class="panel teacher-stat-card-v19 stat-rose-v19"><div class="teacher-stat-top-v19"><span class="teacher-stat-icon-v19" aria-hidden="true">◉</span><span>Exam reviews</span></div><strong><?= $teacherFlaggedCount ?></strong><small>Attempts at warning threshold</small><a href="<?= e($config['base_url']) ?>/teacher-monitoring.php">Open monitoring <span aria-hidden="true">↗</span></a></article>
</div>
<section class="panel teacher-recent-activity teacher-recent-activity-v19"><div class="section-title"><div><p class="eyebrow">LATEST CLASSROOM ACTIVITY</p><h2>Recent student submissions</h2><p class="muted">A quick view of the latest saved results across your exercises.</p></div><a class="button secondary small" href="<?= e($config['base_url']) ?>/teacher-submission.php">View all submissions ↗</a></div>
<?php if ($teacherRecentActivity): ?><div class="teacher-activity-list"><?php foreach ($teacherRecentActivity as $activity): $scorePercent=(int)round((int)$activity['score']/max(1,(int)$activity['max_points'])*100); $scoreTone=$scorePercent>=100?'score-perfect':($scorePercent>=50?'score-progress':'score-failed'); ?><div class="teacher-activity-row"><span class="activity-avatar"><?= e(strtoupper(mb_substr((string)$activity['student_name'],0,1))) ?></span><span class="teacher-activity-copy"><strong><?= e($activity['student_name']) ?></strong><small><?= e($activity['exercise_title']) ?> · <?= e(date('M j, g:i A',strtotime((string)$activity['created_at']))) ?></small></span><span class="teacher-activity-tests"><?= (int)$activity['passed_tests'] ?>/<?= (int)$activity['total_tests'] ?> tests</span><strong class="teacher-activity-score <?= $scoreTone ?>"><?= (int)$activity['score'] ?>/<?= (int)$activity['max_points'] ?></strong></div><?php endforeach; ?></div><?php else: ?><div class="teacher-empty-activity-v19"><span class="teacher-empty-mark-v19" aria-hidden="true">↗</span><div><strong>No submissions yet</strong><p>Once students submit their code, their latest results will appear here. Publish an exercise and assign it to a classroom to get started.</p></div><a class="button secondary small" href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Open classrooms</a></div><?php endif; ?></section>
<section class="teacher-builder-section" id="challenge-builder">
  <div class="section-title teacher-page-section-title">
    <div><p class="eyebrow">CONTENT AUTHORING</p><h2>Create an exercise</h2><p class="muted">Build a challenge, define how it is graded, then save it as a draft or publish it for students.</p></div>
    <span class="builder-step-count"><span><?= $totalExercises ?></span> exercises in your library</span>
  </div>
  <form class="create-exercise-builder panel" method="post" id="create-exercise-form">
    <input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="create">
    <div class="builder-main">
      <section class="builder-step" aria-labelledby="builder-basics-title">
        <div class="builder-step-heading"><span class="builder-step-number">01</span><div><h3 id="builder-basics-title">Exercise basics</h3><p>Give your challenge a clear name, skill topic, difficulty, time, and score.</p></div></div>
        <div class="builder-field-block">
          <label>Exercise title <span class="required-mark">Required</span><input name="title" id="builderTitle" required maxlength="180" placeholder="e.g. Sum of Two Numbers"></label>
        </div>
        <div class="builder-field-grid builder-meta-fields">
          <label>Difficulty<select name="difficulty" id="builderDifficulty"><option>Easy</option><option>Medium</option><option>Hard</option></select><small class="field-hint">Choose the expected skill level.</small></label>
          <label>Topic / skill<select name="topic" id="builderTopic"><?php foreach ($topicOptions as $topicOption): ?><option value="<?= e($topicOption) ?>"><?= e($topicOption) ?></option><?php endforeach; ?></select><small class="field-hint">Used in learning paths and your skills map.</small></label>
          <label>Time limit <span class="field-unit">minutes</span><input type="number" name="time_limit_minutes" id="builderMinutes" value="10" min="1" max="120" step="1" required><small class="field-hint">1–120 minutes per attempt.</small></label>
          <label>Total points<input type="number" name="points" id="builderPoints" value="100" min="1" max="10000" required><small class="field-hint">Maximum score students can earn.</small></label>
        </div>
      </section>

      <section class="builder-step" aria-labelledby="builder-prompt-title">
        <div class="builder-step-heading"><span class="builder-step-number">02</span><div><h3 id="builder-prompt-title">Problem and starter code</h3><p>Explain what the student must solve. Clear input and output rules help the grader stay predictable.</p></div></div>
        <label>Problem description <span class="required-mark">Required</span><textarea name="description" id="builderDescription" rows="7" required placeholder="Describe the task, input format, output format, and any constraints."></textarea><small class="field-hint">Use plain text. Include the input and output format and any constraints students need.</small></label>
        <label>Optional hint for students <textarea name="hint_text" rows="3" maxlength="8000" placeholder="A helpful hint students can reveal after they start (do not include the full answer)."></textarea><small class="field-hint">Displayed inside the started exercise as an optional hint. Do not put hidden test answers here.</small></label>
        <label>Starter code <span class="optional-mark">Optional</span><textarea name="starter_code" rows="7" class="code small-code builder-starter-code" placeholder="# Write starter code for students here"></textarea><small class="field-hint">Keep this short and useful. The starter code is provided when the student starts the exercise.</small></label>
      </section>

      <section class="builder-step" aria-labelledby="builder-test-title">
        <div class="builder-step-heading"><span class="builder-step-number">03</span><div><h3 id="builder-test-title">First test case</h3><p>Define the input and the exact output used by automatic grading. You can add more cases from the Content Library.</p></div></div>
        <div class="builder-field-grid builder-test-fields">
          <label>Standard input <span class="optional-mark">Optional</span><textarea name="stdin" rows="5" class="code" placeholder="2 3"></textarea><small class="field-hint">This text is passed to the program as standard input.</small></label>
          <label>Expected output <span class="optional-mark">Optional</span><textarea name="expected_output" rows="5" class="code" placeholder="5"></textarea><small class="field-hint">Use the exact output expected from a correct solution.</small></label>
        </div>
        <label class="builder-option-row"><input type="checkbox" name="sample" value="1"><span><strong>Show this test case as a public sample</strong><small>Students may view the sample input and expected output before submitting.</small></span></label>
      </section>

      <section class="builder-step builder-settings-step" aria-labelledby="builder-settings-title">
        <div class="builder-step-heading"><span class="builder-step-number">04</span><div><h3 id="builder-settings-title">Exam and publishing settings</h3><p>Monitoring is optional and can be reviewed later from Teacher Studio.</p></div></div>
        <details class="teacher-advanced-settings builder-monitoring-settings">
          <summary><span class="builder-settings-icon">◉</span><span><strong>Exam monitoring</strong><small>Browser event logging for teacher review</small></span></summary>
          <div class="monitor-settings"><div><strong>Monitoring configuration</strong><p class="muted">Events are review signals, not proof of cheating. Clipboard contents are never collected.</p></div><label class="check"><input type="checkbox" name="monitoring_enabled" value="1"> Enable browser monitoring for this exercise</label><label class="builder-threshold-label">Flag the attempt for review after <input type="number" name="warning_threshold" value="3" min="1" max="10" required> recorded events</label><p class="muted small-note">The monitoring settings are copied to an attempt when it starts.</p></div>
        </details>
      </section>
    </div>

    <aside class="builder-sidebar">
      <div class="builder-preview-card">
        <div class="builder-preview-top"><span class="builder-preview-kicker">STUDENT CARD PREVIEW</span><span class="builder-preview-status" id="builderPreviewStatus">Draft</span></div>
        <div class="builder-preview-icon">{ }</div>
        <h3 id="builderPreviewTitle">Your exercise title</h3>
        <p class="builder-preview-description">Students see the exercise title, time limit, and points before they start.</p>
        <div class="builder-preview-meta"><span><small>Topic</small><strong id="builderPreviewTopic">Fundamentals</strong></span><span><small>Difficulty</small><strong id="builderPreviewDifficulty">Easy</strong></span><span><small>Time limit</small><strong><span id="builderPreviewMinutes">10</span> min</strong></span><span><small>Total points</small><strong id="builderPreviewPoints">100 pts</strong></span></div>
      </div>
      <div class="builder-publish-card">
        <div class="builder-publish-heading"><span class="builder-publish-icon">↗</span><div><h3>Ready to share?</h3><p>Choose how this exercise should be saved.</p></div></div>
        <label class="builder-option-row builder-publish-option"><input type="checkbox" name="publish" id="builderPublish" value="1"><span><strong>Publish immediately</strong><small>Make it available to students who have access.</small></span></label>
        <div class="builder-save-note"><span class="builder-note-dot"></span><span>Leave publishing off to keep this as a draft.</span></div>
        <button class="button builder-submit-button" type="submit"><span>Create exercise</span><span aria-hidden="true">→</span></button>
        <p class="builder-security-note"><span>✓</span> You can edit the exercise and its test cases later.</p>
      </div>
      <div class="builder-sidebar-tip"><span class="builder-tip-icon">✦</span><div><strong>Grading tip</strong><p>Add a simple public sample and at least one hidden test case before assigning the exercise to a class.</p></div></div>
    </aside>
  </form>
</section>

<section class="teacher-library-section" id="exercise-library">
  <div class="library-heading-row"><div><p class="eyebrow">YOUR CONTENT</p><h2>Exercise library</h2><p class="muted">Browse your challenges, check their setup, and edit the details or grading cases whenever you need to.</p></div><div class="library-total-badge"><strong><?= $totalExercises ?></strong><span>total exercises</span></div></div>
  <div class="panel teacher-exercise-list-panel">
    <div class="exercise-library-toolbar">
      <label class="exercise-search-label"><span class="library-filter-caption">Search library</span><span class="library-search-control"><span aria-hidden="true">⌕</span><input type="search" id="exerciseSearch" placeholder="Search by title, description, or difficulty…" autocomplete="off"></span></label>
      <label class="exercise-status-filter"><span class="library-filter-caption">Publication</span><select id="exerciseStatusFilter"><option value="all">All exercises</option><option value="published">Published</option><option value="draft">Drafts</option></select></label>
      <label class="exercise-status-filter"><span class="library-filter-caption">Difficulty</span><select id="exerciseDifficultyFilter"><option value="all">All levels</option><option value="Easy">Easy</option><option value="Medium">Medium</option><option value="Hard">Hard</option></select></label>
      <label class="exercise-status-filter"><span class="library-filter-caption">Topic</span><select id="exerciseTopicFilter"><option value="all">All topics</option><?php foreach ($topicOptions as $topicOption): ?><option value="<?= e($topicOption) ?>"><?= e($topicOption) ?></option><?php endforeach; ?></select></label>
    </div>
    <div class="library-results-bar"><span id="exerciseResultsCount"><?= $totalExercises ?> exercise<?= $totalExercises === 1 ? '' : 's' ?></span><span>Newest first</span></div>
    <?php if (!$rows): ?><div class="library-empty-state"><div class="library-empty-icon">{ }</div><h3>Your library is ready for its first challenge</h3><p>Create an exercise using the builder above. You can save it as a draft and publish it when you're ready.</p><a class="button" href="#challenge-builder">Create first exercise</a></div><?php endif; ?>
    <div class="exercise-library-grid" id="exerciseLibraryGrid">
    <?php foreach ($rows as $r): $exerciseId = (int)$r['id']; $searchText = mb_strtolower($r['title'] . ' ' . $r['description'] . ' ' . $r['difficulty'] . ' ' . ($r['topic'] ?? 'Fundamentals') . ' ' . ($r['is_published'] ? 'published' : 'draft')); $minutesForCard = max(1, (int)ceil((int)$r['time_limit_seconds'] / 60)); ?>
      <article id="exercise-<?= $exerciseId ?>" class="exercise-library-card" data-exercise-row data-status="<?= $r['is_published'] ? 'published' : 'draft' ?>" data-difficulty="<?= e($r['difficulty']) ?>" data-topic="<?= e($r['topic'] ?? 'Fundamentals') ?>" data-search="<?= e($searchText) ?>">
        <div class="exercise-library-card-head"><div class="library-exercise-identity"><span class="library-exercise-mark" aria-hidden="true">{ }</span><div class="library-exercise-title-wrap"><h3><?= e($r['title']) ?></h3><p><?= e(mb_strimwidth(trim(strip_tags((string)$r['description'])), 0, 112, '…')) ?></p></div></div><span class="state-pill <?= $r['is_published'] ? 'published' : 'draft' ?>"><span class="state-pill-dot"></span><?= $r['is_published'] ? 'Published' : 'Draft' ?></span></div>
        <div class="library-exercise-metadata"><span class="library-difficulty difficulty-<?= strtolower(e($r['difficulty'])) ?>"><i></i><?= e($r['difficulty']) ?></span><span class="library-topic-tag"><?= e($r['topic'] ?? 'Fundamentals') ?></span><span><b><?= (int)$r['points'] ?></b> points</span><span><b><?= $minutesForCard ?></b> min</span><span><b><?= (int)$r['test_count'] ?></b> test<?= (int)$r['test_count'] === 1 ? '' : 's' ?></span></div>
        <div class="library-exercise-card-actions"><span class="library-card-id">EX-<?= str_pad((string)$exerciseId, 4, '0', STR_PAD_LEFT) ?></span><a class="library-report-link" href="<?= e($config['base_url']) ?>/teacher-monitoring.php?exercise_id=<?= $exerciseId ?>">Monitoring report ↗</a></div>
        <div class="library-exercise-management-actions"><details class="exercise-edit library-exercise-editor"><summary><span class="edit-summary-icon">✎</span><span>Edit exercise</span><small>Details, grading cases, and monitoring</small></summary>
          <form method="post" class="exercise-edit-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="update_exercise"><input type="hidden" name="exercise_id" value="<?= $exerciseId ?>">
            <label>Exercise title<input name="title" required maxlength="180" value="<?= e($r['title']) ?>"></label>
            <label>Problem description<textarea name="description" rows="5" required><?= e($r['description']) ?></textarea></label>
            <div class="form-row"><label>Difficulty<select name="difficulty"><option value="Easy" <?= $r['difficulty']==='Easy'?'selected':'' ?>>Easy</option><option value="Medium" <?= $r['difficulty']==='Medium'?'selected':'' ?>>Medium</option><option value="Hard" <?= $r['difficulty']==='Hard'?'selected':'' ?>>Hard</option></select></label><label>Topic / skill<select name="topic"><?php foreach ($topicOptions as $topicOption): ?><option value="<?= e($topicOption) ?>" <?= (($r['topic'] ?? 'Fundamentals') === $topicOption) ? 'selected' : '' ?>><?= e($topicOption) ?></option><?php endforeach; ?></select></label><label>Time limit (minutes)<input type="number" name="time_limit_minutes" value="<?= $minutesForCard ?>" min="1" max="120" step="1" required></label><label>Points<input type="number" name="points" value="<?= (int)$r['points'] ?>" min="1" max="10000" required></label></div>
            <label>Optional student hint<textarea name="hint_text" rows="3" maxlength="8000" placeholder="A hint students may reveal after starting."><?= e($r['hint_text'] ?? '') ?></textarea><small class="field-hint">This is visible only after the exercise start gate.</small></label>
            <label>Starter code<textarea name="starter_code" rows="5" class="code small-code"><?= e($r['starter_code'] ?? '') ?></textarea></label>
            <div class="edit-publish-grid"><div><strong>Publication</strong><p class="muted">Unpublishing hides the exercise from students, including assigned classes.</p></div><label class="check"><input type="checkbox" name="publish" value="1" <?= $r['is_published'] ? 'checked' : '' ?>> Published and visible to students</label></div>
            <details class="teacher-advanced-settings edit-monitor-details"><summary><span>Exam monitoring settings</span><small><?= $r['monitoring_enabled'] ? 'Enabled for new attempts' : 'Disabled for new attempts' ?></small></summary><div class="edit-monitor-grid"><div><strong>Monitoring configuration</strong><p class="muted">Changes affect new attempts only. Events are reviewed by a teacher and never automatically change grades.</p></div><label class="check"><input type="checkbox" name="monitoring_enabled" value="1" <?= $r['monitoring_enabled'] ? 'checked' : '' ?>> Enable monitoring for new attempts</label><label>Review threshold <input type="number" name="warning_threshold" value="<?= (int)$r['warning_threshold'] ?>" min="1" max="10" required> events</label></div></details>
            <div class="edit-form-actions"><button class="button" type="submit">Save exercise details</button><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-exercise-history.php?exercise_id=<?= $exerciseId ?>">Version history · <?= (int)($r['version_count'] ?? 0) ?> ↗</a><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-monitoring.php?exercise_id=<?= $exerciseId ?>">View exam report ↗</a></div>
          </form>
          <section class="exercise-testcases-management"><div class="testcase-management-heading"><div><h3>Test case manager</h3><p class="muted">Edit public samples and hidden grading cases. Hidden case details are never shown to students.</p></div><span class="pill"><?= (int)$r['test_count'] ?> test<?= (int)$r['test_count'] === 1 ? '' : 's' ?></span></div>
            <?php foreach (($testCasesByExercise[$exerciseId] ?? []) as $testIndex => $testCase): $testCaseId = (int)$testCase['id']; ?>
              <div class="teacher-testcase-card <?= (int)$testCase['is_sample'] ? 'sample-case' : 'hidden-case' ?>"><div class="teacher-testcase-head"><span class="testcase-number">Test <?= $testIndex + 1 ?></span><span class="testcase-visibility <?= (int)$testCase['is_sample'] ? 'public' : 'hidden' ?>"><?= (int)$testCase['is_sample'] ? 'Public sample' : 'Hidden test' ?></span></div>
                <form method="post" class="testcase-edit-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="update_test_case"><input type="hidden" name="exercise_id" value="<?= $exerciseId ?>"><input type="hidden" name="test_case_id" value="<?= $testCaseId ?>"><label>Standard input<textarea name="test_stdin" rows="2"><?= e($testCase['stdin']) ?></textarea></label><label>Expected output<textarea name="test_expected_output" rows="2"><?= e($testCase['expected_output']) ?></textarea></label><div class="testcase-actions"><label class="check"><input type="checkbox" name="test_is_sample" value="1" <?= (int)$testCase['is_sample'] ? 'checked' : '' ?>> Show as a public sample</label><button class="button small" type="submit">Save test case</button></div></form>
                <form method="post" class="testcase-delete-form" onsubmit="return confirm('Delete this test case? At least one test case must remain.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_test_case"><input type="hidden" name="exercise_id" value="<?= $exerciseId ?>"><input type="hidden" name="test_case_id" value="<?= $testCaseId ?>"><button class="quiet-link delete-testcase-button" type="submit">Delete test case</button></form>
              </div>
            <?php endforeach; ?>
            <?php if (!(int)$r['test_count']): ?><p class="muted small-note">No test cases yet. Add the first case below before publishing this exercise for automatic grading.</p><?php endif; ?>
            <form method="post" class="testcase-add-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="add_test_case"><input type="hidden" name="exercise_id" value="<?= $exerciseId ?>"><div class="testcase-add-heading"><span class="edit-summary-icon">＋</span><strong>Add a test case</strong></div><label>Standard input<textarea name="test_stdin" rows="2" placeholder="Input passed to the program"></textarea></label><label>Expected output<textarea name="test_expected_output" rows="2" required placeholder="Exact expected output"></textarea></label><label class="check"><input type="checkbox" name="test_is_sample" value="1"> Show as a public sample</label><button class="button small" type="submit">Add test case</button></form>
          </section>
        </details>
        <form method="post" class="exercise-delete-form" onsubmit="return confirm('Delete this exercise permanently? This also deletes its test cases, classroom assignments, student attempts, submissions, grades, and monitoring history. This cannot be undone.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_exercise"><input type="hidden" name="exercise_id" value="<?= $exerciseId ?>"><button class="button danger small" type="submit">Delete exercise</button></form>
        </div>
      </article>
    <?php endforeach; ?>
    </div>
    <div class="library-no-results" id="exerciseNoResults" hidden><div class="library-empty-icon">⌕</div><h3>No matching exercises</h3><p>Try a different search term or clear one of the filters.</p><button class="button secondary" type="button" id="clearExerciseFilters">Clear filters</button></div>
  </div>
  <div class="library-guidance-row"><div><span class="library-guidance-icon">✓</span><p><strong>Keep the library organized</strong><span>Use drafts while preparing a challenge. Publish only when the instructions and test cases are ready.</span></p></div><div><span class="library-guidance-icon">⚙</span><p><strong>Update grading anytime</strong><span>Open Edit exercise to change the description, minutes, points, test cases, or monitoring settings.</span></p></div></div>
</section>
<script>
(() => {
  const search = document.getElementById('exerciseSearch');
  const status = document.getElementById('exerciseStatusFilter');
  const difficulty = document.getElementById('exerciseDifficultyFilter');
  const topic = document.getElementById('exerciseTopicFilter');
  const cards = Array.from(document.querySelectorAll('[data-exercise-row]'));
  const noResults = document.getElementById('exerciseNoResults');
  const resultsCount = document.getElementById('exerciseResultsCount');
  const clearFilters = document.getElementById('clearExerciseFilters');
  function applyFilters() {
    const q = (search?.value || '').trim().toLowerCase();
    const state = status?.value || 'all';
    const level = difficulty?.value || 'all';
    const skill = topic?.value || 'all';
    let visible = 0;
    cards.forEach(card => {
      const show = (card.dataset.search || '').includes(q)
        && (state === 'all' || card.dataset.status === state)
        && (level === 'all' || card.dataset.difficulty === level)
        && (skill === 'all' || card.dataset.topic === skill);
      card.hidden = !show;
      if (show) visible++;
    });
    if (noResults) noResults.hidden = visible !== 0 || cards.length === 0;
    if (resultsCount) resultsCount.textContent = `${visible} exercise${visible === 1 ? '' : 's'}`;
  }
  search?.addEventListener('input', applyFilters);
  status?.addEventListener('change', applyFilters);
  difficulty?.addEventListener('change', applyFilters);
  topic?.addEventListener('change', applyFilters);
  clearFilters?.addEventListener('click', () => {
    if (search) search.value = '';
    if (status) status.value = 'all';
    if (difficulty) difficulty.value = 'all';
    if (topic) topic.value = 'all';
    applyFilters();
    search?.focus();
  });
  applyFilters();

  const createForm = document.getElementById('create-exercise-form');
  if (createForm) {
    const title = document.getElementById('builderTitle');
    const level = document.getElementById('builderDifficulty');
    const minutes = document.getElementById('builderMinutes');
    const points = document.getElementById('builderPoints');
    const publish = document.getElementById('builderPublish');
    const previewTitle = document.getElementById('builderPreviewTitle');
    const previewTopic = document.getElementById('builderPreviewTopic');
    const previewDifficulty = document.getElementById('builderPreviewDifficulty');
    const previewMinutes = document.getElementById('builderPreviewMinutes');
    const previewPoints = document.getElementById('builderPreviewPoints');
    const previewStatus = document.getElementById('builderPreviewStatus');
    const updatePreview = () => {
      if (previewTitle) previewTitle.textContent = title?.value.trim() || 'Your exercise title';
      if (previewDifficulty) previewDifficulty.textContent = level?.value || 'Easy';
      if (previewMinutes) previewMinutes.textContent = minutes?.value || '10';
      if (previewPoints) previewPoints.textContent = `${points?.value || '100'} pts`;
      if (previewStatus) {
        previewStatus.textContent = publish?.checked ? 'Published' : 'Draft';
        previewStatus.classList.toggle('is-published', !!publish?.checked);
      }
    };
    [title, level, minutes, points, publish].forEach(control => control?.addEventListener('input', updatePreview));
    publish?.addEventListener('change', updatePreview);
    updatePreview();
  }

  const hashMatch = window.location.hash.match(/^#exercise-(\d+)$/);
  if (hashMatch) {
    const card = document.getElementById(`exercise-${hashMatch[1]}`);
    const editor = card?.querySelector('.exercise-edit');
    if (editor) editor.open = true;
    card?.scrollIntoView({ block: 'start', behavior: 'smooth' });
  }
})();
</script>
<?php page_footer(); ?>
