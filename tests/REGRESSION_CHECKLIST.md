# CodeArena v15 regression checklist

Run against a disposable local copy before using the system for a real class. Export the database first and use test accounts. Mark a test complete only after checking the actual browser page and database effect where appropriate.

## Upgrade and recovery

- [ ] Back up the project folder and export the existing `codearena` database.
- [ ] Upgrade from v14 and import `database/migrations/007_exercise_version_history.sql` exactly once.
- [ ] Run `PHP_BIN=/Applications/XAMPP/xamppfiles/bin/php ./tools/check_project.sh`.
- [ ] Run `/Applications/XAMPP/xamppfiles/bin/php tools/health_check.php`; required table checks should pass.
- [ ] Run `./tools/backup_database.sh`, confirm the backup file is outside `htdocs`, and run `./tools/restore_database.sh <backup.sql> codearena_restore_test` into a new database.
- [ ] Confirm restore refuses to overwrite an existing database.

## Navigation and role separation

- [ ] When signed out, public navigation shows Help/About and sign-in links.
- [ ] After student login, Help/About are absent from top navigation and footer; student links are shown.
- [ ] After teacher login, Help/About are absent; Teacher Studio, classrooms, submissions, analytics, learning paths, and monitoring links are available.
- [ ] Super Admin has a separate control-center navigation and no Help/About links.
- [ ] Mobile nav opens/closes, announces expanded state, closes on Escape, and links remain keyboard accessible.
- [ ] The Teacher Studio workflow card shows CREATE, ASSIGN, REVIEW with useful destinations.

## Exercise version history and grading

- [ ] Create a draft exercise with one public sample and at least one hidden test case; save creates version 1.
- [ ] Start a new student attempt; verify the attempt has an `exercise_version_id`.
- [ ] On a v14 upgrade fixture, verify legacy attempts with saved submissions are promoted without resetting `best_score`, `deadline_at`, `status`, or submission history. Verify untouched legacy attempts still show the Start Exercise screen.
- [ ] Edit title/points/starter code/test cases in Teacher Studio; a new version appears.
- [ ] Submit code in the already-started attempt; grading uses the attempt's earlier snapshot and does not reveal hidden test values.
- [ ] Open the teacher submission inspector; it shows the original exercise title, historical maximum points, and version number for a versioned submission.
- [ ] Restore an earlier version; verify current exercise/test cases are restored, while already-started attempts remain on their original snapshot.
- [ ] Confirm gradebook denominators match the historical maximum points tied to the student's best submission.
- [ ] Test a snapshot with no test cases; the history page must not crash, though the exercise cannot be graded until the teacher adds cases.

## Judge0 and execution

- [ ] Run `php tools/health_check.php --judge0` and note if endpoint connectivity passes.
- [ ] Submit a simple program in each configured supported language and verify queued execution returns a terminal result.
- [ ] Confirm batch submission requests use the provider's documented payload shape and auth headers.
- [ ] Confirm batch-result polling maps `status_id` to the same verdicts as individual result polling; if GET batch is unsupported, confirm individual polling fallback works.
- [ ] Test a provider without batch support if available; 404/405/501 batch responses should fall back to individual token submissions.
- [ ] Test a compile error, wrong answer, runtime error, slow result, HTTP 401/403, and HTTP 429; errors should be understandable and credentials/raw provider bodies are not exposed.
- [ ] Run Code does not save a submission or grade; Submit Answer does.
- [ ] A perfect score completes the attempt, stops its timer, and blocks further Run/Submit calls.
- [ ] Hidden test input/expected output is never returned in browser responses or stored in the public verdict summary.

## Student classroom and learning

