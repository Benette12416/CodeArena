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
