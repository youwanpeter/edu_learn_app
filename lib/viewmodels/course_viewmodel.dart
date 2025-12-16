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
    notifyListeners();

    try {
      if (user.isStudent) {
        _courses = await _service.fetchEnrolledCourses(user.id);
      } else if (user.isStaff) {
        _courses = await _service.fetchCoursesByInstructor(user.id);
      } else {
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

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final allCourses = await _service.fetchCourses();
      _selectedCourse = allCourses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      _error = 'Failed to load course: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Course course) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      _courses.add(course);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add course: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(Course course) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
      }
      if (_selectedCourse?.id == course.id) {
        _selectedCourse = course;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update course: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      _courses.removeWhere((course) => course.id == courseId);
      if (_selectedCourse?.id == courseId) {
        _selectedCourse = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete course: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enrollStudent(String courseId, String studentId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      // Mock enrollment logic
      final index = _courses.indexWhere((course) => course.id == courseId);
      if (index != -1) {
        final course = _courses[index];
        if (!course.enrolledStudents.contains(studentId)) {
          final updatedCourse = Course(
            id: course.id,
            title: course.title,
            description: course.description,
            category: course.category,
            instructorId: course.instructorId,
            instructorName: course.instructorName,
            enrolledStudents: [...course.enrolledStudents, studentId],
            totalLessons: course.totalLessons,
            isActive: course.isActive,
            createdAt: course.createdAt,
            progress: course.progress,
          );
          _courses[index] = updatedCourse;
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to enroll: $e';
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
}