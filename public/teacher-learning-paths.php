<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);

function teacher_paths_redirect(int $pathId = 0): never {
    redirect('teacher-learning-paths.php' . ($pathId > 0 ? '#path-' . $pathId : '#create-path'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');
    if ($action === 'create_path' || $action === 'update_path') {
        $pathId = max(0, (int)($_POST['path_id'] ?? 0));
        $title = trim((string)($_POST['title'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));
        $published = isset($_POST['publish']) ? 1 : 0;
        $ids = $_POST['exercise_ids'] ?? [];
        if (!is_array($ids)) $ids = [];
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), static fn($id) => $id > 0)));
        $orderInput = $_POST['exercise_order'] ?? []; if (!is_array($orderInput)) $orderInput = [];
        $originalOrder = array_flip($ids);
        usort($ids, static function($a,$b) use ($orderInput,$originalOrder) { $oa=max(1,min(500,(int)($orderInput[$a] ?? 500))); $ob=max(1,min(500,(int)($orderInput[$b] ?? 500))); return $oa <=> $ob ?: (($originalOrder[$a] ?? 0) <=> ($originalOrder[$b] ?? 0)); });
        if ($title === '' || mb_strlen($title) > 180 || mb_strlen($description) > 4000) {
            flash('Enter a path title (180 characters maximum) and keep the description under 4,000 characters.', 'error');
            teacher_paths_redirect($pathId);
        }
        if (!$ids) {
            flash('Choose at least one of your published exercises for this learning path.', 'error');
            teacher_paths_redirect($pathId);
        }
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $check = $pdo->prepare("SELECT id FROM exercises WHERE created_by=? AND is_published=1 AND id IN ($placeholders) ORDER BY id");
        $check->execute(array_merge([(int)$user['id']], $ids));
        $ownedIds = array_map('intval', $check->fetchAll(PDO::FETCH_COLUMN));
        if (count($ownedIds) !== count($ids)) {
            flash('Learning paths can only include exercises you own that are currently published.', 'error');
            teacher_paths_redirect($pathId);
        }
        try {
            $pdo->beginTransaction();
            if ($action === 'create_path') {
                $stmt = $pdo->prepare('INSERT INTO learning_paths(teacher_id,title,description,is_published) VALUES(?,?,?,?)');
                $stmt->execute([(int)$user['id'], $title, $description !== '' ? $description : null, $published]);
                $pathId = (int)$pdo->lastInsertId();
            } else {
                $stmt = $pdo->prepare('UPDATE learning_paths SET title=?,description=?,is_published=? WHERE id=? AND teacher_id=?');
                $stmt->execute([$title, $description !== '' ? $description : null, $published, $pathId, (int)$user['id']]);
                if ($stmt->rowCount() === 0) {
                    $exists = $pdo->prepare('SELECT id FROM learning_paths WHERE id=? AND teacher_id=?');
                    $exists->execute([$pathId, (int)$user['id']]);
                    if (!$exists->fetchColumn()) throw new RuntimeException('Learning path not found or not owned by you.');
                }
                $pdo->prepare('DELETE FROM learning_path_items WHERE path_id=?')->execute([$pathId]);
            }
            $add = $pdo->prepare('INSERT INTO learning_path_items(path_id,exercise_id,sort_order) VALUES(?,?,?)');
            foreach ($ids as $order => $exerciseId) $add->execute([$pathId, $exerciseId, $order]);
            $pdo->commit();
            audit_log($pdo, (int)$user['id'], $action === 'create_path' ? 'learning_path_created' : 'learning_path_updated', 'learning_path', $pathId, ['item_count' => count($ids), 'published' => (bool)$published]);
            flash($action === 'create_path' ? 'Learning path created.' : 'Learning path updated.', 'success');
        } catch (Throwable $ex) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            flash('Could not save this learning path. Review the exercise selection and try again.', 'error');
        }
        teacher_paths_redirect($pathId);
    }
    if ($action === 'delete_path') {
        $pathId = max(0, (int)($_POST['path_id'] ?? 0));
        $stmt = $pdo->prepare('DELETE FROM learning_paths WHERE id=? AND teacher_id=?');
        $stmt->execute([$pathId, (int)$user['id']]);
        if ($stmt->rowCount()) {
            audit_log($pdo, (int)$user['id'], 'learning_path_deleted', 'learning_path', $pathId);
            flash('Learning path deleted. Exercises and official grades were not deleted.', 'success');
        } else flash('Learning path not found or not owned by you.', 'error');
        teacher_paths_redirect();
    }
}

