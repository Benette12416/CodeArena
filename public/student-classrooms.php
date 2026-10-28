<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['student']);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $rawCode = strtoupper((string)($_POST['join_code'] ?? ''));
    $code = preg_replace('/[^A-Z0-9]/', '', $rawCode) ?? '';
    if (strlen($code) < 6 || strlen($code) > 12) {
        flash('Enter a valid classroom join code.', 'error');
        redirect('student-classrooms.php');
    }
    $stmt = $pdo->prepare('SELECT id, name, section FROM classrooms WHERE join_code=? AND is_active=1');
    $stmt->execute([$code]); $classroom = $stmt->fetch();
    if (!$classroom) {
        flash('That class code was not found or the classroom is paused. Check the code with your teacher.', 'error');
        redirect('student-classrooms.php');
    }
    $stmt = $pdo->prepare("INSERT INTO class_enrollments (classroom_id, student_id, enrollment_status) VALUES (?, ?, 'active') ON DUPLICATE KEY UPDATE enrollment_status='active'");
    $stmt->execute([(int)$classroom['id'], (int)$user['id']]);
    sync_classroom_grades($pdo, (int)$classroom['id']);
    audit_log($pdo, (int)$user['id'], 'student_joined_class', 'classroom', (int)$classroom['id']);
    flash('You joined '. $classroom['name'] .' · '. $classroom['section'] .'. Your class assignments are ready.', 'success');
    redirect('student-classrooms.php');
}

$stmt = $pdo->prepare("SELECT c.id, c.name, c.section, c.subject, c.description, c.join_code, ce.joined_at,
    (SELECT COUNT(*) FROM class_assignments ca WHERE ca.classroom_id=c.id AND ca.is_active=1) AS assignment_count,
    (SELECT COUNT(*) FROM class_assignments ca JOIN grade_records gr ON gr.assignment_id=ca.id AND gr.student_id=? WHERE ca.classroom_id=c.id AND ca.is_active=1 AND gr.best_score>=gr.max_score) AS completed_count,
    u.name AS teacher_name
    FROM class_enrollments ce JOIN classrooms c ON c.id=ce.classroom_id
    JOIN users u ON u.id=c.teacher_id
    WHERE ce.student_id=? AND ce.enrollment_status='active' AND c.is_active=1
    ORDER BY ce.joined_at DESC");
$stmt->execute([(int)$user['id'], (int)$user['id']]); $classrooms = $stmt->fetchAll();
page_header('My classes');
?>
<section class="student-classrooms-hero"><div><p class="eyebrow">STUDENT SPACE · CLASSROOMS</p><h1>Your classes, all in one place.</h1><p class="muted">Join a class with the code from your teacher to see assigned exercises, deadlines, and your grades.</p></div><div class="student-classroom-icon">▦</div></section>
<div class="student-classrooms-grid">
  <section class="panel join-class-panel"><div class="panel-icon">＋</div><h2>Join a classroom</h2><p class="muted">Ask your teacher for an 8-character join code.</p><form method="post" class="join-class-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><label for="join_code">Class join code</label><input id="join_code" name="join_code" maxlength="12" minlength="6" required placeholder="e.g. 8KQ4ZP2M" autocomplete="off" autocapitalize="characters"><button type="submit" class="button full">Join class →</button></form><p class="field-hint">Join codes are case-insensitive. You must be signed in with a student account.</p></section>
  <section class="student-classes-section"><div class="section-title"><div><h2>My classrooms</h2><p class="muted">Assignments and learning progress for your enrolled classes.</p></div><span class="pill"><?= count($classrooms) ?> joined</span></div>
  <?php if (!$classrooms): ?><div class="empty"><div class="empty-symbol">▦</div><h3>No classes yet</h3><p>Enter the join code shared by your teacher to access class assignments.</p></div><?php else: ?><div class="classroom-cards student-classroom-cards"><?php foreach ($classrooms as $c): $total=(int)$c['assignment_count']; $completed=(int)$c['completed_count']; ?><article class="panel classroom-card student-classroom-card"><div class="classroom-card-head"><span class="classroom-icon">▦</span><span class="classroom-state active">Enrolled</span></div><h3><?= e($c['name']) ?></h3><p class="classroom-section-label"><?= e($c['section']) ?><?= $c['subject'] ? ' · '.e($c['subject']) : '' ?></p><p class="muted">Teacher: <?= e($c['teacher_name']) ?></p><?php if ($c['description']): ?><p class="muted clamp"><?= e($c['description']) ?></p><?php endif; ?><div class="student-class-progress"><div class="student-class-progress-copy"><span>Perfect-score assignments</span><strong><?= $completed ?>/<?= $total ?></strong></div><div class="grade-progress"><span style="width:<?= $total ? min(100,(int)round($completed/$total*100)) : 0 ?>%"></span></div></div><div class="classroom-card-actions"><a class="button" href="<?= e($config['base_url']) ?>/student-classroom.php?id=<?= (int)$c['id'] ?>">Open class →</a></div></article><?php endforeach; ?></div><?php endif; ?>
  </section>
</div>
<?php page_footer(); ?>
