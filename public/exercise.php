<?php
header('Cache-Control: no-store, private');
header('Pragma: no-cache');
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
require_once __DIR__ . '/../app/learning_paths.php';
$user = require_role(['student']);
$id = (int)($_GET['id'] ?? 0);
$pathId = max(0, (int)($_GET['path_id'] ?? $_POST['path_id'] ?? 0));
if ($pathId > 0) {
    $pathGate = ca_assert_learning_path_step_unlocked($pdo, (int)$user['id'], $pathId, $id);
    if (!$pathGate['ok']) {
        flash($pathGate['reason'], 'error');
        redirect('student-learning-paths.php?path_id=' . $pathId);
    }
} else {
    $linkedPathId = ca_find_published_path_for_exercise($pdo, $id);
    if ($linkedPathId !== null) {
        flash('This challenge is part of a learning path. Open it from Learning Paths so the steps stay in order.', 'info');
        redirect('student-learning-paths.php?path_id=' . $linkedPathId);
    }
}
$stmt = $pdo->prepare('SELECT * FROM exercises WHERE id = ? AND (is_published = 1 OR EXISTS (SELECT 1 FROM attempts ax WHERE ax.exercise_id = exercises.id AND ax.user_id = ? AND ax.started_explicitly = 1))');
$stmt->execute([$id, (int)$user['id']]);
$exercise = $stmt->fetch();
if (!$exercise) { http_response_code(404); exit('Exercise not found.'); }

$accessContext = student_exercise_access_context($pdo, (int)$user['id'], $id);
if (!$accessContext['allowed']) {
    flash($accessContext['restricted'] ? 'This exercise is assigned to a classroom you have not joined, or its deadline has passed.' : 'This exercise is not available.', 'error');
    redirect('student-classrooms.php');
}
if (!$accessContext['restricted']) {
    // Public or removed assignments are practice-only; do not allow a direct URL to start an official timed attempt.
    redirect('practice.php?id=' . $id);
}

$exerciseMonitoringEnabled = (int)($exercise['monitoring_enabled'] ?? 0) === 1;
$exerciseWarningThreshold = max(1, min(10, (int)($exercise['warning_threshold'] ?? 3)));
$attemptStmt = $pdo->prepare('SELECT * FROM attempts WHERE user_id = ? AND exercise_id = ?');
$attemptStmt->execute([(int)$user['id'], $id]);
$attempt = $attemptStmt->fetch();
$attemptSnapshot = null;
// Older builds allowed a submission before the explicit-start flag existed. Preserve
// those real attempts and their scores instead of treating them like untouched attempts
// and resetting their timer/score when the new Start Exercise gate is introduced.
if ($attempt && (int)($attempt['started_explicitly'] ?? 0) !== 1 && (int)($attempt['retake_pending'] ?? 0) !== 1) {
    $legacySubmissionStmt = $pdo->prepare('SELECT COUNT(*) FROM submissions WHERE user_id=? AND exercise_id=?');
    $legacySubmissionStmt->execute([(int)$user['id'], $id]);
    if ((int)$legacySubmissionStmt->fetchColumn() > 0) {
        try {
            $legacyVersionId = store_exercise_version($pdo, $id, (int)$exercise['created_by'], 'Legacy submitted attempt baseline', (int)$user['id']);
            $promote = $pdo->prepare('UPDATE attempts SET started_explicitly=1, exercise_version_id=? WHERE id=? AND user_id=? AND started_explicitly=0');
            $promote->execute([$legacyVersionId, (int)$attempt['id'], (int)$user['id']]);
            $attemptStmt->execute([(int)$user['id'], $id]);
            $attempt = $attemptStmt->fetch();
            audit_log($pdo, (int)$user['id'], 'legacy_attempt_preserved', 'attempt', (int)$attempt['id'], ['exercise_id'=>$id,'reason'=>'Existing submission history preserved during explicit-start upgrade']);
        } catch (Throwable $legacyError) {
            error_log('Could not preserve legacy CodeArena attempt: ' . $legacyError->getMessage());
            http_response_code(500);
            exit('Could not safely load this existing attempt. Please contact your teacher before continuing.');
        }
    }
}
if ($attempt && (int)($attempt['started_explicitly'] ?? 0) === 1) {
    try {
        [$attempt, $attemptSnapshot] = ensure_attempt_exercise_version($pdo, $attempt, $id, (int)$exercise['created_by']);
        $exercise = array_merge($exercise, $attemptSnapshot['exercise']);
    } catch (Throwable $snapshotError) {
        error_log('Could not load CodeArena attempt version: ' . $snapshotError->getMessage());
        http_response_code(500);
        exit('This attempt version is unavailable. Please contact your teacher before continuing.');
    }
}

