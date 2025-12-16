import '../models/course.dart';

class CourseService {
  // Mock database
  List<Course> _courses = [
    Course(
      id: '1',
      title: 'Flutter Development',
      description: 'Learn Flutter from scratch with hands-on projects',
      category: 'Mobile Development',
      instructorId: 'staff1',
      instructorName: 'Prof. Smith',
      enrolledStudents: ['student1', 'student2'],
      totalLessons: 10,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      progress: 0.7,
    ),
    Course(
      id: '2',
      title: 'Algorithms',
      description: 'Data structures and algorithms mastery',
      category: 'Computer Science',
      instructorId: 'staff2',
      instructorName: 'Dr. Johnson',
      enrolledStudents: ['student1'],
      totalLessons: 8,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      progress: 0.625,
    ),
  ];

  Future<List<Course>> fetchCourses() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_courses);
  }

  Future<List<Course>> fetchCoursesByInstructor(String instructorId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _courses.where((course) => course.instructorId == instructorId).toList();
  }

  Future<List<Course>> fetchEnrolledCourses(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _courses.where((course) => course.enrolledStudents.contains(studentId)).toList();
  }

  Future<Course?> fetchCourseById(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCourse(Course course) async {
    await Future.delayed(const Duration(seconds: 1));
    _courses.add(course);
  }

  Future<void> updateCourse(Course updatedCourse) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _courses.indexWhere((course) => course.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    await Future.delayed(const Duration(seconds: 1));
    _courses.removeWhere((course) => course.id == courseId);
  }

  Future<void> enrollStudent(String courseId, String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index != -1) {
      final course = _courses[index];
      if (!course.enrolledStudents.contains(studentId)) {
        final updatedCourse = course.copyWith(
          enrolledStudents: [...course.enrolledStudents, studentId],
        );
        _courses[index] = updatedCourse;
      }
    }
  }
}