-- CodeArena Python Foundations learning path seed pack (safe to import more than once).
-- Import AFTER the learning_paths, learning_path_items, exercises, and test_cases tables exist.
-- A teacher account must exist. By default this creates the path under the most recently created teacher account.
-- To target a specific teacher, replace the next SET with: SET @teacher_id := 123;
USE codearena;
SET @teacher_id := (SELECT id FROM users WHERE role='teacher' ORDER BY id DESC LIMIT 1);
-- Exercise slugs are namespaced by teacher ID to avoid collisions between teachers.
SET @py01_slug := CONCAT('ca-python-path-01-hello-t', @teacher_id);
SET @py02_slug := CONCAT('ca-python-path-02-add-two-t', @teacher_id);
SET @py03_slug := CONCAT('ca-python-path-03-rectangle-area-t', @teacher_id);
SET @py04_slug := CONCAT('ca-python-path-04-even-odd-t', @teacher_id);
SET @py05_slug := CONCAT('ca-python-path-05-sum-to-n-t', @teacher_id);
SET @py06_slug := CONCAT('ca-python-path-06-largest-three-t', @teacher_id);
SET @py07_slug := CONCAT('ca-python-path-07-count-vowels-t', @teacher_id);
SET @py08_slug := CONCAT('ca-python-path-08-factorial-t', @teacher_id);

-- Create eight published Python-oriented practice exercises. Existing rows are left untouched.
INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 01 - Hello, Python!', @py01_slug, 'Write a Python 3 program that prints exactly Hello, Python! and nothing else.

Input: No input is provided.
Output: Print Hello, Python! on one line.', 'Easy', 'Fundamentals', 300, 100, '# Print the exact message required by the exercise.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 02 - Add Two Integers', @py02_slug, 'Read two integers from standard input. They may be separated by spaces or newlines. Print their sum.

Input: Two integers a and b, each between -100000 and 100000.
Output: Print a + b as one integer.
Hint: Convert the input values to int before adding them.', 'Easy', 'Variables & Types', 480, 100, '# Read two integers and print their sum.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 03 - Rectangle Area', @py03_slug, 'Read the width and height of a rectangle and print its area. Width and height are non-negative integers.

Input: Two integers, width and height, separated by whitespace. Each is between 0 and 1000.
Output: Print width multiplied by height.
Hint: Area = width * height.', 'Easy', 'Variables & Types', 480, 100, '# Read width and height, then print the rectangle area.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 04 - Even or Odd', @py04_slug, 'Read an integer and print Even when it is divisible by 2. Otherwise, print Odd. Include negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator %.', 'Easy', 'Conditionals', 480, 100, '# Read an integer and print Even or Odd.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 05 - Sum from 1 to N', @py05_slug, 'Read a positive integer N and calculate the sum 1 + 2 + ... + N. Use a loop to practice repetition.

Input: One integer N where 1 <= N <= 100000.
Output: The sum as an integer.
Hint: Start a total at 0 and add each number from 1 through N.', 'Easy', 'Loops', 600, 100, '# Read N and use a loop to calculate 1 + 2 + ... + N.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 06 - Largest of Three', @py06_slug, 'Read three integers and print the largest. Values may be negative, and two or more values may be equal.

Input: Three integers separated by spaces or newlines.
Output: The largest integer.
Hint: Compare the numbers or use Python built-in functions.', 'Medium', 'Conditionals', 600, 100, '# Read three integers and print the largest value.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 07 - Count the Vowels', @py07_slug, 'Read one word and count its vowels: a, e, i, o, and u. Count uppercase and lowercase vowels. The input contains English letters only.

Input: One word.
Output: The number of vowels.
Hint: Loop through each character and check whether it is one of the five vowels.', 'Medium', 'Strings', 720, 100, '# Read a word and count its uppercase and lowercase vowels.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

INSERT IGNORE INTO exercises (title, slug, description, difficulty, topic, time_limit_seconds, points, starter_code, is_published, monitoring_enabled, warning_threshold, created_by)
SELECT 'Python 08 - Calculate Factorial', @py08_slug, 'Calculate the factorial of a non-negative integer N. Factorial is the product of all integers from 1 through N. By definition, 0! = 1.

Input: One integer N where 0 <= N <= 12.
Output: N! as an integer.
Hint: Start the product at 1 and multiply it by each number from 1 through N.', 'Medium', 'Loops', 720, 100, '# Read N and calculate N! using a loop.', 1, 0, 3, @teacher_id WHERE @teacher_id IS NOT NULL;

SET @py01_id := (SELECT id FROM exercises WHERE slug=@py01_slug AND created_by=@teacher_id LIMIT 1);
SET @py02_id := (SELECT id FROM exercises WHERE slug=@py02_slug AND created_by=@teacher_id LIMIT 1);
SET @py03_id := (SELECT id FROM exercises WHERE slug=@py03_slug AND created_by=@teacher_id LIMIT 1);
SET @py04_id := (SELECT id FROM exercises WHERE slug=@py04_slug AND created_by=@teacher_id LIMIT 1);
SET @py05_id := (SELECT id FROM exercises WHERE slug=@py05_slug AND created_by=@teacher_id LIMIT 1);
SET @py06_id := (SELECT id FROM exercises WHERE slug=@py06_slug AND created_by=@teacher_id LIMIT 1);
SET @py07_id := (SELECT id FROM exercises WHERE slug=@py07_slug AND created_by=@teacher_id LIMIT 1);
SET @py08_id := (SELECT id FROM exercises WHERE slug=@py08_slug AND created_by=@teacher_id LIMIT 1);

