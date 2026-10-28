<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
if ($_SERVER['REQUEST_METHOD'] === 'POST' && (string)($_POST['action'] ?? '') === 'save_feedback') {
    verify_csrf();
    $feedbackSubmissionId = max(0, (int)($_POST['submission_id'] ?? 0));
    $feedbackText = trim((string)($_POST['feedback_text'] ?? ''));
    $feedbackType = (string)($_POST['feedback_type'] ?? 'comment');
    if (!in_array($feedbackType, ['comment','needs_revision','approved'], true)) $feedbackType = 'comment';
    $owns = $pdo->prepare('SELECT s.id FROM submissions s JOIN exercises e ON e.id=s.exercise_id WHERE s.id=? AND e.created_by=? LIMIT 1');
    $owns->execute([$feedbackSubmissionId,(int)$user['id']]);
    if (!$owns->fetchColumn()) { http_response_code(404); exit('Submission not found in your teaching scope.'); }
    if ($feedbackText === '' || mb_strlen($feedbackText) > 4000) {
        flash('Feedback must contain 1 to 4,000 characters.', 'error');
    } else {
        $save=$pdo->prepare("INSERT INTO submission_feedback(submission_id,teacher_id,feedback_text,feedback_type) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE feedback_text=VALUES(feedback_text),feedback_type=VALUES(feedback_type),updated_at=CURRENT_TIMESTAMP");
        $save->execute([$feedbackSubmissionId,(int)$user['id'],$feedbackText,$feedbackType]);
        audit_log($pdo,(int)$user['id'],'submission_feedback_saved','submission',$feedbackSubmissionId,['feedback_type'=>$feedbackType]);
        flash('Feedback saved. The student can see it in Submission history.', 'success');
    }
    $qs=['submission_id'=>$feedbackSubmissionId];
    foreach(['classroom_id','student_id','exercise_id'] as $key){$v=(int)($_POST[$key]??0);if($v>0)$qs[$key]=$v;}
    redirect('teacher-submission.php?'.http_build_query($qs));
}
$classroomId=max(0,(int)($_GET['classroom_id'] ?? 0));
$studentId=max(0,(int)($_GET['student_id'] ?? 0));
$exerciseId=max(0,(int)($_GET['exercise_id'] ?? 0));
$submissionId=max(0,(int)($_GET['submission_id'] ?? 0));
$classroom=null;
if ($classroomId) {
    $stmt=$pdo->prepare('SELECT id,name,section FROM classrooms WHERE id=? AND teacher_id=?');
    $stmt->execute([$classroomId,(int)$user['id']]); $classroom=$stmt->fetch();
    if (!$classroom) { http_response_code(404); exit('Classroom not found.'); }
}
if ($exerciseId) {
    $sql='SELECT e.id,e.title,e.points FROM exercises e WHERE e.id=? AND e.created_by=?'; $params=[$exerciseId,(int)$user['id']];
    if ($classroomId) { $sql.=' AND EXISTS(SELECT 1 FROM class_assignments ca WHERE ca.classroom_id=? AND ca.exercise_id=e.id)'; $params[]=$classroomId; }
    $stmt=$pdo->prepare($sql); $stmt->execute($params); $exercise=$stmt->fetch();
    if (!$exercise) { http_response_code(404); exit('Exercise not found in your class records.'); }
}
if ($studentId) {
    $sql='SELECT u.id,u.name,u.email FROM users u WHERE u.id=?'; $params=[$studentId];
    if ($classroomId) { $sql.=' AND EXISTS(SELECT 1 FROM class_enrollments ce WHERE ce.classroom_id=? AND ce.student_id=u.id)'; $params[]=$classroomId; }
    $stmt=$pdo->prepare($sql); $stmt->execute($params); $student=$stmt->fetch();
    if (!$student) { http_response_code(404); exit('Student not found in the selected classroom.'); }
}
$detail=null;
if ($submissionId) {
    $stmt=$pdo->prepare('SELECT s.*,u.name AS student_name,u.email,e.title AS exercise_title,e.points AS max_points,e.id AS exercise_id,ev.snapshot_json AS version_snapshot_json,ev.version_number AS version_number FROM submissions s JOIN users u ON u.id=s.user_id JOIN exercises e ON e.id=s.exercise_id LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id WHERE s.id=? AND e.created_by=?');
    $stmt->execute([$submissionId,(int)$user['id']]); $detail=$stmt->fetch();
    if ($detail && !empty($detail['version_snapshot_json'])) { $historicalSnapshot=json_decode((string)$detail['version_snapshot_json'],true); if (is_array($historicalSnapshot['exercise'] ?? null)) { $detail['exercise_title']=(string)($historicalSnapshot['exercise']['title'] ?? $detail['exercise_title']); $detail['max_points']=max(1,(int)($historicalSnapshot['exercise']['points'] ?? $detail['max_points'])); } }
    if (!$detail || ($studentId && (int)$detail['user_id']!==$studentId) || ($exerciseId && (int)$detail['exercise_id']!==$exerciseId)) { http_response_code(404); exit('Submission not found or outside your teaching scope.'); }
    audit_log($pdo, (int)$user['id'], 'submission_inspected', 'submission', (int)$detail['id'], ['exercise_id'=>(int)$detail['exercise_id']]);
    if ($classroomId) {
        $scope=$pdo->prepare('SELECT 1 FROM class_assignments ca JOIN class_enrollments ce ON ce.classroom_id=ca.classroom_id AND ce.student_id=? WHERE ca.classroom_id=? AND ca.exercise_id=? LIMIT 1');
        $scope->execute([(int)$detail['user_id'],$classroomId,(int)$detail['exercise_id']]);
        if (!$scope->fetchColumn()) { http_response_code(404); exit('Submission is not part of this classroom.'); }
    }
}
$feedbackRow = null;
if ($detail && codearena_table_exists($pdo,'submission_feedback')) {
    $feedbackStmt=$pdo->prepare('SELECT feedback_text,feedback_type,created_at,updated_at FROM submission_feedback WHERE submission_id=? AND teacher_id=? LIMIT 1');
    $feedbackStmt->execute([(int)$detail['id'],(int)$user['id']]);
    $feedbackRow=$feedbackStmt->fetch() ?: null;
}
$regradeHistory = [];
if ($detail && codearena_table_exists($pdo,'submission_regrade_history')) {
    $regradeStmt=$pdo->prepare('SELECT rh.*,u.name AS teacher_name,pv.version_number AS previous_version_number,nv.version_number AS new_version_number FROM submission_regrade_history rh JOIN users u ON u.id=rh.teacher_id LEFT JOIN exercise_versions pv ON pv.id=rh.previous_version_id LEFT JOIN exercise_versions nv ON nv.id=rh.new_version_id WHERE rh.submission_id=? ORDER BY rh.regraded_at DESC LIMIT 20');
    $regradeStmt->execute([(int)$detail['id']]);
    $regradeHistory=$regradeStmt->fetchAll();
}
$where=['e.created_by=?']; $params=[(int)$user['id']];
if ($exerciseId) { $where[]='e.id=?'; $params[]=$exerciseId; }
if ($studentId) { $where[]='s.user_id=?'; $params[]=$studentId; }
if ($classroomId) {
    $where[]='EXISTS(SELECT 1 FROM class_assignments ca JOIN class_enrollments ce ON ce.classroom_id=ca.classroom_id AND ce.student_id=s.user_id WHERE ca.classroom_id=? AND ca.exercise_id=e.id)';
    $params[]=$classroomId;
}
$listStmt=$pdo->prepare('SELECT s.id,s.language,s.score,s.passed_tests,s.total_tests,s.created_at,s.user_id,u.name AS student_name,u.email,e.id AS exercise_id,e.title AS exercise_title,e.points AS max_points,ev.snapshot_json AS version_snapshot_json,ev.version_number AS version_number FROM submissions s JOIN users u ON u.id=s.user_id JOIN exercises e ON e.id=s.exercise_id LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id WHERE '.implode(' AND ',$where).' ORDER BY s.created_at DESC LIMIT 100');
$listStmt->execute($params); $submissions=$listStmt->fetchAll();
foreach ($submissions as &$submissionRow) { if (!empty($submissionRow['version_snapshot_json'])) { $historicalSnapshot=json_decode((string)$submissionRow['version_snapshot_json'],true); if (is_array($historicalSnapshot['exercise'] ?? null)) { $submissionRow['exercise_title']=(string)($historicalSnapshot['exercise']['title'] ?? $submissionRow['exercise_title']); $submissionRow['max_points']=max(1,(int)($historicalSnapshot['exercise']['points'] ?? $submissionRow['max_points'])); } } } unset($submissionRow);
page_header('Submission inspector');
?>
<section class="page-hero compact-page-hero"><div><p class="eyebrow">TEACHER STUDIO · CLASS RECORDS</p><h1>Submission inspector</h1><p class="muted"><?= $classroom ? e($classroom['name']).' · '.e($classroom['section']).' · ' : '' ?>Review actual source code and the stored test verdict summary for an individual submission.</p></div><div class="page-hero-actions"><a class="button secondary" href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Classrooms</a><?php if($classroomId): ?><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-gradebook.php?classroom_id=<?= $classroomId ?>">Back to gradebook ↗</a><?php endif; ?></div></section>
<?php if ($studentId && $exerciseId): ?><section class="panel v14-submission-scope"><div><span class="eyebrow">FILTERED RECORD</span><h2><?= e($student['name'] ?? '') ?> · <?= e($exercise['title'] ?? '') ?></h2><p class="muted"><?= e($student['email'] ?? '') ?> · Max score <?= (int)($exercise['points'] ?? 0) ?></p></div><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-submission.php?<?= e(http_build_query(array_filter(['classroom_id'=>$classroomId?:null,'student_id'=>$studentId,'exercise_id'=>$exerciseId]))) ?>">Clear selected submission ↗</a></section><?php endif; ?>
<?php if($detail): $scorePercent=(int)round((int)$detail['score']/max(1,(int)$detail['max_points'])*100); $results=json_decode((string)($detail['result_json'] ?? '[]'),true); if(!is_array($results))$results=[]; ?><section class="panel v14-submission-detail"><div class="v14-submission-detail-head"><div><p class="eyebrow">SUBMISSION #<?= (int)$detail['id'] ?></p><h2><?= e($detail['student_name']) ?> · <?= e($detail['exercise_title']) ?></h2><p class="muted"><?= e(strtoupper((string)$detail['language'])) ?><?= !empty($detail['version_number']) ? ' · Exercise version '.(int)$detail['version_number'] : '' ?> · <?= e(date('M j, Y · g:i:s A',strtotime((string)$detail['created_at']))) ?></p></div><div class="v14-inspector-score"><strong><?= (int)$detail['score'] ?>/<?= (int)$detail['max_points'] ?></strong><span><?= $scorePercent ?>% · <?= (int)$detail['passed_tests'] ?>/<?= (int)$detail['total_tests'] ?> tests</span></div></div><div class="v14-submission-code"><div class="v14-code-title"><strong>Submitted source code</strong><button type="button" class="button secondary small" id="copySubmissionCode">Copy source</button></div><pre id="submissionSource"><?= e($detail['source_code']) ?></pre></div><div class="v14-submission-verdicts"><div class="section-title"><div><h3>Stored test verdicts</h3><p class="muted">Only verdict summaries are saved here. Hidden test inputs and expected outputs are never exposed by this report.</p></div><span class="pill"><?= count($results) ?> results</span></div><?php if($results): ?><div class="v14-verdict-list"><?php foreach($results as $index=>$result): $passed=(bool)($result['passed']??false); ?><div class="v14-verdict-row"><span class="v14-verdict-icon <?= $passed?'passed':'failed' ?>"><?= $passed?'✓':'×' ?></span><div><strong><?= !empty($result['is_sample'])?'Public sample ':'Hidden test ' ?><?= (int)($result['number']??($index+1)) ?></strong><small><?= e((string)($result['verdict']??$result['status']??'Unknown')) ?></small></div><span class="grade-status-badge <?= $passed?'perfect':'needs_practice' ?>"><?= $passed?'Passed':'Failed' ?></span></div><?php endforeach; ?></div><?php else: ?><p class="muted">This older submission has no test verdict summary stored.</p><?php endif; ?></div></section><script>document.getElementById('copySubmissionCode')?.addEventListener('click',async()=>{const text=document.getElementById('submissionSource')?.textContent||'';try{await navigator.clipboard.writeText(text);document.getElementById('copySubmissionCode').textContent='Copied ✓';}catch(_e){window.prompt('Copy source code:',text);}});</script><?php endif; ?>
<?php if($detail): ?><section class="panel v23-regrade-panel"><div class="section-title"><div><h2>Regrade saved code</h2><p class="muted">Re-run this exact source code against the exercise's latest saved test cases and scoring rules.</p></div><span class="pill"><?= count($regradeHistory) ?> regrade<?= count($regradeHistory)===1?'':'s' ?></span></div><p class="muted">The source code is not changed. The prior score, test summary, and version are preserved in the regrade history. The gradebook and learning-path completion may update from the new result. This action uses Judge0 and may consume API quota.</p><form method="post" action="<?= e($config['base_url']) ?>/teacher-regrade.php" class="v23-stacked-form" onsubmit="return confirm('Regrade this submission against the latest saved test cases? The current score and official class record may change. The previous grading result will be archived.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="submission_id" value="<?= (int)$detail['id'] ?>"><label>Regrade reason (optional)<input name="reason" maxlength="500" placeholder="e.g. Corrected an expected output mistake"></label><label class="builder-option-row"><input type="checkbox" name="confirm_regrade" value="1" required><span><strong>I confirm this regrade</strong><small>Use the latest saved version of the exercise and retain the previous grading snapshot.</small></span></label><button class="button secondary" type="submit">Regrade with current version ↻</button></form><?php if($regradeHistory): ?><h3>Regrade history</h3><div class="v23-regrade-history"><?php foreach($regradeHistory as $historyRow): ?><article class="v23-regrade-history-row"><div><strong><?= (int)$historyRow['previous_score'] ?> → <?= (int)$historyRow['new_score'] ?> points</strong><p class="muted"><?= e($historyRow['teacher_name']) ?> · <?= e(date('M j, Y · g:i A',strtotime((string)$historyRow['regraded_at']))) ?></p><small class="muted"><?= (int)$historyRow['previous_passed_tests'] ?>/<?= (int)$historyRow['previous_total_tests'] ?> passed → <?= (int)$historyRow['new_passed_tests'] ?>/<?= (int)$historyRow['new_total_tests'] ?> passed<?= $historyRow['new_version_number'] ? ' · Version '.(int)$historyRow['new_version_number'] : '' ?></small><?php if(!empty($historyRow['reason'])): ?><p><?= e($historyRow['reason']) ?></p><?php endif; ?></div></article><?php endforeach; ?></div><?php endif; ?></section><?php endif; ?>
<?php if($detail): ?><section class="panel v23-feedback-panel"><div class="section-title"><div><h2>Feedback to student</h2><p class="muted">Give actionable guidance without changing the automatic score.</p></div><?php if($feedbackRow): ?><span class="pill"><?= e(str_replace('_',' ',$feedbackRow['feedback_type'])) ?></span><?php endif; ?></div>
<?php if($feedbackRow): ?><div class="v23-feedback-existing"><strong>Current feedback</strong><p><?= nl2br(e($feedbackRow['feedback_text'])) ?></p><small class="muted">Last updated <?= e(date('M j, Y · g:i A',strtotime((string)$feedbackRow['updated_at']))) ?></small></div><?php endif; ?>
<form method="post" class="v23-stacked-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="save_feedback"><input type="hidden" name="submission_id" value="<?= (int)$detail['id'] ?>"><?php foreach(['classroom_id'=>$classroomId,'student_id'=>(int)($detail['user_id']??0),'exercise_id'=>(int)($detail['exercise_id']??0)] as $key=>$value): ?><input type="hidden" name="<?= e($key) ?>" value="<?= (int)$value ?>"><?php endforeach; ?><label>Feedback type<select name="feedback_type"><option value="comment" <?= ($feedbackRow['feedback_type']??'')==='comment'?'selected':'' ?>>Comment</option><option value="needs_revision" <?= ($feedbackRow['feedback_type']??'')==='needs_revision'?'selected':'' ?>>Needs revision</option><option value="approved" <?= ($feedbackRow['feedback_type']??'')==='approved'?'selected':'' ?>>Approved</option></select></label><label>Feedback<textarea name="feedback_text" rows="4" maxlength="4000" required placeholder="Explain what went well or what the student should try next."><?= e($feedbackRow['feedback_text']??'') ?></textarea></label><button class="button" type="submit">Save feedback →</button></form></section><?php endif; ?>
<section class="panel v14-submission-list"><div class="section-title"><div><h2><?= $detail?'Other submissions in this view':'Recent submissions' ?></h2><p class="muted">Showing the latest 100 submissions in your teaching scope.</p></div><span class="pill"><?= count($submissions) ?> listed</span></div><?php if(!$submissions): ?><div class="empty compact-empty"><h3>No saved submissions yet</h3><p>When students submit solutions to your exercises, they will appear here.</p></div><?php else: ?><div class="table-wrap"><table><thead><tr><th>Student</th><th>Exercise</th><th>Language</th><th>Score</th><th>Tests</th><th>Submitted</th><th></th></tr></thead><tbody><?php foreach($submissions as $row): $params=['submission_id'=>(int)$row['id']]; if($classroomId)$params['classroom_id']=$classroomId; if($studentId)$params['student_id']=$studentId; if($exerciseId)$params['exercise_id']=$exerciseId; ?><tr><td><strong><?= e($row['student_name']) ?></strong><small class="muted block"><?= e($row['email']) ?></small></td><td><?= e($row['exercise_title']) ?></td><td><?= e(strtoupper($row['language'])) ?></td><td><strong><?= (int)$row['score'] ?>/<?= (int)$row['max_points'] ?></strong></td><td><?= (int)$row['passed_tests'] ?>/<?= (int)$row['total_tests'] ?></td><td><?= e(date('M j, Y · g:i A',strtotime((string)$row['created_at']))) ?></td><td><a class="button small secondary" href="<?= e($config['base_url']) ?>/teacher-submission.php?<?= e(http_build_query($params)) ?>">Inspect</a></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?></section>
<p class="v14-privacy-note">Submission source code can contain student work. It is visible only to the teacher who owns the exercise. Stored test results show verdict summaries, not hidden test values.</p>
<?php page_footer(); ?>
