-- CodeArena v21: 30-challenge learning paths for every student editor language.
-- Import after CodeArena schema and migrations 001-008 have been applied.
-- Default target is the newest teacher account. To choose another teacher, replace the SET with SET @teacher_id := 123;
-- Safe to re-import: existing exercise text and test cases are not overwritten; missing steps are added.
USE codearena;
SET @teacher_id := (SELECT id FROM users WHERE role='teacher' ORDER BY id DESC LIMIT 1);

-- Preserve and extend the original Python Foundations path from the 8-exercise seed.
UPDATE learning_paths SET description='Thirty Python challenges from print/input basics through arrays, strings, searching, stacks, and problem solving. Code exercises are runnable and sample-testable in Practice Mode.' WHERE teacher_id=@teacher_id AND title='Python Foundations: From First Program to Problem Solving';
INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'Python Foundations: From First Program to Problem Solving','Thirty Python challenges from print/input basics through arrays, strings, searching, stacks, and problem solving. Code exercises are runnable and sample-testable in Practice Mode.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='Python Foundations: From First Program to Problem Solving');
UPDATE learning_paths SET description='Thirty Python challenges from print/input basics through arrays, strings, searching, stacks, and problem solving. Code exercises are runnable and sample-testable in Practice Mode.' WHERE teacher_id=@teacher_id AND title='Python Foundations: From First Program to Problem Solving';
SET @path_python := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='Python Foundations: From First Program to Problem Solving' ORDER BY id DESC LIMIT 1);

INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'C Programming Foundations: 30 Challenges','Thirty C programming challenges, using standard input/output and progressing from fundamentals to arrays, strings, searching, and stacks.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='C Programming Foundations: 30 Challenges');
SET @path_c := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='C Programming Foundations: 30 Challenges' ORDER BY id DESC LIMIT 1);

INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'C++ Programming Foundations: 30 Challenges','Thirty C++ programming challenges, using standard input/output and progressing from fundamentals to arrays, strings, searching, and stacks.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='C++ Programming Foundations: 30 Challenges');
SET @path_cpp := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='C++ Programming Foundations: 30 Challenges' ORDER BY id DESC LIMIT 1);

INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'Java Programming Foundations: 30 Challenges','Thirty Java programming challenges, using standard input/output and progressing from fundamentals to arrays, strings, searching, and stacks.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='Java Programming Foundations: 30 Challenges');
SET @path_java := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='Java Programming Foundations: 30 Challenges' ORDER BY id DESC LIMIT 1);

INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'PHP Programming Foundations: 30 Challenges','Thirty PHP CLI programming challenges, using STDIN/STDOUT and progressing from fundamentals to arrays, strings, searching, and stacks.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='PHP Programming Foundations: 30 Challenges');
SET @path_php := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='PHP Programming Foundations: 30 Challenges' ORDER BY id DESC LIMIT 1);

INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'Ruby Programming Foundations: 30 Challenges','Thirty Ruby programming challenges, using standard input/output and progressing from fundamentals to arrays, strings, searching, and stacks.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='Ruby Programming Foundations: 30 Challenges');
SET @path_ruby := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='Ruby Programming Foundations: 30 Challenges' ORDER BY id DESC LIMIT 1);

INSERT INTO learning_paths(teacher_id,title,description,is_published) SELECT @teacher_id,'HTML & CSS Web Foundations: 30 Projects','Thirty preview-only web projects covering semantic HTML, forms, navigation, components, layout, responsive CSS, and a complete landing page. HTML/CSS projects use a sandboxed browser preview and require the student to mark the project complete after checking their work; they are not auto-graded.',1 WHERE @teacher_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM learning_paths WHERE teacher_id=@teacher_id AND title='HTML & CSS Web Foundations: 30 Projects');
SET @path_htmlcss := (SELECT id FROM learning_paths WHERE teacher_id=@teacher_id AND title='HTML & CSS Web Foundations: 30 Projects' ORDER BY id DESC LIMIT 1);

-- Python: 30 language-specific exercises and test cases.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 01 - Hello, CodeArena!',CONCAT('ca-python-path-01-hello-t', @teacher_id),'Print exactly the text Hello, CodeArena! followed by a newline.

Input: No input is provided.
Output: Hello, CodeArena!
Hint: Start by testing your language''s standard output statement.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Output',300,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-01-hello-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_01,1 WHERE @path_python IS NOT NULL AND @e_python_01 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_01,'','Hello, CodeArena!',1,1 WHERE @e_python_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_01 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_01,'','Hello, CodeArena!',0,2 WHERE @e_python_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_01 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_01,'','Hello, CodeArena!',0,3 WHERE @e_python_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_01 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_01,'','Hello, CodeArena!',0,4 WHERE @e_python_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_01 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 02 - Add Two Integers',CONCAT('ca-python-path-02-add-two-t', @teacher_id),'Read two integers and print their sum. The integers can be separated by spaces or newlines.

Input: Two integers a and b, each from -100000 to 100000.
Output: The value a + b.
Hint: Convert both inputs to integers before adding.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Input & Variables',480,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-02-add-two-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_02,2 WHERE @path_python IS NOT NULL AND @e_python_02 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_02,'3 5','8',1,1 WHERE @e_python_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_02 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_02,'-4 9','5',0,2 WHERE @e_python_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_02 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_02,'0 0','0',0,3 WHERE @e_python_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_02 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_02,'100 -25','75',0,4 WHERE @e_python_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_02 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 03 - Rectangle Area',CONCAT('ca-python-path-03-rectangle-area-t', @teacher_id),'Read the width and height of a rectangle and print its area.

Input: Two non-negative integers w and h, each at most 1000.
Output: w multiplied by h.
Hint: Area = width × height.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Arithmetic',480,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-03-rectangle-area-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_03,3 WHERE @path_python IS NOT NULL AND @e_python_03 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_03,'4 6','24',1,1 WHERE @e_python_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_03 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_03,'1 9','9',0,2 WHERE @e_python_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_03 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_03,'12 12','144',0,3 WHERE @e_python_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_03 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_03,'0 12','0',0,4 WHERE @e_python_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_03 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 04 - Even or Odd',CONCAT('ca-python-path-04-even-odd-t', @teacher_id),'Read an integer. Print Even if it is divisible by 2; otherwise print Odd. Handle negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Conditionals',480,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-04-even-odd-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_04,4 WHERE @path_python IS NOT NULL AND @e_python_04 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_04,'7','Odd',1,1 WHERE @e_python_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_04 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_04,'8','Even',0,2 WHERE @e_python_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_04 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_04,'0','Even',0,3 WHERE @e_python_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_04 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_04,'-3','Odd',0,4 WHERE @e_python_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_04 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 05 - Sum from 1 to N',CONCAT('ca-python-path-05-sum-to-n-t', @teacher_id),'Read a positive integer N and calculate 1 + 2 + ... + N.

Input: One integer N, where 1 ≤ N ≤ 100000.
Output: The sum as an integer.
Hint: Use a loop and a running total.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Loops',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-05-sum-to-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_05,5 WHERE @path_python IS NOT NULL AND @e_python_05 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_05,'5','15',1,1 WHERE @e_python_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_05 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_05,'1','1',0,2 WHERE @e_python_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_05 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_05,'10','55',0,3 WHERE @e_python_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_05 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_05,'100000','5000050000',0,4 WHERE @e_python_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_05 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 06 - Largest of Three',CONCAT('ca-python-path-06-largest-three-t', @teacher_id),'Read three integers and print the largest. If values are tied, print the tied value.

Input: Three integers separated by whitespace.
Output: The maximum value.
Hint: Compare all three values, including when they are equal or negative.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Conditionals',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-06-largest-three-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_06,6 WHERE @path_python IS NOT NULL AND @e_python_06 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_06,'12 25 8','25',1,1 WHERE @e_python_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_06 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_06,'-4 -2 -9','-2',0,2 WHERE @e_python_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_06 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_06,'7 7 2','7',0,3 WHERE @e_python_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_06 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_06,'0 0 0','0',0,4 WHERE @e_python_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_06 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 07 - Count the Vowels',CONCAT('ca-python-path-07-count-vowels-t', @teacher_id),'Read one word and count the vowels a, e, i, o, u. Count uppercase and lowercase vowels.

Input: One word containing English letters.
Output: One integer, the vowel count.
Hint: Check every character against the five vowels.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Strings',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-07-count-vowels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_07,7 WHERE @path_python IS NOT NULL AND @e_python_07 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_07,'Programming','3',1,1 WHERE @e_python_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_07 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_07,'sky','0',0,2 WHERE @e_python_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_07 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_07,'EDUCATION','5',0,3 WHERE @e_python_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_07 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_07,'CodeArena','5',0,4 WHERE @e_python_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_07 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 08 - Calculate Factorial',CONCAT('ca-python-path-08-factorial-t', @teacher_id),'Calculate N!, the product of all integers from 1 to N. By definition, 0! = 1.

Input: One integer N, where 0 ≤ N ≤ 12.
Output: N! as an integer.
Hint: Start the product at 1.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Loops',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-08-factorial-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_08,8 WHERE @path_python IS NOT NULL AND @e_python_08 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_08,'5','120',1,1 WHERE @e_python_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_08 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_08,'0','1',0,2 WHERE @e_python_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_08 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_08,'1','1',0,3 WHERE @e_python_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_08 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_08,'10','3628800',0,4 WHERE @e_python_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_08 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 09 - Reverse a Number',CONCAT('ca-python-path-09-reverse-number-t', @teacher_id),'Read a non-negative integer and print its digits in reverse order. Leading zeros in the reversed result are omitted.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: The reversed integer.
Hint: Use remainder by 10 and integer division by 10.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-09-reverse-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_09,9 WHERE @path_python IS NOT NULL AND @e_python_09 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_09,'12340','4321',1,1 WHERE @e_python_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_09 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_09,'7','7',0,2 WHERE @e_python_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_09 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_09,'1000','1',0,3 WHERE @e_python_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_09 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_09,'908','809',0,4 WHERE @e_python_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_09 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 10 - First Ten Multiples',CONCAT('ca-python-path-10-multiples-of-n-t', @teacher_id),'Read an integer N and print its first ten positive multiples on one line, separated by a single space.

Input: One integer N, where 1 ≤ N ≤ 1000.
Output: N, 2N, ..., 10N. Do not print extra labels.
Hint: Repeat a multiplication for i from 1 through 10.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Loops',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-10-multiples-of-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_10,10 WHERE @path_python IS NOT NULL AND @e_python_10 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_10,'3','3 6 9 12 15 18 21 24 27 30',1,1 WHERE @e_python_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_10 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_10,'1','1 2 3 4 5 6 7 8 9 10',0,2 WHERE @e_python_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_10 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_10,'5','5 10 15 20 25 30 35 40 45 50',0,3 WHERE @e_python_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_10 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_10,'10','10 20 30 40 50 60 70 80 90 100',0,4 WHERE @e_python_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_10 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 11 - Count Digits',CONCAT('ca-python-path-11-count-digits-t', @teacher_id),'Count how many decimal digits are in a non-negative integer. Zero has one digit.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Number of digits.
Hint: Repeatedly divide by 10 or convert to a string.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-11-count-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_11,11 WHERE @path_python IS NOT NULL AND @e_python_11 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_11,'0','1',1,1 WHERE @e_python_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_11 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_11,'9','1',0,2 WHERE @e_python_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_11 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_11,'12034','5',0,3 WHERE @e_python_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_11 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_11,'1000000000','10',0,4 WHERE @e_python_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_11 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 12 - Palindrome Number',CONCAT('ca-python-path-12-palindrome-number-t', @teacher_id),'Determine whether a non-negative integer reads the same forward and backward. Print Yes or No.

Input: One integer N.
Output: Yes if it is a palindrome; otherwise No.
Hint: Compare the number with its reversed digits.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-12-palindrome-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_12,12 WHERE @path_python IS NOT NULL AND @e_python_12 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_12,'121','Yes',1,1 WHERE @e_python_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_12 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_12,'123','No',0,2 WHERE @e_python_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_12 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_12,'7','Yes',0,3 WHERE @e_python_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_12 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_12,'100','No',0,4 WHERE @e_python_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_12 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 13 - Prime Number Check',CONCAT('ca-python-path-13-prime-check-t', @teacher_id),'Check whether N is a prime number. A prime is an integer greater than 1 with exactly two positive divisors.

Input: One integer N, where 0 ≤ N ≤ 1000000.
Output: Prime or Not Prime.
Hint: Check possible divisors only up to the square root of N.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Number Theory',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-13-prime-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_13,13 WHERE @path_python IS NOT NULL AND @e_python_13 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_13,'17','Prime',1,1 WHERE @e_python_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_13 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_13,'1','Not Prime',0,2 WHERE @e_python_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_13 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_13,'2','Prime',0,3 WHERE @e_python_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_13 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_13,'100','Not Prime',0,4 WHERE @e_python_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_13 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 14 - Sum of Digits',CONCAT('ca-python-path-14-sum-digits-t', @teacher_id),'Read a non-negative integer and print the sum of its digits.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Sum of all decimal digits.
Hint: Extract each last digit with remainder by 10.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-14-sum-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_14,14 WHERE @path_python IS NOT NULL AND @e_python_14 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_14,'1234','10',1,1 WHERE @e_python_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_14 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_14,'0','0',0,2 WHERE @e_python_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_14 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_14,'999','27',0,3 WHERE @e_python_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_14 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_14,'10005','6',0,4 WHERE @e_python_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_14 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 15 - Nth Fibonacci Number',CONCAT('ca-python-path-15-fibonacci-nth-t', @teacher_id),'Use the sequence F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2). Print F(N).

Input: One integer N, where 0 ≤ N ≤ 45.
Output: F(N).
Hint: Build the sequence iteratively instead of using slow recursion.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Sequences',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-15-fibonacci-nth-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_15,15 WHERE @path_python IS NOT NULL AND @e_python_15 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_15,'0','0',1,1 WHERE @e_python_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_15 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_15,'1','1',0,2 WHERE @e_python_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_15 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_15,'10','55',0,3 WHERE @e_python_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_15 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_15,'45','1134903170',0,4 WHERE @e_python_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_15 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 16 - Greatest Common Divisor',CONCAT('ca-python-path-16-greatest-common-divisor-t', @teacher_id),'Read two positive integers and print their greatest common divisor (GCD).

Input: Positive integers a and b, each at most 1000000000.
Output: gcd(a, b).
Hint: Use the Euclidean algorithm.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Number Theory',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-16-greatest-common-divisor-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_16,16 WHERE @path_python IS NOT NULL AND @e_python_16 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_16,'12 18','6',1,1 WHERE @e_python_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_16 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_16,'7 13','1',0,2 WHERE @e_python_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_16 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_16,'100 80','20',0,3 WHERE @e_python_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_16 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_16,'1 1','1',0,4 WHERE @e_python_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_16 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 17 - Least Common Multiple',CONCAT('ca-python-path-17-least-common-multiple-t', @teacher_id),'Read two positive integers and print their least common multiple (LCM).

Input: Positive integers a and b, each at most 100000.
Output: lcm(a, b).
Hint: lcm(a,b) = a / gcd(a,b) × b.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Number Theory',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-17-least-common-multiple-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_17,17 WHERE @path_python IS NOT NULL AND @e_python_17 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_17,'4 6','12',1,1 WHERE @e_python_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_17 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_17,'7 5','35',0,2 WHERE @e_python_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_17 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_17,'12 18','36',0,3 WHERE @e_python_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_17 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_17,'1 999','999',0,4 WHERE @e_python_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_17 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 18 - Reverse a Word',CONCAT('ca-python-path-18-reverse-word-t', @teacher_id),'Read one word and print its characters in reverse order. Preserve each character''s case.

Input: One word of English letters.
Output: The reversed word.
Hint: Walk from the final character to the first.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Strings',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-18-reverse-word-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_18,18 WHERE @path_python IS NOT NULL AND @e_python_18 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_18,'CodeArena','anerAedoC',1,1 WHERE @e_python_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_18 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_18,'hello','olleh',0,2 WHERE @e_python_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_18 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_18,'a','a',0,3 WHERE @e_python_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_18 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_18,'Ruby','ybuR',0,4 WHERE @e_python_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_18 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 19 - Count Words in a Sentence',CONCAT('ca-python-path-19-count-words-t', @teacher_id),'Read one complete line and count its whitespace-separated words. Repeated spaces should not create empty words.

Input: One non-empty line.
Output: Number of words.
Hint: Trim the line and split on one or more whitespace characters.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Strings',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-19-count-words-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_19,19 WHERE @path_python IS NOT NULL AND @e_python_19 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_19,'Code Arena is fun','4',1,1 WHERE @e_python_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_19 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_19,'one','1',0,2 WHERE @e_python_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_19 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_19,'  many   spaces here  ','3',0,3 WHERE @e_python_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_19 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_19,'Learn to code every day','5',0,4 WHERE @e_python_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_19 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 20 - Maximum in an Array',CONCAT('ca-python-path-20-array-maximum-t', @teacher_id),'Read N integers and print the maximum value.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: The maximum integer.
Hint: Initialize the maximum from the first value.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Arrays',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-20-array-maximum-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_20,20 WHERE @path_python IS NOT NULL AND @e_python_20 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_20,'5 3 9 1 9 4','9',1,1 WHERE @e_python_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_20 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_20,'4 -8 -3 -10 -5','-3',0,2 WHERE @e_python_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_20 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_20,'1 42','42',0,3 WHERE @e_python_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_20 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_20,'3 0 0 -1','0',0,4 WHERE @e_python_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_20 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 21 - Count Positive Numbers',CONCAT('ca-python-path-21-count-positive-t', @teacher_id),'Count how many values in a list are strictly greater than zero. Zero is not positive.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Count of positive values.
Hint: Increase the counter only when value > 0.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Arrays',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-21-count-positive-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_21,21 WHERE @path_python IS NOT NULL AND @e_python_21 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_21,'5 -3 2 0 7 -1','2',1,1 WHERE @e_python_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_21 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_21,'4 1 2 3 4','4',0,2 WHERE @e_python_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_21 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_21,'3 -1 0 -9','0',0,3 WHERE @e_python_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_21 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_21,'1 100','1',0,4 WHERE @e_python_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_21 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 22 - Second Largest Distinct Number',CONCAT('ca-python-path-22-second-largest-distinct-t', @teacher_id),'Find the second-largest distinct value in a list. Inputs are guaranteed to contain at least two distinct values.

Input: N followed by N integers, where 2 ≤ N ≤ 1000.
Output: The second-largest distinct number.
Hint: Track the largest and second-largest distinct values.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Arrays',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-22-second-largest-distinct-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_22,22 WHERE @path_python IS NOT NULL AND @e_python_22 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_22,'6 4 1 9 7 9 3','7',1,1 WHERE @e_python_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_22 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_22,'3 1 2 3','2',0,2 WHERE @e_python_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_22 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_22,'5 -5 -1 -1 -3 -2','-2',0,3 WHERE @e_python_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_22 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_22,'4 10 10 9 8','9',0,4 WHERE @e_python_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_22 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 23 - Linear Search',CONCAT('ca-python-path-23-linear-search-t', @teacher_id),'Find the first zero-based index of target in an integer array. Print -1 when it is absent.

Input: N, then N integers, then target.
Output: First matching index, or -1.
Hint: Scan the list from left to right.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Easy','Searching',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-23-linear-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_23,23 WHERE @path_python IS NOT NULL AND @e_python_23 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_23,'5 3 9 1 8 4 9','1',1,1 WHERE @e_python_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_23 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_23,'3 1 2 3 4','-1',0,2 WHERE @e_python_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_23 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_23,'4 7 7 7 7 7','0',0,3 WHERE @e_python_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_23 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_23,'1 5 5','0',0,4 WHERE @e_python_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_23 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 24 - Binary Search',CONCAT('ca-python-path-24-binary-search-t', @teacher_id),'Search a sorted ascending array and print the first zero-based index of target, or -1 if absent. If duplicates exist, return the first index.

Input: N, then N sorted integers, then target.
Output: First matching index, or -1.
Hint: Use left and right boundaries; continue left after a match.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Searching',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-24-binary-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_24,24 WHERE @path_python IS NOT NULL AND @e_python_24 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_24,'6 1 2 4 4 7 9 4','2',1,1 WHERE @e_python_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_24 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_24,'5 1 3 5 7 9 6','-1',0,2 WHERE @e_python_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_24 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_24,'4 2 2 2 2 2','0',0,3 WHERE @e_python_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_24 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_24,'1 9 9','0',0,4 WHERE @e_python_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_24 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 25 - Sort Numbers Ascending',CONCAT('ca-python-path-25-sort-ascending-t', @teacher_id),'Sort N integers in ascending order and print them on one line separated by a single space.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Sorted integers.
Hint: Use a built-in sort or implement a sorting algorithm.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Sorting',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-25-sort-ascending-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_25,25 WHERE @path_python IS NOT NULL AND @e_python_25 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_25,'5 3 1 4 1 2','1 1 2 3 4',1,1 WHERE @e_python_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_25 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_25,'3 9 -1 0','-1 0 9',0,2 WHERE @e_python_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_25 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_25,'1 7','7',0,3 WHERE @e_python_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_25 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_25,'4 5 5 5 5','5 5 5 5',0,4 WHERE @e_python_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_25 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 26 - Remove Duplicates, Keep Order',CONCAT('ca-python-path-26-remove-duplicates-t', @teacher_id),'Remove repeated values while preserving the first occurrence of each value. Print the remaining values separated by one space.

