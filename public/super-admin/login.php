<?php
require_once __DIR__ . '/../../app/bootstrap.php';
require_once __DIR__ . '/../../app/auth.php';
require_once __DIR__ . '/../../app/super_admin_layout.php';
if ((current_user()['role'] ?? null) === 'super_admin') redirect('super-admin/index.php');
$error = handle_portal_login($pdo, ['super_admin'], 'Super Admin');
admin_auth_header('Super Admin sign in');
?>
<section class="admin-login-wrap"><form method="post" class="admin-login-card" autocomplete="on">
<div class="admin-emblem">CA<span>✦</span></div><p class="admin-kicker">RESTRICTED ACCESS</p><h1>Super Admin</h1><p class="admin-login-copy">Sign in to manage CodeArena, teacher accounts, and platform activity.</p>
<?php if ($error): ?><div class="admin-alert error" role="alert"><?= e($error) ?></div><?php endif; ?>
<input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
<label for="email">Administrator email</label><input id="email" name="email" type="email" autocomplete="username" required value="<?= e($_POST['email'] ?? '') ?>" placeholder="admin@your-school.edu">
<label for="password">Password</label><input id="password" name="password" type="password" autocomplete="current-password" required placeholder="Enter admin password">
<button class="admin-button full" type="submit">Access control center <span aria-hidden="true">→</span></button>
<p class="admin-security-note"><span>◈</span> This portal is for authorized administrators only.</p>
</form><div class="admin-login-bottom"><a href="<?= e($config['base_url']) ?>/index.php">← Back to CodeArena</a><span>© <?= date('Y') ?> CodeArena</span></div></section>
<?php admin_auth_footer(); ?>
