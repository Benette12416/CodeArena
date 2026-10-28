<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = current_user();
page_header('Help Center');
?>
<section class="info-hero help-hero">
  <div class="info-hero-copy">
    <p class="eyebrow">CODEARENA SUPPORT</p>
    <h1>How can we help you <span class="gradient">move forward?</span></h1>
    <p>Find quick steps and answers for student accounts, classrooms, coding exercises, submissions, teacher tools, and exam monitoring.</p>
    <div class="info-hero-actions">
      <a class="button" href="#quick-start">Browse help topics <span aria-hidden="true">↓</span></a>
      <?php if (!$user): ?><a class="button secondary" href="<?= e($config['base_url']) ?>/login.php">Student sign in</a><?php elseif ($user['role'] === 'student'): ?><a class="button secondary" href="<?= e($config['base_url']) ?>/student-classrooms.php">My classes</a><?php elseif ($user['role'] === 'teacher'): ?><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher.php">Open Teacher Studio</a><?php endif; ?>
    </div>
  </div>
  <div class="info-hero-art" aria-hidden="true">
    <div class="info-hero-art-icon">?</div>
    <div class="info-hero-art-card"><span class="info-art-check">✓</span><div><strong>Find your next step</strong><small>Quick guides · FAQs · Troubleshooting</small></div></div>
    <span class="info-art-pill">CODEARENA HELP</span>
  </div>
</section>

<section class="info-content-section" id="quick-start">
  <div class="info-section-heading"><p class="eyebrow">QUICK START</p><h2>Choose what you're working on.</h2><p class="muted">Jump straight to the instructions that match your role.</p></div>
  <div class="help-topic-grid">
    <a class="help-topic-card" href="#student-guides"><span class="help-topic-icon help-topic-purple">&lt;/&gt;</span><div><h3>Student guide</h3><p>Join a classroom, start exercises, run code, submit answers, and understand scores.</p></div><span class="help-topic-arrow">→</span></a>
    <a class="help-topic-card" href="#teacher-guides"><span class="help-topic-icon help-topic-teal">▦</span><div><h3>Teacher guide</h3><p>Create exercises, manage test cases, publish challenges, and review grades.</p></div><span class="help-topic-arrow">→</span></a>
    <a class="help-topic-card" href="#troubleshooting"><span class="help-topic-icon help-topic-blue">⌘</span><div><h3>Troubleshooting</h3><p>Resolve code execution, login, timer, browser, and connection issues.</p></div><span class="help-topic-arrow">→</span></a>
  </div>
</section>

<section class="info-content-section help-article-section" id="student-guides">
  <div class="info-section-heading"><p class="eyebrow">FOR STUDENTS</p><h2>Learn how to use the coding workspace.</h2></div>
  <div class="help-article-grid">
    <article class="help-article-card" id="classrooms"><span class="help-article-step">01</span><div><h3>Join a classroom</h3><p>Sign in with your student account, open <strong>My Classes</strong>, and enter the join code shared by your teacher. If the class is active and the code is valid, it will appear in your classroom list.</p><a href="<?= e($config['base_url']) ?>/student-classrooms.php">Open My Classes →</a></div></article>
    <article class="help-article-card" id="start-exercise"><span class="help-article-step">02</span><div><h3>Start an exercise</h3><p>Before you start, CodeArena shows only the exercise title, time limit, and total points. Click <strong>Start Exercise</strong> to begin the attempt and reveal the problem description and coding workspace.</p><p class="help-note">The timer begins when the server accepts the start action. Starting an exercise can use up the available time, so start when you're ready to work.</p></div></article>
    <article class="help-article-card" id="running-code"><span class="help-article-step">03</span><div><h3>Run Code vs. Submit Answer</h3><p><strong>Run Code</strong> runs your current code with the custom input you provide and displays the output without recording a grade. <strong>Submit Answer</strong> grades your code against the exercise's configured test cases and saves the result.</p></div></article>
    <article class="help-article-card"><span class="help-article-step">04</span><div><h3>Understand your score</h3><p>Your result depends on the configured test cases and points. A perfect score means the maximum points were earned. Partial scores may still count toward your progress. When a perfect score completes an attempt, its timer stops and CodeArena shows the completion panel.</p></div></article>
  </div>
</section>

