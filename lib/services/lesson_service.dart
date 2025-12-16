import '../models/lesson.dart';

class LessonService {
  // Mock database
  List<Lesson> _lessons = [
    Lesson(
      id: '1',
      courseId: '1',
      title: 'Introduction to Flutter',
      content: 'Learn the basics of Flutter framework...',
      order: 1,
      isCompleted: false,
      isLocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 29)),
    ),
    Lesson(
      id: '2',
      courseId: '1',
      title: 'Widgets in Flutter',
      content: 'Understanding widgets - the building blocks...',
      videoUrl: 'https://example.com/video1',
      order: 2,
      isCompleted: true,
      isLocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    Lesson(
      id: '3',
      courseId: '2',
      title: 'Introduction to Algorithms',
      content: 'What are algorithms? Time complexity...',
      order: 1,
      isCompleted: false,
      isLocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  Future<List<Lesson>> fetchLessonsByCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _lessons
        .where((lesson) => lesson.courseId == courseId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<Lesson?> fetchLessonById(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addLesson(Lesson lesson) async {
    await Future.delayed(const Duration(seconds: 1));
    _lessons.add(lesson);
  }

  Future<void> updateLesson(Lesson updatedLesson) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _lessons.indexWhere((lesson) => lesson.id == updatedLesson.id);
    if (index != -1) {
      _lessons[index] = updatedLesson;
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    await Future.delayed(const Duration(seconds: 1));
    _lessons.removeWhere((lesson) => lesson.id == lessonId);
  }

  Future<void> markAsCompleted(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      _lessons[index] = _lessons[index].copyWith(isCompleted: true);
    }
  }

  Future<void> toggleLock(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      final current = _lessons[index];
      _lessons[index] = current.copyWith(isLocked: !current.isLocked);
    }
  }
}