import '../models/course.dart';

class CourseService {
  List<Course> getMockCourses() {
    return [
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
  }

  Future<List<Course>> fetchCourses() async {
    await Future.delayed(const Duration(seconds: 1));
    return getMockCourses();
  }

  Future<List<Course>> fetchCoursesByInstructor(String instructorId) async {
    await Future.delayed(const Duration(seconds: 1));
    return getMockCourses()
        .where((course) => course.instructorId == instructorId)
        .toList();
  }

  Future<List<Course>> fetchEnrolledCourses(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return getMockCourses()
        .where((course) => course.enrolledStudents.contains(studentId))
        .toList();
  }
}