Input: N followed by N integers.
Output: Unique values in original order.
Hint: Keep a set of values already seen and a separate output list.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Arrays',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-26-remove-duplicates-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_26,26 WHERE @path_python IS NOT NULL AND @e_python_26 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_26,'7 3 3 1 2 1 4 2','3 1 2 4',1,1 WHERE @e_python_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_26 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_26,'4 5 5 5 5','5',0,2 WHERE @e_python_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_26 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_26,'5 1 2 3 4 5','1 2 3 4 5',0,3 WHERE @e_python_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_26 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_26,'6 0 -1 0 -1 2 2','0 -1 2',0,4 WHERE @e_python_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_26 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 27 - Character Frequency',CONCAT('ca-python-path-27-character-frequency-t', @teacher_id),'Read a word and a single character, then count exact case-sensitive occurrences of that character in the word.

Input: A word and a character separated by whitespace.
Output: Number of occurrences.
Hint: Compare each character of the word with the target character.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Strings',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-27-character-frequency-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_27,27 WHERE @path_python IS NOT NULL AND @e_python_27 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_27,'banana a','3',1,1 WHERE @e_python_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_27 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_27,'CodeArena a','1',0,2 WHERE @e_python_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_27 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_27,'hello z','0',0,3 WHERE @e_python_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_27 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_27,'AAAA A','4',0,4 WHERE @e_python_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_27 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 28 - Anagram Check',CONCAT('ca-python-path-28-anagram-check-t', @teacher_id),'Determine whether two lowercase words contain exactly the same letters with the same frequencies. Print Yes or No.

Input: Two lowercase words.
Output: Yes if they are anagrams; otherwise No.
Hint: Compare sorted letters or letter-frequency counts.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Strings',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-28-anagram-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_28,28 WHERE @path_python IS NOT NULL AND @e_python_28 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_28,'listen silent','Yes',1,1 WHERE @e_python_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_28 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_28,'apple paple','Yes',0,2 WHERE @e_python_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_28 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_28,'hello world','No',0,3 WHERE @e_python_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_28 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_28,'ab ba','Yes',0,4 WHERE @e_python_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_28 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 29 - Balanced Brackets',CONCAT('ca-python-path-29-balanced-brackets-t', @teacher_id),'Check whether a string containing only (), [], and {} has correctly matched and nested brackets. Print Yes or No.

Input: A non-empty string of bracket characters.
Output: Yes if balanced; otherwise No.
Hint: Use a stack to remember opening brackets.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Stacks',1200,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-29-balanced-brackets-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_29,29 WHERE @path_python IS NOT NULL AND @e_python_29 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_29,'([]{})','Yes',1,1 WHERE @e_python_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_29 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_29,'([)]','No',0,2 WHERE @e_python_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_29 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_29,'((()))','Yes',0,3 WHERE @e_python_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_29 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_29,'}{','No',0,4 WHERE @e_python_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_29 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Python 30 - FizzBuzz',CONCAT('ca-python-path-30-fizzbuzz-t', @teacher_id),'For every integer from 1 through N, print FizzBuzz if divisible by both 3 and 5, Fizz if divisible by 3, Buzz if divisible by 5, otherwise print the number. Print one result per line.

Input: One integer N, where 1 ≤ N ≤ 100.
Output: N lines.
Hint: Check divisibility by 15 before 3 or 5.

Learning path: Python Foundations. Write your solution using Python. Read standard input and print only the required output.','Medium','Problem Solving',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_python_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-python-path-30-fizzbuzz-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_python,@e_python_30,30 WHERE @path_python IS NOT NULL AND @e_python_30 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_30,'5','1
2
Fizz
4
Buzz',1,1 WHERE @e_python_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_30 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_30,'1','1',0,2 WHERE @e_python_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_30 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_30,'15','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz',0,3 WHERE @e_python_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_30 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_python_30,'16','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16',0,4 WHERE @e_python_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_python_30 AND sort_order=4);

-- C: 30 language-specific exercises and test cases.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 01 - Hello, CodeArena!',CONCAT('ca-c-path-01-hello-codearena-t', @teacher_id),'Print exactly the text Hello, CodeArena! followed by a newline.

Input: No input is provided.
Output: Hello, CodeArena!
Hint: Start by testing your language''s standard output statement.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Output',300,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-01-hello-codearena-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_01,1 WHERE @path_c IS NOT NULL AND @e_c_01 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_01,'','Hello, CodeArena!',1,1 WHERE @e_c_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_01 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_01,'','Hello, CodeArena!',0,2 WHERE @e_c_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_01 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_01,'','Hello, CodeArena!',0,3 WHERE @e_c_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_01 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_01,'','Hello, CodeArena!',0,4 WHERE @e_c_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_01 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 02 - Add Two Integers',CONCAT('ca-c-path-02-add-two-integers-t', @teacher_id),'Read two integers and print their sum. The integers can be separated by spaces or newlines.

Input: Two integers a and b, each from -100000 to 100000.
Output: The value a + b.
Hint: Convert both inputs to integers before adding.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Input & Variables',480,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-02-add-two-integers-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_02,2 WHERE @path_c IS NOT NULL AND @e_c_02 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_02,'3 5','8',1,1 WHERE @e_c_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_02 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_02,'-4 9','5',0,2 WHERE @e_c_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_02 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_02,'0 0','0',0,3 WHERE @e_c_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_02 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_02,'100 -25','75',0,4 WHERE @e_c_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_02 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 03 - Rectangle Area',CONCAT('ca-c-path-03-rectangle-area-t', @teacher_id),'Read the width and height of a rectangle and print its area.

Input: Two non-negative integers w and h, each at most 1000.
Output: w multiplied by h.
Hint: Area = width × height.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Arithmetic',480,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-03-rectangle-area-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_03,3 WHERE @path_c IS NOT NULL AND @e_c_03 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_03,'4 6','24',1,1 WHERE @e_c_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_03 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_03,'1 9','9',0,2 WHERE @e_c_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_03 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_03,'12 12','144',0,3 WHERE @e_c_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_03 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_03,'0 12','0',0,4 WHERE @e_c_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_03 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 04 - Even or Odd',CONCAT('ca-c-path-04-even-or-odd-t', @teacher_id),'Read an integer. Print Even if it is divisible by 2; otherwise print Odd. Handle negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Conditionals',480,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-04-even-or-odd-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_04,4 WHERE @path_c IS NOT NULL AND @e_c_04 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_04,'7','Odd',1,1 WHERE @e_c_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_04 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_04,'8','Even',0,2 WHERE @e_c_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_04 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_04,'0','Even',0,3 WHERE @e_c_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_04 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_04,'-3','Odd',0,4 WHERE @e_c_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_04 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 05 - Sum from 1 to N',CONCAT('ca-c-path-05-sum-one-to-n-t', @teacher_id),'Read a positive integer N and calculate 1 + 2 + ... + N.

Input: One integer N, where 1 ≤ N ≤ 100000.
Output: The sum as an integer.
Hint: Use a loop and a running total.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Loops',600,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-05-sum-one-to-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_05,5 WHERE @path_c IS NOT NULL AND @e_c_05 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_05,'5','15',1,1 WHERE @e_c_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_05 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_05,'1','1',0,2 WHERE @e_c_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_05 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_05,'10','55',0,3 WHERE @e_c_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_05 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_05,'100000','5000050000',0,4 WHERE @e_c_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_05 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 06 - Largest of Three',CONCAT('ca-c-path-06-largest-of-three-t', @teacher_id),'Read three integers and print the largest. If values are tied, print the tied value.

Input: Three integers separated by whitespace.
Output: The maximum value.
Hint: Compare all three values, including when they are equal or negative.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Conditionals',600,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-06-largest-of-three-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_06,6 WHERE @path_c IS NOT NULL AND @e_c_06 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_06,'12 25 8','25',1,1 WHERE @e_c_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_06 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_06,'-4 -2 -9','-2',0,2 WHERE @e_c_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_06 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_06,'7 7 2','7',0,3 WHERE @e_c_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_06 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_06,'0 0 0','0',0,4 WHERE @e_c_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_06 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 07 - Count the Vowels',CONCAT('ca-c-path-07-count-vowels-t', @teacher_id),'Read one word and count the vowels a, e, i, o, u. Count uppercase and lowercase vowels.

Input: One word containing English letters.
Output: One integer, the vowel count.
Hint: Check every character against the five vowels.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Strings',600,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-07-count-vowels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_07,7 WHERE @path_c IS NOT NULL AND @e_c_07 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_07,'Programming','3',1,1 WHERE @e_c_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_07 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_07,'sky','0',0,2 WHERE @e_c_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_07 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_07,'EDUCATION','5',0,3 WHERE @e_c_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_07 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_07,'CodeArena','5',0,4 WHERE @e_c_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_07 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 08 - Calculate Factorial',CONCAT('ca-c-path-08-factorial-t', @teacher_id),'Calculate N!, the product of all integers from 1 to N. By definition, 0! = 1.

Input: One integer N, where 0 ≤ N ≤ 12.
Output: N! as an integer.
Hint: Start the product at 1.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Loops',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-08-factorial-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_08,8 WHERE @path_c IS NOT NULL AND @e_c_08 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_08,'5','120',1,1 WHERE @e_c_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_08 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_08,'0','1',0,2 WHERE @e_c_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_08 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_08,'1','1',0,3 WHERE @e_c_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_08 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_08,'10','3628800',0,4 WHERE @e_c_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_08 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 09 - Reverse a Number',CONCAT('ca-c-path-09-reverse-number-t', @teacher_id),'Read a non-negative integer and print its digits in reverse order. Leading zeros in the reversed result are omitted.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: The reversed integer.
Hint: Use remainder by 10 and integer division by 10.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-09-reverse-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_09,9 WHERE @path_c IS NOT NULL AND @e_c_09 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_09,'12340','4321',1,1 WHERE @e_c_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_09 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_09,'7','7',0,2 WHERE @e_c_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_09 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_09,'1000','1',0,3 WHERE @e_c_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_09 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_09,'908','809',0,4 WHERE @e_c_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_09 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 10 - First Ten Multiples',CONCAT('ca-c-path-10-multiples-of-n-t', @teacher_id),'Read an integer N and print its first ten positive multiples on one line, separated by a single space.

Input: One integer N, where 1 ≤ N ≤ 1000.
Output: N, 2N, ..., 10N. Do not print extra labels.
Hint: Repeat a multiplication for i from 1 through 10.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Loops',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-10-multiples-of-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_10,10 WHERE @path_c IS NOT NULL AND @e_c_10 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_10,'3','3 6 9 12 15 18 21 24 27 30',1,1 WHERE @e_c_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_10 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_10,'1','1 2 3 4 5 6 7 8 9 10',0,2 WHERE @e_c_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_10 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_10,'5','5 10 15 20 25 30 35 40 45 50',0,3 WHERE @e_c_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_10 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_10,'10','10 20 30 40 50 60 70 80 90 100',0,4 WHERE @e_c_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_10 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 11 - Count Digits',CONCAT('ca-c-path-11-count-digits-t', @teacher_id),'Count how many decimal digits are in a non-negative integer. Zero has one digit.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Number of digits.
Hint: Repeatedly divide by 10 or convert to a string.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-11-count-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_11,11 WHERE @path_c IS NOT NULL AND @e_c_11 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_11,'0','1',1,1 WHERE @e_c_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_11 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_11,'9','1',0,2 WHERE @e_c_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_11 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_11,'12034','5',0,3 WHERE @e_c_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_11 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_11,'1000000000','10',0,4 WHERE @e_c_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_11 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 12 - Palindrome Number',CONCAT('ca-c-path-12-palindrome-number-t', @teacher_id),'Determine whether a non-negative integer reads the same forward and backward. Print Yes or No.

Input: One integer N.
Output: Yes if it is a palindrome; otherwise No.
Hint: Compare the number with its reversed digits.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-12-palindrome-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_12,12 WHERE @path_c IS NOT NULL AND @e_c_12 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_12,'121','Yes',1,1 WHERE @e_c_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_12 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_12,'123','No',0,2 WHERE @e_c_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_12 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_12,'7','Yes',0,3 WHERE @e_c_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_12 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_12,'100','No',0,4 WHERE @e_c_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_12 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 13 - Prime Number Check',CONCAT('ca-c-path-13-prime-check-t', @teacher_id),'Check whether N is a prime number. A prime is an integer greater than 1 with exactly two positive divisors.

Input: One integer N, where 0 ≤ N ≤ 1000000.
Output: Prime or Not Prime.
Hint: Check possible divisors only up to the square root of N.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Number Theory',900,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-13-prime-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_13,13 WHERE @path_c IS NOT NULL AND @e_c_13 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_13,'17','Prime',1,1 WHERE @e_c_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_13 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_13,'1','Not Prime',0,2 WHERE @e_c_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_13 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_13,'2','Prime',0,3 WHERE @e_c_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_13 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_13,'100','Not Prime',0,4 WHERE @e_c_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_13 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 14 - Sum of Digits',CONCAT('ca-c-path-14-sum-digits-t', @teacher_id),'Read a non-negative integer and print the sum of its digits.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Sum of all decimal digits.
Hint: Extract each last digit with remainder by 10.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-14-sum-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_14,14 WHERE @path_c IS NOT NULL AND @e_c_14 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_14,'1234','10',1,1 WHERE @e_c_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_14 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_14,'0','0',0,2 WHERE @e_c_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_14 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_14,'999','27',0,3 WHERE @e_c_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_14 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_14,'10005','6',0,4 WHERE @e_c_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_14 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 15 - Nth Fibonacci Number',CONCAT('ca-c-path-15-fibonacci-nth-t', @teacher_id),'Use the sequence F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2). Print F(N).

Input: One integer N, where 0 ≤ N ≤ 45.
Output: F(N).
Hint: Build the sequence iteratively instead of using slow recursion.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Sequences',900,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-15-fibonacci-nth-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_15,15 WHERE @path_c IS NOT NULL AND @e_c_15 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_15,'0','0',1,1 WHERE @e_c_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_15 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_15,'1','1',0,2 WHERE @e_c_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_15 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_15,'10','55',0,3 WHERE @e_c_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_15 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_15,'45','1134903170',0,4 WHERE @e_c_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_15 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 16 - Greatest Common Divisor',CONCAT('ca-c-path-16-greatest-common-divisor-t', @teacher_id),'Read two positive integers and print their greatest common divisor (GCD).

Input: Positive integers a and b, each at most 1000000000.
Output: gcd(a, b).
Hint: Use the Euclidean algorithm.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Number Theory',900,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-16-greatest-common-divisor-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_16,16 WHERE @path_c IS NOT NULL AND @e_c_16 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_16,'12 18','6',1,1 WHERE @e_c_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_16 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_16,'7 13','1',0,2 WHERE @e_c_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_16 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_16,'100 80','20',0,3 WHERE @e_c_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_16 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_16,'1 1','1',0,4 WHERE @e_c_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_16 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 17 - Least Common Multiple',CONCAT('ca-c-path-17-least-common-multiple-t', @teacher_id),'Read two positive integers and print their least common multiple (LCM).

Input: Positive integers a and b, each at most 100000.
Output: lcm(a, b).
Hint: lcm(a,b) = a / gcd(a,b) × b.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Number Theory',900,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-17-least-common-multiple-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_17,17 WHERE @path_c IS NOT NULL AND @e_c_17 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_17,'4 6','12',1,1 WHERE @e_c_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_17 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_17,'7 5','35',0,2 WHERE @e_c_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_17 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_17,'12 18','36',0,3 WHERE @e_c_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_17 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_17,'1 999','999',0,4 WHERE @e_c_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_17 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 18 - Reverse a Word',CONCAT('ca-c-path-18-reverse-word-t', @teacher_id),'Read one word and print its characters in reverse order. Preserve each character''s case.

Input: One word of English letters.
Output: The reversed word.
Hint: Walk from the final character to the first.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Strings',600,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-18-reverse-word-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_18,18 WHERE @path_c IS NOT NULL AND @e_c_18 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_18,'CodeArena','anerAedoC',1,1 WHERE @e_c_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_18 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_18,'hello','olleh',0,2 WHERE @e_c_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_18 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_18,'a','a',0,3 WHERE @e_c_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_18 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_18,'Ruby','ybuR',0,4 WHERE @e_c_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_18 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 19 - Count Words in a Sentence',CONCAT('ca-c-path-19-count-words-t', @teacher_id),'Read one complete line and count its whitespace-separated words. Repeated spaces should not create empty words.

Input: One non-empty line.
Output: Number of words.
Hint: Trim the line and split on one or more whitespace characters.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Strings',900,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-19-count-words-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_19,19 WHERE @path_c IS NOT NULL AND @e_c_19 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_19,'Code Arena is fun','4',1,1 WHERE @e_c_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_19 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_19,'one','1',0,2 WHERE @e_c_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_19 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_19,'  many   spaces here  ','3',0,3 WHERE @e_c_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_19 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_19,'Learn to code every day','5',0,4 WHERE @e_c_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_19 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 20 - Maximum in an Array',CONCAT('ca-c-path-20-array-maximum-t', @teacher_id),'Read N integers and print the maximum value.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: The maximum integer.
Hint: Initialize the maximum from the first value.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Arrays',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-20-array-maximum-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_20,20 WHERE @path_c IS NOT NULL AND @e_c_20 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_20,'5 3 9 1 9 4','9',1,1 WHERE @e_c_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_20 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_20,'4 -8 -3 -10 -5','-3',0,2 WHERE @e_c_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_20 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_20,'1 42','42',0,3 WHERE @e_c_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_20 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_20,'3 0 0 -1','0',0,4 WHERE @e_c_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_20 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 21 - Count Positive Numbers',CONCAT('ca-c-path-21-count-positive-t', @teacher_id),'Count how many values in a list are strictly greater than zero. Zero is not positive.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Count of positive values.
Hint: Increase the counter only when value > 0.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Arrays',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-21-count-positive-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_21,21 WHERE @path_c IS NOT NULL AND @e_c_21 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_21,'5 -3 2 0 7 -1','2',1,1 WHERE @e_c_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_21 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_21,'4 1 2 3 4','4',0,2 WHERE @e_c_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_21 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_21,'3 -1 0 -9','0',0,3 WHERE @e_c_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_21 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_21,'1 100','1',0,4 WHERE @e_c_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_21 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 22 - Second Largest Distinct Number',CONCAT('ca-c-path-22-second-largest-distinct-t', @teacher_id),'Find the second-largest distinct value in a list. Inputs are guaranteed to contain at least two distinct values.

Input: N followed by N integers, where 2 ≤ N ≤ 1000.
Output: The second-largest distinct number.
Hint: Track the largest and second-largest distinct values.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Arrays',1080,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-22-second-largest-distinct-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_22,22 WHERE @path_c IS NOT NULL AND @e_c_22 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_22,'6 4 1 9 7 9 3','7',1,1 WHERE @e_c_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_22 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_22,'3 1 2 3','2',0,2 WHERE @e_c_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_22 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_22,'5 -5 -1 -1 -3 -2','-2',0,3 WHERE @e_c_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_22 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_22,'4 10 10 9 8','9',0,4 WHERE @e_c_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_22 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 23 - Linear Search',CONCAT('ca-c-path-23-linear-search-t', @teacher_id),'Find the first zero-based index of target in an integer array. Print -1 when it is absent.

Input: N, then N integers, then target.
Output: First matching index, or -1.
Hint: Scan the list from left to right.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Easy','Searching',720,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-23-linear-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_23,23 WHERE @path_c IS NOT NULL AND @e_c_23 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_23,'5 3 9 1 8 4 9','1',1,1 WHERE @e_c_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_23 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_23,'3 1 2 3 4','-1',0,2 WHERE @e_c_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_23 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_23,'4 7 7 7 7 7','0',0,3 WHERE @e_c_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_23 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_23,'1 5 5','0',0,4 WHERE @e_c_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_23 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 24 - Binary Search',CONCAT('ca-c-path-24-binary-search-t', @teacher_id),'Search a sorted ascending array and print the first zero-based index of target, or -1 if absent. If duplicates exist, return the first index.

Input: N, then N sorted integers, then target.
Output: First matching index, or -1.
Hint: Use left and right boundaries; continue left after a match.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Searching',1080,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-24-binary-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_24,24 WHERE @path_c IS NOT NULL AND @e_c_24 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_24,'6 1 2 4 4 7 9 4','2',1,1 WHERE @e_c_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_24 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_24,'5 1 3 5 7 9 6','-1',0,2 WHERE @e_c_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_24 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_24,'4 2 2 2 2 2','0',0,3 WHERE @e_c_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_24 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_24,'1 9 9','0',0,4 WHERE @e_c_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_24 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 25 - Sort Numbers Ascending',CONCAT('ca-c-path-25-sort-ascending-t', @teacher_id),'Sort N integers in ascending order and print them on one line separated by a single space.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Sorted integers.
Hint: Use a built-in sort or implement a sorting algorithm.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Sorting',1080,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-25-sort-ascending-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_25,25 WHERE @path_c IS NOT NULL AND @e_c_25 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_25,'5 3 1 4 1 2','1 1 2 3 4',1,1 WHERE @e_c_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_25 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_25,'3 9 -1 0','-1 0 9',0,2 WHERE @e_c_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_25 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_25,'1 7','7',0,3 WHERE @e_c_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_25 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_25,'4 5 5 5 5','5 5 5 5',0,4 WHERE @e_c_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_25 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 26 - Remove Duplicates, Keep Order',CONCAT('ca-c-path-26-remove-duplicates-t', @teacher_id),'Remove repeated values while preserving the first occurrence of each value. Print the remaining values separated by one space.

