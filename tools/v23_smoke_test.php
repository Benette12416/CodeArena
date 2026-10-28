<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit("Not found.\n"); }
$configPath = __DIR__ . '/../config/config.php';
if (!is_file($configPath)) { fwrite(STDERR, "Missing config/config.php. Copy config/config.example.php and configure MySQL first.\n"); exit(2); }
if (!extension_loaded('pdo') || !extension_loaded('pdo_mysql')) { fwrite(STDERR, "PDO and pdo_mysql are required. Use XAMPP's bundled PHP CLI.\n"); exit(2); }
$config = require $configPath;
$db = $config['db'] ?? [];
$dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=%s', $db['host'] ?? '127.0.0.1', $db['port'] ?? '3306', $db['name'] ?? 'codearena', $db['charset'] ?? 'utf8mb4');
try {
    $pdo = new PDO($dsn, (string)($db['user'] ?? 'root'), (string)($db['pass'] ?? ''), [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES=>false]);
} catch (Throwable $e) {
    fwrite(STDERR, "Database connection failed. Check XAMPP MySQL and config/config.php; credentials are not printed.\n"); exit(2);
}
$tableExists = static function(string $table) use ($pdo): bool {
    $s=$pdo->prepare('SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? LIMIT 1'); $s->execute([$table]); return (bool)$s->fetchColumn();
};
$columnExists = static function(string $table,string $column) use ($pdo): bool {
    $s=$pdo->prepare('SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? AND column_name=? LIMIT 1'); $s->execute([$table,$column]); return (bool)$s->fetchColumn();
};
$results=[];
$failures=0;
$check = static function(string $name, callable $work, bool $required=true) use (&$results,&$failures): void {
    try { $detail=$work(); $results[]=['name'=>$name,'state'=>'OK','detail'=>is_string($detail)?$detail:'Query succeeded']; }
    catch(Throwable $e) { $state=$required?'FAIL':'WARN'; if($required)$failures++; $detail=preg_replace('/[\r\n\x00-\x1F]+/',' ',substr($e->getMessage(),0,160)); $results[]=['name'=>$name,'state'=>$state,'detail'=>$detail ?: 'Query did not complete']; }
};
$requireSchema = static function(array $requirements) use ($tableExists,$columnExists): void {
    $missing=[]; foreach($requirements as $t=>$cols){if(!$tableExists($t)){$missing[]=$t.' table';continue;}foreach($cols as $c)if(!$columnExists($t,$c))$missing[]=$t.'.'.$c;}
    if($missing) throw new RuntimeException('Missing schema: '.implode(', ',$missing).'. Apply the relevant migration(s).');
};
$check('Core accounts and coding schema', static function() use ($requireSchema): string {
    $requireSchema(['users'=>['id','name','email','role','is_active'],'exercises'=>['id','title','description','hint_text','points','time_limit_seconds','is_published'],'attempts'=>['id','user_id','exercise_id','status','best_score','started_explicitly','retake_pending'],'submissions'=>['id','user_id','exercise_id','source_code','score','result_json','exercise_version_id'],'test_cases'=>['exercise_id','stdin','expected_output','is_sample']]); return 'Core student/teacher, grading and start-gate columns exist.';
});
$check('Teacher lessons and completion schema', static function() use ($requireSchema): string {
    $requireSchema(['learning_paths'=>['id','teacher_id','title','is_published'],'learning_path_items'=>['path_id','exercise_id','sort_order'],'learning_path_completions'=>['user_id','path_id','exercise_id','completion_type','passed_tests','total_tests'],'practice_lesson_completions'=>['user_id','path_id','exercise_id','completed_at'],'learning_lessons'=>['id','path_id','teacher_id','title','lesson_content','example_code','hint_text','is_published'],'learning_lesson_completions'=>['user_id','lesson_id','completed_at']]);
    return 'Lesson builder and lesson completion tables exist.';
});
$check('Submission feedback and regrade history schema', static function() use ($requireSchema): string {
    $requireSchema(['submission_feedback'=>['submission_id','teacher_id','feedback_text','feedback_type'],'submission_regrade_history'=>['submission_id','teacher_id','previous_score','previous_total_tests','new_score','new_total_tests','reason','regraded_at'],'exercise_versions'=>['id','exercise_id','snapshot_json'],'audit_logs'=>['actor_id','action','details','created_at']]); return 'Feedback, immutable versions, regrade archive and audit log exist.';
});
$check('Classroom workflows schema', static function() use ($requireSchema): string {
    $requireSchema(['classrooms'=>['id','teacher_id','name','join_code','is_active','archived_at'],'class_enrollments'=>['classroom_id','student_id','enrollment_status'],'class_assignments'=>['id','classroom_id','exercise_id','is_active','due_at'],'grade_records'=>['assignment_id','student_id','best_score','max_score','submission_count'],'class_announcements'=>['classroom_id','teacher_id','title','body','is_published'],'student_assignment_overrides'=>['assignment_id','student_id','extended_due_at','updated_by'],'attempt_retake_history'=>['attempt_id','teacher_id','previous_status','previous_best_score']]); return 'Enrollment, announcements, grade records, deadline overrides and retakes exist.';
});
$check('Achievements and security schema', static function() use ($requireSchema): string {
    $requireSchema(['badge_definitions'=>['id','slug','title'],'student_badges'=>['student_id','badge_id','awarded_at'],'auth_rate_limits'=>['identity_hash','failed_count','blocked_until'],'audit_logs'=>['actor_id','actor_role','action','entity_type','entity_id','details','created_at']]); return 'Badge awards, login throttling and audit logging schema exists.';
});
$check('Student Progress query shape', static function() use ($pdo): string {
    $s=$pdo->prepare("SELECT e.id,e.title,e.points,e.time_limit_seconds,COALESCE(a.best_score,0) AS best_score,a.status AS attempt_status FROM exercises e LEFT JOIN attempts a ON a.exercise_id=e.id AND a.user_id=? WHERE e.is_published=1 ORDER BY e.title LIMIT 0"); $s->execute([0]); $s->fetchAll(); return 'Progress query compiles with the current core schema.';
});
$check('Leaderboard query shape', static function() use ($pdo): string {
    $s=$pdo->query("SELECT u.id,u.name,COALESCE(SUM(COALESCE(gr.best_score,0)),0) AS total_points FROM users u LEFT JOIN (SELECT s.user_id,s.exercise_id,MAX(s.score) AS best_score FROM submissions s GROUP BY s.user_id,s.exercise_id) gr ON gr.user_id=u.id WHERE u.role='student' GROUP BY u.id,u.name ORDER BY total_points DESC,u.name LIMIT 0"); $s->fetchAll(); return 'Leaderboard aggregation query compiles.';
});
$check('Student class and announcement query shape', static function() use ($pdo): string {
    $s=$pdo->prepare("SELECT c.id,c.name,c.section,COUNT(DISTINCT ca.id) AS assignment_count FROM class_enrollments ce JOIN classrooms c ON c.id=ce.classroom_id LEFT JOIN class_assignments ca ON ca.classroom_id=c.id AND ca.is_active=1 WHERE ce.student_id=? AND ce.enrollment_status='active' GROUP BY c.id,c.name,c.section LIMIT 0"); $s->execute([0]); $s->fetchAll();
    $a=$pdo->prepare('SELECT id,title,body,created_at FROM class_announcements WHERE classroom_id=? AND is_published=1 ORDER BY created_at DESC LIMIT 0'); $a->execute([0]); $a->fetchAll(); return 'Class list and student-visible announcement queries compile.';
});
$check('Teacher gradebook and submission detail query shape', static function() use ($pdo): string {
    $s=$pdo->prepare("SELECT ce.student_id,u.name,e.id AS exercise_id,e.title,COALESCE(gr.best_score,0) AS best_score,COALESCE(gr.max_score,e.points) AS max_score FROM class_enrollments ce JOIN users u ON u.id=ce.student_id JOIN class_assignments ca ON ca.classroom_id=ce.classroom_id AND ca.is_active=1 JOIN exercises e ON e.id=ca.exercise_id LEFT JOIN grade_records gr ON gr.assignment_id=ca.id AND gr.student_id=ce.student_id WHERE ce.classroom_id=? AND ce.enrollment_status='active' LIMIT 0"); $s->execute([0]); $s->fetchAll();
    $f=$pdo->prepare('SELECT sf.submission_id,sf.teacher_id,sf.feedback_text,sf.feedback_type FROM submission_feedback sf JOIN submissions s ON s.id=sf.submission_id WHERE s.id=? LIMIT 0'); $f->execute([0]); $f->fetchAll(); return 'Gradebook and submission-feedback queries compile.';
});
$check('Exam monitoring and review query shape', static function() use ($pdo): string {
    $s=$pdo->prepare('SELECT me.id,me.attempt_id,me.event_type,mr.review_status,mr.notes FROM monitor_events me LEFT JOIN monitor_reviews mr ON mr.attempt_id=me.attempt_id WHERE me.user_id=? LIMIT 0'); $s->execute([0]); $s->fetchAll(); return 'Monitoring event timeline and review join compile.';
});
$check('Exercise version and regrade query shape', static function() use ($pdo): string {
    $s=$pdo->prepare('SELECT s.id,s.score,s.exercise_version_id,ev.snapshot_json FROM submissions s LEFT JOIN exercise_versions ev ON ev.id=s.exercise_version_id WHERE s.user_id=? ORDER BY s.created_at DESC LIMIT 0'); $s->execute([0]); $s->fetchAll();
    $r=$pdo->prepare('SELECT submission_id,previous_score,new_score,reason,regraded_at FROM submission_regrade_history WHERE submission_id=? ORDER BY regraded_at DESC LIMIT 0'); $r->execute([0]); $r->fetchAll(); return 'Attempt snapshots and regrade history queries compile.';
});
$check('Student badges query shape', static function() use ($pdo): string {
    $s=$pdo->prepare('SELECT bd.slug,bd.title,sb.awarded_at FROM student_badges sb JOIN badge_definitions bd ON bd.id=sb.badge_id WHERE sb.student_id=? ORDER BY sb.awarded_at DESC LIMIT 0'); $s->execute([0]); $s->fetchAll(); return 'Student achievements query compiles.';
});
foreach($results as $r) printf('[%s] %-43s %s\n',$r['state'],$r['name'],$r['detail']);
printf("\nv23 smoke test: %d check(s), %d failure(s). No application rows were changed.\n",count($results),$failures);
if($failures>0) echo "Use tools/health_check.php or Super Admin > System Health to identify missing migrations.\n";
exit($failures===0?0:1);
