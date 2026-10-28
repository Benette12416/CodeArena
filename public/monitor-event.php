<?php
require_once __DIR__ . '/../app/bootstrap.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');

function monitor_fail(string $message, int $status = 400): never {
    http_response_code($status);
    echo json_encode(['ok' => false, 'error' => $message], JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

$user = current_user();
if (!$user) monitor_fail('Please sign in again.', 401);
if (($user['role'] ?? '') !== 'student') monitor_fail('Only student accounts can record exam events.', 403);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') monitor_fail('POST required.', 405);
$postedToken = $_POST['_csrf'] ?? '';
$sessionToken = $_SESSION['_csrf'] ?? '';
if (!is_string($postedToken) || !is_string($sessionToken) || $postedToken === '' || !hash_equals($sessionToken, $postedToken)) {
    monitor_fail('Your session token expired. Refresh the exam page.', 419);
}

$exerciseId = filter_var($_POST['exercise_id'] ?? null, FILTER_VALIDATE_INT);
$type = (string)($_POST['event_type'] ?? '');
$allowedTypes = ['tab_hidden', 'copy', 'cut', 'paste', 'fullscreen_exit'];
if (!$exerciseId || !in_array($type, $allowedTypes, true)) monitor_fail('Invalid monitoring event.');

$stmt = $pdo->prepare('SELECT id, is_published FROM exercises WHERE id=?');
$stmt->execute([(int)$exerciseId]);
$exercise = $stmt->fetch();
if (!$exercise || (int)$exercise['is_published'] !== 1) monitor_fail('Exercise not found or no longer available.', 404);

$accessContext = student_exercise_access_context($pdo, (int)$user['id'], (int)$exerciseId);
if (!$accessContext['allowed']) monitor_fail('You no longer have access to this exercise.', 403);

$stmt = $pdo->prepare('SELECT id, status, deadline_at, monitoring_enabled, warning_threshold, started_explicitly FROM attempts WHERE user_id=? AND exercise_id=?');
$stmt->execute([(int)$user['id'], (int)$exerciseId]);
$attempt = $stmt->fetch();
if (!$attempt || (int)($attempt['started_explicitly'] ?? 0) !== 1) monitor_fail('No started attempt was found.', 409);
if ((int)$attempt['monitoring_enabled'] !== 1) monitor_fail('Monitoring was not enabled when this attempt started.', 403);
$deadlineTs = strtotime((string)$attempt['deadline_at']);
if (!empty($accessContext['due_at'])) $deadlineTs = min($deadlineTs, strtotime((string)$accessContext['due_at']));
if ($attempt['status'] !== 'in_progress' || $deadlineTs <= time()) {
    if ($attempt['status'] === 'in_progress') {
        $pdo->prepare("UPDATE attempts SET status='expired' WHERE id=? AND status='in_progress'")->execute([(int)$attempt['id']]);
    }
    monitor_fail('This exam attempt is no longer active.', 410);
}

// Keep event storms from malfunctioning clients from flooding the database.
$stmt = $pdo->prepare('SELECT COUNT(*) FROM monitor_events WHERE attempt_id=? AND created_at >= (NOW() - INTERVAL 1 MINUTE)');
$stmt->execute([(int)$attempt['id']]);
if ((int)$stmt->fetchColumn() >= 40) monitor_fail('Too many monitoring events in a short period.', 429);

$stmt = $pdo->prepare('INSERT INTO monitor_events(attempt_id,user_id,exercise_id,event_type) VALUES(?,?,?,?)');
$stmt->execute([(int)$attempt['id'], (int)$user['id'], (int)$exerciseId, $type]);
$stmt = $pdo->prepare('SELECT COUNT(*) FROM monitor_events WHERE attempt_id=?');
$stmt->execute([(int)$attempt['id']]);
$count = (int)$stmt->fetchColumn();
$threshold = max(1, min(10, (int)$attempt['warning_threshold']));

echo json_encode([
    'ok' => true,
    'event_count' => $count,
    'threshold' => $threshold,
    'threshold_reached' => $count >= $threshold,
    'event_type' => $type,
    'saved_at' => date('c'),
], JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);
