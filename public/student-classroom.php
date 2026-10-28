<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['student']);
$classroomId = max(0, (int)($_GET['id'] ?? 0));
$stmt = $pdo->prepare("SELECT c.*, u.name AS teacher_name FROM classrooms c JOIN users u ON u.id=c.teacher_id
    JOIN class_enrollments ce ON ce.classroom_id=c.id AND ce.student_id=? AND ce.enrollment_status='active'
    WHERE c.id=? AND c.is_active=1");
$stmt->execute([(int)$user['id'], $classroomId]); $classroom = $stmt->fetch();
if (!$classroom) { flash('You are not enrolled in that active classroom.', 'error'); redirect('student-classrooms.php'); }

sync_classroom_grades($pdo, $classroomId);
$hasOverrides = codearena_table_exists($pdo, 'student_assignment_overrides');
$dueExpression = $hasOverrides ? 'COALESCE(sao.extended_due_at, ca.due_at)' : 'ca.due_at';
$overrideJoin = $hasOverrides ? 'LEFT JOIN student_assignment_overrides sao ON sao.assignment_id=ca.id AND sao.student_id=?' : '';
$sql = "SELECT ca.id AS assignment_id, {$dueExpression} AS due_at, ca.due_at AS original_due_at, e.id AS exercise_id, e.title, e.difficulty, e.points, e.time_limit_seconds,
        COALESCE(a.started_explicitly,0) AS has_started, COALESCE(a.retake_pending,0) AS retake_pending, a.status AS attempt_status, a.deadline_at AS attempt_deadline,
        COALESCE(gr.best_score,0) AS best_score, COALESCE(gr.max_score,e.points) AS max_score, COALESCE(gr.submission_count,0) AS submission_count, gr.last_submitted_at, av.snapshot_json AS attempt_snapshot_json
        FROM class_assignments ca JOIN exercises e ON e.id=ca.exercise_id
        LEFT JOIN grade_records gr ON gr.assignment_id=ca.id AND gr.student_id=?
        LEFT JOIN attempts a ON a.user_id=? AND a.exercise_id=e.id
        {$overrideJoin}
        LEFT JOIN exercise_versions av ON av.id=a.exercise_version_id
        WHERE ca.classroom_id=? AND ca.is_active=1 AND e.is_published=1
        ORDER BY ({$dueExpression} IS NULL), {$dueExpression}, ca.created_at DESC";
$stmt = $pdo->prepare($sql);
$stmt->execute($hasOverrides ? [(int)$user['id'], (int)$user['id'], (int)$user['id'], $classroomId] : [(int)$user['id'], (int)$user['id'], $classroomId]);
$assignments = $stmt->fetchAll();
$announcementStmt = $pdo->prepare('SELECT title,body,created_at FROM class_announcements WHERE classroom_id=? AND is_published=1 ORDER BY created_at DESC LIMIT 10');
$announcements = [];
try { $announcementStmt->execute([$classroomId]); $announcements = $announcementStmt->fetchAll(); } catch (Throwable $ignored) { $announcements = []; }
foreach ($assignments as &$assignmentRow) { if ((int)$assignmentRow['has_started'] === 1 && !empty($assignmentRow['attempt_snapshot_json'])) { $snap=json_decode((string)$assignmentRow['attempt_snapshot_json'],true); if (is_array($snap['exercise'] ?? null)) { $versionExercise=$snap['exercise']; $assignmentRow['title']=(string)($versionExercise['title'] ?? $assignmentRow['title']); $assignmentRow['points']=max(1,(int)($versionExercise['points'] ?? $assignmentRow['points'])); $assignmentRow['time_limit_seconds']=max(1,(int)($versionExercise['time_limit_seconds'] ?? $assignmentRow['time_limit_seconds'])); } } } unset($assignmentRow);
page_header($classroom['name']);
?>
<div class="classroom-detail-top"><a class="back" href="<?= e($config['base_url']) ?>/student-classrooms.php">← My classes</a><div class="classroom-detail-head"><div><p class="eyebrow">MY CLASS · <?= e($classroom['section']) ?></p><h1><?= e($classroom['name']) ?></h1><p class="muted"><?= e($classroom['subject'] ?: 'Programming class') ?> · Teacher: <?= e($classroom['teacher_name']) ?></p></div><span class="classroom-state active">Enrolled</span></div></div>
<?php if ($announcements): ?><section class="panel v23-student-announcements"><div class="section-title"><div><h2>Class announcements</h2><p class="muted">Updates from your teacher.</p></div><span class="pill"><?= count($announcements) ?> recent</span></div><div class="v23-announcement-list"><?php foreach($announcements as $ann): ?><article class="v23-announcement-card"><div><h3><?= e($ann['title']) ?></h3><small class="muted"><?= e(date('M j, Y · g:i A',strtotime((string)$ann['created_at']))) ?></small><p><?= nl2br(e($ann['body'])) ?></p></div></article><?php endforeach; ?></div></section><?php endif; ?>
<div class="section-title"><div><h2>Class assignments</h2><p class="muted">Complete the assigned challenges and check your latest best score.</p></div><span class="pill"><?= count($assignments) ?> assignments</span></div>
<?php if (!$assignments): ?><div class="empty"><div class="empty-symbol">✓</div><h3>No assignments yet</h3><p>Your teacher has not assigned any published exercises to this class yet.</p></div><?php else: ?><div class="class-assignment-list"><?php foreach ($assignments as $a): $max=max(1,(int)($a['max_score'] ?? $a['points'])); $score=(int)$a['best_score']; $pastDue=$a['due_at'] && strtotime($a['due_at'])<time(); $retakePending=(int)($a['retake_pending']??0)===1; $perfect=!$retakePending && $score >= $max; $gradedNonPerfect=!$retakePending && !$perfect && ($a['attempt_status']??'')==='submitted'; $inProgress=(int)$a['has_started']===1 && ($a['attempt_status']??'')==='in_progress' && !$pastDue; $expired=$pastDue || ($a['attempt_status']??'')==='expired'; $scoreTone=$perfect?'score-perfect':((int)$a['submission_count']===0?'':($score*2 >= $max ? 'score-progress':'score-failed')); ?><article class="panel class-assignment-card"><div class="class-assignment-main"><div class="class-assignment-topline"><span class="difficulty <?= strtolower(e($a['difficulty'])) ?>"><?= e($a['difficulty']) ?></span><?php if ($perfect): ?><span class="classroom-state active">Completed</span><?php elseif ($retakePending): ?><span class="classroom-state upcoming">Retake available</span><?php elseif ($inProgress): ?><span class="classroom-state upcoming">In progress</span><?php elseif ($expired): ?><span class="classroom-state inactive">Deadline passed</span><?php elseif ($gradedNonPerfect): ?><span class="classroom-state upcoming">Graded · not perfect</span><?php else: ?><span class="classroom-state upcoming">Not started</span><?php endif; ?></div><h3><?= e($a['title']) ?></h3><p class="muted clamp">The instructions and coding workspace appear after you start the exercise.</p><div class="class-assignment-meta"><span>◷ <?= (int)ceil((int)$a['time_limit_seconds']/60) ?> min timer</span><span>✦ <?= (int)$a['points'] ?> points</span><span>Due: <?= $a['due_at'] ? e(date('M j, Y · g:i A',strtotime($a['due_at']))) : 'No deadline' ?></span></div></div><div class="class-assignment-score"><span class="muted">Best score</span><strong class="<?= $scoreTone ?>"><?= $score ?> <small>/ <?= $max ?></small></strong><div class="grade-progress <?= $scoreTone ?>"><span style="width:<?= min(100,(int)round($score/$max*100)) ?>%"></span></div><span class="muted"><?= (int)$a['submission_count'] ?> submission<?= (int)$a['submission_count']===1?'':'s' ?></span><?php if (!$pastDue): ?><a class="button small" href="<?= e($config['base_url']) ?>/exercise.php?id=<?= (int)$a['exercise_id'] ?>"><?= $perfect ? 'View result' : ($retakePending ? 'Start retake' : ($gradedNonPerfect ? 'Review result' : ((int)$a['has_started'] === 1 ? 'Continue exercise' : 'Start exercise'))) ?> →</a><?php else: ?><span class="muted small-note">The deadline has passed. Contact your teacher if you need help.</span><?php endif; ?></div></article><?php endforeach; ?></div><?php endif; ?>
<?php page_footer(); ?>