Input: N followed by N integers.
Output: Unique values in original order.
Hint: Keep a set of values already seen and a separate output list.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Arrays',1080,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-26-remove-duplicates-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_26,26 WHERE @path_c IS NOT NULL AND @e_c_26 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_26,'7 3 3 1 2 1 4 2','3 1 2 4',1,1 WHERE @e_c_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_26 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_26,'4 5 5 5 5','5',0,2 WHERE @e_c_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_26 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_26,'5 1 2 3 4 5','1 2 3 4 5',0,3 WHERE @e_c_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_26 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_26,'6 0 -1 0 -1 2 2','0 -1 2',0,4 WHERE @e_c_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_26 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 27 - Character Frequency',CONCAT('ca-c-path-27-character-frequency-t', @teacher_id),'Read a word and a single character, then count exact case-sensitive occurrences of that character in the word.

Input: A word and a character separated by whitespace.
Output: Number of occurrences.
Hint: Compare each character of the word with the target character.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Strings',900,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-27-character-frequency-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_27,27 WHERE @path_c IS NOT NULL AND @e_c_27 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_27,'banana a','3',1,1 WHERE @e_c_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_27 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_27,'CodeArena a','1',0,2 WHERE @e_c_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_27 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_27,'hello z','0',0,3 WHERE @e_c_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_27 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_27,'AAAA A','4',0,4 WHERE @e_c_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_27 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 28 - Anagram Check',CONCAT('ca-c-path-28-anagram-check-t', @teacher_id),'Determine whether two lowercase words contain exactly the same letters with the same frequencies. Print Yes or No.

Input: Two lowercase words.
Output: Yes if they are anagrams; otherwise No.
Hint: Compare sorted letters or letter-frequency counts.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Strings',1080,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-28-anagram-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_28,28 WHERE @path_c IS NOT NULL AND @e_c_28 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_28,'listen silent','Yes',1,1 WHERE @e_c_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_28 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_28,'apple paple','Yes',0,2 WHERE @e_c_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_28 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_28,'hello world','No',0,3 WHERE @e_c_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_28 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_28,'ab ba','Yes',0,4 WHERE @e_c_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_28 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 29 - Balanced Brackets',CONCAT('ca-c-path-29-balanced-brackets-t', @teacher_id),'Check whether a string containing only (), [], and {} has correctly matched and nested brackets. Print Yes or No.

Input: A non-empty string of bracket characters.
Output: Yes if balanced; otherwise No.
Hint: Use a stack to remember opening brackets.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Stacks',1200,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-29-balanced-brackets-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_29,29 WHERE @path_c IS NOT NULL AND @e_c_29 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_29,'([]{})','Yes',1,1 WHERE @e_c_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_29 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_29,'([)]','No',0,2 WHERE @e_c_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_29 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_29,'((()))','Yes',0,3 WHERE @e_c_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_29 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_29,'}{','No',0,4 WHERE @e_c_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_29 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C 30 - FizzBuzz',CONCAT('ca-c-path-30-fizzbuzz-t', @teacher_id),'For every integer from 1 through N, print FizzBuzz if divisible by both 3 and 5, Fizz if divisible by 3, Buzz if divisible by 5, otherwise print the number. Print one result per line.

Input: One integer N, where 1 ≤ N ≤ 100.
Output: N lines.
Hint: Check divisibility by 15 before 3 or 5.

Learning path: C Foundations. Write your solution using C. Read standard input and print only the required output.','Medium','Problem Solving',1080,100,'#include <stdio.h>

int main(void) {
    /* TODO: solve the problem. Read from stdin and print only the required output. */
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_c_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-c-path-30-fizzbuzz-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_c,@e_c_30,30 WHERE @path_c IS NOT NULL AND @e_c_30 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_30,'5','1
2
Fizz
4
Buzz',1,1 WHERE @e_c_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_30 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_30,'1','1',0,2 WHERE @e_c_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_30 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_30,'15','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz',0,3 WHERE @e_c_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_30 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_c_30,'16','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16',0,4 WHERE @e_c_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_c_30 AND sort_order=4);

-- C++: 30 language-specific exercises and test cases.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 01 - Hello, CodeArena!',CONCAT('ca-cpp-path-01-hello-codearena-t', @teacher_id),'Print exactly the text Hello, CodeArena! followed by a newline.

Input: No input is provided.
Output: Hello, CodeArena!
Hint: Start by testing your language''s standard output statement.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Output',300,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-01-hello-codearena-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_01,1 WHERE @path_cpp IS NOT NULL AND @e_cpp_01 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_01,'','Hello, CodeArena!',1,1 WHERE @e_cpp_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_01 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_01,'','Hello, CodeArena!',0,2 WHERE @e_cpp_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_01 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_01,'','Hello, CodeArena!',0,3 WHERE @e_cpp_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_01 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_01,'','Hello, CodeArena!',0,4 WHERE @e_cpp_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_01 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 02 - Add Two Integers',CONCAT('ca-cpp-path-02-add-two-integers-t', @teacher_id),'Read two integers and print their sum. The integers can be separated by spaces or newlines.

Input: Two integers a and b, each from -100000 to 100000.
Output: The value a + b.
Hint: Convert both inputs to integers before adding.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Input & Variables',480,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-02-add-two-integers-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_02,2 WHERE @path_cpp IS NOT NULL AND @e_cpp_02 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_02,'3 5','8',1,1 WHERE @e_cpp_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_02 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_02,'-4 9','5',0,2 WHERE @e_cpp_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_02 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_02,'0 0','0',0,3 WHERE @e_cpp_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_02 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_02,'100 -25','75',0,4 WHERE @e_cpp_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_02 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 03 - Rectangle Area',CONCAT('ca-cpp-path-03-rectangle-area-t', @teacher_id),'Read the width and height of a rectangle and print its area.

Input: Two non-negative integers w and h, each at most 1000.
Output: w multiplied by h.
Hint: Area = width × height.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Arithmetic',480,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-03-rectangle-area-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_03,3 WHERE @path_cpp IS NOT NULL AND @e_cpp_03 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_03,'4 6','24',1,1 WHERE @e_cpp_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_03 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_03,'1 9','9',0,2 WHERE @e_cpp_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_03 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_03,'12 12','144',0,3 WHERE @e_cpp_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_03 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_03,'0 12','0',0,4 WHERE @e_cpp_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_03 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 04 - Even or Odd',CONCAT('ca-cpp-path-04-even-or-odd-t', @teacher_id),'Read an integer. Print Even if it is divisible by 2; otherwise print Odd. Handle negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Conditionals',480,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-04-even-or-odd-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_04,4 WHERE @path_cpp IS NOT NULL AND @e_cpp_04 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_04,'7','Odd',1,1 WHERE @e_cpp_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_04 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_04,'8','Even',0,2 WHERE @e_cpp_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_04 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_04,'0','Even',0,3 WHERE @e_cpp_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_04 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_04,'-3','Odd',0,4 WHERE @e_cpp_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_04 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 05 - Sum from 1 to N',CONCAT('ca-cpp-path-05-sum-one-to-n-t', @teacher_id),'Read a positive integer N and calculate 1 + 2 + ... + N.

Input: One integer N, where 1 ≤ N ≤ 100000.
Output: The sum as an integer.
Hint: Use a loop and a running total.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Loops',600,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-05-sum-one-to-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_05,5 WHERE @path_cpp IS NOT NULL AND @e_cpp_05 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_05,'5','15',1,1 WHERE @e_cpp_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_05 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_05,'1','1',0,2 WHERE @e_cpp_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_05 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_05,'10','55',0,3 WHERE @e_cpp_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_05 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_05,'100000','5000050000',0,4 WHERE @e_cpp_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_05 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 06 - Largest of Three',CONCAT('ca-cpp-path-06-largest-of-three-t', @teacher_id),'Read three integers and print the largest. If values are tied, print the tied value.

Input: Three integers separated by whitespace.
Output: The maximum value.
Hint: Compare all three values, including when they are equal or negative.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Conditionals',600,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-06-largest-of-three-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_06,6 WHERE @path_cpp IS NOT NULL AND @e_cpp_06 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_06,'12 25 8','25',1,1 WHERE @e_cpp_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_06 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_06,'-4 -2 -9','-2',0,2 WHERE @e_cpp_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_06 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_06,'7 7 2','7',0,3 WHERE @e_cpp_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_06 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_06,'0 0 0','0',0,4 WHERE @e_cpp_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_06 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 07 - Count the Vowels',CONCAT('ca-cpp-path-07-count-vowels-t', @teacher_id),'Read one word and count the vowels a, e, i, o, u. Count uppercase and lowercase vowels.

Input: One word containing English letters.
Output: One integer, the vowel count.
Hint: Check every character against the five vowels.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Strings',600,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-07-count-vowels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_07,7 WHERE @path_cpp IS NOT NULL AND @e_cpp_07 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_07,'Programming','3',1,1 WHERE @e_cpp_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_07 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_07,'sky','0',0,2 WHERE @e_cpp_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_07 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_07,'EDUCATION','5',0,3 WHERE @e_cpp_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_07 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_07,'CodeArena','5',0,4 WHERE @e_cpp_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_07 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 08 - Calculate Factorial',CONCAT('ca-cpp-path-08-factorial-t', @teacher_id),'Calculate N!, the product of all integers from 1 to N. By definition, 0! = 1.

Input: One integer N, where 0 ≤ N ≤ 12.
Output: N! as an integer.
Hint: Start the product at 1.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Loops',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-08-factorial-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_08,8 WHERE @path_cpp IS NOT NULL AND @e_cpp_08 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_08,'5','120',1,1 WHERE @e_cpp_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_08 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_08,'0','1',0,2 WHERE @e_cpp_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_08 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_08,'1','1',0,3 WHERE @e_cpp_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_08 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_08,'10','3628800',0,4 WHERE @e_cpp_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_08 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 09 - Reverse a Number',CONCAT('ca-cpp-path-09-reverse-number-t', @teacher_id),'Read a non-negative integer and print its digits in reverse order. Leading zeros in the reversed result are omitted.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: The reversed integer.
Hint: Use remainder by 10 and integer division by 10.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-09-reverse-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_09,9 WHERE @path_cpp IS NOT NULL AND @e_cpp_09 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_09,'12340','4321',1,1 WHERE @e_cpp_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_09 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_09,'7','7',0,2 WHERE @e_cpp_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_09 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_09,'1000','1',0,3 WHERE @e_cpp_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_09 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_09,'908','809',0,4 WHERE @e_cpp_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_09 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 10 - First Ten Multiples',CONCAT('ca-cpp-path-10-multiples-of-n-t', @teacher_id),'Read an integer N and print its first ten positive multiples on one line, separated by a single space.

Input: One integer N, where 1 ≤ N ≤ 1000.
Output: N, 2N, ..., 10N. Do not print extra labels.
Hint: Repeat a multiplication for i from 1 through 10.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Loops',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-10-multiples-of-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_10,10 WHERE @path_cpp IS NOT NULL AND @e_cpp_10 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_10,'3','3 6 9 12 15 18 21 24 27 30',1,1 WHERE @e_cpp_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_10 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_10,'1','1 2 3 4 5 6 7 8 9 10',0,2 WHERE @e_cpp_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_10 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_10,'5','5 10 15 20 25 30 35 40 45 50',0,3 WHERE @e_cpp_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_10 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_10,'10','10 20 30 40 50 60 70 80 90 100',0,4 WHERE @e_cpp_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_10 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 11 - Count Digits',CONCAT('ca-cpp-path-11-count-digits-t', @teacher_id),'Count how many decimal digits are in a non-negative integer. Zero has one digit.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Number of digits.
Hint: Repeatedly divide by 10 or convert to a string.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-11-count-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_11,11 WHERE @path_cpp IS NOT NULL AND @e_cpp_11 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_11,'0','1',1,1 WHERE @e_cpp_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_11 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_11,'9','1',0,2 WHERE @e_cpp_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_11 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_11,'12034','5',0,3 WHERE @e_cpp_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_11 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_11,'1000000000','10',0,4 WHERE @e_cpp_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_11 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 12 - Palindrome Number',CONCAT('ca-cpp-path-12-palindrome-number-t', @teacher_id),'Determine whether a non-negative integer reads the same forward and backward. Print Yes or No.

Input: One integer N.
Output: Yes if it is a palindrome; otherwise No.
Hint: Compare the number with its reversed digits.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-12-palindrome-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_12,12 WHERE @path_cpp IS NOT NULL AND @e_cpp_12 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_12,'121','Yes',1,1 WHERE @e_cpp_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_12 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_12,'123','No',0,2 WHERE @e_cpp_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_12 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_12,'7','Yes',0,3 WHERE @e_cpp_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_12 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_12,'100','No',0,4 WHERE @e_cpp_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_12 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 13 - Prime Number Check',CONCAT('ca-cpp-path-13-prime-check-t', @teacher_id),'Check whether N is a prime number. A prime is an integer greater than 1 with exactly two positive divisors.

Input: One integer N, where 0 ≤ N ≤ 1000000.
Output: Prime or Not Prime.
Hint: Check possible divisors only up to the square root of N.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Number Theory',900,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-13-prime-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_13,13 WHERE @path_cpp IS NOT NULL AND @e_cpp_13 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_13,'17','Prime',1,1 WHERE @e_cpp_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_13 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_13,'1','Not Prime',0,2 WHERE @e_cpp_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_13 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_13,'2','Prime',0,3 WHERE @e_cpp_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_13 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_13,'100','Not Prime',0,4 WHERE @e_cpp_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_13 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 14 - Sum of Digits',CONCAT('ca-cpp-path-14-sum-digits-t', @teacher_id),'Read a non-negative integer and print the sum of its digits.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Sum of all decimal digits.
Hint: Extract each last digit with remainder by 10.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-14-sum-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_14,14 WHERE @path_cpp IS NOT NULL AND @e_cpp_14 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_14,'1234','10',1,1 WHERE @e_cpp_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_14 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_14,'0','0',0,2 WHERE @e_cpp_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_14 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_14,'999','27',0,3 WHERE @e_cpp_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_14 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_14,'10005','6',0,4 WHERE @e_cpp_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_14 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 15 - Nth Fibonacci Number',CONCAT('ca-cpp-path-15-fibonacci-nth-t', @teacher_id),'Use the sequence F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2). Print F(N).

Input: One integer N, where 0 ≤ N ≤ 45.
Output: F(N).
Hint: Build the sequence iteratively instead of using slow recursion.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Sequences',900,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-15-fibonacci-nth-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_15,15 WHERE @path_cpp IS NOT NULL AND @e_cpp_15 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_15,'0','0',1,1 WHERE @e_cpp_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_15 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_15,'1','1',0,2 WHERE @e_cpp_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_15 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_15,'10','55',0,3 WHERE @e_cpp_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_15 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_15,'45','1134903170',0,4 WHERE @e_cpp_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_15 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 16 - Greatest Common Divisor',CONCAT('ca-cpp-path-16-greatest-common-divisor-t', @teacher_id),'Read two positive integers and print their greatest common divisor (GCD).

Input: Positive integers a and b, each at most 1000000000.
Output: gcd(a, b).
Hint: Use the Euclidean algorithm.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Number Theory',900,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-16-greatest-common-divisor-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_16,16 WHERE @path_cpp IS NOT NULL AND @e_cpp_16 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_16,'12 18','6',1,1 WHERE @e_cpp_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_16 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_16,'7 13','1',0,2 WHERE @e_cpp_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_16 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_16,'100 80','20',0,3 WHERE @e_cpp_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_16 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_16,'1 1','1',0,4 WHERE @e_cpp_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_16 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 17 - Least Common Multiple',CONCAT('ca-cpp-path-17-least-common-multiple-t', @teacher_id),'Read two positive integers and print their least common multiple (LCM).

Input: Positive integers a and b, each at most 100000.
Output: lcm(a, b).
Hint: lcm(a,b) = a / gcd(a,b) × b.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Number Theory',900,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-17-least-common-multiple-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_17,17 WHERE @path_cpp IS NOT NULL AND @e_cpp_17 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_17,'4 6','12',1,1 WHERE @e_cpp_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_17 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_17,'7 5','35',0,2 WHERE @e_cpp_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_17 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_17,'12 18','36',0,3 WHERE @e_cpp_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_17 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_17,'1 999','999',0,4 WHERE @e_cpp_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_17 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 18 - Reverse a Word',CONCAT('ca-cpp-path-18-reverse-word-t', @teacher_id),'Read one word and print its characters in reverse order. Preserve each character''s case.

Input: One word of English letters.
Output: The reversed word.
Hint: Walk from the final character to the first.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Strings',600,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-18-reverse-word-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_18,18 WHERE @path_cpp IS NOT NULL AND @e_cpp_18 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_18,'CodeArena','anerAedoC',1,1 WHERE @e_cpp_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_18 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_18,'hello','olleh',0,2 WHERE @e_cpp_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_18 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_18,'a','a',0,3 WHERE @e_cpp_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_18 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_18,'Ruby','ybuR',0,4 WHERE @e_cpp_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_18 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 19 - Count Words in a Sentence',CONCAT('ca-cpp-path-19-count-words-t', @teacher_id),'Read one complete line and count its whitespace-separated words. Repeated spaces should not create empty words.

Input: One non-empty line.
Output: Number of words.
Hint: Trim the line and split on one or more whitespace characters.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Strings',900,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-19-count-words-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_19,19 WHERE @path_cpp IS NOT NULL AND @e_cpp_19 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_19,'Code Arena is fun','4',1,1 WHERE @e_cpp_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_19 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_19,'one','1',0,2 WHERE @e_cpp_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_19 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_19,'  many   spaces here  ','3',0,3 WHERE @e_cpp_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_19 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_19,'Learn to code every day','5',0,4 WHERE @e_cpp_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_19 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 20 - Maximum in an Array',CONCAT('ca-cpp-path-20-array-maximum-t', @teacher_id),'Read N integers and print the maximum value.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: The maximum integer.
Hint: Initialize the maximum from the first value.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Arrays',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-20-array-maximum-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_20,20 WHERE @path_cpp IS NOT NULL AND @e_cpp_20 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_20,'5 3 9 1 9 4','9',1,1 WHERE @e_cpp_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_20 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_20,'4 -8 -3 -10 -5','-3',0,2 WHERE @e_cpp_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_20 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_20,'1 42','42',0,3 WHERE @e_cpp_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_20 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_20,'3 0 0 -1','0',0,4 WHERE @e_cpp_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_20 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 21 - Count Positive Numbers',CONCAT('ca-cpp-path-21-count-positive-t', @teacher_id),'Count how many values in a list are strictly greater than zero. Zero is not positive.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Count of positive values.
Hint: Increase the counter only when value > 0.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Arrays',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-21-count-positive-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_21,21 WHERE @path_cpp IS NOT NULL AND @e_cpp_21 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_21,'5 -3 2 0 7 -1','2',1,1 WHERE @e_cpp_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_21 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_21,'4 1 2 3 4','4',0,2 WHERE @e_cpp_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_21 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_21,'3 -1 0 -9','0',0,3 WHERE @e_cpp_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_21 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_21,'1 100','1',0,4 WHERE @e_cpp_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_21 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 22 - Second Largest Distinct Number',CONCAT('ca-cpp-path-22-second-largest-distinct-t', @teacher_id),'Find the second-largest distinct value in a list. Inputs are guaranteed to contain at least two distinct values.

Input: N followed by N integers, where 2 ≤ N ≤ 1000.
Output: The second-largest distinct number.
Hint: Track the largest and second-largest distinct values.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Arrays',1080,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-22-second-largest-distinct-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_22,22 WHERE @path_cpp IS NOT NULL AND @e_cpp_22 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_22,'6 4 1 9 7 9 3','7',1,1 WHERE @e_cpp_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_22 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_22,'3 1 2 3','2',0,2 WHERE @e_cpp_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_22 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_22,'5 -5 -1 -1 -3 -2','-2',0,3 WHERE @e_cpp_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_22 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_22,'4 10 10 9 8','9',0,4 WHERE @e_cpp_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_22 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 23 - Linear Search',CONCAT('ca-cpp-path-23-linear-search-t', @teacher_id),'Find the first zero-based index of target in an integer array. Print -1 when it is absent.

Input: N, then N integers, then target.
Output: First matching index, or -1.
Hint: Scan the list from left to right.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Easy','Searching',720,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-23-linear-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_23,23 WHERE @path_cpp IS NOT NULL AND @e_cpp_23 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_23,'5 3 9 1 8 4 9','1',1,1 WHERE @e_cpp_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_23 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_23,'3 1 2 3 4','-1',0,2 WHERE @e_cpp_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_23 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_23,'4 7 7 7 7 7','0',0,3 WHERE @e_cpp_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_23 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_23,'1 5 5','0',0,4 WHERE @e_cpp_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_23 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 24 - Binary Search',CONCAT('ca-cpp-path-24-binary-search-t', @teacher_id),'Search a sorted ascending array and print the first zero-based index of target, or -1 if absent. If duplicates exist, return the first index.

Input: N, then N sorted integers, then target.
Output: First matching index, or -1.
Hint: Use left and right boundaries; continue left after a match.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Searching',1080,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-24-binary-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_24,24 WHERE @path_cpp IS NOT NULL AND @e_cpp_24 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_24,'6 1 2 4 4 7 9 4','2',1,1 WHERE @e_cpp_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_24 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_24,'5 1 3 5 7 9 6','-1',0,2 WHERE @e_cpp_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_24 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_24,'4 2 2 2 2 2','0',0,3 WHERE @e_cpp_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_24 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_24,'1 9 9','0',0,4 WHERE @e_cpp_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_24 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 25 - Sort Numbers Ascending',CONCAT('ca-cpp-path-25-sort-ascending-t', @teacher_id),'Sort N integers in ascending order and print them on one line separated by a single space.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Sorted integers.
Hint: Use a built-in sort or implement a sorting algorithm.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Sorting',1080,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-25-sort-ascending-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_25,25 WHERE @path_cpp IS NOT NULL AND @e_cpp_25 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_25,'5 3 1 4 1 2','1 1 2 3 4',1,1 WHERE @e_cpp_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_25 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_25,'3 9 -1 0','-1 0 9',0,2 WHERE @e_cpp_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_25 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_25,'1 7','7',0,3 WHERE @e_cpp_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_25 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_25,'4 5 5 5 5','5 5 5 5',0,4 WHERE @e_cpp_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_25 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 26 - Remove Duplicates, Keep Order',CONCAT('ca-cpp-path-26-remove-duplicates-t', @teacher_id),'Remove repeated values while preserving the first occurrence of each value. Print the remaining values separated by one space.

Input: N followed by N integers.
Output: Unique values in original order.
Hint: Keep a set of values already seen and a separate output list.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Arrays',1080,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-26-remove-duplicates-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_26,26 WHERE @path_cpp IS NOT NULL AND @e_cpp_26 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_26,'7 3 3 1 2 1 4 2','3 1 2 4',1,1 WHERE @e_cpp_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_26 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_26,'4 5 5 5 5','5',0,2 WHERE @e_cpp_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_26 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_26,'5 1 2 3 4 5','1 2 3 4 5',0,3 WHERE @e_cpp_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_26 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_26,'6 0 -1 0 -1 2 2','0 -1 2',0,4 WHERE @e_cpp_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_26 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 27 - Character Frequency',CONCAT('ca-cpp-path-27-character-frequency-t', @teacher_id),'Read a word and a single character, then count exact case-sensitive occurrences of that character in the word.

Input: A word and a character separated by whitespace.
Output: Number of occurrences.
Hint: Compare each character of the word with the target character.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Strings',900,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-27-character-frequency-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_27,27 WHERE @path_cpp IS NOT NULL AND @e_cpp_27 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_27,'banana a','3',1,1 WHERE @e_cpp_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_27 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_27,'CodeArena a','1',0,2 WHERE @e_cpp_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_27 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_27,'hello z','0',0,3 WHERE @e_cpp_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_27 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_27,'AAAA A','4',0,4 WHERE @e_cpp_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_27 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 28 - Anagram Check',CONCAT('ca-cpp-path-28-anagram-check-t', @teacher_id),'Determine whether two lowercase words contain exactly the same letters with the same frequencies. Print Yes or No.

Input: Two lowercase words.
Output: Yes if they are anagrams; otherwise No.
Hint: Compare sorted letters or letter-frequency counts.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Strings',1080,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-28-anagram-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_28,28 WHERE @path_cpp IS NOT NULL AND @e_cpp_28 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_28,'listen silent','Yes',1,1 WHERE @e_cpp_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_28 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_28,'apple paple','Yes',0,2 WHERE @e_cpp_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_28 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_28,'hello world','No',0,3 WHERE @e_cpp_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_28 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_28,'ab ba','Yes',0,4 WHERE @e_cpp_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_28 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 29 - Balanced Brackets',CONCAT('ca-cpp-path-29-balanced-brackets-t', @teacher_id),'Check whether a string containing only (), [], and {} has correctly matched and nested brackets. Print Yes or No.

Input: A non-empty string of bracket characters.
Output: Yes if balanced; otherwise No.
Hint: Use a stack to remember opening brackets.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Stacks',1200,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-29-balanced-brackets-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_29,29 WHERE @path_cpp IS NOT NULL AND @e_cpp_29 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_29,'([]{})','Yes',1,1 WHERE @e_cpp_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_29 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_29,'([)]','No',0,2 WHERE @e_cpp_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_29 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_29,'((()))','Yes',0,3 WHERE @e_cpp_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_29 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_29,'}{','No',0,4 WHERE @e_cpp_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_29 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'C++ 30 - FizzBuzz',CONCAT('ca-cpp-path-30-fizzbuzz-t', @teacher_id),'For every integer from 1 through N, print FizzBuzz if divisible by both 3 and 5, Fizz if divisible by 3, Buzz if divisible by 5, otherwise print the number. Print one result per line.

Input: One integer N, where 1 ≤ N ≤ 100.
Output: N lines.
Hint: Check divisibility by 15 before 3 or 5.

Learning path: C++ Foundations. Write your solution using C++. Read standard input and print only the required output.','Medium','Problem Solving',1080,100,'#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // TODO: solve the problem. Read from stdin and print only the required output.
    return 0;
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_cpp_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-cpp-path-30-fizzbuzz-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_cpp,@e_cpp_30,30 WHERE @path_cpp IS NOT NULL AND @e_cpp_30 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_30,'5','1
2
Fizz
4
Buzz',1,1 WHERE @e_cpp_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_30 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_30,'1','1',0,2 WHERE @e_cpp_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_30 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_30,'15','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz',0,3 WHERE @e_cpp_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_30 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_cpp_30,'16','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16',0,4 WHERE @e_cpp_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_cpp_30 AND sort_order=4);

-- Java: 30 language-specific exercises and test cases.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 01 - Hello, CodeArena!',CONCAT('ca-java-path-01-hello-codearena-t', @teacher_id),'Print exactly the text Hello, CodeArena! followed by a newline.

Input: No input is provided.
Output: Hello, CodeArena!
Hint: Start by testing your language''s standard output statement.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Output',300,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-01-hello-codearena-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_01,1 WHERE @path_java IS NOT NULL AND @e_java_01 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_01,'','Hello, CodeArena!',1,1 WHERE @e_java_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_01 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_01,'','Hello, CodeArena!',0,2 WHERE @e_java_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_01 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_01,'','Hello, CodeArena!',0,3 WHERE @e_java_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_01 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_01,'','Hello, CodeArena!',0,4 WHERE @e_java_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_01 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 02 - Add Two Integers',CONCAT('ca-java-path-02-add-two-integers-t', @teacher_id),'Read two integers and print their sum. The integers can be separated by spaces or newlines.

Input: Two integers a and b, each from -100000 to 100000.
Output: The value a + b.
Hint: Convert both inputs to integers before adding.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Input & Variables',480,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-02-add-two-integers-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_02,2 WHERE @path_java IS NOT NULL AND @e_java_02 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_02,'3 5','8',1,1 WHERE @e_java_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_02 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_02,'-4 9','5',0,2 WHERE @e_java_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_02 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_02,'0 0','0',0,3 WHERE @e_java_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_02 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_02,'100 -25','75',0,4 WHERE @e_java_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_02 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 03 - Rectangle Area',CONCAT('ca-java-path-03-rectangle-area-t', @teacher_id),'Read the width and height of a rectangle and print its area.

Input: Two non-negative integers w and h, each at most 1000.
Output: w multiplied by h.
Hint: Area = width × height.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Arithmetic',480,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-03-rectangle-area-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_03,3 WHERE @path_java IS NOT NULL AND @e_java_03 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_03,'4 6','24',1,1 WHERE @e_java_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_03 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_03,'1 9','9',0,2 WHERE @e_java_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_03 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_03,'12 12','144',0,3 WHERE @e_java_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_03 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_03,'0 12','0',0,4 WHERE @e_java_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_03 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 04 - Even or Odd',CONCAT('ca-java-path-04-even-or-odd-t', @teacher_id),'Read an integer. Print Even if it is divisible by 2; otherwise print Odd. Handle negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Conditionals',480,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-04-even-or-odd-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_04,4 WHERE @path_java IS NOT NULL AND @e_java_04 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_04,'7','Odd',1,1 WHERE @e_java_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_04 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_04,'8','Even',0,2 WHERE @e_java_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_04 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_04,'0','Even',0,3 WHERE @e_java_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_04 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_04,'-3','Odd',0,4 WHERE @e_java_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_04 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 05 - Sum from 1 to N',CONCAT('ca-java-path-05-sum-one-to-n-t', @teacher_id),'Read a positive integer N and calculate 1 + 2 + ... + N.

Input: One integer N, where 1 ≤ N ≤ 100000.
Output: The sum as an integer.
Hint: Use a loop and a running total.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Loops',600,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-05-sum-one-to-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_05,5 WHERE @path_java IS NOT NULL AND @e_java_05 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_05,'5','15',1,1 WHERE @e_java_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_05 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_05,'1','1',0,2 WHERE @e_java_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_05 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_05,'10','55',0,3 WHERE @e_java_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_05 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_05,'100000','5000050000',0,4 WHERE @e_java_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_05 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 06 - Largest of Three',CONCAT('ca-java-path-06-largest-of-three-t', @teacher_id),'Read three integers and print the largest. If values are tied, print the tied value.

Input: Three integers separated by whitespace.
Output: The maximum value.
Hint: Compare all three values, including when they are equal or negative.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Conditionals',600,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-06-largest-of-three-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_06,6 WHERE @path_java IS NOT NULL AND @e_java_06 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_06,'12 25 8','25',1,1 WHERE @e_java_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_06 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_06,'-4 -2 -9','-2',0,2 WHERE @e_java_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_06 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_06,'7 7 2','7',0,3 WHERE @e_java_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_06 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_06,'0 0 0','0',0,4 WHERE @e_java_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_06 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 07 - Count the Vowels',CONCAT('ca-java-path-07-count-vowels-t', @teacher_id),'Read one word and count the vowels a, e, i, o, u. Count uppercase and lowercase vowels.

Input: One word containing English letters.
Output: One integer, the vowel count.
Hint: Check every character against the five vowels.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Strings',600,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-07-count-vowels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_07,7 WHERE @path_java IS NOT NULL AND @e_java_07 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_07,'Programming','3',1,1 WHERE @e_java_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_07 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_07,'sky','0',0,2 WHERE @e_java_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_07 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_07,'EDUCATION','5',0,3 WHERE @e_java_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_07 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_07,'CodeArena','5',0,4 WHERE @e_java_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_07 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 08 - Calculate Factorial',CONCAT('ca-java-path-08-factorial-t', @teacher_id),'Calculate N!, the product of all integers from 1 to N. By definition, 0! = 1.

Input: One integer N, where 0 ≤ N ≤ 12.
Output: N! as an integer.
Hint: Start the product at 1.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Loops',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-08-factorial-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_08,8 WHERE @path_java IS NOT NULL AND @e_java_08 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_08,'5','120',1,1 WHERE @e_java_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_08 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_08,'0','1',0,2 WHERE @e_java_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_08 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_08,'1','1',0,3 WHERE @e_java_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_08 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_08,'10','3628800',0,4 WHERE @e_java_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_08 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 09 - Reverse a Number',CONCAT('ca-java-path-09-reverse-number-t', @teacher_id),'Read a non-negative integer and print its digits in reverse order. Leading zeros in the reversed result are omitted.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: The reversed integer.
Hint: Use remainder by 10 and integer division by 10.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-09-reverse-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_09,9 WHERE @path_java IS NOT NULL AND @e_java_09 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_09,'12340','4321',1,1 WHERE @e_java_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_09 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_09,'7','7',0,2 WHERE @e_java_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_09 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_09,'1000','1',0,3 WHERE @e_java_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_09 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_09,'908','809',0,4 WHERE @e_java_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_09 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 10 - First Ten Multiples',CONCAT('ca-java-path-10-multiples-of-n-t', @teacher_id),'Read an integer N and print its first ten positive multiples on one line, separated by a single space.

Input: One integer N, where 1 ≤ N ≤ 1000.
Output: N, 2N, ..., 10N. Do not print extra labels.
Hint: Repeat a multiplication for i from 1 through 10.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Loops',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-10-multiples-of-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_10,10 WHERE @path_java IS NOT NULL AND @e_java_10 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_10,'3','3 6 9 12 15 18 21 24 27 30',1,1 WHERE @e_java_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_10 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_10,'1','1 2 3 4 5 6 7 8 9 10',0,2 WHERE @e_java_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_10 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_10,'5','5 10 15 20 25 30 35 40 45 50',0,3 WHERE @e_java_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_10 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_10,'10','10 20 30 40 50 60 70 80 90 100',0,4 WHERE @e_java_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_10 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 11 - Count Digits',CONCAT('ca-java-path-11-count-digits-t', @teacher_id),'Count how many decimal digits are in a non-negative integer. Zero has one digit.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Number of digits.
Hint: Repeatedly divide by 10 or convert to a string.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-11-count-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_11,11 WHERE @path_java IS NOT NULL AND @e_java_11 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_11,'0','1',1,1 WHERE @e_java_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_11 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_11,'9','1',0,2 WHERE @e_java_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_11 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_11,'12034','5',0,3 WHERE @e_java_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_11 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_11,'1000000000','10',0,4 WHERE @e_java_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_11 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 12 - Palindrome Number',CONCAT('ca-java-path-12-palindrome-number-t', @teacher_id),'Determine whether a non-negative integer reads the same forward and backward. Print Yes or No.

Input: One integer N.
Output: Yes if it is a palindrome; otherwise No.
Hint: Compare the number with its reversed digits.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-12-palindrome-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_12,12 WHERE @path_java IS NOT NULL AND @e_java_12 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_12,'121','Yes',1,1 WHERE @e_java_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_12 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_12,'123','No',0,2 WHERE @e_java_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_12 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_12,'7','Yes',0,3 WHERE @e_java_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_12 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_12,'100','No',0,4 WHERE @e_java_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_12 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 13 - Prime Number Check',CONCAT('ca-java-path-13-prime-check-t', @teacher_id),'Check whether N is a prime number. A prime is an integer greater than 1 with exactly two positive divisors.

Input: One integer N, where 0 ≤ N ≤ 1000000.
Output: Prime or Not Prime.
Hint: Check possible divisors only up to the square root of N.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Number Theory',900,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-13-prime-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_13,13 WHERE @path_java IS NOT NULL AND @e_java_13 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_13,'17','Prime',1,1 WHERE @e_java_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_13 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_13,'1','Not Prime',0,2 WHERE @e_java_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_13 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_13,'2','Prime',0,3 WHERE @e_java_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_13 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_13,'100','Not Prime',0,4 WHERE @e_java_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_13 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 14 - Sum of Digits',CONCAT('ca-java-path-14-sum-digits-t', @teacher_id),'Read a non-negative integer and print the sum of its digits.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Sum of all decimal digits.
Hint: Extract each last digit with remainder by 10.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-14-sum-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_14,14 WHERE @path_java IS NOT NULL AND @e_java_14 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_14,'1234','10',1,1 WHERE @e_java_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_14 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_14,'0','0',0,2 WHERE @e_java_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_14 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_14,'999','27',0,3 WHERE @e_java_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_14 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_14,'10005','6',0,4 WHERE @e_java_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_14 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 15 - Nth Fibonacci Number',CONCAT('ca-java-path-15-fibonacci-nth-t', @teacher_id),'Use the sequence F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2). Print F(N).