// A perfect best score completes the attempt permanently and stops its timer.
// This check happens before the legacy-start handling so old perfect attempts remain completed.
if ($attempt && (int)($attempt['best_score'] ?? 0) >= (int)$exercise['points']) {
    if (($attempt['status'] ?? '') !== 'submitted' || empty($attempt['completed_at'])) {
        $pdo->prepare("UPDATE attempts SET status = 'submitted', completed_at = COALESCE(completed_at, CURRENT_TIMESTAMP) WHERE id = ? AND user_id = ?")
            ->execute([(int)$attempt['id'], (int)$user['id']]);
    }
    $nextExerciseUrl = student_next_incomplete_exercise_url($pdo, (int)$user['id'], $id);
    $doneUrl = student_exercise_done_url($pdo, (int)$user['id'], $id);
    if ($pathId > 0) {
        $pathReturnUrl = rtrim($config['base_url'], '/') . '/student-learning-paths.php?path_id=' . $pathId;
        $doneUrl = $pathReturnUrl;
        $nextExerciseUrl = $pathReturnUrl;
    }
    page_header($exercise['title'] . ' · Completed');
    ?>
    <div class="work-head work-head-v2 completion-work-head">
      <div class="work-title-block">
        <a class="back" href="<?= e($doneUrl) ?>">← Back</a>
        <div class="work-title-meta"><span class="difficulty easy">COMPLETED</span><span class="editor-meta-dot"></span><span><?= (int)$exercise['points'] ?> points</span></div>
        <h1><?= e($exercise['title']) ?></h1>
      </div>
      <div class="timer-box timer-box-v2 timer-perfect"><span>ATTEMPT STATUS</span><strong>COMPLETED</strong><span class="timer-caption">Perfect score · timer stopped</span></div>
    </div>
    <section class="completion-stage completion-stage-server" aria-live="polite">
      <article class="completion-card is-perfect">
        <div class="completion-trophy" aria-hidden="true">🏆</div>
        <span class="completion-label">PERFECT SCORE</span>
        <h2>Congratulations!</h2>
        <p class="completion-intro">You got every test case right. This exercise is complete, and your timer has stopped.</p>
        <div class="completion-score"><strong><?= (int)$exercise['points'] ?></strong><span>/ <?= (int)$exercise['points'] ?> points</span></div>
        <div class="completion-meta"><span>✓ All test cases passed</span><span>✓ Attempt completed</span></div>
        <div class="completion-actions">
          <a class="button completion-done" href="<?= e($doneUrl) ?>">Done</a>
          <?php if ($nextExerciseUrl): ?><a class="button completion-next" href="<?= e($nextExerciseUrl) ?>"><?= $pathId > 0 ? 'Continue learning path' : 'Continue to next exercise' ?> <span aria-hidden="true">→</span></a><?php endif; ?>
        </div>
        <?php if (!$nextExerciseUrl): ?><p class="completion-note">You've completed all currently available exercises with a perfect score. Great work!</p><?php endif; ?>
      </article>
    </section>
    <script src="<?= e($config['base_url']) ?>/assets/confetti.js"></script>
    <script>window.addEventListener('DOMContentLoaded', function () { if (window.CodeArenaConfetti) CodeArenaConfetti.launchOnce(<?= json_encode('codearena:perfect:' . (int)$user['id'] . ':' . $id) ?>); });</script>
    <?php
    page_footer();
    exit;
}

// Starting is an explicit POST action. A plain GET never creates an attempt or exposes the problem statement.
if ((!$attempt || (int)($attempt['started_explicitly'] ?? 0) !== 1) && $_SERVER['REQUEST_METHOD'] === 'POST') {
    if (($_POST['action'] ?? '') !== 'start_attempt') {
        http_response_code(405);
        exit('Use the Start Exercise button to begin this attempt.');
    }
    verify_csrf();
    $now = new DateTimeImmutable('now');
    $deadline = $now->modify('+' . (int)$exercise['time_limit_seconds'] . ' seconds');
    if (!empty($accessContext['due_at'])) {
        $assignmentDeadline = new DateTimeImmutable((string)$accessContext['due_at']);
        if ($assignmentDeadline < $deadline) $deadline = $assignmentDeadline;
    }
    if ($deadline <= $now) {
        flash('The assignment deadline has passed.', 'error');
        redirect('student-classrooms.php');
    }
    try {
        $exerciseVersionId = store_exercise_version($pdo, $id, (int)$exercise['created_by'], 'Attempt baseline', (int)$user['id']);
    } catch (Throwable $versionError) {
        error_log('Could not snapshot CodeArena exercise at attempt start: ' . $versionError->getMessage());
        flash('Could not prepare this exercise safely. Ask your teacher to save it again.', 'error');
        redirect('student-classrooms.php');
    }
    try {
        if ($attempt && (int)($attempt['started_explicitly'] ?? 0) !== 1) {
            // Legacy auto-created attempts with no saved submissions are safely restarted on explicit confirmation.
            $restart = $pdo->prepare("UPDATE attempts SET started_at=?, deadline_at=?, completed_at=NULL, best_score=0, status='in_progress', monitoring_enabled=?, warning_threshold=?, started_explicitly=1, retake_pending=0, exercise_version_id=? WHERE id=? AND user_id=? AND exercise_id=? AND started_explicitly=0");
            $restart->execute([$now->format('Y-m-d H:i:s'), $deadline->format('Y-m-d H:i:s'), $exerciseMonitoringEnabled ? 1 : 0, $exerciseWarningThreshold, $exerciseVersionId, (int)$attempt['id'], (int)$user['id'], $id]);
            if ($restart->rowCount() !== 1) {
                $attemptStmt->execute([(int)$user['id'], $id]);
                $latest = $attemptStmt->fetch();
                if (!$latest || (int)($latest['started_explicitly'] ?? 0) !== 1) {
                    flash('Could not start this exercise. Please refresh and try again.', 'error');
                    redirect('student-classrooms.php');
                }
            }
        } else {
            $insert = $pdo->prepare('INSERT INTO attempts(user_id, exercise_id, exercise_version_id, started_at, deadline_at, monitoring_enabled, warning_threshold, started_explicitly) VALUES(?, ?, ?, ?, ?, ?, ?, 1)');
            $insert->execute([(int)$user['id'], $id, $exerciseVersionId, $now->format('Y-m-d H:i:s'), $deadline->format('Y-m-d H:i:s'), $exerciseMonitoringEnabled ? 1 : 0, $exerciseWarningThreshold]);
        }
    } catch (PDOException $exception) {
        // A second request in another tab may have started the unique attempt first.
        $attemptStmt->execute([(int)$user['id'], $id]);
        $latest = $attemptStmt->fetch();
        if (!$latest || (int)($latest['started_explicitly'] ?? 0) !== 1) {
            flash('Could not start this exercise. Please refresh and try again.', 'error');
            redirect('student-classrooms.php');
        }
    }
    $auditAttemptStmt = $pdo->prepare('SELECT id FROM attempts WHERE user_id=? AND exercise_id=?');
    $auditAttemptStmt->execute([(int)$user['id'], $id]);
    $auditAttemptId = (int)$auditAttemptStmt->fetchColumn();
    audit_log($pdo, (int)$user['id'], 'attempt_started', 'attempt', $auditAttemptId, ['exercise_id'=>$id,'monitoring_enabled'=>$exerciseMonitoringEnabled]);
    redirect('exercise.php?id=' . $id . ($pathId > 0 ? '&path_id=' . $pathId : ''));
}

