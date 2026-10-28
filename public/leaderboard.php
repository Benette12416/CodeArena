<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
$user = require_role(['student']);

// Keep the leaderboard usable on existing databases where the optional v15
// version-history migration has not yet been applied. Once installed, rankings
// use the maximum points from the exact version tied to each submission.
$hasVersionScoring = codearena_table_exists($pdo, 'exercise_versions')
    && codearena_column_exists($pdo, 'submissions', 'exercise_version_id');
$maxPointsExpr = $hasVersionScoring
    ? "COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(ev.snapshot_json, '$.exercise.points')) AS UNSIGNED), e.points)"
    : 'e.points';
$versionJoin = $hasVersionScoring ? 'LEFT JOIN exercise_versions ev ON ev.id=best.exercise_version_id' : '';

$classStmt = $pdo->prepare("SELECT c.id, c.name, c.section, c.subject
    FROM classrooms c
    JOIN class_enrollments ce ON ce.classroom_id = c.id
    WHERE ce.student_id = ? AND ce.enrollment_status = 'active' AND c.is_active = 1
    ORDER BY c.name, c.section");
$classStmt->execute([(int)$user['id']]);
$myClasses = $classStmt->fetchAll();
$availableClassIds = array_map(static fn(array $row): int => (int)$row['id'], $myClasses);
$selectedClassId = (int)($_GET['classroom_id'] ?? 0);
if ($selectedClassId > 0 && !in_array($selectedClassId, $availableClassIds, true)) {
    $selectedClassId = 0;
    flash('That classroom leaderboard is not available for your account.', 'error');
}
$selectedClass = null;
foreach ($myClasses as $classRow) {
    if ((int)$classRow['id'] === $selectedClassId) { $selectedClass = $classRow; break; }
}

if ($selectedClass) {
    // Each student/exercise pair uses the best saved submission and the maximum points
    // stored in the exact exercise version that submission used.
    $rankingSql = "SELECT u.id, u.name,
        COALESCE(SUM(bp.best_score), 0) AS total_points,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 THEN 1 ELSE 0 END), 0) AS attempted,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 AND bp.best_score >= bp.max_points THEN 1 ELSE 0 END), 0) AS solved,
        COALESCE(SUM(bp.submission_count), 0) AS submissions,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 THEN bp.best_score ELSE 0 END), 0) AS earned_points,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 THEN bp.max_points ELSE 0 END), 0) AS available_points
      FROM class_enrollments ce
      JOIN users u ON u.id = ce.student_id AND u.role = 'student'
      LEFT JOIN (
        SELECT ce2.student_id AS user_id, ca.exercise_id,
          COALESCE(best.score, 0) AS best_score,
          {$maxPointsExpr} AS max_points,
          (SELECT COUNT(*) FROM submissions s3 WHERE s3.user_id=ce2.student_id AND s3.exercise_id=ca.exercise_id AND s3.created_at >= GREATEST(ca.created_at,ce2.joined_at)) AS submission_count
        FROM class_enrollments ce2
        JOIN class_assignments ca ON ca.classroom_id = ce2.classroom_id AND ca.is_active = 1
        JOIN exercises e ON e.id = ca.exercise_id
        LEFT JOIN submissions best ON best.id = (
          SELECT s2.id FROM submissions s2
          WHERE s2.user_id=ce2.student_id AND s2.exercise_id=ca.exercise_id
            AND s2.created_at >= GREATEST(ca.created_at,ce2.joined_at)
          ORDER BY s2.score DESC,s2.created_at DESC,s2.id DESC LIMIT 1
        )
        {$versionJoin}
        WHERE ce2.classroom_id = ? AND ce2.enrollment_status = 'active'
      ) bp ON bp.user_id = u.id
      WHERE ce.classroom_id = ? AND ce.enrollment_status = 'active'
      GROUP BY u.id, u.name
      ORDER BY total_points DESC, solved DESC, attempted DESC, u.name ASC";
    $rankingStmt = $pdo->prepare($rankingSql);
    $rankingStmt->execute([$selectedClassId, $selectedClassId]);
} else {
    $rankingSql = "SELECT u.id, u.name,
        COALESCE(SUM(bp.best_score), 0) AS total_points,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 THEN 1 ELSE 0 END), 0) AS attempted,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 AND bp.best_score >= bp.max_points THEN 1 ELSE 0 END), 0) AS solved,
        COALESCE(SUM(bp.submission_count), 0) AS submissions,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 THEN bp.best_score ELSE 0 END), 0) AS earned_points,
        COALESCE(SUM(CASE WHEN bp.submission_count > 0 THEN bp.max_points ELSE 0 END), 0) AS available_points
      FROM users u
      LEFT JOIN (
        SELECT submission_pairs.user_id, e.id AS exercise_id,
          COALESCE(best.score, 0) AS best_score,
          {$maxPointsExpr} AS max_points,
          (SELECT COUNT(*) FROM submissions s3 WHERE s3.user_id=submission_pairs.user_id AND s3.exercise_id=e.id) AS submission_count
        FROM (SELECT DISTINCT user_id, exercise_id FROM submissions) AS submission_pairs
        JOIN exercises e ON e.id=submission_pairs.exercise_id AND e.is_published=1
        LEFT JOIN submissions best ON best.id = (
          SELECT s2.id FROM submissions s2
          WHERE s2.user_id=submission_pairs.user_id AND s2.exercise_id=e.id
          ORDER BY s2.score DESC,s2.created_at DESC,s2.id DESC LIMIT 1
        )
        {$versionJoin}
      ) bp ON bp.user_id = u.id
      WHERE u.role = 'student'
      GROUP BY u.id, u.name
      ORDER BY total_points DESC, solved DESC, attempted DESC, u.name ASC";
    $rankingStmt = $pdo->query($rankingSql);
}
$allRows = $rankingStmt->fetchAll();
$topRows = array_slice($allRows, 0, 100);
$currentRank = null;
$currentStats = null;
foreach ($allRows as $index => $row) {
    if ((int)$row['id'] === (int)$user['id']) {
        $currentRank = $index + 1;
        $currentStats = $row;
        break;
    }
}
$participantCount = count($allRows);
$totalSolved = array_sum(array_map(static fn(array $row): int => (int)$row['solved'], $allRows));
$totalSubmissions = array_sum(array_map(static fn(array $row): int => (int)$row['submissions'], $allRows));
$leader = $topRows[0] ?? null;
$podiumRows = array_slice($topRows, 0, 3);
page_header('Leaderboard');
?>
<?php if (!$hasVersionScoring): ?>
<div class="alert info v17-schema-notice" role="status">The leaderboard is using current exercise point values because exercise-version history is not available in this database. The page remains usable; ask the site administrator to check migration 007 for version-aware historical scoring.</div>
<?php endif; ?>
<section class="leaderboard-hero">
  <div class="leaderboard-hero-copy"><p class="eyebrow">CODEARENA · COMMUNITY</p><h1><?= $selectedClass ? 'Class leaderboard' : 'The leaderboard' ?></h1><p><?= $selectedClass ? 'Friendly competition for ' . e($selectedClass['name']) . ' · ' . e($selectedClass['section']) . '.' : 'Track progress, celebrate consistent practice, and see how your best solutions stack up.' ?></p>
    <form class="leaderboard-filter" method="get"><label for="leaderboard-class">Ranking scope</label><select name="classroom_id" id="leaderboard-class" onchange="this.form.submit()"><option value="0" <?= !$selectedClass ? 'selected' : '' ?>>Global leaderboard</option><?php foreach ($myClasses as $classRow): ?><option value="<?= (int)$classRow['id'] ?>" <?= (int)$classRow['id'] === $selectedClassId ? 'selected' : '' ?>><?= e($classRow['name']) ?> · <?= e($classRow['section']) ?></option><?php endforeach; ?></select><noscript><button class="button small" type="submit">Apply</button></noscript></form>
  </div>
  <div class="leaderboard-hero-mark" aria-hidden="true"><span class="trophy-orbit">✦</span><span class="trophy-icon">♛</span><span class="trophy-caption">LEARN · BUILD · LEVEL UP</span></div>