<section class="info-content-section help-article-section" id="teacher-guides">
  <div class="info-section-heading"><p class="eyebrow">FOR TEACHERS</p><h2>Build and manage programming activities.</h2></div>
  <div class="help-article-grid">
    <article class="help-article-card"><span class="help-article-step">01</span><div><h3>Create and publish an exercise</h3><p>Open Teacher Studio and use the exercise builder to add a title, difficulty, description, starter code, point value, and time limit in minutes. Save a draft while preparing it, or publish when it is ready.</p><a href="<?= e($config['base_url']) ?>/teacher.php">Open Teacher Studio →</a></div></article>
    <article class="help-article-card"><span class="help-article-step">02</span><div><h3>Configure test cases</h3><p>Add expected input and output for each test case. Use public cases to show students sample behavior. Mark private cases as hidden so their inputs and expected outputs are not displayed in student results.</p></div></article>
    <article class="help-article-card"><span class="help-article-step">03</span><div><h3>Assign work to a class</h3><p>Create a classroom, share its join code, and assign published exercises. Assignments can have a due date. Students must be actively enrolled in the class to access its assigned work.</p><a href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Manage classrooms →</a></div></article>
    <article class="help-article-card" id="exam-monitoring"><span class="help-article-step">04</span><div><h3>Review exam monitoring</h3><p>Enable monitoring in an exercise's settings before students start their attempts. Review supported browser events in the teacher-only Exam Monitoring area. Events are review signals, not automatic proof of cheating, and they do not automatically change scores.</p><a href="<?= e($config['base_url']) ?>/teacher-monitoring.php">Open Exam Monitoring →</a></div></article>
  </div>
</section>

<section class="info-content-section help-faq-section" id="troubleshooting">
  <div class="info-section-heading"><p class="eyebrow">TROUBLESHOOTING</p><h2>Common questions.</h2><p class="muted">Start with these checks if something isn't working as expected.</p></div>
  <div class="help-faq-list">
    <details><summary>Why can't I see the exercise instructions before I start?</summary><div><p>This is intentional. The pre-start screen only shows the title, time limit, and total points. Click <strong>Start Exercise</strong> to begin the attempt and access the instructions and editor.</p></div></details>
    <details><summary>Why does CodeArena say it couldn't reach Judge0?</summary><div><p>Code execution depends on a reachable Judge0-compatible service. Check that your Mac has an internet connection, the endpoint in <code>config/config.php</code> is correct for your provider, and any required API key and authentication header are configured. A DNS error usually means the hostname could not be resolved; an HTTP 401, 403, or 429 means the host responded but access or usage may be restricted.</p></div></details>
    <details><summary>Why did my code run but my submission score not change?</summary><div><p><strong>Run Code</strong> is for testing with custom input and does not save a grade. Use <strong>Submit Answer</strong> to run the configured test suite and record a score.</p></div></details>
    <details><summary>Can students sign up as teachers?</summary><div><p>No. Public registration creates student accounts only. A Super Admin creates teacher accounts and provides the teacher with the sign-in details.</p><a href="<?= e($config['base_url']) ?>/teacher-login.php">Teacher Portal →</a></div></details>
    <details><summary>What does browser exam monitoring detect?</summary><div><p>Depending on the browser and page, CodeArena can record events such as the exam page becoming hidden, copy/cut/paste interactions inside the page, or fullscreen exits. It does not inspect other applications, capture screenshots, or store clipboard contents. A normal website cannot guarantee that all outside activity is detected or blocked.</p></div></details>
    <details><summary>What should I do if the timer, page, or login looks wrong?</summary><div><p>Refresh once, confirm the Mac's network connection, and sign in again if the session expired. If the problem continues, note the page, exercise title, browser, and exact error message and share those details with your teacher or CodeArena administrator. Do not share your password or API key.</p></div></details>
  </div>
</section>

<section class="info-bottom-cta"><div><p class="eyebrow">READY TO CONTINUE?</p><h2>Back to the practice arena.</h2><p>Find a challenge or return to your class and keep building your skills.</p></div><div class="info-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/index.php#practice">Explore challenges →</a><?php if (!$user): ?><a class="button secondary" href="<?= e($config['base_url']) ?>/register.php">Create student account</a><?php endif; ?></div></section>
<?php page_footer(); ?>
