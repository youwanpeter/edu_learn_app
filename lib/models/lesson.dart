class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String? videoUrl;
  final String? pdfUrl;
  final int order;
  final bool isCompleted;
  final bool isLocked;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    this.videoUrl,
    this.pdfUrl,
    required this.order,
    this.isCompleted = false,
    this.isLocked = false,
    required this.createdAt,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'order': order,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      videoUrl: map['videoUrl'],
      pdfUrl: map['pdfUrl'],
      order: map['order'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      isLocked: map['isLocked'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Update copy
  Lesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? content,
    String? videoUrl,
    String? pdfUrl,
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
      videoUrl: videoUrl ?? this.videoUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}