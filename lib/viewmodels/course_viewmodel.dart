import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/user.dart';
import '../services/course_service.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseService _service = CourseService();

  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourses(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (user.isStudent) {
        _courses = await _service.fetchEnrolledCourses(user.id);
      } else if (user.isStaff) {
        _courses = await _service.fetchCoursesByInstructor(user.id);
      } else if (user.isAdmin) {
        _courses = await _service.fetchCourses();
      }
    } catch (e) {
      _error = 'Failed to load courses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedCourse = await _service.fetchCourseById(courseId);
    } catch (e) {
      _error = 'Failed to load course: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCourse(Course course) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.addCourse(course);
      _courses.add(course);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add course: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateCourse(Course course) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateCourse(course);
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
      }
      if (_selectedCourse?.id == course.id) {
        _selectedCourse = course;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update course: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteCourse(courseId);
      _courses.removeWhere((course) => course.id == courseId);
      if (_selectedCourse?.id == courseId) {
        _selectedCourse = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete course: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> enrollStudent(String courseId, String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.enrollStudent(courseId, studentId);
      final course = await _service.fetchCourseById(courseId);
      if (course != null) {
        final index = _courses.indexWhere((c) => c.id == courseId);
        if (index != -1) {
          _courses[index] = course;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to enroll: $e';
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
}