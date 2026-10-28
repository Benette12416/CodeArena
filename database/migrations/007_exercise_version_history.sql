-- CodeArena v15: immutable exercise snapshots per attempt and submission version tracking.
-- Upgrade from v14 by importing once into the existing codearena database.
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
ALTER TABLE attempts ADD COLUMN exercise_version_id BIGINT UNSIGNED NULL AFTER exercise_id, ADD KEY idx_attempt_exercise_version (exercise_version_id), ADD CONSTRAINT fk_attempt_exercise_version FOREIGN KEY (exercise_version_id) REFERENCES exercise_versions(id) ON DELETE SET NULL;
ALTER TABLE submissions ADD COLUMN exercise_version_id BIGINT UNSIGNED NULL AFTER exercise_id, ADD KEY idx_submission_exercise_version (exercise_version_id), ADD CONSTRAINT fk_submission_exercise_version FOREIGN KEY (exercise_version_id) REFERENCES exercise_versions(id) ON DELETE SET NULL;
