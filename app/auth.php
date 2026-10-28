<?php
declare(strict_types=1);

/** Processes a portal-specific login POST and redirects on success. */
function handle_portal_login(PDO $pdo, array $allowedRoles, string $portalName): ?string {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') return null;

    verify_csrf();
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    $password = (string)($_POST['password'] ?? '');
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
        return 'Check your email and password, then try again.';
    }

    $rateKey = login_rate_limit_key($email);
    $wait = login_rate_limit_remaining($pdo, $rateKey);
    if ($wait > 0) {
        $minutes = max(1, (int)ceil($wait / 60));
        audit_log($pdo, null, 'login_rate_limited', 'portal', null, ['portal' => $portalName]);
        return 'Too many failed sign-in attempts. Try again in about ' . $minutes . ' minute' . ($minutes === 1 ? '' : 's') . '.';
    }

    $stmt = $pdo->prepare('SELECT id, name, email, password_hash, role, is_active FROM users WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    $account = $stmt->fetch();

    if (!$account || (int)($account['is_active'] ?? 1) !== 1 || !password_verify($password, $account['password_hash']) || !in_array($account['role'], $allowedRoles, true)) {
        record_login_failure($pdo, $rateKey);
        audit_log($pdo, null, 'login_failed', 'portal', null, ['portal' => $portalName]);
        return 'These credentials do not grant access to the ' . $portalName . ' portal.';
    }

    clear_login_rate_limit($pdo, $rateKey);
    session_regenerate_id(true);
    unset($account['password_hash']);
    $_SESSION['user'] = $account;
    $_SESSION['_csrf'] = bin2hex(random_bytes(32));
    audit_log($pdo, (int)$account['id'], 'login_succeeded', 'portal', (int)$account['id'], ['portal' => $portalName]);
    redirect(role_home_path((string)$account['role']));
}
