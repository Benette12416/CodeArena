<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/learning_paths.php';
$user = require_role(['student']);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit('Method not allowed.'); }
verify_csrf();
$exerciseId = max(0, (int)($_POST['exercise_id'] ?? 0));
$pathId = max(0, (int)($_POST['path_id'] ?? 0));
if ($exerciseId < 1 || $pathId < 1) { http_response_code(400); exit('A valid learning path and project are required.'); }
$gate = ca_assert_learning_path_step_unlocked($pdo, (int)$user['id'], $pathId, $exerciseId);
if (!$gate['ok']) {
    flash($gate['reason'], 'error');
    redirect('student-learning-paths.php?path_id=' . $pathId);
}
$check = $pdo->prepare("SELECT e.id FROM exercises e JOIN learning_path_items lpi ON lpi.exercise_id=e.id JOIN learning_paths lp ON lp.id=lpi.path_id
    WHERE e.id=? AND lp.id=? AND lp.is_published=1 AND e.is_published=1 AND e.slug LIKE 'ca-htmlcss-path-%'
      AND NOT EXISTS (SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1) LIMIT 1");
$check->execute([$exerciseId, $pathId]);
if (!$check->fetchColumn()) { http_response_code(404); exit('This HTML/CSS project is not available in this learning path.'); }

$pdo->beginTransaction();
try {
    $save = $pdo->prepare('INSERT INTO practice_lesson_completions(user_id,path_id,exercise_id,completed_at) VALUES(?,?,?,CURRENT_TIMESTAMP) ON DUPLICATE KEY UPDATE completed_at=VALUES(completed_at)');
    $save->execute([(int)$user['id'], $pathId, $exerciseId]);
    if (function_exists('codearena_table_exists') && codearena_table_exists($pdo, 'learning_path_completions')) {
        $completion = $pdo->prepare("INSERT INTO learning_path_completions(user_id,path_id,exercise_id,completion_type,passed_tests,total_tests,completed_at)
            VALUES(?,?,?,'manual_project',0,0,CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE completion_type=VALUES(completion_type),completed_at=VALUES(completed_at)");
        $completion->execute([(int)$user['id'], $pathId, $exerciseId]);
    }
    $pdo->commit();
    if (function_exists('audit_log')) audit_log($pdo, (int)$user['id'], 'html_css_project_completed', 'exercise', $exerciseId, ['path_id' => $pathId]);
    if (function_exists('award_student_badges')) award_student_badges($pdo, (int)$user['id']);
} catch (Throwable $error) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    error_log('CodeArena HTML/CSS path completion failed: ' . $error->getMessage());
    http_response_code(500);
    exit('Could not save project completion. Please try again.');
}
flash('Project marked complete. The next step is now unlocked. This does not affect official classroom grades.', 'success');
redirect('student-learning-paths.php?path_id=' . $pathId);
