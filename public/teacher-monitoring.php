<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$exerciseId = max(0, (int)($_GET['exercise_id'] ?? $_POST['filter_exercise_id'] ?? 0));
$eventType = (string)($_GET['event_type'] ?? $_POST['filter_event_type'] ?? 'all');
$allowedEventTypes = ['all','tab_hidden','copy','cut','paste','fullscreen_exit'];
if (!in_array($eventType, $allowedEventTypes, true)) $eventType = 'all';

function teacher_monitoring_redirect(int $exerciseId, string $eventType): never {
    $query = [];
    if ($exerciseId > 0) $query['exercise_id'] = $exerciseId;
    if ($eventType !== 'all') $query['event_type'] = $eventType;
    redirect('teacher-monitoring.php' . ($query ? '?' . http_build_query($query) : ''));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');

    if ($action === 'delete_event') {
        $eventId = max(0, (int)($_POST['event_id'] ?? 0));
        $find = $pdo->prepare('SELECT me.id, me.attempt_id, me.exercise_id FROM monitor_events me JOIN exercises e ON e.id=me.exercise_id WHERE me.id=? AND e.created_by=?');
        $find->execute([$eventId, (int)$user['id']]);
        $event = $find->fetch();
        if (!$event) {
            flash('Monitoring event not found or you do not have permission to delete it.', 'error');
            teacher_monitoring_redirect($exerciseId, $eventType);
        }
        try {
            $pdo->beginTransaction();
            $delete = $pdo->prepare('DELETE FROM monitor_events WHERE id=? AND exercise_id=?');
            $delete->execute([$eventId, (int)$event['exercise_id']]);
            if ($delete->rowCount() !== 1) {
                $pdo->rollBack();
                flash('This monitoring event was already deleted. Refresh the report and try again.', 'info');
                teacher_monitoring_redirect($exerciseId, $eventType);
            }
            $remaining = $pdo->prepare('SELECT COUNT(*) FROM monitor_events WHERE attempt_id=?');
            $remaining->execute([(int)$event['attempt_id']]);
            if ((int)$remaining->fetchColumn() === 0) {
                // Remove the review attached to an attempt only when its final event is removed.
                $review = $pdo->prepare('DELETE FROM monitor_reviews WHERE attempt_id=? AND teacher_id=?');
                $review->execute([(int)$event['attempt_id'], (int)$user['id']]);
            }
            $pdo->commit();
            audit_log($pdo, (int)$user['id'], 'monitor_event_deleted', 'monitor_event', $eventId, ['exercise_id'=>(int)$event['exercise_id']]);
            flash('Monitoring event deleted. Student grades and attempt scores were not changed.', 'success');
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            flash('Could not delete the monitoring event. No changes were saved.', 'error');
        }
        teacher_monitoring_redirect($exerciseId, $eventType);
    }

    if ($action === 'delete_all_events') {
        try {
            $pdo->beginTransaction();
            $delete = $pdo->prepare('DELETE me FROM monitor_events me INNER JOIN exercises e ON e.id=me.exercise_id WHERE e.created_by=?');
            $delete->execute([(int)$user['id']]);
            $deletedCount = $delete->rowCount();
            // Reviews are part of the monitoring log workflow, so clear notes for this teacher's attempts too.
            $reviews = $pdo->prepare('DELETE mr FROM monitor_reviews mr INNER JOIN attempts a ON a.id=mr.attempt_id INNER JOIN exercises e ON e.id=a.exercise_id WHERE e.created_by=? AND mr.teacher_id=?');
            $reviews->execute([(int)$user['id'], (int)$user['id']]);
            $pdo->commit();
            audit_log($pdo, (int)$user['id'], 'monitor_logs_deleted_all', 'monitoring', null, ['deleted_events'=>$deletedCount]);
            flash('Deleted ' . $deletedCount . ' monitoring event' . ($deletedCount === 1 ? '' : 's') . ' and the related review notes for your exercises. Student grades and attempts were not changed.', 'success');
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            flash('Could not delete the monitoring logs. No changes were saved.', 'error');
        }
        // A delete-all action clears the whole teacher-owned monitoring log, regardless of filters.
        teacher_monitoring_redirect(0, 'all');
    }

    if ($action === 'save_review') {
        $attemptId = max(0, (int)($_POST['attempt_id'] ?? 0));
        $reviewStatus = (string)($_POST['review_status'] ?? 'pending');
        $notes = trim((string)($_POST['review_notes'] ?? ''));
        if (!in_array($reviewStatus, ['pending','reviewed','cleared','follow_up'], true)) {
            flash('Choose a valid monitoring review status.', 'error');
            redirect('teacher-monitoring.php' . ($exerciseId ? '?exercise_id=' . $exerciseId : ''));
        }
        if (mb_strlen($notes) > 3000) {
            flash('Review notes must be 3,000 characters or fewer.', 'error');
            redirect('teacher-monitoring.php' . ($exerciseId ? '?exercise_id=' . $exerciseId : ''));
        }
        $ownership = $pdo->prepare('SELECT a.id FROM attempts a JOIN exercises e ON e.id=a.exercise_id WHERE a.id=? AND e.created_by=? AND a.monitoring_enabled=1');
        $ownership->execute([$attemptId, (int)$user['id']]);
        if (!$ownership->fetchColumn()) {
            flash('This monitored attempt was not found in your exercises.', 'error');
            redirect('teacher-monitoring.php' . ($exerciseId ? '?exercise_id=' . $exerciseId : ''));
        }
        $save = $pdo->prepare("INSERT INTO monitor_reviews (attempt_id,teacher_id,review_status,notes,reviewed_at)
            VALUES (?,?,?,?,IF(?='pending',NULL,CURRENT_TIMESTAMP))
            ON DUPLICATE KEY UPDATE review_status=VALUES(review_status), notes=VALUES(notes), reviewed_at=IF(VALUES(review_status)='pending',NULL,CURRENT_TIMESTAMP)");
        $save->execute([$attemptId, (int)$user['id'], $reviewStatus, $notes !== '' ? $notes : null, $reviewStatus]);
        audit_log($pdo, (int)$user['id'], 'monitor_review_saved', 'attempt', $attemptId, ['review_status'=>$reviewStatus]);
        flash('Monitoring review saved. This does not change the student grade.', 'success');
        teacher_monitoring_redirect($exerciseId, $eventType);
    }
}

$stmt = $pdo->prepare('SELECT id, title, monitoring_enabled, warning_threshold FROM exercises WHERE created_by=? ORDER BY created_at DESC');
$stmt->execute([(int)$user['id']]);
$exercises = $stmt->fetchAll();
$ownIds = array_map(static fn($e) => (int)$e['id'], $exercises);
if ($exerciseId && !in_array($exerciseId, $ownIds, true)) $exerciseId = 0;
$where = 'e.created_by=?';
$params = [(int)$user['id']];
if ($exerciseId) { $where .= ' AND e.id=?'; $params[] = $exerciseId; }

$stmt = $pdo->prepare("SELECT COUNT(me.id) AS event_count, COUNT(DISTINCT me.attempt_id) AS attempts_count, COUNT(DISTINCT me.user_id) AS student_count FROM monitor_events me JOIN exercises e ON e.id=me.exercise_id WHERE $where");
$stmt->execute($params);
$stats = $stmt->fetch() ?: ['event_count'=>0,'attempts_count'=>0,'student_count'=>0];

$stmt = $pdo->prepare("SELECT e.id AS exercise_id, e.title, a.warning_threshold, a.monitoring_enabled, u.id AS user_id, u.name AS student_name, u.email, a.id AS attempt_id, a.best_score, a.status AS attempt_status, a.started_at, a.deadline_at,
    COUNT(me.id) AS event_count,
    SUM(me.event_type='tab_hidden') AS tab_hidden_count,
    SUM(me.event_type='copy') AS copy_count,
    SUM(me.event_type='cut') AS cut_count,
    SUM(me.event_type='paste') AS paste_count,
    SUM(me.event_type='fullscreen_exit') AS fullscreen_exit_count,
    MAX(me.created_at) AS last_event,
    COALESCE(mr.review_status,'pending') AS review_status, mr.notes AS review_notes, mr.reviewed_at
    FROM exercises e
    JOIN attempts a ON a.exercise_id=e.id AND a.monitoring_enabled=1
    JOIN users u ON u.id=a.user_id
    LEFT JOIN monitor_events me ON me.attempt_id=a.id
    LEFT JOIN monitor_reviews mr ON mr.attempt_id=a.id AND mr.teacher_id=e.created_by
    WHERE $where
    GROUP BY e.id,e.title,a.warning_threshold,a.monitoring_enabled,u.id,u.name,u.email,a.id,a.best_score,a.status,a.started_at,a.deadline_at,mr.review_status,mr.notes,mr.reviewed_at
    HAVING COUNT(me.id)>0 ORDER BY (COUNT(me.id)>=a.warning_threshold) DESC, last_event DESC LIMIT 200");
$stmt->execute($params);
$attemptRows = $stmt->fetchAll();
$flaggedAttempts = count(array_filter($attemptRows, static fn(array $row): bool => (int)$row['event_count'] >= max(1,(int)$row['warning_threshold'])));
$pendingReviews = count(array_filter($attemptRows, static fn(array $row): bool => (int)$row['event_count'] >= max(1,(int)$row['warning_threshold']) && $row['review_status'] === 'pending'));

$eventWhere = $where;
$eventParams = $params;
if ($eventType !== 'all') { $eventWhere .= ' AND me.event_type=?'; $eventParams[] = $eventType; }
$stmt = $pdo->prepare("SELECT me.id AS event_id, me.event_type, me.created_at, u.name AS student_name, u.email, e.title AS exercise_title, me.attempt_id FROM monitor_events me JOIN exercises e ON e.id=me.exercise_id JOIN users u ON u.id=me.user_id WHERE $eventWhere ORDER BY me.created_at DESC LIMIT 150");
$stmt->execute($eventParams);
$eventRows = $stmt->fetchAll();
$labels = ['tab_hidden'=>'Exam tab hidden','copy'=>'Copy action','cut'=>'Cut action','paste'=>'Paste action','fullscreen_exit'=>'Fullscreen exited'];
if (($_GET['export'] ?? '') === 'csv') {
    $csvCell = static function (mixed $value): string { $text = (string)($value ?? ''); return preg_match('/^\s*[=+\-@]/', $text) ? "'".$text : $text; };
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="codearena-monitoring-events.csv"');
    $out = fopen('php://output', 'w'); fprintf($out, chr(0xEF).chr(0xBB).chr(0xBF));
    fputcsv($out, ['Timestamp','Student','Email','Exercise','Event','Attempt ID']);
    foreach ($eventRows as $row) fputcsv($out, array_map($csvCell, [$row['created_at'],$row['student_name'],$row['email'],$row['exercise_title'],$labels[$row['event_type']] ?? $row['event_type'],$row['attempt_id']]));
    fclose($out); exit;
}
page_header('Exam monitoring reports');
?>
<section class="page-hero compact-page-hero monitoring-page-hero"><div><p class="eyebrow">TEACHER STUDIO · EXAM INTEGRITY</p><h1>Exam monitoring</h1><p class="muted">Review browser events recorded during monitored attempts. Events are indicators for review, not proof of cheating, and never automatically change grades.</p></div><div class="page-hero-actions"><a class="button" href="<?= e($config['base_url']) ?>/teacher.php#exercise-library">Manage exercises ↗</a><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-classrooms.php">Classrooms ↗</a></div></section>
<div class="monitor-report-toolbar panel"><form method="get" class="monitor-filter"><label>Exercise<select name="exercise_id"><option value="0">All your exercises</option><?php foreach($exercises as $ex): ?><option value="<?= (int)$ex['id'] ?>" <?= $exerciseId===(int)$ex['id']?'selected':'' ?>><?= e($ex['title']) ?></option><?php endforeach; ?></select></label><label>Event type<select name="event_type"><option value="all" <?= $eventType==='all'?'selected':'' ?>>All event types</option><?php foreach($labels as $key=>$label): ?><option value="<?= e($key) ?>" <?= $eventType===$key?'selected':'' ?>><?= e($label) ?></option><?php endforeach; ?></select></label><button class="button" type="submit">Apply filters</button><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-monitoring.php">Reset</a></form><div class="monitor-toolbar-actions"><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-monitoring.php?<?= e(http_build_query(array_filter(['exercise_id'=>$exerciseId ?: null,'event_type'=>$eventType!=='all'?$eventType:null,'export'=>'csv']))) ?>">Export event log ↓</a><form method="post" class="monitor-delete-all-form" onsubmit="return confirm('Permanently delete ALL monitoring events and related review notes for all of your exercises? This cannot be undone. Student grades and attempts will remain unchanged.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_all_events"><input type="hidden" name="filter_exercise_id" value="<?= $exerciseId ?>"><input type="hidden" name="filter_event_type" value="<?= e($eventType) ?>"><button class="button danger small" type="submit">Delete all logs</button></form></div></div>
<div class="monitor-stats"><article class="panel monitor-stat"><span class="muted">Recorded events</span><strong><?= (int)$stats['event_count'] ?></strong><small>All events in selected scope</small></article><article class="panel monitor-stat"><span class="muted">Attempts with events</span><strong><?= (int)$stats['attempts_count'] ?></strong><small>Unique monitored attempts</small></article><article class="panel monitor-stat"><span class="muted">Threshold reached</span><strong><?= $flaggedAttempts ?></strong><small>Attempts at or above threshold</small></article><article class="panel monitor-stat"><span class="muted">Pending reviews</span><strong><?= $pendingReviews ?></strong><small>Teacher decision still needed</small></article></div>
<section class="panel monitor-report-panel"><div class="section-title"><div><h2>Attempt review</h2><p class="muted">Save a review status and optional notes. Review actions do not alter scores or attempt outcomes.</p></div><span class="pill"><?= count($attemptRows) ?> attempts</span></div>
<?php if(!$attemptRows): ?><div class="monitor-empty"><strong>No monitoring events to review</strong><p class="muted">No events match the current filters. Check that monitoring is enabled for the exercise and test it with a new student attempt.</p><a class="button small" href="<?= e($config['base_url']) ?>/teacher.php#exercise-library">Check exercise settings</a></div><?php else: ?><div class="monitor-attempt-list"><?php foreach($attemptRows as $r): $threshold=max(1,(int)$r['warning_threshold']); $reached=(int)$r['event_count'] >= $threshold; $statusLabels=['pending'=>$reached?'Needs review':'Not reviewed','reviewed'=>'Reviewed','cleared'=>'Cleared','follow_up'=>'Follow-up']; ?><article class="monitor-attempt-card"><div class="monitor-attempt-overview"><div class="monitor-student-identity"><span class="leaderboard-mini-avatar"><?= e(strtoupper(mb_substr((string)$r['student_name'],0,1))) ?></span><div><strong><?= e($r['student_name']) ?></strong><small><?= e($r['email']) ?> · Attempt #<?= (int)$r['attempt_id'] ?></small></div></div><span class="monitor-status <?= $reached?'review':'below' ?>"><?= $reached?'Threshold reached':'Below threshold' ?></span></div><div class="monitor-attempt-meta"><span><strong><?= (int)$r['event_count'] ?></strong> events / threshold <?= $threshold ?></span><span><?= e($r['title']) ?></span><span>Last event: <?= e($r['last_event']) ?></span><span>Score: <?= (int)$r['best_score'] ?></span></div><div class="monitor-breakdown"><span>Tab hidden: <?= (int)$r['tab_hidden_count'] ?></span><span>Copy: <?= (int)$r['copy_count'] ?></span><span>Cut: <?= (int)$r['cut_count'] ?></span><span>Paste: <?= (int)$r['paste_count'] ?></span><span>Fullscreen exit: <?= (int)$r['fullscreen_exit_count'] ?></span></div><form method="post" class="monitor-review-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="save_review"><input type="hidden" name="attempt_id" value="<?= (int)$r['attempt_id'] ?>"><input type="hidden" name="filter_exercise_id" value="<?= $exerciseId ?>"><div class="monitor-review-fields"><label>Review status<select name="review_status"><?php foreach($statusLabels as $value=>$label): ?><option value="<?= e($value) ?>" <?= $r['review_status']===$value?'selected':'' ?>><?= e($label) ?></option><?php endforeach; ?></select></label><label>Teacher notes<textarea name="review_notes" rows="2" maxlength="3000" placeholder="Optional context or follow-up note"><?= e($r['review_notes'] ?? '') ?></textarea></label><div class="monitor-review-action"><button class="button small" type="submit">Save review</button><?php if ($r['reviewed_at']): ?><small class="muted">Updated <?= e(date('M j, Y · g:i A',strtotime((string)$r['reviewed_at']))) ?></small><?php endif; ?></div></div></form></article><?php endforeach; ?></div><?php endif; ?></section>
<section class="panel monitor-report-panel"><div class="section-title"><div><h2>Recent event timeline</h2><p class="muted">The log stores event types and timestamps, not the text students copied or pasted.</p></div><span class="pill"><?= count($eventRows) ?> listed</span></div><?php if(!$eventRows): ?><p class="muted">No events for this filter.</p><?php else: ?><div class="table-wrap"><table><thead><tr><th>When</th><th>Student</th><th>Exercise</th><th>Event</th><th>Attempt</th><th>Actions</th></tr></thead><tbody><?php foreach($eventRows as $r): ?><tr><td><?= e(date('M j, Y · g:i:s A',strtotime((string)$r['created_at']))) ?></td><td><strong><?= e($r['student_name']) ?></strong><div class="muted"><?= e($r['email']) ?></div></td><td><?= e($r['exercise_title']) ?></td><td><?= e($labels[$r['event_type']] ?? $r['event_type']) ?></td><td>#<?= (int)$r['attempt_id'] ?></td><td><form method="post" class="monitor-delete-event-form" onsubmit="return confirm('Delete this monitoring event permanently? If it is the last event for the attempt, its related review note will also be deleted. Grades will not change.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_event"><input type="hidden" name="event_id" value="<?= (int)$r['event_id'] ?>"><input type="hidden" name="filter_exercise_id" value="<?= $exerciseId ?>"><input type="hidden" name="filter_event_type" value="<?= e($eventType) ?>"><button class="button danger small" type="submit">Delete</button></form></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?></section>
<div class="monitor-privacy-note"><strong>Privacy and fair review</strong><p class="muted">Monitoring detects only supported browser events on the CodeArena exam page. It cannot observe other applications, prove misconduct, or guarantee lockdown. Review surrounding context and speak with the student before making a decision. Review notes are visible only to the teacher who owns the exercise.</p></div>
<?php page_footer(); ?>
