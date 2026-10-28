-- CodeArena v10: teacher-only monitoring review workflow. Run once on an existing database.
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