Input: One integer N, where 0 ≤ N ≤ 45.
Output: F(N).
Hint: Build the sequence iteratively instead of using slow recursion.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Sequences',900,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-15-fibonacci-nth-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_15,15 WHERE @path_java IS NOT NULL AND @e_java_15 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_15,'0','0',1,1 WHERE @e_java_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_15 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_15,'1','1',0,2 WHERE @e_java_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_15 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_15,'10','55',0,3 WHERE @e_java_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_15 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_15,'45','1134903170',0,4 WHERE @e_java_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_15 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 16 - Greatest Common Divisor',CONCAT('ca-java-path-16-greatest-common-divisor-t', @teacher_id),'Read two positive integers and print their greatest common divisor (GCD).

Input: Positive integers a and b, each at most 1000000000.
Output: gcd(a, b).
Hint: Use the Euclidean algorithm.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Number Theory',900,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-16-greatest-common-divisor-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_16,16 WHERE @path_java IS NOT NULL AND @e_java_16 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_16,'12 18','6',1,1 WHERE @e_java_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_16 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_16,'7 13','1',0,2 WHERE @e_java_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_16 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_16,'100 80','20',0,3 WHERE @e_java_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_16 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_16,'1 1','1',0,4 WHERE @e_java_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_16 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 17 - Least Common Multiple',CONCAT('ca-java-path-17-least-common-multiple-t', @teacher_id),'Read two positive integers and print their least common multiple (LCM).

Input: Positive integers a and b, each at most 100000.
Output: lcm(a, b).
Hint: lcm(a,b) = a / gcd(a,b) × b.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Number Theory',900,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-17-least-common-multiple-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_17,17 WHERE @path_java IS NOT NULL AND @e_java_17 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_17,'4 6','12',1,1 WHERE @e_java_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_17 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_17,'7 5','35',0,2 WHERE @e_java_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_17 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_17,'12 18','36',0,3 WHERE @e_java_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_17 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_17,'1 999','999',0,4 WHERE @e_java_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_17 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 18 - Reverse a Word',CONCAT('ca-java-path-18-reverse-word-t', @teacher_id),'Read one word and print its characters in reverse order. Preserve each character''s case.

Input: One word of English letters.
Output: The reversed word.
Hint: Walk from the final character to the first.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Strings',600,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-18-reverse-word-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_18,18 WHERE @path_java IS NOT NULL AND @e_java_18 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_18,'CodeArena','anerAedoC',1,1 WHERE @e_java_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_18 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_18,'hello','olleh',0,2 WHERE @e_java_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_18 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_18,'a','a',0,3 WHERE @e_java_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_18 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_18,'Ruby','ybuR',0,4 WHERE @e_java_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_18 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 19 - Count Words in a Sentence',CONCAT('ca-java-path-19-count-words-t', @teacher_id),'Read one complete line and count its whitespace-separated words. Repeated spaces should not create empty words.

Input: One non-empty line.
Output: Number of words.
Hint: Trim the line and split on one or more whitespace characters.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Strings',900,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-19-count-words-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_19,19 WHERE @path_java IS NOT NULL AND @e_java_19 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_19,'Code Arena is fun','4',1,1 WHERE @e_java_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_19 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_19,'one','1',0,2 WHERE @e_java_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_19 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_19,'  many   spaces here  ','3',0,3 WHERE @e_java_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_19 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_19,'Learn to code every day','5',0,4 WHERE @e_java_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_19 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 20 - Maximum in an Array',CONCAT('ca-java-path-20-array-maximum-t', @teacher_id),'Read N integers and print the maximum value.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: The maximum integer.
Hint: Initialize the maximum from the first value.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Arrays',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-20-array-maximum-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_20,20 WHERE @path_java IS NOT NULL AND @e_java_20 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_20,'5 3 9 1 9 4','9',1,1 WHERE @e_java_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_20 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_20,'4 -8 -3 -10 -5','-3',0,2 WHERE @e_java_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_20 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_20,'1 42','42',0,3 WHERE @e_java_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_20 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_20,'3 0 0 -1','0',0,4 WHERE @e_java_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_20 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 21 - Count Positive Numbers',CONCAT('ca-java-path-21-count-positive-t', @teacher_id),'Count how many values in a list are strictly greater than zero. Zero is not positive.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Count of positive values.
Hint: Increase the counter only when value > 0.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Arrays',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-21-count-positive-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_21,21 WHERE @path_java IS NOT NULL AND @e_java_21 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_21,'5 -3 2 0 7 -1','2',1,1 WHERE @e_java_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_21 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_21,'4 1 2 3 4','4',0,2 WHERE @e_java_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_21 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_21,'3 -1 0 -9','0',0,3 WHERE @e_java_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_21 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_21,'1 100','1',0,4 WHERE @e_java_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_21 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 22 - Second Largest Distinct Number',CONCAT('ca-java-path-22-second-largest-distinct-t', @teacher_id),'Find the second-largest distinct value in a list. Inputs are guaranteed to contain at least two distinct values.

Input: N followed by N integers, where 2 ≤ N ≤ 1000.
Output: The second-largest distinct number.
Hint: Track the largest and second-largest distinct values.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Arrays',1080,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-22-second-largest-distinct-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_22,22 WHERE @path_java IS NOT NULL AND @e_java_22 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_22,'6 4 1 9 7 9 3','7',1,1 WHERE @e_java_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_22 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_22,'3 1 2 3','2',0,2 WHERE @e_java_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_22 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_22,'5 -5 -1 -1 -3 -2','-2',0,3 WHERE @e_java_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_22 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_22,'4 10 10 9 8','9',0,4 WHERE @e_java_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_22 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 23 - Linear Search',CONCAT('ca-java-path-23-linear-search-t', @teacher_id),'Find the first zero-based index of target in an integer array. Print -1 when it is absent.

