# Multi-language learning paths regression checklist

## Seed/import
- [ ] Back up the existing `codearena` database before importing seed data.
- [ ] Apply migration `008_html_css_learning_completion.sql` once.
- [ ] Import `database/seeds/all_language_learning_paths_30.sql`.
- [ ] Confirm seven published paths appear under the selected teacher.
- [ ] Confirm each path has 30 steps in the final summary query.
- [ ] Re-import into a test database and confirm no duplicate path items or test cases appear.

## Code paths
- [ ] Open one Python step and confirm the editor defaults to Python.
- [ ] Open one C step and confirm the editor defaults to C.
- [ ] Open one C++ step and confirm the editor defaults to C++.
- [ ] Open one Java step and confirm the editor defaults to Java.
- [ ] Open one PHP step and confirm the editor defaults to PHP.
- [ ] Open one Ruby step and confirm the editor defaults to Ruby.
- [ ] Run the public sample for each language using a working Judge0 endpoint.
- [ ] Confirm hidden test cases are not exposed in Practice Mode.
- [ ] Confirm public sample checks affect practice progress only, not official grades.

## HTML/CSS projects
- [ ] Open a project from the published HTML/CSS path.
- [ ] Confirm HTML/CSS Preview is selected and code is shown in an HTML-aware editor.
- [ ] Change markup or CSS and click Preview HTML; confirm the sandboxed preview updates.
- [ ] Confirm no code is sent to Judge0 when Preview HTML is clicked.
- [ ] Click Mark project complete; confirm a row is stored in `practice_lesson_completions`.
- [ ] Return to Student Learning Paths and confirm the step is complete.
- [ ] Confirm the project completion does not affect official grades or classroom submissions.
- [ ] Confirm a direct HTML/CSS project URL without a valid path context redirects to Student Learning Paths.

## Existing data
- [ ] Confirm the original first eight Python exercises remain unchanged if they were already seeded.
- [ ] Confirm existing classroom assignments, submissions, scores, and monitoring logs remain unchanged.
- [ ] Confirm the migration does not recreate tables that already exist.
