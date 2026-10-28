CREATE DATABASE IF NOT EXISTS codearena CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE codearena;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('student','teacher','super_admin') NOT NULL DEFAULT 'student',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exercises (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  slug VARCHAR(200) NOT NULL,
  description MEDIUMTEXT NOT NULL,
  hint_text MEDIUMTEXT NULL,
  difficulty ENUM('Easy','Medium','Hard') NOT NULL DEFAULT 'Easy',
  topic VARCHAR(80) NOT NULL DEFAULT 'Fundamentals',
  time_limit_seconds INT UNSIGNED NOT NULL DEFAULT 600,
  points INT UNSIGNED NOT NULL DEFAULT 100,
  starter_code MEDIUMTEXT NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  monitoring_enabled TINYINT(1) NOT NULL DEFAULT 0,
  warning_threshold TINYINT UNSIGNED NOT NULL DEFAULT 3,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_exercise_slug (slug),
  CONSTRAINT fk_exercise_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exercise_versions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  exercise_id BIGINT UNSIGNED NOT NULL,
  version_number INT UNSIGNED NOT NULL,
  snapshot_json JSON NOT NULL,
  change_reason VARCHAR(120) NOT NULL DEFAULT 'Exercise updated',
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_exercise_version_number (exercise_id, version_number),
  KEY idx_exercise_versions_created (exercise_id, created_at),
  KEY idx_exercise_versions_author (created_by, created_at),
  CONSTRAINT fk_exercise_version_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
  CONSTRAINT fk_exercise_version_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS test_cases (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  exercise_id BIGINT UNSIGNED NOT NULL,
  stdin MEDIUMTEXT NOT NULL,
  expected_output MEDIUMTEXT NOT NULL,
  is_sample TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_test_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attempts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  exercise_version_id BIGINT UNSIGNED NULL,
  started_at DATETIME NOT NULL,
  deadline_at DATETIME NOT NULL,
  completed_at DATETIME NULL,
  best_score INT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('in_progress','submitted','expired') NOT NULL DEFAULT 'in_progress',
  monitoring_enabled TINYINT(1) NOT NULL DEFAULT 0,
  warning_threshold TINYINT UNSIGNED NOT NULL DEFAULT 3,
  started_explicitly TINYINT(1) NOT NULL DEFAULT 0,
  retake_pending TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_user_exercise_attempt (user_id, exercise_id),
  KEY idx_attempt_exercise_version (exercise_version_id),
  CONSTRAINT fk_attempt_exercise_version FOREIGN KEY (exercise_version_id) REFERENCES exercise_versions(id) ON DELETE SET NULL,
  CONSTRAINT fk_attempt_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_attempt_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS submissions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  exercise_version_id BIGINT UNSIGNED NULL,
  language VARCHAR(20) NOT NULL,
  source_code MEDIUMTEXT NOT NULL,
  score INT UNSIGNED NOT NULL DEFAULT 0,
  passed_tests INT UNSIGNED NOT NULL DEFAULT 0,
  total_tests INT UNSIGNED NOT NULL DEFAULT 0,
  result_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_submission_user_exercise (user_id, exercise_id),
  KEY idx_submission_exercise_version (exercise_version_id),
  CONSTRAINT fk_submission_exercise_version FOREIGN KEY (exercise_version_id) REFERENCES exercise_versions(id) ON DELETE SET NULL,
  CONSTRAINT fk_submission_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_submission_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS monitor_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  attempt_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  event_type ENUM('tab_hidden','copy','cut','paste','fullscreen_exit') NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_monitor_attempt_created (attempt_id, created_at),
  INDEX idx_monitor_exercise_created (exercise_id, created_at),
  INDEX idx_monitor_user_created (user_id, created_at),
  CONSTRAINT fk_monitor_attempt FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON DELETE CASCADE,
  CONSTRAINT fk_monitor_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_monitor_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Classroom management tables are also included for fresh installs.
-- CodeArena classroom management upgrade (run once on an existing CodeArena database)
-- Adds classrooms, enrollment by join code, class assignments, and computed grade records.

CREATE TABLE IF NOT EXISTS classrooms (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  teacher_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  section VARCHAR(100) NOT NULL,
  subject VARCHAR(120) NULL,
  description TEXT NULL,
  join_code VARCHAR(12) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  archived_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_classrooms_join_code (join_code),
  KEY idx_classrooms_teacher (teacher_id, is_active),
  CONSTRAINT fk_classrooms_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_enrollments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  classroom_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  enrollment_status ENUM('active','removed') NOT NULL DEFAULT 'active',
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_class_enrollment (classroom_id, student_id),
  KEY idx_enrollments_student (student_id, enrollment_status),
  CONSTRAINT fk_enrollment_classroom FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE,
  CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_assignments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  classroom_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  assigned_by BIGINT UNSIGNED NOT NULL,
  due_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_class_assignment (classroom_id, exercise_id),
  KEY idx_assignment_exercise (exercise_id, is_active),
  CONSTRAINT fk_assignment_classroom FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE,
  CONSTRAINT fk_assignment_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
  CONSTRAINT fk_assignment_teacher FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS grade_records (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  assignment_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  best_score INT UNSIGNED NOT NULL DEFAULT 0,
  max_score INT UNSIGNED NOT NULL DEFAULT 100,
  submission_count INT UNSIGNED NOT NULL DEFAULT 0,
  last_submitted_at DATETIME NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_grade_assignment_student (assignment_id, student_id),
  KEY idx_grade_student (student_id, updated_at),
  CONSTRAINT fk_grade_assignment FOREIGN KEY (assignment_id) REFERENCES class_assignments(id) ON DELETE CASCADE,
  CONSTRAINT fk_grade_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Teacher-only review decisions and notes for recorded exam monitoring events.
CREATE TABLE IF NOT EXISTS monitor_reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  attempt_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  review_status ENUM('pending','reviewed','cleared','follow_up') NOT NULL DEFAULT 'pending',
  notes TEXT NULL,
  reviewed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_monitor_review_attempt_teacher (attempt_id, teacher_id),
  KEY idx_monitor_review_teacher_status (teacher_id, review_status),
  CONSTRAINT fk_monitor_review_attempt FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON DELETE CASCADE,
  CONSTRAINT fk_monitor_review_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- CodeArena v14: learning paths, isolated practice telemetry, auth rate limiting, and audit trail.
CREATE TABLE IF NOT EXISTS learning_paths (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  teacher_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_learning_paths_teacher (teacher_id, is_published),
  CONSTRAINT fk_learning_path_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_path_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  path_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  sort_order INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_learning_path_exercise (path_id, exercise_id),
  KEY idx_path_items_order (path_id, sort_order),
  CONSTRAINT fk_path_item_path FOREIGN KEY (path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
  CONSTRAINT fk_path_item_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS practice_runs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  topic_snapshot VARCHAR(80) NOT NULL DEFAULT 'Fundamentals',
  language VARCHAR(20) NOT NULL,
  passed_samples INT UNSIGNED NOT NULL DEFAULT 0,
  total_samples INT UNSIGNED NOT NULL DEFAULT 0,
  all_samples_passed TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_practice_user_exercise (user_id, exercise_id, created_at),
  KEY idx_practice_user_topic (user_id, topic_snapshot, created_at),
  CONSTRAINT fk_practice_run_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_practice_run_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS auth_rate_limits (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  identity_hash CHAR(64) NOT NULL UNIQUE,
  failed_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  window_started_at DATETIME NOT NULL,
  blocked_until DATETIME NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actor_id BIGINT UNSIGNED NULL,
  actor_role VARCHAR(30) NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(60) NULL,
  entity_id BIGINT UNSIGNED NULL,
  details JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_audit_created (created_at),
  KEY idx_audit_actor (actor_id, created_at),
  KEY idx_audit_action (action, created_at),
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;


-- HTML/CSS preview project completion (manual completion; no automatic visual grading).
-- CodeArena v21: student completion records for preview-only HTML/CSS learning projects.
-- Apply once to an existing database. Safe to run again.
CREATE TABLE IF NOT EXISTS practice_lesson_completions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  path_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_practice_lesson_completion (user_id, path_id, exercise_id),
  KEY idx_practice_completion_user (user_id, completed_at),
  CONSTRAINT fk_practice_completion_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_practice_completion_path FOREIGN KEY (path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
  CONSTRAINT fk_practice_completion_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- v22: sequential learning-path completion (perfect public + hidden test pass, or manual HTML/CSS confirmation).
CREATE TABLE IF NOT EXISTS learning_path_completions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  path_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  completion_type ENUM('all_tests_passed','manual_project') NOT NULL DEFAULT 'all_tests_passed',
  passed_tests INT UNSIGNED NOT NULL DEFAULT 0,
  total_tests INT UNSIGNED NOT NULL DEFAULT 0,
  completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_learning_path_completion (user_id, path_id, exercise_id),
  KEY idx_lpc_user_path (user_id, path_id, completed_at),
  CONSTRAINT fk_lpc_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_lpc_path FOREIGN KEY (path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
  CONSTRAINT fk_lpc_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- CodeArena v23: interactive lessons, feedback, school workflows, achievements, and retake audit.
CREATE TABLE IF NOT EXISTS learning_lessons (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  path_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  objectives VARCHAR(500) NULL,
  lesson_content MEDIUMTEXT NOT NULL,
  example_language VARCHAR(20) NOT NULL DEFAULT 'python',
  example_code MEDIUMTEXT NULL,
  hint_text MEDIUMTEXT NULL,
  sort_order INT UNSIGNED NOT NULL DEFAULT 0,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_lessons_path_order (path_id, is_published, sort_order),
  CONSTRAINT fk_lesson_path FOREIGN KEY (path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
  CONSTRAINT fk_lesson_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_lesson_completions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  lesson_id BIGINT UNSIGNED NOT NULL,
  completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_lesson_completion (user_id, lesson_id),
  KEY idx_lesson_completion_user (user_id, completed_at),
  CONSTRAINT fk_lesson_completion_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_lesson_completion_lesson FOREIGN KEY (lesson_id) REFERENCES learning_lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS submission_feedback (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  submission_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  feedback_text TEXT NOT NULL,
  feedback_type ENUM('comment','needs_revision','approved') NOT NULL DEFAULT 'comment',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_submission_feedback_teacher (submission_id, teacher_id),
  KEY idx_submission_feedback_teacher (teacher_id, updated_at),
  CONSTRAINT fk_feedback_submission FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
  CONSTRAINT fk_feedback_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_announcements (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  classroom_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  body MEDIUMTEXT NOT NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_announcement_class (classroom_id, is_published, created_at),
  CONSTRAINT fk_announcement_classroom FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE,
  CONSTRAINT fk_announcement_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_assignment_overrides (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  assignment_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  extended_due_at DATETIME NULL,
  note VARCHAR(500) NULL,
  updated_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_assignment_student_override (assignment_id, student_id),
  KEY idx_override_student (student_id, extended_due_at),
  CONSTRAINT fk_override_assignment FOREIGN KEY (assignment_id) REFERENCES class_assignments(id) ON DELETE CASCADE,
  CONSTRAINT fk_override_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_override_teacher FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attempt_retake_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  attempt_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  previous_status VARCHAR(30) NOT NULL,
  previous_best_score INT UNSIGNED NOT NULL DEFAULT 0,
  reason VARCHAR(500) NULL,
  granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_retake_attempt (attempt_id, granted_at),
  CONSTRAINT fk_retake_attempt FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON DELETE CASCADE,
  CONSTRAINT fk_retake_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS submission_regrade_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  submission_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  previous_version_id BIGINT UNSIGNED NULL,
  new_version_id BIGINT UNSIGNED NULL,
  previous_score INT UNSIGNED NOT NULL DEFAULT 0,
  previous_passed_tests INT UNSIGNED NOT NULL DEFAULT 0,
  previous_total_tests INT UNSIGNED NOT NULL DEFAULT 0,
  previous_result_json JSON NULL,
  new_score INT UNSIGNED NOT NULL DEFAULT 0,
  new_passed_tests INT UNSIGNED NOT NULL DEFAULT 0,
  new_total_tests INT UNSIGNED NOT NULL DEFAULT 0,
  reason VARCHAR(500) NULL,
  regraded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_regrade_submission (submission_id, regraded_at),
  KEY idx_regrade_teacher (teacher_id, regraded_at),
  CONSTRAINT fk_regrade_submission FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
  CONSTRAINT fk_regrade_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_regrade_previous_version FOREIGN KEY (previous_version_id) REFERENCES exercise_versions(id) ON DELETE SET NULL,
  CONSTRAINT fk_regrade_new_version FOREIGN KEY (new_version_id) REFERENCES exercise_versions(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS badge_definitions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(80) NOT NULL UNIQUE,
  title VARCHAR(120) NOT NULL,
  description VARCHAR(300) NOT NULL,
  icon VARCHAR(20) NOT NULL DEFAULT '🏅',
  sort_order INT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_badges (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  badge_id BIGINT UNSIGNED NOT NULL,
  awarded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_student_badge (student_id, badge_id),
  KEY idx_badges_student (student_id, awarded_at),
  CONSTRAINT fk_student_badge_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_student_badge_definition FOREIGN KEY (badge_id) REFERENCES badge_definitions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT IGNORE INTO badge_definitions(slug,title,description,icon,sort_order) VALUES
 ('first_submission','First Submission','Submit your first graded programming solution.','🚀',1),
 ('perfect_score','Perfect Score','Earn your first perfect score on a graded exercise.','🏆',2),
 ('five_perfect','Perfect Five','Earn perfect scores on five distinct exercises.','⭐',3),
 ('ten_solved','Problem Solver','Complete ten distinct graded exercises with a perfect score.','🧠',4),
 ('practice_explorer','Practice Explorer','Run practice checks on five distinct exercises.','🧭',5),
 ('lesson_learner','Lesson Learner','Complete your first interactive lesson.','📚',6),
 ('seven_day_streak','Seven-Day Streak','Be active in CodeArena on seven consecutive calendar days.','🔥',7);
