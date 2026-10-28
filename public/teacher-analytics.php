<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$teacherId = (int)$user['id'];

$scalar = static function (PDO $pdo, string $sql, array $params = []): int {
    $stmt = $pdo->prepare($sql); $stmt->execute($params); return (int)$stmt->fetchColumn();
};
$classCount = $scalar($pdo, 'SELECT COUNT(*) FROM classrooms WHERE teacher_id=? AND is_active=1', [$teacherId]);
$studentCount = $scalar($pdo, "SELECT COUNT(DISTINCT ce.student_id) FROM class_enrollments ce JOIN classrooms c ON c.id=ce.classroom_id WHERE c.teacher_id=? AND c.is_active=1 AND ce.enrollment_status='active'", [$teacherId]);
$exerciseCount = $scalar($pdo, 'SELECT COUNT(*) FROM exercises WHERE created_by=?', [$teacherId]);
$submissionCount = $scalar($pdo, 'SELECT COUNT(*) FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE e.created_by=?', [$teacherId]);
$publishedCount = $scalar($pdo, 'SELECT COUNT(*) FROM exercises WHERE created_by=? AND is_published=1', [$teacherId]);
$monitoringCount = $scalar($pdo, 'SELECT COUNT(*) FROM exercises WHERE created_by=? AND monitoring_enabled=1', [$teacherId]);

