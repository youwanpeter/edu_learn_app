import '../models/lesson.dart';
import '../services/course_service.dart';

class LessonService {
  final CourseService _courseService = CourseService();

  // Mock lessons database
  List<Lesson> _lessons = [
    Lesson(
      id: '1',
      courseId: '1',
      title: 'Introduction to Flutter',
      content: 'Learn the basics of Flutter framework and Dart programming language. Understand the widget tree and how Flutter renders UI.',
      order: 1,
      isCompleted: false,
      isLocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 29)),
    ),
    Lesson(
      id: '2',
      courseId: '1',
      title: 'Widgets in Flutter',
      content: 'Understanding widgets - the building blocks of Flutter UI. Learn about StatelessWidget, StatefulWidget, and common widgets.',
      order: 2,
      isCompleted: true,
      isLocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    Lesson(
      id: '3',
      courseId: '2',
      title: 'Introduction to Algorithms',
      content: 'What are algorithms? Time complexity analysis. Understanding Big O notation and algorithm efficiency.',
      order: 1,
      isCompleted: false,
      isLocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Lesson(
      id: '4',
      courseId: '2',
      title: 'Sorting Algorithms',
      content: 'Learn about bubble sort, quick sort, merge sort, and heap sort. Understand when to use each algorithm.',
      order: 2,
      isCompleted: false,
      isLocked: true,
      createdAt: DateTime.now().subtract(const Duration(days: 13)),
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

  // Check if user can add lesson to this course
  Future<bool> canAddLesson(String courseId, String staffId) async {
    // For demo purposes, allow any staff to add lessons
    // In production, check if staff teaches this course
    return true;
  }

  Future<void> addLesson(Lesson lesson, String staffId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if course exists (but don't check instructor for demo)
    final course = await _courseService.fetchCourseById(lesson.courseId);
    if (course == null) {
      throw Exception('Course not found with ID: ${lesson.courseId}');
    }

    // For demo: Print debug info
    print('📝 Adding lesson to course: ${course.title}');
    print('   Course ID: ${lesson.courseId}');
    print('   Staff ID: $staffId');
    print('   Course Instructor: ${course.instructorId}');

    _lessons.add(lesson);
  }

  Future<void> updateLesson(Lesson updatedLesson, String staffId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if lesson exists
    final index = _lessons.indexWhere((lesson) => lesson.id == updatedLesson.id);
    if (index == -1) {
      throw Exception('Lesson not found');
    }

    _lessons[index] = updatedLesson;
  }

  Future<void> deleteLesson(String lessonId, String staffId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if lesson exists
    final lessonExists = _lessons.any((l) => l.id == lessonId);
    if (!lessonExists) {
      throw Exception('Lesson not found');
    }

    _lessons.removeWhere((lesson) => lesson.id == lessonId);
  }

  Future<void> markAsCompleted(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      _lessons[index] = _lessons[index].copyWith(isCompleted: true);
    }
  }

  Future<void> toggleLock(String lessonId, String staffId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      final current = _lessons[index];
      _lessons[index] = current.copyWith(isLocked: !current.isLocked);
    }
  }
}