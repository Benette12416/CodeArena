-- CodeArena browser-based exam monitoring upgrade. Run once on an existing database.
USE codearena;

ALTER TABLE exercises
  ADD COLUMN monitoring_enabled TINYINT(1) NOT NULL DEFAULT 0 AFTER is_published,
  ADD COLUMN warning_threshold TINYINT UNSIGNED NOT NULL DEFAULT 3;

-- Capture the monitoring rules at the moment an attempt starts so a later settings change
-- does not silently change the rules in the middle of an exam. Existing attempts default off.
ALTER TABLE attempts
  ADD COLUMN monitoring_enabled TINYINT(1) NOT NULL DEFAULT 0 AFTER status,
  ADD COLUMN warning_threshold TINYINT UNSIGNED NOT NULL DEFAULT 3;

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
