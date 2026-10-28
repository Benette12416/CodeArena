<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['student']);
$hasPracticeRuns = codearena_table_exists($pdo, 'practice_runs');
$hasExerciseVersions = codearena_table_exists($pdo, 'exercise_versions')
    && codearena_column_exists($pdo, 'attempts', 'exercise_version_id');
$hasTopic = codearena_column_exists($pdo, 'exercises', 'topic');
$hasExplicitStart = codearena_column_exists($pdo, 'attempts', 'started_explicitly');
$topicExpr = $hasTopic ? 'e.topic' : "'Fundamentals' AS topic";
$startedExpr = $hasExplicitStart ? 'a.started_explicitly' : '0 AS started_explicitly';
$snapshotExpr = $hasExerciseVersions ? 'av.snapshot_json AS attempt_snapshot_json' : 'NULL AS attempt_snapshot_json';
$versionJoin = $hasExerciseVersions ? 'LEFT JOIN exercise_versions av ON av.id=a.exercise_version_id' : '';
$practiceCountExpr = $hasPracticeRuns
    ? '(SELECT COUNT(*) FROM practice_runs pr WHERE pr.user_id=? AND pr.exercise_id=e.id) AS practice_run_count'
    : '0 AS practice_run_count';
$practiceMasteredExpr = $hasPracticeRuns
    ? 'EXISTS(SELECT 1 FROM practice_runs pr WHERE pr.user_id=? AND pr.exercise_id=e.id AND pr.all_samples_passed=1) AS practice_mastered'
    : '0 AS practice_mastered';
$bindings = [];
if ($hasPracticeRuns) $bindings[] = (int)$user['id'];
if ($hasPracticeRuns) $bindings[] = (int)$user['id'];
$sql = "SELECT e.id,e.title,{$topicExpr},e.difficulty,e.points,e.time_limit_seconds,
  {$snapshotExpr}, COALESCE(a.best_score,0) AS best_score,{$startedExpr},a.status AS attempt_status,
  {$practiceCountExpr}, {$practiceMasteredExpr},
  EXISTS(SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1) AS has_assignment
  FROM exercises e LEFT JOIN attempts a ON a.exercise_id=e.id AND a.user_id=?
  {$versionJoin}
  WHERE e.is_published=1 ORDER BY topic,e.difficulty,e.title";
