<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit("Not found.\n"); }
$configPath = __DIR__ . '/../config/config.php';
if (!is_file($configPath)) { fwrite(STDERR, "Missing config/config.php. Copy config/config.example.php and configure MySQL first.\n"); exit(2); }
if (!extension_loaded('pdo') || !extension_loaded('pdo_mysql')) { fwrite(STDERR, "PDO and pdo_mysql are required for the database smoke test.\n"); exit(2); }
$config = require $configPath;
$db = $config['db'] ?? [];
$dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=%s', $db['host'] ?? '127.0.0.1', $db['port'] ?? '3306', $db['name'] ?? 'codearena', $db['charset'] ?? 'utf8mb4');
try {
    $pdo = new PDO($dsn, (string)($db['user'] ?? 'root'), (string)($db['pass'] ?? ''), [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES=>false]);
} catch (Throwable $e) {
    fwrite(STDERR, "Database connection failed. Check XAMPP MySQL and config/config.php. Raw credentials are not printed.\n");
    exit(2);
}

$tableExists = static function(string $table) use ($pdo): bool {
    $stmt=$pdo->prepare('SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? LIMIT 1'); $stmt->execute([$table]); return (bool)$stmt->fetchColumn();
};
$columnExists = static function(string $table,string $column) use ($pdo): bool {
    $stmt=$pdo->prepare('SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? AND column_name=? LIMIT 1'); $stmt->execute([$table,$column]); return (bool)$stmt->fetchColumn();
};
$results=[];
$run = static function(string $name, callable $operation, bool $required = true) use (&$results): void {
    try { $detail = $operation(); $results[]=['name'=>$name,'state'=>'ok','detail'=>is_string($detail)?$detail:'Query completed','required'=>$required]; }
    catch (Throwable $e) { $results[]=['name'=>$name,'state'=>$required?'fail':'warn','detail'=>'Query failed: ' . preg_replace('/[\r\n\x00-\x1F]+/', ' ', substr($e->getMessage(),0,180)),'required'=>$required]; }
};
$skip = static function(string $name,string $why) use (&$results): void { $results[]=['name'=>$name,'state'=>'skip','detail'=>$why,'required'=>false]; };
$has = static function(array $requirements) use ($tableExists,$columnExists): bool {
    foreach ($requirements as $table=>$columns) { if (!$tableExists($table)) return false; foreach ($columns as $column) if (!$columnExists($table,$column)) return false; }
    return true;
};

$core = [
    'users'=>['id','name','email','role'],
    'exercises'=>['id','title','difficulty','points','time_limit_seconds','is_published'],
    'attempts'=>['id','user_id','exercise_id','best_score','status'],
    'submissions'=>['id','user_id','exercise_id','source_code','score','created_at'],
    'test_cases'=>['id','exercise_id','stdin','expected_output','is_sample'],
];
if (!$has($core)) {
    echo "[FAIL] Core schema: one or more users/exercises/attempts/submissions/test_cases tables or columns are missing. Run tools/health_check.php for specifics.\n";
    exit(1);
}

