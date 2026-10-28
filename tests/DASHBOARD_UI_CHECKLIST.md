# CodeArena v19 Dashboard UI Checklist

Use this checklist after installing v19. It checks rendered workflows, not only PHP syntax.

## Student dashboard

- [ ] Sign in as a student and open `public/index.php`.
- [ ] Confirm the greeting, primary actions, four metrics, momentum strip, quick links, continuation panel, deadline panel, recent submissions, classrooms and practice arena render without horizontal page overflow.
- [ ] Test the layout at desktop width, tablet width, and a narrow mobile viewport.
- [ ] Confirm the progress bar shows `0%` when there are no available exercises and does not display a completed count greater than the available count.
- [ ] With no submissions, confirm the empty-state guidance and Find a challenge link appear.
- [ ] Click each shortcut: My Classes, Learning Paths, My Progress, and Leaderboard.
- [ ] With submissions available, confirm the recent rows show title, timestamp, passed/total test count, and score color.
- [ ] Check keyboard focus visibility and verify reduced-motion preferences do not cause unnecessary hover animations.

## Teacher dashboard

- [ ] Sign in as a teacher and open `public/teacher.php`.
- [ ] Confirm the first-name welcome, Create Exercise and Manage Classrooms actions, and CREATE · ASSIGN · REVIEW cards are visible.
- [ ] Click each workflow item and verify Create goes to `#challenge-builder`, Assign opens Teacher Classrooms, and Review opens submissions.
- [ ] Confirm all six metric cards render sensible counts and the action links go to the content library, classrooms/rosters, assignments, submissions, and exam monitoring.
- [ ] Confirm the Teacher Studio section nav can scroll horizontally on small screens and each in-page anchor lands on the correct section.
- [ ] With no submissions, confirm the empty state offers an Open Classrooms action; with activity, confirm student names, exercise titles, dates, test counts, and scores render.
- [ ] Confirm the existing create/edit exercise form, test-case actions, monitoring settings, and content-library filters still work.

## Regression / integration

- [ ] Open Super Admin System Health and confirm no required route is missing.
- [ ] Run `PHP_BIN=/Applications/XAMPP/xamppfiles/bin/php ./tools/check_project.sh` from the project directory.
- [ ] Run `tools/health_check.php` and `tools/smoke_test.php` using XAMPP's PHP CLI.
- [ ] Test Judge0 only when ready to consume an API request; static tests don't prove live code execution.