</section>
<section class="leaderboard-stats" aria-label="Leaderboard statistics">
  <article class="leaderboard-stat"><span class="leaderboard-stat-icon participants">◎</span><span class="muted">Participants</span><strong><?= number_format($participantCount) ?></strong><small><?= $selectedClass ? 'Enrolled students' : 'Student accounts' ?></small></article>
  <article class="leaderboard-stat"><span class="leaderboard-stat-icon points">✦</span><span class="muted">Top score</span><strong><?= number_format((int)($leader['total_points'] ?? 0)) ?></strong><small><?= $leader ? e($leader['name']) . ' leads' : 'Be the first to score' ?></small></article>
  <article class="leaderboard-stat"><span class="leaderboard-stat-icon solved">✓</span><span class="muted">Challenges solved</span><strong><?= number_format($totalSolved) ?></strong><small>Full-score exercises</small></article>
  <article class="leaderboard-stat"><span class="leaderboard-stat-icon submissions">↗</span><span class="muted">Submissions</span><strong><?= number_format($totalSubmissions) ?></strong><small>Across this ranking</small></article>
</section>
<?php if (count($podiumRows) > 0): ?>
<section class="leaderboard-section"><div class="section-title"><div><h2>Top performers</h2><p class="muted">Every solved challenge starts with one more attempt.</p></div><span class="pill">Top 3</span></div>
  <div class="leaderboard-podium">
  <?php foreach ($podiumRows as $idx => $row): $rank = $idx + 1; $initial = strtoupper(mb_substr((string)$row['name'], 0, 1)); ?>
    <article class="podium-card rank-<?= $rank ?> <?= (int)$row['id'] === (int)$user['id'] ? 'is-you' : '' ?>">
      <div class="podium-rank-badge"><?= $rank === 1 ? '♛' : ($rank === 2 ? 'Ⅱ' : 'Ⅲ') ?></div>
      <div class="podium-avatar avatar-<?= $rank ?>"><?= e($initial) ?></div>
      <h3><?= e($row['name']) ?><?= (int)$row['id'] === (int)$user['id'] ? ' <span class="you-tag">YOU</span>' : '' ?></h3>
      <p><?= number_format((int)$row['solved']) ?> solved · <?= number_format((int)$row['attempted']) ?> attempted</p>
      <strong class="podium-score"><?= number_format((int)$row['total_points']) ?><small> pts</small></strong>
      <span class="podium-footnote"><?= $rank === 1 ? 'Current leader' : 'Rank #' . $rank ?></span>
    </article>
  <?php endforeach; ?>
  </div>
