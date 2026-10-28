<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$pathId = max(0, (int)($_GET['path_id'] ?? $_POST['path_id'] ?? 0));
$pathStmt = $pdo->prepare('SELECT id,title,description,is_published FROM learning_paths WHERE id=? AND teacher_id=?');
$pathStmt->execute([$pathId, (int)$user['id']]);
$path = $pathStmt->fetch();
if (!$path) { http_response_code(404); exit('Learning path not found or not owned by you.'); }
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');
    $lessonId = max(0, (int)($_POST['lesson_id'] ?? 0));
    if (in_array($action, ['create_lesson','update_lesson'], true)) {
        $title = trim((string)($_POST['title'] ?? ''));
        $objectives = trim((string)($_POST['objectives'] ?? ''));
        $content = trim((string)($_POST['lesson_content'] ?? ''));
        $language = strtolower(trim((string)($_POST['example_language'] ?? 'python')));
        $code = (string)($_POST['example_code'] ?? '');
        $hints = trim((string)($_POST['hint_text'] ?? ''));
        $order = max(1, min(999, (int)($_POST['sort_order'] ?? 1)));
        $published = isset($_POST['publish']) ? 1 : 0;
        if ($title === '' || mb_strlen($title) > 180 || $content === '' || mb_strlen($content) > 50000 || mb_strlen($objectives) > 500 || mb_strlen($hints) > 12000 || strlen($code) > 50000) {
            flash('Provide a lesson title and content. Keep the title under 180 characters and lesson text under 50,000 characters.', 'error');
            redirect('teacher-lessons.php?path_id='.$pathId.($lessonId ? '#lesson-'.$lessonId : '#lesson-builder'));
        }
        if (!in_array($language, ['python','c','cpp','java','php','ruby','html','css','javascript','text'], true)) $language = 'text';
        try {
            if ($action === 'create_lesson') {
                $stmt = $pdo->prepare('INSERT INTO learning_lessons(path_id,teacher_id,title,objectives,lesson_content,example_language,example_code,hint_text,sort_order,is_published) VALUES(?,?,?,?,?,?,?,?,?,?)');
                $stmt->execute([$pathId,(int)$user['id'],$title,$objectives !== '' ? $objectives : null,$content,$language,$code !== '' ? $code : null,$hints !== '' ? $hints : null,$order,$published]);
                $lessonId = (int)$pdo->lastInsertId();
                audit_log($pdo,(int)$user['id'],'lesson_created','learning_lesson',$lessonId,['path_id'=>$pathId,'published'=>(bool)$published]);
                flash('Lesson created.', 'success');
            } else {
                $stmt = $pdo->prepare('UPDATE learning_lessons SET title=?,objectives=?,lesson_content=?,example_language=?,example_code=?,hint_text=?,sort_order=?,is_published=? WHERE id=? AND path_id=? AND teacher_id=?');
                $stmt->execute([$title,$objectives !== '' ? $objectives : null,$content,$language,$code !== '' ? $code : null,$hints !== '' ? $hints : null,$order,$published,$lessonId,$pathId,(int)$user['id']]);
                if (!$stmt->rowCount()) {
                    $exists=$pdo->prepare('SELECT id FROM learning_lessons WHERE id=? AND path_id=? AND teacher_id=?'); $exists->execute([$lessonId,$pathId,(int)$user['id']]);
                    if (!$exists->fetchColumn()) throw new RuntimeException('Lesson not found.');
                }
                audit_log($pdo,(int)$user['id'],'lesson_updated','learning_lesson',$lessonId,['path_id'=>$pathId,'published'=>(bool)$published]);
                flash('Lesson updated.','success');
            }
        } catch (Throwable $ex) { error_log('CodeArena lesson save failed: '.$ex->getMessage()); flash('Could not save the lesson. Check that migration 010 is installed.', 'error'); }
        redirect('teacher-lessons.php?path_id='.$pathId.'#lesson-'.$lessonId);
    }
    if ($action === 'delete_lesson') {
        $stmt=$pdo->prepare('DELETE FROM learning_lessons WHERE id=? AND path_id=? AND teacher_id=?'); $stmt->execute([$lessonId,$pathId,(int)$user['id']]);
        if ($stmt->rowCount()) { audit_log($pdo,(int)$user['id'],'lesson_deleted','learning_lesson',$lessonId,['path_id'=>$pathId]); flash('Lesson deleted. Student completion for this lesson was removed.','success'); }
        else flash('Lesson was not found.','error');
        redirect('teacher-lessons.php?path_id='.$pathId);
    }
}
$stmt=$pdo->prepare('SELECT l.*, (SELECT COUNT(*) FROM learning_lesson_completions c WHERE c.lesson_id=l.id) AS completion_count FROM learning_lessons l WHERE l.path_id=? AND l.teacher_id=? ORDER BY l.sort_order,l.id');
$stmt->execute([$pathId,(int)$user['id']]); $lessons=$stmt->fetchAll();
$editId=max(0,(int)($_GET['edit']??0)); $editing=null;
foreach($lessons as $row){if((int)$row['id']===$editId){$editing=$row;break;}}
page_header('Lesson builder');
?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow">TEACHER STUDIO · LESSONS</p><h1>Lesson builder</h1><p class="muted">Create short lessons, explain concepts, add code examples and hints, then publish them within a learning path.</p><p class="muted"><strong><?= e($path['title']) ?></strong> · <?= (int)$path['is_published'] ? 'Published path' : 'Draft path' ?></p></div><div class="page-hero-actions"><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher-learning-paths.php">Back to learning paths</a><a class="button" href="#lesson-builder">＋ New lesson</a></div></section>
<div class="v23-lesson-layout">
<section class="panel v23-lesson-form" id="lesson-builder"><div class="section-title"><div><h2><?= $editing ? 'Edit lesson' : 'Create a lesson' ?></h2><p class="muted">Keep each lesson focused on one idea. Use plain text and code examples.</p></div></div>
<form method="post" class="v23-stacked-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="<?= $editing ? 'update_lesson' : 'create_lesson' ?>"><input type="hidden" name="path_id" value="<?= $pathId ?>"><input type="hidden" name="lesson_id" value="<?= (int)($editing['id']??0) ?>">
<label>Lesson title<input name="title" maxlength="180" required value="<?= e($editing['title']??'') ?>" placeholder="e.g. Python variables"></label>
<label>Learning objective (optional)<input name="objectives" maxlength="500" value="<?= e($editing['objectives']??'') ?>" placeholder="Students can create variables and print their values"></label>
<label>Lesson content<textarea name="lesson_content" rows="8" maxlength="50000" required placeholder="Explain the concept step by step. Plain text is supported."><?= e($editing['lesson_content']??'') ?></textarea></label>
<div class="v23-form-two"><label>Code language<select name="example_language"><?php foreach(['python'=>'Python','c'=>'C','cpp'=>'C++','java'=>'Java','php'=>'PHP','ruby'=>'Ruby','html'=>'HTML','css'=>'CSS','javascript'=>'JavaScript','text'=>'Plain text'] as $key=>$label): ?><option value="<?= e($key) ?>" <?= ($editing['example_language']??'python')===$key?'selected':'' ?>><?= e($label) ?></option><?php endforeach; ?></select></label><label>Lesson order<input type="number" name="sort_order" min="1" max="999" required value="<?= (int)($editing['sort_order']??(count($lessons)+1)) ?>"></label></div>
<label>Example code (optional)<textarea name="example_code" rows="7" maxlength="50000" spellcheck="false" placeholder="print('Hello, world!')"><?= e($editing['example_code']??'') ?></textarea></label>
<label>Hints / key takeaways (optional)<textarea name="hint_text" rows="3" maxlength="12000" placeholder="Small reminders or tips students can reveal after reading."><?= e($editing['hint_text']??'') ?></textarea></label>
<label class="builder-option-row"><input type="checkbox" name="publish" value="1" <?= !empty($editing['is_published'])?'checked':'' ?>><span><strong>Publish this lesson</strong><small>Only published lessons inside a published path are visible to students.</small></span></label>
<div class="v14-form-actions"><button class="button" type="submit"><?= $editing ? 'Save lesson' : 'Create lesson' ?> →</button><?php if($editing): ?><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher-lessons.php?path_id=<?= $pathId ?>">Cancel edit</a><?php endif; ?></div></form></section>
<section class="v23-lesson-library"><div class="section-title"><div><h2>Lessons in this path</h2><p class="muted">Order controls the student progression.</p></div><span class="pill"><?= count($lessons) ?> lessons</span></div>
<?php if(!$lessons): ?><div class="empty"><div class="empty-symbol">📘</div><h3>No lessons yet</h3><p>Create your first concept lesson in the form.</p></div><?php else: ?><?php foreach($lessons as $lesson): ?><article class="panel v23-lesson-card" id="lesson-<?= (int)$lesson['id'] ?>"><div class="v23-lesson-card-no"><?= sprintf('%02d',(int)$lesson['sort_order']) ?></div><div class="v23-lesson-card-copy"><div class="v23-lesson-card-meta"><span class="pill <?= (int)$lesson['is_published']?'pill-success':'pill-muted' ?>"><?= (int)$lesson['is_published']?'Published':'Draft' ?></span><span class="muted"><?= (int)$lesson['completion_count'] ?> completions</span></div><h3><?= e($lesson['title']) ?></h3><p><?= e($lesson['objectives'] ?: mb_strimwidth(strip_tags((string)$lesson['lesson_content']),0,150,'…')) ?></p><div class="v23-lesson-card-actions"><a class="button small secondary" href="<?= e($config['base_url']) ?>/teacher-lessons.php?path_id=<?= $pathId ?>&edit=<?= (int)$lesson['id'] ?>#lesson-builder">Edit</a><form method="post" onsubmit="return confirm('Delete this lesson and its completion records?');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_lesson"><input type="hidden" name="path_id" value="<?= $pathId ?>"><input type="hidden" name="lesson_id" value="<?= (int)$lesson['id'] ?>"><button class="button small danger" type="submit">Delete</button></form></div></div></article><?php endforeach; ?><?php endif; ?>
</section></div>
<?php page_footer(); ?>