$run('Core account/exercise counts', static function() use ($pdo): string {
    $students=(int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='student'")->fetchColumn();
    $exercises=(int)$pdo->query('SELECT COUNT(*) FROM exercises')->fetchColumn();
    $submissions=(int)$pdo->query('SELECT COUNT(*) FROM submissions')->fetchColumn();
    return $students . ' students · ' . $exercises . ' exercises · ' . $submissions . ' submissions';
});

$hasPractice=$has(['practice_runs'=>['user_id','exercise_id','all_samples_passed']]);
$hasVersions=$has(['exercise_versions'=>['id','snapshot_json'],'attempts'=>['exercise_version_id']]);
$topicExpr=$columnExists('exercises','topic') ? 'e.topic' : "'Fundamentals' AS topic";
$startExpr=$columnExists('attempts','started_explicitly') ? 'a.started_explicitly' : '0 AS started_explicitly';
$snapshotExpr=$hasVersions ? 'av.snapshot_json AS attempt_snapshot_json' : 'NULL AS attempt_snapshot_json';
$versionJoin=$hasVersions ? 'LEFT JOIN exercise_versions av ON av.id=a.exercise_version_id' : '';
$practiceCountExpr=$hasPractice ? '(SELECT COUNT(*) FROM practice_runs pr WHERE pr.user_id=? AND pr.exercise_id=e.id) AS practice_run_count' : '0 AS practice_run_count';
$practiceMasteredExpr=$hasPractice ? 'EXISTS(SELECT 1 FROM practice_runs pr WHERE pr.user_id=? AND pr.exercise_id=e.id AND pr.all_samples_passed=1) AS practice_mastered' : '0 AS practice_mastered';
$progressBindings=[]; if($hasPractice){$progressBindings[] = 0; $progressBindings[] = 0;} $progressBindings[] = 0;
$progressSql="SELECT e.id,e.title,{$topicExpr},e.difficulty,e.points,e.time_limit_seconds,{$snapshotExpr},COALESCE(a.best_score,0) AS best_score,{$startExpr},a.status AS attempt_status,{$practiceCountExpr},{$practiceMasteredExpr},EXISTS(SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1) AS has_assignment FROM exercises e LEFT JOIN attempts a ON a.exercise_id=e.id AND a.user_id=? {$versionJoin} WHERE e.is_published=1 ORDER BY topic,e.difficulty,e.title LIMIT 0";
if ($tableExists('class_assignments')) {
    $run('Student My Progress query', static function() use($pdo,$progressSql,$progressBindings): string { $s=$pdo->prepare($progressSql); $s->execute($progressBindings); $s->fetchAll(); return 'Progress query compiles and executes with current optional-feature compatibility.'; });
} else $skip('Student My Progress query','class_assignments is missing; check migration 003.');

$versionScoring=$has(['exercise_versions'=>['id','snapshot_json'],'submissions'=>['exercise_version_id']]);
$maxPointsExpr=$versionScoring ? "COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(ev.snapshot_json, '$.exercise.points')) AS UNSIGNED),e.points)" : 'e.points';
$versionJoinLeaderboard=$versionScoring ? 'LEFT JOIN exercise_versions ev ON ev.id=best.exercise_version_id' : '';
$leaderboardSql="SELECT u.id,u.name,COALESCE(SUM(bp.best_score),0) AS total_points,COALESCE(SUM(CASE WHEN bp.submission_count>0 THEN 1 ELSE 0 END),0) AS attempted,COALESCE(SUM(CASE WHEN bp.submission_count>0 AND bp.best_score>=bp.max_points THEN 1 ELSE 0 END),0) AS solved,COALESCE(SUM(bp.submission_count),0) AS submissions,COALESCE(SUM(CASE WHEN bp.submission_count>0 THEN bp.best_score ELSE 0 END),0) AS earned_points,COALESCE(SUM(CASE WHEN bp.submission_count>0 THEN bp.max_points ELSE 0 END),0) AS available_points FROM users u LEFT JOIN (SELECT submission_pairs.user_id,e.id AS exercise_id,COALESCE(best.score,0) AS best_score,{$maxPointsExpr} AS max_points,(SELECT COUNT(*) FROM submissions s3 WHERE s3.user_id=submission_pairs.user_id AND s3.exercise_id=e.id) AS submission_count FROM (SELECT DISTINCT user_id,exercise_id FROM submissions) AS submission_pairs JOIN exercises e ON e.id=submission_pairs.exercise_id AND e.is_published=1 LEFT JOIN submissions best ON best.id=(SELECT s2.id FROM submissions s2 WHERE s2.user_id=submission_pairs.user_id AND s2.exercise_id=e.id ORDER BY s2.score DESC,s2.created_at DESC,s2.id DESC LIMIT 1) {$versionJoinLeaderboard}) bp ON bp.user_id=u.id WHERE u.role='student' GROUP BY u.id,u.name ORDER BY total_points DESC,solved DESC,attempted DESC,u.name ASC LIMIT 0";
$run('Global leaderboard query', static function() use($pdo,$leaderboardSql): string { $pdo->query($leaderboardSql)->fetchAll(); return 'Leaderboard ranking query compiles and executes.'; });

$classroomTables=['classrooms'=>['id','name','section','subject','teacher_id','is_active'],'class_enrollments'=>['classroom_id','student_id','enrollment_status','joined_at'],'class_assignments'=>['id','classroom_id','exercise_id','is_active','due_at'],'grade_records'=>['assignment_id','student_id','best_score','max_score','submission_count']];
if ($has($classroomTables)) {
    $run('Student My Classes query', static function() use($pdo): string {
        $sql="SELECT c.id,c.name,c.section,c.subject,c.join_code,ce.joined_at,(SELECT COUNT(*) FROM class_assignments ca WHERE ca.classroom_id=c.id AND ca.is_active=1) AS assignment_count,(SELECT COUNT(*) FROM class_assignments ca JOIN grade_records gr ON gr.assignment_id=ca.id AND gr.student_id=? WHERE ca.classroom_id=c.id AND ca.is_active=1 AND gr.best_score>=gr.max_score) AS completed_count,u.name AS teacher_name FROM class_enrollments ce JOIN classrooms c ON c.id=ce.classroom_id JOIN users u ON u.id=c.teacher_id WHERE ce.student_id=? AND ce.enrollment_status='active' AND c.is_active=1 ORDER BY ce.joined_at DESC LIMIT 0";
        $stmt=$pdo->prepare($sql);$stmt->execute([0,0]);$stmt->fetchAll();return 'Student class list query compiles and executes.';
    });
    $run('Teacher gradebook query', static function() use($pdo): string {
        $sql="SELECT ce.student_id,u.name AS student_name,u.email,ca.id AS assignment_id,e.id AS exercise_id,e.title AS exercise_title,COALESCE(gr.max_score,e.points) AS max_score,ca.due_at,ca.is_active AS assignment_active,COALESCE(gr.best_score,0) AS best_score,COALESCE(gr.submission_count,0) AS submission_count,gr.last_submitted_at,a.status AS attempt_status,COALESCE(a.started_explicitly,0) AS started_explicitly FROM class_enrollments ce JOIN users u ON u.id=ce.student_id JOIN class_assignments ca ON ca.classroom_id=ce.classroom_id AND ca.is_active=1 JOIN exercises e ON e.id=ca.exercise_id LEFT JOIN grade_records gr ON gr.assignment_id=ca.id AND gr.student_id=ce.student_id LEFT JOIN attempts a ON a.user_id=ce.student_id AND a.exercise_id=e.id WHERE ce.classroom_id=? AND ce.enrollment_status='active' ORDER BY u.name,e.title LIMIT 0";
        $stmt=$pdo->prepare($sql);$stmt->execute([0]);$stmt->fetchAll();return 'Teacher classroom gradebook query compiles and executes.';
    });
} else {
    $skip('Student My Classes query','Classroom tables are missing; check migration 003.');
    $skip('Teacher gradebook query','Classroom tables are missing; check migration 003.');
}

if ($hasVersions) {
    $run('Exercise version snapshot query', static function() use($pdo): string { $pdo->query("SELECT exercise_id,version_number,JSON_EXTRACT(snapshot_json,'$.exercise.points') AS snapshot_points FROM exercise_versions LIMIT 0")->fetchAll(); return 'Exercise version table and JSON snapshot query are available.'; }, false);
} else $skip('Exercise version snapshot query','Version-history migration 007 is not fully installed.');

$monitorTables=['monitor_events'=>['attempt_id','user_id','exercise_id','event_type','created_at'],'monitor_reviews'=>['attempt_id','teacher_id','review_status','notes']];
if ($has($monitorTables)) {
    $run('Exam monitoring report query', static function() use($pdo): string { $pdo->query("SELECT me.id,me.attempt_id,me.user_id,me.exercise_id,me.event_type,me.created_at,mr.review_status,mr.notes FROM monitor_events me JOIN attempts a ON a.id=me.attempt_id LEFT JOIN monitor_reviews mr ON mr.attempt_id=a.id LIMIT 0")->fetchAll(); return 'Monitoring event and review join is available.'; }, false);
} else $skip('Exam monitoring report query','Monitoring tables are not all installed; check migrations 002 and 005.');

$failed = 0;
$requiredFailed = 0;
foreach ($results as $result) {
    $prefix = match($result['state']) { 'ok'=>'OK', 'warn'=>'WARN', 'skip'=>'SKIP', default=>'FAIL' };
    printf("[%s] %-34s %s\n",$prefix,$result['name'],$result['detail']);
    if ($result['state']==='fail') { $failed++; if ($result['required']) $requiredFailed++; }
}
printf("\nSmoke test complete: %d passed, %d warnings/skips, %d failed. No database rows were changed.\n", count(array_filter($results,static fn($r)=>$r['state']==='ok')), count(array_filter($results,static fn($r)=>in_array($r['state'],['warn','skip'],true))), $failed);
if ($failed > 0) echo "Use tools/health_check.php and the Super Admin System Health page to locate missing tables/columns.\n";
exit($requiredFailed === 0 ? 0 : 1);