// Load submitted scores with their immutable version snapshot, when available.
$scoreStmt = $pdo->prepare("SELECT s.id,s.user_id,s.exercise_id,s.score,s.created_at,e.title,e.topic,e.points AS current_points,ev.snapshot_json,u.name AS student_name
    FROM submissions s JOIN exercises e ON e.id=s.exercise_id JOIN users u ON u.id=s.user_id
    LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id
    WHERE e.created_by=? ORDER BY s.created_at DESC LIMIT 10000");
$scoreStmt->execute([$teacherId]); $scoreRows = $scoreStmt->fetchAll();
foreach ($scoreRows as &$historicalRow) {
    if (!empty($historicalRow['snapshot_json'])) {
        $historicalSnapshot = json_decode((string)$historicalRow['snapshot_json'], true);
        if (is_array($historicalSnapshot['exercise'] ?? null)) {
            $historicalExercise = $historicalSnapshot['exercise'];
            $historicalRow['title'] = (string)($historicalExercise['title'] ?? $historicalRow['title']);
            $historicalRow['topic'] = (string)($historicalExercise['topic'] ?? $historicalRow['topic']);
            $historicalRow['current_points'] = max(1, (int)($historicalExercise['points'] ?? $historicalRow['current_points']));
        }
    }
}
unset($historicalRow);
$maxForRow = static function (array $row): int {
    $max = max(1, (int)($row['current_points'] ?? 1));
    if (!empty($row['snapshot_json'])) {
        $snapshot = json_decode((string)$row['snapshot_json'], true);
        $points = $snapshot['exercise']['points'] ?? null;
        if (is_numeric($points)) $max = max(1, (int)$points);
    }
    return $max;
};
$percentForRow = static fn(array $row): int => min(100, (int)round((int)$row['score'] / $maxForRow($row) * 100));
$percentTotal = 0; $perfectCount = 0; $scoreDistribution = ['Below 50%' => 0, '50–74%' => 0, '75–99%' => 0, 'Perfect' => 0];
$topicStats = []; $exerciseStats = []; $studentStats = [];
foreach ($scoreRows as $row) {
    $percent = $percentForRow($row); $percentTotal += $percent;
    if ($percent >= 100) { $perfectCount++; $scoreDistribution['Perfect']++; }
    elseif ($percent >= 75) $scoreDistribution['75–99%']++;
    elseif ($percent >= 50) $scoreDistribution['50–74%']++;
    else $scoreDistribution['Below 50%']++;
    $topic = trim((string)($row['topic'] ?? 'Fundamentals')) ?: 'Fundamentals';
    if (!isset($topicStats[$topic])) $topicStats[$topic] = ['count'=>0,'percent_total'=>0];
    $topicStats[$topic]['count']++; $topicStats[$topic]['percent_total'] += $percent;
    $exerciseId = (int)$row['exercise_id'];
    if (!isset($exerciseStats[$exerciseId])) $exerciseStats[$exerciseId] = ['title'=>(string)$row['title'],'count'=>0,'percent_total'=>0,'perfect'=>0];
    $exerciseStats[$exerciseId]['count']++; $exerciseStats[$exerciseId]['percent_total'] += $percent;
    if ($percent >= 100) $exerciseStats[$exerciseId]['perfect']++;
    $studentId = (int)$row['user_id'];
    if (!isset($studentStats[$studentId])) $studentStats[$studentId] = ['name'=>(string)$row['student_name'],'count'=>0,'percent_total'=>0];
    $studentStats[$studentId]['count']++; $studentStats[$studentId]['percent_total'] += $percent;
}
$overallAverage = $scoreRows ? (int)round($percentTotal / count($scoreRows)) : 0;
foreach ($topicStats as &$stats) $stats['average'] = (int)round($stats['percent_total'] / max(1,$stats['count'])); unset($stats);
foreach ($exerciseStats as &$stats) $stats['average'] = (int)round($stats['percent_total'] / max(1,$stats['count'])); unset($stats);
foreach ($studentStats as &$stats) $stats['average'] = (int)round($stats['percent_total'] / max(1,$stats['count'])); unset($stats);
$topicStats = array_values($topicStats); usort($topicStats, static fn($a,$b) => $b['count'] <=> $a['count']);
$exerciseStats = array_values($exerciseStats); usort($exerciseStats, static fn($a,$b) => $b['count'] <=> $a['count']);
$studentsNeedHelp = array_values(array_filter($studentStats, static fn($s) => $s['count'] >= 2 && $s['average'] < 50));
usort($studentsNeedHelp, static fn($a,$b) => $a['average'] <=> $b['average']);

// Fill all 14 days to avoid gaps in the activity chart.
$trendStmt = $pdo->prepare("SELECT DATE(s.created_at) AS day, COUNT(*) AS total FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE e.created_by=? AND s.created_at >= DATE_SUB(CURDATE(), INTERVAL 13 DAY) GROUP BY DATE(s.created_at)");
$trendStmt->execute([$teacherId]); $trendRows = [];
foreach ($trendStmt->fetchAll() as $r) $trendRows[(string)$r['day']] = (int)$r['total'];
$trend = []; $maxDay = 1; $today = new DateTimeImmutable('today');
for ($i=13; $i>=0; $i--) { $day=$today->modify('-'.$i.' days')->format('Y-m-d'); $total=$trendRows[$day]??0; $trend[]=['day'=>$day,'label'=>date('M j',strtotime($day)),'total'=>$total]; $maxDay=max($maxDay,$total); }
$recent = array_slice($scoreRows,0,8);
$teacherPortalBase = rtrim((string)$config['base_url'],'/');
page_header('Teacher analytics');
?>
<section class="page-hero compact-page-hero v15-analytics-hero">
  <div><p class="eyebrow">TEACHER STUDIO · INSIGHTS</p><h1>Classroom analytics</h1><p class="muted">A focused view of activity, exercise performance, and students who may need extra support. These insights inform teaching decisions; they do not change grades. A maximum of 10,000 latest submissions is included in detailed analysis.</p></div>
  <div class="page-hero-actions"><a class="button secondary" href="<?= e($teacherPortalBase) ?>/teacher-classrooms.php">Open gradebooks</a><a class="button" href="<?= e($teacherPortalBase) ?>/teacher-submission.php">Inspect submissions</a></div>
</section>
<div class="v15-analytics-summary">
  <article class="panel v15-analytics-stat"><small>ACTIVE CLASSROOMS</small><strong><?= $classCount ?></strong><span>Classrooms you currently manage</span></article>
  <article class="panel v15-analytics-stat"><small>ENROLLED STUDENTS</small><strong><?= $studentCount ?></strong><span>Distinct active student accounts</span></article>
  <article class="panel v15-analytics-stat"><small>EXERCISE LIBRARY</small><strong><?= $exerciseCount ?></strong><span><?= $publishedCount ?> published · <?= $exerciseCount-$publishedCount ?> drafts</span></article>
  <article class="panel v15-analytics-stat"><small>SUBMISSION AVERAGE</small><strong><?= $overallAverage ?>%</strong><span><?= $submissionCount ?> saved submissions analyzed</span></article>
</div>
<div class="v15-analytics-grid">
  <section class="panel v15-analytics-panel">
    <div class="section-title"><div><h2>Submission activity</h2><p class="panel-subtitle">Daily submissions over the last 14 days.</p></div><span class="pill">14 days</span></div>
    <?php if ($submissionCount): ?><div class="v15-day-bars" role="img" aria-label="Bar chart of daily submissions for the past 14 days."><?php foreach ($trend as $day): $height=(int)round(($day['total']/$maxDay)*100); ?><div class="v15-day-bar" title="<?= e($day['label']) ?>: <?= $day['total'] ?> submissions"><div class="v15-day-bar-track"><span class="v15-day-bar-fill" style="height:<?= max($day['total']>0?5:1,$height) ?>%"></span></div><time><?= e($day['label']) ?></time></div><?php endforeach; ?></div><p class="muted" style="font-size:10px;margin:12px 0 0">Daily total: <?= array_sum(array_column($trend,'total')) ?> submissions in this 14-day window.</p><?php else: ?><div class="v15-analytics-empty">No submissions yet. Once students submit solutions, daily activity will appear here.</div><?php endif; ?>
  </section>
  <section class="panel v15-analytics-panel">
    <h2>Topic performance</h2><p class="panel-subtitle">Average percentage based on saved submission scores and their original exercise-version points.</p>
    <?php if ($topicStats): ?><div class="v15-topic-list"><?php foreach (array_slice($topicStats,0,8) as $topic): ?><div class="v15-topic-row"><div class="v15-topic-label"><strong><?= e($topic['topic']??'') ?></strong><span><?= (int)$topic['average'] ?>% · <?= (int)$topic['count'] ?> runs</span></div><div class="v15-topic-track"><div class="v15-topic-fill" style="width:<?= (int)$topic['average'] ?>%"></div></div></div><?php endforeach; ?></div><?php else: ?><div class="v15-analytics-empty">Topic analytics will appear when students submit work.</div><?php endif; ?>
  </section>
</div>
<div class="v15-analytics-below">
  <section class="panel v15-analytics-panel">
    <h2>Score distribution</h2><p class="panel-subtitle">Each saved submission is grouped by its percentage of the maximum points for that version.</p>
    <?php if ($submissionCount): ?><div class="v15-score-bars"><?php foreach ($scoreDistribution as $label=>$count): ?><div class="v15-score-row"><span class="bar-label"><?= e($label) ?></span><div class="bar"><span style="width:<?= (int)round($count/max(1,$submissionCount)*100) ?>%"></span></div><strong><?= (int)$count ?></strong></div><?php endforeach; ?></div><?php else: ?><div class="v15-analytics-empty">No scored submissions yet.</div><?php endif; ?>
  </section>
  <section class="panel v15-analytics-panel">
    <h2>Exercises with the most activity</h2><p class="panel-subtitle">Useful for spotting frequently attempted or assigned challenges.</p>
    <?php if ($exerciseStats): ?><div class="v15-topic-list"><?php foreach (array_slice($exerciseStats,0,6) as $exercise): ?><div class="v15-topic-row"><div class="v15-topic-label"><strong><?= e($exercise['title']) ?></strong><span><?= (int)$exercise['count'] ?> runs · <?= (int)$exercise['average'] ?>% avg</span></div><div class="v15-topic-track"><div class="v15-topic-fill" style="width:<?= (int)$exercise['average'] ?>%"></div></div></div><?php endforeach; ?></div><p style="margin:17px 0 0"><a class="quiet-link" href="<?= e($teacherPortalBase) ?>/teacher.php#exercise-library">Manage exercise library ↗</a></p><?php else: ?><div class="v15-analytics-empty">Your exercise activity will appear here.</div><?php endif; ?>
  </section>
</div>
<section class="panel v15-analytics-panel" style="margin-top:18px">
  <div class="section-title"><div><h2>Students to check in with</h2><p class="panel-subtitle">Students averaging below 50% across at least two submissions. This is a support signal, not a grade penalty.</p></div><span class="pill"><?= count($studentsNeedHelp) ?> suggested check-ins</span></div>
  <?php if ($studentsNeedHelp): ?><div class="table-wrap"><table><thead><tr><th>Student</th><th>Submissions</th><th>Average</th><th>Suggested next step</th></tr></thead><tbody><?php foreach (array_slice($studentsNeedHelp,0,10) as $student): ?><tr><td><strong><?= e($student['name']) ?></strong></td><td><?= (int)$student['count'] ?></td><td><strong class="score-failed"><?= (int)$student['average'] ?>%</strong></td><td>Review submission feedback and assign a foundational practice challenge.</td></tr><?php endforeach; ?></tbody></table></div><?php else: ?><div class="v15-analytics-empty">No students currently match this suggestion. Students with fewer than two submissions are not included.</div><?php endif; ?>
</section>
<section class="panel v15-analytics-panel" style="margin-top:18px">
  <div class="section-title"><div><h2>Recent submissions</h2><p class="panel-subtitle">Latest saved submissions across your exercise library.</p></div><a class="quiet-link" href="<?= e($teacherPortalBase) ?>/teacher-submission.php">Open inspector ↗</a></div>
  <?php if ($recent): ?><div class="table-wrap"><table><thead><tr><th>Student</th><th>Exercise</th><th>Topic</th><th>Score</th><th>Submitted</th><th></th></tr></thead><tbody><?php foreach ($recent as $row): $percent=$percentForRow($row); ?><tr><td><strong><?= e($row['student_name']) ?></strong></td><td><?= e($row['title']) ?></td><td><?= e($row['topic']) ?></td><td><strong class="<?= $percent>=100?'score-perfect':($percent>=50?'score-progress':'score-failed') ?>"><?= (int)$row['score'] ?> / <?= $maxForRow($row) ?></strong><small class="muted block"><?= $percent ?>%</small></td><td><?= e(date('M j, Y · g:i A',strtotime((string)$row['created_at']))) ?></td><td><a class="button secondary small" href="<?= e($teacherPortalBase) ?>/teacher-submission.php?submission_id=<?= (int)$row['id'] ?>">Inspect</a></td></tr><?php endforeach; ?></tbody></table></div><?php else: ?><div class="v15-analytics-empty">Recent submissions will appear after students submit solutions.</div><?php endif; ?>
</section>
<section class="v15-analytics-panel" style="margin-top:18px"><p class="muted" style="font-size:10px;margin:0">Exam monitoring is enabled for <?= $monitoringCount ?> exercise(s). Review browser event reports separately; event counts are not proof of cheating.</p></section>
<?php page_footer(); ?>
