<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/auth.php';
require_once __DIR__ . '/../app/auth_layout.php';
if ((current_user()['role'] ?? null) === 'teacher') redirect('teacher.php');
$error = handle_portal_login($pdo, ['teacher'], 'teacher');
auth_header('Teacher sign in', 'teacher');
?>
<section class="auth-panel-wrap"><form class="auth-panel" method="post" autocomplete="on">
<div class="panel-icon teacher-icon">⌘</div><p class="eyebrow">TEACHER STUDIO</p><h2>Welcome, educator</h2><p class="form-subtitle">Sign in to create challenges and manage your programming exercises.</p>
<?php if ($error): ?><div class="alert error" role="alert"><?= e($error) ?></div><?php endif; ?>
<input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
<label for="email">Work email</label><input id="email" type="email" name="email" autocomplete="username" required value="<?= e($_POST['email'] ?? '') ?>" placeholder="teacher@school.edu">
<label for="password">Password</label><input id="password" type="password" name="password" autocomplete="current-password" required placeholder="Enter your password">
<button class="button full teacher-button" type="submit">Open Teacher Studio <span aria-hidden="true">→</span></button>
<div class="managed-account"><span class="managed-icon">♙</span><div><strong>Teacher accounts are managed by your Super Admin.</strong><p>There is no teacher sign-up form. Ask your administrator to create an account for you.</p></div></div>
<div class="auth-divider"><span>OTHER PORTALS</span></div><div class="portal-shortcuts"><a href="<?= e($config['base_url']) ?>/login.php">Student sign in <span>↗</span></a><a href="<?= e($config['base_url']) ?>/super-admin/login.php">Super Admin <span>↗</span></a></div>
</form><p class="secure-note"><span>⌑</span> Staff access is role-restricted.</p></section>
<?php auth_footer(); ?>
