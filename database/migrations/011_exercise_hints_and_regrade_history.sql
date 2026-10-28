-- CodeArena v23 add-on. Back up the database first and run once after migration 010.
ALTER TABLE exercises ADD COLUMN hint_text MEDIUMTEXT NULL AFTER description;

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
