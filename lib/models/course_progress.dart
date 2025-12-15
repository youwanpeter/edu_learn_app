class CourseProgress {
  final String courseName;
  final int completedLessons;
  final int totalLessons;

  CourseProgress({
    required this.courseName,
    required this.completedLessons,
    required this.totalLessons,
  });

  double get progress => completedLessons / totalLessons;
}
