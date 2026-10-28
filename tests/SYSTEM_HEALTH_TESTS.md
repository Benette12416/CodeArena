# CodeArena v18 System Health Test Plan

This test plan supplements `REGRESSION_CHECKLIST.md`. The system-health dashboard is restricted to Super Admins and is available at `/CodeArena/public/super-admin/system-health.php`.

## 1. Static checks

From the project folder on macOS XAMPP:

```bash
PHP_BIN=/Applications/XAMPP/xamppfiles/bin/php ./tools/check_project.sh
/Applications/XAMPP/xamppfiles/bin/php tools/health_check.php
/Applications/XAMPP/xamppfiles/bin/php tools/smoke_test.php
```

The CLI health check reports missing tables/columns and required route/tool files without printing database credentials. The smoke test is read-only: it prepares and executes query shapes for Student My Progress, the global leaderboard, My Classes, Teacher Gradebook, exercise-version snapshots, and monitoring joins with `LIMIT 0` where appropriate. It does not create or alter student data.

For a separate Judge0 endpoint connectivity probe:

```bash
/Applications/XAMPP/xamppfiles/bin/php tools/health_check.php --judge0
```

This checks service reachability only; it does not prove that a specific language ID compiles successfully.

## 2. Super Admin System Health page

1. Sign in using a Super Admin account.
2. Open Control Center → System health.
3. Confirm runtime checks, database feature groups, routes/files, and Judge0 language IDs are displayed without exposing any API key or database password.
4. Click **Check endpoint**. Verify it distinguishes successful responses, authentication/access errors, HTTP errors, and DNS/network failures.
5. Click **Run Python execution test** only when ready. This submits one short Python program through the configured Judge0 endpoint and may consume provider quota.
6. Open Audit log and confirm the diagnostic event is recorded without storing credentials, program source, or provider response bodies.
7. Confirm a student or teacher cannot access the Super Admin health page; they should be redirected to their own portal.

## 3. Data and route checks

Use at least one student test account, one teacher test account, and one Super Admin account.

- Student My Classes loads with zero classes and with one or more classes.
- My Progress loads when no submissions exist and after a partial/perfect submission.
- Leaderboard loads with no submissions, global rankings, and a classroom selection. A student cannot select a classroom to which they are not enrolled.
- Teacher Gradebook opens the class picker and a specific class gradebook. The teacher cannot query another teacher's class.
- Submission inspector shows only records accessible to the teacher and never returns hidden test inputs/expected outputs.
- A started attempt retains its exercise snapshot; editing an exercise does not change the version tied to an existing attempt/submission.
- A completed/expired attempt rejects new Run Code and Submit Answer requests.
- Exam events and review notes are teacher-scoped; deleting monitoring history does not change grades.
- The backup script creates a private SQL file outside the web root. Restore into a new test database and validate it before switching the app config.

## 4. Expected limitations

- A database failure prevents authenticated pages from loading because sessions and roles depend on the database. Use the CLI health check to diagnose that case.
- A system-info endpoint may be disabled by a Judge0 provider. In that case, connectivity diagnostics can report that the host responds while the endpoint is unavailable; the Python execution smoke test is a separate, explicit test.
- Passing static checks does not guarantee browser compatibility or live Judge0 functionality. Complete these tests in the local XAMPP environment before real classroom use.
