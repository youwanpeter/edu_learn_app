class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String instructorId;
  final String instructorName;
  final List<String> enrolledStudents;
  final int totalLessons;
  final bool isActive;
  final DateTime createdAt;
  final double progress;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.instructorId,
    required this.instructorName,
    this.enrolledStudents = const [],
    this.totalLessons = 0,
    this.isActive = true,
    required this.createdAt,
    this.progress = 0.0,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'enrolledStudents': enrolledStudents,
      'totalLessons': totalLessons,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'progress': progress,
    };
  }

  // Create from Map
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      enrolledStudents: List<String>.from(map['enrolledStudents'] ?? []),
      totalLessons: map['totalLessons'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }

  // Update copy
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? instructorId,
    String? instructorName,
    List<String>? enrolledStudents,
    int? totalLessons,
    bool? isActive,
    DateTime? createdAt,
    double? progress,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      totalLessons: totalLessons ?? this.totalLessons,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      progress: progress ?? this.progress,
    );
  }
}