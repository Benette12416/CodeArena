<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['teacher']);
$classroomId = max(0, (int)($_GET['id'] ?? 0));
$stmt = $pdo->prepare('SELECT * FROM classrooms WHERE id=? AND teacher_id=?');
$stmt->execute([$classroomId, (int)$user['id']]);
$classroom = $stmt->fetch();
if (!$classroom) { http_response_code(404); exit('Classroom not found.'); }
if (!empty($classroom['archived_at']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
    flash('Archived classrooms are read-only. Restore the classroom before changing assignments, members, announcements, or deadlines.', 'error');
    redirect('teacher-classrooms.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');
    if ($action === 'import_students_csv') {
        if (empty($_FILES['students_csv']) || !is_array($_FILES['students_csv']) || (int)($_FILES['students_csv']['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            flash('Choose a CSV file with an email column. Maximum file size is 2 MB.', 'error');
            redirect('teacher-classroom.php?id='.$classroomId.'#bulk-enroll');
        }
        $file=$_FILES['students_csv'];
        if ((int)$file['size'] > 2*1024*1024 || !is_uploaded_file((string)$file['tmp_name'])) {
            flash('The CSV file is too large or could not be validated.', 'error');
            redirect('teacher-classroom.php?id='.$classroomId.'#bulk-enroll');
        }
        $fh=fopen((string)$file['tmp_name'],'rb');
        if (!$fh) { flash('Could not read the CSV file.','error'); redirect('teacher-classroom.php?id='.$classroomId.'#bulk-enroll'); }
        $emails=[]; $line=0; $first=true;
        while (($cols=fgetcsv($fh,10000,',')) !== false) {
            $line++; if (!$cols) continue;
            $value=trim((string)($cols[0]??''));
            if ($first) { $first=false; if (strtolower($value)==='email' || strtolower($value)==='student_email') continue; }
            $email=strtolower($value);
            if (filter_var($email,FILTER_VALIDATE_EMAIL)) $emails[$email]=true;
            if (count($emails)>1000) break;
        }
        fclose($fh);
        if (!$emails || count($emails)>1000) { flash('CSV must contain between 1 and 1,000 valid student email addresses in the first column.','error'); redirect('teacher-classroom.php?id='.$classroomId.'#bulk-enroll'); }
        $find=$pdo->prepare("SELECT id FROM users WHERE email=? AND role='student' AND is_active=1 LIMIT 1");
        $add=$pdo->prepare("INSERT INTO class_enrollments(classroom_id,student_id,enrollment_status) VALUES(?,?,'active') ON DUPLICATE KEY UPDATE enrollment_status='active'");
        $added=0; $skipped=0; $pdo->beginTransaction();
        try {
            foreach(array_keys($emails) as $email){$find->execute([$email]);$sid=$find->fetchColumn();if(!$sid){$skipped++;continue;}$add->execute([$classroomId,(int)$sid]);if($add->rowCount()>0)$added++;}
            $pdo->commit();
            sync_classroom_grades($pdo,$classroomId);
            audit_log($pdo,(int)$user['id'],'csv_students_enrolled','classroom',$classroomId,['added_or_reactivated'=>$added,'skipped'=>$skipped]);
            flash("CSV import finished: {$added} enrollment(s) added or reactivated; {$skipped} email(s) skipped because no active student account matched.",'success');
        } catch(Throwable $ex){if($pdo->inTransaction())$pdo->rollBack();error_log('CodeArena CSV enrollment failed: '.$ex->getMessage());flash('The CSV import failed; no partial enrollment changes were saved.','error');}
        redirect('teacher-classroom.php?id='.$classroomId.'#bulk-enroll');
    }
    if ($action === 'post_announcement') {
        $title=trim((string)($_POST['announcement_title']??'')); $body=trim((string)($_POST['announcement_body']??''));
        if($title===''||mb_strlen($title)>180||$body===''||mb_strlen($body)>12000){flash('Enter an announcement title and message (maximum 12,000 characters).','error');redirect('teacher-classroom.php?id='.$classroomId.'#announcements');}
        $stmt=$pdo->prepare('INSERT INTO class_announcements(classroom_id,teacher_id,title,body,is_published) VALUES(?,?,?,?,1)');$stmt->execute([$classroomId,(int)$user['id'],$title,$body]);$announcementId=(int)$pdo->lastInsertId();
        audit_log($pdo,(int)$user['id'],'class_announcement_posted','class_announcement',$announcementId,['classroom_id'=>$classroomId]);flash('Announcement posted for enrolled students.','success');redirect('teacher-classroom.php?id='.$classroomId.'#announcements');
    }
    if ($action === 'delete_announcement') {
        $announcementId=max(0,(int)($_POST['announcement_id']??0));$stmt=$pdo->prepare('DELETE FROM class_announcements WHERE id=? AND classroom_id=? AND teacher_id=?');$stmt->execute([$announcementId,$classroomId,(int)$user['id']]);
        if($stmt->rowCount())audit_log($pdo,(int)$user['id'],'class_announcement_deleted','class_announcement',$announcementId,['classroom_id'=>$classroomId]);flash($stmt->rowCount()?'Announcement deleted.':'Announcement not found.',$stmt->rowCount()?'success':'error');redirect('teacher-classroom.php?id='.$classroomId.'#announcements');
    }
    if ($action === 'extend_deadline') {
        $assignmentId=max(0,(int)($_POST['assignment_id']??0));$studentId=max(0,(int)($_POST['student_id']??0));$raw=trim((string)($_POST['extended_due_at']??''));$note=trim((string)($_POST['override_note']??''));
        $dt=$raw!==''?DateTimeImmutable::createFromFormat('Y-m-d\\TH:i',$raw):false;
        $check=$pdo->prepare("SELECT ca.id,ca.due_at FROM class_assignments ca JOIN classrooms c ON c.id=ca.classroom_id JOIN class_enrollments ce ON ce.classroom_id=c.id AND ce.student_id=? AND ce.enrollment_status='active' WHERE ca.id=? AND ca.classroom_id=? AND c.teacher_id=? AND ca.is_active=1 LIMIT 1");$check->execute([$studentId,$assignmentId,$classroomId,(int)$user['id']]);$assignment=$check->fetch();
        if(!$assignment||!$dt||$dt<=new DateTimeImmutable('now')||mb_strlen($note)>500){flash('Choose a valid student, active assignment, and future extension deadline.','error');redirect('teacher-classroom.php?id='.$classroomId.'#deadline-extensions');}
        $extended=$dt->format('Y-m-d H:i:s');
        if(!empty($assignment['due_at'])&&strtotime($extended)<=strtotime((string)$assignment['due_at'])){flash('The extension must be later than the original assignment deadline.','error');redirect('teacher-classroom.php?id='.$classroomId.'#deadline-extensions');}
        $save=$pdo->prepare('INSERT INTO student_assignment_overrides(assignment_id,student_id,extended_due_at,note,updated_by) VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE extended_due_at=VALUES(extended_due_at),note=VALUES(note),updated_by=VALUES(updated_by),updated_at=CURRENT_TIMESTAMP');$save->execute([$assignmentId,$studentId,$extended,$note!==''?$note:null,(int)$user['id']]);
        audit_log($pdo,(int)$user['id'],'student_deadline_extended','class_assignment',$assignmentId,['classroom_id'=>$classroomId,'student_id'=>$studentId,'extended_due_at'=>$extended]);flash('Individual deadline extension saved. The student must refresh the assignment page.','success');redirect('teacher-classroom.php?id='.$classroomId.'#deadline-extensions');
    }
    if ($action === 'grant_retake') {
        $assignmentId=max(0,(int)($_POST['assignment_id']??0));$studentId=max(0,(int)($_POST['student_id']??0));$reason=trim((string)($_POST['retake_reason']??''));
        $stmt=$pdo->prepare("SELECT a.id AS attempt_id,a.status,a.best_score,a.started_explicitly,e.id AS exercise_id,e.time_limit_seconds,e.monitoring_enabled,e.warning_threshold,e.created_by,ca.due_at,COALESCE(sao.extended_due_at,ca.due_at) AS effective_due_at FROM class_assignments ca JOIN classrooms c ON c.id=ca.classroom_id JOIN class_enrollments ce ON ce.classroom_id=c.id AND ce.student_id=? AND ce.enrollment_status='active' JOIN exercises e ON e.id=ca.exercise_id LEFT JOIN attempts a ON a.user_id=ce.student_id AND a.exercise_id=e.id LEFT JOIN student_assignment_overrides sao ON sao.assignment_id=ca.id AND sao.student_id=ce.student_id WHERE ca.id=? AND ca.classroom_id=? AND c.teacher_id=? AND ca.is_active=1 LIMIT 1");
        try{$stmt->execute([$studentId,$assignmentId,$classroomId,(int)$user['id']]);$row=$stmt->fetch();}catch(Throwable $ex){$row=null;}
        if(!$row||empty($row['attempt_id'])||($row['status']==='in_progress' && (int)$row['started_explicitly']===1)||mb_strlen($reason)>500){flash('A retake can only be granted for an existing, non-active attempt.','error');redirect('teacher-classroom.php?id='.$classroomId.'#deadline-extensions');}
        if(!empty($row['effective_due_at'])&&strtotime((string)$row['effective_due_at'])<=time()){flash('The effective assignment deadline has passed. Extend the deadline first, then grant a retake.','error');redirect('teacher-classroom.php?id='.$classroomId.'#deadline-extensions');}
        try{$versionId=store_exercise_version($pdo,(int)$row['exercise_id'],(int)$row['created_by'],'Teacher-granted retake',(int)$user['id']);$pdo->beginTransaction();$history=$pdo->prepare('INSERT INTO attempt_retake_history(attempt_id,teacher_id,previous_status,previous_best_score,reason) VALUES(?,?,?,?,?)');$history->execute([(int)$row['attempt_id'],(int)$user['id'],(string)$row['status'],(int)$row['best_score'],$reason!==''?$reason:null]);$upd=$pdo->prepare("UPDATE attempts SET status='in_progress',started_explicitly=0,retake_pending=1,best_score=0,completed_at=NULL,exercise_version_id=?,monitoring_enabled=?,warning_threshold=?,deadline_at=DATE_ADD(NOW(),INTERVAL ? SECOND) WHERE id=?");$upd->execute([$versionId,(int)$row['monitoring_enabled'],max(1,min(10,(int)$row['warning_threshold'])),max(60,(int)$row['time_limit_seconds']),(int)$row['attempt_id']]);$pdo->commit();audit_log($pdo,(int)$user['id'],'retake_granted','attempt',(int)$row['attempt_id'],['student_id'=>$studentId,'assignment_id'=>$assignmentId,'reason'=>$reason]);flash('Retake granted. The student must click Start Exercise again. Previous submissions remain in history; the gradebook retains the best score.','success');}
        catch(Throwable $ex){if($pdo->inTransaction())$pdo->rollBack();error_log('CodeArena retake grant failed: '.$ex->getMessage());flash('Could not grant the retake. Check migration 010 and the exercise version history.','error');}
        redirect('teacher-classroom.php?id='.$classroomId.'#deadline-extensions');
    }
    if ($action === 'bulk_assign_exercises') {
        $ids=$_POST['exercise_ids']??[];if(!is_array($ids))$ids=[];$ids=array_values(array_unique(array_filter(array_map('intval',$ids),static fn($x)=>$x>0)));
        $dueRaw=trim((string)($_POST['bulk_due_at']??''));$dueAt=null;
        if($dueRaw!==''){$dt=DateTimeImmutable::createFromFormat('Y-m-d\\TH:i',$dueRaw);if(!$dt||$dt<=new DateTimeImmutable('now')){flash('Choose a future bulk assignment deadline.','error');redirect('teacher-classroom.php?id='.$classroomId.'#bulk-assign');}$dueAt=$dt->format('Y-m-d H:i:s');}
        if(!$ids||count($ids)>100){flash('Select between 1 and 100 exercises to assign.','error');redirect('teacher-classroom.php?id='.$classroomId.'#bulk-assign');}
        $ph=implode(',',array_fill(0,count($ids),'?'));$owned=$pdo->prepare("SELECT id FROM exercises WHERE created_by=? AND is_published=1 AND (slug IS NULL OR slug NOT LIKE 'ca-htmlcss-path-%') AND id IN ({$ph})");$owned->execute(array_merge([(int)$user['id']],$ids));$okIds=array_map('intval',$owned->fetchAll(PDO::FETCH_COLUMN));
        if(count($okIds)!==count($ids)){flash('Some selected exercises are not published programming exercises owned by you. Nothing was assigned.','error');redirect('teacher-classroom.php?id='.$classroomId.'#bulk-assign');}
        try{$pdo->beginTransaction();$add=$pdo->prepare('INSERT INTO class_assignments(classroom_id,exercise_id,assigned_by,due_at,is_active) VALUES(?,?,?,?,1) ON DUPLICATE KEY UPDATE due_at=VALUES(due_at),assigned_by=VALUES(assigned_by),is_active=1');foreach($ids as $eid)$add->execute([$classroomId,$eid,(int)$user['id'],$dueAt]);$pdo->commit();sync_classroom_grades($pdo,$classroomId);audit_log($pdo,(int)$user['id'],'bulk_assignments_created','classroom',$classroomId,['exercise_ids'=>$ids,'due_at'=>$dueAt]);flash(count($ids).' exercises assigned to the classroom.','success');}catch(Throwable $ex){if($pdo->inTransaction())$pdo->rollBack();flash('Could not assign the selected exercises.','error');}
        redirect('teacher-classroom.php?id='.$classroomId.'#bulk-assign');
    }
    if ($action === 'assign_exercise') {
        $exerciseId = (int)($_POST['exercise_id'] ?? 0);
        $dueRaw = trim((string)($_POST['due_at'] ?? ''));
        $dueAt = null;
        if ($dueRaw !== '') {
            $dt = DateTimeImmutable::createFromFormat('Y-m-d\\TH:i', $dueRaw);
            if (!$dt) {
                flash('The due date format was not valid.', 'error');
                redirect('teacher-classroom.php?id='.$classroomId);
            }
            if ($dt <= new DateTimeImmutable('now')) {
                flash('Choose a future due date and time, or leave the field blank for no deadline.', 'error');
                redirect('teacher-classroom.php?id='.$classroomId);
            }
            $dueAt = $dt->format('Y-m-d H:i:s');
        }
        $check = $pdo->prepare("SELECT id FROM exercises WHERE id=? AND created_by=? AND is_published=1 AND (slug IS NULL OR slug NOT LIKE 'ca-htmlcss-path-%')");
        $check->execute([$exerciseId, (int)$user['id']]);
        if (!$check->fetchColumn()) {
            flash('Choose one of your published programming exercises. HTML/CSS preview projects belong to the Learning Paths area and cannot be assigned as automatically graded classroom exercises.', 'error');
            redirect('teacher-classroom.php?id='.$classroomId);
        }
        try {
            $stmt = $pdo->prepare('INSERT INTO class_assignments (classroom_id, exercise_id, assigned_by, due_at, is_active) VALUES (?, ?, ?, ?, 1) ON DUPLICATE KEY UPDATE due_at=VALUES(due_at), assigned_by=VALUES(assigned_by), is_active=1');
            $stmt->execute([$classroomId, $exerciseId, (int)$user['id'], $dueAt]);
            $assignmentId = (int)$pdo->lastInsertId();
            if ($assignmentId === 0) {
                $lookup = $pdo->prepare('SELECT id FROM class_assignments WHERE classroom_id=? AND exercise_id=?');
                $lookup->execute([$classroomId, $exerciseId]);
                $assignmentId = (int)$lookup->fetchColumn();
            }
            sync_classroom_grades($pdo, $classroomId);
            audit_log($pdo, (int)$user['id'], 'class_assignment_saved', 'class_assignment', $assignmentId, ['classroom_id'=>$classroomId,'exercise_id'=>$exerciseId,'due_at'=>$dueAt]);
            flash('Exercise assigned to this classroom. Grade records are ready for enrolled students.', 'success');
        } catch (Throwable $ex) {
            flash('Could not assign this exercise. Check that the classroom migration has been applied.', 'error');
        }
        redirect('teacher-classroom.php?id='.$classroomId);
    }
    if ($action === 'remove_assignment') {
        $assignmentId = (int)($_POST['assignment_id'] ?? 0);
        $stmt = $pdo->prepare('UPDATE class_assignments ca JOIN classrooms c ON c.id=ca.classroom_id SET ca.is_active=0 WHERE ca.id=? AND ca.classroom_id=? AND c.teacher_id=?');
        $stmt->execute([$assignmentId, $classroomId, (int)$user['id']]);
        if ($stmt->rowCount()) audit_log($pdo, (int)$user['id'], 'class_assignment_removed', 'class_assignment', $assignmentId, ['classroom_id'=>$classroomId]);
        flash('Assignment removed from this classroom. Existing grade records are retained.', 'success');
        redirect('teacher-classroom.php?id='.$classroomId);
    }
    if ($action === 'remove_student') {
        $studentId = (int)($_POST['student_id'] ?? 0);
        $stmt = $pdo->prepare("UPDATE class_enrollments SET enrollment_status='removed' WHERE classroom_id=? AND student_id=?");
        $stmt->execute([$classroomId, $studentId]);
        if ($stmt->rowCount()) audit_log($pdo, (int)$user['id'], 'student_removed_from_class', 'classroom', $classroomId, ['student_id'=>$studentId]);
        flash($stmt->rowCount() ? 'Student removed from this classroom.' : 'Student was not enrolled in this classroom.', $stmt->rowCount() ? 'success' : 'info');
        redirect('teacher-classroom.php?id='.$classroomId);
    }
}

$stmt = $pdo->prepare("SELECT ce.student_id, u.name, u.email, ce.joined_at
    FROM class_enrollments ce JOIN users u ON u.id=ce.student_id
    WHERE ce.classroom_id=? AND ce.enrollment_status='active' ORDER BY u.name");
$stmt->execute([$classroomId]); $students = $stmt->fetchAll();
$stmt = $pdo->prepare("SELECT id,title,difficulty,points,time_limit_seconds FROM exercises WHERE created_by=? AND is_published=1 AND (slug IS NULL OR slug NOT LIKE 'ca-htmlcss-path-%') ORDER BY title");
$stmt->execute([(int)$user['id']]); $availableExercises = $stmt->fetchAll();
$stmt = $pdo->prepare("SELECT ca.id AS assignment_id, ca.due_at, ca.is_active, ca.created_at, e.id AS exercise_id, e.title, e.difficulty, e.points,
    (SELECT COUNT(*) FROM grade_records gr WHERE gr.assignment_id=ca.id AND gr.submission_count>0) AS students_submitted,
    (SELECT COUNT(*) FROM grade_records gr WHERE gr.assignment_id=ca.id) AS grade_rows
    FROM class_assignments ca JOIN exercises e ON e.id=ca.exercise_id WHERE ca.classroom_id=? ORDER BY ca.is_active DESC, ca.created_at DESC");
$stmt->execute([$classroomId]); $assignments = $stmt->fetchAll();
$announcementStmt=$pdo->prepare('SELECT id,title,body,created_at FROM class_announcements WHERE classroom_id=? AND teacher_id=? ORDER BY created_at DESC LIMIT 30');$announcementStmt->execute([$classroomId,(int)$user['id']]);$announcements=$announcementStmt->fetchAll();
$overrideStmt=$pdo->prepare("SELECT sao.assignment_id,sao.student_id,sao.extended_due_at,sao.note,u.name AS student_name,e.title AS exercise_title FROM student_assignment_overrides sao JOIN class_assignments ca ON ca.id=sao.assignment_id JOIN exercises e ON e.id=ca.exercise_id JOIN users u ON u.id=sao.student_id JOIN class_enrollments ce ON ce.classroom_id=ca.classroom_id AND ce.student_id=u.id AND ce.enrollment_status='active' WHERE ca.classroom_id=? ORDER BY sao.updated_at DESC LIMIT 100");$overrideStmt->execute([$classroomId]);$overrides=$overrideStmt->fetchAll();
page_header($classroom['name']);
?>
<div class="classroom-detail-top"><a class="back" href="<?= e($config['base_url']) ?>/teacher-classrooms.php">← All classrooms</a><div class="classroom-detail-head"><div><p class="eyebrow">CLASSROOM · <?= e($classroom['section']) ?></p><h1><?= e($classroom['name']) ?></h1><p class="muted"><?= e($classroom['subject'] ?: 'Programming class') ?><?= $classroom['description'] ? ' · '.e($classroom['description']) : '' ?></p></div><span class="classroom-state <?= !empty($classroom['archived_at']) ? 'inactive' : ((int)$classroom['is_active'] ? 'active' : 'inactive') ?>"><?= !empty($classroom['archived_at']) ? 'Archived · Read only' : ((int)$classroom['is_active'] ? 'Active' : 'Paused') ?></span></div>
  <div class="class-code-panel panel"><div><span class="eyebrow">SHARE THIS JOIN CODE</span><p class="muted">Students sign in to CodeArena, open My Classes, and enter this code.</p></div><div class="class-code-large"><strong><?= e($classroom['join_code']) ?></strong><button type="button" class="button small" id="copyJoinCode" data-code="<?= e($classroom['join_code']) ?>">Copy code</button></div></div>
</div>
<?php if (!empty($classroom['archived_at'])): ?><div class="alert warning" role="status"><strong>Archived classroom · read-only</strong><p>This classroom is preserved for records. Restore it from the Classrooms page before changing students, assignments, announcements, deadlines, or retakes.</p><a class="button small" href="<?= e($config['base_url']) ?>/teacher-classrooms.php#archived-classrooms">Manage archived classrooms</a></div><?php endif; ?>
<div class="classroom-overview-stats"><div class="panel"><span class="muted">Enrolled students</span><strong><?= count($students) ?></strong></div><div class="panel"><span class="muted">Active assignments</span><strong><?= count(array_filter($assignments, static fn($a)=>(int)$a['is_active']===1)) ?></strong></div><div class="panel"><span class="muted">Gradebook</span><a class="stat-link" href="<?= e($config['base_url']) ?>/teacher-gradebook.php?classroom_id=<?= $classroomId ?>">View grades ↗</a></div></div>
<div class="classroom-management-grid">
  <section class="panel form-panel"><div class="section-title"><div><h2>Assign an exercise</h2><p class="muted">Assign published programming exercises with automatic grading. Preview-only HTML/CSS projects stay in Learning Paths.</p></div></div>
  <?php if (!empty($classroom['archived_at'])): ?><div class="empty compact-empty"><h3>Archived classroom</h3><p>Assignments are read-only. Restore this classroom to make changes.</p></div>
  <?php elseif (!$availableExercises): ?><div class="empty compact-empty"><h3>No published exercises yet</h3><p>Publish a challenge in Teacher Studio, then return here to assign it.</p><a class="button small" href="<?= e($config['base_url']) ?>/teacher.php">Open Teacher Studio</a></div>
  <?php else: ?><form method="post" class="classroom-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="assign_exercise"><label>Exercise<select name="exercise_id" required><option value="">Select a published exercise</option><?php foreach ($availableExercises as $ex): ?><option value="<?= (int)$ex['id'] ?>"><?= e($ex['title']) ?> · <?= (int)$ex['points'] ?> pts</option><?php endforeach; ?></select></label><label>Due date and time (optional)<input type="datetime-local" name="due_at"><small class="field-hint">Leave blank for no class deadline. Deadlines are checked by the server when starting or submitting.</small></label><button class="button" type="submit">Assign to class →</button></form><?php endif; ?>
  </section>
  <section class="panel classroom-roster"><div class="section-title"><div><h2>Students</h2><p class="muted">Students who joined with your class code.</p></div><span class="pill"><?= count($students) ?> enrolled</span></div>
    <?php if (!$students): ?><div class="empty compact-empty"><h3>Waiting for students</h3><p>Share the join code above so students can enroll.</p></div><?php else: ?><div class="roster-list"><?php foreach ($students as $student): ?><div class="roster-item"><span class="avatar"><?= e(strtoupper(mb_substr((string)$student['name'],0,1))) ?></span><div class="roster-person"><strong><?= e($student['name']) ?></strong><span><?= e($student['email']) ?></span></div><?php if (empty($classroom['archived_at'])): ?><form method="post" onsubmit="return confirm('Remove this student from the classroom? Existing grades are kept.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="remove_student"><input type="hidden" name="student_id" value="<?= (int)$student['student_id'] ?>"><button type="submit" class="quiet-link danger-link">Remove</button></form><?php else: ?><span class="muted">Read only</span><?php endif; ?></div><?php endforeach; ?></div><?php endif; ?>
  </section>
</div>
<section class="panel v23-class-tools" id="bulk-enroll"><div class="section-title"><div><h2>Bulk enroll existing students</h2><p class="muted">Import a CSV with student email addresses in the first column. This does not create accounts or import passwords.</p></div></div><?php if (!empty($classroom['archived_at'])): ?><p class="muted">This classroom is archived. Enrollment changes are disabled.</p><?php else: ?><form method="post" enctype="multipart/form-data" class="v23-inline-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="import_students_csv"><label>Student CSV<input type="file" name="students_csv" accept=".csv,text/csv" required></label><button class="button" type="submit">Import enrollments →</button></form><p class="field-hint">Example CSV: <code>email</code> on the first line, followed by one active student email per row. Maximum 1,000 unique addresses and 2 MB.</p><?php endif; ?></section>
<section class="panel v23-class-tools" id="announcements"><div class="section-title"><div><h2>Class announcements</h2><p class="muted">Post updates about assignments, class reminders, or schedule changes.</p></div><span class="pill"><?= count($announcements) ?> recent</span></div><?php if (empty($classroom['archived_at'])): ?><form method="post" class="v23-stacked-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="post_announcement"><label>Announcement title<input name="announcement_title" maxlength="180" required placeholder="e.g. Lab activity deadline reminder"></label><label>Message<textarea name="announcement_body" rows="3" maxlength="12000" required placeholder="Write an update for enrolled students."></textarea></label><button class="button" type="submit">Post announcement →</button></form><?php else: ?><p class="muted">Archived classroom: announcements are shown read-only.</p><?php endif; ?><?php if($announcements): ?><div class="v23-announcement-list"><?php foreach($announcements as $ann): ?><article class="v23-announcement-card"><div><h3><?= e($ann['title']) ?></h3><small class="muted"><?= e(date('M j, Y · g:i A',strtotime((string)$ann['created_at']))) ?></small><p><?= nl2br(e($ann['body'])) ?></p></div><?php if (empty($classroom['archived_at'])): ?><form method="post" onsubmit="return confirm('Delete this announcement?');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="delete_announcement"><input type="hidden" name="announcement_id" value="<?= (int)$ann['id'] ?>"><button class="button small danger" type="submit">Delete</button></form><?php endif; ?></article><?php endforeach; ?></div><?php endif; ?></section>
<section class="panel v23-class-tools" id="bulk-assign"><div class="section-title"><div><h2>Assign multiple exercises</h2><p class="muted">Select published exercises to assign in one action.</p></div></div><?php if (!empty($classroom['archived_at'])): ?><p class="muted">Archived classroom: assignments cannot be changed.</p><?php elseif($availableExercises): ?><form method="post" class="v23-stacked-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="bulk_assign_exercises"><div class="v23-bulk-exercise-grid"><?php foreach($availableExercises as $ex): ?><label class="v23-bulk-exercise-option"><input type="checkbox" name="exercise_ids[]" value="<?= (int)$ex['id'] ?>"><span><strong><?= e($ex['title']) ?></strong><small><?= e($ex['difficulty']) ?> · <?= (int)$ex['points'] ?> pts</small></span></label><?php endforeach; ?></div><label>Due date and time (optional)<input type="datetime-local" name="bulk_due_at"><small class="field-hint">The same due date is applied to each selected exercise. Existing assignment due dates will be updated.</small></label><button class="button" type="submit">Assign selected exercises →</button></form><?php else: ?><div class="empty compact-empty"><p>Publish programming exercises before assigning them.</p></div><?php endif; ?></section>
<section class="panel v23-class-tools" id="deadline-extensions"><div class="section-title"><div><h2>Individual deadlines and retakes</h2><p class="muted">Extend a student's due date or grant a new timed attempt. The best saved grade remains in the gradebook.</p></div></div>
<?php if (!empty($classroom['archived_at'])): ?><p class="muted">Archived classroom: deadline extensions and retakes are disabled.</p><?php elseif($students && $assignments): ?><div class="v23-class-management-grid"><form method="post" class="v23-stacked-form"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="extend_deadline"><h3>Extend a deadline</h3><label>Student<select name="student_id" required><?php foreach($students as $st): ?><option value="<?= (int)$st['student_id'] ?>"><?= e($st['name']) ?> · <?= e($st['email']) ?></option><?php endforeach; ?></select></label><label>Assignment<select name="assignment_id" required><?php foreach($assignments as $a): if(!(int)$a['is_active'])continue; ?><option value="<?= (int)$a['assignment_id'] ?>"><?= e($a['title']) ?><?= $a['due_at']?' · original '.date('M j',strtotime($a['due_at'])):'' ?></option><?php endforeach; ?></select></label><label>New deadline<input type="datetime-local" name="extended_due_at" required></label><label>Note (optional)<input name="override_note" maxlength="500" placeholder="Reason for extension"></label><button class="button" type="submit">Save extension →</button></form><form method="post" class="v23-stacked-form" onsubmit="return confirm('Grant a new timed attempt? Previous submissions will remain in history, and the gradebook keeps the best score.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="grant_retake"><h3>Grant retake</h3><label>Student<select name="student_id" required><?php foreach($students as $st): ?><option value="<?= (int)$st['student_id'] ?>"><?= e($st['name']) ?> · <?= e($st['email']) ?></option><?php endforeach; ?></select></label><label>Assignment<select name="assignment_id" required><?php foreach($assignments as $a): if(!(int)$a['is_active'])continue; ?><option value="<?= (int)$a['assignment_id'] ?>"><?= e($a['title']) ?></option><?php endforeach; ?></select></label><label>Reason (optional)<input name="retake_reason" maxlength="500" placeholder="e.g. approved extra attempt"></label><button class="button secondary" type="submit">Grant retake →</button></form></div><?php else: ?><div class="empty compact-empty"><p>At least one enrolled student and one assignment are required.</p></div><?php endif; ?>
<?php if($overrides): ?><h3>Saved deadline extensions</h3><div class="table-wrap"><table><thead><tr><th>Student</th><th>Assignment</th><th>Extended deadline</th><th>Note</th></tr></thead><tbody><?php foreach($overrides as $ov): ?><tr><td><?= e($ov['student_name']) ?></td><td><?= e($ov['exercise_title']) ?></td><td><?= e(date('M j, Y · g:i A',strtotime((string)$ov['extended_due_at']))) ?></td><td><?= e($ov['note']??'') ?></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?></section>
<section class="panel assignment-panel"><div class="section-title"><div><h2>Class assignments</h2><p class="muted">Active work and grade record coverage for this section.</p></div><a class="quiet-link" href="<?= e($config['base_url']) ?>/teacher-gradebook.php?classroom_id=<?= $classroomId ?>">Open gradebook ↗</a></div>
<?php if (!$assignments): ?><div class="empty compact-empty"><h3>No assignments yet</h3><p>Use the form above to assign the first published exercise.</p></div><?php else: ?><div class="table-wrap"><table><thead><tr><th>Exercise</th><th>Points</th><th>Due date</th><th>Students submitted</th><th>Status</th><th>Action</th></tr></thead><tbody><?php foreach ($assignments as $assignment): ?><tr><td><strong><?= e($assignment['title']) ?></strong><div class="muted"><?= e($assignment['difficulty']) ?></div></td><td><?= (int)$assignment['points'] ?></td><td><?= $assignment['due_at'] ? e(date('M j, Y · g:i A', strtotime($assignment['due_at']))) : '<span class="muted">No deadline</span>' ?></td><td><?= (int)$assignment['students_submitted'] ?> / <?= count($students) ?></td><td><span class="classroom-state <?= (int)$assignment['is_active'] ? 'active' : 'inactive' ?>"><?= (int)$assignment['is_active'] ? 'Assigned' : 'Removed' ?></span></td><td><?php if ((int)$assignment['is_active'] && empty($classroom['archived_at'])): ?><form method="post" onsubmit="return confirm('Remove this assignment from the class? Existing grade records will be retained.');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="action" value="remove_assignment"><input type="hidden" name="assignment_id" value="<?= (int)$assignment['assignment_id'] ?>"><button type="submit" class="quiet-link danger-link">Remove</button></form><?php elseif (!empty($classroom['archived_at']) && (int)$assignment['is_active']): ?><span class="muted">Read only</span><?php else: ?><span class="muted">—</span><?php endif; ?></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?>
</section>
<script>document.getElementById('copyJoinCode')?.addEventListener('click',async function(){try{await navigator.clipboard.writeText(this.dataset.code);this.textContent='Copied ✓';setTimeout(()=>this.textContent='Copy code',1300)}catch(_e){window.prompt('Copy class code:',this.dataset.code)}});</script>
<?php page_footer(); ?>
