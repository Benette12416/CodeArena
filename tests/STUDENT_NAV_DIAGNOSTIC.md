# Student navigation and page diagnostic (v17)

## Routes checked

- `student-classrooms.php` — student classroom list and join-code form
- `student-progress.php` — skills map and challenge history
- `leaderboard.php` — global/class rankings
- Shared navigation links use the configured `base_url` and filenames that exist under `public/`.

## What changed

- Student progress now uses compatibility-aware SQL when optional schema elements from migrations 004, 006, or 007 are missing. In compatibility mode it still renders basic published-exercise progress, and shows a notice identifying that the database may need an upgrade.
- The leaderboard checks whether exercise-version snapshots are available. Without them, it uses the current exercise point value rather than failing due to a missing `exercise_versions` table or `submissions.exercise_version_id` column.
- The progress query includes `time_limit_seconds`, fixing the recommendation card's time display.
- The My Classes grid now gives a single classroom card a balanced, wider layout instead of leaving an empty second column. The grid collapses responsively for tablets and phones.

## Manual verification

1. Sign in with a student account.
2. Open **My classes**, join a class or open an existing class.
3. Open **My progress**. Confirm it renders and the recommended challenge shows a sensible time limit.
4. Open **Leaderboard**. Confirm the global ranking renders; if enrolled in a class, select the classroom ranking too.
5. If a compatibility notice appears, inspect the current database and apply only the missing migration(s). Do not re-run migrations that have already been applied.
6. Test at desktop width and at phone width. A single classroom should not be confined to half the content area.
