<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/auth.php';
require_once __DIR__ . '/../app/auth_layout.php';
if ((current_user()['role'] ?? null) === 'student') redirect('index.php');
$error = handle_portal_login($pdo, ['student'], 'student');
auth_header('Student sign in', 'student');
?>
<section class="auth-panel-wrap"><form class="auth-panel" method="post" autocomplete="on">
<div class="panel-icon">↗</div><p class="eyebrow">STUDENT ACCESS</p><h2>Welcome back</h2><p class="form-subtitle">Pick up where you left off.</p>
<?php if ($error): ?><div class="alert error" role="alert"><?= e($error) ?></div><?php endif; ?>
<input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
<label for="email">Email address</label><input id="email" type="email" name="email" autocomplete="username" required value="<?= e($_POST['email'] ?? '') ?>" placeholder="you@example.com">
<label for="password">Password</label><input id="password" type="password" name="password" autocomplete="current-password" required placeholder="Enter your password">
<button class="button full" type="submit">Sign in to CodeArena <span aria-hidden="true">→</span></button>
<p class="auth-switch">New to the arena? <a href="<?= e($config['base_url']) ?>/register.php">Create a student account</a></p>
<div class="auth-divider"><span>STAFF ACCESS</span></div><div class="portal-shortcuts"><a href="<?= e($config['base_url']) ?>/teacher-login.php">Teacher sign in <span>↗</span></a><a href="<?= e($config['base_url']) ?>/super-admin/login.php">Super Admin <span>↗</span></a></div>
</form><p class="secure-note"><span>⌑</span> Your account is protected with secure password hashing.</p></section>
<?php auth_footer(); ?>
