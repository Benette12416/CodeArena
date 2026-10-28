# Developer Contact Link Tests · v25

## Static checks
- [ ] `https://github.com/Benette12416` appears in the About profile card.
- [ ] Public homepage includes a Contact developer CTA.
- [ ] Shared footer displays Contact developer for signed-out and signed-in users.
- [ ] Student/teacher authentication footer has a GitHub contact link.
- [ ] Super Admin login and authenticated footer have a GitHub contact link.
- [ ] External anchors use `target="_blank"` and `rel="noopener noreferrer"`.
- [ ] No database migration is needed.

## Browser checks on macOS XAMPP
- [ ] Open `public/index.php`; click Contact developer in the homepage support section.
- [ ] Open `public/about.php`; check profile card at desktop and mobile widths.
- [ ] Sign in as a student and check footer contact link.
- [ ] Sign in as a teacher and check footer contact link.
- [ ] Sign in as Super Admin and check Control Center footer contact link.
- [ ] Open student/teacher login and Super Admin login; verify authentication footer contact link.
- [ ] Check the link opens a new tab and returns to CodeArena unchanged.
- [ ] Confirm no database changes occurred.
