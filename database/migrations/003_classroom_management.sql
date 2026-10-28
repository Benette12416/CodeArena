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
