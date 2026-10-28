<?php
function admin_auth_header(string $title): void {
    global $config;
    ?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="color-scheme" content="light"><meta name="theme-color" content="#f6f8fc"><title><?= e($title) ?> · CodeArena Control Center</title><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/admin.css"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v24-design-system.css?v=24.0"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v25-developer-contact.css?v=25.0"></head><body class="admin-login-page"><div class="admin-login-shell"><a class="admin-login-brand" href="<?= e($config['base_url']) ?>/index.php"><span class="admin-brand-mark">CA</span><span>CodeArena <small>CONTROL CENTER</small></span></a><?php
}
function admin_auth_footer(): void {
    ?><div class="admin-login-contact"><a href="https://github.com/Benette12416" target="_blank" rel="noopener noreferrer">Contact developer on GitHub ↗</a></div></div></body></html><?php
}
function admin_header(string $title, string $active = 'overview'): void {
    global $config;
    $user = current_user();
    $flash = consume_flash();
    $base = rtrim($config['base_url'], '/') . '/super-admin/';
    $nav = [
        'overview' => ['index.php', 'Overview', '⌂'],
        'teachers' => ['teachers.php', 'Teacher accounts', '♙'],
        'users' => ['users.php', 'Manage users', '☷'],
        'audit' => ['audit-log.php', 'Audit log', '◷'],
        'health' => ['system-health.php', 'System health', '✚'],
    ];
    ?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="color-scheme" content="light"><meta name="theme-color" content="#f6f8fc"><title><?= e($title) ?> · CodeArena Control Center</title><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/admin.css"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v14.css"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v16.css"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v24-design-system.css?v=24.0"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v25-developer-contact.css?v=25.0"></head><body class="admin-app"><div class="admin-shell">
    <aside class="admin-sidebar"><a class="admin-logo" href="<?= e($base) ?>index.php"><span class="admin-brand-mark">CA</span><span>CodeArena<small>CONTROL CENTER</small></span></a><div class="sidebar-label">WORKSPACE</div><nav class="admin-nav">
    <?php foreach ($nav as $key => $item): ?><a class="<?= $active === $key ? 'active' : '' ?>" href="<?= e($base . $item[0]) ?>"><span class="nav-icon"><?= e($item[2]) ?></span><?= e($item[1]) ?><?php if ($active === $key): ?><span class="nav-current"></span><?php endif; ?></a><?php endforeach; ?>
    </nav><div class="sidebar-spacer"></div><div class="sidebar-protected"><span class="protected-icon">◈</span><div><strong>Protected area</strong><small>Super Admin access only</small></div></div><a class="sidebar-exit" href="<?= e($config['base_url']) ?>/logout.php">↩ Sign out</a></aside>
    <div class="admin-main"><header class="admin-topbar"><div class="admin-top-title"><p>CODEARENA / CONTROL CENTER</p><h1><?= e($title) ?></h1></div><div class="admin-profile"><span class="admin-status-dot"></span><div><strong><?= e($user['name'] ?? 'Administrator') ?></strong><small>Super Administrator</small></div><span class="admin-avatar">A</span></div></header><main class="admin-content">
    <?php if ($flash): ?><div class="admin-alert <?= e($flash['type']) ?>"><?= e($flash['message']) ?></div><?php endif; ?>
    <?php
}
function admin_footer(): void {
    ?></main><footer class="admin-footer"><span>CodeArena Control Center</span><span>Administration, made clearer.</span><a href="https://github.com/Benette12416" target="_blank" rel="noopener noreferrer">Contact developer ↗</a><span>© <?= date('Y') ?></span></footer></div></div></body></html><?php
}
