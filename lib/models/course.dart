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
    required this.enrolledStudents,
    required this.totalLessons,
    required this.isActive,
    required this.createdAt,
    this.progress = 0.0, // Make progress optional
  });

  // Simple copyWith method
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