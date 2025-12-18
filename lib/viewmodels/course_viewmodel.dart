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

  // Load courses based on user role
  Future<void> loadCourses(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('📚 Loading courses for user: ${user.name} (${user.role})');

    try {
      if (user.isStudent) {
        print('   Loading enrolled courses...');
        _courses = await _service.fetchEnrolledCourses(user.id);
      } else if (user.isStaff) {
        print('   Loading teaching courses...');
        _courses = await _service.fetchCoursesByInstructor(user.id);
      }

      print('✅ Loaded ${_courses.length} courses');
      for (var course in _courses) {
        print('   - ${course.title} (ID: ${course.id})');
      }
    } catch (e) {
      _error = 'Failed to load courses: $e';
      print('❌ Error loading courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load available courses for students to enroll
  Future<List<Course>> loadAvailableCourses(String studentId) async {
    try {
      print('📚 Loading available courses for student: $studentId');
      final available = await _service.fetchAvailableCourses(studentId);
      print('✅ Found ${available.length} available courses');
      return available;
    } catch (e) {
      _error = 'Failed to load available courses: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> selectCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    print('🎯 Selecting course ID: $courseId');

    try {
      _selectedCourse = await _service.fetchCourseById(courseId);
      if (_selectedCourse == null) {
        print('⚠️ Course not found: $courseId');
      } else {
        print('✅ Selected course: ${_selectedCourse!.title}');
      }
    } catch (e) {
      _error = 'Failed to load course: $e';
      print('❌ Error selecting course: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCourse(Course course, User user) async {
    _isLoading = true;
    notifyListeners();

    print('➕ Adding new course...');
    print('   Title: ${course.title}');
    print('   Instructor: ${user.name} (${user.id})');

    try {
      if (!user.isStaff) {
        throw Exception('Only staff can add courses');
      }

      // Set the instructor to the current staff member
      final courseWithInstructor = course.copyWith(
        instructorId: user.id,
        instructorName: user.name,
      );

      await _service.addCourse(courseWithInstructor);
      _courses.add(courseWithInstructor);

      print('✅ Course added successfully!');
      print('   Course ID: ${courseWithInstructor.id}');

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add course: $e';
      print('❌ Error adding course: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateCourse(Course course, User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!user.isStaff) {
        throw Exception('Only staff can update courses');
      }

      // Check if staff owns this course
      if (course.instructorId != user.id) {
        throw Exception('You can only edit your own courses');
      }

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

  Future<bool> deleteCourse(String courseId, User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!user.isStaff) {
        throw Exception('Only staff can delete courses');
      }

      await _service.deleteCourse(courseId, user.id);
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

  Future<bool> unenrollStudent(String courseId, String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.unenrollStudent(courseId, studentId);
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
      _error = 'Failed to unenroll: $e';
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