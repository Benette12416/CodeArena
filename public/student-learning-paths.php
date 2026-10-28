<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
require_once __DIR__ . '/../app/learning_paths.php';
$user = require_role(['student']);
$selectedPathId = max(0, (int)($_GET['path_id'] ?? 0));

$pathIdsStmt = $pdo->query("SELECT id FROM learning_paths WHERE is_published=1 ORDER BY updated_at DESC,id DESC");
$publishedPathIds = array_map('intval', $pathIdsStmt->fetchAll(PDO::FETCH_COLUMN));
$pathCards = [];
$selectedContext = null;
foreach ($publishedPathIds as $publishedPathId) {
    $context = ca_student_learning_path_context($pdo, (int)$user['id'], $publishedPathId);
    if (!$context) continue;
    if ($selectedPathId === $publishedPathId) $selectedContext = $context;
    $pathCards[] = $context;
}
if ($selectedPathId > 0 && !$selectedContext) {
    flash('That learning path is not available.', 'error');
    redirect('student-learning-paths.php');
}

$languageMeta = static function (string $title): array {
    $name = strtolower($title);
    if (str_contains($name, 'python')) return ['label'=>'PY', 'class'=>'python', 'language'=>'Python'];
    if (str_contains($name, 'c++')) return ['label'=>'C++', 'class'=>'cpp', 'language'=>'C++'];
    if (preg_match('/\bc programming\b/', $name)) return ['label'=>'C', 'class'=>'c', 'language'=>'C'];
    if (str_contains($name, 'java')) return ['label'=>'JV', 'class'=>'java', 'language'=>'Java'];
    if (str_contains($name, 'php')) return ['label'=>'PHP', 'class'=>'php', 'language'=>'PHP'];
    if (str_contains($name, 'ruby')) return ['label'=>'RB', 'class'=>'ruby', 'language'=>'Ruby'];
    if (str_contains($name, 'html')) return ['label'=>'</>', 'class'=>'html', 'language'=>'HTML & CSS'];
    return ['label'=>'</>', 'class'=>'generic', 'language'=>'Programming'];
};

$baseUrl = rtrim($config['base_url'], '/');
page_header($selectedContext ? $selectedContext['path']['title'] : 'Learning paths');
?>
<?php if (!$selectedContext): ?>
<section class="v22-paths-hero">
  <div class="v22-paths-hero-copy">
    <span class="v22-paths-kicker">STUDENT SPACE · LEARNING PATHS</span>
    <h1>Choose a language.<br><span>Master it step by step.</span></h1>
    <p>Pick a learning path to open its full curriculum. Each step stays locked until you pass the previous step with a perfect score.</p>
    <div class="v22-paths-hero-points"><span>✓ 7 guided paths</span><span>✓ 30 steps per path</span><span>✓ Hidden tests protect progression</span></div>
  </div>
  <div class="v22-paths-hero-art" aria-hidden="true"><div class="v22-code-window"><div class="v22-code-window-bar"><i></i><i></i><i></i><span>learning.py</span></div><pre><b>def</b> <em>learn</em>(step):
    <b>if</b> step.passed:
        <b>return</b> <strong>next_step</strong>()
    <b>return</b> <strong>keep_practicing</strong>()</pre><div class="v22-code-window-foot"><span>●</span> One step at a time</div></div></div>
</section>
<div class="v22-paths-section-heading"><div><span class="v22-paths-kicker">YOUR CURRICULUM</span><h2>Explore learning paths</h2><p>Select a language to view its complete 30-step progression.</p></div><span class="v22-path-count"><?= count($pathCards) ?> paths available</span></div>
<?php if (!$pathCards): ?>
  <div class="empty"><div class="empty-symbol">⌘</div><h3>No published learning paths yet</h3><p>Your teacher can publish a sequence of exercises from Teacher Studio.</p><a class="button" href="<?= e($baseUrl) ?>/index.php#practice">Browse practice challenges</a></div>
<?php else: ?>
  <div class="v22-language-path-grid">
  <?php foreach ($pathCards as $card): $path=$card['path']; $meta=$languageMeta((string)$path['title']); $progress=(int)$card['progress']; ?>
    <a class="v22-language-path-card" href="<?= e($baseUrl) ?>/student-learning-paths.php?path_id=<?= (int)$path['id'] ?>">
      <div class="v22-language-card-top"><span class="v22-language-mark <?= e($meta['class']) ?>"><?= e($meta['label']) ?></span><span class="v22-language-arrow" aria-hidden="true">↗</span></div>
      <span class="v22-language-card-label"><?= e($meta['language']) ?> LEARNING PATH</span>
      <h3><?= e($path['title']) ?></h3>
      <p><?= e($path['description'] ?: 'A guided sequence of programming activities, from fundamentals to problem solving.') ?></p>
      <div class="v22-language-card-meta"><span><span aria-hidden="true" class="v22-meta-glyph">▤</span> <?= (int)$card['total_count'] ?> steps</span><span><?= (int)$card['completed_count'] ?> completed</span></div>
      <div class="v22-language-progress"><span style="width:<?= $progress ?>%"></span></div>
      <div class="v22-language-card-footer"><span><?= $progress ?>% progress</span><strong>Open learning path <span aria-hidden="true">→</span></strong></div>
    </a>
  <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php else: $path=$selectedContext['path']; $meta=$languageMeta((string)$path['title']); $allDone=$selectedContext['total_count']>0 && $selectedContext['completed_count']===$selectedContext['total_count']; ?>
