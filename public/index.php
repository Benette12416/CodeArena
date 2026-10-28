<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = current_user();
if ($user && $user['role'] === 'teacher') redirect('teacher.php');
if ($user && in_array($user['role'], ['super_admin', 'admin'], true)) redirect('super-admin/index.php');
$studentId = (int)($user['id'] ?? 0);
$sql = "SELECT e.*, u.name AS teacher_name,
        (SELECT MAX(s.score) FROM submissions s WHERE s.exercise_id=e.id AND s.user_id=?) AS my_score,
        EXISTS(SELECT 1 FROM class_assignments active_ca WHERE active_ca.exercise_id=e.id AND active_ca.is_active=1) AS has_active_assignment
        FROM exercises e JOIN users u ON u.id=e.created_by
        WHERE e.is_published=1
          AND (NOT EXISTS (SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1)
            OR EXISTS (SELECT 1 FROM class_assignments ca
              JOIN class_enrollments ce ON ce.classroom_id=ca.classroom_id AND ce.student_id=? AND ce.enrollment_status='active'
              JOIN classrooms c ON c.id=ca.classroom_id AND c.is_active=1
              WHERE ca.exercise_id=e.id AND ca.is_active=1 AND (ca.due_at IS NULL OR ca.due_at >= NOW())))
        ORDER BY e.created_at DESC";
