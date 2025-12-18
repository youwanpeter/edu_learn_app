class Assignment {
  final int id;
  final String courseId;
  final String title;
  final DateTime dueDate;
  final String attachmentPath;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.dueDate,
    required this.attachmentPath,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      courseId: map['course_id'],
      title: map['title'],
      dueDate: DateTime.parse(map['due_date']),
      attachmentPath: map['attachment_path'] ?? '',
    );
  }
}