$stmt = $pdo->prepare('SELECT * FROM learning_paths WHERE teacher_id=? ORDER BY updated_at DESC, id DESC');
$stmt->execute([(int)$user['id']]);
$paths = $stmt->fetchAll();
$stmt = $pdo->prepare("SELECT id,title,topic,difficulty,points,time_limit_seconds FROM exercises WHERE created_by=? AND is_published=1 ORDER BY topic,title");
$stmt->execute([(int)$user['id']]);
$publishedExercises = $stmt->fetchAll();
$itemsByPath = [];
if ($paths) {
    $pathIds = array_map(static fn($p) => (int)$p['id'], $paths);
    $ph = implode(',', array_fill(0, count($pathIds), '?'));
    $stmt = $pdo->prepare("SELECT lpi.path_id,lpi.exercise_id,lpi.sort_order,e.title,e.topic,e.difficulty FROM learning_path_items lpi JOIN exercises e ON e.id=lpi.exercise_id WHERE lpi.path_id IN ($ph) ORDER BY lpi.path_id,lpi.sort_order,lpi.id");
    $stmt->execute($pathIds);
    foreach ($stmt->fetchAll() as $item) $itemsByPath[(int)$item['path_id']][] = $item;
}
page_header('Learning path builder');
?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow">TEACHER STUDIO · CURRICULUM</p><h1>Learning path builder</h1><p class="muted">Sequence your published challenges into a guided progression, from fundamentals to harder skills. A path organizes exercises without changing their grading rules.</p></div><div class="page-hero-actions"><a class="button" href="#create-path">＋ Create learning path</a><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher.php#exercise-library">Exercise library ↗</a></div></section>
<section class="learning-path-guidance"><article class="panel"><span class="learning-step-icon">01</span><div><strong>Build a sequence</strong><p>Choose published exercises you own. Their displayed order becomes the path order.</p></div></article><article class="panel"><span class="learning-step-icon">02</span><div><strong>Publish when ready</strong><p>Draft paths remain teacher-only. Published paths appear in Student Learning Paths.</p></div></article><article class="panel"><span class="learning-step-icon">03</span><div><strong>Sequential progression</strong><p>Students unlock one step at a time. Programming steps require a perfect score across public and hidden tests; HTML/CSS preview projects are marked complete manually.</p></div></article></section>
<section class="panel learning-path-form-panel" id="create-path"><div class="section-title"><div><h2>Create a learning path</h2><p class="muted">Example: Programming Fundamentals → Conditionals → Loops.</p></div></div>
<?php if (!$publishedExercises): ?><div class="empty compact-empty"><h3>Publish an exercise first</h3><p>Learning paths use your published exercises. Create and publish a challenge in the Content Library, then return here.</p><a class="button" href="<?= e($config['base_url']) ?>/teacher.php#challenge-builder">Create exercise</a></div><?php else: ?>
<form method="post" class="v14-path-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="create_path"><label>Path title<input name="title" maxlength="180" required placeholder="e.g. Programming Fundamentals"></label><label>Description<textarea name="description" rows="3" maxlength="4000" placeholder="Explain what learners will practice in this sequence."></textarea></label><fieldset class="path-exercise-picker"><legend>Choose exercises and set their step numbers</legend><p class="field-hint">Check at least one exercise and set Step numbers to control the sequence. Duplicate step numbers are allowed and use list order as a tie-breaker.</p><div class="path-exercise-options"><?php foreach ($publishedExercises as $exerciseIndex=>$ex): ?><div class="path-exercise-option"><input id="create-path-exercise-<?= (int)$ex['id'] ?>" type="checkbox" name="exercise_ids[]" value="<?= (int)$ex['id'] ?>" aria-label="Include <?= e($ex['title']) ?> in learning path"><span><strong><label class="path-exercise-title" for="create-path-exercise-<?= (int)$ex['id'] ?>"><?= e($ex['title']) ?></label></strong><small><?= e($ex['topic'] ?? 'Fundamentals') ?> · <?= e($ex['difficulty']) ?> · <?= (int)$ex['points'] ?> pts</small></span><label class="path-order-control">Step <input type="number" name="exercise_order[<?= (int)$ex['id'] ?>]" min="1" max="500" value="<?= $exerciseIndex+1 ?>" aria-label="Step order for <?= e($ex['title']) ?>"></label><span class="path-option-time"><?= (int)ceil((int)$ex['time_limit_seconds']/60) ?> min</span></div><?php endforeach; ?></div></fieldset><label class="builder-option-row"><input type="checkbox" name="publish" value="1"><span><strong>Publish this learning path</strong><small>Students can see the path, its description, and available steps.</small></span></label><div class="v14-form-actions"><button class="button" type="submit">Create path →</button><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher.php">Back to Studio</a></div></form><?php endif; ?></section>
<section class="v14-path-list-section"><div class="section-title"><div><h2>Your learning paths</h2><p class="muted">Edit the sequence or keep a path as a private draft until it is ready.</p></div><span class="pill"><?= count($paths) ?> paths</span></div>
<?php if (!$paths): ?><div class="empty"><div class="empty-symbol">↗</div><h3>No learning paths yet</h3><p>Create a path with a title, a description, and at least one published exercise.</p></div><?php else: ?><div class="v14-path-admin-list"><?php foreach ($paths as $path): $pathId=(int)$path['id']; $pathItems=$itemsByPath[$pathId] ?? []; ?>
<article class="panel v14-path-admin-card" id="path-<?= $pathId ?>"><div class="v14-path-admin-header"><div><span class="state-pill <?= (int)$path['is_published']?'published':'draft' ?>"><?= (int)$path['is_published']?'Published':'Draft' ?></span><h3><?= e($path['title']) ?></h3><p><a class="button small secondary" href="<?= e($config['base_url']) ?>/teacher-lessons.php?path_id=<?= (int)$pathId ?>">Manage lessons ↗</a></p><p class="muted"><?= e($path['description'] ?: 'No description added.') ?></p></div><span class="pill"><?= count($pathItems) ?> steps</span></div><div class="v14-path-step-preview"><?php foreach ($pathItems as $index=>$item): ?><span><b><?= $index+1 ?></b><?= e($item['title']) ?></span><?php endforeach; ?></div>
<details class="v14-path-edit"><summary>Edit path and sequence</summary><form method="post" class="v14-path-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="update_path"><input type="hidden" name="path_id" value="<?= $pathId ?>"><label>Path title<input name="title" required maxlength="180" value="<?= e($path['title']) ?>"></label><label>Description<textarea name="description" rows="3" maxlength="4000"><?= e($path['description'] ?? '') ?></textarea></label><fieldset class="path-exercise-picker"><legend>Exercises included</legend><div class="path-exercise-options"><?php $selectedIds=array_map(static fn($i)=>(int)$i['exercise_id'],$pathItems); $orderMap=[]; foreach($pathItems as $pi=>$itemRow) $orderMap[(int)$itemRow['exercise_id']]=$pi+1; foreach ($publishedExercises as $exerciseIndex=>$ex): ?><div class="path-exercise-option"><input id="edit-path-exercise-<?= (int)$ex['id'] ?>" type="checkbox" name="exercise_ids[]" value="<?= (int)$ex['id'] ?>" <?= in_array((int)$ex['id'],$selectedIds,true)?'checked':'' ?> aria-label="Include <?= e($ex['title']) ?> in learning path"><span><strong><label class="path-exercise-title" for="edit-path-exercise-<?= (int)$ex['id'] ?>"><?= e($ex['title']) ?></label></strong><small><?= e($ex['topic'] ?? 'Fundamentals') ?> · <?= e($ex['difficulty']) ?></small></span><label class="path-order-control">Step <input type="number" name="exercise_order[<?= (int)$ex['id'] ?>]" min="1" max="500" value="<?= (int)($orderMap[(int)$ex['id']] ?? ($exerciseIndex+1)) ?>" aria-label="Step order for <?= e($ex['title']) ?>"></label><span class="path-option-time"><?= (int)ceil((int)$ex['time_limit_seconds']/60) ?> min</span></div><?php endforeach; ?></div></fieldset><label class="builder-option-row"><input type="checkbox" name="publish" value="1" <?= (int)$path['is_published']?'checked':'' ?>><span><strong>Published</strong><small>Uncheck to hide this path from students.</small></span></label><div class="v14-form-actions"><button class="button small" type="submit">Save path</button></div></form></details>
<form method="post" class="v14-path-delete" onsubmit="return confirm('Delete this learning path? Its exercises, submissions, and grades will remain unchanged.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_path"><input type="hidden" name="path_id" value="<?= $pathId ?>"><button class="button danger small" type="submit">Delete path</button></form></article><?php endforeach; ?></div><?php endif; ?></section>
<?php page_footer(); ?>
