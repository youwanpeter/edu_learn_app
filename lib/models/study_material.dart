class StudyMaterial {
  final int id;
  final String courseId;
  final String title;
  final String type;
  final String filePath;
  final DateTime createdAt;

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.filePath,
    required this.createdAt,
  });

  factory StudyMaterial.fromMap(Map<String, dynamic> map) {
    return StudyMaterial(
      id: map['id'],
      courseId: map['course_id'],
      title: map['title'],
      type: map['type'],
      filePath: map['file_path'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
