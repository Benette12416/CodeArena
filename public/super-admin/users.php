<?php
require_once __DIR__ . '/../../app/bootstrap.php';
require_once __DIR__ . '/../../app/super_admin_layout.php';
require_role(['super_admin']);
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $id = (int)($_POST['user_id'] ?? 0);
    $action = (string)($_POST['action'] ?? 'change_role');
    if ($action === 'toggle_account_status') {
        $find = $pdo->prepare('SELECT id,role,name,is_active FROM users WHERE id=?');
        $find->execute([$id]); $target = $find->fetch();
        if (!$target || !in_array($target['role'], ['student','teacher'], true)) {
            flash('Only student and teacher accounts can be activated or deactivated here.', 'error');
        } else {
            $newStatus = (int)$target['is_active'] === 1 ? 0 : 1;
            $update = $pdo->prepare('UPDATE users SET is_active=? WHERE id=?');
            $update->execute([$newStatus, $id]);
            audit_log($pdo, (int)current_user()['id'], $newStatus ? 'account_activated' : 'account_deactivated', 'user', $id, ['target_role'=>$target['role']]);
            flash($newStatus ? 'Account activated.' : 'Account deactivated. The user will be denied access at the next request.', 'success');
        }
        redirect('super-admin/users.php' . ($filterParam = isset($_GET['role']) ? '?role='.rawurlencode((string)$_GET['role']) : ''));
    }
    if ($action === 'reset_password') {
        $temporaryPassword = (string)($_POST['temporary_password'] ?? '');
        $find = $pdo->prepare('SELECT id,role,name FROM users WHERE id=?');
        $find->execute([$id]); $target = $find->fetch();
        if (!$target || !in_array($target['role'], ['student','teacher'], true)) {
            flash('Only student and teacher passwords can be reset from this screen.', 'error');
        } elseif (strlen($temporaryPassword) < 12 || strlen($temporaryPassword) > 200) {
            flash('Temporary passwords must be at least 12 characters.', 'error');
        } else {
            $update = $pdo->prepare('UPDATE users SET password_hash=? WHERE id=?');
            $update->execute([password_hash($temporaryPassword, PASSWORD_DEFAULT), $id]);
            audit_log($pdo, (int)current_user()['id'], 'admin_password_reset', 'user', $id, ['target_role'=>$target['role']]);
            flash('Password reset for '. $target['name'] .'. Share the new temporary password securely and ask the account holder to change it using your school’s approved process.', 'success');
        }
        redirect('super-admin/users.php' . (isset($_GET['role']) ? '?role='.rawurlencode((string)$_GET['role']) : ''));
    }
    $newRole = (string)($_POST['role'] ?? '');
    if ($id < 1 || !in_array($newRole, ['student', 'teacher'], true)) {
        flash('Choose a valid account role.', 'error');
    } else {
        $find = $pdo->prepare('SELECT id,role FROM users WHERE id=?');
        $find->execute([$id]);
        $target = $find->fetch();
        if (!$target || in_array($target['role'], ['super_admin', 'admin'], true)) {
            flash('Super Admin accounts cannot be changed from this screen.', 'error');
        } else {
            $update = $pdo->prepare('UPDATE users SET role=? WHERE id=?');
            $update->execute([$newRole, $id]);
            audit_log($pdo, (int)current_user()['id'], 'account_role_changed', 'user', $id, ['new_role'=>$newRole]);
            flash('Account role updated.', 'success');
        }
    }
    redirect('super-admin/users.php');
}
$filter = (string)($_GET['role'] ?? 'all');
$allowedFilters = ['all', 'student', 'teacher', 'super_admin'];
if (!in_array($filter, $allowedFilters, true)) $filter = 'all';
if ($filter === 'all') {
    $stmt = $pdo->query('SELECT id,name,email,role,is_active,created_at FROM users ORDER BY created_at DESC LIMIT 250');
} else {
    $stmt = $pdo->prepare('SELECT id,name,email,role,is_active,created_at FROM users WHERE role=? ORDER BY created_at DESC LIMIT 250');
    $stmt->execute([$filter]);
}
$users = $stmt->fetchAll();
admin_header('Manage users', 'users');
?>
<div class="admin-page-intro"><div><p class="admin-kicker">ACCOUNT DIRECTORY</p><h2>Manage users</h2><p>Review registered accounts and maintain student or teacher access. Super Admin privileges are protected separately.</p></div></div>
<section class="admin-panel users-panel"><div class="admin-panel-head"><div><h3>All accounts</h3><p>Showing up to 250 most recently created accounts.</p></div><form class="filter-form" method="get"><label for="role-filter">Filter</label><select id="role-filter" name="role" onchange="this.form.submit()"><option value="all" <?= $filter==='all'?'selected':'' ?>>All roles</option><option value="student" <?= $filter==='student'?'selected':'' ?>>Students</option><option value="teacher" <?= $filter==='teacher'?'selected':'' ?>>Teachers</option><option value="super_admin" <?= $filter==='super_admin'?'selected':'' ?>>Super Admins</option></select></form></div>
<div class="admin-table-wrap"><table class="admin-table users-table"><thead><tr><th>Account</th><th>Current role</th><th>Created</th><th>Access role</th><th>Account status</th><th>Password access</th></tr></thead><tbody>
<?php foreach ($users as $account): ?><tr><td><div class="account-cell"><span class="mini-avatar <?= e($account['role']) ?>"><?= e(strtoupper(mb_substr((string)$account['name'], 0, 1))) ?></span><div><strong><?= e($account['name']) ?></strong><small><?= e($account['email']) ?></small></div></div></td><td><span class="role-pill <?= e($account['role']) ?>"><?= e(str_replace('_', ' ', $account['role'])) ?></span></td><td><?= e(date('M j, Y', strtotime($account['created_at']))) ?></td><td><?php if ($account['role'] !== 'super_admin' && $account['role'] !== 'admin'): ?><form class="role-change-form" method="post"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="user_id" value="<?= (int)$account['id'] ?>"><input type="hidden" name="action" value="change_role"><select name="role" aria-label="Role for <?= e($account['name']) ?>"><option value="student" <?= $account['role']==='student'?'selected':'' ?>>Student</option><option value="teacher" <?= $account['role']==='teacher'?'selected':'' ?>>Teacher</option></select><button type="submit" class="mini-admin-button">Save</button></form><?php else: ?><span class="protected-role">Protected</span><?php endif; ?></td><td><?php if (in_array($account['role'], ['student','teacher'], true)): ?><div class="v23-account-status-cell"><span class="classroom-state <?= (int)$account['is_active']===1?'active':'inactive' ?>"><?= (int)$account['is_active']===1?'Active':'Deactivated' ?></span><form method="post" onsubmit="return confirm('<?= (int)$account['is_active']===1?'Deactivate':'Activate' ?> this account?');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="user_id" value="<?= (int)$account['id'] ?>"><input type="hidden" name="action" value="toggle_account_status"><button type="submit" class="mini-admin-button"><?= (int)$account['is_active']===1?'Deactivate':'Activate' ?></button></form></div><?php else: ?><span class="protected-role">Protected</span><?php endif; ?></td><td><?php if (in_array($account['role'], ['student','teacher'], true)): ?><details class="admin-reset-password"><summary>Reset password</summary><form method="post"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="user_id" value="<?= (int)$account['id'] ?>"><input type="hidden" name="action" value="reset_password"><label>Temporary password<input type="password" name="temporary_password" minlength="12" maxlength="200" required autocomplete="new-password" placeholder="At least 12 characters"></label><button type="submit" class="mini-admin-button" onclick="return confirm('Reset this account password? The account holder will need the new temporary password.');">Set password</button></form></details><?php else: ?><span class="protected-role">Protected</span><?php endif; ?></td></tr><?php endforeach; ?>
<?php if (!$users): ?><tr><td colspan="6" class="admin-empty">No accounts match this filter.</td></tr><?php endif; ?></tbody></table></div><p class="admin-table-note">Changing a student to teacher grants access to Teacher Studio. It does not grant Super Admin access. Admin-assisted password resets are audited; deliver temporary credentials privately and do not send them in public channels.</p></section>
<?php admin_footer(); ?>
