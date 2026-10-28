<?php
require_once __DIR__ . '/../../app/bootstrap.php';
require_once __DIR__ . '/../../app/super_admin_layout.php';
require_role(['super_admin']);
$actionFilter=trim((string)($_GET['action'] ?? ''));
if (mb_strlen($actionFilter)>80) $actionFilter='';
$sql='SELECT al.id,al.actor_id,al.actor_role,al.action,al.entity_type,al.entity_id,al.details,al.created_at,u.name AS actor_name,u.email AS actor_email FROM audit_logs al LEFT JOIN users u ON u.id=al.actor_id';
$params=[];
if($actionFilter!==''){ $sql.=' WHERE al.action LIKE ?'; $params[]='%'.$actionFilter.'%'; }
$sql.=' ORDER BY al.created_at DESC,al.id DESC LIMIT 250';
$stmt=$pdo->prepare($sql);$stmt->execute($params);$logs=$stmt->fetchAll();
admin_header('Audit log','audit');
?>
<div class="admin-page-intro"><div><p class="admin-kicker">SECURITY & ACCOUNTABILITY</p><h2>Platform audit log</h2><p>Recent sign-ins, exercise changes, submissions, learning-path edits, and other recorded events. Passwords, source code, and clipboard contents are never stored in this log.</p></div><span class="directory-count"><?= count($logs) ?> records</span></div>
<section class="admin-panel"><div class="admin-panel-head"><div><h3>Recent events</h3><p>Showing up to 250 most recent records.</p></div><form method="get" class="filter-form"><label for="audit-action-filter">Action</label><input id="audit-action-filter" name="action" value="<?= e($actionFilter) ?>" maxlength="80" placeholder="e.g. login_failed"><button class="mini-admin-button" type="submit">Filter</button><a class="admin-link" href="<?= e($config['base_url']) ?>/super-admin/audit-log.php">Reset</a></form></div>
<div class="admin-table-wrap"><table class="admin-table"><thead><tr><th>When</th><th>Actor</th><th>Action</th><th>Related record</th><th>Details</th></tr></thead><tbody><?php foreach($logs as $row): $details=json_decode((string)($row['details']??''),true); if(!is_array($details))$details=[]; ?><tr><td><?= e(date('M j, Y · g:i:s A',strtotime((string)$row['created_at']))) ?></td><td><?php if($row['actor_name']): ?><strong><?= e($row['actor_name']) ?></strong><small><?= e($row['actor_email']) ?></small><?php else: ?><span class="protected-role">Unauthenticated</span><?php endif; ?><small><?= e($row['actor_role'] ?? 'No session role') ?></small></td><td><span class="role-pill <?= str_contains((string)$row['action'],'failed')?'student':'teacher' ?>"><?= e($row['action']) ?></span></td><td><?= e($row['entity_type'] ?? '—') ?><?= $row['entity_id'] ? ' #'.(int)$row['entity_id'] : '' ?></td><td><?php if($details): ?><details class="audit-details"><summary>View details</summary><pre><?= e(json_encode($details,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE)) ?></pre></details><?php else: ?><span class="admin-muted">—</span><?php endif; ?></td></tr><?php endforeach; ?><?php if(!$logs): ?><tr><td colspan="5" class="admin-empty">No audit events match this filter.</td></tr><?php endif; ?></tbody></table></div></section>
<div class="admin-security-box"><span>◈</span><p><strong>Retention and privacy</strong><br>Audit events support troubleshooting and accountability. Review your school's retention policy before deploying CodeArena with real student data.</p></div>
<?php admin_footer(); ?>
