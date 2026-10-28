-- CodeArena v22: generic completion records for sequential learning paths.
-- Apply once when upgrading an existing v21 database. Existing HTML/CSS completions are preserved.

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

INSERT IGNORE INTO learning_path_completions
  (user_id, path_id, exercise_id, completion_type, passed_tests, total_tests, completed_at)
SELECT user_id, path_id, exercise_id, 'manual_project', 0, 0, completed_at
FROM practice_lesson_completions;
