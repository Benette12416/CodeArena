<?php
/** Student-side learning path state and sequential-access helpers. */

declare(strict_types=1);

function ca_student_learning_path_context(PDO $pdo, int $userId, int $pathId): ?array
{
    $pathStmt = $pdo->prepare("SELECT lp.id, lp.title, lp.description, lp.teacher_id, u.name AS teacher_name, lp.updated_at
        FROM learning_paths lp JOIN users u ON u.id=lp.teacher_id
        WHERE lp.id=? AND lp.is_published=1 LIMIT 1");
    $pathStmt->execute([$pathId]);
    $path = $pathStmt->fetch();
    if (!$path) return null;

    $hasGenericCompletions = function_exists('codearena_table_exists') && codearena_table_exists($pdo, 'learning_path_completions');
    $hasLegacyHtmlCompletions = function_exists('codearena_table_exists') && codearena_table_exists($pdo, 'practice_lesson_completions');
    $completionSelect = $hasGenericCompletions ? 'lpc.completion_type AS path_completion_type, lpc.completed_at AS path_completed_at' : 'NULL AS path_completion_type, NULL AS path_completed_at';
    $completionJoin = $hasGenericCompletions ? 'LEFT JOIN learning_path_completions lpc ON lpc.path_id=lpi.path_id AND lpc.exercise_id=e.id AND lpc.user_id=?' : '';
    $itemsSql = "SELECT lpi.id AS path_item_id, lpi.sort_order, e.id, e.slug, e.title, e.description,
            e.topic, e.difficulty, e.points, e.time_limit_seconds, e.starter_code, e.is_published,
            EXISTS(SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1) AS has_assignment,
            COALESCE(a.best_score,0) AS best_score,
            {$completionSelect}
        FROM learning_path_items lpi
        JOIN exercises e ON e.id=lpi.exercise_id
        LEFT JOIN attempts a ON a.exercise_id=e.id AND a.user_id=?
        {$completionJoin}
        WHERE lpi.path_id=?
        ORDER BY lpi.sort_order,lpi.id";
    $itemsStmt = $pdo->prepare($itemsSql);
    $binds = [$userId];
    if ($hasGenericCompletions) $binds[] = $userId;
    $binds[] = $pathId;
    $itemsStmt->execute($binds);
    $items = $itemsStmt->fetchAll();

    $legacyCompleted = [];
    if ($hasLegacyHtmlCompletions) {
        $legacyStmt = $pdo->prepare('SELECT exercise_id FROM practice_lesson_completions WHERE user_id=? AND path_id=?');
        $legacyStmt->execute([$userId, $pathId]);
        $legacyCompleted = array_fill_keys(array_map('intval', $legacyStmt->fetchAll(PDO::FETCH_COLUMN)), true);
    }

    $previousAllCompleted = true;
    $completedCount = 0;
    foreach ($items as &$item) {
        $exerciseId = (int)$item['id'];
        $isHtmlProject = str_starts_with((string)($item['slug'] ?? ''), 'ca-htmlcss-path-');
        $manualLegacyComplete = $isHtmlProject && isset($legacyCompleted[$exerciseId]);
        $perfectClassAttempt = (int)$item['has_assignment'] === 1
            && (int)$item['best_score'] >= (int)$item['points'];
        $completed = !empty($item['path_completion_type']) || $manualLegacyComplete || $perfectClassAttempt;
        $item['is_html_project'] = $isHtmlProject;
        $item['completed'] = $completed;
        $item['unlocked'] = $previousAllCompleted;
        $item['exercise_available'] = (int)($item['is_published'] ?? 0) === 1;
        $item['assignment_access_allowed'] = $item['exercise_available'];
        if ((int)$item['has_assignment'] === 1 && function_exists('student_exercise_access_context')) {
            $assignmentAccess = student_exercise_access_context($pdo, $userId, $exerciseId);
            $item['assignment_access_allowed'] = $item['exercise_available'] && (bool)$assignmentAccess['allowed'];
        }
        if ($completed) $completedCount++;
        $previousAllCompleted = $previousAllCompleted && $completed;
    }
    unset($item);

    foreach ($items as $idx => &$item) {
        $item['position'] = $idx + 1;
        $item['total_steps'] = count($items);
        $item['status_label'] = $item['completed'] ? 'Completed' : ($item['unlocked'] ? 'Available now' : 'Locked');
        $item['is_last_step'] = $idx === count($items) - 1;
    }
    unset($item);

    return [
        'path' => $path,
        'items' => $items,
        'completed_count' => $completedCount,
        'total_count' => count($items),
        'progress' => count($items) > 0 ? (int)round($completedCount / count($items) * 100) : 0,
        'has_completion_table' => $hasGenericCompletions,
    ];
}

function ca_assert_learning_path_step_unlocked(PDO $pdo, int $userId, int $pathId, int $exerciseId): array
{
    $context = ca_student_learning_path_context($pdo, $userId, $pathId);
    if (!$context) return ['ok' => false, 'reason' => 'This learning path is not published or is unavailable.', 'context' => null, 'item' => null];

    foreach ($context['items'] as $item) {
        if ((int)$item['id'] !== $exerciseId) continue;
        if (!$item['exercise_available']) {
            return ['ok' => false, 'reason' => 'This exercise is currently unpublished. Ask your teacher to republish it before continuing.', 'context' => $context, 'item' => $item];
        }
        if (!$item['unlocked']) {
            $reason = 'This step is locked. Complete step ' . max(1, (int)$item['position'] - 1) . ' with a perfect score before opening it.';
            return ['ok' => false, 'reason' => $reason, 'context' => $context, 'item' => $item];
        }
        if ((int)$item['has_assignment'] === 1 && empty($item['assignment_access_allowed'])) {
            return ['ok' => false, 'reason' => 'Join the classroom assigned to this challenge before continuing.', 'context' => $context, 'item' => $item];
        }
        return ['ok' => true, 'reason' => '', 'context' => $context, 'item' => $item];
    }
    return ['ok' => false, 'reason' => 'This exercise does not belong to the selected published learning path.', 'context' => $context, 'item' => null];
}

function ca_find_published_path_for_exercise(PDO $pdo, int $exerciseId): ?int
{
    $stmt = $pdo->prepare("SELECT lp.id FROM learning_path_items lpi JOIN learning_paths lp ON lp.id=lpi.path_id
        WHERE lpi.exercise_id=? AND lp.is_published=1 ORDER BY lp.id ASC LIMIT 1");
    $stmt->execute([$exerciseId]);
    $value = $stmt->fetchColumn();
    return $value === false ? null : (int)$value;
}
