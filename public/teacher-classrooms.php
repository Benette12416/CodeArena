<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');
    if ($action === 'create_classroom') {
        $name = trim((string)($_POST['name'] ?? ''));
        $section = trim((string)($_POST['section'] ?? ''));
        $subject = trim((string)($_POST['subject'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));
        if ($name === '' || $section === '') {
            flash('Enter a class name and section to create a classroom.', 'error');
            redirect('teacher-classrooms.php');
        }
        try {
            $code = generate_class_join_code($pdo);
            $stmt = $pdo->prepare('INSERT INTO classrooms (teacher_id, name, section, subject, description, join_code) VALUES (?, ?, ?, ?, ?, ?)');
            $stmt->execute([(int)$user['id'], $name, $section, $subject !== '' ? $subject : null, $description !== '' ? $description : null, $code]);
            audit_log($pdo, (int)$user['id'], 'classroom_created', 'classroom', (int)$pdo->lastInsertId(), ['section'=>$section]);
            flash('Classroom created. Share its join code with your students.', 'success');
        } catch (Throwable $ex) {
            flash('Could not create the classroom. Please check the database migration and try again.', 'error');
        }
        redirect('teacher-classrooms.php');
    }
    if ($action === 'toggle_classroom') {
        $classroomId = (int)($_POST['classroom_id'] ?? 0);
        $stmt = $pdo->prepare('UPDATE classrooms SET is_active = IF(is_active = 1, 0, 1) WHERE id = ? AND teacher_id = ? AND archived_at IS NULL');
        $stmt->execute([$classroomId, (int)$user['id']]);
        if ($stmt->rowCount()) audit_log($pdo, (int)$user['id'], 'classroom_status_toggled', 'classroom', $classroomId);
        flash($stmt->rowCount() ? 'Classroom status updated.' : 'Classroom not found.', $stmt->rowCount() ? 'success' : 'error');
        redirect('teacher-classrooms.php');
    }
    if ($action === 'archive_classroom') {
        $classroomId = (int)($_POST['classroom_id'] ?? 0);
        $stmt = $pdo->prepare('UPDATE classrooms SET archived_at=CURRENT_TIMESTAMP, is_active=0 WHERE id=? AND teacher_id=? AND archived_at IS NULL');
        $stmt->execute([$classroomId, (int)$user['id']]);
        if ($stmt->rowCount()) audit_log($pdo, (int)$user['id'], 'classroom_archived', 'classroom', $classroomId);
        flash($stmt->rowCount() ? 'Classroom archived. Student access is disabled; grade and assignment history is retained.' : 'Classroom not found or already archived.', $stmt->rowCount() ? 'success' : 'error');
        redirect('teacher-classrooms.php');
    }
    if ($action === 'restore_classroom') {
        $classroomId = (int)($_POST['classroom_id'] ?? 0);
        $stmt = $pdo->prepare('UPDATE classrooms SET archived_at=NULL, is_active=1 WHERE id=? AND teacher_id=? AND archived_at IS NOT NULL');
        $stmt->execute([$classroomId, (int)$user['id']]);
        if ($stmt->rowCount()) audit_log($pdo, (int)$user['id'], 'classroom_restored', 'classroom', $classroomId);
        flash($stmt->rowCount() ? 'Classroom restored and reactivated.' : 'Classroom not found or not archived.', $stmt->rowCount() ? 'success' : 'error');
        redirect('teacher-classrooms.php');
    }
}