-- Create the published path once for this teacher.
INSERT INTO learning_paths (teacher_id, title, description, is_published)
SELECT @teacher_id, 'Python Foundations: From First Program to Problem Solving', 'A beginner-friendly, step-by-step Python 3 path. Learn output, input and variables, arithmetic, conditionals, loops, strings, and problem solving. Complete the public sample in each step to record your practice progress. These practice exercises do not change official classroom grades.', 1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='Python Foundations: From First Program to Problem Solving');
SET @python_path_id := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='Python Foundations: From First Program to Problem Solving' ORDER BY id DESC LIMIT 1);

-- Add ordered steps. INSERT IGNORE makes re-import safe.
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py01_id, 1 WHERE @python_path_id IS NOT NULL AND @py01_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py02_id, 2 WHERE @python_path_id IS NOT NULL AND @py02_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py03_id, 3 WHERE @python_path_id IS NOT NULL AND @py03_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py04_id, 4 WHERE @python_path_id IS NOT NULL AND @py04_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py05_id, 5 WHERE @python_path_id IS NOT NULL AND @py05_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py06_id, 6 WHERE @python_path_id IS NOT NULL AND @py06_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py07_id, 7 WHERE @python_path_id IS NOT NULL AND @py07_id IS NOT NULL;
INSERT IGNORE INTO learning_path_items (path_id, exercise_id, sort_order) SELECT @python_path_id, @py08_id, 8 WHERE @python_path_id IS NOT NULL AND @py08_id IS NOT NULL;

-- Add one public sample plus three hidden cases for each exercise; do not overwrite edited cases.
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py01_id, '', 'Hello, Python!', 1, 1 WHERE @py01_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py01_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py01_id, '', 'Hello, Python!', 0, 2 WHERE @py01_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py01_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py01_id, '', 'Hello, Python!', 0, 3 WHERE @py01_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py01_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py01_id, '', 'Hello, Python!', 0, 4 WHERE @py01_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py01_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py02_id, '3 5', '8', 1, 1 WHERE @py02_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py02_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py02_id, '-4 9', '5', 0, 2 WHERE @py02_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py02_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py02_id, '0 0', '0', 0, 3 WHERE @py02_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py02_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py02_id, '100 -25', '75', 0, 4 WHERE @py02_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py02_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py03_id, '4 6', '24', 1, 1 WHERE @py03_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py03_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py03_id, '1 9', '9', 0, 2 WHERE @py03_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py03_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py03_id, '12 12', '144', 0, 3 WHERE @py03_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py03_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py03_id, '0 12', '0', 0, 4 WHERE @py03_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py03_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py04_id, '7', 'Odd', 1, 1 WHERE @py04_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py04_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py04_id, '8', 'Even', 0, 2 WHERE @py04_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py04_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py04_id, '0', 'Even', 0, 3 WHERE @py04_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py04_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py04_id, '-3', 'Odd', 0, 4 WHERE @py04_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py04_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py05_id, '5', '15', 1, 1 WHERE @py05_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py05_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py05_id, '1', '1', 0, 2 WHERE @py05_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py05_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py05_id, '10', '55', 0, 3 WHERE @py05_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py05_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py05_id, '100000', '5000050000', 0, 4 WHERE @py05_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py05_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py06_id, '12 25 8', '25', 1, 1 WHERE @py06_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py06_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py06_id, '-4 -2 -9', '-2', 0, 2 WHERE @py06_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py06_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py06_id, '7 7 2', '7', 0, 3 WHERE @py06_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py06_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py06_id, '0 0 0', '0', 0, 4 WHERE @py06_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py06_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py07_id, 'Programming', '3', 1, 1 WHERE @py07_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py07_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py07_id, 'sky', '0', 0, 2 WHERE @py07_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py07_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py07_id, 'EDUCATION', '5', 0, 3 WHERE @py07_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py07_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py07_id, 'CodeArena', '5', 0, 4 WHERE @py07_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py07_id AND sort_order=4);

INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py08_id, '5', '120', 1, 1 WHERE @py08_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py08_id AND sort_order=1);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py08_id, '0', '1', 0, 2 WHERE @py08_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py08_id AND sort_order=2);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py08_id, '1', '1', 0, 3 WHERE @py08_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py08_id AND sort_order=3);
INSERT INTO test_cases (exercise_id, stdin, expected_output, is_sample, sort_order)
SELECT @py08_id, '10', '3628800', 0, 4 WHERE @py08_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@py08_id AND sort_order=4);

-- Summary. If teacher_id is NULL, create a teacher account and re-import this file.
SELECT @teacher_id AS target_teacher_id, @python_path_id AS python_learning_path_id, (SELECT COUNT(*) FROM learning_path_items WHERE path_id=@python_path_id) AS path_steps;
SELECT e.id, e.title, e.difficulty, e.topic, e.points, ROUND(e.time_limit_seconds/60) AS time_limit_minutes FROM exercises e WHERE e.created_by=@teacher_id AND e.slug LIKE CONCAT('ca-python-path-%-t', @teacher_id) ORDER BY e.slug;