if (!$attempt || (int)($attempt['started_explicitly'] ?? 0) !== 1) {
    if (!empty($accessContext['due_at']) && strtotime((string)$accessContext['due_at']) <= time()) {
        flash('The assignment deadline has passed.', 'error');
        redirect('student-classrooms.php');
    }
    page_header($exercise['title']);
    ?>
    <div class="exercise-start-wrap">
      <a class="back" href="<?= e($config['base_url']) ?>/<?= e($pathId > 0 ? 'student-learning-paths.php?path_id=' . $pathId : 'index.php#practice') ?>">← <?= $pathId > 0 ? 'Back to learning path' : 'Back to challenges' ?></a>
      <section class="panel exercise-start-card">
        <div class="exercise-start-icon" aria-hidden="true">&lt;/&gt;</div>
        <p class="eyebrow">READY TO BEGIN?</p>
        <h1><?= e($exercise['title']) ?></h1>
        <p class="muted exercise-start-intro">Review the challenge details below. The instructions, examples, and coding workspace become available after you start.</p>
        <div class="exercise-start-meta">
          <div><span>Time limit</span><strong><?= max(1, (int)ceil((int)$exercise['time_limit_seconds'] / 60)) ?> minutes</strong></div>
          <div><span>Total points</span><strong><?= (int)$exercise['points'] ?> points</strong></div>
        </div>
        <p class="exercise-start-note">Your timer begins when you select Start Exercise. Once started, the deadline continues even if you leave this page.</p>
        <form method="post" action="<?= e($config['base_url']) ?>/exercise.php?id=<?= $id ?><?= $pathId > 0 ? '&path_id=' . $pathId : '' ?>" class="exercise-start-form">
          <input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
          <input type="hidden" name="action" value="start_attempt">
          <button class="button" type="submit">Start Exercise <span aria-hidden="true">→</span></button>
        </form>
      </section>
    </div>
    <?php
    page_footer();
    exit;
}

$pathRequiredLanguage = null;
if ($pathId > 0 && preg_match('/^ca-(python|cpp|c|java|php|ruby)-path-/', (string)($exercise['slug'] ?? ''), $pathLanguageMatch)) {
    $pathRequiredLanguage = $pathLanguageMatch[1];
}
$effectiveDeadlineTs = strtotime((string)$attempt['deadline_at']);
if (!empty($accessContext['due_at'])) $effectiveDeadlineTs = min($effectiveDeadlineTs, strtotime((string)$accessContext['due_at']));
$monitoringEnabled = (int)($attempt['monitoring_enabled'] ?? 0) === 1;
$warningThreshold = max(1, min(10, (int)($attempt['warning_threshold'] ?? 3)));
$samples = [];
if (is_array($attemptSnapshot) && is_array($attemptSnapshot['test_cases'] ?? null)) {
    foreach ($attemptSnapshot['test_cases'] as $case) {
        if ((int)($case['is_sample'] ?? 0) === 1 && count($samples) < 5) $samples[] = ['stdin'=>(string)$case['stdin'], 'expected_output'=>(string)$case['expected_output']];
    }
} else {
    $sampleStmt = $pdo->prepare('SELECT stdin, expected_output FROM test_cases WHERE exercise_id = ? AND is_sample = 1 ORDER BY sort_order, id LIMIT 5');
    $sampleStmt->execute([$id]);
    $samples = $sampleStmt->fetchAll();
}
$historyStmt = $pdo->prepare('SELECT id, language, score, passed_tests, total_tests, created_at FROM submissions WHERE user_id = ? AND exercise_id = ? ORDER BY id DESC LIMIT 5');
$historyStmt->execute([(int)$user['id'], $id]);
$history = $historyStmt->fetchAll();
$left = max(0, $effectiveDeadlineTs - time());
$activeAttempt = ($attempt['status'] ?? '') === 'in_progress' && $left > 0;
$load_codemirror = true;
page_header($exercise['title']);
?>
<div class="work-head work-head-v2">
  <div class="work-title-block">
    <a class="back" href="<?= e($config['base_url']) ?>/index.php">← All exercises</a>
    <div class="work-title-meta"><span class="difficulty <?= strtolower(e($exercise['difficulty'])) ?>"><?= e($exercise['difficulty']) ?></span><span class="editor-meta-dot"></span><span><?= (int)$exercise['points'] ?> points</span><span class="editor-meta-dot"></span><span><?= max(1, (int)ceil((int)$exercise['time_limit_seconds'] / 60)) ?> min limit</span></div>
    <h1><?= e($exercise['title']) ?></h1>
  </div>
  <div class="timer-box timer-box-v2"><span class="muted">TIME REMAINING</span><strong id="timer" data-seconds="<?= $left ?>" data-deadline-ms="<?= $effectiveDeadlineTs * 1000 ?>">--:--</strong><span class="timer-caption" id="timerCaption"><?= $activeAttempt ? 'Attempt in progress' : 'Attempt ended' ?></span></div>
</div>
<!-- Monitoring settings, banners, and reports are teacher-only. -->

<section class="completion-stage completion-stage-live" id="completionStage" hidden aria-live="polite">
  <article class="completion-card is-perfect" id="completionCard">
    <div class="completion-trophy" aria-hidden="true">🏆</div>
    <span class="completion-label" id="completionLabel">PERFECT SCORE</span>
    <h2 id="completionHeadline">Congratulations!</h2>
    <p class="completion-intro" id="completionIntro">You got every test case right. This exercise is complete, and your timer has stopped.</p>
    <div class="completion-score"><strong id="completionScore">0</strong><span>/ <span id="completionMaxScore">0</span> points</span></div>
    <div class="completion-meta"><span id="completionTests">✓ All test cases passed</span><span>✓ Attempt completed</span></div>
    <div class="completion-actions">
      <a class="button completion-done" id="completionDoneBtn" hidden>Done</a>
      <a class="button completion-next" id="completionNextBtn" hidden>Continue to next exercise <span aria-hidden="true">→</span></a>
    </div>
    <p class="completion-note" id="completionNote" hidden>You've completed all currently available exercises with a perfect score. Great work!</p>
  </article>
</section>

