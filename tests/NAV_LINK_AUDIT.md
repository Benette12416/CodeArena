# CodeArena v16 Navigation Link Audit

## Shared Student navigation

| Label | Destination | Expected behavior |
|---|---|---|
| Home | `public/index.php` | Opens student dashboard/home. |
| My classes | `public/student-classrooms.php` | Opens the student's classroom list. |
| Learn → Learning paths | `public/student-learning-paths.php` | Opens assigned learning paths. |
| Learn → Practice arena | `public/index.php#practice` | Scrolls to the published challenge list. |
| My progress | `public/student-progress.php` | Opens student skills/progress view. |
| Leaderboard | `public/leaderboard.php` | Opens student leaderboard. |
| Sign out | `public/logout.php` | Signs out and returns through the configured auth flow. |

## Shared Teacher navigation

| Label | Destination | Expected behavior |
|---|---|---|
| Studio | `public/teacher.php` | Opens Teacher Studio. |
| Classrooms | `public/teacher-classrooms.php` | Opens classroom management. |
| Gradebook | `public/teacher-gradebook.php` | Opens a classroom picker; selecting a class opens `teacher-gradebook.php?classroom_id=ID`. |
| Submissions | `public/teacher-submission.php` | Opens the latest 100 submissions in the signed-in teacher's scope. |
| Tools → Analytics | `public/teacher-analytics.php` | Opens teacher analytics. |
| Tools → Learning paths | `public/teacher-learning-paths.php` | Opens learning-path authoring. |
| Tools → Exam monitoring | `public/teacher-monitoring.php` | Opens teacher-only monitoring/report workflow. |

## Shared Super Admin navigation

| Label | Destination | Expected behavior |
|---|---|---|
| Control center | `public/super-admin/index.php` | Opens the protected admin overview. |
| Administration → Teacher accounts | `public/super-admin/teachers.php` | Opens teacher account management. |
| Administration → Manage users | `public/super-admin/users.php` | Opens user management. |
| Administration → Audit log | `public/super-admin/audit-log.php` | Opens platform audit history. |

The dedicated Super Admin pages use their own protected sidebar. The same role links in the shared layout are available if the role lands on a page that uses `page_header()`.

## Signed-out navigation

| Label | Destination |
|---|---|
| Explore | `public/index.php` |
| Help | `public/help.php` |
| About | `public/about.php` |
| Portals → Teacher portal | `public/teacher-login.php` |
| Portals → Super Admin | `public/super-admin/login.php` |
| Sign in | `public/login.php` |
| Join free | `public/register.php` |

Help and About intentionally remain hidden from the shared navigation/footer while a student, teacher, or Super Admin is signed in.

## Manual browser checks

1. Test each role at desktop width (1440px), tablet width (1024px), and phone width (390px).
2. On phone width, check that the logo and hamburger button share the same row; the menu is closed initially and opens after pressing the button.
3. Open dropdowns with mouse and keyboard. Press Escape to close a dropdown or the mobile menu; click outside to close an open dropdown/menu.
4. Sign in as a teacher and click Gradebook without a query string. It must display classrooms or an empty state, not `Classroom not found`.
5. Select a classroom and test gradebook, export CSV, and the back-to-classroom link.
6. Confirm role-restricted pages redirect unauthorized roles to their appropriate portal.
7. Confirm Help/About are visible when signed out and absent from the authenticated shared navbar/footer.


## v18 additions

- Super Admin Control Center now includes `system-health.php` in the dedicated administration sidebar. It is protected by `require_role(['super_admin'])`.
- The System Health dashboard runs endpoint checks only after an authenticated Super Admin submits a CSRF-protected form. The optional Python execution probe consumes one Judge0 submission and should be used deliberately.
