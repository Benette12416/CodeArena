<?php
declare(strict_types=1);

function e(mixed $value): string {
    return htmlspecialchars((string)($value ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** Safely inspect optional schema features so pages can explain or gracefully
 * degrade when an existing database has not yet received a newer migration. */
function codearena_table_exists(PDO $pdo, string $table): bool {
    static $cache = [];
    $key = strtolower($table);
    if (array_key_exists($key, $cache)) return $cache[$key];
    try {
        $stmt = $pdo->prepare('SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ? LIMIT 1');
        $stmt->execute([$table]);
        return $cache[$key] = (bool)$stmt->fetchColumn();
    } catch (Throwable $ignored) {
        return $cache[$key] = false;
    }
}

function codearena_column_exists(PDO $pdo, string $table, string $column): bool {
    static $cache = [];
    $key = strtolower($table . '.' . $column);
    if (array_key_exists($key, $cache)) return $cache[$key];
    // These identifiers are supplied by the application, never directly by a request.
    try {
        $stmt = $pdo->prepare('SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ? LIMIT 1');
        $stmt->execute([$table, $column]);
        return $cache[$key] = (bool)$stmt->fetchColumn();
    } catch (Throwable $ignored) {
        return $cache[$key] = false;
    }
}

function redirect(string $path): never {
    global $config;
    header('Location: ' . rtrim($config['base_url'], '/') . '/' . ltrim($path, '/'));
    exit;
}

function csrf_token(): string {
    if (empty($_SESSION['_csrf'])) {
        $_SESSION['_csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['_csrf'];
}

function verify_csrf(): void {
    $token = $_POST['_csrf'] ?? '';
    $sessionToken = $_SESSION['_csrf'] ?? null;
    if (!is_string($token) || $token === '' || !is_string($sessionToken) || $sessionToken === '' || !hash_equals($sessionToken, $token)) {
        http_response_code(419);
        exit('Your session token expired. Refresh the page and try again.');
    }
}

function current_user(): ?array {
    global $pdo;
    if (!isset($_SESSION['user']) || !is_array($_SESSION['user'])) return null;
    // Normalize legacy sessions after upgrading the old 'admin' role.
    if (($_SESSION['user']['role'] ?? '') === 'admin') $_SESSION['user']['role'] = 'super_admin';
    $id = (int)($_SESSION['user']['id'] ?? 0);
    static $verifiedActiveUsers = [];
    if ($id > 0 && !isset($verifiedActiveUsers[$id]) && isset($pdo) && $pdo instanceof PDO
        && codearena_column_exists($pdo, 'users', 'is_active')) {
        $verifiedActiveUsers[$id] = true;
        try {
            $stmt = $pdo->prepare('SELECT is_active FROM users WHERE id=? LIMIT 1');
            $stmt->execute([$id]);
            $active = $stmt->fetchColumn();
            if ($active === false || (int)$active !== 1) {
                unset($_SESSION['user']);
                $_SESSION['_flash'] = ['message'=>'Your account is inactive. Contact the site administrator if you believe this is an error.','type'=>'error'];
                return null;
            }
        } catch (Throwable $ignored) {
            // Authentication pages still load if the optional account-status column is not installed.
        }
    }
    return $_SESSION['user'];
}

function role_home_path(string $role): string {
    return match ($role) {
        'teacher' => 'teacher.php',
        'super_admin', 'admin' => 'super-admin/index.php',
        default => 'index.php',
    };
}

function role_login_path(string $role): string {
    return match ($role) {
        'teacher' => 'teacher-login.php',
        'super_admin', 'admin' => 'super-admin/login.php',
        default => 'login.php',
    };
}

function redirect_to_user_home(?array $user = null): never {
    $user ??= current_user();
    redirect($user ? role_home_path((string)$user['role']) : 'login.php');
}

function require_login(): array {
    $user = current_user();
    if (!$user) {
        redirect('login.php');
    }
    return $user;
}

function require_role(array $roles): array {
    $user = current_user();
    if (!$user) {
        $requestedRole = in_array('super_admin', $roles, true) ? 'super_admin'
            : (in_array('teacher', $roles, true) ? 'teacher' : 'student');
        redirect(role_login_path($requestedRole));
    }
    if (!in_array($user['role'], $roles, true)) {
        flash('You were redirected to the correct portal for your account.', 'info');
        redirect(role_home_path((string)$user['role']));
    }
    return $user;
}

function flash(string $message, string $type = 'info'): void {
    $_SESSION['_flash'] = ['message' => $message, 'type' => $type];
}

function consume_flash(): ?array {
    $f = $_SESSION['_flash'] ?? null;
    unset($_SESSION['_flash']);
    return $f;
}

function slugify(string $text): string {
    $slug = strtolower(trim((string)preg_replace('/[^A-Za-z0-9-]+/', '-', $text), '-'));
    return $slug !== '' ? $slug : 'exercise-' . bin2hex(random_bytes(4));
}

function normalize_output(string $s): string {
    return trim(str_replace(["\r\n", "\r"], "\n", $s));
}


/** Generate a short, human-readable, unique class join code. */
function generate_class_join_code(PDO $pdo): string {
    $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for ($attempt = 0; $attempt < 20; $attempt++) {
        $code = '';
        for ($i = 0; $i < 8; $i++) {
            $code .= $alphabet[random_int(0, strlen($alphabet) - 1)];
        }
        $check = $pdo->prepare('SELECT 1 FROM classrooms WHERE join_code = ? LIMIT 1');
        $check->execute([$code]);
        if (!$check->fetchColumn()) return $code;
    }
    throw new RuntimeException('Could not generate a unique class join code. Please try again.');
}

/**
 * Determine whether a student can open an actively assigned classroom exercise.
 * Unassigned or removed assignments return `restricted=false` and should be opened
 * through Practice Mode; graded execution endpoints must require `restricted=true`.
 * If multiple enrolled classes have the same exercise, a no-deadline assignment
 * takes precedence; otherwise the earliest still-open deadline is used.
 */
function student_exercise_access_context(PDO $pdo, int $studentId, int $exerciseId): array {
    $assigned = $pdo->prepare('SELECT 1 FROM class_assignments WHERE exercise_id = ? AND is_active = 1 LIMIT 1');
    $assigned->execute([$exerciseId]);
    $isRestricted = (bool)$assigned->fetchColumn();
    if (!$isRestricted) return ['allowed' => true, 'restricted' => false, 'due_at' => null];

    $hasOverrides = codearena_table_exists($pdo, 'student_assignment_overrides');
    $dueExpr = $hasOverrides ? 'COALESCE(sao.extended_due_at, ca.due_at)' : 'ca.due_at';
    $overrideJoin = $hasOverrides ? 'LEFT JOIN student_assignment_overrides sao ON sao.assignment_id=ca.id AND sao.student_id=?' : '';
    $stmt = $pdo->prepare("SELECT {$dueExpr} AS due_at
        FROM class_assignments ca
        JOIN classrooms c ON c.id = ca.classroom_id AND c.is_active = 1
        JOIN class_enrollments ce ON ce.classroom_id = c.id AND ce.student_id = ? AND ce.enrollment_status = 'active'
        {$overrideJoin}
        WHERE ca.exercise_id = ? AND ca.is_active = 1
          AND ({$dueExpr} IS NULL OR {$dueExpr} >= NOW())");
    $stmt->execute($hasOverrides ? [$studentId, $studentId, $exerciseId] : [$studentId, $exerciseId]);
    $rows = $stmt->fetchAll();
    if (!$rows) return ['allowed' => false, 'restricted' => true, 'due_at' => null];

    foreach ($rows as $row) {
        if ($row['due_at'] === null) return ['allowed' => true, 'restricted' => true, 'due_at' => null];
    }
    $deadlines = array_values(array_filter(array_column($rows, 'due_at')));
    sort($deadlines);
    return ['allowed' => true, 'restricted' => true, 'due_at' => $deadlines[0] ?? null];
}

/** Recalculate a grade record using the exercise-version maximum tied to the student's best submission. */
function sync_assignment_grade(PDO $pdo, int $assignmentId, int $studentId): void {
    $assignmentStmt = $pdo->prepare("SELECT ca.id,ca.exercise_id,ca.created_at,e.points AS current_points,ce.joined_at
        FROM class_assignments ca
        JOIN exercises e ON e.id=ca.exercise_id
        JOIN classrooms c ON c.id=ca.classroom_id
        JOIN class_enrollments ce ON ce.classroom_id=ca.classroom_id AND ce.student_id=? AND ce.enrollment_status='active'
        WHERE ca.id=? LIMIT 1");
    $assignmentStmt->execute([$studentId,$assignmentId]);
    $assignment = $assignmentStmt->fetch();
    if (!$assignment) return;

    $submissionsStmt = $pdo->prepare("SELECT s.score,s.created_at,ev.snapshot_json
        FROM submissions s
        LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id
        WHERE s.user_id=? AND s.exercise_id=? AND s.created_at >= GREATEST(?,?)
        ORDER BY s.score DESC,s.created_at DESC,s.id DESC");
    $submissionsStmt->execute([$studentId,(int)$assignment['exercise_id'],(string)$assignment['created_at'],(string)$assignment['joined_at']]);
    $submissions = $submissionsStmt->fetchAll();
    $bestScore = 0;
    $maxScore = max(1,(int)$assignment['current_points']);
    $lastSubmitted = null;
    $submissionCount = count($submissions);
    if ($submissions) {
        $bestScore = (int)$submissions[0]['score'];
        $lastSubmitted = max(array_map(static fn(array $r): string => (string)$r['created_at'],$submissions));
        if (!empty($submissions[0]['snapshot_json'])) {
            $snapshot = json_decode((string)$submissions[0]['snapshot_json'],true);
            $historicalPoints = $snapshot['exercise']['points'] ?? null;
            if (is_numeric($historicalPoints)) $maxScore = max(1,(int)$historicalPoints);
        }
    }
    $upsert = $pdo->prepare("INSERT INTO grade_records(assignment_id,student_id,best_score,max_score,submission_count,last_submitted_at)
        VALUES(?,?,?,?,?,?) ON DUPLICATE KEY UPDATE best_score=VALUES(best_score),max_score=VALUES(max_score),submission_count=VALUES(submission_count),last_submitted_at=VALUES(last_submitted_at),updated_at=CURRENT_TIMESTAMP");
    $upsert->execute([$assignmentId,$studentId,$bestScore,$maxScore,$submissionCount,$lastSubmitted]);
}

/** Refresh grade records for all active assignments and enrollments in a classroom. */
function sync_classroom_grades(PDO $pdo, int $classroomId): void {
    $stmt = $pdo->prepare("SELECT ca.id AS assignment_id,ce.student_id
        FROM class_assignments ca
        JOIN class_enrollments ce ON ce.classroom_id=ca.classroom_id AND ce.enrollment_status='active'
        WHERE ca.classroom_id=? AND ca.is_active=1 ORDER BY ca.id,ce.student_id");
    $stmt->execute([$classroomId]);
    foreach ($stmt->fetchAll() as $row) sync_assignment_grade($pdo,(int)$row['assignment_id'],(int)$row['student_id']);
}

/** Return the next accessible exercise in the current classroom, or the public arena, that is not perfected yet. */
function student_next_incomplete_exercise_url(PDO $pdo, int $studentId, int $currentExerciseId): ?string {
    global $config;

    // When the current exercise belongs to a classroom, continue within that class first.
    $currentClassStmt = $pdo->prepare("SELECT ca.classroom_id
        FROM class_assignments ca
        JOIN classrooms c ON c.id = ca.classroom_id AND c.is_active = 1
        JOIN class_enrollments ce ON ce.classroom_id = c.id AND ce.student_id = ? AND ce.enrollment_status = 'active'
        WHERE ca.exercise_id = ? AND ca.is_active = 1
          AND (ca.due_at IS NULL OR ca.due_at >= NOW())
        ORDER BY ca.created_at DESC, ca.id DESC
        LIMIT 1");
    $currentClassStmt->execute([$studentId, $currentExerciseId]);
    $currentClassroomId = $currentClassStmt->fetchColumn();

    if ($currentClassroomId) {
        $stmt = $pdo->prepare("SELECT e.id, e.points, a.status AS attempt_status, a.best_score, a.deadline_at
            FROM class_assignments ca
            JOIN classrooms c ON c.id = ca.classroom_id AND c.is_active = 1
            JOIN exercises e ON e.id = ca.exercise_id AND e.is_published = 1
            LEFT JOIN attempts a ON a.exercise_id = e.id AND a.user_id = ?
            WHERE ca.classroom_id = ? AND ca.is_active = 1
              AND (ca.due_at IS NULL OR ca.due_at >= NOW())
            ORDER BY CASE WHEN e.id > ? THEN 0 ELSE 1 END, e.id ASC");
        $stmt->execute([$studentId, (int)$currentClassroomId, $currentExerciseId]);
    } else {
        $stmt = $pdo->prepare("SELECT e.id, e.points, a.status AS attempt_status, a.best_score, a.deadline_at
            FROM exercises e
            LEFT JOIN attempts a ON a.exercise_id = e.id AND a.user_id = ?
            WHERE e.is_published = 1 AND e.id <> ?
            ORDER BY CASE WHEN e.id > ? THEN 0 ELSE 1 END, e.id ASC");
        $stmt->execute([$studentId, $currentExerciseId, $currentExerciseId]);
    }

    foreach ($stmt->fetchAll() as $candidate) {
        $candidateId = (int)$candidate['id'];
        if ($candidateId === $currentExerciseId) continue;
        $context = student_exercise_access_context($pdo, $studentId, $candidateId);
        if (!$context['allowed']) continue;

        $points = max(1, (int)$candidate['points']);
        if ((int)($candidate['best_score'] ?? 0) >= $points) continue;

        $status = (string)($candidate['attempt_status'] ?? '');
        if ($status === 'submitted' || $status === 'expired') continue;
        if ($status === 'in_progress' && !empty($candidate['deadline_at']) && strtotime((string)$candidate['deadline_at']) <= time()) continue;
        if (!empty($context['due_at']) && strtotime((string)$context['due_at']) <= time()) continue;

        return rtrim((string)$config['base_url'], '/') . '/exercise.php?id=' . $candidateId;
    }
    return null;
}

/** Return to the most relevant active classroom, or the public practice arena. */
function student_exercise_done_url(PDO $pdo, int $studentId, int $exerciseId): string {
    global $config;
    $stmt = $pdo->prepare("SELECT c.id
        FROM class_assignments ca
        JOIN classrooms c ON c.id = ca.classroom_id AND c.is_active = 1
        JOIN class_enrollments ce ON ce.classroom_id = c.id AND ce.student_id = ? AND ce.enrollment_status = 'active'
        WHERE ca.exercise_id = ? AND ca.is_active = 1
        ORDER BY ca.created_at DESC, c.id DESC
        LIMIT 1");
    $stmt->execute([$studentId, $exerciseId]);
    $classroomId = $stmt->fetchColumn();
    if ($classroomId) {
        return rtrim((string)$config['base_url'], '/') . '/student-classroom.php?id=' . (int)$classroomId;
    }
    return rtrim((string)$config['base_url'], '/') . '/index.php#practice';
}

/** Write a privacy-conscious audit event. Avoid storing passwords, source code, or clipboard content. */
function audit_log(PDO $pdo, ?int $actorId, string $action, ?string $entityType = null, ?int $entityId = null, array $details = []): void {
    try {
        $role = current_user()['role'] ?? null;
        $payload = json_encode($details, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
        $stmt = $pdo->prepare('INSERT INTO audit_logs(actor_id,actor_role,action,entity_type,entity_id,details) VALUES(?,?,?,?,?,?)');
        $stmt->execute([$actorId, is_string($role) ? $role : null, mb_substr($action, 0, 80), $entityType !== null ? mb_substr($entityType, 0, 60) : null, $entityId, $payload ?: null]);
    } catch (Throwable $ignored) {
        // Logging should never break the primary workflow; local admins can verify the migration separately.
    }
}

/** Hash the email/IP pair so the rate-limit table does not store plaintext identifiers. */
function login_rate_limit_key(string $email): string {
    $ip = (string)($_SERVER['REMOTE_ADDR'] ?? 'unknown');
    return hash('sha256', strtolower(trim($email)) . '|' . $ip);
}

/** Number of seconds until a login identity can try again; zero means not blocked. */
function login_rate_limit_remaining(PDO $pdo, string $key): int {
    try {
        $stmt = $pdo->prepare('SELECT blocked_until FROM auth_rate_limits WHERE identity_hash=? LIMIT 1');
        $stmt->execute([$key]);
        $blockedUntil = $stmt->fetchColumn();
        if (!$blockedUntil) return 0;
        return max(0, strtotime((string)$blockedUntil) - time());
    } catch (Throwable $ignored) {
        // During setup before migration 006, fail open so legitimate users can access the app.
        return 0;
    }
}

function record_login_failure(PDO $pdo, string $key): void {
    try {
        $now = date('Y-m-d H:i:s');
        $windowStart = date('Y-m-d H:i:s', time() - 900);
        $stmt = $pdo->prepare('SELECT id,failed_count,window_started_at FROM auth_rate_limits WHERE identity_hash=? LIMIT 1');
        $stmt->execute([$key]);
        $row = $stmt->fetch();
        if (!$row) {
            $pdo->prepare('INSERT INTO auth_rate_limits(identity_hash,failed_count,window_started_at,blocked_until) VALUES(?,1,?,NULL)')->execute([$key, $now]);
            return;
        }
        if (strtotime((string)$row['window_started_at']) < time() - 900) {
            $pdo->prepare('UPDATE auth_rate_limits SET failed_count=1,window_started_at=?,blocked_until=NULL WHERE id=?')->execute([$now, (int)$row['id']]);
            return;
        }
        $count = (int)$row['failed_count'] + 1;
        $blocked = $count >= 5 ? date('Y-m-d H:i:s', time() + 900) : null;
        $pdo->prepare('UPDATE auth_rate_limits SET failed_count=?,blocked_until=? WHERE id=?')->execute([$count, $blocked, (int)$row['id']]);
    } catch (Throwable $ignored) {
        // Authentication still works if the optional rate-limit migration has not yet been applied.
    }
}

function clear_login_rate_limit(PDO $pdo, string $key): void {
    try {
        $stmt = $pdo->prepare('DELETE FROM auth_rate_limits WHERE identity_hash=?');
        $stmt->execute([$key]);
    } catch (Throwable $ignored) {
    }
}


/** Award deterministic student badges from saved platform activity. Safe to call after any learning action. */
function award_student_badges(PDO $pdo, int $studentId): void {
    if ($studentId < 1 || !codearena_table_exists($pdo, 'badge_definitions') || !codearena_table_exists($pdo, 'student_badges')) return;
    try {
        $submissionStmt = $pdo->prepare('SELECT COUNT(*) FROM submissions WHERE user_id=?');
        $submissionStmt->execute([$studentId]);
        $submissionCount = (int)$submissionStmt->fetchColumn();
        $perfectStmt = $pdo->prepare("SELECT COUNT(*) FROM (
            SELECT s.exercise_id, MAX(CASE WHEN s.score >= COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(ev.snapshot_json, '$.exercise.points')) AS UNSIGNED), e.points) THEN 1 ELSE 0 END) AS perfect
            FROM submissions s JOIN exercises e ON e.id=s.exercise_id
            LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id
            WHERE s.user_id=? GROUP BY s.exercise_id
        ) completed WHERE perfect=1");
        $perfectStmt->execute([$studentId]);
        $perfectCount = (int)$perfectStmt->fetchColumn();
        $practiceCount = 0;
        if (codearena_table_exists($pdo,'practice_runs')) {
            $practiceStmt=$pdo->prepare('SELECT COUNT(DISTINCT exercise_id) FROM practice_runs WHERE user_id=?');
            $practiceStmt->execute([$studentId]); $practiceCount=(int)$practiceStmt->fetchColumn();
        }
        $lessonCount = 0;
        if (codearena_table_exists($pdo,'learning_lesson_completions')) {
            $lessonStmt=$pdo->prepare('SELECT COUNT(*) FROM learning_lesson_completions WHERE user_id=?');
            $lessonStmt->execute([$studentId]); $lessonCount=(int)$lessonStmt->fetchColumn();
        }
        $streak = 0;
        try {
            $dates = [];
            $activityStmt = $pdo->prepare("SELECT activity_date FROM (
                SELECT DATE(created_at) AS activity_date FROM submissions WHERE user_id=?
                UNION SELECT DATE(created_at) AS activity_date FROM practice_runs WHERE user_id=?
                UNION SELECT DATE(completed_at) AS activity_date FROM learning_lesson_completions WHERE user_id=?
            ) activity_dates ORDER BY activity_date DESC LIMIT 7");
            $activityStmt->execute([$studentId,$studentId,$studentId]);
            $dates = array_map('strval',$activityStmt->fetchAll(PDO::FETCH_COLUMN));
            $today = new DateTimeImmutable('today');
            $expected = $today;
            if (!$dates || $dates[0] !== $today->format('Y-m-d')) $expected = $today->modify('-1 day');
            foreach ($dates as $date) {
                if ($date !== $expected->format('Y-m-d')) break;
                $streak++; $expected = $expected->modify('-1 day');
            }
        } catch (Throwable $ignored) { $streak=0; }
        $earned = [];
        if ($submissionCount >= 1) $earned[]='first_submission';
        if ($perfectCount >= 1) $earned[]='perfect_score';
        if ($perfectCount >= 5) $earned[]='five_perfect';
        if ($perfectCount >= 10) $earned[]='ten_solved';
        if ($practiceCount >= 5) $earned[]='practice_explorer';
        if ($lessonCount >= 1) $earned[]='lesson_learner';
        if ($streak >= 7) $earned[]='seven_day_streak';
        if (!$earned) return;
        $marks=implode(',',array_fill(0,count($earned),'?'));
        $defs=$pdo->prepare("SELECT id,slug FROM badge_definitions WHERE slug IN ({$marks})");
        $defs->execute($earned); $insert=$pdo->prepare('INSERT IGNORE INTO student_badges(student_id,badge_id) VALUES(?,?)');
        foreach ($defs->fetchAll() as $badge) $insert->execute([$studentId,(int)$badge['id']]);
    } catch (Throwable $ignored) {
        // Badges are optional rewards; an unavailable badge schema must not break grading.
    }
}

/** Build a stable snapshot of the exercise as it exists now, including hidden tests. */
function exercise_snapshot_payload(PDO $pdo, int $exerciseId): array {
    $stmt = $pdo->prepare('SELECT id,title,slug,description,hint_text,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by FROM exercises WHERE id=?');
    $stmt->execute([$exerciseId]);
    $exercise = $stmt->fetch();
    if (!$exercise) throw new RuntimeException('Exercise not found while creating a version snapshot.');
    $tests = $pdo->prepare('SELECT stdin,expected_output,is_sample,sort_order FROM test_cases WHERE exercise_id=? ORDER BY sort_order,id');
    $tests->execute([$exerciseId]);
    $cases = array_map(static fn(array $r): array => ['stdin'=>(string)$r['stdin'],'expected_output'=>(string)$r['expected_output'],'is_sample'=>(int)$r['is_sample'],'sort_order'=>(int)$r['sort_order']], $tests->fetchAll());
    foreach (['id','time_limit_seconds','points','is_published','monitoring_enabled','warning_threshold','created_by'] as $key) $exercise[$key] = (int)$exercise[$key];
    return ['exercise'=>$exercise, 'test_cases'=>$cases];
}

/** Save a version only when the snapshot changed. Return the history row ID. */
function store_exercise_version(PDO $pdo, int $exerciseId, int $createdBy, string $reason = 'Exercise updated', ?int $auditActorId = null): int {
    $snapshot = exercise_snapshot_payload($pdo, $exerciseId);
    $json = json_encode($snapshot, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    if ($json === false) throw new RuntimeException('Could not encode the exercise version snapshot.');
    $latestStmt = $pdo->prepare('SELECT id,version_number,snapshot_json FROM exercise_versions WHERE exercise_id=? ORDER BY version_number DESC LIMIT 1');
    $latestStmt->execute([$exerciseId]);
    $latest = $latestStmt->fetch();
    $latestPayload = $latest ? json_decode((string)$latest['snapshot_json'], true) : null;
    // MySQL may normalize native JSON key order and whitespace. Canonicalize object
    // keys before comparing so opening an exercise does not create duplicate versions.
    $canonicalize = static function ($value) use (&$canonicalize) {
        if (!is_array($value)) return $value;
        if (!array_is_list($value)) ksort($value, SORT_STRING);
        foreach ($value as &$child) $child = $canonicalize($child);
        unset($child);
        return $value;
    };
    $latestCanonical = is_array($latestPayload) ? json_encode($canonicalize($latestPayload), JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE) : false;
    $newCanonical = json_encode($canonicalize($snapshot), JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    if ($latest && is_string($latestCanonical) && is_string($newCanonical) && hash_equals(hash('sha256',$latestCanonical), hash('sha256',$newCanonical))) return (int)$latest['id'];
    $versionNumber = $latest ? ((int)$latest['version_number'] + 1) : 1;
    $insert = $pdo->prepare('INSERT INTO exercise_versions(exercise_id,version_number,snapshot_json,change_reason,created_by) VALUES(?,?,?,?,?)');
    $insert->execute([$exerciseId,$versionNumber,$json,mb_substr($reason,0,120),$createdBy]);
    $versionId = (int)$pdo->lastInsertId();
    audit_log($pdo,$auditActorId ?? $createdBy,'exercise_version_created','exercise_version',$versionId,['exercise_id'=>$exerciseId,'version_number'=>$versionNumber,'reason'=>$reason]);
    return $versionId;
}

/** Read an attempt's immutable exercise version, creating a legacy fallback if necessary. */
function ensure_attempt_exercise_version(PDO $pdo, array $attempt, int $exerciseId, int $teacherId): array {
    $versionId = (int)($attempt['exercise_version_id'] ?? 0);
    if ($versionId <= 0) {
        $versionId = store_exercise_version($pdo,$exerciseId,$teacherId,'Legacy attempt baseline',(int)$attempt['user_id']);
        $update = $pdo->prepare('UPDATE attempts SET exercise_version_id=? WHERE id=? AND user_id=? AND (exercise_version_id IS NULL OR exercise_version_id=0)');
        $update->execute([$versionId,(int)$attempt['id'],(int)$attempt['user_id']]);
        $attempt['exercise_version_id'] = $versionId;
    }
    $stmt = $pdo->prepare('SELECT snapshot_json FROM exercise_versions WHERE id=? AND exercise_id=?');
    $stmt->execute([$versionId,$exerciseId]);
    $raw = $stmt->fetchColumn();
    $payload = is_string($raw) ? json_decode($raw,true) : null;
    if (!is_array($payload) || !is_array($payload['exercise'] ?? null) || !is_array($payload['test_cases'] ?? null)) throw new RuntimeException('The exercise version snapshot is unavailable or invalid.');
    return [$attempt,$payload];
}
