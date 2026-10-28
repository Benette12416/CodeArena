# CodeArena v25 · Developer Contact Profile

This release adds the developer's GitHub profile as a clear contact destination across the public site and authenticated portals.

**Developer profile:** https://github.com/Benette12416

## What changed

- Added a responsive developer profile card to `public/about.php` with a **Visit GitHub profile** link.
- Added **Contact developer ↗** to the public landing-page support banner.
- Added a **Contact developer ↗** link to the shared footer on student, teacher, public, and signed-in pages.
- Added a contact link to student/teacher authentication footers and Super Admin login/footer areas.
- External links use `target="_blank"` with `rel="noopener noreferrer"`.
- Added `public/assets/v25-developer-contact.css` for responsive styling and keyboard focus states.
- No application behavior, role permissions, learning paths, grading, monitoring, or database schema changed.

GitHub is the contact destination. Available contact methods depend on the profile and repository settings; GitHub may not provide direct messaging. Users can visit the profile and use contact options available there.

## Upgrade on macOS XAMPP

1. Back up the current `CodeArena` folder and export the `codearena` database from phpMyAdmin.
2. Extract the v25 ZIP and copy the updated `CodeArena` folder contents into:
   `/Applications/XAMPP/xamppfiles/htdocs/CodeArena`
3. Keep your current `config/config.php`; do not replace it with `config.example.php`.
4. Start Apache and MySQL in XAMPP Manager.
5. Open `http://localhost/CodeArena/public/` and press **Command + Shift + R** to refresh cached assets.
6. No SQL migration is required.

## Verification

From Terminal:

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/CodeArena
PHP_BIN=/Applications/XAMPP/xamppfiles/bin/php ./tools/check_project.sh
```

The shared layout, authentication layout, and Super Admin layout include the new CSS. The contact URL is available in the homepage support banner, About page profile card, all shared footers, and login/authentication footers.

Static PHP and CSS checks do not replace a live browser check. Please open the public homepage, About page, student dashboard, teacher dashboard, Super Admin dashboard, and login pages on your Mac to verify the link looks good at desktop and mobile widths.