$stmt = $pdo->prepare("SELECT c.*,
    (SELECT COUNT(*) FROM class_enrollments ce WHERE ce.classroom_id=c.id AND ce.enrollment_status='active') AS student_count,
    (SELECT COUNT(*) FROM class_assignments ca WHERE ca.classroom_id=c.id AND ca.is_active=1) AS assignment_count
    FROM classrooms c WHERE c.teacher_id=? ORDER BY c.created_at DESC");
$stmt->execute([(int)$user['id']]);
$classrooms = $stmt->fetchAll();
$activeClassrooms = array_values(array_filter($classrooms, static fn(array $c): bool => empty($c['archived_at'])));
$archivedClassrooms = array_values(array_filter($classrooms, static fn(array $c): bool => !empty($c['archived_at'])));
page_header('Classrooms');
?>
<section class="teacher-welcome classroom-welcome"><div><p class="eyebrow">TEACHER STUDIO · CLASSROOMS</p><h1>Bring your class together.</h1><p class="muted">Create a space for each course or section, share its join code, assign programming exercises, and track grades in one place.</p><div class="hero-actions"><a class="button" href="#create-classroom">＋ Create a classroom</a><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher.php">Build an exercise ↗</a></div></div><div class="classroom-stat-mark"><strong><?= count($activeClassrooms) ?></strong><span>ACTIVE CLASSROOMS</span></div></section>
<div class="classroom-page-grid">
  <section class="panel form-panel" id="create-classroom">
    <div class="section-title"><div><h2>Create classroom</h2><p class="muted">Students join using a short class code.</p></div><span class="pill">New class</span></div>
    <form method="post" class="classroom-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="create_classroom">
      <label>Class name<input name="name" maxlength="160" required placeholder="e.g. Introduction to Programming"></label>
      <label>Section<input name="section" maxlength="100" required placeholder="e.g. BSIT 1A"></label>
      <label>Subject or course (optional)<input name="subject" maxlength="120" placeholder="e.g. Programming 1"></label>
      <label>Description (optional)<textarea name="description" rows="3" placeholder="A short note about this class"></textarea></label>
      <button class="button" type="submit">Create classroom <span aria-hidden="true">→</span></button>
    </form>
  </section>
  <section class="classroom-list-section" id="your-classrooms">
    <div class="section-title"><div><h2>Your classrooms</h2><p class="muted">Manage sections, assignments, and gradebooks.</p></div><span class="pill"><?= count($activeClassrooms) ?> active · <?= count($archivedClassrooms) ?> archived</span></div>
    <?php if (!$activeClassrooms): ?>
      <div class="empty classroom-empty"><div class="empty-symbol">▦</div><h3>Your first classroom starts here</h3><p>Create a class to get its unique join code. Students can join from their CodeArena account.<?php if($archivedClassrooms): ?> Your archived classes are listed below.<?php endif; ?></p></div>
    <?php else: ?>
      <div class="classroom-cards">
      <?php foreach ($activeClassrooms as $classroom): ?>
        <article class="classroom-card panel">
          <div class="classroom-card-head"><span class="classroom-icon">▦</span><span class="classroom-state <?= !empty($classroom['archived_at']) ? 'inactive' : ((int)$classroom['is_active'] ? 'active' : 'inactive') ?>"><?= !empty($classroom['archived_at']) ? 'Archived' : ((int)$classroom['is_active'] ? 'Active' : 'Paused') ?></span></div>
          <h3><?= e($classroom['name']) ?></h3><p class="classroom-section-label"><?= e($classroom['section']) ?><?= $classroom['subject'] ? ' · '.e($classroom['subject']) : '' ?></p>
          <?php if ($classroom['description']): ?><p class="muted clamp"><?= e($classroom['description']) ?></p><?php endif; ?>
          <div class="join-code-inline"><span><small>CLASS JOIN CODE</small><strong><?= e($classroom['join_code']) ?></strong></span><button type="button" class="icon-button copy-class-code" data-code="<?= e($classroom['join_code']) ?>" aria-label="Copy join code" title="Copy join code">⧉</button></div>
          <div class="classroom-card-stats"><span><strong><?= (int)$classroom['student_count'] ?></strong> students</span><span><strong><?= (int)$classroom['assignment_count'] ?></strong> assignments</span></div>
          <div class="classroom-card-actions"><a class="button" href="<?= e($config['base_url']) ?>/teacher-classroom.php?id=<?= (int)$classroom['id'] ?>">Open classroom <span aria-hidden="true">→</span></a><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-gradebook.php?classroom_id=<?= (int)$classroom['id'] ?>">Gradebook</a></div>
          <?php if (empty($classroom['archived_at'])): ?>
          <form method="post" class="classroom-toggle-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="toggle_classroom"><input type="hidden" name="classroom_id" value="<?= (int)$classroom['id'] ?>"><button class="quiet-link" type="submit"><?= (int)$classroom['is_active'] ? 'Pause classroom' : 'Reactivate classroom' ?></button></form>
          <form method="post" class="classroom-toggle-form" onsubmit="return confirm('Archive this class? Students will lose access, but grade history will be retained.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="archive_classroom"><input type="hidden" name="classroom_id" value="<?= (int)$classroom['id'] ?>"><button class="quiet-link danger-link" type="submit">Archive class</button></form>
          <?php else: ?><form method="post" class="classroom-toggle-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="restore_classroom"><input type="hidden" name="classroom_id" value="<?= (int)$classroom['id'] ?>"><button class="button small" type="submit">Restore classroom</button></form><?php endif; ?>
        </article>
      <?php endforeach; ?>
      </div>
    <?php endif; ?>
    <?php if ($archivedClassrooms): ?><section class="v23-archived-classrooms" id="archived-classrooms"><div class="section-title"><div><h2>Archived classrooms</h2><p class="muted">Archived classes are kept for records and can be restored later.</p></div><span class="pill"><?= count($archivedClassrooms) ?> archived</span></div><div class="v23-archived-list"><?php foreach($archivedClassrooms as $archived): ?><article class="panel v23-archived-class-card"><div><strong><?= e($archived['name']) ?></strong><p class="muted"><?= e($archived['section']) ?> · Archived <?= e(date('M j, Y',strtotime((string)$archived['archived_at']))) ?></p></div><div class="v23-archived-actions"><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-classroom.php?id=<?= (int)$archived['id'] ?>">View records</a><form method="post"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="restore_classroom"><input type="hidden" name="classroom_id" value="<?= (int)$archived['id'] ?>"><button type="submit" class="button small">Restore</button></form></div></article><?php endforeach; ?></div></section><?php endif; ?>
  </section>
</div>
<script>
document.querySelectorAll('.copy-class-code').forEach(button=>button.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(button.dataset.code);button.textContent='✓';setTimeout(()=>button.textContent='⧉',1200);}catch(_e){window.prompt('Copy this class join code:',button.dataset.code);}}));
</script>
<?php page_footer(); ?>
