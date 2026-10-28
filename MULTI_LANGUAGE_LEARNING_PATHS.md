# CodeArena v21: 30 Challenges per Language

This update provides **seven published learning paths with 30 steps each**, or **210 learning activities** total:

1. Python Foundations: From First Program to Problem Solving (extended from the original 8 to 30)
2. C Programming Foundations: 30 Challenges
3. C++ Programming Foundations: 30 Challenges
4. Java Programming Foundations: 30 Challenges
5. PHP Programming Foundations: 30 Challenges
6. Ruby Programming Foundations: 30 Challenges
7. HTML & CSS Web Foundations: 30 Projects

The six Judge0-supported paths share a carefully ordered problem-solving curriculum but have language-specific starter files. Each exercise is 100 points and includes one public sample plus three hidden test cases. Suggested time limits range from 5 to 20 minutes.

## Programming challenge sequence (30 each for Python, C, C++, Java, PHP, and Ruby)

1. Hello, CodeArena! (the existing first Python exercise keeps its original Hello, Python! content when it was already seeded)
2. Add Two Integers
3. Rectangle Area
4. Even or Odd
5. Sum from 1 to N
6. Largest of Three
7. Count the Vowels
8. Calculate Factorial
9. Reverse a Number
10. First Ten Multiples
11. Count Digits
12. Palindrome Number
13. Prime Number Check
14. Sum of Digits
15. Nth Fibonacci Number
16. Greatest Common Divisor
17. Least Common Multiple
18. Reverse a Word
19. Count Words in a Sentence
20. Maximum in an Array
21. Count Positive Numbers
22. Second Largest Distinct Number
23. Linear Search
24. Binary Search
25. Sort Numbers Ascending
26. Remove Duplicates, Keep Order
27. Character Frequency
28. Anagram Check
29. Balanced Brackets
30. FizzBuzz

All programming exercises read from standard input and print only the requested output. The seed script gives each language its own starter code while keeping the problem descriptions and expected outputs language-neutral.

## HTML/CSS project sequence (30 preview-only projects)

1. Semantic HTML Page
2. Headings and Paragraphs
3. Personal Profile Card
4. Navigation Bar
5. Button Collection
6. Accessible Contact Form
7. Sign-in Card (visual mockup only)
8. Pricing Card
9. Product Card
10. Landing Page Hero
11. Feature Grid
12. Testimonial Card
13. FAQ Section
14. Two-column Layout
15. CSS Color Variables
16. Typography Scale
17. Spacing System
18. CSS Gallery Grid
19. Status Badges
20. Accessible Data Table
21. Progress Card
22. Alert Components
23. Statistics Dashboard
24. Timeline
25. Blog Article Layout
26. Responsive Footer
27. Light and Dark Panels
28. Responsive Card Grid
29. Portfolio Showcase
30. Complete Mini Landing Page

HTML/CSS currently uses CodeArena's sandboxed browser preview and is **not automatically graded**. Students preview their design and click **Mark project complete** when they've reviewed the project checklist. This completion is stored separately from official classroom grades. The preview iframe is sandboxed, with scripts blocked.

## Install or upgrade on macOS XAMPP

1. Back up the project folder and export the `codearena` database through phpMyAdmin.
2. Copy the updated `CodeArena` folder into `/Applications/XAMPP/xamppfiles/htdocs/CodeArena`, keeping the existing `config/config.php`.
3. Start Apache and MySQL in XAMPP Manager.
4. In phpMyAdmin, select `codearena` and import `database/migrations/008_html_css_learning_completion.sql` once. This creates the progress table needed for HTML/CSS projects.
5. Import `database/seeds/all_language_learning_paths_30.sql`.
6. By default, the seed assigns the paths to the newest account with role `teacher`. If the original 8-step Python path already belongs to a specific teacher, use that same teacher ID so the new steps extend that existing path instead of creating another Python path. To target a teacher, edit the first `SET @teacher_id := ...` line to `SET @teacher_id := 123;` using the desired teacher's numeric ID.
7. Sign in as the selected teacher and open **Teacher Studio → Learning paths**. Sign in as a student and open **Learning paths** to begin.

The seed is designed to be re-imported for the same teacher: stable slugs and existence checks prevent duplicate paths, exercises, steps, and test cases. Existing exercise content and test cases are not overwritten. Python exercises 1-8 reuse the original seed slugs and extend the existing Python Foundations path with exercises 9-30.

## Verify the import

The SQL script ends with a summary query for each path. Confirm all seven paths report `steps = 30`. Open one challenge from each programming path and run its public sample to verify that the configured Judge0 endpoint supports the selected language. For HTML/CSS, open a project from the learning path, choose **Preview HTML**, inspect the sandboxed preview, and click **Mark project complete**. The seed script creates content, but it does not itself verify a live Judge0 provider or automatically assess visual HTML/CSS work.