<div class="workspace workspace-v2" id="codingWorkspace">
  <section class="panel problem problem-v2">
    <div class="problem-heading"><span class="section-icon">{ }</span><div><p class="eyebrow">CHALLENGE BRIEF</p><h2>Problem</h2></div></div>
    <div class="prose"><?= nl2br(e($exercise['description'])) ?></div>
    <div class="problem-stats"><div><span>Difficulty</span><strong><?= e($exercise['difficulty']) ?></strong></div><div><span>Maximum score</span><strong><?= (int)$exercise['points'] ?> pts</strong></div></div>
    <?php if (!empty($exercise['hint_text'])): ?><details class="v23-exercise-hint"><summary>Need a hint?</summary><div><?= nl2br(e((string)$exercise['hint_text'])) ?></div></details><?php endif; ?>
    <div class="sample-box sample-box-v2"><div class="subsection-heading"><h3>Sample test cases</h3><span class="muted"><?= count($samples) ?> public sample<?= count($samples) === 1 ? '' : 's' ?></span></div>
    <?php foreach ($samples as $index => $sample): ?><div class="sample sample-v2"><div class="sample-title"><b>Sample <?= $index + 1 ?></b><span>Public</span></div><label>Input</label><pre><?= e($sample['stdin']) ?></pre><label>Expected output</label><pre><?= e($sample['expected_output']) ?></pre></div><?php endforeach; ?>
    <?php if (!$samples): ?><p class="muted sample-empty">No public samples were provided. Run Code lets you enter your own input.</p><?php endif; ?>
    </div>
    <div class="workspace-tip"><span>✦</span><p><strong>Tip</strong> Run your code with sample input first. Submit Answer checks all public and hidden test cases and records your grade.</p></div>
  </section>

  <section class="panel editor-panel editor-panel-v2">
    <form id="submitForm" method="post" action="<?= e($config['base_url']) ?>/submit.php" data-user-id="<?= (int)$user['id'] ?>" data-exercise-id="<?= $id ?>" data-path-id="<?= $pathId ?>" data-active-attempt="<?= $activeAttempt ? '1' : '0' ?>">
      <input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
      <input type="hidden" name="exercise_id" value="<?= $id ?>">
      <input type="hidden" name="path_id" value="<?= $pathId ?>">
      <div class="coding-panel-head">
        <div><p class="eyebrow">WORKSPACE</p><h2>Code editor</h2></div>
        <div class="coding-head-actions"><label class="language-select">Language<select name="language" id="language"><?php if ($pathRequiredLanguage): ?><option value="<?= e($pathRequiredLanguage) ?>" selected><?= e($pathRequiredLanguage === 'cpp' ? 'C++' : ($pathRequiredLanguage === 'python' ? 'Python 3' : strtoupper($pathRequiredLanguage))) ?> · required for this path</option><?php else: ?><option value="python">Python 3</option><option value="cpp">C++</option><option value="c">C</option><option value="java">Java</option><option value="php">PHP</option><option value="ruby">Ruby</option><option value="html">HTML/CSS preview</option><?php endif; ?></select></label><button type="button" class="focus-mode-button" id="focusModeBtn" aria-pressed="false">⛶ Focus mode</button></div>
      </div>
      <div class="editor-statusbar"><span><i class="editor-live-dot"></i><span id="editorStatus">Editor ready</span></span><span id="editorLanguage">PYTHON 3</span><span class="editor-shortcut">⌘/Ctrl + Enter to run</span></div>
      <div class="code-editor-shell" id="codeEditorShell"><textarea class="code" name="source_code" id="source_code" spellcheck="false" autocapitalize="off" autocomplete="off" autocorrect="off" aria-label="Source code editor"><?= e($exercise['starter_code'] ?? '') ?></textarea></div>
      <div class="editor-bottomline"><span>Indentation: 4 spaces</span><span>Autosaves this draft in your browser</span><button type="button" class="editor-text-button" id="resetCodeBtn">Reset code</button></div>
      <div class="editor-actions editor-actions-v2"><div class="editor-primary-actions"><button class="button run-button" id="runBtn" type="button" <?= !$activeAttempt ? 'disabled' : '' ?>><span aria-hidden="true">▶</span> Run Code</button><button class="button submit-answer-button" id="submitBtn" type="submit" <?= !$activeAttempt ? 'disabled' : '' ?>>Submit Answer <span aria-hidden="true">↗</span></button></div><span class="muted" id="submitHint"><?= $activeAttempt ? 'Run does not affect your grade.' : 'This attempt has ended.' ?></span></div>
    </form>

    <div id="previewWrap" class="preview-wrap preview-wrap-v2" hidden><div class="subsection-heading"><h3>HTML/CSS preview</h3><span class="muted">Sandboxed preview</span></div><iframe id="preview" sandbox="" title="HTML and CSS preview"></iframe><p class="field-hint">This preview runs only in your browser and is not automatically graded.</p></div>

    <section class="coding-console" aria-label="Code console">
      <div class="console-header"><div class="console-tabs" role="tablist" aria-label="Console panels"><button type="button" class="console-tab active" data-console-tab="input" role="tab" aria-selected="true">Input</button><button type="button" class="console-tab" data-console-tab="output" role="tab" aria-selected="false">Output</button><button type="button" class="console-tab" data-console-tab="tests" role="tab" aria-selected="false">Test results <span class="console-count" id="testCount">0</span></button></div><span class="console-caption" id="consoleCaption">Standard input (stdin)</span></div>
      <div class="console-pane" id="consoleInputPane"><div class="console-pane-label"><label for="stdin">Standard input</label><select id="sampleSelect" aria-label="Load sample input"><option value="custom">Custom input</option><?php foreach ($samples as $index => $sample): ?><option value="<?= $index ?>">Load sample <?= $index + 1 ?></option><?php endforeach; ?></select></div><textarea id="stdin" rows="4" spellcheck="false" placeholder="Enter input your program should read..."></textarea><p class="field-hint">This input is sent to the program when you choose Run Code.</p></div>
      <div class="console-pane" id="consoleOutputPane" hidden><div class="console-pane-label"><strong>Program output</strong><span class="output-status" id="outputStatus">Waiting for a run</span></div><pre class="console-output" id="runOutput">Run your code to see the output here.</pre><div class="console-metrics" id="runMetrics"></div></div>
      <div class="console-pane" id="consoleTestsPane" hidden><div id="testSummary" class="test-summary empty-test-summary"><span class="test-summary-icon">◎</span><div><strong>No submission yet</strong><p>Submit Answer to run every public and hidden test case.</p></div></div><div id="testResults" class="test-results-list"></div></div>
    </section>

    <?php if ($history): ?><section class="submission-history"><div class="subsection-heading"><h3>Recent submissions</h3><span class="muted">Latest 5 attempts</span></div><div class="table-wrap"><table><thead><tr><th>Language</th><th>Score</th><th>Tests passed</th><th>Submitted</th></tr></thead><tbody id="historyBody"><?php foreach ($history as $submission): ?><tr><td><?= e(strtoupper((string)$submission['language'])) ?></td><td><strong><?= (int)$submission['score'] ?></strong></td><td><?= (int)$submission['passed_tests'] ?>/<?= (int)$submission['total_tests'] ?></td><td><?= e($submission['created_at']) ?></td></tr><?php endforeach; ?></tbody></table></div></section><?php else: ?><section class="submission-history" id="emptyHistory"><div class="subsection-heading"><h3>Recent submissions</h3><span class="muted">Your results will appear here</span></div><div class="history-empty"><span>↗</span><p>No submissions yet. Run your code, then submit when you're ready.</p></div><div class="table-wrap" id="historyTableWrap" hidden><table><thead><tr><th>Language</th><th>Score</th><th>Tests passed</th><th>Submitted</th></tr></thead><tbody id="historyBody"></tbody></table></div></section><?php endif; ?>
  </section>
