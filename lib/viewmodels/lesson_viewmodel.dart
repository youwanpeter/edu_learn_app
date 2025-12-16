import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/user.dart';
import '../services/lesson_service.dart';

class LessonViewModel extends ChangeNotifier {
  final LessonService _service = LessonService();

  List<Lesson> _lessons = [];
  Lesson? _selectedLesson;
  bool _isLoading = false;
  String? _error;

  List<Lesson> get lessons => _lessons;
  Lesson? get selectedLesson => _selectedLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLessonsByCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lessonMaps = await _service.fetchLessonsByCourse(courseId);
      _lessons = lessonMaps.map((map) => Lesson.fromMap(map)).toList();
      _lessons.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      _error = 'Failed to load lessons: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectLesson(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final lessonMap = await _service.fetchLessonById(lessonId);
      _selectedLesson = Lesson.fromMap(lessonMap);
    } catch (e) {
      _error = 'Failed to load lesson: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLesson(Lesson lesson) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.addLesson(lesson.toMap());
      _lessons.add(lesson);
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add lesson: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLesson(Lesson lesson) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateLesson(lesson.toMap());
      final index = _lessons.indexWhere((l) => l.id == lesson.id);
      if (index != -1) {
        _lessons[index] = lesson;
      }
      if (_selectedLesson?.id == lesson.id) {
        _selectedLesson = lesson;
      }
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update lesson: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteLesson(lessonId);
      _lessons.removeWhere((lesson) => lesson.id == lessonId);
      if (_selectedLesson?.id == lessonId) {
        _selectedLesson = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete lesson: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsCompleted(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.markAsCompleted(lessonId);

      // Update local state
      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        _lessons[index] = _lessons[index].copyWith(isCompleted: true);
      }

      if (_selectedLesson?.id == lessonId) {
        _selectedLesson = _selectedLesson!.copyWith(isCompleted: true);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark as completed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLock(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.toggleLock(lessonId);

      // Update local state
      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        final current = _lessons[index];
        _lessons[index] = current.copyWith(isLocked: !current.isLocked);
      }

      if (_selectedLesson?.id == lessonId) {
        _selectedLesson = _selectedLesson!.copyWith(isLocked: !_selectedLesson!.isLocked);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle lock: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool canEditLesson(User user, String instructorId) {
    return user.isAdmin || (user.isStaff && user.id == instructorId);
  }
}