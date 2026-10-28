-- Run this once in phpMyAdmin for an existing CodeArena database.
-- It preserves existing student/teacher accounts and upgrades legacy 'admin' roles.
ALTER TABLE users
  MODIFY role ENUM('student','teacher','admin','super_admin') NOT NULL DEFAULT 'student';

UPDATE users SET role = 'super_admin' WHERE role = 'admin';

ALTER TABLE users
  MODIFY role ENUM('student','teacher','super_admin') NOT NULL DEFAULT 'student';
