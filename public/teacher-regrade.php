<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/judge0.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit('POST required.'); }
verify_csrf();
$submissionId = max(0, (int)($_POST['submission_id'] ?? 0));
$reason = trim((string)($_POST['reason'] ?? ''));
if ($submissionId < 1 || mb_strlen($reason) > 500 || empty($_POST['confirm_regrade'])) { flash('Confirm the regrade and keep the reason under 500 characters.', 'error'); redirect('teacher-submission.php'); }

$find = $pdo->prepare('SELECT s.*,e.created_by,e.title AS current_exercise_title,e.points AS current_points FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE s.id=? AND e.created_by=? LIMIT 1');
$find->execute([$submissionId, (int)$user['id']]);
$original = $find->fetch();
if (!$original) { http_response_code(404); exit('Submission not found in your teaching scope.'); }
$language = (string)$original['language'];
if (!in_array($language, ['c','cpp','java','python','php','ruby'], true) || empty(($config['judge0']['languages'][$language] ?? null))) {
    flash('The submission language is not enabled in your Judge0 configuration.', 'error');
    redirect('teacher-submission.php?submission_id='.$submissionId);
}

try {
    // Pin grading to the immutable version snapshot, not a second live read that
    // could observe an edit made while this regrade is running.
    $versionId = store_exercise_version($pdo, (int)$original['exercise_id'], (int)$original['created_by'], 'Teacher regrade baseline', (int)$user['id']);
    $snapshotStmt = $pdo->prepare('SELECT snapshot_json FROM exercise_versions WHERE id=? AND exercise_id=? LIMIT 1');
    $snapshotStmt->execute([$versionId, (int)$original['exercise_id']]);
    $snapshotRaw = $snapshotStmt->fetchColumn();
    $payload = is_string($snapshotRaw) ? json_decode($snapshotRaw, true) : null;
    if (!is_array($payload) || !is_array($payload['exercise'] ?? null) || !is_array($payload['test_cases'] ?? null)) {
        throw new RuntimeException('The version snapshot cannot be loaded for regrading.');
    }
    $tests = $payload['test_cases'];
    $maxPoints = max(1, (int)($payload['exercise']['points'] ?? $original['current_points']));
    if (!$tests) throw new RuntimeException('This exercise has no test cases to use for regrading.');
    if (count($tests) > 100) throw new RuntimeException('This exercise has more than 100 test cases. Reduce the test suite before regrading.');

    $results = [];
    $passed = 0;
    foreach (array_chunk($tests, 20) as $chunkIndex => $testChunk) {
        $jobs = array_map(static fn(array $test): array => ['language'=>$language, 'source_code'=>(string)$original['source_code'], 'stdin'=>(string)$test['stdin']], $testChunk);
        $runs = judge0_execute_batch($config['judge0'] ?? [], $jobs);
        foreach ($testChunk as $localIndex => $test) {
            $run = $runs[$localIndex] ?? [];
            $status = (string)($run['status']['description'] ?? 'Unknown');
            $isPassed = $status === 'Accepted' && normalize_output((string)($run['stdout'] ?? '')) === normalize_output((string)$test['expected_output']);
            if ($isPassed) $passed++;
            $results[] = ['number'=>count($results)+1, 'is_sample'=>(int)($test['is_sample'] ?? 0), 'passed'=>$isPassed,
                'status'=>$status, 'verdict'=>$isPassed ? 'Accepted' : ($status === 'Accepted' ? 'Wrong Answer' : $status)];
        }
    }
    $total = count($tests);
    $score = (int)floor($maxPoints * $passed / max(1, $total));
    $summary = json_encode($results, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    if ($summary === false) throw new RuntimeException('Could not encode regrade result summaries.');

    $pdo->beginTransaction();
    $lock = $pdo->prepare('SELECT s.score,s.passed_tests,s.total_tests,s.result_json,s.exercise_version_id,s.source_code,s.user_id,s.exercise_id,e.points FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE s.id=? AND e.created_by=? FOR UPDATE');
    $lock->execute([$submissionId, (int)$user['id']]);
    $locked = $lock->fetch();
    if (!$locked || !hash_equals((string)$locked['source_code'], (string)$original['source_code']) || (int)($locked['exercise_version_id'] ?? 0) !== (int)($original['exercise_version_id'] ?? 0)) {
        throw new RuntimeException('The submission changed while regrading. Reload the page and try again.');
    }
    $history = $pdo->prepare('INSERT INTO submission_regrade_history(submission_id,teacher_id,previous_version_id,new_version_id,previous_score,previous_passed_tests,previous_total_tests,previous_result_json,new_score,new_passed_tests,new_total_tests,reason) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)');
    $history->execute([$submissionId,(int)$user['id'],$locked['exercise_version_id'] ?: null,$versionId,(int)$locked['score'],(int)$locked['passed_tests'],(int)$locked['total_tests'],$locked['result_json'],$score,$passed,$total,$reason !== '' ? $reason : null]);
    $update = $pdo->prepare('UPDATE submissions SET exercise_version_id=?,score=?,passed_tests=?,total_tests=?,result_json=? WHERE id=?');
    $update->execute([$versionId,$score,$passed,$total,$summary,$submissionId]);

    // Recompute the attempt best score and perfect status using each submission's
    // saved exercise-version points. This is important if a teacher corrected points.
    $allScoresStmt = $pdo->prepare("SELECT s.id,s.score,s.passed_tests,s.total_tests,s.created_at,e.points AS current_points,ev.snapshot_json
        FROM submissions s JOIN exercises e ON e.id=s.exercise_id
        LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id
        WHERE s.user_id=? AND s.exercise_id=? ORDER BY s.score DESC,s.created_at DESC,s.id DESC");
    $allScoresStmt->execute([(int)$locked['user_id'],(int)$locked['exercise_id']]);
    $scoreRows = $allScoresStmt->fetchAll();
    $newBest = 0;
    $bestRow = null;
    $hasPerfect = false;
    $perfectRow = null;
    foreach ($scoreRows as $scoreRow) {
        $rowPoints = max(1, (int)$scoreRow['current_points']);
        if (!empty($scoreRow['snapshot_json'])) {
            $savedSnapshot = json_decode((string)$scoreRow['snapshot_json'], true);
            if (is_array($savedSnapshot['exercise'] ?? null) && is_numeric($savedSnapshot['exercise']['points'] ?? null)) {
                $rowPoints = max(1, (int)$savedSnapshot['exercise']['points']);
            }
        }
        if ($bestRow === null) { $bestRow = $scoreRow; $newBest = (int)$scoreRow['score']; }
        if ((int)$scoreRow['score'] >= $rowPoints) { $hasPerfect = true; if ($perfectRow === null) $perfectRow = $scoreRow; }
    }
    $attemptStmt = $pdo->prepare("UPDATE attempts SET best_score=?,
        status=CASE WHEN ?=1 THEN 'submitted' ELSE status END,
        completed_at=CASE WHEN ?=1 THEN COALESCE(completed_at,NOW()) ELSE completed_at END
        WHERE user_id=? AND exercise_id=?");
    $attemptStmt->execute([$newBest, $hasPerfect ? 1 : 0, $hasPerfect ? 1 : 0, (int)$locked['user_id'], (int)$locked['exercise_id']]);

    // Reconcile path completion with the new saved results. A perfect result only
    // records completion if all earlier steps in that path are already complete.
    if (codearena_table_exists($pdo, 'learning_path_completions') && codearena_table_exists($pdo, 'learning_path_items')) {
        $linked = $pdo->prepare('SELECT id,path_id,sort_order FROM learning_path_items WHERE exercise_id=? ORDER BY path_id,sort_order,id');
        $linked->execute([(int)$locked['exercise_id']]);
        $pathItems = $linked->fetchAll();
        foreach ($pathItems as $pathItem) {
            $pathId = (int)$pathItem['path_id'];
            $removeCompletion = $pdo->prepare('DELETE FROM learning_path_completions WHERE user_id=? AND path_id=? AND exercise_id=?');
            if (!$hasPerfect) {
                $removeCompletion->execute([(int)$locked['user_id'], $pathId, (int)$locked['exercise_id']]);
                continue;
            }
            $prior = $pdo->prepare("SELECT COUNT(*) FROM learning_path_items prior_item
                LEFT JOIN learning_path_completions prior_done ON prior_done.path_id=prior_item.path_id
                    AND prior_done.exercise_id=prior_item.exercise_id AND prior_done.user_id=?
                WHERE prior_item.path_id=? AND (prior_item.sort_order < ? OR (prior_item.sort_order = ? AND prior_item.id < ?))
                    AND prior_done.id IS NULL");
            $prior->execute([(int)$locked['user_id'], $pathId, (int)$pathItem['sort_order'], (int)$pathItem['sort_order'], (int)$pathItem['id']]);
            if ((int)$prior->fetchColumn() > 0) {
                $removeCompletion->execute([(int)$locked['user_id'], $pathId, (int)$locked['exercise_id']]);
                continue;
            }
            $completion = $pdo->prepare("INSERT INTO learning_path_completions(user_id,path_id,exercise_id,completion_type,passed_tests,total_tests)
                VALUES(?,?,?,'all_tests_passed',?,?)
                ON DUPLICATE KEY UPDATE completion_type='all_tests_passed',passed_tests=VALUES(passed_tests),total_tests=VALUES(total_tests)");
            $completion->execute([(int)$locked['user_id'], $pathId, (int)$locked['exercise_id'], (int)($perfectRow['passed_tests'] ?? $passed), (int)($perfectRow['total_tests'] ?? $total)]);
        }
    }

    // Keep grade records, badges, and audit history in the same transaction as the regrade.
    $assignmentStmt=$pdo->prepare('SELECT id FROM class_assignments WHERE exercise_id=? AND is_active=1');
    $assignmentStmt->execute([(int)$locked['exercise_id']]);
    foreach ($assignmentStmt->fetchAll(PDO::FETCH_COLUMN) as $assignmentId) sync_assignment_grade($pdo,(int)$assignmentId,(int)$locked['user_id']);
    award_student_badges($pdo,(int)$locked['user_id']);
    audit_log($pdo, (int)$user['id'], 'submission_regraded', 'submission', $submissionId, ['exercise_id'=>(int)$locked['exercise_id'],'previous_score'=>(int)$locked['score'],'new_score'=>$score,'passed_tests'=>$passed,'total_tests'=>$total,'version_id'=>$versionId,'reason'=>$reason]);
    $pdo->commit();
    flash('Regrade completed: '.$passed.'/'.$total.' tests passed; score updated to '.$score.'/'.$maxPoints.'. The previous result was saved in regrade history.', 'success');
    redirect('teacher-submission.php?submission_id='.$submissionId);
} catch (Throwable $error) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    error_log('CodeArena teacher regrade failed: '.$error->getMessage());
    flash('Regrade could not be completed. Check the Judge0 connection, test-case setup, and server log, then retry.', 'error');
    redirect('teacher-submission.php?submission_id='.$submissionId);
}
