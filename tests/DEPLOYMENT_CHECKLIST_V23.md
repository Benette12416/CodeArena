# CodeArena v23 · Deployment and recovery checklist

This checklist is for local evaluation and controlled deployment. Do not expose an XAMPP development install directly to the public internet.

## Before upgrade

- [ ] Export the active database using phpMyAdmin or `./tools/backup_database.sh`.
- [ ] Make a file copy of the CodeArena folder, especially `config/config.php`.
- [ ] Confirm available disk space and note the current migration level.
- [ ] Apply migration 010 once, then migration 011 once when upgrading from v22.
- [ ] Keep the backup outside the public `htdocs` web root.

## Configuration and application hardening

- [ ] Use a dedicated MySQL account with only the privileges the application requires; do not use MySQL root on a deployed server.
- [ ] Keep Judge0 keys and database secrets on the server. Never hard-code them into browser JavaScript.
- [ ] Use HTTPS, secure/HttpOnly/SameSite cookies, a strong Super Admin password, and `display_errors=Off` in deployed PHP configuration.
- [ ] Keep `config`, `database`, and `tools` inaccessible from HTTP. The provided `.htaccess` restrictions require Apache `AllowOverride` to permit them.
- [ ] Configure application/PHP error logs with restricted filesystem permissions and avoid logging source code, passwords, tokens, or clipboard contents.
- [ ] Review account activation, role changes, password resets, regrades, bulk enrollment, and destructive actions in audit logs.
- [ ] Confirm the Judge0 provider's authentication, language IDs, resource/time limits, and quota before inviting a class.

## Backups and recovery

- [ ] Run a fresh database backup before every migration or destructive cleanup.
- [ ] Restore a copy into a new database name; never test restoration over the active database.
- [ ] Run health and smoke tests against the restored DB.
- [ ] Retain at least one backup in a separate secure location.
- [ ] Document who can access backups and how long they are retained.

## Operational acceptance

- [ ] Run `tools/check_project.sh`.
- [ ] Run `tools/health_check.php`, `tools/smoke_test.php`, and `tools/v23_smoke_test.php`.
- [ ] Complete `tests/ALL_PRIORITIES_V23.md` on a test copy with test accounts.
- [ ] Verify Judge0 compilation/execution with a safe program and check usage quota.
- [ ] Verify mobile layout and keyboard operation.
- [ ] Do not open access to students until core role, grading, deadlines, hidden tests, monitoring, and backup/restore tests pass.
