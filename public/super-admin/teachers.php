<?php
require_once __DIR__ . '/../../app/bootstrap.php';
require_once __DIR__ . '/../../app/super_admin_layout.php';
require_role(['super_admin']);
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $name = trim((string)($_POST['name'] ?? ''));
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    $password = (string)($_POST['password'] ?? '');
    if (mb_strlen($name) < 2 || mb_strlen($name) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 10) {
        $error = 'Enter a valid name and email. The initial password must be at least 10 characters.';
    } else {
        try {
            $stmt = $pdo->prepare("INSERT INTO users(name,email,password_hash,role) VALUES(?,?,?,'teacher')");
            $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
            audit_log($pdo, (int)current_user()['id'], 'teacher_account_created', 'user', (int)$pdo->lastInsertId());
            flash('Teacher account created. Share the sign-in details with the teacher securely.', 'success');
            redirect('super-admin/teachers.php');
        } catch (PDOException $ex) {
            $error = 'That email is already in use. Each account needs a unique email address.';
        }
    }
}
$teachers = $pdo->query("SELECT u.id,u.name,u.email,u.created_at,COUNT(e.id) AS exercise_count FROM users u LEFT JOIN exercises e ON e.created_by=u.id WHERE u.role='teacher' GROUP BY u.id,u.name,u.email,u.created_at ORDER BY u.created_at DESC")->fetchAll();
admin_header('Teacher accounts', 'teachers');
?>
<div class="admin-page-intro"><div><p class="admin-kicker">STAFF DIRECTORY</p><h2>Teacher accounts</h2><p>Create staff accounts and give educators access to the Teacher Studio. Teachers cannot create their own accounts.</p></div><span class="directory-count"><?= count($teachers) ?> teacher<?= count($teachers) === 1 ? '' : 's' ?></span></div>
<div class="admin-two-col teacher-admin-layout"><section class="admin-panel create-teacher-panel"><div class="admin-panel-head"><div><h3>Create a teacher</h3><p>Set up secure sign-in credentials.</p></div><span class="admin-panel-icon">＋</span></div>
<?php if ($error): ?><div class="admin-alert error" role="alert"><?= e($error) ?></div><?php endif; ?>
<form method="post" class="admin-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><label for="teacher-name">Full name</label><input id="teacher-name" name="name" maxlength="100" required value="<?= e($_POST['name'] ?? '') ?>" placeholder="e.g. Alex Rivera"><label for="teacher-email">Email address</label><input id="teacher-email" name="email" type="email" required value="<?= e($_POST['email'] ?? '') ?>" placeholder="alex@school.edu"><label for="teacher-password">Initial password</label><input id="teacher-password" name="password" type="password" minlength="10" required placeholder="At least 10 characters"><p class="admin-field-hint">Use a strong temporary password and share it privately. The teacher can sign in at the Teacher Portal.</p><button class="admin-button full" type="submit">Create teacher account <span>→</span></button></form>
<div class="admin-security-box"><span>◈</span><p><strong>Role-protected</strong><br>Teacher accounts are created here only. The public registration page always creates student accounts.</p></div></section>
<section class="admin-panel teacher-directory"><div class="admin-panel-head"><div><h3>Teacher directory</h3><p>Accounts with access to Teacher Studio</p></div></div><div class="teacher-list">
<?php foreach ($teachers as $teacher): ?><div class="teacher-row"><span class="teacher-avatar-large"><?= e(strtoupper(mb_substr((string)$teacher['name'], 0, 1))) ?></span><div class="teacher-row-info"><strong><?= e($teacher['name']) ?></strong><small><?= e($teacher['email']) ?></small><div class="teacher-meta"><?= (int)$teacher['exercise_count'] ?> exercise<?= (int)$teacher['exercise_count'] === 1 ? '' : 's' ?> · Joined <?= e(date('M j, Y', strtotime($teacher['created_at']))) ?></div></div><span class="staff-state"><i></i> Active</span></div><?php endforeach; ?>
<?php if (!$teachers): ?><div class="admin-empty spacious"><span>♙</span><strong>No teacher accounts yet</strong><p>Create the first teacher account using the form.</p></div><?php endif; ?></div></section></div>
<?php admin_footer(); ?>
