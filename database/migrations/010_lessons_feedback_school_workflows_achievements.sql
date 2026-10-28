-- CodeArena v23 migration. Back up the database and run once when upgrading v22.
ALTER TABLE users ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER role;
ALTER TABLE classrooms ADD COLUMN archived_at DATETIME NULL AFTER is_active;
ALTER TABLE attempts ADD COLUMN retake_pending TINYINT(1) NOT NULL DEFAULT 0 AFTER started_explicitly;

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
