<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
if (current_user()) redirect_to_user_home();
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $name = trim((string)($_POST['name'] ?? ''));
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    $password = (string)($_POST['password'] ?? '');
    if (mb_strlen($name) < 2 || mb_strlen($name) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 8) {
        $error = 'Enter a valid name and email. Your password must be at least 8 characters.';
    } else {
        try {
            $stmt = $pdo->prepare("INSERT INTO users(name,email,password_hash,role) VALUES(?,?,?,'student')");
            $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
            audit_log($pdo, (int)$pdo->lastInsertId(), 'student_registered', 'account', null);
            flash('Student account created. Sign in to enter the arena.', 'success');
            redirect('login.php');
        } catch (PDOException $ex) {
            $error = 'That email may already be registered. Try signing in instead.';
        }
    }
}
page_header('Create student account');
?>
<div class="auth-wrap"><form class="panel auth" method="post" autocomplete="on"><div class="panel-icon">✦</div><p class="eyebrow">CREATE YOUR STUDENT ACCOUNT</p><h1>Join the arena.</h1><p class="muted">Start solving problems and track your progress.</p>
<?php if ($error): ?><div class="alert error" role="alert"><?= e($error) ?></div><?php endif; ?>
<input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
<label>Full name<input name="name" autocomplete="name" required maxlength="100" value="<?= e($_POST['name'] ?? '') ?>" placeholder="Your full name"></label>
<label>Email address<input type="email" name="email" autocomplete="email" required value="<?= e($_POST['email'] ?? '') ?>" placeholder="you@example.com"></label>
<label>Password<input type="password" name="password" autocomplete="new-password" minlength="8" required placeholder="At least 8 characters"><small class="field-hint">Use at least 8 characters.</small></label>
<button class="button full" type="submit">Create student account <span aria-hidden="true">→</span></button><p class="muted center">Already have an account? <a href="<?= e($config['base_url']) ?>/login.php">Sign in</a></p>
<p class="muted center staff-signup-note">Are you a teacher? <a href="<?= e($config['base_url']) ?>/teacher-login.php">Use the teacher portal</a>. Teacher accounts are created by a Super Admin.</p></form></div>
<?php page_footer(); ?>
