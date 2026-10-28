# Practice Arena and Python learning-path test plan

## Practice Arena visibility

- Sign in as a student and verify `Practice Arena` appears as a prominent purple button in the top navigation on desktop and mobile.
- Click it from a page other than the dashboard and confirm it returns to `index.php#practice`.
- On the student dashboard, verify the Practice Arena spotlight appears above the continue/deadlines panels and its buttons work.
- Confirm the Practice Arena note says practice runs do not affect official classroom grades.
- Sign in as a teacher or Super Admin and confirm the student-only spotlight does not appear.

## Seed the Python path

1. Ensure the `learning_paths`, `learning_path_items`, `exercises`, and `test_cases` tables exist. The v19 schema contains these already.
2. Ensure at least one teacher account exists.
3. Open phpMyAdmin, select `codearena`, choose **Import**, and import `database/seeds/python_foundations_learning_path.sql`.
4. Check the import result. The final query should show the target teacher ID, a Python path ID, and 8 path steps.
5. Sign in as the target teacher and open Teacher Studio > Learning paths. Verify the published path and its eight published exercises are present.
6. Sign in as a student and open **Learning paths**. The path should appear with eight steps.

## Test each path step

The path steps each have one public sample and three hidden cases. In Practice Mode, only the public sample is run. Successful sample checking records practice progress; it must not create official submissions or attempts.

1. `Python 01 - Hello, Python!`: empty input, expected `Hello, Python!`.
2. `Python 02 - Add Two Integers`: sample `3 5`, expected `8`.
3. `Python 03 - Rectangle Area`: sample `4 6`, expected `24`.
4. `Python 04 - Even or Odd`: sample `7`, expected `Odd`.
5. `Python 05 - Sum from 1 to N`: sample `5`, expected `15`.
6. `Python 06 - Largest of Three`: sample `12 25 8`, expected `25`.
7. `Python 07 - Count the Vowels`: sample `Programming`, expected `3`.
8. `Python 08 - Calculate Factorial`: sample `5`, expected `120`.

After passing a sample, refresh Learning Paths and confirm its progress moves forward. If code execution is unavailable, check Judge0 settings in `config/config.php` before treating the seed as faulty.

## Seed behavior and ownership

The seed script uses the most recently created teacher account by default, so that teacher owns the exercises and learning path. To choose a different teacher, replace the `SET @teacher_id` line in the SQL with that teacher's numeric ID. Query teacher IDs with:

```sql
SELECT id, name, email FROM users WHERE role = 'teacher' ORDER BY id DESC;
```

The seed is safe to import again for the same teacher: it does not duplicate exercises, the path, or path items, and it does not overwrite an existing test case at the same sort order. Missing test cases for an exercise/sort order are inserted again; an existing but incorrect test case is left unchanged. Existing exercise descriptions, starter code, and teacher path edits are not overwritten.
