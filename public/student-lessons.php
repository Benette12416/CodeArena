<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user=require_role(['student']);
$pathId=max(0,(int)($_GET['path_id']??0));
if ($pathId<1) {
  $stmt=$pdo->query("SELECT lp.id,lp.title,lp.description,u.name AS teacher_name,COUNT(ll.id) AS lesson_count FROM learning_paths lp JOIN users u ON u.id=lp.teacher_id JOIN learning_lessons ll ON ll.path_id=lp.id AND ll.is_published=1 WHERE lp.is_published=1 GROUP BY lp.id,lp.title,lp.description,u.name ORDER BY lp.updated_at DESC");
  $paths=$stmt->fetchAll(); page_header('Lessons');
  ?>
  <section class="page-hero compact-page-hero"><div><p class="eyebrow">STUDENT SPACE · LESSONS</p><h1>Learn the concept first.</h1><p class="muted">Choose a learning path to read its lessons, study examples, and unlock each lesson in order.</p></div><div class="page-hero-actions"><a class="button secondary" href="<?= e($config['base_url']) ?>/student-learning-paths.php">Learning paths</a></div></section>
  <?php if(!$paths): ?><div class="empty"><h3>No published lessons yet</h3><p>Your teacher can create lessons within a published learning path.</p></div><?php else: ?><div class="v23-path-cards"><?php foreach($paths as $path): ?><a class="panel v23-path-card" href="<?= e($config['base_url']) ?>/student-lessons.php?path_id=<?= (int)$path['id'] ?>"><span class="v23-path-card-icon">📘</span><h2><?= e($path['title']) ?></h2><p><?= e($path['description'] ?: 'Study short lessons and examples before solving exercises.') ?></p><div class="muted"><?= (int)$path['lesson_count'] ?> lessons · <?= e($path['teacher_name']) ?></div><strong>Open lessons →</strong></a><?php endforeach; ?></div><?php endif; ?>
  <?php page_footer(); exit;
}
$pathStmt=$pdo->prepare('SELECT id,title,description FROM learning_paths WHERE id=? AND is_published=1'); $pathStmt->execute([$pathId]); $path=$pathStmt->fetch();
if(!$path){http_response_code(404);exit('Learning path not found.');}
$stmt=$pdo->prepare("SELECT ll.id,ll.title,ll.objectives,ll.sort_order,ll.example_language,ll.is_published,lc.completed_at FROM learning_lessons ll LEFT JOIN learning_lesson_completions lc ON lc.lesson_id=ll.id AND lc.user_id=? WHERE ll.path_id=? AND ll.is_published=1 ORDER BY ll.sort_order,ll.id");
$stmt->execute([(int)$user['id'],$pathId]); $lessons=$stmt->fetchAll();
$previousComplete=true; $completed=0;
foreach($lessons as &$lesson){$lesson['completed']=!empty($lesson['completed_at']);$lesson['unlocked']=$previousComplete;if($lesson['completed'])$completed++;$previousComplete=$previousComplete && $lesson['completed'];} unset($lesson);
page_header('Lessons · '.$path['title']);
?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow">LESSON SERIES</p><h1><?= e($path['title']) ?></h1><p class="muted"><?= e($path['description'] ?: 'Work through the lessons in order. Each lesson builds on the previous one.') ?></p></div><div class="page-hero-actions"><a class="button secondary" href="<?= e($config['base_url']) ?>/student-learning-paths.php?path_id=<?= $pathId ?>">Challenges in this path</a></div></section>
<section class="panel v23-lesson-progress"><div><strong>Your lesson progress</strong><p class="muted"><?= $completed ?> of <?= count($lessons) ?> lessons complete</p></div><div class="grade-progress"><span style="width:<?= count($lessons)?(int)round($completed/count($lessons)*100):0 ?>%"></span></div></section>
<?php if(!$lessons): ?><div class="empty"><h3>No published lessons</h3><p>Your teacher has not published lessons for this path yet.</p></div><?php else: ?><div class="v23-lesson-student-list"><?php foreach($lessons as $lesson): ?><article class="panel v23-student-lesson-card"><span class="v23-lesson-card-no"><?= $lesson['completed']?'✓':sprintf('%02d',(int)$lesson['sort_order']) ?></span><div class="v23-lesson-card-copy"><span class="pill <?= $lesson['completed']?'pill-success':($lesson['unlocked']?'pill-info':'pill-muted') ?>"><?= $lesson['completed']?'Completed':($lesson['unlocked']?'Available':'Locked') ?></span><h2><?= e($lesson['title']) ?></h2><p><?= e($lesson['objectives'] ?: 'Read the explanation and example, then mark the lesson complete.') ?></p></div><div class="v23-lesson-card-actions"><?php if($lesson['unlocked']||$lesson['completed']): ?><a class="button small <?= $lesson['completed']?'secondary':'' ?>" href="<?= e($config['base_url']) ?>/student-lesson.php?id=<?= (int)$lesson['id'] ?>"><?= $lesson['completed']?'Review lesson':'Start lesson' ?> →</a><?php else: ?><button type="button" class="button small secondary" disabled>🔒 Locked</button><?php endif; ?></div></article><?php endforeach; ?></div><?php endif; ?>
<?php page_footer(); ?>
