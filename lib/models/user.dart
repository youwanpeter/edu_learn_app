class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'staff' or 'student'

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isStaff => role == 'staff';
  bool get isStudent => role == 'student';

  // Convert from Map (from SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }

  // Convert to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}