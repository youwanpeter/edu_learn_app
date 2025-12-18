import '../models/course.dart';

class CourseService {
  // Mock database - Courses with staff and students
  List<Course> _courses = [
    // Course 1 - Taught by staff1
    Course(
      id: '1',
      title: 'Flutter Development',
      description: 'Learn Flutter from scratch with hands-on projects',
      category: 'Mobile Development',
      instructorId: 'staff1', // Lecturer ID
      instructorName: 'Prof. Smith',
      enrolledStudents: ['student1', 'student2'], // Enrolled students
      totalLessons: 10,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      progress: 0.7,
    ),
    // Course 2 - Taught by staff1
    Course(
      id: '2',
      title: 'Algorithms',
      description: 'Data structures and algorithms mastery',
      category: 'Computer Science',
      instructorId: 'staff1',
      instructorName: 'Prof. Smith',
      enrolledStudents: ['student1'], // Only student1 enrolled
      totalLessons: 8,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      progress: 0.625,
    ),
    // Course 3 - Taught by staff2
    Course(
      id: '3',
      title: 'Web Development',
      description: 'Full stack web development with React and Node.js',
      category: 'Web Development',
      instructorId: 'staff2',
      instructorName: 'Dr. Johnson',
      enrolledStudents: ['student2'],
      totalLessons: 12,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      progress: 0.0,
    ),
  ];

  // Get all courses (for staff to see all they teach, for students to see all available)
  Future<List<Course>> fetchCourses() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_courses);
  }

  // Get courses by instructor (for staff dashboard)
  Future<List<Course>> fetchCoursesByInstructor(String instructorId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _courses
        .where((course) => course.instructorId == instructorId)
        .toList();
  }

  // Get enrolled courses (for student dashboard)
  Future<List<Course>> fetchEnrolledCourses(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _courses
        .where((course) => course.enrolledStudents.contains(studentId))
        .toList();
  }

  // Get available courses for students to enroll
  Future<List<Course>> fetchAvailableCourses(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _courses
        .where((course) => !course.enrolledStudents.contains(studentId))
        .toList();
  }

  Future<Course?> fetchCourseById(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      print('⚠️ Course not found with ID: $courseId');
      return null;
    }
  }

  Future<void> addCourse(Course course) async {
    await Future.delayed(const Duration(seconds: 1));

    // Debug print
    print('✅ Adding new course:');
    print('   ID: ${course.id}');
    print('   Title: ${course.title}');
    print('   Instructor: ${course.instructorName} (${course.instructorId})');
    print('   Total courses before: ${_courses.length}');

    _courses.add(course);

    print('   Total courses after: ${_courses.length}');
  }

  Future<void> updateCourse(Course updatedCourse) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _courses.indexWhere((course) => course.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
    }
  }

  // Only staff can delete their own courses
  Future<bool> deleteCourse(String courseId, String staffId) async {
    await Future.delayed(const Duration(seconds: 1));

    final course = _courses.firstWhere((c) => c.id == courseId);

    // Check if the staff member owns this course
    if (course.instructorId != staffId) {
      throw Exception('You can only delete your own courses');
    }

    _courses.removeWhere((course) => course.id == courseId);
    return true;
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

  Future<void> unenrollStudent(String courseId, String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index != -1) {
      final course = _courses[index];
      final updatedList = List<String>.from(course.enrolledStudents)
        ..remove(studentId);
      final updatedCourse = course.copyWith(
        enrolledStudents: updatedList,
      );
      _courses[index] = updatedCourse;
    }
  }
}