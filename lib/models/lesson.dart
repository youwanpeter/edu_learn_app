class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final int order;
  final bool isCompleted;
  final bool isLocked;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.order,
    this.isCompleted = false,
    this.isLocked = false,
    required this.createdAt,
  });

  // Convert from Map (from SQLite)
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      courseId: map['courseId'],
      title: map['title'],
      content: map['content'],
      order: map['lessonOrder'], // Note: using lessonOrder to avoid SQL keyword conflict
      isCompleted: map['isCompleted'] == 1,
      isLocked: map['isLocked'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Convert to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'lessonOrder': order,
      'isCompleted': isCompleted ? 1 : 0,
      'isLocked': isLocked ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Update copy
  Lesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? content,
    int? order,
    bool? isCompleted,
    bool? isLocked,
    DateTime? createdAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}