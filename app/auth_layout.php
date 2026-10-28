<?php
function auth_header(string $title, string $portal = 'student'): void {
    global $config;
    $portalData = match ($portal) {
        'teacher' => ['label' => 'TEACHER PORTAL', 'title' => 'Teach with clarity.', 'copy' => 'Prepare challenges, publish assignments, and follow your students’ progress.', 'class' => 'teacher-auth'],
        default => ['label' => 'STUDENT PORTAL', 'title' => 'Your next level starts here.', 'copy' => 'Practice problems, sharpen your logic, and turn progress into points.', 'class' => 'student-auth'],
    };
    ?><!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light"><meta name="theme-color" content="#f6f8fc"><title><?= e($title) ?> · <?= e($config['app_name']) ?></title>
<link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/style.css"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v14.css"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v24-design-system.css?v=24.0"><link rel="stylesheet" href="<?= e($config['base_url']) ?>/assets/v25-developer-contact.css?v=25.0"></head>
<body class="auth-page <?= e($portalData['class']) ?>">
<header class="auth-topbar"><a class="brand" href="<?= e($config['base_url']) ?>/index.php"><span class="brand-mark">&lt;/&gt;</span> CodeArena</a>
<div class="auth-top-actions"><span><?= e($portalData['label']) ?></span><a href="<?= e($config['base_url']) ?>/index.php">Back to site <span aria-hidden="true">↗</span></a></div></header>
<main class="auth-stage"><section class="auth-story"><div class="story-chip"><span class="status-dot"></span> PRACTICE. SUBMIT. LEVEL UP.</div>
<h1><?= e($portalData['title']) ?></h1><p><?= e($portalData['copy']) ?></p>
<div class="story-art" aria-hidden="true"><div class="art-window"><div class="art-window-bar"><i></i><i></i><i></i><span>main.cpp</span></div><div class="art-code"><span class="code-muted">01</span> <span class="code-purple">int</span> <span class="code-cyan">main</span>() {<br><span class="code-muted">02</span> &nbsp;&nbsp;<span class="code-purple">return</span> <span class="code-green">0</span>;<br><span class="code-muted">03</span> }</div></div><div class="art-score"><span class="score-icon">✦</span><div><strong>+100 XP</strong><small>Progress unlocked</small></div></div></div>
</section><?php
}

function auth_footer(): void {
    ?></main><footer class="auth-footer">© <?= date('Y') ?> CodeArena <span>Built for curious minds and clean code.</span><a href="https://github.com/Benette12416" target="_blank" rel="noopener noreferrer">Contact developer on GitHub ↗</a></footer></body></html><?php
}
