class LessonService {
  List<Map<String, dynamic>> _mockLessons = [
    {
      'id': '1',
      'courseId': '1',
      'title': 'Introduction to Flutter',
      'content': 'Learn the basics of Flutter framework, Dart programming language, and how to set up your development environment.',
      'videoUrl': null,
      'pdfUrl': null,
      'order': 1,
      'isCompleted': false,
      'isLocked': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 29)).toIso8601String(),
    },
    {
      'id': '2',
      'courseId': '1',
      'title': 'Widgets in Flutter',
      'content': 'Understanding widgets - the building blocks of Flutter apps. Stateless vs Stateful widgets.',
      'videoUrl': 'https://example.com/video1',
      'pdfUrl': null,
      'order': 2,
      'isCompleted': false,
      'isLocked': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
    },
    {
      'id': '3',
      'courseId': '1',
      'title': 'State Management',
      'content': 'Learn different state management approaches in Flutter - setState, Provider, Riverpod.',
      'videoUrl': null,
      'pdfUrl': 'https://example.com/state-management.pdf',
      'order': 3,
      'isCompleted': true,
      'isLocked': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 27)).toIso8601String(),
    },
    {
      'id': '4',
      'courseId': '2',
      'title': 'Introduction to Algorithms',
      'content': 'What are algorithms? Time and space complexity analysis. Big O notation.',
      'videoUrl': null,
      'pdfUrl': null,
      'order': 1,
      'isCompleted': false,
      'isLocked': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
    },
    {
      'id': '5',
      'courseId': '2',
      'title': 'Arrays and Strings',
      'content': 'Working with arrays and strings. Common algorithms and problems.',
      'videoUrl': null,
      'pdfUrl': null,
      'order': 2,
      'isCompleted': true,
      'isLocked': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 13)).toIso8601String(),
    },
    {
      'id': '6',
      'courseId': '2',
      'title': 'Linked Lists',
      'content': 'Singly and doubly linked lists. Operations and applications.',
      'videoUrl': 'https://example.com/linked-lists.mp4',
      'pdfUrl': 'https://example.com/linked-list-notes.pdf',
      'order': 3,
      'isCompleted': false,
      'isLocked': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
    },
  ];

  Future<List<Map<String, dynamic>>> fetchLessonsByCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockLessons.where((lesson) => lesson['courseId'] == courseId).toList();
  }

  Future<Map<String, dynamic>> fetchLessonById(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockLessons.firstWhere((lesson) => lesson['id'] == lessonId);
  }

  Future<void> addLesson(Map<String, dynamic> lesson) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockLessons.add(lesson);
  }

  Future<void> updateLesson(Map<String, dynamic> updatedLesson) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockLessons.indexWhere((lesson) => lesson['id'] == updatedLesson['id']);
    if (index != -1) {
      _mockLessons[index] = updatedLesson;
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockLessons.removeWhere((lesson) => lesson['id'] == lessonId);
  }

  Future<void> markAsCompleted(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockLessons.indexWhere((lesson) => lesson['id'] == lessonId);
    if (index != -1) {
      _mockLessons[index] = {..._mockLessons[index], 'isCompleted': true};
    }
  }

  Future<void> toggleLock(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockLessons.indexWhere((lesson) => lesson['id'] == lessonId);
    if (index != -1) {
      final current = _mockLessons[index];
      _mockLessons[index] = {...current, 'isLocked': !(current['isLocked'] ?? false)};
    }
  }
}