-- CodeArena v8: require an explicit Start Exercise action before revealing exercise content.
-- Run this migration once on an existing CodeArena database.

ALTER TABLE attempts
  ADD COLUMN started_explicitly TINYINT(1) NOT NULL DEFAULT 0 AFTER warning_threshold;

-- Preserve the history of attempts that already produced a submission, a monitoring event,
-- a score, or a completed status. Untouched legacy auto-created attempts remain gated and
-- receive a fresh timer only when the student explicitly starts the exercise.
UPDATE attempts a
SET started_explicitly = 1
WHERE a.best_score > 0
   OR a.status = 'submitted'
   OR EXISTS (
      SELECT 1 FROM submissions s
      WHERE s.user_id = a.user_id AND s.exercise_id = a.exercise_id
   )
   OR EXISTS (
      SELECT 1 FROM monitor_events me
      WHERE me.attempt_id = a.id
   );