Input: N, then N integers, then target.
Output: First matching index, or -1.
Hint: Scan the list from left to right.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Easy','Searching',720,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-23-linear-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_23,23 WHERE @path_java IS NOT NULL AND @e_java_23 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_23,'5 3 9 1 8 4 9','1',1,1 WHERE @e_java_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_23 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_23,'3 1 2 3 4','-1',0,2 WHERE @e_java_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_23 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_23,'4 7 7 7 7 7','0',0,3 WHERE @e_java_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_23 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_23,'1 5 5','0',0,4 WHERE @e_java_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_23 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 24 - Binary Search',CONCAT('ca-java-path-24-binary-search-t', @teacher_id),'Search a sorted ascending array and print the first zero-based index of target, or -1 if absent. If duplicates exist, return the first index.

Input: N, then N sorted integers, then target.
Output: First matching index, or -1.
Hint: Use left and right boundaries; continue left after a match.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Searching',1080,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-24-binary-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_24,24 WHERE @path_java IS NOT NULL AND @e_java_24 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_24,'6 1 2 4 4 7 9 4','2',1,1 WHERE @e_java_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_24 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_24,'5 1 3 5 7 9 6','-1',0,2 WHERE @e_java_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_24 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_24,'4 2 2 2 2 2','0',0,3 WHERE @e_java_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_24 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_24,'1 9 9','0',0,4 WHERE @e_java_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_24 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 25 - Sort Numbers Ascending',CONCAT('ca-java-path-25-sort-ascending-t', @teacher_id),'Sort N integers in ascending order and print them on one line separated by a single space.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Sorted integers.
Hint: Use a built-in sort or implement a sorting algorithm.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Sorting',1080,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-25-sort-ascending-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_25,25 WHERE @path_java IS NOT NULL AND @e_java_25 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_25,'5 3 1 4 1 2','1 1 2 3 4',1,1 WHERE @e_java_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_25 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_25,'3 9 -1 0','-1 0 9',0,2 WHERE @e_java_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_25 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_25,'1 7','7',0,3 WHERE @e_java_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_25 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_25,'4 5 5 5 5','5 5 5 5',0,4 WHERE @e_java_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_25 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 26 - Remove Duplicates, Keep Order',CONCAT('ca-java-path-26-remove-duplicates-t', @teacher_id),'Remove repeated values while preserving the first occurrence of each value. Print the remaining values separated by one space.

Input: N followed by N integers.
Output: Unique values in original order.
Hint: Keep a set of values already seen and a separate output list.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Arrays',1080,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-26-remove-duplicates-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_26,26 WHERE @path_java IS NOT NULL AND @e_java_26 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_26,'7 3 3 1 2 1 4 2','3 1 2 4',1,1 WHERE @e_java_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_26 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_26,'4 5 5 5 5','5',0,2 WHERE @e_java_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_26 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_26,'5 1 2 3 4 5','1 2 3 4 5',0,3 WHERE @e_java_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_26 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_26,'6 0 -1 0 -1 2 2','0 -1 2',0,4 WHERE @e_java_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_26 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 27 - Character Frequency',CONCAT('ca-java-path-27-character-frequency-t', @teacher_id),'Read a word and a single character, then count exact case-sensitive occurrences of that character in the word.

Input: A word and a character separated by whitespace.
Output: Number of occurrences.
Hint: Compare each character of the word with the target character.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Strings',900,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-27-character-frequency-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_27,27 WHERE @path_java IS NOT NULL AND @e_java_27 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_27,'banana a','3',1,1 WHERE @e_java_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_27 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_27,'CodeArena a','1',0,2 WHERE @e_java_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_27 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_27,'hello z','0',0,3 WHERE @e_java_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_27 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_27,'AAAA A','4',0,4 WHERE @e_java_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_27 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 28 - Anagram Check',CONCAT('ca-java-path-28-anagram-check-t', @teacher_id),'Determine whether two lowercase words contain exactly the same letters with the same frequencies. Print Yes or No.

Input: Two lowercase words.
Output: Yes if they are anagrams; otherwise No.
Hint: Compare sorted letters or letter-frequency counts.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Strings',1080,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-28-anagram-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_28,28 WHERE @path_java IS NOT NULL AND @e_java_28 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_28,'listen silent','Yes',1,1 WHERE @e_java_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_28 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_28,'apple paple','Yes',0,2 WHERE @e_java_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_28 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_28,'hello world','No',0,3 WHERE @e_java_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_28 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_28,'ab ba','Yes',0,4 WHERE @e_java_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_28 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 29 - Balanced Brackets',CONCAT('ca-java-path-29-balanced-brackets-t', @teacher_id),'Check whether a string containing only (), [], and {} has correctly matched and nested brackets. Print Yes or No.

Input: A non-empty string of bracket characters.
Output: Yes if balanced; otherwise No.
Hint: Use a stack to remember opening brackets.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Stacks',1200,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-29-balanced-brackets-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_29,29 WHERE @path_java IS NOT NULL AND @e_java_29 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_29,'([]{})','Yes',1,1 WHERE @e_java_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_29 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_29,'([)]','No',0,2 WHERE @e_java_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_29 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_29,'((()))','Yes',0,3 WHERE @e_java_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_29 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_29,'}{','No',0,4 WHERE @e_java_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_29 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Java 30 - FizzBuzz',CONCAT('ca-java-path-30-fizzbuzz-t', @teacher_id),'For every integer from 1 through N, print FizzBuzz if divisible by both 3 and 5, Fizz if divisible by 3, Buzz if divisible by 5, otherwise print the number. Print one result per line.

Input: One integer N, where 1 ≤ N ≤ 100.
Output: N lines.
Hint: Check divisibility by 15 before 3 or 5.

Learning path: Java Foundations. Write your solution using Java. Read standard input and print only the required output.','Medium','Problem Solving',1080,100,'import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // TODO: solve the problem. Read from stdin and print only the required output.
    }
}
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_java_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-java-path-30-fizzbuzz-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_java,@e_java_30,30 WHERE @path_java IS NOT NULL AND @e_java_30 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_30,'5','1
2
Fizz
4
Buzz',1,1 WHERE @e_java_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_30 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_30,'1','1',0,2 WHERE @e_java_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_30 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_30,'15','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz',0,3 WHERE @e_java_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_30 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_java_30,'16','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16',0,4 WHERE @e_java_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_java_30 AND sort_order=4);

-- PHP: 30 language-specific exercises and test cases.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 01 - Hello, CodeArena!',CONCAT('ca-php-path-01-hello-codearena-t', @teacher_id),'Print exactly the text Hello, CodeArena! followed by a newline.

Input: No input is provided.
Output: Hello, CodeArena!
Hint: Start by testing your language''s standard output statement.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Output',300,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-01-hello-codearena-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_01,1 WHERE @path_php IS NOT NULL AND @e_php_01 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_01,'','Hello, CodeArena!',1,1 WHERE @e_php_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_01 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_01,'','Hello, CodeArena!',0,2 WHERE @e_php_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_01 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_01,'','Hello, CodeArena!',0,3 WHERE @e_php_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_01 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_01,'','Hello, CodeArena!',0,4 WHERE @e_php_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_01 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 02 - Add Two Integers',CONCAT('ca-php-path-02-add-two-integers-t', @teacher_id),'Read two integers and print their sum. The integers can be separated by spaces or newlines.

Input: Two integers a and b, each from -100000 to 100000.
Output: The value a + b.
Hint: Convert both inputs to integers before adding.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Input & Variables',480,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-02-add-two-integers-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_02,2 WHERE @path_php IS NOT NULL AND @e_php_02 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_02,'3 5','8',1,1 WHERE @e_php_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_02 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_02,'-4 9','5',0,2 WHERE @e_php_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_02 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_02,'0 0','0',0,3 WHERE @e_php_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_02 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_02,'100 -25','75',0,4 WHERE @e_php_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_02 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 03 - Rectangle Area',CONCAT('ca-php-path-03-rectangle-area-t', @teacher_id),'Read the width and height of a rectangle and print its area.

Input: Two non-negative integers w and h, each at most 1000.
Output: w multiplied by h.
Hint: Area = width × height.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Arithmetic',480,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-03-rectangle-area-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_03,3 WHERE @path_php IS NOT NULL AND @e_php_03 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_03,'4 6','24',1,1 WHERE @e_php_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_03 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_03,'1 9','9',0,2 WHERE @e_php_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_03 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_03,'12 12','144',0,3 WHERE @e_php_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_03 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_03,'0 12','0',0,4 WHERE @e_php_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_03 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 04 - Even or Odd',CONCAT('ca-php-path-04-even-or-odd-t', @teacher_id),'Read an integer. Print Even if it is divisible by 2; otherwise print Odd. Handle negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Conditionals',480,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-04-even-or-odd-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_04,4 WHERE @path_php IS NOT NULL AND @e_php_04 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_04,'7','Odd',1,1 WHERE @e_php_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_04 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_04,'8','Even',0,2 WHERE @e_php_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_04 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_04,'0','Even',0,3 WHERE @e_php_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_04 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_04,'-3','Odd',0,4 WHERE @e_php_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_04 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 05 - Sum from 1 to N',CONCAT('ca-php-path-05-sum-one-to-n-t', @teacher_id),'Read a positive integer N and calculate 1 + 2 + ... + N.

Input: One integer N, where 1 ≤ N ≤ 100000.
Output: The sum as an integer.
Hint: Use a loop and a running total.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Loops',600,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-05-sum-one-to-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_05,5 WHERE @path_php IS NOT NULL AND @e_php_05 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_05,'5','15',1,1 WHERE @e_php_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_05 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_05,'1','1',0,2 WHERE @e_php_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_05 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_05,'10','55',0,3 WHERE @e_php_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_05 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_05,'100000','5000050000',0,4 WHERE @e_php_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_05 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 06 - Largest of Three',CONCAT('ca-php-path-06-largest-of-three-t', @teacher_id),'Read three integers and print the largest. If values are tied, print the tied value.

Input: Three integers separated by whitespace.
Output: The maximum value.
Hint: Compare all three values, including when they are equal or negative.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Conditionals',600,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-06-largest-of-three-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_06,6 WHERE @path_php IS NOT NULL AND @e_php_06 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_06,'12 25 8','25',1,1 WHERE @e_php_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_06 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_06,'-4 -2 -9','-2',0,2 WHERE @e_php_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_06 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_06,'7 7 2','7',0,3 WHERE @e_php_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_06 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_06,'0 0 0','0',0,4 WHERE @e_php_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_06 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 07 - Count the Vowels',CONCAT('ca-php-path-07-count-vowels-t', @teacher_id),'Read one word and count the vowels a, e, i, o, u. Count uppercase and lowercase vowels.

Input: One word containing English letters.
Output: One integer, the vowel count.
Hint: Check every character against the five vowels.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Strings',600,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-07-count-vowels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_07,7 WHERE @path_php IS NOT NULL AND @e_php_07 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_07,'Programming','3',1,1 WHERE @e_php_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_07 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_07,'sky','0',0,2 WHERE @e_php_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_07 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_07,'EDUCATION','5',0,3 WHERE @e_php_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_07 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_07,'CodeArena','5',0,4 WHERE @e_php_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_07 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 08 - Calculate Factorial',CONCAT('ca-php-path-08-factorial-t', @teacher_id),'Calculate N!, the product of all integers from 1 to N. By definition, 0! = 1.

Input: One integer N, where 0 ≤ N ≤ 12.
Output: N! as an integer.
Hint: Start the product at 1.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Loops',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-08-factorial-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_08,8 WHERE @path_php IS NOT NULL AND @e_php_08 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_08,'5','120',1,1 WHERE @e_php_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_08 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_08,'0','1',0,2 WHERE @e_php_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_08 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_08,'1','1',0,3 WHERE @e_php_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_08 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_08,'10','3628800',0,4 WHERE @e_php_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_08 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 09 - Reverse a Number',CONCAT('ca-php-path-09-reverse-number-t', @teacher_id),'Read a non-negative integer and print its digits in reverse order. Leading zeros in the reversed result are omitted.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: The reversed integer.
Hint: Use remainder by 10 and integer division by 10.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-09-reverse-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_09,9 WHERE @path_php IS NOT NULL AND @e_php_09 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_09,'12340','4321',1,1 WHERE @e_php_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_09 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_09,'7','7',0,2 WHERE @e_php_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_09 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_09,'1000','1',0,3 WHERE @e_php_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_09 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_09,'908','809',0,4 WHERE @e_php_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_09 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 10 - First Ten Multiples',CONCAT('ca-php-path-10-multiples-of-n-t', @teacher_id),'Read an integer N and print its first ten positive multiples on one line, separated by a single space.

Input: One integer N, where 1 ≤ N ≤ 1000.
Output: N, 2N, ..., 10N. Do not print extra labels.
Hint: Repeat a multiplication for i from 1 through 10.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Loops',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-10-multiples-of-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_10,10 WHERE @path_php IS NOT NULL AND @e_php_10 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_10,'3','3 6 9 12 15 18 21 24 27 30',1,1 WHERE @e_php_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_10 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_10,'1','1 2 3 4 5 6 7 8 9 10',0,2 WHERE @e_php_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_10 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_10,'5','5 10 15 20 25 30 35 40 45 50',0,3 WHERE @e_php_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_10 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_10,'10','10 20 30 40 50 60 70 80 90 100',0,4 WHERE @e_php_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_10 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 11 - Count Digits',CONCAT('ca-php-path-11-count-digits-t', @teacher_id),'Count how many decimal digits are in a non-negative integer. Zero has one digit.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Number of digits.
Hint: Repeatedly divide by 10 or convert to a string.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-11-count-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_11,11 WHERE @path_php IS NOT NULL AND @e_php_11 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_11,'0','1',1,1 WHERE @e_php_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_11 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_11,'9','1',0,2 WHERE @e_php_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_11 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_11,'12034','5',0,3 WHERE @e_php_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_11 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_11,'1000000000','10',0,4 WHERE @e_php_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_11 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 12 - Palindrome Number',CONCAT('ca-php-path-12-palindrome-number-t', @teacher_id),'Determine whether a non-negative integer reads the same forward and backward. Print Yes or No.

Input: One integer N.
Output: Yes if it is a palindrome; otherwise No.
Hint: Compare the number with its reversed digits.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-12-palindrome-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_12,12 WHERE @path_php IS NOT NULL AND @e_php_12 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_12,'121','Yes',1,1 WHERE @e_php_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_12 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_12,'123','No',0,2 WHERE @e_php_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_12 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_12,'7','Yes',0,3 WHERE @e_php_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_12 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_12,'100','No',0,4 WHERE @e_php_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_12 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 13 - Prime Number Check',CONCAT('ca-php-path-13-prime-check-t', @teacher_id),'Check whether N is a prime number. A prime is an integer greater than 1 with exactly two positive divisors.

Input: One integer N, where 0 ≤ N ≤ 1000000.
Output: Prime or Not Prime.
Hint: Check possible divisors only up to the square root of N.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Number Theory',900,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-13-prime-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_13,13 WHERE @path_php IS NOT NULL AND @e_php_13 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_13,'17','Prime',1,1 WHERE @e_php_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_13 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_13,'1','Not Prime',0,2 WHERE @e_php_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_13 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_13,'2','Prime',0,3 WHERE @e_php_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_13 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_13,'100','Not Prime',0,4 WHERE @e_php_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_13 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 14 - Sum of Digits',CONCAT('ca-php-path-14-sum-digits-t', @teacher_id),'Read a non-negative integer and print the sum of its digits.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Sum of all decimal digits.
Hint: Extract each last digit with remainder by 10.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-14-sum-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_14,14 WHERE @path_php IS NOT NULL AND @e_php_14 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_14,'1234','10',1,1 WHERE @e_php_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_14 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_14,'0','0',0,2 WHERE @e_php_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_14 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_14,'999','27',0,3 WHERE @e_php_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_14 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_14,'10005','6',0,4 WHERE @e_php_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_14 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 15 - Nth Fibonacci Number',CONCAT('ca-php-path-15-fibonacci-nth-t', @teacher_id),'Use the sequence F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2). Print F(N).

Input: One integer N, where 0 ≤ N ≤ 45.
Output: F(N).
Hint: Build the sequence iteratively instead of using slow recursion.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Sequences',900,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-15-fibonacci-nth-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_15,15 WHERE @path_php IS NOT NULL AND @e_php_15 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_15,'0','0',1,1 WHERE @e_php_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_15 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_15,'1','1',0,2 WHERE @e_php_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_15 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_15,'10','55',0,3 WHERE @e_php_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_15 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_15,'45','1134903170',0,4 WHERE @e_php_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_15 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 16 - Greatest Common Divisor',CONCAT('ca-php-path-16-greatest-common-divisor-t', @teacher_id),'Read two positive integers and print their greatest common divisor (GCD).

Input: Positive integers a and b, each at most 1000000000.
Output: gcd(a, b).
Hint: Use the Euclidean algorithm.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Number Theory',900,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-16-greatest-common-divisor-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_16,16 WHERE @path_php IS NOT NULL AND @e_php_16 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_16,'12 18','6',1,1 WHERE @e_php_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_16 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_16,'7 13','1',0,2 WHERE @e_php_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_16 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_16,'100 80','20',0,3 WHERE @e_php_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_16 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_16,'1 1','1',0,4 WHERE @e_php_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_16 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 17 - Least Common Multiple',CONCAT('ca-php-path-17-least-common-multiple-t', @teacher_id),'Read two positive integers and print their least common multiple (LCM).

Input: Positive integers a and b, each at most 100000.
Output: lcm(a, b).
Hint: lcm(a,b) = a / gcd(a,b) × b.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Number Theory',900,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-17-least-common-multiple-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_17,17 WHERE @path_php IS NOT NULL AND @e_php_17 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_17,'4 6','12',1,1 WHERE @e_php_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_17 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_17,'7 5','35',0,2 WHERE @e_php_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_17 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_17,'12 18','36',0,3 WHERE @e_php_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_17 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_17,'1 999','999',0,4 WHERE @e_php_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_17 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 18 - Reverse a Word',CONCAT('ca-php-path-18-reverse-word-t', @teacher_id),'Read one word and print its characters in reverse order. Preserve each character''s case.

Input: One word of English letters.
Output: The reversed word.
Hint: Walk from the final character to the first.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Strings',600,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-18-reverse-word-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_18,18 WHERE @path_php IS NOT NULL AND @e_php_18 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_18,'CodeArena','anerAedoC',1,1 WHERE @e_php_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_18 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_18,'hello','olleh',0,2 WHERE @e_php_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_18 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_18,'a','a',0,3 WHERE @e_php_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_18 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_18,'Ruby','ybuR',0,4 WHERE @e_php_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_18 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 19 - Count Words in a Sentence',CONCAT('ca-php-path-19-count-words-t', @teacher_id),'Read one complete line and count its whitespace-separated words. Repeated spaces should not create empty words.

Input: One non-empty line.
Output: Number of words.
Hint: Trim the line and split on one or more whitespace characters.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Strings',900,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-19-count-words-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_19,19 WHERE @path_php IS NOT NULL AND @e_php_19 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_19,'Code Arena is fun','4',1,1 WHERE @e_php_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_19 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_19,'one','1',0,2 WHERE @e_php_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_19 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_19,'  many   spaces here  ','3',0,3 WHERE @e_php_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_19 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_19,'Learn to code every day','5',0,4 WHERE @e_php_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_19 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 20 - Maximum in an Array',CONCAT('ca-php-path-20-array-maximum-t', @teacher_id),'Read N integers and print the maximum value.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: The maximum integer.
Hint: Initialize the maximum from the first value.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Arrays',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-20-array-maximum-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_20,20 WHERE @path_php IS NOT NULL AND @e_php_20 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_20,'5 3 9 1 9 4','9',1,1 WHERE @e_php_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_20 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_20,'4 -8 -3 -10 -5','-3',0,2 WHERE @e_php_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_20 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_20,'1 42','42',0,3 WHERE @e_php_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_20 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_20,'3 0 0 -1','0',0,4 WHERE @e_php_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_20 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 21 - Count Positive Numbers',CONCAT('ca-php-path-21-count-positive-t', @teacher_id),'Count how many values in a list are strictly greater than zero. Zero is not positive.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Count of positive values.
Hint: Increase the counter only when value > 0.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Arrays',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-21-count-positive-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_21,21 WHERE @path_php IS NOT NULL AND @e_php_21 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_21,'5 -3 2 0 7 -1','2',1,1 WHERE @e_php_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_21 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_21,'4 1 2 3 4','4',0,2 WHERE @e_php_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_21 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_21,'3 -1 0 -9','0',0,3 WHERE @e_php_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_21 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_21,'1 100','1',0,4 WHERE @e_php_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_21 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 22 - Second Largest Distinct Number',CONCAT('ca-php-path-22-second-largest-distinct-t', @teacher_id),'Find the second-largest distinct value in a list. Inputs are guaranteed to contain at least two distinct values.

Input: N followed by N integers, where 2 ≤ N ≤ 1000.
Output: The second-largest distinct number.
Hint: Track the largest and second-largest distinct values.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Arrays',1080,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-22-second-largest-distinct-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_22,22 WHERE @path_php IS NOT NULL AND @e_php_22 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_22,'6 4 1 9 7 9 3','7',1,1 WHERE @e_php_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_22 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_22,'3 1 2 3','2',0,2 WHERE @e_php_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_22 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_22,'5 -5 -1 -1 -3 -2','-2',0,3 WHERE @e_php_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_22 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_22,'4 10 10 9 8','9',0,4 WHERE @e_php_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_22 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 23 - Linear Search',CONCAT('ca-php-path-23-linear-search-t', @teacher_id),'Find the first zero-based index of target in an integer array. Print -1 when it is absent.

