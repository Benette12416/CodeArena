<?php
require_once __DIR__ . '/../../app/bootstrap.php';
require_once __DIR__ . '/../../app/super_admin_layout.php';
require_role(['super_admin']);
$counts = [
    'students' => (int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='student'")->fetchColumn(),
    'teachers' => (int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='teacher'")->fetchColumn(),
    'exercises' => (int)$pdo->query('SELECT COUNT(*) FROM exercises')->fetchColumn(),
    'submissions' => (int)$pdo->query('SELECT COUNT(*) FROM submissions')->fetchColumn(),
];
$latestUsers = $pdo->query('SELECT name,email,role,created_at FROM users ORDER BY created_at DESC LIMIT 7')->fetchAll();
$latestExercises = $pdo->query('SELECT e.title,e.difficulty,e.is_published,e.created_at,u.name AS creator FROM exercises e JOIN users u ON u.id=e.created_by ORDER BY e.created_at DESC LIMIT 5')->fetchAll();
admin_header('Overview', 'overview');
?>
<section class="admin-welcome"><div><p class="admin-kicker">PLATFORM OVERVIEW</p><h2>Good to have you here, <?= e(explode(' ', (string)current_user()['name'])[0]) ?>.</h2><p>Here’s the latest pulse of your programming learning platform.</p></div><a class="welcome-badge" href="<?= e($config['base_url']) ?>/super-admin/system-health.php" style="text-decoration:none"><span class="welcome-badge-icon">✓</span><div><strong>System health</strong><small>Run diagnostics and checks ↗</small></div></a></section>
<section class="stat-grid">
<div class="stat-card"><div class="stat-top"><span>Students</span><span class="stat-symbol student-symbol">♙</span></div><strong><?= number_format($counts['students']) ?></strong><small>Registered learners</small><span class="stat-accent student-accent"></span></div>
<div class="stat-card"><div class="stat-top"><span>Teachers</span><span class="stat-symbol teacher-symbol">⌘</span></div><strong><?= number_format($counts['teachers']) ?></strong><small>Staff accounts</small><a class="stat-link" href="<?= e($config['base_url']) ?>/super-admin/teachers.php">Manage teachers ↗</a><span class="stat-accent teacher-accent"></span></div>
<div class="stat-card"><div class="stat-top"><span>Exercises</span><span class="stat-symbol exercise-symbol">&lt;/&gt;</span></div><strong><?= number_format($counts['exercises']) ?></strong><small>Created challenges</small><span class="stat-accent exercise-accent"></span></div>
<div class="stat-card"><div class="stat-top"><span>Submissions</span><span class="stat-symbol submission-symbol">↗</span></div><strong><?= number_format($counts['submissions']) ?></strong><small>Code attempts recorded</small><span class="stat-accent submission-accent"></span></div>
</section>
<section class="admin-two-col"><div class="admin-panel"><div class="admin-panel-head"><div><h3>Recent accounts</h3><p>Latest users added to CodeArena</p></div><a class="admin-text-link" href="<?= e($config['base_url']) ?>/super-admin/users.php">View all ↗</a></div><div class="admin-table-wrap"><table class="admin-table"><thead><tr><th>Account</th><th>Role</th><th>Joined</th></tr></thead><tbody>
<?php foreach ($latestUsers as $row): ?><tr><td><div class="account-cell"><span class="mini-avatar <?= e($row['role']) ?>"><?= e(strtoupper(mb_substr((string)$row['name'], 0, 1))) ?></span><div><strong><?= e($row['name']) ?></strong><small><?= e($row['email']) ?></small></div></div></td><td><span class="role-pill <?= e($row['role']) ?>"><?= e(str_replace('_', ' ', $row['role'] === 'super_admin' ? 'super admin' : $row['role'])) ?></span></td><td><?= e(date('M j, Y', strtotime($row['created_at']))) ?></td></tr><?php endforeach; ?>
<?php if (!$latestUsers): ?><tr><td colspan="3" class="admin-empty">No accounts yet.</td></tr><?php endif; ?></tbody></table></div></div>
<div class="admin-panel"><div class="admin-panel-head"><div><h3>Latest exercises</h3><p>Content created by your teachers</p></div></div><div class="exercise-list">
<?php foreach ($latestExercises as $row): ?><div class="admin-exercise-row"><span class="exercise-glyph">&lt;/&gt;</span><div class="admin-exercise-info"><strong><?= e($row['title']) ?></strong><small><?= e($row['difficulty']) ?> · by <?= e($row['creator']) ?></small></div><span class="publish-status <?= $row['is_published'] ? 'published' : 'draft' ?>"><?= $row['is_published'] ? 'Published' : 'Draft' ?></span></div><?php endforeach; ?>
<?php if (!$latestExercises): ?><div class="admin-empty">No exercises have been created yet.</div><?php endif; ?></div><div class="admin-callout"><span>✦</span><div><strong>Keep the arena growing</strong><p>Create teacher accounts so educators can publish new challenges for students.</p><a href="<?= e($config['base_url']) ?>/super-admin/teachers.php">Set up a teacher account →</a></div></div></div></section>
<?php admin_footer(); ?>