$stmt = $pdo->prepare($sql); $stmt->execute([$studentId, $studentId]); $exercises = $stmt->fetchAll();
$myClassrooms = [];
$studentStats = null;
$continueExercise = null;
$recentStudentSubmissions = [];
$upcomingDeadlines = [];
if ($user && $user['role'] === 'student') {
    $classStmt = $pdo->prepare("SELECT c.id,c.name,c.section,
      (SELECT COUNT(*) FROM class_assignments ca WHERE ca.classroom_id=c.id AND ca.is_active=1) AS assignment_count
      FROM class_enrollments ce JOIN classrooms c ON c.id=ce.classroom_id
      WHERE ce.student_id=? AND ce.enrollment_status='active' AND c.is_active=1 ORDER BY ce.joined_at DESC LIMIT 3");
    $classStmt->execute([$studentId]); $myClassrooms = $classStmt->fetchAll();

    $statsStmt = $pdo->prepare("SELECT
        COUNT(DISTINCT CASE WHEN a.started_explicitly=1 THEN a.exercise_id END) AS started_count,
        COUNT(DISTINCT CASE WHEN a.started_explicitly=1 AND (a.status='submitted' OR a.best_score>=e.points) THEN a.exercise_id END) AS completed_count,
        COUNT(DISTINCT CASE WHEN a.started_explicitly=1 AND a.status='in_progress' AND a.deadline_at>NOW() AND a.best_score<e.points THEN a.exercise_id END) AS in_progress_count
      FROM attempts a JOIN exercises e ON e.id=a.exercise_id AND e.is_published=1 WHERE a.user_id=?");
    $statsStmt->execute([$studentId]);
    $studentStats = $statsStmt->fetch() ?: ['started_count'=>0,'completed_count'=>0,'in_progress_count'=>0];
    $submissionCountStmt = $pdo->prepare('SELECT COUNT(*) FROM submissions WHERE user_id=?');
    $submissionCountStmt->execute([$studentId]);
    $studentStats['submission_count'] = (int)$submissionCountStmt->fetchColumn();
    $studentStats['available_count'] = count($exercises);

    $continueStmt = $pdo->prepare("SELECT e.id, e.title, e.difficulty, e.points, a.deadline_at, a.started_at
      FROM attempts a JOIN exercises e ON e.id=a.exercise_id AND e.is_published=1
      WHERE a.user_id=? AND a.started_explicitly=1 AND a.status='in_progress' AND a.deadline_at>NOW() AND a.best_score<e.points
      ORDER BY a.started_at DESC LIMIT 10");
    $continueStmt->execute([$studentId]);
    foreach ($continueStmt->fetchAll() as $candidate) {
        $context = student_exercise_access_context($pdo, $studentId, (int)$candidate['id']);
        if ($context['allowed'] && (empty($context['due_at']) || strtotime((string)$context['due_at']) > time())) { $continueExercise = $candidate; break; }
    }

    $recentStmt = $pdo->prepare("SELECT s.score,s.passed_tests,s.total_tests,s.created_at,e.id AS exercise_id,e.title,e.points AS max_points
      FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE s.user_id=? AND e.is_published=1
      ORDER BY s.created_at DESC LIMIT 4");
    $recentStmt->execute([$studentId]); $recentStudentSubmissions = $recentStmt->fetchAll();

    $dueStmt = $pdo->prepare("SELECT DISTINCT e.id AS exercise_id,e.title,ca.due_at,c.name AS classroom_name,c.id AS classroom_id
      FROM class_assignments ca JOIN classrooms c ON c.id=ca.classroom_id AND c.is_active=1
      JOIN class_enrollments ce ON ce.classroom_id=c.id AND ce.student_id=? AND ce.enrollment_status='active'
      JOIN exercises e ON e.id=ca.exercise_id AND e.is_published=1
      LEFT JOIN attempts a ON a.exercise_id=e.id AND a.user_id=?
      WHERE ca.is_active=1 AND ca.due_at IS NOT NULL AND ca.due_at>=NOW()
        AND (a.id IS NULL OR (a.status<>'submitted' AND a.best_score<e.points))
      ORDER BY ca.due_at ASC LIMIT 4");
    $dueStmt->execute([$studentId,$studentId]); $upcomingDeadlines = $dueStmt->fetchAll();
}
page_header($user && $user['role'] === 'student' ? 'Student dashboard' : (!$user ? 'Learn to code' : 'Exercises'));
?>
<?php if (!$user): ?>
<section class="landing-hero" aria-labelledby="landing-title">
  <div class="landing-hero-copy">
    <span class="landing-eyebrow"><span class="status-dot"></span> LEARN · PRACTICE · LEVEL UP</span>
    <h1 id="landing-title">Build real coding skills, <span class="gradient">one challenge at a time.</span></h1>
    <p>CodeArena brings coding practice, instant feedback, classroom assignments, and visible progress into one focused learning space.</p>
    <div class="landing-hero-actions">
      <a class="button" href="<?= e($config['base_url']) ?>/register.php">Start learning free <span aria-hidden="true">↗</span></a>
      <a class="button secondary" href="#practice">Explore challenges <span aria-hidden="true">↓</span></a>
    </div>
    <div class="landing-trust-row">
      <span><i>✓</i> Practice at your pace</span>
      <span><i>✓</i> Get feedback on submissions</span>
      <span><i>✓</i> Learn with your class</span>
    </div>
  </div>
  <div class="landing-hero-visual" aria-label="Preview of the CodeArena coding workspace">
    <div class="landing-orb landing-orb-one"></div><div class="landing-orb landing-orb-two"></div>
    <div class="landing-editor-preview">
      <div class="landing-editor-top"><div class="window-dots"><i></i><i></i><i></i></div><span>solution.py</span><span class="landing-editor-language">PYTHON</span></div>
      <div class="landing-code-lines">
        <div><span>01</span><code><b>def</b> <em>sum_values</em>(numbers):</code></div>
        <div><span>02</span><code>    total = <i>sum</i>(numbers)</code></div>
        <div><span>03</span><code>    <b>return</b> total</code></div>
        <div><span>04</span><code></code></div>
        <div><span>05</span><code><i>print</i>(sum_values([2, 3, 5]))</code></div>
      </div>
      <div class="landing-editor-result"><span>✓</span><div><strong>All sample tests passed</strong><small>Output matched the expected result</small></div><b>ACCEPTED</b></div>
    </div>
    <div class="landing-float-card landing-float-score"><span class="landing-float-check">✓</span><span><strong>Challenge complete</strong><small>Progress saved</small></span></div>
    <div class="landing-float-card landing-float-points"><span class="landing-points-icon">✦</span><span><strong>100 points</strong><small>Keep building your streak</small></span></div>
  </div>
</section>
<section class="landing-value-strip" aria-label="CodeArena benefits">
  <div><span class="landing-value-icon value-purple">&lt;/&gt;</span><span><strong>Practice with purpose</strong><small>Try problems at your level</small></span></div>
  <div><span class="landing-value-icon value-blue">✓</span><span><strong>Learn from feedback</strong><small>See how your code performs</small></span></div>
  <div><span class="landing-value-icon value-green">↗</span><span><strong>Track your progress</strong><small>Build confidence over time</small></span></div>
</section>
<section class="landing-feature-section" aria-labelledby="landing-features-title">
  <div class="landing-section-heading"><p class="eyebrow">YOUR WORKSPACE FOR GROWTH</p><h2 id="landing-features-title">Everything in one place to keep getting better.</h2><p>From the first exercise to classroom assignments, CodeArena helps turn practice into progress.</p></div>
  <div class="landing-feature-grid">
    <article class="landing-feature-card"><span class="landing-feature-icon feature-lavender">&lt;/&gt;</span><h3>Hands-on coding</h3><p>Write code, run it with custom input, and submit solutions for automated checking.</p><a href="<?= e($config['base_url']) ?>/help.php#running-code">How coding works <span aria-hidden="true">→</span></a></article>
    <article class="landing-feature-card"><span class="landing-feature-icon feature-mint">▦</span><h3>Classroom assignments</h3><p>Join a class with your teacher's code and find assignments, deadlines, and results in one view.</p><a href="<?= e($config['base_url']) ?>/help.php#classrooms">Explore classrooms <span aria-hidden="true">→</span></a></article>
    <article class="landing-feature-card"><span class="landing-feature-icon feature-sky">★</span><h3>Progress you can see</h3><p>Review your submitted scores, celebrate perfect results, and compare rankings on the leaderboard.</p><a href="<?= e($config['base_url']) ?>/leaderboard.php">View leaderboard <span aria-hidden="true">→</span></a></article>
  </div>
</section>
<section class="landing-how-section" id="how-it-works" aria-labelledby="landing-how-title">
  <div class="landing-section-heading"><p class="eyebrow">GET STARTED IN THREE STEPS</p><h2 id="landing-how-title">Small steps. Stronger skills.</h2></div>
  <div class="landing-steps-grid">
    <article><span class="landing-step-number">01</span><h3>Create your student account</h3><p>Join as a student to explore available challenges and connect to your teacher's classroom.</p></article>
    <article><span class="landing-step-number">02</span><h3>Start and solve a challenge</h3><p>Read the exercise, write your solution, run it, and submit when you're ready.</p></article>
    <article><span class="landing-step-number">03</span><h3>Learn from the result</h3><p>Review the score and test results, improve your solution, and keep progressing.</p></article>
  </div>
</section>
<section class="landing-support-banner">
  <div><p class="eyebrow">NEW TO CODEARENA?</p><h2>Find your way around.</h2><p>Read the Help Center for student, teacher, and troubleshooting guidance, or learn more about the platform.</p></div>
  <div class="landing-support-actions"><a class="button" href="<?= e($config['base_url']) ?>/help.php">Visit Help Center <span aria-hidden="true">→</span></a><a class="button secondary" href="<?= e($config['base_url']) ?>/about.php">About CodeArena</a><a class="button secondary developer-contact-home" href="https://github.com/Benette12416" target="_blank" rel="noopener noreferrer">Contact developer ↗</a></div>
</section>
<?php endif; ?>
<?php if ($user && $user['role'] === 'student' && $studentStats): ?>
<section class="student-dashboard-overview student-dashboard-overview-v19" aria-label="Your learning overview">
  <div class="student-dashboard-heading student-dashboard-heading-v19">
    <div class="student-dashboard-heading-copy"><p class="eyebrow">YOUR LEARNING SPACE</p><h1>Welcome back, <?= e(explode(' ', trim((string)$user['name']))[0] ?: 'coder') ?>.</h1><p class="muted">A little progress adds up. Continue an exercise, check your classes, or find your next challenge.</p></div>
    <div class="student-dashboard-actions-v19"><a class="button student-practice-primary-v20" href="#practice"><span aria-hidden="true">&lt;/&gt;</span> Practice Arena <span aria-hidden="true">→</span></a><a class="button secondary" href="<?= e($config['base_url']) ?>/student-classrooms.php">My classes</a></div>
  </div>
  <div class="student-metric-grid student-metric-grid-v19">
    <article class="student-metric-card"><span class="student-metric-icon metric-purple" aria-hidden="true">✓</span><span>Finished challenges</span><strong><?= (int)$studentStats['completed_count'] ?></strong><small>Submitted or completed attempts</small></article>
    <article class="student-metric-card"><span class="student-metric-icon metric-blue" aria-hidden="true">◷</span><span>In progress</span><strong><?= (int)$studentStats['in_progress_count'] ?></strong><small>Active timed attempts</small></article>
    <article class="student-metric-card"><span class="student-metric-icon metric-green" aria-hidden="true">↗</span><span>Submissions</span><strong><?= (int)$studentStats['submission_count'] ?></strong><small>Saved coding attempts</small></article>
    <article class="student-metric-card"><span class="student-metric-icon metric-orange" aria-hidden="true">⌘</span><span>Available</span><strong><?= (int)$studentStats['available_count'] ?></strong><small>Challenges you can access</small></article>
  </div>
  <?php $studentAvailableTotal = max(0, (int)$studentStats['available_count']); $studentFinishedTotal = $studentAvailableTotal > 0 ? min($studentAvailableTotal, max(0, (int)$studentStats['completed_count'])) : 0; $studentProgressPct = $studentAvailableTotal > 0 ? (int)round(($studentFinishedTotal / $studentAvailableTotal) * 100) : 0; ?>
  <section class="student-momentum-strip-v19" aria-label="Challenge progress">
    <div class="student-momentum-copy-v19"><span class="student-momentum-mark-v19" aria-hidden="true">✦</span><div><strong>Your learning momentum</strong><p><?= $studentAvailableTotal > 0 ? e((string)$studentFinishedTotal) . ' of ' . e((string)$studentAvailableTotal) . ' available challenges marked finished.' : 'Join a classroom or check back when challenges are published.' ?></p></div></div>
    <div class="student-momentum-progress-v19"><div class="student-momentum-progress-label-v19"><span>Challenge progress</span><strong><?= $studentProgressPct ?>%</strong></div><div class="student-momentum-track-v19" role="progressbar" aria-label="Challenge progress" aria-valuemin="0" aria-valuemax="100" aria-valuenow="<?= $studentProgressPct ?>"><span style="width:<?= $studentProgressPct ?>%"></span></div></div>
  </section>
  <nav class="student-dashboard-shortcuts-v19" aria-label="Student quick links">
    <a href="<?= e($config['base_url']) ?>/student-classrooms.php"><span class="student-shortcut-icon-v19 shortcut-purple-v19" aria-hidden="true">▦</span><span><strong>My classes</strong><small>Assignments and deadlines</small></span><span class="student-shortcut-arrow-v19" aria-hidden="true">↗</span></a>
    <a href="<?= e($config['base_url']) ?>/student-learning-paths.php"><span class="student-shortcut-icon-v19 shortcut-blue-v19" aria-hidden="true">⌁</span><span><strong>Learning paths</strong><small>Follow guided topics</small></span><span class="student-shortcut-arrow-v19" aria-hidden="true">↗</span></a>
    <a href="<?= e($config['base_url']) ?>/student-progress.php"><span class="student-shortcut-icon-v19 shortcut-green-v19" aria-hidden="true">◔</span><span><strong>My progress</strong><small>Review skills and results</small></span><span class="student-shortcut-arrow-v19" aria-hidden="true">↗</span></a>
    <a href="<?= e($config['base_url']) ?>/leaderboard.php"><span class="student-shortcut-icon-v19 shortcut-orange-v19" aria-hidden="true">★</span><span><strong>Leaderboard</strong><small>See class and global ranks</small></span><span class="student-shortcut-arrow-v19" aria-hidden="true">↗</span></a>
  </nav>
  <section class="student-practice-spotlight-v20" aria-label="Practice Arena shortcut">
    <div class="student-practice-spotlight-mark-v20" aria-hidden="true">&lt;/&gt;</div>
    <div class="student-practice-spotlight-copy-v20"><span class="student-practice-kicker-v20">YOUR PERSONAL CODING SPACE</span><h2>Practice Arena</h2><p>Try challenges at your own pace. Run code, check public samples, and build confidence without changing your official classroom grades.</p></div>
    <div class="student-practice-spotlight-actions-v20"><a class="button student-practice-primary-v20" href="#practice">Browse challenges <span aria-hidden="true">↘</span></a><a class="button secondary" href="<?= e($config['base_url']) ?>/student-learning-paths.php">Follow a learning path</a></div>
  </section>
  <div class="student-dashboard-secondary">
    <section class="panel student-continue-panel"><div class="student-panel-top"><div><p class="eyebrow">PICK UP WHERE YOU LEFT OFF</p><h3><?= $continueExercise ? e($continueExercise['title']) : 'Ready for a new challenge?' ?></h3></div><span class="student-panel-symbol">&lt;/&gt;</span></div>
    <?php if ($continueExercise): ?><div class="student-continue-meta"><span class="difficulty <?= strtolower(e($continueExercise['difficulty'])) ?>"><?= e($continueExercise['difficulty']) ?></span><span>◷ <?= (int)ceil(max(0, strtotime((string)$continueExercise['deadline_at']) - time()) / 60) ?> min remaining</span><span>✦ <?= (int)$continueExercise['points'] ?> pts</span></div><a class="button" href="<?= e($config['base_url']) ?>/exercise.php?id=<?= (int)$continueExercise['id'] ?>">Continue exercise →</a>
    <?php else: ?><p class="muted">You have no active attempts right now. Start a challenge or open one of your classes to keep learning.</p><a class="button" href="#practice">Browse challenges →</a><?php endif; ?></section>
    <section class="panel student-deadline-panel"><div class="student-panel-top"><div><p class="eyebrow">STAY ON TRACK</p><h3>Upcoming deadlines</h3></div><span class="student-panel-symbol">◷</span></div>
    <?php if ($upcomingDeadlines): ?><div class="upcoming-deadline-list"><?php foreach ($upcomingDeadlines as $due): ?><a href="<?= e($config['base_url']) ?>/exercise.php?id=<?= (int)$due['exercise_id'] ?>" class="upcoming-deadline-item"><span class="deadline-date"><strong><?= e(date('d',strtotime((string)$due['due_at']))) ?></strong><small><?= e(date('M',strtotime((string)$due['due_at']))) ?></small></span><span class="deadline-copy"><strong><?= e($due['title']) ?></strong><small><?= e($due['classroom_name']) ?></small></span><span class="deadline-arrow">→</span></a><?php endforeach; ?></div>
    <?php else: ?><p class="muted">No upcoming class deadlines. You're all clear for now.</p><a class="quiet-link" href="<?= e($config['base_url']) ?>/student-classrooms.php">View my classes ↗</a><?php endif; ?></section>
  </div>
  <section class="panel student-recent-panel student-recent-panel-v19"><div class="section-title"><div><p class="eyebrow">YOUR LATEST WORK</p><h3>Recent submissions</h3><p class="muted">A quick look at your latest saved results.</p></div><a class="quiet-link" href="<?= e($config['base_url']) ?>/leaderboard.php">View leaderboard ↗</a></div><?php if ($recentStudentSubmissions): ?><div class="student-recent-list"><?php foreach ($recentStudentSubmissions as $recent): $maxRecent = max(1,(int)$recent['max_points']); $scoreRecent=(int)$recent['score']; $scoreTone=$scoreRecent >= $maxRecent ? 'score-perfect' : ($scoreRecent*2 >= $maxRecent ? 'score-progress' : 'score-failed'); ?><a class="student-recent-row" href="<?= e($config['base_url']) ?>/exercise.php?id=<?= (int)$recent['exercise_id'] ?>"><span class="recent-submission-icon">&lt;/&gt;</span><span class="recent-submission-name"><strong><?= e($recent['title']) ?></strong><small><?= e(date('M j, Y · g:i A',strtotime((string)$recent['created_at']))) ?> · <?= (int)$recent['passed_tests'] ?>/<?= (int)$recent['total_tests'] ?> tests passed</small></span><span class="score-chip <?= $scoreTone ?>"><?= $scoreRecent ?> pts</span></a><?php endforeach; ?></div><?php else: ?><div class="student-empty-state-v19"><span class="student-empty-icon-v19" aria-hidden="true">&lt;/&gt;</span><div><strong>Your first submission starts here</strong><p>Run a solution in the Practice Arena or open a classroom assignment to save your first result.</p></div><a class="button secondary small" href="#practice">Find a challenge</a></div><?php endif; ?></section>
</section>
<?php endif; ?>
<?php if ($user && $user['role'] === 'student'): ?>
<section class="student-home-classes"><div class="section-title"><div><p class="eyebrow">LEARN WITH YOUR CLASS</p><h2>My classrooms</h2><p class="muted">Your teacher's assignments and class progress start here.</p></div><a class="quiet-link" href="<?= e($config['base_url']) ?>/student-classrooms.php">View all classes ↗</a></div>
<?php if ($myClassrooms): ?><div class="student-home-class-grid"><?php foreach ($myClassrooms as $c): ?><a class="panel student-home-class-card" href="<?= e($config['base_url']) ?>/student-classroom.php?id=<?= (int)$c['id'] ?>"><span class="classroom-icon">▦</span><div><strong><?= e($c['name']) ?></strong><span><?= e($c['section']) ?></span></div><small><?= (int)$c['assignment_count'] ?> assignment<?= (int)$c['assignment_count']===1?'':'s' ?> →</small></a><?php endforeach; ?><a class="panel student-home-class-card class-join-cta" href="<?= e($config['base_url']) ?>/student-classrooms.php"><span class="classroom-icon">＋</span><div><strong>Join another class</strong><span>Have a code from your teacher?</span></div><small>Enter code →</small></a></div><?php else: ?><div class="panel student-join-prompt"><div><strong>Have a class join code?</strong><p class="muted">Join your teacher's classroom to access assignments and see your grades.</p></div><a class="button" href="<?= e($config['base_url']) ?>/student-classrooms.php">Join a classroom →</a></div><?php endif; ?></section>
<?php endif; ?>
<section class="practice-section <?= $user && $user['role'] === 'student' ? 'practice-section-student-v20' : '' ?>" id="practice">
  <div class="section-title practice-section-heading"><div><p class="eyebrow"><?= $user && $user['role'] === 'student' ? 'YOUR NEXT STEP' : 'PICK YOUR NEXT CHALLENGE' ?></p><h2><?= $user && $user['role'] === 'student' ? 'Practice arena' : 'Find a challenge. Build a skill.' ?></h2><p class="muted"><?= $user && $user['role'] === 'student' ? 'Choose a challenge, work through it, and see what you can do.' : 'Browse published exercises. Sign in or create a student account to get started.' ?></p></div><span class="pill"><span class="pill-dot"></span><?= count($exercises) ?> published</span></div>
  <?php if ($user && $user['role'] === 'student'): ?><div class="practice-arena-note-v20"><span class="practice-arena-note-icon-v20" aria-hidden="true">✦</span><div><strong>Practice freely. Learn from every run.</strong><p>Practice Mode checks public samples and custom input only. It does not affect official classroom grades.</p></div><a href="<?= e($config['base_url']) ?>/student-learning-paths.php">Explore learning paths ↗</a></div><?php endif; ?>
  <?php if ($exercises): ?><div class="practice-filterbar"><label class="practice-search"><span aria-hidden="true">⌕</span><span class="sr-only">Search exercises</span><input type="search" id="challenge-search" placeholder="Search challenges by title…" autocomplete="off"></label><label class="practice-difficulty-filter"><span class="sr-only">Filter by difficulty</span><select id="challenge-difficulty"><option value="all">All difficulties</option><option value="easy">Easy</option><option value="medium">Medium</option><option value="hard">Hard</option></select></label><span class="practice-results-count" id="challenge-results-count"><?= count($exercises) ?> challenges</span></div><?php endif; ?>
  <div class="grid practice-grid" id="challenge-grid">
  <?php foreach ($exercises as $x): ?>
  <a class="card exercise-card" data-title="<?= e(strtolower((string)$x['title'])) ?>" data-difficulty="<?= e(strtolower((string)$x['difficulty'])) ?>" href="<?= e($config['base_url']) ?>/<?= ((int)$x['has_active_assignment'] === 1 || !$user) ? 'exercise.php' : 'practice.php' ?>?id=<?= (int)$x['id'] ?>">
  <div class="card-top"><span class="difficulty <?= strtolower(e($x['difficulty'])) ?>"><?= e($x['difficulty']) ?></span><span class="points">✦ <?= (int)$x['points'] ?> pts</span></div>
  <h3><?= e($x['title']) ?></h3><p class="muted clamp">Open the challenge<?= (int)$x['has_active_assignment'] ? ' and start the timed classroom attempt.' : ' in Practice Mode without changing official grades.' ?></p>
  <div class="card-bottom"><span>◷ <?= (int)ceil($x['time_limit_seconds']/60) ?> min <?= (int)$x['has_active_assignment'] ? 'attempt' : 'reference' ?></span><span><?= (int)$x['has_active_assignment'] ? ($x['my_score'] !== null ? 'Best: '.(int)$x['my_score'] : 'Assigned') : 'Practice mode' ?> ↗</span></div>
  </a>
  <?php endforeach; ?>
  <?php if (!$exercises): ?><div class="empty"><h3>The arena is warming up.</h3><p>No published exercises yet. A teacher can publish the first challenge.</p></div><?php endif; ?>
  </div>
  <?php if ($exercises): ?><div class="practice-no-results" id="challenge-no-results" hidden><strong>No challenges match those filters.</strong><span>Try a different search or choose another difficulty.</span><button class="button secondary small" type="button" id="clear-challenge-filters">Clear filters</button></div><?php endif; ?>
</section>
<?php if (!$user): ?><script>
(() => {
  const search = document.getElementById('challenge-search');
  const difficulty = document.getElementById('challenge-difficulty');
  const cards = Array.from(document.querySelectorAll('#challenge-grid .exercise-card'));
  const count = document.getElementById('challenge-results-count');
  const empty = document.getElementById('challenge-no-results');
  const clear = document.getElementById('clear-challenge-filters');
  const filter = () => {
    const query = (search?.value || '').trim().toLowerCase();
    const level = difficulty?.value || 'all';
    let visible = 0;
    cards.forEach(card => {
      const match = (card.dataset.title || '').includes(query) && (level === 'all' || card.dataset.difficulty === level);
      card.hidden = !match;
      if (match) visible++;
    });
    if (count) count.textContent = `${visible} challenge${visible === 1 ? '' : 's'}`;
    if (empty) empty.hidden = visible !== 0;
  };
  search?.addEventListener('input', filter);
  difficulty?.addEventListener('change', filter);
  clear?.addEventListener('click', () => { if (search) search.value = ''; if (difficulty) difficulty.value = 'all'; filter(); search?.focus(); });
})();
</script><?php endif; ?>
<?php page_footer(); ?>
