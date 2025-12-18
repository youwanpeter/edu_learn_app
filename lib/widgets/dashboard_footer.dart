import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../views/course/course_list_view.dart';
import '../../views/feature2/study_materials_assignments_screen.dart';

class DashboardFooter extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onDashboardTap;
  final VoidCallback? onCoursesTap;
  final VoidCallback? onLessonsTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onProfileTap;

  const DashboardFooter({
    super.key,
    required this.currentIndex,
    this.onDashboardTap,
    this.onCoursesTap,
    this.onLessonsTap,
    this.onAnalyticsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /// 1. Dashboard
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: "Dashboard",
            active: currentIndex == 0,
            onTap: onDashboardTap ?? () {},
          ),

          /// 2. Courses
          _NavItem(
            icon: Icons.book_rounded,
            label: "Courses",
            active: currentIndex == 1,
            onTap:
                onCoursesTap ??
                () {
                  final user = User(
                    id: 'lecturer1',
                    name: 'Youwan',
                    email: 'lecturer@example.com',
                    role: 'lecturer',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseListView(user: user),
                    ),
                  );
                },
          ),

          /// 3. Lessons → Study Materials & Assignments
          _NavItem(
            icon: Icons.play_circle_fill_rounded,
            label: "Lessons",
            active: currentIndex == 2,
            onTap:
                onLessonsTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudyMaterialsAssignmentsScreen(
                        courseId: 'course_default',
                        userRole: 'lecturer',
                      ),
                    ),
                  );
                },
          ),

          /// 4. Analytics
          _NavItem(
            icon: Icons.bar_chart_rounded,
            label: "Analytics",
            active: currentIndex == 3,
            onTap: onAnalyticsTap ?? () {},
          ),

          /// 5. Profile
          _NavItem(
            icon: Icons.person_rounded,
            label: "Profile",
            active: currentIndex == 4,
            onTap: onProfileTap ?? () {},
          ),
        ],
      ),
    );
  }
}

/// ================= NAV ITEM =================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: active ? Colors.blueAccent : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.blueAccent : Colors.grey,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