- [ ] Before starting, exercise page returns only title, time limit, total points, and Start action; no problem text or samples appear in HTML.
- [ ] Start Exercise creates a new attempt with a version snapshot and a server-enforced deadline.
- [ ] Test a partial score, at-least-half score, and perfect score; labels/tones match configured rules.
- [ ] Student classroom assignment shows correct title/time/points for an active attempt snapshot.
- [ ] Join a classroom, open an assignment, and confirm assignment and enrollment checks run server-side.
- [ ] Practice Mode does not create official grades/attempts, runs only public sample cases, and logs practice progress separately.
- [ ] Learning path order and progress are correct; suggestions do not change official scores.
- [ ] Student skills map and progress views do not mark an untouched exercise as failed.

## Teacher reporting, monitoring, and audit

- [ ] Teacher analytics page loads with empty states when no submissions exist.
- [ ] Activity chart covers 14 days and has correct submission totals for the displayed window.
- [ ] Topic score percentages and gradebook use the exercise version's max points where available.
- [ ] Class gradebook search/status filters, submission inspector, and CSV export work.
- [ ] Enable monitoring before a fresh attempt and choose a warning threshold.
- [ ] Switch browser tabs and test copy/cut/paste within supported exam content; confirm only supported browser events are logged.
- [ ] Verify server timestamps, event count, warning threshold, and teacher-scoped reports.
- [ ] Save a review note/status and verify it persists after reload.
- [ ] Delete one event, then test bulk deletion only on disposable records; grades and submissions remain unchanged and the deletion is audited.
- [ ] Monitoring events do not automatically change grades or label a student as cheating.

## Security, responsiveness, and accessibility

- [ ] A student cannot open Teacher Studio, teacher submission inspection, analytics, monitoring reports, or Super Admin routes.
- [ ] A teacher cannot inspect or edit another teacher's exercise/class/submission by modifying URL or POST IDs.
- [ ] All state-changing teacher/student POST forms validate CSRF; no destructive action uses GET.
- [ ] Five repeated failed login attempts exercise the rate limit; successful login clears the test identity's rate-limit record.
- [ ] Inspect audit logs for exercise-version changes/restores, login success/failure, monitoring review/deletion, and submission inspection. Ensure no passwords, clipboard content, or source code are stored in audit details.
- [ ] `config/config.php` is not committed or exposed; Judge0 credentials stay server-side.
- [ ] Test desktop (1440px), tablet (768px), and phone (390px) layouts.
- [ ] Verify CREATE · ASSIGN · REVIEW workflow kicker and cards remain legible at each width.
- [ ] Keyboard-only navigation has a visible focus ring, skip link, working nav toggle, and usable forms.
- [ ] Reduced-motion preference suppresses nonessential transitions/animations.
- [ ] Verify optional CDN failures still leave a usable text editor fallback.

## Known limitations to test/document

- Browser monitoring is not a full lockdown browser and cannot reliably detect activity in other applications or read clipboard content.
- Migration 007 cannot recreate historical snapshots for work that happened in v14 before version tracking existed; old attempts get a baseline when first revisited.
- Restoring an exercise version does not automatically regrade previous submissions. Regrading should be a separate, audited, deliberate operation.
- Static checks do not establish database/SQL correctness or live Judge0 compatibility; test the target provider and XAMPP database explicitly.


## v18 system health and database smoke tests

- [ ] Sign in as Super Admin and open **System health** from the Control Center sidebar.
- [ ] Verify the page reports PHP/extensions, database feature groups, required files, and Judge0 language IDs without showing secrets.
- [ ] Click **Check endpoint** and confirm the result distinguishes success, authentication denial, provider status, and network/DNS failures.
- [ ] Run the Python execution smoke test only when ready to consume one Judge0 submission; verify the expected marker result.
- [ ] Run `tools/health_check.php` and `tools/smoke_test.php` using the XAMPP PHP CLI. Confirm the latter does not mutate data.
- [ ] If any feature group is incomplete, apply only the relevant migration that has not already been run; never repeatedly import a migration as a generic troubleshooting step.
- [ ] Test a restore into a new database name before considering the installation deployment-ready.