</section>
<?php endif; ?>
<section class="leaderboard-section leaderboard-table-section"><div class="section-title"><div><h2>Rankings</h2><p class="muted">Ranked by total best points, then full-score solves and activity.</p></div><span class="pill">Showing <?= min(100, $participantCount) ?> of <?= $participantCount ?></span></div>
  <div class="leaderboard-table-wrap"><table class="leaderboard-table"><thead><tr><th>Rank</th><th>Student</th><th>Challenges solved</th><th>Attempted</th><th>Submissions</th><th>Total points</th></tr></thead><tbody>
  <?php foreach ($topRows as $index => $row): $rank = $index + 1; $isYou = (int)$row['id'] === (int)$user['id']; $accuracy = (int)$row['available_points'] > 0 ? min(100, (int)round((int)$row['earned_points'] / (int)$row['available_points'] * 100)) : 0; ?>
    <tr class="<?= $isYou ? 'current-user-row' : '' ?>"><td><span class="leaderboard-rank rank-style-<?= $rank <= 3 ? $rank : 'regular' ?>"><?= $rank <= 3 ? ['♛','Ⅱ','Ⅲ'][$rank - 1] : $rank ?></span></td><td><div class="leaderboard-person"><span class="leaderboard-mini-avatar"><?= e(strtoupper(mb_substr((string)$row['name'], 0, 1))) ?></span><span><strong><?= e($row['name']) ?><?= $isYou ? ' <span class="you-tag">YOU</span>' : '' ?></strong><small><?= $isYou ? 'Your profile' : 'CodeArena student' ?></small></span></div></td><td><strong><?= number_format((int)$row['solved']) ?></strong></td><td><?= number_format((int)$row['attempted']) ?></td><td><?= number_format((int)$row['submissions']) ?></td><td><div class="leaderboard-score-cell"><strong><?= number_format((int)$row['total_points']) ?></strong><span class="points-progress"><i style="width:<?= $accuracy ?>%"></i></span></div></td></tr>
  <?php endforeach; ?>
  <?php if (!$topRows): ?><tr><td colspan="6"><div class="leaderboard-empty"><span>✦</span><strong>No rankings yet</strong><p>Submit your first programming solution to get the leaderboard moving.</p><a class="button small" href="<?= e($config['base_url']) ?>/index.php">Explore challenges →</a></div></td></tr><?php endif; ?>
  </tbody></table></div>
  <?php if ($currentRank && $currentRank > 100 && $currentStats): ?><div class="leaderboard-your-rank"><span class="leaderboard-rank rank-style-regular"><?= $currentRank ?></span><div><strong>Your current position</strong><p class="muted">You're outside the top 100 shown above. Keep practicing to move up.</p></div><strong class="your-rank-score"><?= number_format((int)$currentStats['total_points']) ?> pts</strong></div><?php elseif ($currentRank && $currentRank <= 100): ?><p class="leaderboard-footnote">Your row is highlighted so you can find your place quickly.</p><?php endif; ?>
</section>
<div class="leaderboard-note"><span>ⓘ</span><p><strong>How rankings work</strong> Total points are calculated from each student's best score per published exercise. A challenge counts as solved when its full point value is earned. Class rankings use only active assignments for that class and submissions made after a student joined.</p></div>
<?php page_footer(); ?>
