import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../viewmodels/dashboard_viewmodel.dart'; // If you have user info here
import '../../views/course/course_list_view.dart';

class DashboardFooter extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onDashboardTap;
  final VoidCallback? onCoursesTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onProfileTap;

  const DashboardFooter({
    super.key,
    required this.currentIndex,
    this.onDashboardTap,
    this.onCoursesTap,
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
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: "Dashboard",
            active: currentIndex == 0,
            onTap: onDashboardTap ?? () {},
          ),
          _NavItem(
            icon: Icons.book_rounded,
            label: "Courses",
            active: currentIndex == 1,
            onTap: onCoursesTap ?? () {
              // Option 1: Get user from your HomeScreen's role switcher
              // (This requires passing user down or using Provider)

              // Option 2: Hardcoded for testing (choose one role)
              // final user = User(
              //   id: 'staff1', // For staff testing
              //   name: 'Prof. Sewwandi',
              //   email: 'sewwandi@university.com',
              //   role: 'staff',
              // );

              // Option 3: Check current route to determine role
              _navigateToCourses(context);
            },
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            label: "Analytics",
            active: currentIndex == 2,
            onTap: onAnalyticsTap ?? () {},
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: "Profile",
            active: currentIndex == 3,
            onTap: onProfileTap ?? () {},
          ),
        ],
      ),
    );
  }

  void _navigateToCourses(BuildContext context) {
    // Check the current route or use a flag to determine user role
    // For now, let's create a user selector dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select User Role'),
        content: const Text('Choose which role to use for testing:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openCoursesWithRole(context, 'staff');
            },
            child: const Text('Staff (Lecturer)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openCoursesWithRole(context, 'student');
            },
            child: const Text('Student'),
          ),
        ],
      ),
    );
  }

  void _openCoursesWithRole(BuildContext context, String role) {
    User user;

    if (role == 'staff') {
      user = User(
        id: 'staff1',
        name: 'Prof. Sewwandi',
        email: 'sewwandi@university.com',
        role: 'staff',
      );
    } else {
      user = User(
        id: 'student1',
        name: 'Yashodha Sewwandi',
        email: 'yashodha@example.com',
        role: 'student',
      );
    }

    print('🎯 Navigating to CourseListView');
    print('   User: ${user.name} (${user.role})');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseListView(user: user),
      ),
    );
  }
}

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
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.blueAccent : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.blueAccent : Colors.grey,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}