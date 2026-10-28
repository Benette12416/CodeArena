<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user=require_role(['student']);
award_student_badges($pdo,(int)$user['id']);
$badges=[];
if (codearena_table_exists($pdo,'badge_definitions') && codearena_table_exists($pdo,'student_badges')) {
 $stmt=$pdo->prepare('SELECT bd.*,sb.awarded_at FROM badge_definitions bd LEFT JOIN student_badges sb ON sb.badge_id=bd.id AND sb.student_id=? ORDER BY bd.sort_order,bd.id');$stmt->execute([(int)$user['id']]);$badges=$stmt->fetchAll();
}
$stats=['submissions'=>0,'perfect'=>0,'practice'=>0,'lessons'=>0];
$stmt=$pdo->prepare('SELECT COUNT(*) FROM submissions WHERE user_id=?');$stmt->execute([(int)$user['id']]);$stats['submissions']=(int)$stmt->fetchColumn();
$stmt=$pdo->prepare("SELECT COUNT(*) FROM (SELECT s.exercise_id,MAX(CASE WHEN s.score>=COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(ev.snapshot_json,'$.exercise.points')) AS UNSIGNED),e.points) THEN 1 ELSE 0 END) perfect FROM submissions s JOIN exercises e ON e.id=s.exercise_id LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id WHERE s.user_id=? GROUP BY s.exercise_id) x WHERE perfect=1");$stmt->execute([(int)$user['id']]);$stats['perfect']=(int)$stmt->fetchColumn();
if(codearena_table_exists($pdo,'practice_runs')){$stmt=$pdo->prepare('SELECT COUNT(DISTINCT exercise_id) FROM practice_runs WHERE user_id=?');$stmt->execute([(int)$user['id']]);$stats['practice']=(int)$stmt->fetchColumn();}
if(codearena_table_exists($pdo,'learning_lesson_completions')){$stmt=$pdo->prepare('SELECT COUNT(*) FROM learning_lesson_completions WHERE user_id=?');$stmt->execute([(int)$user['id']]);$stats['lessons']=(int)$stmt->fetchColumn();}
page_header('Achievements');
?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow">STUDENT SPACE · ACHIEVEMENTS</p><h1>Progress worth celebrating.</h1><p class="muted">Badges are earned from saved activity, perfect scores, practice, and lessons completed.</p></div><div class="page-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/student-progress.php">My progress ↗</a></div></section>
<section class="v23-achievement-stats"><article class="panel"><span>Graded submissions</span><strong><?= $stats['submissions'] ?></strong></article><article class="panel"><span>Perfected challenges</span><strong><?= $stats['perfect'] ?></strong></article><article class="panel"><span>Practice challenges</span><strong><?= $stats['practice'] ?></strong></article><article class="panel"><span>Lessons completed</span><strong><?= $stats['lessons'] ?></strong></article></section>
<?php if(!$badges): ?><div class="alert info">Badge tables are not available. Ask the administrator to apply migration 010.</div><?php else: ?><section class="v23-badge-grid"><?php foreach($badges as $b):$earned=!empty($b['awarded_at']); ?><article class="panel v23-badge-card <?= $earned?'earned':'locked' ?>"><span class="v23-badge-icon" aria-hidden="true"><?= e($b['icon']) ?></span><div><span class="pill <?= $earned?'pill-success':'pill-muted' ?>"><?= $earned?'Earned':'Not yet earned' ?></span><h2><?= e($b['title']) ?></h2><p><?= e($b['description']) ?></p><?php if($earned): ?><small class="muted">Earned <?= e(date('M j, Y',strtotime((string)$b['awarded_at']))) ?></small><?php endif; ?></div></article><?php endforeach; ?></section><?php endif; ?>
<?php page_footer(); ?>
