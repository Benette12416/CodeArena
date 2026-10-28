# CodeArena v23 · All-priorities regression checklist

Run after applying migrations 010 and 011 to a backed-up copy of a v22 database. Use separate browser profiles for student, teacher, and Super Admin. Avoid testing irreversible deletions on real records.

## 1. Baseline and role permissions

- [ ] Sign in as a student, teacher, and Super Admin separately.
- [ ] Confirm a deactivated student/teacher is denied access on the next request.
- [ ] Confirm teachers can only edit their own exercises, lessons, classrooms, announcements, and submissions.
- [ ] Confirm a student cannot access teacher or Super Admin routes by pasting their URLs.
- [ ] Confirm hidden test case input/expected output is not sent to student HTML or JSON.
- [ ] Confirm CSRF-protected POST actions reject missing/invalid tokens.

## 2. Lessons and sequential path progress

- [ ] Teacher creates a lesson inside a learning path, adds objectives, lesson content, example code, and a hint, then saves as draft.
- [ ] Draft lesson is not visible as a published student lesson.
- [ ] Teacher publishes the lesson; the eligible student can open it.
- [ ] The next lesson remains locked before the previous lesson is marked complete.
- [ ] Lesson completion survives refresh and appears in student progress.
- [ ] Exercise hint is only included after the student passes the explicit Start Exercise gate.

## 3. Submission feedback and regrading

- [ ] Teacher opens a submission belonging to an exercise they own and leaves feedback.
- [ ] Student sees their own feedback in submission history, not other students' feedback.
- [ ] Teacher regrades a test submission with a reason and confirmation.
- [ ] Regrade is run against the immutable saved exercise-version snapshot selected for the regrade.
- [ ] New score/test summary is saved and previous score/test summary/reason is recorded in `submission_regrade_history`.
- [ ] Class grade record reflects the regraded submission.
- [ ] Learning-path completion is granted only if the regraded result is perfect and all prior path steps are complete; a revoked perfect result removes that exercise completion.
- [ ] Regrade failures do not partially update the submission, grade record, and completion status.
- [ ] Test only with a harmless program because each regrade can consume Judge0 quota.

## 4. Class workflows

- [ ] CSV enrollment adds or reactivates active student accounts only; unknown/inactive emails are skipped.
- [ ] CSV size/row caps and header handling work.
- [ ] Teacher posts an announcement; enrolled students see it in the classroom.
- [ ] Teacher bulk-assigns published exercises and verifies the class gradebook.
- [ ] Individual deadline extension is reflected by the student's assignment/attempt deadline.
- [ ] Teacher grants a retake; earlier submissions remain in history and the new attempt starts at the explicit start gate.
- [ ] Archive a classroom; verify editing controls are hidden and POST requests are rejected.
- [ ] Restore the classroom and confirm the teacher can edit it again.

## 5. Achievements and student insights

- [ ] Submit a first exercise and confirm a first-submission badge is awarded once.
- [ ] Earn a perfect score and verify the badge/progress state.
- [ ] Run practice checks and complete a lesson; verify the related milestones.
- [ ] Student Progress and Leaderboard load with no submissions, partial scores, and perfect scores.
- [ ] Practice runs do not change official classroom grades.

## 6. Exercise versioning, deadlines, and grading

- [ ] Start an exercise, record its snapshot/version, then edit the live exercise.
- [ ] Existing attempt uses its saved snapshot; new attempts use the new version.
- [ ] Run Code does not create a graded submission or change official grades.
- [ ] Submit Answer saves one final result and duplicate clicks do not create inconsistent duplicate grades.
- [ ] Expired/completed attempts reject new execution/submission requests.
- [ ] Perfect score stops the timer and shows the correct Done/Continue action.

## 7. Exam monitoring

- [ ] Monitoring is enabled by a teacher for a new attempt; settings are snapshotted at attempt start.
- [ ] Tab visibility, copy, cut, paste, and supported fullscreen events are logged server-side.
- [ ] Teacher can filter and review events and save a note/status.
- [ ] Individual event deletion and delete-all actions require CSRF and the teacher's ownership scope.
- [ ] Monitoring events never automatically change a student's score.

## 8. Super Admin and deployment readiness

- [ ] System Health shows required runtime, database groups, and project files.
- [ ] `tools/health_check.php`, `tools/smoke_test.php`, and `tools/v23_smoke_test.php` finish successfully against the local database.
- [ ] Verify the Judge0 endpoint separately; execution probe may consume provider quota.
- [ ] Back up the database and restore it into a separate test database.
- [ ] Verify the restored database can connect before making a production upgrade.
- [ ] Check desktop, tablet, mobile, keyboard focus, reduced motion, empty states, and visible form errors.
