<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = current_user();
page_header('About CodeArena');
?>
<section class="info-hero about-hero">
  <div class="info-hero-copy">
    <p class="eyebrow">ABOUT CODEARENA</p>
    <h1>A place to practice, <span class="gradient">learn, and make progress.</span></h1>
    <p>CodeArena is a browser-based programming practice and classroom assessment platform. It brings coding exercises, automated checking, class assignments, and learning progress together in one organized space.</p>
    <div class="info-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/index.php#practice">Explore challenges <span aria-hidden="true">→</span></a><a class="button secondary" href="<?= e($config['base_url']) ?>/help.php">Visit Help Center</a></div>
  </div>
  <div class="about-hero-symbol" aria-hidden="true"><span class="about-symbol-mark">&lt;/&gt;</span><strong>CodeArena</strong><small>Practice with purpose.</small><div class="about-symbol-lines"><i></i><i></i><i></i><i></i></div></div>
</section>

<section class="info-content-section">
  <div class="info-section-heading"><p class="eyebrow">WHY CODEARENA</p><h2>Make practice part of the learning process.</h2><p class="muted">The goal is to give students a place to work through programming challenges and give teachers a practical way to organize classroom coding activities.</p></div>
  <div class="about-principles-grid">
    <article class="about-principle-card"><span class="about-principle-icon principle-purple">&lt;/&gt;</span><h3>Learn by doing</h3><p>Students write programs, run them with custom input, submit solutions, and review the results.</p></article>
    <article class="about-principle-card"><span class="about-principle-icon principle-green">✓</span><h3>Get useful feedback</h3><p>Configured test cases help evaluate output and award points, including partial credit where the exercise supports it.</p></article>
    <article class="about-principle-card"><span class="about-principle-icon principle-blue">▦</span><h3>Connect classroom work</h3><p>Teachers can organize students into classrooms, assign exercises, set deadlines, and review grade records.</p></article>
    <article class="about-principle-card"><span class="about-principle-icon principle-orange">↗</span><h3>See progress</h3><p>Submission histories and the leaderboard help students and teachers review outcomes over time.</p></article>
  </div>
</section>

<section class="about-workflow-section">
  <div class="about-workflow-copy"><p class="eyebrow">HOW IT FITS TOGETHER</p><h2>One workflow for students and educators.</h2><p>Teachers prepare exercises and test cases, organize class assignments, and review results. Students join their class, start an exercise when ready, write and run code, and submit for grading.</p><a class="quiet-link" href="<?= e($config['base_url']) ?>/help.php">Read how to get started →</a></div>
  <div class="about-workflow-list">
    <div><span>01</span><div><strong>Prepare</strong><small>Teachers create exercises, test cases, and assignments.</small></div></div>
    <div><span>02</span><div><strong>Practice</strong><small>Students run code, submit solutions, and review results.</small></div></div>
    <div><span>03</span><div><strong>Review</strong><small>Teachers use gradebooks and reports to understand progress.</small></div></div>
  </div>
</section>

<section class="about-roles-section">
  <div class="info-section-heading"><p class="eyebrow">THREE PORTALS</p><h2>Purpose-built spaces for each role.</h2></div>
  <div class="about-role-grid">
    <article class="about-role-card"><span class="about-role-mark role-student">S</span><h3>Students</h3><p>Explore available practice problems, join classrooms, complete assignments, and review scores.</p><?php if (!$user): ?><a href="<?= e($config['base_url']) ?>/register.php">Create student account →</a><?php else: ?><a href="<?= e($config['base_url']) ?>/index.php">Open practice arena →</a><?php endif; ?></article>
    <article class="about-role-card"><span class="about-role-mark role-teacher">T</span><h3>Teachers</h3><p>Create and publish exercises, manage classes, grade work, and review exam-monitoring events when enabled.</p><a href="<?= e($config['base_url']) ?>/teacher-login.php">Teacher Portal →</a></article>
    <article class="about-role-card"><span class="about-role-mark role-admin">A</span><h3>Super Admin</h3><p>Manage teacher accounts and users through a separate administration portal.</p><a href="<?= e($config['base_url']) ?>/super-admin/login.php">Super Admin login →</a></article>
  </div>
</section>

<section class="about-developer-section" aria-labelledby="about-developer-title">
  <div class="about-developer-avatar" aria-hidden="true">&lt;/&gt;</div>
  <div class="about-developer-copy"><p class="eyebrow">PROJECT DEVELOPER</p><h2 id="about-developer-title">Have feedback or a suggestion?</h2><p>CodeArena is continually being improved. For feedback, bug reports, or feature ideas, visit the developer's GitHub profile and use the contact options available there.</p><div class="about-developer-meta"><span class="about-developer-handle">@Benette12416</span><span class="about-developer-dot" aria-hidden="true">·</span><span>CodeArena developer</span></div></div>
  <a class="button about-developer-button" href="https://github.com/Benette12416" target="_blank" rel="noopener noreferrer">Visit GitHub profile <span aria-hidden="true">↗</span></a>
</section>

<section class="about-note-panel"><span class="about-note-icon">i</span><div><h3>A note about exam monitoring</h3><p>CodeArena can record certain browser events when monitoring is enabled for an exercise. It is not a complete lockdown browser and cannot guarantee that all activity outside the exam page is detected or prevented. Monitoring events should be reviewed fairly and do not automatically prove cheating.</p></div></section>
<section class="info-bottom-cta"><div><p class="eyebrow">TAKE THE NEXT STEP</p><h2>Start with one challenge.</h2><p>A small, consistent practice habit can make programming feel more familiar over time.</p></div><div class="info-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/index.php#practice">Explore challenges →</a><a class="button secondary" href="<?= e($config['base_url']) ?>/help.php">Help Center</a></div></section>
<?php page_footer(); ?>