Input: N, then N integers, then target.
Output: First matching index, or -1.
Hint: Scan the list from left to right.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Easy','Searching',720,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-23-linear-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_23,23 WHERE @path_php IS NOT NULL AND @e_php_23 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_23,'5 3 9 1 8 4 9','1',1,1 WHERE @e_php_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_23 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_23,'3 1 2 3 4','-1',0,2 WHERE @e_php_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_23 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_23,'4 7 7 7 7 7','0',0,3 WHERE @e_php_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_23 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_23,'1 5 5','0',0,4 WHERE @e_php_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_23 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 24 - Binary Search',CONCAT('ca-php-path-24-binary-search-t', @teacher_id),'Search a sorted ascending array and print the first zero-based index of target, or -1 if absent. If duplicates exist, return the first index.

Input: N, then N sorted integers, then target.
Output: First matching index, or -1.
Hint: Use left and right boundaries; continue left after a match.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Searching',1080,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-24-binary-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_24,24 WHERE @path_php IS NOT NULL AND @e_php_24 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_24,'6 1 2 4 4 7 9 4','2',1,1 WHERE @e_php_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_24 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_24,'5 1 3 5 7 9 6','-1',0,2 WHERE @e_php_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_24 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_24,'4 2 2 2 2 2','0',0,3 WHERE @e_php_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_24 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_24,'1 9 9','0',0,4 WHERE @e_php_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_24 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 25 - Sort Numbers Ascending',CONCAT('ca-php-path-25-sort-ascending-t', @teacher_id),'Sort N integers in ascending order and print them on one line separated by a single space.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Sorted integers.
Hint: Use a built-in sort or implement a sorting algorithm.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Sorting',1080,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-25-sort-ascending-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_25,25 WHERE @path_php IS NOT NULL AND @e_php_25 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_25,'5 3 1 4 1 2','1 1 2 3 4',1,1 WHERE @e_php_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_25 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_25,'3 9 -1 0','-1 0 9',0,2 WHERE @e_php_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_25 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_25,'1 7','7',0,3 WHERE @e_php_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_25 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_25,'4 5 5 5 5','5 5 5 5',0,4 WHERE @e_php_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_25 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 26 - Remove Duplicates, Keep Order',CONCAT('ca-php-path-26-remove-duplicates-t', @teacher_id),'Remove repeated values while preserving the first occurrence of each value. Print the remaining values separated by one space.

Input: N followed by N integers.
Output: Unique values in original order.
Hint: Keep a set of values already seen and a separate output list.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Arrays',1080,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-26-remove-duplicates-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_26,26 WHERE @path_php IS NOT NULL AND @e_php_26 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_26,'7 3 3 1 2 1 4 2','3 1 2 4',1,1 WHERE @e_php_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_26 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_26,'4 5 5 5 5','5',0,2 WHERE @e_php_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_26 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_26,'5 1 2 3 4 5','1 2 3 4 5',0,3 WHERE @e_php_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_26 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_26,'6 0 -1 0 -1 2 2','0 -1 2',0,4 WHERE @e_php_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_26 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 27 - Character Frequency',CONCAT('ca-php-path-27-character-frequency-t', @teacher_id),'Read a word and a single character, then count exact case-sensitive occurrences of that character in the word.

Input: A word and a character separated by whitespace.
Output: Number of occurrences.
Hint: Compare each character of the word with the target character.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Strings',900,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-27-character-frequency-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_27,27 WHERE @path_php IS NOT NULL AND @e_php_27 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_27,'banana a','3',1,1 WHERE @e_php_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_27 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_27,'CodeArena a','1',0,2 WHERE @e_php_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_27 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_27,'hello z','0',0,3 WHERE @e_php_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_27 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_27,'AAAA A','4',0,4 WHERE @e_php_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_27 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 28 - Anagram Check',CONCAT('ca-php-path-28-anagram-check-t', @teacher_id),'Determine whether two lowercase words contain exactly the same letters with the same frequencies. Print Yes or No.

Input: Two lowercase words.
Output: Yes if they are anagrams; otherwise No.
Hint: Compare sorted letters or letter-frequency counts.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Strings',1080,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-28-anagram-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_28,28 WHERE @path_php IS NOT NULL AND @e_php_28 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_28,'listen silent','Yes',1,1 WHERE @e_php_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_28 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_28,'apple paple','Yes',0,2 WHERE @e_php_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_28 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_28,'hello world','No',0,3 WHERE @e_php_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_28 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_28,'ab ba','Yes',0,4 WHERE @e_php_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_28 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 29 - Balanced Brackets',CONCAT('ca-php-path-29-balanced-brackets-t', @teacher_id),'Check whether a string containing only (), [], and {} has correctly matched and nested brackets. Print Yes or No.

Input: A non-empty string of bracket characters.
Output: Yes if balanced; otherwise No.
Hint: Use a stack to remember opening brackets.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Stacks',1200,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-29-balanced-brackets-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_29,29 WHERE @path_php IS NOT NULL AND @e_php_29 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_29,'([]{})','Yes',1,1 WHERE @e_php_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_29 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_29,'([)]','No',0,2 WHERE @e_php_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_29 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_29,'((()))','Yes',0,3 WHERE @e_php_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_29 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_29,'}{','No',0,4 WHERE @e_php_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_29 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'PHP 30 - FizzBuzz',CONCAT('ca-php-path-30-fizzbuzz-t', @teacher_id),'For every integer from 1 through N, print FizzBuzz if divisible by both 3 and 5, Fizz if divisible by 3, Buzz if divisible by 5, otherwise print the number. Print one result per line.

Input: One integer N, where 1 ≤ N ≤ 100.
Output: N lines.
Hint: Check divisibility by 15 before 3 or 5.

Learning path: PHP Foundations. Write your solution using PHP. Read standard input and print only the required output.','Medium','Problem Solving',1080,100,'<?php
// TODO: solve the problem. Read from STDIN and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_php_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-php-path-30-fizzbuzz-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_php,@e_php_30,30 WHERE @path_php IS NOT NULL AND @e_php_30 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_30,'5','1
2
Fizz
4
Buzz',1,1 WHERE @e_php_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_30 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_30,'1','1',0,2 WHERE @e_php_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_30 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_30,'15','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz',0,3 WHERE @e_php_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_30 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_php_30,'16','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16',0,4 WHERE @e_php_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_php_30 AND sort_order=4);

-- Ruby: 30 language-specific exercises and test cases.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 01 - Hello, CodeArena!',CONCAT('ca-ruby-path-01-hello-codearena-t', @teacher_id),'Print exactly the text Hello, CodeArena! followed by a newline.

Input: No input is provided.
Output: Hello, CodeArena!
Hint: Start by testing your language''s standard output statement.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Output',300,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-01-hello-codearena-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_01,1 WHERE @path_ruby IS NOT NULL AND @e_ruby_01 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_01,'','Hello, CodeArena!',1,1 WHERE @e_ruby_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_01 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_01,'','Hello, CodeArena!',0,2 WHERE @e_ruby_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_01 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_01,'','Hello, CodeArena!',0,3 WHERE @e_ruby_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_01 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_01,'','Hello, CodeArena!',0,4 WHERE @e_ruby_01 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_01 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 02 - Add Two Integers',CONCAT('ca-ruby-path-02-add-two-integers-t', @teacher_id),'Read two integers and print their sum. The integers can be separated by spaces or newlines.

Input: Two integers a and b, each from -100000 to 100000.
Output: The value a + b.
Hint: Convert both inputs to integers before adding.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Input & Variables',480,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-02-add-two-integers-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_02,2 WHERE @path_ruby IS NOT NULL AND @e_ruby_02 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_02,'3 5','8',1,1 WHERE @e_ruby_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_02 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_02,'-4 9','5',0,2 WHERE @e_ruby_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_02 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_02,'0 0','0',0,3 WHERE @e_ruby_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_02 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_02,'100 -25','75',0,4 WHERE @e_ruby_02 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_02 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 03 - Rectangle Area',CONCAT('ca-ruby-path-03-rectangle-area-t', @teacher_id),'Read the width and height of a rectangle and print its area.

Input: Two non-negative integers w and h, each at most 1000.
Output: w multiplied by h.
Hint: Area = width × height.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Arithmetic',480,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-03-rectangle-area-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_03,3 WHERE @path_ruby IS NOT NULL AND @e_ruby_03 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_03,'4 6','24',1,1 WHERE @e_ruby_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_03 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_03,'1 9','9',0,2 WHERE @e_ruby_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_03 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_03,'12 12','144',0,3 WHERE @e_ruby_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_03 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_03,'0 12','0',0,4 WHERE @e_ruby_03 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_03 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 04 - Even or Odd',CONCAT('ca-ruby-path-04-even-or-odd-t', @teacher_id),'Read an integer. Print Even if it is divisible by 2; otherwise print Odd. Handle negative numbers and zero.

Input: One integer n.
Output: Exactly Even or Odd.
Hint: Use the remainder operator.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Conditionals',480,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-04-even-or-odd-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_04,4 WHERE @path_ruby IS NOT NULL AND @e_ruby_04 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_04,'7','Odd',1,1 WHERE @e_ruby_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_04 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_04,'8','Even',0,2 WHERE @e_ruby_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_04 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_04,'0','Even',0,3 WHERE @e_ruby_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_04 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_04,'-3','Odd',0,4 WHERE @e_ruby_04 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_04 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 05 - Sum from 1 to N',CONCAT('ca-ruby-path-05-sum-one-to-n-t', @teacher_id),'Read a positive integer N and calculate 1 + 2 + ... + N.

Input: One integer N, where 1 ≤ N ≤ 100000.
Output: The sum as an integer.
Hint: Use a loop and a running total.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Loops',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-05-sum-one-to-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_05,5 WHERE @path_ruby IS NOT NULL AND @e_ruby_05 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_05,'5','15',1,1 WHERE @e_ruby_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_05 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_05,'1','1',0,2 WHERE @e_ruby_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_05 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_05,'10','55',0,3 WHERE @e_ruby_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_05 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_05,'100000','5000050000',0,4 WHERE @e_ruby_05 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_05 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 06 - Largest of Three',CONCAT('ca-ruby-path-06-largest-of-three-t', @teacher_id),'Read three integers and print the largest. If values are tied, print the tied value.

Input: Three integers separated by whitespace.
Output: The maximum value.
Hint: Compare all three values, including when they are equal or negative.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Conditionals',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-06-largest-of-three-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_06,6 WHERE @path_ruby IS NOT NULL AND @e_ruby_06 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_06,'12 25 8','25',1,1 WHERE @e_ruby_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_06 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_06,'-4 -2 -9','-2',0,2 WHERE @e_ruby_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_06 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_06,'7 7 2','7',0,3 WHERE @e_ruby_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_06 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_06,'0 0 0','0',0,4 WHERE @e_ruby_06 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_06 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 07 - Count the Vowels',CONCAT('ca-ruby-path-07-count-vowels-t', @teacher_id),'Read one word and count the vowels a, e, i, o, u. Count uppercase and lowercase vowels.

Input: One word containing English letters.
Output: One integer, the vowel count.
Hint: Check every character against the five vowels.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Strings',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-07-count-vowels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_07,7 WHERE @path_ruby IS NOT NULL AND @e_ruby_07 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_07,'Programming','3',1,1 WHERE @e_ruby_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_07 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_07,'sky','0',0,2 WHERE @e_ruby_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_07 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_07,'EDUCATION','5',0,3 WHERE @e_ruby_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_07 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_07,'CodeArena','5',0,4 WHERE @e_ruby_07 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_07 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 08 - Calculate Factorial',CONCAT('ca-ruby-path-08-factorial-t', @teacher_id),'Calculate N!, the product of all integers from 1 to N. By definition, 0! = 1.

Input: One integer N, where 0 ≤ N ≤ 12.
Output: N! as an integer.
Hint: Start the product at 1.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Loops',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-08-factorial-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_08,8 WHERE @path_ruby IS NOT NULL AND @e_ruby_08 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_08,'5','120',1,1 WHERE @e_ruby_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_08 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_08,'0','1',0,2 WHERE @e_ruby_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_08 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_08,'1','1',0,3 WHERE @e_ruby_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_08 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_08,'10','3628800',0,4 WHERE @e_ruby_08 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_08 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 09 - Reverse a Number',CONCAT('ca-ruby-path-09-reverse-number-t', @teacher_id),'Read a non-negative integer and print its digits in reverse order. Leading zeros in the reversed result are omitted.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: The reversed integer.
Hint: Use remainder by 10 and integer division by 10.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-09-reverse-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_09,9 WHERE @path_ruby IS NOT NULL AND @e_ruby_09 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_09,'12340','4321',1,1 WHERE @e_ruby_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_09 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_09,'7','7',0,2 WHERE @e_ruby_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_09 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_09,'1000','1',0,3 WHERE @e_ruby_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_09 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_09,'908','809',0,4 WHERE @e_ruby_09 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_09 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 10 - First Ten Multiples',CONCAT('ca-ruby-path-10-multiples-of-n-t', @teacher_id),'Read an integer N and print its first ten positive multiples on one line, separated by a single space.

Input: One integer N, where 1 ≤ N ≤ 1000.
Output: N, 2N, ..., 10N. Do not print extra labels.
Hint: Repeat a multiplication for i from 1 through 10.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Loops',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-10-multiples-of-n-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_10,10 WHERE @path_ruby IS NOT NULL AND @e_ruby_10 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_10,'3','3 6 9 12 15 18 21 24 27 30',1,1 WHERE @e_ruby_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_10 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_10,'1','1 2 3 4 5 6 7 8 9 10',0,2 WHERE @e_ruby_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_10 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_10,'5','5 10 15 20 25 30 35 40 45 50',0,3 WHERE @e_ruby_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_10 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_10,'10','10 20 30 40 50 60 70 80 90 100',0,4 WHERE @e_ruby_10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_10 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 11 - Count Digits',CONCAT('ca-ruby-path-11-count-digits-t', @teacher_id),'Count how many decimal digits are in a non-negative integer. Zero has one digit.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Number of digits.
Hint: Repeatedly divide by 10 or convert to a string.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-11-count-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_11,11 WHERE @path_ruby IS NOT NULL AND @e_ruby_11 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_11,'0','1',1,1 WHERE @e_ruby_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_11 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_11,'9','1',0,2 WHERE @e_ruby_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_11 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_11,'12034','5',0,3 WHERE @e_ruby_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_11 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_11,'1000000000','10',0,4 WHERE @e_ruby_11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_11 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 12 - Palindrome Number',CONCAT('ca-ruby-path-12-palindrome-number-t', @teacher_id),'Determine whether a non-negative integer reads the same forward and backward. Print Yes or No.

Input: One integer N.
Output: Yes if it is a palindrome; otherwise No.
Hint: Compare the number with its reversed digits.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Number Manipulation',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-12-palindrome-number-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_12,12 WHERE @path_ruby IS NOT NULL AND @e_ruby_12 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_12,'121','Yes',1,1 WHERE @e_ruby_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_12 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_12,'123','No',0,2 WHERE @e_ruby_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_12 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_12,'7','Yes',0,3 WHERE @e_ruby_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_12 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_12,'100','No',0,4 WHERE @e_ruby_12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_12 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 13 - Prime Number Check',CONCAT('ca-ruby-path-13-prime-check-t', @teacher_id),'Check whether N is a prime number. A prime is an integer greater than 1 with exactly two positive divisors.

Input: One integer N, where 0 ≤ N ≤ 1000000.
Output: Prime or Not Prime.
Hint: Check possible divisors only up to the square root of N.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Number Theory',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-13-prime-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_13,13 WHERE @path_ruby IS NOT NULL AND @e_ruby_13 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_13,'17','Prime',1,1 WHERE @e_ruby_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_13 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_13,'1','Not Prime',0,2 WHERE @e_ruby_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_13 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_13,'2','Prime',0,3 WHERE @e_ruby_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_13 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_13,'100','Not Prime',0,4 WHERE @e_ruby_13 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_13 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 14 - Sum of Digits',CONCAT('ca-ruby-path-14-sum-digits-t', @teacher_id),'Read a non-negative integer and print the sum of its digits.

Input: One integer N, where 0 ≤ N ≤ 1000000000.
Output: Sum of all decimal digits.
Hint: Extract each last digit with remainder by 10.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Number Manipulation',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-14-sum-digits-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_14,14 WHERE @path_ruby IS NOT NULL AND @e_ruby_14 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_14,'1234','10',1,1 WHERE @e_ruby_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_14 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_14,'0','0',0,2 WHERE @e_ruby_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_14 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_14,'999','27',0,3 WHERE @e_ruby_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_14 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_14,'10005','6',0,4 WHERE @e_ruby_14 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_14 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 15 - Nth Fibonacci Number',CONCAT('ca-ruby-path-15-fibonacci-nth-t', @teacher_id),'Use the sequence F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2). Print F(N).

Input: One integer N, where 0 ≤ N ≤ 45.
Output: F(N).
Hint: Build the sequence iteratively instead of using slow recursion.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Sequences',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-15-fibonacci-nth-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_15,15 WHERE @path_ruby IS NOT NULL AND @e_ruby_15 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_15,'0','0',1,1 WHERE @e_ruby_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_15 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_15,'1','1',0,2 WHERE @e_ruby_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_15 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_15,'10','55',0,3 WHERE @e_ruby_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_15 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_15,'45','1134903170',0,4 WHERE @e_ruby_15 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_15 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 16 - Greatest Common Divisor',CONCAT('ca-ruby-path-16-greatest-common-divisor-t', @teacher_id),'Read two positive integers and print their greatest common divisor (GCD).

Input: Positive integers a and b, each at most 1000000000.
Output: gcd(a, b).
Hint: Use the Euclidean algorithm.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Number Theory',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-16-greatest-common-divisor-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_16,16 WHERE @path_ruby IS NOT NULL AND @e_ruby_16 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_16,'12 18','6',1,1 WHERE @e_ruby_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_16 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_16,'7 13','1',0,2 WHERE @e_ruby_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_16 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_16,'100 80','20',0,3 WHERE @e_ruby_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_16 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_16,'1 1','1',0,4 WHERE @e_ruby_16 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_16 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 17 - Least Common Multiple',CONCAT('ca-ruby-path-17-least-common-multiple-t', @teacher_id),'Read two positive integers and print their least common multiple (LCM).

Input: Positive integers a and b, each at most 100000.
Output: lcm(a, b).
Hint: lcm(a,b) = a / gcd(a,b) × b.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Number Theory',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-17-least-common-multiple-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_17,17 WHERE @path_ruby IS NOT NULL AND @e_ruby_17 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_17,'4 6','12',1,1 WHERE @e_ruby_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_17 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_17,'7 5','35',0,2 WHERE @e_ruby_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_17 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_17,'12 18','36',0,3 WHERE @e_ruby_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_17 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_17,'1 999','999',0,4 WHERE @e_ruby_17 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_17 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 18 - Reverse a Word',CONCAT('ca-ruby-path-18-reverse-word-t', @teacher_id),'Read one word and print its characters in reverse order. Preserve each character''s case.

Input: One word of English letters.
Output: The reversed word.
Hint: Walk from the final character to the first.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Strings',600,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-18-reverse-word-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_18,18 WHERE @path_ruby IS NOT NULL AND @e_ruby_18 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_18,'CodeArena','anerAedoC',1,1 WHERE @e_ruby_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_18 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_18,'hello','olleh',0,2 WHERE @e_ruby_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_18 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_18,'a','a',0,3 WHERE @e_ruby_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_18 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_18,'Ruby','ybuR',0,4 WHERE @e_ruby_18 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_18 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 19 - Count Words in a Sentence',CONCAT('ca-ruby-path-19-count-words-t', @teacher_id),'Read one complete line and count its whitespace-separated words. Repeated spaces should not create empty words.

Input: One non-empty line.
Output: Number of words.
Hint: Trim the line and split on one or more whitespace characters.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Strings',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-19-count-words-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_19,19 WHERE @path_ruby IS NOT NULL AND @e_ruby_19 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_19,'Code Arena is fun','4',1,1 WHERE @e_ruby_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_19 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_19,'one','1',0,2 WHERE @e_ruby_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_19 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_19,'  many   spaces here  ','3',0,3 WHERE @e_ruby_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_19 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_19,'Learn to code every day','5',0,4 WHERE @e_ruby_19 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_19 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 20 - Maximum in an Array',CONCAT('ca-ruby-path-20-array-maximum-t', @teacher_id),'Read N integers and print the maximum value.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: The maximum integer.
Hint: Initialize the maximum from the first value.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Arrays',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-20-array-maximum-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_20,20 WHERE @path_ruby IS NOT NULL AND @e_ruby_20 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_20,'5 3 9 1 9 4','9',1,1 WHERE @e_ruby_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_20 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_20,'4 -8 -3 -10 -5','-3',0,2 WHERE @e_ruby_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_20 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_20,'1 42','42',0,3 WHERE @e_ruby_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_20 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_20,'3 0 0 -1','0',0,4 WHERE @e_ruby_20 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_20 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 21 - Count Positive Numbers',CONCAT('ca-ruby-path-21-count-positive-t', @teacher_id),'Count how many values in a list are strictly greater than zero. Zero is not positive.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Count of positive values.
Hint: Increase the counter only when value > 0.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Arrays',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-21-count-positive-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_21,21 WHERE @path_ruby IS NOT NULL AND @e_ruby_21 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_21,'5 -3 2 0 7 -1','2',1,1 WHERE @e_ruby_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_21 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_21,'4 1 2 3 4','4',0,2 WHERE @e_ruby_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_21 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_21,'3 -1 0 -9','0',0,3 WHERE @e_ruby_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_21 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_21,'1 100','1',0,4 WHERE @e_ruby_21 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_21 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 22 - Second Largest Distinct Number',CONCAT('ca-ruby-path-22-second-largest-distinct-t', @teacher_id),'Find the second-largest distinct value in a list. Inputs are guaranteed to contain at least two distinct values.

Input: N followed by N integers, where 2 ≤ N ≤ 1000.
Output: The second-largest distinct number.
Hint: Track the largest and second-largest distinct values.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Arrays',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-22-second-largest-distinct-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_22,22 WHERE @path_ruby IS NOT NULL AND @e_ruby_22 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_22,'6 4 1 9 7 9 3','7',1,1 WHERE @e_ruby_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_22 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_22,'3 1 2 3','2',0,2 WHERE @e_ruby_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_22 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_22,'5 -5 -1 -1 -3 -2','-2',0,3 WHERE @e_ruby_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_22 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_22,'4 10 10 9 8','9',0,4 WHERE @e_ruby_22 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_22 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 23 - Linear Search',CONCAT('ca-ruby-path-23-linear-search-t', @teacher_id),'Find the first zero-based index of target in an integer array. Print -1 when it is absent.

Input: N, then N integers, then target.
Output: First matching index, or -1.
Hint: Scan the list from left to right.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Easy','Searching',720,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-23-linear-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_23,23 WHERE @path_ruby IS NOT NULL AND @e_ruby_23 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_23,'5 3 9 1 8 4 9','1',1,1 WHERE @e_ruby_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_23 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_23,'3 1 2 3 4','-1',0,2 WHERE @e_ruby_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_23 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_23,'4 7 7 7 7 7','0',0,3 WHERE @e_ruby_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_23 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_23,'1 5 5','0',0,4 WHERE @e_ruby_23 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_23 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 24 - Binary Search',CONCAT('ca-ruby-path-24-binary-search-t', @teacher_id),'Search a sorted ascending array and print the first zero-based index of target, or -1 if absent. If duplicates exist, return the first index.

Input: N, then N sorted integers, then target.
Output: First matching index, or -1.
Hint: Use left and right boundaries; continue left after a match.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Searching',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-24-binary-search-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_24,24 WHERE @path_ruby IS NOT NULL AND @e_ruby_24 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_24,'6 1 2 4 4 7 9 4','2',1,1 WHERE @e_ruby_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_24 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_24,'5 1 3 5 7 9 6','-1',0,2 WHERE @e_ruby_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_24 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_24,'4 2 2 2 2 2','0',0,3 WHERE @e_ruby_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_24 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_24,'1 9 9','0',0,4 WHERE @e_ruby_24 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_24 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 25 - Sort Numbers Ascending',CONCAT('ca-ruby-path-25-sort-ascending-t', @teacher_id),'Sort N integers in ascending order and print them on one line separated by a single space.

Input: N followed by N integers, where 1 ≤ N ≤ 1000.
Output: Sorted integers.
Hint: Use a built-in sort or implement a sorting algorithm.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Sorting',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-25-sort-ascending-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_25,25 WHERE @path_ruby IS NOT NULL AND @e_ruby_25 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_25,'5 3 1 4 1 2','1 1 2 3 4',1,1 WHERE @e_ruby_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_25 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_25,'3 9 -1 0','-1 0 9',0,2 WHERE @e_ruby_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_25 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_25,'1 7','7',0,3 WHERE @e_ruby_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_25 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_25,'4 5 5 5 5','5 5 5 5',0,4 WHERE @e_ruby_25 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_25 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 26 - Remove Duplicates, Keep Order',CONCAT('ca-ruby-path-26-remove-duplicates-t', @teacher_id),'Remove repeated values while preserving the first occurrence of each value. Print the remaining values separated by one space.

Input: N followed by N integers.
Output: Unique values in original order.
Hint: Keep a set of values already seen and a separate output list.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Arrays',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-26-remove-duplicates-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_26,26 WHERE @path_ruby IS NOT NULL AND @e_ruby_26 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_26,'7 3 3 1 2 1 4 2','3 1 2 4',1,1 WHERE @e_ruby_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_26 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_26,'4 5 5 5 5','5',0,2 WHERE @e_ruby_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_26 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_26,'5 1 2 3 4 5','1 2 3 4 5',0,3 WHERE @e_ruby_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_26 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_26,'6 0 -1 0 -1 2 2','0 -1 2',0,4 WHERE @e_ruby_26 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_26 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 27 - Character Frequency',CONCAT('ca-ruby-path-27-character-frequency-t', @teacher_id),'Read a word and a single character, then count exact case-sensitive occurrences of that character in the word.

Input: A word and a character separated by whitespace.
Output: Number of occurrences.
Hint: Compare each character of the word with the target character.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Strings',900,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-27-character-frequency-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_27,27 WHERE @path_ruby IS NOT NULL AND @e_ruby_27 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_27,'banana a','3',1,1 WHERE @e_ruby_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_27 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_27,'CodeArena a','1',0,2 WHERE @e_ruby_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_27 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_27,'hello z','0',0,3 WHERE @e_ruby_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_27 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_27,'AAAA A','4',0,4 WHERE @e_ruby_27 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_27 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 28 - Anagram Check',CONCAT('ca-ruby-path-28-anagram-check-t', @teacher_id),'Determine whether two lowercase words contain exactly the same letters with the same frequencies. Print Yes or No.

Input: Two lowercase words.
Output: Yes if they are anagrams; otherwise No.
Hint: Compare sorted letters or letter-frequency counts.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Strings',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-28-anagram-check-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_28,28 WHERE @path_ruby IS NOT NULL AND @e_ruby_28 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_28,'listen silent','Yes',1,1 WHERE @e_ruby_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_28 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_28,'apple paple','Yes',0,2 WHERE @e_ruby_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_28 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_28,'hello world','No',0,3 WHERE @e_ruby_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_28 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_28,'ab ba','Yes',0,4 WHERE @e_ruby_28 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_28 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 29 - Balanced Brackets',CONCAT('ca-ruby-path-29-balanced-brackets-t', @teacher_id),'Check whether a string containing only (), [], and {} has correctly matched and nested brackets. Print Yes or No.

Input: A non-empty string of bracket characters.
Output: Yes if balanced; otherwise No.
Hint: Use a stack to remember opening brackets.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Stacks',1200,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-29-balanced-brackets-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_29,29 WHERE @path_ruby IS NOT NULL AND @e_ruby_29 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_29,'([]{})','Yes',1,1 WHERE @e_ruby_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_29 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_29,'([)]','No',0,2 WHERE @e_ruby_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_29 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_29,'((()))','Yes',0,3 WHERE @e_ruby_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_29 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_29,'}{','No',0,4 WHERE @e_ruby_29 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_29 AND sort_order=4);
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'Ruby 30 - FizzBuzz',CONCAT('ca-ruby-path-30-fizzbuzz-t', @teacher_id),'For every integer from 1 through N, print FizzBuzz if divisible by both 3 and 5, Fizz if divisible by 3, Buzz if divisible by 5, otherwise print the number. Print one result per line.

Input: One integer N, where 1 ≤ N ≤ 100.
Output: N lines.
Hint: Check divisibility by 15 before 3 or 5.

Learning path: Ruby Foundations. Write your solution using Ruby. Read standard input and print only the required output.','Medium','Problem Solving',1080,100,'# TODO: solve the problem. Read from standard input and print only the required output.
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_ruby_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-ruby-path-30-fizzbuzz-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_ruby,@e_ruby_30,30 WHERE @path_ruby IS NOT NULL AND @e_ruby_30 IS NOT NULL;
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_30,'5','1
2
Fizz
4
Buzz',1,1 WHERE @e_ruby_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_30 AND sort_order=1);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_30,'1','1',0,2 WHERE @e_ruby_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_30 AND sort_order=2);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_30,'15','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz',0,3 WHERE @e_ruby_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_30 AND sort_order=3);
INSERT INTO test_cases(exercise_id,stdin,expected_output,is_sample,sort_order) SELECT @e_ruby_30,'16','1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16',0,4 WHERE @e_ruby_30 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM test_cases WHERE exercise_id=@e_ruby_30 AND sort_order=4);

