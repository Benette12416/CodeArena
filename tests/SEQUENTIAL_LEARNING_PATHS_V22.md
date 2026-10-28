# CodeArena v22: Language Cards and Sequential Progression Tests

Use a test student and a disposable learning path before assigning the curriculum to a real class.

## Language card overview

- [ ] Student Learning Paths shows a separate card for each published path: Python, C, C++, Java, PHP, Ruby, and HTML/CSS.
- [ ] Each card shows its language/title, step count, completion count, and progress bar.
- [ ] Clicking Python opens its full ordered list; other language cards open their own path rather than the Python curriculum.
- [ ] A 30-step path displays all 30 rows, from 01 through 30, in `sort_order` order.
- [ ] The back button returns to the card overview.

## Unlocking and server-side enforcement

- [ ] A new student can open step 1, subject to classroom enrollment rules.
- [ ] Steps 2–30 show a locked state until all earlier steps are complete.
- [ ] Locked rows contain only title and safe metadata, not the problem statement, starter source, sample input/expected output, or hidden test data.
- [ ] Manually opening `/practice.php?id=<step-2-id>&path_id=<path-id>` redirects to the path instead of exposing the locked problem.
- [ ] Sending a `practice-run.php` POST for a locked step is rejected server-side.
- [ ] Sending `practice-complete.php` a POST for a locked HTML/CSS step is rejected server-side.
- [ ] Passing all public samples does not unlock the next step.
- [ ] Passing some but not all tests in path mode does not record completion.
- [ ] Passing every public and hidden test records a completion and unlocks the next step only.
- [ ] Hidden test responses show only pass/fail status, not their input or expected output.
- [ ] Reloading the page and signing out/back in preserve completion.
- [ ] A step completed earlier can be reviewed without erasing completed progress.
- [ ] Python/C/C++/Java/PHP/Ruby path steps enforce the correct programming language server-side.

## HTML/CSS preview projects

- [ ] HTML/CSS steps open the sandboxed preview editor.
- [ ] Mark project complete saves a manual completion record.
- [ ] The completion record unlocks the next step but does not change official grades.
- [ ] The next HTML/CSS project remains locked until its predecessor is marked complete.

## Classroom access and migrations

- [ ] A student not enrolled in a classroom assignment cannot open that assigned challenge.
- [ ] A path item requiring enrollment directs the student to My Classes if not enrolled.
- [ ] Migration 009 creates `learning_path_completions` and copies the existing HTML/CSS manual completion records.
- [ ] The migration is applied only once on an existing v21 database. Fresh installs use `database/schema.sql` instead.
- [ ] All seven paths show 30 steps each after seeding the curriculum.

## Judge0 and completion errors

- [ ] A Judge0/network failure displays an error without recording a path completion.
- [ ] An execution that times out or returns a non-Accepted result does not unlock the next step.
- [ ] The `learning_path_completions` unique key prevents duplicate completion rows for the same student, path, and exercise.
