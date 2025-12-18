
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

// Helper for backward compatibility
bool get canEdit => isStaff;

@override
String toString() {
return 'User(id: $id, name: $name, email: $email, role: $role)';
}
}