</div>

<script src="<?= e($config['base_url']) ?>/assets/confetti.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/edit/matchbrackets.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/edit/closebrackets.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/xml/xml.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/javascript/javascript.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/css/css.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/htmlmixed/htmlmixed.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/clike/clike.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/python/python.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/php/php.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/ruby/ruby.min.js"></script>
<script>
(() => {
  'use strict';
  const form = document.getElementById('submitForm');
  const textarea = document.getElementById('source_code');
  const language = document.getElementById('language');
  const runButton = document.getElementById('runBtn');
  const submitButton = document.getElementById('submitBtn');
  const previewWrap = document.getElementById('previewWrap');
  const preview = document.getElementById('preview');
  const stdin = document.getElementById('stdin');
  const sampleSelect = document.getElementById('sampleSelect');
  const consoleCaption = document.getElementById('consoleCaption');
  const outputStatus = document.getElementById('outputStatus');
  const output = document.getElementById('runOutput');
  const metrics = document.getElementById('runMetrics');
  const testSummary = document.getElementById('testSummary');
  const testResults = document.getElementById('testResults');
  const testCount = document.getElementById('testCount');
  const editorStatus = document.getElementById('editorStatus');
  const timer = document.getElementById('timer');
  const focusModeBtn = document.getElementById('focusModeBtn');
  const baseUrl = <?= json_encode(rtrim($config['base_url'], '/'), JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT) ?>;
  const sampleCases = <?= json_encode(array_map(static fn(array $sample): array => ['stdin' => (string)$sample['stdin'], 'expected_output' => (string)$sample['expected_output']], $samples), JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE) ?>;
  const monitoringEnabled = <?= $monitoringEnabled ? 'true' : 'false' ?>;
  const originalCode = textarea.value;
  const userId = form.dataset.userId;
  const exerciseId = form.dataset.exerciseId;
  let seconds = Number(timer.dataset.seconds || 0);
  let timerStopped = false;
  const deadlineMs = Number(timer.dataset.deadlineMs || 0);
  let editor = null;
  let runSequence = 0;
  const langInfo = {
    python: {label:'Python 3', badge:'PYTHON 3', mode:'python'},
    cpp: {label:'C++', badge:'C++', mode:'text/x-c++src'},
    c: {label:'C', badge:'C', mode:'text/x-csrc'},
    java: {label:'Java', badge:'JAVA', mode:'text/x-java'},
    php: {label:'PHP', badge:'PHP', mode:'application/x-httpd-php'},
    ruby: {label:'Ruby', badge:'RUBY', mode:'text/x-ruby'},
    html: {label:'HTML/CSS preview', badge:'HTML / CSS', mode:'htmlmixed'}
  };
  const draftKey = () => 'codearena:draft:' + userId + ':' + exerciseId + ':' + language.value;

  function getCode() { return editor ? editor.getValue() : textarea.value; }
  function setCode(value) {
    if (editor) editor.setValue(value);
    else textarea.value = value;
  }
  function saveCodeToForm() { if (editor) editor.save(); }
  function setEditorStatus(text) { editorStatus.textContent = text; }

  // CodeMirror enhances the textarea when the CDN is reachable; the textarea remains a working fallback offline.
  if (window.CodeMirror) {
    editor = CodeMirror.fromTextArea(textarea, {
      lineNumbers: true,
      indentUnit: 4,
      tabSize: 4,
      indentWithTabs: false,
      lineWrapping: false,
      matchBrackets: true,
      autoCloseBrackets: true,
      mode: langInfo[language.value].mode,
      viewportMargin: 20,
      extraKeys: {
        'Cmd-Enter': () => runCode(),
        'Ctrl-Enter': () => runCode(),
        'Cmd-Shift-Enter': () => submitCode(),
        'Ctrl-Shift-Enter': () => submitCode(),
        Tab: cm => cm.execCommand('insertSoftTab')
      }
    });
    editor.setSize('100%', 400);
    editor.on('change', () => { setEditorStatus('Unsaved changes'); saveDraft(); updatePreview(); });
  } else {
    setEditorStatus('Basic editor mode · CodeMirror CDN unavailable');
    textarea.addEventListener('input', () => { setEditorStatus('Unsaved changes'); saveDraft(); updatePreview(); });
  }

  function saveDraft() {
    try {
      localStorage.setItem(draftKey(), getCode());
      setEditorStatus('Draft saved in this browser');
    } catch (_) { setEditorStatus('Draft autosave unavailable in this browser'); }
  }
  function restoreDraft() {
    try {
      const saved = localStorage.getItem(draftKey());
      if (saved !== null && saved !== originalCode) {
        setCode(saved);
        setEditorStatus('Restored your local draft');
      }
    } catch (_) { /* local storage may be disabled */ }
  }

  function setConsoleTab(name) {
    document.querySelectorAll('[data-console-tab]').forEach(button => {
      const active = button.dataset.consoleTab === name;
      button.classList.toggle('active', active);
      button.setAttribute('aria-selected', active ? 'true' : 'false');
    });
    document.getElementById('consoleInputPane').hidden = name !== 'input';
    document.getElementById('consoleOutputPane').hidden = name !== 'output';
    document.getElementById('consoleTestsPane').hidden = name !== 'tests';
    const captions = {input:'Standard input (stdin)', output:'Latest run output', tests:'Automated test results'};
    consoleCaption.textContent = captions[name] || '';
  }
  document.querySelectorAll('[data-console-tab]').forEach(button => button.addEventListener('click', () => setConsoleTab(button.dataset.consoleTab)));

  sampleSelect.addEventListener('change', () => {
    if (sampleSelect.value !== 'custom') {
      const sample = sampleCases[Number(sampleSelect.value)];
      if (sample) stdin.value = sample.stdin;
      setConsoleTab('input');
    }
  });

  function updateLanguage() {
    const info = langInfo[language.value] || langInfo.python;
    document.getElementById('editorLanguage').textContent = info.badge;
    if (editor) {
      editor.setOption('mode', info.mode);
      editor.refresh();
    }
    const isHtml = language.value === 'html';
    runButton.innerHTML = isHtml ? '<span aria-hidden="true">▷</span> Preview HTML' : '<span aria-hidden="true">▶</span> Run Code';
    submitButton.disabled = isHtml || seconds <= 0 || form.dataset.activeAttempt !== '1';
    document.getElementById('submitHint').textContent = isHtml ? 'HTML/CSS is preview-only and is not graded.' : (seconds <= 0 ? 'This attempt has ended.' : 'Run does not affect your grade.');
    if (isHtml) { previewWrap.hidden = false; updatePreview(); } else { previewWrap.hidden = true; }
  }
  function updatePreview() {
    if (language.value === 'html' && preview) preview.srcdoc = getCode();
  }
  language.addEventListener('change', () => { updateLanguage(); setEditorStatus('Language changed'); });

  let wasFullscreen = Boolean(document.fullscreenElement);
  function syncFocusModeButton() {
    const active = Boolean(document.fullscreenElement);
    focusModeBtn.textContent = active ? '⤢ Exit focus mode' : '⛶ Focus mode';
    focusModeBtn.setAttribute('aria-pressed', active ? 'true' : 'false');
  }
  focusModeBtn.addEventListener('click', async () => {
    try {
      if (document.fullscreenElement) await document.exitFullscreen();
      else if (document.documentElement.requestFullscreen) await document.documentElement.requestFullscreen({navigationUI:'hide'});
      else throw new Error('Fullscreen mode is not supported by this browser.');
    } catch (_) {
      const message = 'This browser could not enter fullscreen mode. You can continue coding normally.';
      document.getElementById('submitHint').textContent = message;
    }
  });
  document.addEventListener('fullscreenchange', () => { syncFocusModeButton(); });

  document.getElementById('resetCodeBtn').addEventListener('click', () => {
    if (!window.confirm('Reset the editor to the original starter code? Your current local draft for this language will be deleted.')) return;
    try { localStorage.removeItem(draftKey()); } catch (_) { /* ignore */ }
    setCode(originalCode);
    setEditorStatus('Starter code restored');
    updatePreview();
  });

  function escapeText(value) { return String(value ?? ''); }
  async function readJson(response) {
    const raw = await response.text();
    let data;
    try { data = JSON.parse(raw); }
    catch (_) { throw new Error(raw.trim() || 'The server returned an unreadable response. Refresh the page and try again.'); }
    if (!response.ok) throw new Error(data.error || ('Request failed with HTTP ' + response.status));
    return data;
  }
  function outputText(text) { output.textContent = text === '' ? '(No output)' : text; }
  function formatMetric(value, unit) { return value === null || value === undefined || value === '' ? '' : String(value) + unit; }
  function safeError(error) { return error && error.message ? error.message : 'Something went wrong. Please try again.'; }

  async function runCode() {
    if (seconds <= 0 || form.dataset.activeAttempt !== '1') { showOutputMessage('Attempt ended', 'The timer has expired. Code can no longer be run.'); return; }
    saveCodeToForm();
    if (language.value === 'html') {
      previewWrap.hidden = false;
      updatePreview();
      outputStatus.textContent = 'Preview ready';
      outputText('HTML/CSS preview opened below the editor. This preview is not graded.');
      metrics.textContent = 'Local browser preview · No submission saved';
      setConsoleTab('output');
      return;
    }
    if (getCode().trim() === '') { showOutputMessage('Nothing to run', 'Write some code in the editor first.'); setConsoleTab('output'); return; }
    const thisRun = ++runSequence;
    runButton.disabled = true;
    submitButton.disabled = true;
    runButton.innerHTML = '<span class="button-spinner"></span> Running…';
    outputStatus.textContent = 'Running on Judge0…';
    outputText('Sending your source code to the configured Judge0 service…');
    metrics.textContent = '';
    setConsoleTab('output');
    try {
      const body = new FormData(form);
      body.set('source_code', getCode());
      body.set('stdin', stdin.value);
      const response = await fetch(baseUrl + '/run.php', {method:'POST', body, credentials:'same-origin', headers:{'X-Requested-With':'fetch'}});
      const data = await readJson(response);
      if (thisRun !== runSequence) return;
      const status = data.status || 'Unknown';
      outputStatus.textContent = status;
      outputStatus.className = 'output-status ' + (status === 'Accepted' ? 'is-success' : 'is-error');
      const sections = [];
      if (data.stdout) sections.push(data.stdout);
      if (data.compile_output) sections.push('COMPILER OUTPUT\n' + data.compile_output);
      if (data.stderr) sections.push('STANDARD ERROR\n' + data.stderr);
      outputText(sections.join('\n\n'));
      const timing = formatMetric(data.time, ' s');
      const memory = formatMetric(data.memory, ' KB');
      metrics.textContent = [timing, memory, 'No grade saved'].filter(Boolean).join('  ·  ');
    } catch (error) {
      if (thisRun !== runSequence) return;
      outputStatus.textContent = 'Run failed';
      outputStatus.className = 'output-status is-error';
      outputText(safeError(error));
      metrics.textContent = 'Your submission history and score were not changed.';
    } finally {
      runButton.innerHTML = language.value === 'html' ? '<span aria-hidden="true">▷</span> Preview HTML' : '<span aria-hidden="true">▶</span> Run Code';
      runButton.disabled = seconds <= 0 || form.dataset.activeAttempt !== '1';
      submitButton.disabled = language.value === 'html' || seconds <= 0 || form.dataset.activeAttempt !== '1';
    }
  }
  function showOutputMessage(title, message) {
    outputStatus.textContent = title;
    outputStatus.className = 'output-status is-error';
    outputText(message);
  }
  runButton.addEventListener('click', runCode);

  function element(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined && text !== null) node.textContent = String(text);
    return node;
  }
  function addOutputBlock(parent, title, value) {
    const block = element('div', 'test-output-block');
    block.appendChild(element('span', 'test-output-label', title));
    block.appendChild(element('pre', 'test-output-value', value === '' ? '(No output)' : value));
    parent.appendChild(block);
  }
  function renderSubmission(data) {
    setConsoleTab('tests');
    testResults.replaceChildren();
    testCount.textContent = String(data.total_tests || 0);
    const allPassed = Number(data.passed_tests) === Number(data.total_tests) && Number(data.total_tests) > 0;
    const score = Number(data.score || 0);
    const maxScore = Math.max(1, Number(data.max_score || 1));
    const reachedHalf = score * 2 >= maxScore;
    const resultClass = allPassed ? 'is-success' : (reachedHalf ? 'is-progress' : 'is-failed');
    const resultMessage = allPassed
      ? 'All tests passed! Your perfect score completes this exercise.'
      : (reachedHalf ? 'You reached at least half of the available points. Keep improving until you earn a perfect score.' : 'Not passed yet: your score is below half of the available points. Review the failed tests and try again.');
    testSummary.className = 'test-summary ' + resultClass;
    testSummary.replaceChildren();
    testSummary.appendChild(element('span', 'test-summary-icon', allPassed ? '✓' : (reachedHalf ? '↗' : '×')));
    const summaryCopy = element('div', 'test-summary-copy');
    const scoreHeadline = allPassed ? 'Perfect score' : (reachedHalf ? 'Good progress' : 'Failed');
    summaryCopy.appendChild(element('strong', '', `${scoreHeadline} · ${data.score} / ${data.max_score} points`));
    summaryCopy.appendChild(element('p', '', `${data.passed_tests} of ${data.total_tests} tests passed. ${resultMessage}`));
    testSummary.appendChild(summaryCopy);
    const progressTrack = element('div', 'test-progress-track');
    const progressBar = element('div', 'test-progress-bar');
    progressBar.style.width = (Number(data.total_tests) ? (100 * Number(data.passed_tests) / Number(data.total_tests)) : 0) + '%';
    progressTrack.appendChild(progressBar);
    testSummary.appendChild(progressTrack);

    (data.tests || []).forEach(test => {
      const card = element('article', 'test-case-card ' + (test.passed ? 'passed' : 'failed'));
      const heading = element('div', 'test-case-heading');
      heading.appendChild(element('span', 'test-case-check', test.passed ? '✓' : '×'));
      const testLabel = test.is_sample ? `Sample test ${test.sample_number}` : `Hidden test ${test.number}`;
      const titleWrap = element('div', 'test-case-title');
      titleWrap.appendChild(element('strong', '', testLabel));
      titleWrap.appendChild(element('small', '', test.verdict || test.status || (test.passed ? 'Accepted' : 'Failed')));
      heading.appendChild(titleWrap);
      const statusBadge = element('span', 'verdict-badge', test.passed ? 'PASSED' : 'FAILED');
      heading.appendChild(statusBadge);
      card.appendChild(heading);
      if (test.is_sample) {
        const columns = element('div', 'test-output-columns');
        addOutputBlock(columns, 'Input', test.input || '');
        addOutputBlock(columns, 'Expected output', test.expected_output || '');
        addOutputBlock(columns, 'Your output', test.actual_output || '');
        card.appendChild(columns);
        if (test.error_output) card.appendChild(element('pre', 'test-error-output', test.error_output));
      } else {
        card.appendChild(element('p', 'hidden-test-note', 'Hidden test details are kept private. This result shows only whether the test passed.'));
      }
      const meta = [formatMetric(test.time, ' s'), formatMetric(test.memory, ' KB')].filter(Boolean).join(' · ');
      if (meta) card.appendChild(element('div', 'test-case-metrics', meta));
      testResults.appendChild(card);
    });
  }

  function showCompletion(data) {
    timerStopped = true;
    form.dataset.activeAttempt = '0';
    timer.textContent = 'COMPLETED';
    timer.parentElement.classList.add('timer-perfect');
    document.getElementById('timerCaption').textContent = 'Perfect score · timer stopped';
    document.getElementById('submitHint').textContent = 'Perfect score achieved. Your attempt is complete.';
    runButton.disabled = true;
    submitButton.disabled = true;
    language.disabled = true;
    textarea.disabled = true;
    document.getElementById('resetCodeBtn').disabled = true;
    if (editor) editor.setOption('readOnly', true);

    const stage = document.getElementById('completionStage');
    const workspace = document.getElementById('codingWorkspace');
    document.getElementById('completionScore').textContent = String(data.best_score ?? data.score ?? 0);
    document.getElementById('completionMaxScore').textContent = String(data.max_score ?? 0);
    document.getElementById('completionTests').textContent = `✓ ${data.passed_tests ?? 0} of ${data.total_tests ?? 0} test cases passed`;
    document.getElementById('completionHeadline').textContent = 'Congratulations!';
    document.getElementById('completionIntro').textContent = 'You earned a perfect score. This exercise is marked done and your timer has stopped.';
    const doneButton = document.getElementById('completionDoneBtn');
    doneButton.href = data.done_url || (baseUrl + '/index.php#practice');
    doneButton.hidden = false;
    const nextButton = document.getElementById('completionNextBtn');
    if (data.next_exercise_url) {
      nextButton.href = data.next_exercise_url;
      nextButton.textContent = data.path_mode ? 'Continue learning path →' : 'Continue to next exercise →';
      nextButton.hidden = false;
      document.getElementById('completionNote').hidden = true;
    } else {
      nextButton.hidden = true;
      document.getElementById('completionNote').hidden = false;
    }
    workspace.hidden = true;
    stage.hidden = false;
    const prefersReducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    stage.scrollIntoView({behavior: prefersReducedMotion ? 'auto' : 'smooth', block: 'start'});
    if (window.CodeArenaConfetti) CodeArenaConfetti.launchOnce('codearena:perfect:' + userId + ':' + exerciseId);
  }

  async function submitCode() {
    if (language.value === 'html') { previewWrap.hidden = false; updatePreview(); showOutputMessage('Preview only', 'HTML/CSS preview is not graded. Select a programming language to submit a solution.'); setConsoleTab('output'); return; }
    if (seconds <= 0 || form.dataset.activeAttempt !== '1') return;
    saveCodeToForm();
    if (getCode().trim() === '') { showOutputMessage('Nothing to submit', 'Write some code in the editor first.'); setConsoleTab('output'); return; }
    const originalRunLabel = runButton.innerHTML;
    runButton.disabled = true;
    submitButton.disabled = true;
    submitButton.textContent = 'Grading…';
    const currentBody = new FormData(form);
    currentBody.set('source_code', getCode());
    try {
      const response = await fetch(form.action, {method:'POST', body:currentBody, credentials:'same-origin', headers:{'X-Requested-With':'fetch'}});
      const data = await readJson(response);
      renderSubmission(data);
      const empty = document.getElementById('emptyHistory');
      if (empty) {
        const tableWrap = document.getElementById('historyTableWrap');
        if (tableWrap) tableWrap.hidden = false;
        const placeholder = empty.querySelector('.history-empty');
        if (placeholder) placeholder.hidden = true;
      }
      let historyBody = document.getElementById('historyBody');
      if (historyBody) {
        const row = document.createElement('tr');
        row.appendChild(element('td', '', (langInfo[language.value] || langInfo.python).badge));
        const scoreCell = element('td'); scoreCell.appendChild(element('strong', '', data.score)); row.appendChild(scoreCell);
        row.appendChild(element('td', '', `${data.passed_tests}/${data.total_tests}`));
        row.appendChild(element('td', '', new Date().toLocaleString()));
        historyBody.prepend(row);
        while (historyBody.children.length > 5) historyBody.lastElementChild.remove();
      }
      setEditorStatus('Submission graded · draft kept locally');
      if (data.completed || data.perfect_score) showCompletion(data);
    } catch (error) {
      testResults.replaceChildren();
      testSummary.className = 'test-summary is-warning';
      testSummary.replaceChildren(element('span', 'test-summary-icon', '!'));
      const copy = element('div', 'test-summary-copy');
      copy.appendChild(element('strong', '', 'Submission could not be graded'));
      copy.appendChild(element('p', '', safeError(error)));
      testSummary.appendChild(copy);
      setConsoleTab('tests');
    } finally {
      runButton.innerHTML = originalRunLabel;
      runButton.disabled = seconds <= 0 || form.dataset.activeAttempt !== '1';
      submitButton.textContent = 'Submit Answer ↗';
      submitButton.disabled = language.value === 'html' || seconds <= 0 || form.dataset.activeAttempt !== '1';
    }
  }
  form.addEventListener('submit', event => { event.preventDefault(); submitCode(); });
  window.addEventListener('beforeunload', saveDraft);

  // Teacher-configured monitoring is recorded server-side. Students never receive teacher controls or reports.
  if (monitoringEnabled) {
    const csrfToken = form.querySelector('input[name="_csrf"]').value;
    const lastSent = new Map();
    async function logMonitorEvent(type) {
      if (timerStopped || form.dataset.activeAttempt !== '1') return;
      const now = Date.now();
      if (now - (lastSent.get(type) || 0) < 1200) return;
      lastSent.set(type, now);
      const payload = new URLSearchParams();
      payload.set('_csrf', csrfToken);
      payload.set('exercise_id', exerciseId);
      payload.set('event_type', type);
      try {
        // sendBeacon is more reliable when the page is becoming hidden or is unloading.
        if (type === 'tab_hidden' && navigator.sendBeacon && navigator.sendBeacon(baseUrl + '/monitor-event.php', payload)) return;
        const response = await fetch(baseUrl + '/monitor-event.php', {
          method: 'POST', body: payload, credentials: 'same-origin', keepalive: true,
          headers: {'X-Requested-With': 'fetch'}
        });
        if (!response.ok) {
          const responseBody = await response.text().catch(() => '');
          console.warn('CodeArena monitoring event was not saved:', response.status, responseBody);
        }
      } catch (error) {
        console.warn('CodeArena monitoring could not reach its event endpoint.', error);
      }
    }
    document.addEventListener('visibilitychange', () => { if (!timerStopped && document.hidden) logMonitorEvent('tab_hidden'); });
    document.addEventListener('copy', () => logMonitorEvent('copy'), true);
    document.addEventListener('cut', () => logMonitorEvent('cut'), true);
    document.addEventListener('paste', () => logMonitorEvent('paste'), true);
    document.addEventListener('fullscreenchange', () => {
      const nowFullscreen = Boolean(document.fullscreenElement);
      if (wasFullscreen && !nowFullscreen && !document.hidden) {
        setTimeout(() => { if (!document.hidden && !document.fullscreenElement) logMonitorEvent('fullscreen_exit'); }, 800);
      }
      wasFullscreen = nowFullscreen;
    });
  } else {
    document.addEventListener('fullscreenchange', () => { wasFullscreen = Boolean(document.fullscreenElement); });
  }

  function tick() {
    if (timerStopped) return;
    seconds = deadlineMs ? Math.max(0, Math.ceil((deadlineMs - Date.now()) / 1000)) : Math.max(0, seconds);
    if (seconds <= 0) {
      timer.textContent = '00:00';
      document.getElementById('timerCaption').textContent = 'Attempt ended';
      runButton.disabled = true; submitButton.disabled = true;
      document.getElementById('submitHint').textContent = 'The timer has expired.';
      return;
    }
    timer.textContent = String(Math.floor(seconds / 60)).padStart(2, '0') + ':' + String(seconds % 60).padStart(2, '0');
    setTimeout(tick, 250);
  }

  restoreDraft();
  updateLanguage();
  tick();
})();
</script>
<?php page_footer(); ?>