<section class="v22-path-detail-hero">
  <a class="v22-back-to-paths" href="<?= e($baseUrl) ?>/student-learning-paths.php">← All learning paths</a>
  <div class="v22-path-detail-main">
    <span class="v22-language-mark large <?= e($meta['class']) ?>"><?= e($meta['label']) ?></span>
    <div><span class="v22-paths-kicker"><?= e($meta['language']) ?> · GUIDED CURRICULUM</span><h1><?= e($path['title']) ?></h1><p><?= e($path['description'] ?: 'Work through each challenge in order. Pass every hidden and public test before moving to the next step.') ?></p><div class="v22-path-teacher-line">Created by <?= e($path['teacher_name']) ?></div></div>
  </div>
  <div class="v22-path-progress-panel"><div class="v22-path-progress-copy"><div><strong>Your progress</strong><small><?= $allDone ? 'Path completed. You can review any finished step.' : 'Complete every test in the current step to unlock the next one.' ?></small></div><b><?= (int)$selectedContext['completed_count'] ?> <span>/ <?= (int)$selectedContext['total_count'] ?></span></b></div><div class="v22-language-progress wide"><span style="width:<?= (int)$selectedContext['progress'] ?>%"></span></div><div class="v22-path-progress-bottom"><span><?= (int)$selectedContext['progress'] ?>% complete</span><span><?= (int)$selectedContext['total_count'] ?> steps</span></div></div>
</section>
<?php if (!$selectedContext['total_count']): ?>
  <div class="empty"><h3>No available steps in this path yet</h3><p>Your teacher may need to publish the exercises included in this curriculum.</p></div>
<?php else: ?>
  <?php if ($allDone): ?><div class="v22-path-complete-banner"><span class="v22-path-complete-icon">✓</span><div><strong>Congratulations! You completed this learning path.</strong><p>Every step is complete. You can reopen any step to review it.</p></div></div><?php endif; ?>
  <div class="v22-step-list">
  <?php foreach ($selectedContext['items'] as $item):
      $position=(int)$item['position'];
      $locked=empty($item['unlocked']);
      $assignmentAccessAllowed=!empty($item['exercise_available']);
      if ((int)$item['has_assignment']===1 && $assignmentAccessAllowed) {
          $accessContext=student_exercise_access_context($pdo,(int)$user['id'],(int)$item['id']);
          $assignmentAccessAllowed=(bool)$accessContext['allowed'];
      }
      $openable=!$locked && $assignmentAccessAllowed;
      $url=(int)$item['has_assignment']===1
          ? $baseUrl.'/exercise.php?id='.(int)$item['id'].'&path_id='.(int)$path['id']
          : $baseUrl.'/practice.php?id='.(int)$item['id'].'&path_id='.(int)$path['id'];
      if ($item['completed']) { $statusClass='complete'; $statusText='Completed'; $numberText='✓'; }
      elseif (empty($item['exercise_available'])) { $statusClass='locked'; $statusText='Unavailable'; $numberText='🔒'; }
      elseif (!$assignmentAccessAllowed) { $statusClass='locked'; $statusText='Join assigned class'; $numberText='🔒'; }
      elseif ($locked) { $statusClass='locked'; $statusText='Locked'; $numberText='🔒'; }
      else { $statusClass='available'; $statusText='Available now'; $numberText=sprintf('%02d',$position); }
  ?>
    <article class="v22-learning-step <?= e($statusClass) ?>">
      <div class="v22-step-number <?= e($statusClass) ?>"><?= e($numberText) ?></div>
      <div class="v22-step-copy"><div class="v22-step-eyebrow">STEP <?= sprintf('%02d',$position) ?> OF <?= sprintf('%02d',(int)$selectedContext['total_count']) ?></div><h3><?= e($item['title']) ?></h3><p><?= e($item['topic'] ?: 'Programming fundamentals') ?> <span>·</span> <?= e($item['difficulty']) ?> <span>·</span> <?= (int)ceil((int)$item['time_limit_seconds']/60) ?> min <span>·</span> <?= (int)$item['points'] ?> points</p><?php if (empty($item['exercise_available']) && !$item['completed']): ?><small class="v22-step-lock-hint">This exercise is unpublished. Ask your teacher to republish it.</small><?php elseif ($locked && !$item['completed'] && $assignmentAccessAllowed): ?><small class="v22-step-lock-hint">Complete step <?= max(1,$position-1) ?> with a perfect score to unlock this challenge.</small><?php elseif (!$assignmentAccessAllowed): ?><small class="v22-step-lock-hint">Join the classroom assigned this challenge before continuing.</small><?php elseif ($item['completed']): ?><small class="v22-step-completed-hint">Perfect score recorded. This step is permanently completed.</small><?php endif; ?></div>
      <div class="v22-step-actions"><span class="v22-step-status <?= e($statusClass) ?>"><?= e($statusText) ?></span><?php if ($openable): ?><a class="button small <?= $item['completed']?'secondary':'' ?>" href="<?= e($url) ?>"><?= $item['completed']?'Review':'Start step' ?> <span aria-hidden="true">→</span></a><?php elseif (!empty($item['exercise_available']) && !$assignmentAccessAllowed): ?><a class="button small secondary" href="<?= e($baseUrl) ?>/student-classrooms.php">My classes →</a><?php else: ?><button class="button small secondary" type="button" disabled aria-disabled="true">🔒 Locked</button><?php endif; ?></div>
    </article>
  <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php endif; ?>
<?php page_footer(); ?>
