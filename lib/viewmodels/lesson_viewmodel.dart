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
      _lessons = await _service.fetchLessonsByCourse(courseId);
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
      _selectedLesson = await _service.fetchLessonById(lessonId);
    } catch (e) {
      _error = 'Failed to load lesson: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLesson(Lesson lesson) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.addLesson(lesson);
      _lessons.add(lesson);
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add lesson: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateLesson(Lesson lesson) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateLesson(lesson);
      final index = _lessons.indexWhere((l) => l.id == lesson.id);
      if (index != -1) {
        _lessons[index] = lesson;
      }
      if (_selectedLesson?.id == lesson.id) {
        _selectedLesson = lesson;
      }
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update lesson: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteLesson(lessonId);
      _lessons.removeWhere((lesson) => lesson.id == lessonId);
      if (_selectedLesson?.id == lessonId) {
        _selectedLesson = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete lesson: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> markAsCompleted(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.markAsCompleted(lessonId);
      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        _lessons[index] = _lessons[index].copyWith(isCompleted: true);
      }
      if (_selectedLesson?.id == lessonId) {
        _selectedLesson = _selectedLesson!.copyWith(isCompleted: true);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to mark as completed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> toggleLock(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.toggleLock(lessonId);
      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        final current = _lessons[index];
        _lessons[index] = current.copyWith(isLocked: !current.isLocked);
      }
      if (_selectedLesson?.id == lessonId) {
        _selectedLesson = _selectedLesson!.copyWith(isLocked: !_selectedLesson!.isLocked);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle lock: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
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