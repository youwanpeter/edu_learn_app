import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final double size;

  const RoleBadge({
    Key? key,
    required this.role,
    this.size = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roleData = _getRoleData(role);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * size,
        vertical: 4 * size,
      ),
      decoration: BoxDecoration(
        color: roleData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * size),
        border: Border.all(
          color: roleData.color.withOpacity(0.3),
          width: 1 * size,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleData.icon,
            size: 12 * size,
            color: roleData.color,
          ),
          SizedBox(width: 4 * size),
          Text(
            roleData.label,
            style: TextStyle(
              fontSize: 10 * size,
              fontWeight: FontWeight.w600,
              color: roleData.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _RoleData _getRoleData(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return _RoleData(
          label: 'ADMIN',
          color: Colors.purple,
          icon: Icons.admin_panel_settings_rounded,
        );
      case 'staff':
      case 'instructor':
      case 'teacher':
        return _RoleData(
          label: 'STAFF',
          color: Colors.blue,
          icon: Icons.school_rounded,
        );
      case 'student':
      default:
        return _RoleData(
          label: 'STUDENT',
          color: Colors.green,
          icon: Icons.person_rounded,
        );
    }
  }
}

class _RoleData {
  final String label;
  final Color color;
  final IconData icon;

  _RoleData({
    required this.label,
    required this.color,
    required this.icon,
  });
}