-- HTML/CSS: 30 preview-only web projects. Progress is completed by student self-attestation after preview.
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 01 - Semantic HTML Page',CONCAT('ca-htmlcss-path-01-semantic-html-page-t', @teacher_id),'HTML/CSS Preview Project 01: Create a semantic document using header, nav, main, section, and footer. Keep the content in a sensible reading order.

Project checklist:
- Use semantic elements instead of div for every region.
- Include a clear page title.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Semantic HTML Page</title>
<style>
:root { --accent: #6554d9; --tint: #f2f0ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<header><p class="eyebrow">CODEARENA · WEB BASICS</p><h1>My semantic page</h1></header><nav aria-label="Main navigation"><a href="#about">About</a> <a href="#work">Work</a></nav><main><section id="about"><h2>About this page</h2><p>Replace this text with your introduction.</p></section><section id="work"><h2>My work</h2><p>Add a short section here.</p></section></main><footer>Created while learning HTML and CSS.</footer>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_01 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-01-semantic-html-page-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_01,1 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_01 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 02 - Headings and Paragraphs',CONCAT('ca-htmlcss-path-02-headings-and-paragraphs-t', @teacher_id),'HTML/CSS Preview Project 02: Create a short article with one h1, at least two h2 headings, and readable paragraphs.

Project checklist:
- Use a logical heading hierarchy.
- Set a comfortable line-height.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Headings and Paragraphs</title>
<style>
:root { --accent: #2366a8; --tint: #edf6ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><article><p class="eyebrow">ARTICLE · 4 MIN READ</p><h1>A small story</h1><p class="lead">Write a short introduction to your article.</p><h2>First idea</h2><p>Add a paragraph that explains the first idea.</p><h2>Another idea</h2><p>Add another paragraph and keep the reading order clear.</p></article></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_02 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-02-headings-and-paragraphs-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_02,2 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_02 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 03 - Personal Profile Card',CONCAT('ca-htmlcss-path-03-personal-profile-card-t', @teacher_id),'HTML/CSS Preview Project 03: Build a profile card with name, role, short bio, and three skill tags.

Project checklist:
- Keep the card readable on narrow screens.
- Use spacing, border, and shadow thoughtfully.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Personal Profile Card</title>
<style>
:root { --accent: #0f766e; --tint: #e8f8f5; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="profile"><div class="avatar" aria-hidden="true">CA</div><p class="eyebrow">PROFILE</p><h1>Your Name</h1><p class="role">Aspiring developer</p><p>Write a short two-sentence introduction about yourself.</p><div class="tags"><span>HTML</span><span>CSS</span><span>Learning</span></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_03 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-03-personal-profile-card-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_03,3 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_03 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 04 - Navigation Bar',CONCAT('ca-htmlcss-path-04-navigation-bar-t', @teacher_id),'HTML/CSS Preview Project 04: Build a responsive-looking navigation row with a brand and three navigation links.

Project checklist:
- Use flexbox.
- Provide a visible focus style for links.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Navigation Bar</title>
<style>
:root { --accent: #b45309; --tint: #fff5e6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<header class="nav"><a class="brand" href="#home">CodeArena</a><nav aria-label="Main navigation"><a href="#learn">Learn</a><a href="#practice">Practice</a><a href="#about">About</a></nav><a class="nav-cta" href="#start">Get started</a></header><main id="home"><h1>A navigation bar that guides the way</h1><p>Resize the preview and improve how the links fit.</p></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_04 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-04-navigation-bar-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_04,4 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_04 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 05 - Button Collection',CONCAT('ca-htmlcss-path-05-button-collection-t', @teacher_id),'HTML/CSS Preview Project 05: Design primary, secondary, and outline button styles using CSS classes.

Project checklist:
- Reuse shared button styles.
- Add hover and focus states.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Button Collection</title>
<style>
:root { --accent: #9d174d; --tint: #fff0f6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><h1>Button collection</h1><p>Buttons should look clickable and have clear focus styles.</p><div class="button-row"><button class="btn primary">Primary action</button><button class="btn secondary">Secondary</button><button class="btn outline">Outline</button></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_05 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-05-button-collection-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_05,5 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_05 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 06 - Accessible Contact Form',CONCAT('ca-htmlcss-path-06-accessible-contact-form-t', @teacher_id),'HTML/CSS Preview Project 06: Create a contact form with name, email, and message fields with properly associated labels.

Project checklist:
- Use label-for and matching input IDs.
- Use appropriate input types.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Accessible Contact Form</title>
<style>
:root { --accent: #6554d9; --tint: #f2f0ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="form-card"><h1>Contact us</h1><p>We would love to hear from you.</p><form><label for="name">Full name</label><input id="name" name="name" placeholder="Your name" required><label for="email">Email address</label><input id="email" name="email" type="email" placeholder="you@example.com" required><label for="message">Message</label><textarea id="message" name="message" rows="4" placeholder="How can we help?"></textarea><button class="btn primary" type="submit">Send message</button></form></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_06 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-06-accessible-contact-form-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_06,6 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_06 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 07 - Sign-in Card',CONCAT('ca-htmlcss-path-07-sign-in-card-t', @teacher_id),'HTML/CSS Preview Project 07: Create a mock sign-in card with email and password fields and a submit button. This is a visual exercise, not a real authentication form.

Project checklist:
- Keep labels visible.
- Make the form width comfortable.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sign-in Card</title>
<style>
:root { --accent: #2366a8; --tint: #edf6ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="form-card"><p class="eyebrow">WELCOME BACK</p><h1>Sign in</h1><p>This is a visual mockup only.</p><form><label for="email">Email</label><input id="email" type="email" placeholder="you@example.com"><label for="password">Password</label><input id="password" type="password" placeholder="Enter password"><button class="btn primary" type="button">Continue</button></form><small>Build a clear and accessible form.</small></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_07 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-07-sign-in-card-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_07,7 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_07 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 08 - Pricing Card',CONCAT('ca-htmlcss-path-08-pricing-card-t', @teacher_id),'HTML/CSS Preview Project 08: Create a plan card with plan name, price, feature list, and a call-to-action button.

Project checklist:
- Emphasize the price.
- Use a semantic list for features.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pricing Card</title>
<style>
:root { --accent: #0f766e; --tint: #e8f8f5; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="pricing"><p class="eyebrow">SIMPLE PRICING</p><h1>Choose your plan</h1><section class="price-card"><h2>Starter</h2><p class="price">₱0 <small>/ month</small></p><p>Everything you need to begin.</p><ul><li>Practice challenges</li><li>Progress tracking</li><li>Community learning</li></ul><a class="btn primary" href="#start">Start learning</a></section></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_08 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-08-pricing-card-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_08,8 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_08 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 09 - Product Card',CONCAT('ca-htmlcss-path-09-product-card-t', @teacher_id),'HTML/CSS Preview Project 09: Build a product card with a CSS-made color swatch, product name, description, and price.

Project checklist:
- Align content consistently.
- Use a responsive maximum width.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Product Card</title>
<style>
:root { --accent: #b45309; --tint: #fff5e6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="product-card"><div class="swatch" aria-hidden="true"></div><p class="eyebrow">FEATURED ITEM</p><h1>Everyday notebook</h1><p>A simple product description that explains its main benefit.</p><div class="product-bottom"><strong>₱249</strong><button class="btn primary" type="button">View details</button></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_09 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-09-product-card-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_09,9 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_09 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 10 - Landing Page Hero',CONCAT('ca-htmlcss-path-10-landing-page-hero-t', @teacher_id),'HTML/CSS Preview Project 10: Create a hero section with an eyebrow label, headline, description, and primary action.

Project checklist:
- Create strong text hierarchy.
- Use whitespace to guide attention.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',600,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Landing Page Hero</title>
<style>
:root { --accent: #9d174d; --tint: #fff0f6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="hero"><p class="eyebrow">LEARN · BUILD · SHARE</p><h1>Make your next idea real.</h1><p class="lead">A strong hero explains what a product does and why it matters in a few clear lines.</p><div class="button-row"><a class="btn primary" href="#features">Explore features</a><a class="btn secondary" href="#learn">How it works</a></div><p class="note">Made for curious beginners.</p></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_10 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-10-landing-page-hero-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_10,10 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_10 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 11 - Feature Grid',CONCAT('ca-htmlcss-path-11-feature-grid-t', @teacher_id),'HTML/CSS Preview Project 11: Display three feature cards with a small symbol, title, and description.

Project checklist:
- Use CSS grid.
- Keep equal gaps between cards.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Feature Grid</title>
<style>
:root { --accent: #6554d9; --tint: #f2f0ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">WHAT YOU GET</p><h1>Features that help you grow</h1><div class="feature-grid"><article><span>01</span><h2>Learn</h2><p>Build a strong foundation.</p></article><article><span>02</span><h2>Practice</h2><p>Turn ideas into skills.</p></article><article><span>03</span><h2>Improve</h2><p>Learn from every attempt.</p></article></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_11 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-11-feature-grid-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_11,11 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_11 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 12 - Testimonial Card',CONCAT('ca-htmlcss-path-12-testimonial-card-t', @teacher_id),'HTML/CSS Preview Project 12: Create a testimonial with quote, author name, and role.

Project checklist:
- Use blockquote where appropriate.
- Make muted text readable.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Testimonial Card</title>
<style>
:root { --accent: #2366a8; --tint: #edf6ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="quote-card"><p class="eyebrow">STUDENT STORY</p><blockquote>“Small, consistent practice made programming feel possible.”</blockquote><div class="author"><div class="avatar">AJ</div><div><strong>Alex Johnson</strong><small>Beginner developer</small></div></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_12 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-12-testimonial-card-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_12,12 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_12 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 13 - FAQ Section',CONCAT('ca-htmlcss-path-13-faq-section-t', @teacher_id),'HTML/CSS Preview Project 13: Create three FAQ entries using details and summary so they expand without JavaScript.

Project checklist:
- Use details and summary.
- Style the disclosure marker and spacing.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FAQ Section</title>
<style>
:root { --accent: #0f766e; --tint: #e8f8f5; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">HELP CENTER</p><h1>Frequently asked questions</h1><section class="faq"><details open><summary>How do I get started?</summary><p>Begin with the first lesson and follow the steps.</p></details><details><summary>Can I practise more than once?</summary><p>Yes. Repeating practice is part of learning.</p></details><details><summary>Where can I see progress?</summary><p>Open your learning dashboard to review progress.</p></details></section></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_13 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-13-faq-section-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_13,13 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_13 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 14 - Two-column Layout',CONCAT('ca-htmlcss-path-14-two-column-layout-t', @teacher_id),'HTML/CSS Preview Project 14: Build a main-content and sidebar layout that stacks on a narrow screen.

Project checklist:
- Use CSS grid or flexbox.
- Include a mobile media query.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Two-column Layout</title>
<style>
:root { --accent: #b45309; --tint: #fff5e6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="two-col"><article><p class="eyebrow">MAIN CONTENT</p><h1>A flexible two-column layout</h1><p>The main area should receive more space for the article or primary task.</p><p>Add another paragraph to see how the content flows.</p></article><aside><h2>On this page</h2><ul><li>Overview</li><li>Details</li><li>Resources</li></ul></aside></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_14 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-14-two-column-layout-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_14,14 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_14 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 15 - CSS Color Variables',CONCAT('ca-htmlcss-path-15-css-color-variables-t', @teacher_id),'HTML/CSS Preview Project 15: Define a small palette using CSS custom properties and use the variables across a card layout.

Project checklist:
- Define variables on :root.
- Use variables for text, surface, accent, and border.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Easy','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CSS Color Variables</title>
<style>
:root { --accent: #9d174d; --tint: #fff0f6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">DESIGN TOKENS</p><h1>Colour palette</h1><div class="palette"><div><span class="swatch accent"></span><strong>Accent</strong><small>#6554D9</small></div><div><span class="swatch surface"></span><strong>Surface</strong><small>#FFFFFF</small></div><div><span class="swatch tint"></span><strong>Tint</strong><small>#F2F0FF</small></div></div><p>Use CSS variables so the palette can be changed in one place.</p></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_15 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-15-css-color-variables-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_15,15 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_15 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 16 - Typography Scale',CONCAT('ca-htmlcss-path-16-typography-scale-t', @teacher_id),'HTML/CSS Preview Project 16: Create a heading, subheading, body text, and small caption with a consistent type scale.

Project checklist:
- Use relative font sizes.
- Maintain sufficient contrast and line-height.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Typography Scale</title>
<style>
:root { --accent: #6554d9; --tint: #f2f0ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="type-sample"><p class="eyebrow">TYPE SCALE</p><h1>Heading one</h1><h2>Heading two</h2><h3>Heading three</h3><p class="lead">Lead paragraph for introductions.</p><p>Body text should be comfortable to read across devices and line lengths.</p><small>Caption text for supporting detail.</small></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_16 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-16-typography-scale-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_16,16 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_16 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 17 - Spacing System',CONCAT('ca-htmlcss-path-17-spacing-system-t', @teacher_id),'HTML/CSS Preview Project 17: Build a simple panel using a consistent spacing scale instead of arbitrary margins everywhere.

Project checklist:
- Use CSS custom properties for spacing.
- Keep padding consistent.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Spacing System</title>
<style>
:root { --accent: #2366a8; --tint: #edf6ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">SPACING SYSTEM</p><h1>Consistent spacing</h1><section class="spacing-card"><span>Compact spacing</span><p>Keep related items close.</p></section><section class="spacing-card roomy"><span>Roomy spacing</span><p>Use extra space between separate groups.</p></section></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_17 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-17-spacing-system-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_17,17 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_17 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 18 - CSS Gallery Grid',CONCAT('ca-htmlcss-path-18-css-gallery-grid-t', @teacher_id),'HTML/CSS Preview Project 18: Create a six-tile gallery using gradient backgrounds and captions, with a responsive grid.

Project checklist:
- Use grid-template-columns.
- Make each tile maintain a useful shape.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CSS Gallery Grid</title>
<style>
:root { --accent: #0f766e; --tint: #e8f8f5; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">GALLERY</p><h1>Gradient gallery</h1><p>Use CSS gradients as simple image placeholders.</p><div class="gallery"><figure><div class="art art-one"></div><figcaption>Morning</figcaption></figure><figure><div class="art art-two"></div><figcaption>Ocean</figcaption></figure><figure><div class="art art-three"></div><figcaption>Garden</figcaption></figure><figure><div class="art art-four"></div><figcaption>Sunset</figcaption></figure><figure><div class="art art-five"></div><figcaption>Sky</figcaption></figure><figure><div class="art art-six"></div><figcaption>Night</figcaption></figure></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_18 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-18-css-gallery-grid-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_18,18 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_18 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 19 - Status Badges',CONCAT('ca-htmlcss-path-19-status-badges-t', @teacher_id),'HTML/CSS Preview Project 19: Design success, warning, information, and error badges with text labels and clear contrast.

Project checklist:
- Do not rely on color alone.
- Use consistent padding and radius.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Status Badges</title>
<style>
:root { --accent: #b45309; --tint: #fff5e6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">COMPONENTS</p><h1>Status badges</h1><p>Use both colour and text to communicate state.</p><div class="badge-row"><span class="badge success">Success</span><span class="badge warning">Needs review</span><span class="badge info">Information</span><span class="badge error">Error</span></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_19 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-19-status-badges-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_19,19 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_19 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 20 - Accessible Data Table',CONCAT('ca-htmlcss-path-20-accessible-data-table-t', @teacher_id),'HTML/CSS Preview Project 20: Create a small table with a caption, header row, and three data rows.

Project checklist:
- Use caption, thead, th, and tbody.
- Make borders and row spacing readable.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Accessible Data Table</title>
<style>
:root { --accent: #9d174d; --tint: #fff0f6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">CLASS RECORD</p><h1>Recent submissions</h1><div class="table-wrap"><table><caption>Example programming submissions</caption><thead><tr><th scope="col">Student</th><th scope="col">Exercise</th><th scope="col">Status</th></tr></thead><tbody><tr><td>Jamie</td><td>Loops</td><td><span class="badge success">Passed</span></td></tr><tr><td>Alex</td><td>Arrays</td><td><span class="badge warning">Review</span></td></tr><tr><td>Sam</td><td>Functions</td><td><span class="badge info">Started</span></td></tr></tbody></table></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_20 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-20-accessible-data-table-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_20,20 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_20 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 21 - Progress Card',CONCAT('ca-htmlcss-path-21-progress-card-t', @teacher_id),'HTML/CSS Preview Project 21: Create a course progress panel with a native progress element and descriptive status text.

Project checklist:
- Use progress with max and value.
- Include text that states the percentage.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Progress Card</title>
<style>
:root { --accent: #6554d9; --tint: #f2f0ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="progress-card"><p class="eyebrow">YOUR LEARNING</p><h1>Python foundations</h1><p>You are making steady progress through the lessons.</p><div class="progress-copy"><span>Completed lessons</span><strong>18 of 30</strong></div><progress max="30" value="18">60%</progress><p class="note">60% complete · Keep going!</p></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_21 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-21-progress-card-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_21,21 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_21 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 22 - Alert Components',CONCAT('ca-htmlcss-path-22-alert-components-t', @teacher_id),'HTML/CSS Preview Project 22: Build informational, success, warning, and error message panels.

Project checklist:
- Use a shared alert class and variants.
- Keep each message understandable without color.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Alert Components</title>
<style>
:root { --accent: #2366a8; --tint: #edf6ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">FEEDBACK PATTERNS</p><h1>Helpful alerts</h1><div class="alert info"><strong>Information</strong><p>Your draft has been saved.</p></div><div class="alert success"><strong>Success</strong><p>All public samples passed.</p></div><div class="alert warning"><strong>Warning</strong><p>Your deadline is approaching.</p></div><div class="alert error"><strong>Error</strong><p>Check the input and try again.</p></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_22 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-22-alert-components-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_22,22 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_22 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 23 - Statistics Dashboard',CONCAT('ca-htmlcss-path-23-statistics-dashboard-t', @teacher_id),'HTML/CSS Preview Project 23: Create three metric cards for completed challenges, study hours, and current streak.

Project checklist:
- Use consistent number hierarchy.
- Arrange cards responsively.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Statistics Dashboard</title>
<style>
:root { --accent: #0f766e; --tint: #e8f8f5; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">OVERVIEW</p><h1>Learning at a glance</h1><div class="stats-grid"><article><small>Challenges solved</small><strong>24</strong><span>+4 this week</span></article><article><small>Study hours</small><strong>12.5</strong><span>This month</span></article><article><small>Current streak</small><strong>5 days</strong><span>Keep it up</span></article></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_23 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-23-statistics-dashboard-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_23,23 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_23 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 24 - Timeline',CONCAT('ca-htmlcss-path-24-timeline-t', @teacher_id),'HTML/CSS Preview Project 24: Build a vertical timeline with four milestones and dates.

Project checklist:
- Use a clear connecting line.
- Keep timeline text readable.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Timeline</title>
<style>
:root { --accent: #b45309; --tint: #fff5e6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">MILESTONES</p><h1>My learning timeline</h1><ol class="timeline"><li><time>Week 1</time><strong>First program</strong><p>Printed your first message.</p></li><li><time>Week 2</time><strong>Decision making</strong><p>Practised if/else conditions.</p></li><li><time>Week 3</time><strong>Loops</strong><p>Repeated tasks with confidence.</p></li><li><time>Week 4</time><strong>Problem solving</strong><p>Combined the skills you learned.</p></li></ol></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_24 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-24-timeline-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_24,24 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_24 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 25 - Blog Article Layout',CONCAT('ca-htmlcss-path-25-blog-article-layout-t', @teacher_id),'HTML/CSS Preview Project 25: Create an article layout with category, title, author/date, lead paragraph, and body sections.

Project checklist:
- Use article and time elements.
- Limit line length for reading comfort.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',900,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Blog Article Layout</title>
<style>
:root { --accent: #9d174d; --tint: #fff0f6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="article"><article><p class="eyebrow">LEARNING JOURNAL · 5 MIN READ</p><h1>What I learned by building small projects</h1><p class="byline">By CodeArena Learner · <time datetime="2026-10-01">October 1, 2026</time></p><p class="lead">A good article layout makes long-form content easy to scan and comfortable to read.</p><h2>Start with one idea</h2><p>Focus on one useful idea at a time, then support it with a clear example.</p><h2>Build a habit</h2><p>Small practice sessions can add up to meaningful progress.</p></article></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_25 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-25-blog-article-layout-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_25,25 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_25 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 26 - Responsive Footer',CONCAT('ca-htmlcss-path-26-responsive-footer-t', @teacher_id),'HTML/CSS Preview Project 26: Design a footer with a short description, two link groups, and copyright.

Project checklist:
- Use semantic footer.
- Stack the groups on mobile.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',1200,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Responsive Footer</title>
<style>
:root { --accent: #6554d9; --tint: #f2f0ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><h1>Build a useful footer</h1><p>The footer below should wrap into a single column on small screens.</p></main><footer class="site-footer"><div><a class="brand" href="#top">CodeArena</a><p>Practice a little. Learn a lot.</p></div><div><strong>Explore</strong><a href="#lessons">Lessons</a><a href="#practice">Practice</a></div><div><strong>Support</strong><a href="#help">Help center</a><a href="#about">About</a></div><small>© 2026 CodeArena</small></footer>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_26 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-26-responsive-footer-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_26,26 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_26 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 27 - Light and Dark Panels',CONCAT('ca-htmlcss-path-27-light-and-dark-panels-t', @teacher_id),'HTML/CSS Preview Project 27: Create two sample cards showing the same content on light and dark surfaces, using separate CSS classes.

Project checklist:
- Use CSS variables for text and surfaces.
- Ensure contrast in both cards.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Medium','HTML & CSS',1200,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Light and Dark Panels</title>
<style>
:root { --accent: #2366a8; --tint: #edf6ff; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">SURFACE CONTRAST</p><h1>Light and dark panels</h1><div class="theme-grid"><section class="light-panel"><h2>Light surface</h2><p>Keep dark text on a light background.</p><span class="badge success">Readable</span></section><section class="dark-panel"><h2>Dark surface</h2><p>Use light text with enough contrast.</p><span class="badge light-badge">Readable</span></section></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_27 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-27-light-and-dark-panels-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_27,27 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_27 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 28 - Responsive Card Grid',CONCAT('ca-htmlcss-path-28-responsive-card-grid-t', @teacher_id),'HTML/CSS Preview Project 28: Create a reusable card grid that changes column count at tablet and desktop breakpoints.

Project checklist:
- Use minmax and auto-fit or media queries.
- Avoid horizontal overflow.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Hard','HTML & CSS',1200,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Responsive Card Grid</title>
<style>
:root { --accent: #0f766e; --tint: #e8f8f5; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main><p class="eyebrow">RESPONSIVE GRID</p><h1>Cards that adapt</h1><p>Resize the preview to test the grid.</p><div class="responsive-grid"><article><span>01</span><h2>Plan</h2><p>Outline the task.</p></article><article><span>02</span><h2>Build</h2><p>Create the layout.</p></article><article><span>03</span><h2>Refine</h2><p>Check each viewport.</p></article><article><span>04</span><h2>Share</h2><p>Polish the result.</p></article></div></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_28 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-28-responsive-card-grid-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_28,28 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_28 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 29 - Portfolio Showcase',CONCAT('ca-htmlcss-path-29-portfolio-showcase-t', @teacher_id),'HTML/CSS Preview Project 29: Build a portfolio intro with a profile area and three project cards with technologies listed.

Project checklist:
- Use semantic sections.
- Add hover and keyboard-focus affordances.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Hard','HTML & CSS',1200,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Portfolio Showcase</title>
<style>
:root { --accent: #b45309; --tint: #fff5e6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<main class="portfolio"><p class="eyebrow">PORTFOLIO</p><h1>Hello, I am a new developer.</h1><p class="lead">I enjoy turning ideas into clear, useful web experiences.</p><section class="project-grid"><article><div class="project-art"></div><h2>Profile page</h2><p>HTML · CSS</p></article><article><div class="project-art second"></div><h2>Study dashboard</h2><p>Grid · Flexbox</p></article><article><div class="project-art third"></div><h2>Challenge cards</h2><p>Responsive UI</p></article></section></main>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_29 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-29-portfolio-showcase-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_29,29 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_29 IS NOT NULL;
INSERT IGNORE INTO exercises(title,slug,description,difficulty,topic,time_limit_seconds,points,starter_code,is_published,monitoring_enabled,warning_threshold,created_by) SELECT 'HTML/CSS 30 - Complete Mini Landing Page',CONCAT('ca-htmlcss-path-30-complete-mini-landing-page-t', @teacher_id),'HTML/CSS Preview Project 30: Combine a navbar, hero, feature grid, testimonial, and footer into a cohesive mini landing page.

Project checklist:
- Keep a consistent color palette and spacing.
- Test at narrow and wide widths.

How to work: Edit the starter HTML and embedded CSS, choose HTML/CSS preview, and use Preview HTML to inspect your result. When you have checked the project against the goals above, select Mark project complete. This activity is a visual practice project; the current browser preview does not automatically grade HTML/CSS.','Hard','HTML & CSS',1200,100,'<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Complete Mini Landing Page</title>
<style>
:root { --accent: #9d174d; --tint: #fff0f6; --ink: #22263a; --muted: #626b80; --line: #e0e5ef; --surface: #ffffff; }
* { box-sizing: border-box; } body { margin: 0; padding: 28px; background: #f7f8fc; color: var(--ink); font: 16px/1.55 system-ui, -apple-system, sans-serif; } main, header.nav, .site-footer { max-width: 980px; margin: 0 auto 22px; } h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.1; letter-spacing: -.035em; margin: .3em 0 .55em; } h2 { font-size: 1.2rem; margin: .4em 0; } p { color: var(--muted); } a { color: var(--accent); } button, input, textarea { font: inherit; } .eyebrow { color: var(--accent); font-size: .76rem; font-weight: 800; letter-spacing: .12em; } .lead { font-size: 1.12rem; max-width: 62ch; } article, .profile, .form-card, .pricing, .quote-card, .progress-card, .spacing-card, .light-panel, .dark-panel { background: var(--surface); border: 1px solid var(--line); border-radius: 18px; padding: 22px; box-shadow: 0 12px 30px rgba(30,40,75,.06); } .profile, .form-card, .price-card, .quote-card, .progress-card { max-width: 520px; margin: 30px auto; } .avatar { width: 56px; height: 56px; display: grid; place-items: center; border-radius: 50%; background: var(--tint); color: var(--accent); font-weight: 800; } .tags, .button-row, .badge-row, .product-bottom, .author, .nav { display:flex; align-items:center; gap: 12px; flex-wrap:wrap; } .tags span, .badge { display:inline-flex; padding: 5px 10px; border-radius: 999px; background: var(--tint); color: var(--accent); font-size: .82rem; font-weight: 700; } .btn, .nav-cta { display:inline-block; border:1px solid var(--line); border-radius: 10px; padding: 10px 15px; text-decoration:none; font-weight:700; cursor:pointer; } .btn.primary, .nav-cta { color:white; background:var(--accent); border-color:var(--accent); } .btn.secondary { background:var(--tint); color:var(--accent); } .btn.outline { background:transparent; color:var(--accent); } :focus-visible { outline: 3px solid #8ea3ff; outline-offset: 3px; } form { display:grid; gap:10px; } label { font-weight:700; } input, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:9px; background:#fff; } .nav { justify-content:space-between; background:var(--surface); border:1px solid var(--line); padding:14px 18px; border-radius:14px; } .nav nav { display:flex; gap:16px; flex-wrap:wrap; } .brand { font-weight:850; font-size:1.1rem; text-decoration:none; color:var(--ink); } .feature-grid, .stats-grid, .project-grid, .theme-grid, .responsive-grid, .gallery, .palette { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin:18px 0; } .feature-grid article span, .responsive-grid article span { color:var(--accent); font-weight:800; } .price { color:var(--ink); font-size:2.2rem; font-weight:850; } .price small { font-size:.9rem; color:var(--muted); } .swatch, .art, .project-art { min-height:100px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--tint)); } .palette .swatch { min-height:60px; display:block; } .palette strong, .palette small { display:block; margin-top:6px; } .product-bottom { justify-content:space-between; } .product-bottom strong, .stats-grid strong { font-size:1.6rem; } .faq details { padding:14px 0; border-bottom:1px solid var(--line); } .faq summary { font-weight:750; cursor:pointer; } .two-col { display:grid; grid-template-columns:minmax(0,2fr) minmax(180px,1fr); gap:24px; } aside { background:var(--tint); padding:20px; border-radius:16px; } .badge.success { background:#e5f8ec; color:#166344; } .badge.warning { background:#fff2d7; color:#8e5a00; } .badge.info { background:#e5f1ff; color:#235fa8; } .badge.error { background:#fde8eb; color:#ad263e; } .table-wrap { overflow-x:auto; } table { width:100%; border-collapse:collapse; background:#fff; } caption { text-align:left; padding:8px 0; font-weight:700; } th,td { padding:12px; text-align:left; border-bottom:1px solid var(--line); } th { background:var(--tint); } progress { width:100%; height:14px; accent-color:var(--accent); } .progress-copy { display:flex; justify-content:space-between; margin-top:20px; } .alert { padding:12px 16px; border-radius:10px; margin:10px 0; } .alert p { margin-bottom:0; } .alert.info { background:#eaf3ff; } .alert.success { background:#e6f8ee; } .alert.warning { background:#fff4dd; } .alert.error { background:#fdecef; } .timeline { border-left:2px solid var(--line); padding-left:22px; } .timeline li { padding:0 0 18px 6px; } .timeline time, .byline, .note { color:var(--muted); font-size:.9rem; } .article { max-width:760px; margin:auto; } .site-footer { display:flex; gap:28px; justify-content:space-between; flex-wrap:wrap; padding:22px; background:var(--surface); border:1px solid var(--line); border-radius:14px; } .site-footer a { display:block; } .site-footer small { flex-basis:100%; } .light-panel { background:#fff; color:#22263a; } .dark-panel { background:#202537; color:#f5f6fc; } .dark-panel p { color:#d4daea; } .light-badge { background:#dce8ff; color:#234b8a; } .art-one { background:linear-gradient(135deg,#f9ba66,#d65c79); } .art-two { background:linear-gradient(135deg,#92d9f6,#3c70b8); } .art-three { background:linear-gradient(135deg,#a0ddad,#2a7f72); } .art-four { background:linear-gradient(135deg,#f7a66b,#9251a6); } .art-five { background:linear-gradient(135deg,#c0c7ff,#5c61bb); } .art-six { background:linear-gradient(135deg,#384b73,#131c32); } .gallery figure { margin:0; } .gallery figcaption { padding:8px 2px; font-weight:700; } .project-art { min-height:130px; } .project-art.second { background:linear-gradient(135deg,#b8eddf,#6554d9); } .project-art.third { background:linear-gradient(135deg,#ffd5a8,#b33d69); } .role { color:var(--accent); font-weight:700; } .spacing-card.roomy { margin-top:28px; padding:30px; } .byline { margin-top:-8px; } .author small { display:block; color:var(--muted); } .author { margin-top:20px; } .form-card { display:grid; gap:10px; } @media(max-width:640px) { body { padding:14px; } .two-col { grid-template-columns:1fr; } .nav { align-items:flex-start; } .nav nav { width:100%; } .site-footer { display:grid; grid-template-columns:1fr 1fr; } .site-footer>div:first-child, .site-footer small { grid-column:1/-1; } }
</style>
</head>
<body>
<header class="nav"><a class="brand" href="#top">CodeArena</a><nav aria-label="Main navigation"><a href="#features">Features</a><a href="#about">About</a><a href="#contact">Contact</a></nav></header><main id="top"><section class="hero"><p class="eyebrow">LEARN SOMETHING NEW</p><h1>Turn practice into progress.</h1><p class="lead">A complete mini landing page that combines clear typography, thoughtful spacing, and responsive sections.</p><a class="btn primary" href="#features">Explore features</a></section><section id="features"><h2>Made for learners</h2><div class="feature-grid"><article><h3>Learn</h3><p>Start with the fundamentals.</p></article><article><h3>Practise</h3><p>Build confidence by doing.</p></article><article><h3>Grow</h3><p>Track what you achieve.</p></article></div></section></main><footer id="contact" class="site-footer"><div><strong>CodeArena</strong><p>Learn by writing code.</p></div><p id="about">Built for curious learners.</p></footer>
</body>
</html>
',1,0,3,@teacher_id WHERE @teacher_id IS NOT NULL;
SET @e_htmlcss_30 := (SELECT id FROM exercises WHERE created_by=@teacher_id AND slug=CONCAT('ca-htmlcss-path-30-complete-mini-landing-page-t', @teacher_id) LIMIT 1);
INSERT IGNORE INTO learning_path_items(path_id,exercise_id,sort_order) SELECT @path_htmlcss,@e_htmlcss_30,30 WHERE @path_htmlcss IS NOT NULL AND @e_htmlcss_30 IS NOT NULL;

-- Summary: expected 30 items per path when the teacher account and required tables are present.
SELECT @teacher_id AS target_teacher_id;
SELECT 'Python Foundations: From First Program to Problem Solving' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='Python Foundations: From First Program to Problem Solving' GROUP BY lp.id;
SELECT 'C Programming Foundations: 30 Challenges' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='C Programming Foundations: 30 Challenges' GROUP BY lp.id;
SELECT 'C++ Programming Foundations: 30 Challenges' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='C++ Programming Foundations: 30 Challenges' GROUP BY lp.id;
SELECT 'Java Programming Foundations: 30 Challenges' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='Java Programming Foundations: 30 Challenges' GROUP BY lp.id;
SELECT 'PHP Programming Foundations: 30 Challenges' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='PHP Programming Foundations: 30 Challenges' GROUP BY lp.id;
SELECT 'Ruby Programming Foundations: 30 Challenges' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='Ruby Programming Foundations: 30 Challenges' GROUP BY lp.id;
SELECT 'HTML & CSS Web Foundations: 30 Projects' AS learning_path, COUNT(lpi.id) AS steps FROM learning_paths lp LEFT JOIN learning_path_items lpi ON lpi.path_id=lp.id WHERE lp.teacher_id=@teacher_id AND lp.title='HTML & CSS Web Foundations: 30 Projects' GROUP BY lp.id;
SELECT 'Done' AS seed_status, 'HTML/CSS projects are preview-only and manually completed by students.' AS note;
