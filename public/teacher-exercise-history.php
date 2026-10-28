<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$exerciseId = max(0, (int)($_GET['exercise_id'] ?? 0));
$exerciseStmt = $pdo->prepare('SELECT id,title,points,time_limit_seconds FROM exercises WHERE id=? AND created_by=?');
$exerciseStmt->execute([$exerciseId,(int)$user['id']]);
$exercise = $exerciseStmt->fetch();
if (!$exercise) { http_response_code(404); exit('Exercise not found.'); }
$versionsStmt = $pdo->prepare('SELECT id,version_number,change_reason,created_at FROM exercise_versions WHERE exercise_id=? AND created_by=? ORDER BY version_number DESC');
$versionsStmt->execute([$exerciseId,(int)$user['id']]); $versions = $versionsStmt->fetchAll();
page_header('Exercise version history');
?>
<section class="page-hero compact-page-hero v15-history-hero"><div><p class="eyebrow">TEACHER STUDIO · CONTENT SAFETY</p><h1>Exercise version history</h1><p class="muted">Restore an earlier version if a correction caused a problem. Attempts already started remain tied to the snapshot they began with.</p><div class="v15-history-title"><strong><?= e($exercise['title']) ?></strong><span class="pill"><?= (int)$exercise['points'] ?> points · <?= max(1,(int)ceil((int)$exercise['time_limit_seconds']/60)) ?> min</span></div></div><div class="page-hero-actions"><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher.php#exercise-<?= $exerciseId ?>">Back to exercise</a></div></section>
<section class="panel v15-version-list"><div class="section-title"><div><h2>Saved versions</h2><p class="muted">Snapshots include the problem details, starter code, settings, and all test cases.</p></div><span class="pill"><?= count($versions) ?> versions</span></div>
<?php if (!$versions): ?><div class="empty compact-empty"><h3>No versions saved yet</h3><p>The next save to this exercise will create a version snapshot.</p></div><?php else: ?><div class="v15-version-timeline"><?php foreach ($versions as $index=>$version): $isLatest = $index === 0; ?><article class="v15-version-card"><div class="v15-version-icon"><?= $isLatest ? '✓' : (int)$version['version_number'] ?></div><div class="v15-version-body"><div class="v15-version-head"><div><strong>Version <?= (int)$version['version_number'] ?><?= $isLatest ? ' · Current' : '' ?></strong><p class="muted"><?= e($version['change_reason']) ?></p></div><time><?= e(date('M j, Y · g:i A',strtotime((string)$version['created_at']))) ?></time></div><?php if (!$isLatest): ?><form method="post" action="<?= e($config['base_url']) ?>/teacher.php" onsubmit="return confirm('Restore version <?= (int)$version['version_number'] ?>? Current details and test cases will be replaced. Existing student attempts will keep their saved version.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="restore_exercise_version"><input type="hidden" name="exercise_id" value="<?= $exerciseId ?>"><input type="hidden" name="version_id" value="<?= (int)$version['id'] ?>"><button class="button secondary small" type="submit">Restore this version</button></form><?php else: ?><span class="v15-current-version-label">Latest saved snapshot</span><?php endif; ?></div></article><?php endforeach; ?></div><?php endif; ?></section>
<?php page_footer(); ?>
