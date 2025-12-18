import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../models/course.dart';
import 'database_helper.dart';

class SqliteCourseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all courses
  Future<List<Course>> fetchCourses() async {
    final db = await _dbHelper.database;
    final maps = await db.query('courses', orderBy: 'createdAt DESC');

    List<Course> courses = [];
    for (var map in maps) {
      final course = await _convertMapToCourse(map);
      courses.add(course);
    }

    return courses;
  }

  // Get courses by instructor
  Future<List<Course>> fetchCoursesByInstructor(String instructorId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'courses',
      where: 'instructorId = ?',
      whereArgs: [instructorId],
      orderBy: 'createdAt DESC',
    );

    List<Course> courses = [];
    for (var map in maps) {
      final course = await _convertMapToCourse(map);
      courses.add(course);
    }

    return courses;
  }

  // Get enrolled courses for a student
  Future<List<Course>> fetchEnrolledCourses(String studentId) async {
    final db = await _dbHelper.database;

    // Get course IDs where student is enrolled
    final enrollmentMaps = await db.query(
      'course_students',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );

    if (enrollmentMaps.isEmpty) return [];

    final courseIds = enrollmentMaps.map((map) => map['courseId'] as String).toList();
    final placeholders = List.filled(courseIds.length, '?').join(',');

    final courseMaps = await db.query(
      'courses',
      where: 'id IN ($placeholders)',
      whereArgs: courseIds,
      orderBy: 'createdAt DESC',
    );

    List<Course> courses = [];
    for (var map in courseMaps) {
      final course = await _convertMapToCourse(map);
      courses.add(course);
    }

    return courses;
  }

  // Get available courses for a student
  Future<List<Course>> fetchAvailableCourses(String studentId) async {
    final db = await _dbHelper.database;

    // Get courses where student is NOT enrolled
    final enrollmentMaps = await db.query(
      'course_students',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );

    final enrolledCourseIds = enrollmentMaps.map((map) => map['courseId'] as String).toList();

    List<Map<String, dynamic>> courseMaps;
    if (enrolledCourseIds.isEmpty) {
      courseMaps = await db.query('courses', orderBy: 'createdAt DESC');
    } else {
      final placeholders = List.filled(enrolledCourseIds.length, '?').join(',');
      courseMaps = await db.query(
        'courses',
        where: 'id NOT IN ($placeholders)',
        whereArgs: enrolledCourseIds,
        orderBy: 'createdAt DESC',
      );
    }

    List<Course> courses = [];
    for (var map in courseMaps) {
      final course = await _convertMapToCourse(map);
      courses.add(course);
    }

    return courses;
  }

  // Get course by ID
  Future<Course?> fetchCourseById(String courseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );

    if (maps.isEmpty) return null;

    return await _convertMapToCourse(maps.first);
  }

  // Add a new course
  Future<void> addCourse(Course course) async {
    final db = await _dbHelper.database;

    print('📝 Inserting course into database:');
    print('   ID: ${course.id}');
    print('   Title: ${course.title}');
    print('   Instructor: ${course.instructorName}');

    try {
      // Use course.toMap() which should NOT include enrolledStudentsJson
      await db.insert('courses', course.toMap());
      print('✅ Course inserted successfully');
    } catch (e) {
      print('❌ Error inserting course: $e');
      print('   Course data: ${course.toMap()}');

      // Print the actual INSERT statement being executed
      final map = course.toMap();
      final columns = map.keys.join(', ');
      final placeholders = List.filled(map.length, '?').join(', ');
      print('   SQL: INSERT INTO courses ($columns) VALUES ($placeholders)');
      print('   Values: ${map.values.toList()}');

      rethrow;
    }
  }

  // Update a course
  Future<void> updateCourse(Course course) async {
    final db = await _dbHelper.database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  // Delete a course
  Future<bool> deleteCourse(String courseId, String staffId) async {
    final db = await _dbHelper.database;

    // Check if course exists and belongs to staff
    final course = await fetchCourseById(courseId);
    if (course == null || course.instructorId != staffId) {
      throw Exception('You can only delete your own courses');
    }

    // Delete from course_students first (foreign key constraint)
    await db.delete(
      'course_students',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );

    // Delete from courses
    final result = await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );

    return result > 0;
  }

  // Enroll student in a course
  Future<void> enrollStudent(String courseId, String studentId) async {
    final db = await _dbHelper.database;

    // Check if already enrolled
    final existing = await db.query(
      'course_students',
      where: 'courseId = ? AND studentId = ?',
      whereArgs: [courseId, studentId],
    );

    if (existing.isEmpty) {
      await db.insert('course_students', {
        'courseId': courseId,
        'studentId': studentId,
      });

      print('✅ Student $studentId enrolled in course $courseId');
    } else {
      print('ℹ️ Student $studentId already enrolled in course $courseId');
    }
  }

  // Unenroll student from a course
  Future<void> unenrollStudent(String courseId, String studentId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_students',
      where: 'courseId = ? AND studentId = ?',
      whereArgs: [courseId, studentId],
    );

    print('✅ Student $studentId unenrolled from course $courseId');
  }

  // Get total lessons count for a course
  Future<int> getCourseLessonCount(String courseId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lessons WHERE courseId = ?',
      [courseId],
    );
    return maps.first['count'] as int;
  }

  // Update course lesson count
  Future<void> updateCourseLessonCount(String courseId) async {
    final count = await getCourseLessonCount(courseId);
    final db = await _dbHelper.database;
    await db.update(
      'courses',
      {'totalLessons': count},
      where: 'id = ?',
      whereArgs: [courseId],
    );

    print('📊 Updated course $courseId total lessons to $count');
  }

  // Check if student is enrolled in course
  Future<bool> isStudentEnrolled(String courseId, String studentId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'course_students',
      where: 'courseId = ? AND studentId = ?',
      whereArgs: [courseId, studentId],
    );
    return result.isNotEmpty;
  }

  // Get enrolled student count for a course
  Future<int> getEnrolledStudentCount(String courseId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT COUNT(*) as count FROM course_students WHERE courseId = ?',
      [courseId],
    );
    return maps.first['count'] as int;
  }

  // Get all enrolled students for a course
  Future<List<String>> getEnrolledStudents(String courseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_students',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return maps.map((map) => map['studentId'] as String).toList();
  }

  // Helper method to convert map to Course with enrolled students
  Future<Course> _convertMapToCourse(Map<String, dynamic> map) async {
    final db = await _dbHelper.database;

    // Get enrolled students from course_students table
    final enrollmentMaps = await db.query(
      'course_students',
      where: 'courseId = ?',
      whereArgs: [map['id']],
    );

    final enrolledStudents = enrollmentMaps.map((e) => e['studentId'] as String).toList();

    return Course(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      instructorId: map['instructorId'] as String,
      instructorName: map['instructorName'] as String,
      enrolledStudents: enrolledStudents,
      totalLessons: map['totalLessons'] as int? ?? 0,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}