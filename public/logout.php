<?php
require_once __DIR__ . '/../app/bootstrap.php';
$user = current_user();
$loginPath = $user ? role_login_path((string)$user['role']) : 'login.php';
if ($user) audit_log($pdo, (int)$user['id'], 'logout_succeeded', 'portal', (int)$user['id'], ['portal'=>(string)$user['role']]);
$_SESSION = [];
if (ini_get('session.use_cookies')) {
    $p = session_get_cookie_params();
    setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
}
session_destroy();
redirect($loginPath);