// The user ID for the attempts join follows the optional practice-run parameters.
$bindings[] = (int)$user['id'];
$stmt = $pdo->prepare($sql);
$stmt->execute($bindings);
$topics=[]; $accessible=[];
foreach ($stmt->fetchAll() as $row) {
    if ((int)($row['started_explicitly'] ?? 0) === 1 && !empty($row['attempt_snapshot_json'])) { $snap=json_decode((string)$row['attempt_snapshot_json'],true); if (is_array($snap['exercise'] ?? null)) { $ve=$snap['exercise']; $row['title']=(string)($ve['title'] ?? $row['title']); $row['topic']=(string)($ve['topic'] ?? $row['topic']); $row['difficulty']=(string)($ve['difficulty'] ?? $row['difficulty']); $row['points']=max(1,(int)($ve['points'] ?? $row['points'])); } }
    $context=student_exercise_access_context($pdo,(int)$user['id'],(int)$row['id']);
    if (!$context['allowed']) continue;
    $row['topic'] = trim((string)$row['topic']) ?: 'Fundamentals';
    $row['max_points'] = max(1,(int)$row['points']);
    $row['best_score'] = min($row['max_points'],(int)$row['best_score']);
    $row['mastered'] = $row['best_score'] >= $row['max_points'] || (int)$row['practice_mastered'] === 1;
    $row['attempted'] = (int)($row['started_explicitly'] ?? 0) === 1 || (int)$row['practice_run_count'] > 0;
    $row['url'] = rtrim($config['base_url'],'/') . ((int)$row['has_assignment'] ? '/exercise.php?id=' : '/practice.php?id=') . (int)$row['id'];
    $accessible[] = $row;
    if (!isset($topics[$row['topic']])) $topics[$row['topic']]=['topic'=>$row['topic'],'total'=>0,'attempted'=>0,'mastered'=>0,'score_sum'=>0,'scored'=>0,'items'=>[]];
    $key=$row['topic']; $topics[$key]['total']++;
    $topics[$key]['attempted'] += $row['attempted'] ? 1 : 0;
    $topics[$key]['mastered'] += $row['mastered'] ? 1 : 0;
    if ($row['attempted'] && (int)$row['started_explicitly']===1) { $topics[$key]['score_sum'] += (int)round($row['best_score']/$row['max_points']*100); $topics[$key]['scored']++; }
    $topics[$key]['items'][]=$row;
}
foreach ($topics as &$t) {
    $t['progress']=$t['total'] ? (int)round($t['mastered']/$t['total']*100) : 0;
    $t['average']=$t['scored'] ? (int)round($t['score_sum']/$t['scored']) : null;
    usort($t['items'], static function($a,$b){
        if ($a['mastered'] !== $b['mastered']) return $a['mastered'] <=> $b['mastered'];
        $rank=['Easy'=>0,'Medium'=>1,'Hard'=>2]; return ($rank[$a['difficulty']]??3) <=> ($rank[$b['difficulty']]??3);
    });
}
unset($t);
usort($topics, static fn($a,$b) => $a['progress'] <=> $b['progress'] ?: strcmp($a['topic'],$b['topic']));
$recommended=null;
foreach ($topics as $topic) {
    foreach ($topic['items'] as $item) if (!$item['mastered']) { $recommended=['topic'=>$topic['topic'],'item'=>$item]; break 2; }
}
$masteredTotal=count(array_filter($accessible,static fn($r)=>$r['mastered']));
$attemptedTotal=count(array_filter($accessible,static fn($r)=>$r['attempted']));
$overall=count($accessible)?(int)round($masteredTotal/count($accessible)*100):0;
page_header('My progress');
?>
<?php if (!$hasPracticeRuns || !$hasTopic || !$hasExplicitStart || !$hasExerciseVersions): ?>
<div class="alert info v17-schema-notice" role="status">Some optional progress-history features are not installed in this database yet. This page is using compatibility mode so your progress can still load. Ask the site administrator to check migrations 004, 006, and 007 in the README, and run only the migrations that have not already been applied.</div>
<?php endif; ?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow">STUDENT SPACE · SKILLS MAP</p><h1>Your progress, made visible.</h1><p class="muted">Review what you have practiced, what you've mastered, and which concept could use a little more attention.</p></div><div class="page-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/student-learning-paths.php">Explore learning paths ↗</a></div></section>
<section class="v14-progress-summary"><article class="panel"><span>Accessible challenges</span><strong><?= count($accessible) ?></strong><small>Published work available to you</small></article><article class="panel"><span>Attempted</span><strong><?= $attemptedTotal ?></strong><small>Practice runs or started attempts</small></article><article class="panel"><span>Mastered</span><strong><?= $masteredTotal ?></strong><small>Perfect score or public practice samples passed</small></article><article class="panel"><span>Mastery progress</span><strong><?= $overall ?>%</strong><div class="grade-progress"><span style="width:<?= $overall ?>%"></span></div></article></section>
<?php if ($recommended): ?><section class="panel v14-recommendation"><div class="v14-recommendation-icon">✦</div><div><p class="eyebrow">RECOMMENDED NEXT STEP</p><h2><?= e($recommended['item']['title']) ?></h2><p class="muted">Build confidence in <?= e($recommended['topic']) ?>. This is a challenge you haven't mastered yet.</p><div class="v14-recommendation-meta"><span class="difficulty <?= strtolower(e($recommended['item']['difficulty'])) ?>"><?= e($recommended['item']['difficulty']) ?></span><span><?= (int)$recommended['item']['points'] ?> points</span><span><?= (int)ceil((int)$recommended['item']['time_limit_seconds']/60) ?> min</span></div></div><a class="button" href="<?= e($recommended['item']['url']) ?>">Continue learning →</a></section><?php endif; ?>
<section class="v14-skill-section"><div class="section-title"><div><h2>Skills map</h2><p class="muted">Topic progress comes from perfect graded scores or passing all configured public sample cases in Practice Mode. Hidden tests stay private.</p></div><span class="pill"><?= count($topics) ?> topics</span></div>
<?php if (!$topics): ?><div class="empty"><div class="empty-symbol">⌘</div><h3>No published challenges available</h3><p>Join a classroom or return when your teacher publishes exercises.</p><a class="button" href="<?= e($config['base_url']) ?>/student-classrooms.php">My classes</a></div><?php else: ?><div class="v14-skill-grid"><?php foreach ($topics as $t): $next=array_values(array_filter($t['items'],static fn($i)=>!$i['mastered'])); ?><article class="panel v14-skill-card"><div class="v14-skill-head"><span class="v14-skill-icon">&lt;/&gt;</span><span class="pill"><?= (int)$t['mastered'] ?>/<?= (int)$t['total'] ?> mastered</span></div><h3><?= e($t['topic']) ?></h3><div class="v14-skill-progress-copy"><span>Topic mastery</span><strong><?= (int)$t['progress'] ?>%</strong></div><div class="grade-progress"><span style="width:<?= (int)$t['progress'] ?>%"></span></div><div class="v14-skill-stats"><span><?= (int)$t['attempted'] ?> attempted</span><span><?= $t['average']===null?'No graded scores yet':'Graded average '.$t['average'].'%' ?></span></div><?php if ($next): ?><a class="quiet-link" href="<?= e($next[0]['url']) ?>">Practice next: <?= e($next[0]['title']) ?> →</a><?php else: ?><span class="v14-skill-complete">✓ All available items mastered</span><?php endif; ?></article><?php endforeach; ?></div><?php endif; ?></section>
<section class="panel v14-progress-details"><div class="section-title"><div><h2>Challenge history</h2><p class="muted">Your currently available challenges and their progress state.</p></div></div><div class="table-wrap"><table><thead><tr><th>Challenge</th><th>Topic</th><th>Difficulty</th><th>Status</th><th>Best graded score</th><th></th></tr></thead><tbody><?php foreach($accessible as $row): ?><tr><td><strong><?= e($row['title']) ?></strong></td><td><?= e($row['topic']) ?></td><td><?= e($row['difficulty']) ?></td><td><span class="grade-status-badge <?= $row['mastered']?'perfect':($row['attempted']?'partial':'not_started') ?>"><?= $row['mastered']?'Mastered':($row['attempted']?'In progress':'Not started') ?></span></td><td><?= (int)$row['started_explicitly']===1 ? (int)$row['best_score'].' / '.$row['max_points'] : '<span class="muted">Practice only</span>' ?></td><td><a class="quiet-link" href="<?= e($row['url']) ?>">Open →</a></td></tr><?php endforeach; ?></tbody></table></div></section>
<?php page_footer(); ?>
