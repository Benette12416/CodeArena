<?php
function page_header(string $title): void {
    global $config;
    $user = current_user();
    $flash = consume_flash();
    $currentScript = str_replace('\\', '/', (string)($_SERVER['SCRIPT_NAME'] ?? ''));
    $currentPage = basename($currentScript);
    $isCurrentRoute = static function (string $suffix) use ($currentScript): bool { return str_ends_with($currentScript, $suffix); };
    $base = rtrim((string)$config['base_url'], '/');
    $isActive = static function (array $pages) use ($currentPage): string {
        return in_array($currentPage, $pages, true) ? ' is-active' : '';
    };
    $ariaCurrent = static function (array $pages) use ($currentPage): string {
        return in_array($currentPage, $pages, true) ? ' aria-current="page"' : '';
    };
    $studentLearnPages = ['student-learning-paths.php','student-lessons.php','student-lesson.php'];
    $teacherToolPages = ['teacher-analytics.php', 'teacher-learning-paths.php', 'teacher-monitoring.php','teacher-lessons.php'];
    $adminManagePages = ['teachers.php', 'users.php', 'audit-log.php'];
    ?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light"><meta name="theme-color" content="#f6f8fc"><meta name="description" content="CodeArena programming practice, classrooms, assignments and coding assessments."><title><?= e($title) ?> · <?= e($config['app_name']) ?></title>
    <?php if (!empty($GLOBALS['load_codemirror'])): ?><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.css"><?php endif; ?>
    <link rel="stylesheet" href="<?= e($base) ?>/assets/style.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v14.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v15.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v16.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v17.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v19-dashboard.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v20-practice-arena.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v22-learning-paths.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v23-learning-priority.css"><link rel="stylesheet" href="<?= e($base) ?>/assets/v24-design-system.css?v=24.0"><link rel="stylesheet" href="<?= e($base) ?>/assets/v25-developer-contact.css?v=25.0"></head><body>
    <a class="skip-link" href="#main-content">Skip to content</a>
    <nav class="nav ca-nav ca-nav-v16" aria-label="Main navigation">
      <a class="brand" href="<?= e($base) ?>/index.php" aria-label="CodeArena home"><span class="brand-mark">&lt;/&gt;</span><span class="brand-wordmark">CodeArena<small><?= $user ? e(ucwords(str_replace('_', ' ', (string)$user['role']))) : 'LEARN · BUILD · IMPROVE' ?></small></span></a>
      <button class="nav-menu-toggle" type="button" aria-label="Open navigation menu" aria-expanded="false" aria-controls="primaryNavLinks"><span></span><span></span><span></span></button>
      <div class="navlinks ca-navlinks" id="primaryNavLinks">
      <?php if ($user && $user['role'] === 'student'): ?>
        <a class="<?= trim($isActive(['index.php'])) ?>" href="<?= e($base) ?>/index.php"<?= $ariaCurrent(['index.php']) ?>>Home</a>
        <a class="nav-practice-arena" href="<?= e($base) ?>/index.php#practice" aria-label="Open Practice Arena"><span class="nav-practice-arena-icon" aria-hidden="true">&lt;/&gt;</span><span>Practice Arena</span><span class="nav-practice-arena-arrow" aria-hidden="true">↗</span></a>
        <a class="<?= trim($isActive(['student-classrooms.php','student-classroom.php'])) ?>" href="<?= e($base) ?>/student-classrooms.php"<?= $ariaCurrent(['student-classrooms.php','student-classroom.php']) ?>>My classes</a>
        <a class="<?= trim($isActive(['student-learning-paths.php'])) ?>" href="<?= e($base) ?>/student-learning-paths.php"<?= $ariaCurrent(['student-learning-paths.php']) ?>>Learning paths</a>
        <a class="<?= trim($isActive(['student-progress.php'])) ?>" href="<?= e($base) ?>/student-progress.php"<?= $ariaCurrent(['student-progress.php']) ?>>My progress</a>
        <a class="<?= trim($isActive(['leaderboard.php'])) ?>" href="<?= e($base) ?>/leaderboard.php"<?= $ariaCurrent(['leaderboard.php']) ?>>Leaderboard</a>
        <details class="nav-dropdown<?= in_array($currentPage, ['student-lessons.php','student-lesson.php','student-submissions.php','student-achievements.php'], true) ? ' is-active' : '' ?>">
          <summary>More <span class="nav-chevron" aria-hidden="true">⌄</span></summary>
          <div class="nav-dropdown-menu">
            <a class="<?= trim($isActive(['student-lessons.php','student-lesson.php'])) ?>" href="<?= e($base) ?>/student-lessons.php">Lessons</a>
            <a class="<?= trim($isActive(['student-submissions.php'])) ?>" href="<?= e($base) ?>/student-submissions.php">Submission history</a>
            <a class="<?= trim($isActive(['student-achievements.php'])) ?>" href="<?= e($base) ?>/student-achievements.php">Achievements</a>
          </div>
        </details>
        <span class="nav-account"><span class="avatar"><?= e(strtoupper(mb_substr((string)$user['name'], 0, 1))) ?></span><span class="nav-account-copy"><strong><?= e($user['name']) ?></strong><small>Student account</small></span></span>
        <a class="nav-signout" href="<?= e($base) ?>/logout.php">Sign out</a>
      <?php elseif ($user && $user['role'] === 'teacher'): ?>
        <a class="<?= trim($isActive(['teacher.php'])) ?>" href="<?= e($base) ?>/teacher.php"<?= $ariaCurrent(['teacher.php']) ?>>Studio</a>
        <a class="<?= trim($isActive(['teacher-classrooms.php','teacher-classroom.php'])) ?>" href="<?= e($base) ?>/teacher-classrooms.php"<?= $ariaCurrent(['teacher-classrooms.php','teacher-classroom.php']) ?>>Classrooms</a>
        <a class="<?= trim($isActive(['teacher-gradebook.php'])) ?>" href="<?= e($base) ?>/teacher-gradebook.php"<?= $ariaCurrent(['teacher-gradebook.php']) ?>>Gradebook</a>
        <a class="<?= trim($isActive(['teacher-submission.php'])) ?>" href="<?= e($base) ?>/teacher-submission.php"<?= $ariaCurrent(['teacher-submission.php']) ?>>Submissions</a>
        <details class="nav-dropdown<?= in_array($currentPage, $teacherToolPages, true) ? ' is-active' : '' ?>">
          <summary>Tools <span class="nav-chevron" aria-hidden="true">⌄</span></summary>
          <div class="nav-dropdown-menu">
            <a class="<?= trim($isActive(['teacher-analytics.php'])) ?>" href="<?= e($base) ?>/teacher-analytics.php"<?= $ariaCurrent(['teacher-analytics.php']) ?>>Analytics</a>
            <a class="<?= trim($isActive(['teacher-learning-paths.php','teacher-lessons.php'])) ?>" href="<?= e($base) ?>/teacher-learning-paths.php"<?= $ariaCurrent(['teacher-learning-paths.php','teacher-lessons.php']) ?>>Learning paths & lessons</a>
            <a class="<?= trim($isActive(['teacher-monitoring.php'])) ?>" href="<?= e($base) ?>/teacher-monitoring.php"<?= $ariaCurrent(['teacher-monitoring.php']) ?>>Exam monitoring</a>
          </div>
        </details>
        <span class="nav-account"><span class="avatar teacher-avatar"><?= e(strtoupper(mb_substr((string)$user['name'], 0, 1))) ?></span><span class="nav-account-copy"><strong><?= e($user['name']) ?></strong><small>Teacher account</small></span></span>
        <a class="nav-signout" href="<?= e($base) ?>/logout.php">Sign out</a>
      <?php elseif ($user && in_array($user['role'], ['super_admin', 'admin'], true)): ?>
        <a class="<?= $isCurrentRoute('/super-admin/index.php') ? 'is-active' : '' ?>" href="<?= e($base) ?>/super-admin/index.php"<?= $isCurrentRoute('/super-admin/index.php') ? ' aria-current="page"' : '' ?>>Control center</a>
        <details class="nav-dropdown<?= in_array($currentPage, $adminManagePages, true) ? ' is-active' : '' ?>">
          <summary>Administration <span class="nav-chevron" aria-hidden="true">⌄</span></summary>
          <div class="nav-dropdown-menu">
            <a class="<?= trim($isActive(['teachers.php'])) ?>" href="<?= e($base) ?>/super-admin/teachers.php"<?= $ariaCurrent(['teachers.php']) ?>>Teacher accounts</a>
            <a class="<?= trim($isActive(['users.php'])) ?>" href="<?= e($base) ?>/super-admin/users.php"<?= $ariaCurrent(['users.php']) ?>>Manage users</a>
            <a class="<?= trim($isActive(['audit-log.php'])) ?>" href="<?= e($base) ?>/super-admin/audit-log.php"<?= $ariaCurrent(['audit-log.php']) ?>>Audit log</a>
          </div>
        </details>
        <span class="nav-account"><span class="avatar admin-avatar"><?= e(strtoupper(mb_substr((string)$user['name'], 0, 1))) ?></span><span class="nav-account-copy"><strong><?= e($user['name']) ?></strong><small>Super Admin</small></span></span>
        <a class="nav-signout" href="<?= e($base) ?>/logout.php">Sign out</a>
      <?php else: ?>
        <a class="<?= trim($isActive(['index.php'])) ?>" href="<?= e($base) ?>/index.php"<?= $ariaCurrent(['index.php']) ?>>Explore</a>
        <a class="<?= trim($isActive(['help.php'])) ?>" href="<?= e($base) ?>/help.php"<?= $ariaCurrent(['help.php']) ?>>Help</a>
        <a class="<?= trim($isActive(['about.php'])) ?>" href="<?= e($base) ?>/about.php"<?= $ariaCurrent(['about.php']) ?>>About</a>
        <details class="nav-dropdown<?= (in_array($currentPage, ['teacher-login.php','register.php'], true) || $isCurrentRoute('/super-admin/login.php')) ? ' is-active' : '' ?>">
          <summary>Portals <span class="nav-chevron" aria-hidden="true">⌄</span></summary>
          <div class="nav-dropdown-menu">
            <a href="<?= e($base) ?>/teacher-login.php">Teacher portal</a>
            <a href="<?= e($base) ?>/super-admin/login.php">Super Admin</a>
          </div>
        </details>
        <a class="<?= ($currentPage === 'login.php' && !$isCurrentRoute('/super-admin/login.php')) ? 'is-active' : '' ?>" href="<?= e($base) ?>/login.php"<?= ($currentPage === 'login.php' && !$isCurrentRoute('/super-admin/login.php')) ? ' aria-current="page"' : '' ?>>Sign in</a>
        <a class="button small nav-join-button <?= trim($isActive(['register.php'])) ?>" href="<?= e($base) ?>/register.php"<?= $ariaCurrent(['register.php']) ?>>Join free <span aria-hidden="true">↗</span></a>
      <?php endif; ?>
      </div>
    </nav>
    <main class="container" id="main-content">
    <?php if ($flash): ?><div class="alert <?= e($flash['type']) ?>" role="status"><?= e($flash['message']) ?></div><?php endif; ?>
    <?php
}
function page_footer(): void {
    global $config;
    $user = current_user();
    $base = rtrim((string)$config['base_url'], '/');
    ?></main><footer class="footer ca-footer"><a class="footer-brand" href="<?= e($base) ?>/index.php"><span class="brand-mark">&lt;/&gt;</span><span>CodeArena<small>Practice with purpose.</small></span></a><span class="footer-tagline">Progress one problem at a time.</span><nav class="footer-links" aria-label="Footer navigation"><?php if (!$user): ?><a href="<?= e($base) ?>/help.php">Help center</a><a href="<?= e($base) ?>/about.php">About</a><?php endif; ?><?php if ($user && $user['role'] === 'student'): ?><a href="<?= e($base) ?>/leaderboard.php">Leaderboard</a><a href="<?= e($base) ?>/student-progress.php">My progress</a><a href="<?= e($base) ?>/student-achievements.php">Achievements</a><a href="<?= e($base) ?>/student-submissions.php">Submissions</a><?php endif; ?><?php if ($user && $user['role'] === 'teacher'): ?><a href="<?= e($base) ?>/teacher-analytics.php">Analytics</a><a href="<?= e($base) ?>/teacher-monitoring.php">Exam monitoring</a><?php endif; ?><?php if ($user && in_array($user['role'], ['super_admin','admin'], true)): ?><a href="<?= e($base) ?>/super-admin/index.php">Control center</a><?php endif; ?><a class="developer-contact-footer-link" href="https://github.com/Benette12416" target="_blank" rel="noopener noreferrer" aria-label="Contact the CodeArena developer on GitHub (opens in a new tab)">Contact developer ↗</a></nav><span class="footer-copy">© <?= date('Y') ?> CodeArena</span></footer><script src="<?= e($base) ?>/assets/nav.js" defer></script></body></html><?php
}
