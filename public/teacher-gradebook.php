<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$classroomId = max(0, (int)($_GET['classroom_id'] ?? 0));
if ($classroomId === 0) {
    // The global Gradebook navigation opens a classroom picker rather than an invalid empty gradebook.
    $stmt = $pdo->prepare("SELECT c.id, c.name, c.section, c.subject, c.is_active,
        (SELECT COUNT(*) FROM class_enrollments ce WHERE ce.classroom_id=c.id AND ce.enrollment_status='active') AS student_count,
        (SELECT COUNT(*) FROM class_assignments ca WHERE ca.classroom_id=c.id AND ca.is_active=1) AS assignment_count
        FROM classrooms c WHERE c.teacher_id=? ORDER BY c.created_at DESC");
    $stmt->execute([(int)$user['id']]);
    $classrooms = $stmt->fetchAll();
    page_header('Choose a gradebook');
    ?>
    <section class="page-hero compact-page-hero v16-gradebook-picker-hero">
      <div><p class="eyebrow">TEACHER STUDIO · GRADEBOOK</p><h1>Choose a classroom</h1><p class="muted">Open a class gradebook to review student scores, assignment completion, and submission history.</p></div>
      <div class="page-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/teacher-classrooms.php#create-classroom">＋ Create classroom</a></div>
    </section>
    <?php if (!$classrooms): ?>
      <section class="panel v16-gradebook-picker-empty"><span class="v16-picker-icon" aria-hidden="true">▦</span><h2>No classrooms yet</h2><p class="muted">Create a classroom first. Once students join and exercises are assigned, the gradebook will appear here.</p><a class="button" href="<?= e($config['base_url']) ?>/teacher-classrooms.php#create-classroom">Create your first classroom</a></section>
    <?php else: ?>
      <section class="v16-gradebook-picker-grid" aria-label="Your classroom gradebooks">
      <?php foreach ($classrooms as $classroomOption): ?>
        <article class="panel v16-gradebook-picker-card">
          <div class="v16-picker-card-top"><span class="v16-picker-icon" aria-hidden="true">▦</span><span class="classroom-state <?= (int)$classroomOption['is_active'] ? 'active' : 'inactive' ?>"><?= (int)$classroomOption['is_active'] ? 'Active' : 'Paused' ?></span></div>
          <p class="eyebrow"><?= e($classroomOption['section']) ?><?= !empty($classroomOption['subject']) ? ' · '.e($classroomOption['subject']) : '' ?></p>
          <h2><?= e($classroomOption['name']) ?></h2>
          <div class="v16-picker-metrics"><span><strong><?= (int)$classroomOption['student_count'] ?></strong><small>Students</small></span><span><strong><?= (int)$classroomOption['assignment_count'] ?></strong><small>Assignments</small></span></div>
          <a class="button" href="<?= e($config['base_url']) ?>/teacher-gradebook.php?classroom_id=<?= (int)$classroomOption['id'] ?>">Open gradebook <span aria-hidden="true">→</span></a>
        </article>
      <?php endforeach; ?>
      </section>
    <?php endif; ?>
    <?php page_footer(); exit;
}
$stmt = $pdo->prepare('SELECT * FROM classrooms WHERE id=? AND teacher_id=?');
$stmt->execute([$classroomId, (int)$user['id']]);
$classroom = $stmt->fetch();
if (!$classroom) { http_response_code(404); exit('Classroom not found.'); }

sync_classroom_grades($pdo, $classroomId);
$sql = "SELECT ce.student_id, u.name AS student_name, u.email,
        ca.id AS assignment_id, e.id AS exercise_id, e.title AS exercise_title, COALESCE(gr.max_score,e.points) AS max_score,
        ca.due_at, ca.is_active AS assignment_active,
        COALESCE(gr.best_score, 0) AS best_score,
        COALESCE(gr.submission_count, 0) AS submission_count,
        gr.last_submitted_at, a.status AS attempt_status, COALESCE(a.started_explicitly,0) AS started_explicitly
        FROM class_enrollments ce
        JOIN users u ON u.id=ce.student_id
        JOIN class_assignments ca ON ca.classroom_id=ce.classroom_id AND ca.is_active=1
        JOIN exercises e ON e.id=ca.exercise_id
        LEFT JOIN grade_records gr ON gr.assignment_id=ca.id AND gr.student_id=ce.student_id
        LEFT JOIN attempts a ON a.user_id=ce.student_id AND a.exercise_id=e.id
        WHERE ce.classroom_id=? AND ce.enrollment_status='active'
        ORDER BY u.name, e.title";
$stmt = $pdo->prepare($sql); $stmt->execute([$classroomId]); $grades = $stmt->fetchAll();
$stmt = $pdo->prepare("SELECT COUNT(*) FROM class_enrollments WHERE classroom_id=? AND enrollment_status='active'");
$stmt->execute([$classroomId]); $studentCount = (int)$stmt->fetchColumn();
$stmt = $pdo->prepare("SELECT COUNT(*) FROM class_assignments WHERE classroom_id=? AND is_active=1");
$stmt->execute([$classroomId]); $assignmentCount = (int)$stmt->fetchColumn();

$pointsTotal = 0; $maxTotal = 0; $perfectCount = 0; $submittedCount = 0; $notStartedCount = 0; $belowHalfCount = 0;
foreach ($grades as $row) {
    $max = max(1, (int)$row['max_score']); $score = min($max, (int)$row['best_score']);
    $pointsTotal += $score; $maxTotal += $max;
    if ($score >= $max) $perfectCount++;
    if ((int)$row['submission_count'] > 0) $submittedCount++;
    else if ((int)$row['started_explicitly'] === 0) $notStartedCount++;
    if ((int)$row['submission_count'] > 0 && $score * 2 < $max) $belowHalfCount++;
}
$classAverage = $maxTotal > 0 ? (int)round($pointsTotal / $maxTotal * 100) : 0;

if (($_GET['export'] ?? '') === 'csv') {
    $csvCell = static function (mixed $value): string {
        $text = (string)($value ?? '');
        return preg_match('/^\s*[=+\-@]/', $text) ? "'".$text : $text;
    };
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="codearena-gradebook-class-'.$classroomId.'.csv"');
    $out = fopen('php://output', 'w');
    fprintf($out, chr(0xEF).chr(0xBB).chr(0xBF));
    fputcsv($out, array_map($csvCell, ['Class', $classroom['name'], 'Section', $classroom['section']]));
    fputcsv($out, array_map($csvCell, ['Student name', 'Student email', 'Assignment', 'Score', 'Maximum score', 'Percent', 'Status', 'Submissions', 'Last submission', 'Due date']));
    foreach ($grades as $row) {
        $max = max(1, (int)$row['max_score']); $score = min($max, (int)$row['best_score']);
        $percent = (int)round($score / $max * 100);
        $status = $score >= $max ? 'Perfect score' : ((int)$row['started_explicitly'] === 1 && $row['attempt_status'] === 'in_progress' ? 'In progress' : ((int)$row['submission_count'] > 0 ? ($percent >= 50 ? 'Partial score' : 'Needs practice') : (!empty($row['due_at']) && strtotime((string)$row['due_at']) < time() ? 'Overdue' : 'Not started')));
        fputcsv($out, array_map($csvCell, [$row['student_name'], $row['email'], $row['exercise_title'], $score, $max, $percent.'%', $status, (int)$row['submission_count'], $row['last_submitted_at'] ?? '', $row['due_at'] ?? '']));
    }
    fclose($out); exit;
}

page_header('Class gradebook');
?>
<section class="page-hero compact-page-hero">
  <div><p class="eyebrow">TEACHER STUDIO · GRADEBOOK</p><h1><?= e($classroom['name']) ?></h1><p class="muted"><?= e($classroom['section']) ?> · Review assignment scores, student progress, and submission activity.</p></div>
  <div class="page-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/teacher-gradebook.php?classroom_id=<?= $classroomId ?>&export=csv">Export CSV ↓</a><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-classroom.php?id=<?= $classroomId ?>">Back to classroom ↗</a></div>
</section>
<div class="gradebook-summary-grid">
  <article class="panel gradebook-summary-card"><span class="summary-icon metric-purple">♙</span><span class="muted">Enrolled students</span><strong><?= $studentCount ?></strong><small>Active class roster</small></article>
  <article class="panel gradebook-summary-card"><span class="summary-icon metric-blue">▤</span><span class="muted">Active assignments</span><strong><?= $assignmentCount ?></strong><small>Included in this gradebook</small></article>
  <article class="panel gradebook-summary-card"><span class="summary-icon metric-green">✓</span><span class="muted">Perfect-score rows</span><strong><?= $perfectCount ?></strong><small>Student × assignment pairs</small></article>
  <article class="panel gradebook-summary-card"><span class="summary-icon metric-orange">◷</span><span class="muted">Class score average</span><strong><?= $classAverage ?>%</strong><small><?= $belowHalfCount ?> submitted scores below 50%</small></article>
</div>
<section class="panel gradebook-panel">
  <div class="section-title"><div><h2>Gradebook</h2><p class="muted">Scores use each student's best saved submission. Missing submissions remain visible rather than being hidden from the report.</p></div><span class="pill"><?= count($grades) ?> records</span></div>
  <div class="gradebook-tools"><label class="gradebook-search">Search students or exercises<input id="gradebookSearch" type="search" placeholder="Search by name, email, or exercise…" autocomplete="off"></label><label class="gradebook-status-filter">Progress status<select id="gradebookStatus"><option value="all">All statuses</option><option value="perfect">Perfect score</option><option value="in_progress">In progress</option><option value="partial">Partial score</option><option value="needs_practice">Needs practice</option><option value="not_started">Not started</option><option value="overdue">Overdue</option></select></label></div>
  <?php if (!$studentCount): ?><div class="empty compact-empty"><h3>No students enrolled yet</h3><p>Share the classroom join code to start building the gradebook.</p></div>
  <?php elseif (!$assignmentCount): ?><div class="empty compact-empty"><h3>No active assignments</h3><p>Assign a published exercise to this classroom to create grade records.</p></div>
  <?php else: ?><div class="table-wrap"><table id="gradebookTable"><thead><tr><th>Student</th><th>Assignment</th><th>Best score</th><th>Progress</th><th>Status</th><th>Submissions</th><th>Last submitted</th><th>Due date</th><th>Submission inspector</th></tr></thead><tbody><?php foreach ($grades as $row): $maximum=max(1,(int)$row['max_score']); $score=min($maximum,(int)$row['best_score']); $percent=min(100,(int)round($score/$maximum*100)); $duePassed=!empty($row['due_at']) && strtotime((string)$row['due_at'])<time(); if ($score >= $maximum) { $statusKey='perfect'; $statusLabel='Perfect score'; } elseif ((int)$row['started_explicitly']===1 && $row['attempt_status']==='in_progress') { $statusKey='in_progress'; $statusLabel='In progress'; } elseif ((int)$row['submission_count']>0 && $percent>=50) { $statusKey='partial'; $statusLabel='Partial score'; } elseif ((int)$row['submission_count']>0) { $statusKey='needs_practice'; $statusLabel='Needs practice'; } elseif ($duePassed) { $statusKey='overdue'; $statusLabel='Overdue'; } else { $statusKey='not_started'; $statusLabel='Not started'; } $tone=$statusKey==='perfect'?'score-perfect':(($statusKey==='partial'||$statusKey==='in_progress')?'score-progress':(($statusKey==='needs_practice'||$statusKey==='overdue')?'score-failed':'')); ?><tr data-grade-row data-search="<?= e(mb_strtolower($row['student_name'].' '.$row['email'].' '.$row['exercise_title'])) ?>" data-status="<?= e($statusKey) ?>"><td><div class="gradebook-student"><span class="leaderboard-mini-avatar"><?= e(strtoupper(mb_substr((string)$row['student_name'],0,1))) ?></span><span><strong><?= e($row['student_name']) ?></strong><small><?= e($row['email']) ?></small></span></div></td><td><strong><?= e($row['exercise_title']) ?></strong></td><td><strong class="<?= $tone ?>"><?= $score ?> / <?= $maximum ?></strong><div class="muted"><?= $percent ?>%</div></td><td><div class="grade-progress <?= $tone ?>"><span style="width:<?= $percent ?>%"></span></div></td><td><span class="grade-status-badge <?= e($statusKey) ?>"><?= e($statusLabel) ?></span></td><td><?= (int)$row['submission_count'] ?: '<span class="muted">—</span>' ?></td><td><?= $row['last_submitted_at'] ? e(date('M j, Y · g:i A', strtotime($row['last_submitted_at']))) : '<span class="muted">—</span>' ?></td><td><?= $row['due_at'] ? e(date('M j, Y · g:i A', strtotime($row['due_at']))) : '<span class="muted">No deadline</span>' ?></td><td><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-submission.php?classroom_id=<?= $classroomId ?>&student_id=<?= (int)$row['student_id'] ?>&exercise_id=<?= (int)$row['exercise_id'] ?>">Inspect submissions ↗</a></td></tr><?php endforeach; ?><tr id="gradebookNoResults" hidden><td colspan="9"><div class="empty compact-empty"><h3>No matching records</h3><p>Change the search or status filter to see more students.</p></div></td></tr></tbody></table></div><?php endif; ?>
</section>
<p class="muted gradebook-note">Scores are calculated from saved CodeArena submissions. They are not manually editable. The status filter is for triage and does not change grades.</p>
<script>
(() => {
  const search = document.getElementById('gradebookSearch');
  const status = document.getElementById('gradebookStatus');
  const rows = Array.from(document.querySelectorAll('[data-grade-row]'));
  const empty = document.getElementById('gradebookNoResults');
  function filterRows() {
    const q = (search?.value || '').trim().toLowerCase();
    const wanted = status?.value || 'all'; let visible=0;
    rows.forEach(row => { const show = (row.dataset.search || '').includes(q) && (wanted === 'all' || row.dataset.status === wanted); row.hidden = !show; if (show) visible++; });
    if (empty) empty.hidden = visible > 0;
  }
  search?.addEventListener('input', filterRows); status?.addEventListener('change', filterRows);
})();
</script>
<?php page_footer(); ?>
