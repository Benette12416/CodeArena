<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user=require_role(['student']);
$lessonId=max(0,(int)($_GET['id']??$_POST['lesson_id']??0));
$stmt=$pdo->prepare('SELECT ll.*,lp.title AS path_title,lp.id AS path_id,lp.is_published AS path_published FROM learning_lessons ll JOIN learning_paths lp ON lp.id=ll.path_id WHERE ll.id=? AND ll.is_published=1 AND lp.is_published=1');
$stmt->execute([$lessonId]); $lesson=$stmt->fetch(); if(!$lesson){http_response_code(404);exit('Lesson not found.');}
$previous=$pdo->prepare('SELECT COUNT(*) FROM learning_lessons ll LEFT JOIN learning_lesson_completions lc ON lc.lesson_id=ll.id AND lc.user_id=? WHERE ll.path_id=? AND ll.is_published=1 AND (ll.sort_order < ? OR (ll.sort_order=? AND ll.id < ?)) AND lc.id IS NULL');
$previous->execute([(int)$user['id'],(int)$lesson['path_id'],(int)$lesson['sort_order'],(int)$lesson['sort_order'],$lessonId]);
if((int)$previous->fetchColumn()>0){flash('Complete the previous lesson before opening this one.','info');redirect('student-lessons.php?path_id='.(int)$lesson['path_id']);}
$doneStmt=$pdo->prepare('SELECT completed_at FROM learning_lesson_completions WHERE user_id=? AND lesson_id=?');$doneStmt->execute([(int)$user['id'],$lessonId]);$completedAt=$doneStmt->fetchColumn();
if($_SERVER['REQUEST_METHOD']==='POST'){
  verify_csrf();
  $pdo->prepare('INSERT IGNORE INTO learning_lesson_completions(user_id,lesson_id) VALUES(?,?)')->execute([(int)$user['id'],$lessonId]);
  audit_log($pdo,(int)$user['id'],'lesson_completed','learning_lesson',$lessonId,['path_id'=>(int)$lesson['path_id']]);
  award_student_badges($pdo,(int)$user['id']);
  flash('Lesson marked complete. Your next lesson is now available.','success');
  redirect('student-lessons.php?path_id='.(int)$lesson['path_id']);
}
page_header($lesson['title']);
?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow"><?= e($lesson['path_title']) ?> · LESSON <?= (int)$lesson['sort_order'] ?></p><h1><?= e($lesson['title']) ?></h1><p class="muted"><?= e($lesson['objectives'] ?: 'Read the lesson and study the example before moving on.') ?></p></div><div class="page-hero-actions"><a class="button secondary" href="<?= e($config['base_url']) ?>/student-lessons.php?path_id=<?= (int)$lesson['path_id'] ?>">← All lessons</a></div></section>
<article class="panel v23-lesson-reading"><div class="v23-lesson-reading-content"><?= nl2br(e($lesson['lesson_content'])) ?></div>
<?php if(trim((string)$lesson['example_code'])!==''): ?><section class="v23-example-block"><div class="v23-example-header"><strong>Code example · <?= e(strtoupper((string)$lesson['example_language'])) ?></strong><button type="button" class="button small secondary" id="copyLessonCode">Copy code</button></div><pre id="lessonCode"><code><?= e($lesson['example_code']) ?></code></pre></section><script>document.getElementById('copyLessonCode')?.addEventListener('click',async()=>{const t=document.querySelector('#lessonCode code')?.textContent||'';try{await navigator.clipboard.writeText(t);document.getElementById('copyLessonCode').textContent='Copied ✓'}catch(_){window.prompt('Copy code:',t)}});</script><?php endif; ?>
<?php if(trim((string)$lesson['hint_text'])!==''): ?><details class="v23-lesson-hints"><summary>Hints and key takeaways</summary><div><?= nl2br(e($lesson['hint_text'])) ?></div></details><?php endif; ?>
<div class="v23-lesson-finish"><div><strong><?= $completedAt?'Lesson completed ✓':'Ready to continue?' ?></strong><p class="muted"><?= $completedAt?'You can revisit this lesson any time.':'Mark this lesson complete to unlock the next lesson in this path.' ?></p></div><?php if(!$completedAt): ?><form method="post"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="lesson_id" value="<?= $lessonId ?>"><button class="button" type="submit">Mark lesson complete →</button></form><?php else: ?><a class="button" href="<?= e($config['base_url']) ?>/student-lessons.php?path_id=<?= (int)$lesson['path_id'] ?>">Continue to lesson list →</a><?php endif; ?></div></article>
<?php page_footer(); ?>
