import 'package:sqflite/sqflite.dart';
import '../models/lesson.dart';
import 'database_helper.dart';
import 'sqlite_course_service.dart';

class SqliteLessonService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SqliteCourseService _courseService = SqliteCourseService();

  // Get lessons by course
  Future<List<Lesson>> fetchLessonsByCourse(String courseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'lessons',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'lessonOrder ASC',
    );
    return maps.map((map) => Lesson.fromMap(map)).toList();
  }

  // Get lesson by ID
  Future<Lesson?> fetchLessonById(String lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
    );

    if (maps.isEmpty) return null;
    return Lesson.fromMap(maps.first);
  }

  // Add a new lesson
  Future<void> addLesson(Lesson lesson, String staffId) async {
    final db = await _dbHelper.database;

    // Check if course exists
    final course = await _courseService.fetchCourseById(lesson.courseId);
    if (course == null) {
      throw Exception('Course not found with ID: ${lesson.courseId}');
    }

    // Check if user is staff
    final userMaps = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [staffId, 'staff'],
    );

    if (userMaps.isEmpty) {
      throw Exception('Only staff can add lessons');
    }

    // Insert lesson
    await db.insert('lessons', lesson.toMap());

    // Update course lesson count
    await _courseService.updateCourseLessonCount(lesson.courseId);
  }

  // Update a lesson
  Future<void> updateLesson(Lesson lesson, String staffId) async {
    final db = await _dbHelper.database;

    // Check if user is staff
    final userMaps = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [staffId, 'staff'],
    );

    if (userMaps.isEmpty) {
      throw Exception('Only staff can update lessons');
    }

    await db.update(
      'lessons',
      lesson.toMap(),
      where: 'id = ?',
      whereArgs: [lesson.id],
    );
  }

  // Delete a lesson
  Future<void> deleteLesson(String lessonId, String staffId) async {
    final db = await _dbHelper.database;

    // Check if user is staff
    final userMaps = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [staffId, 'staff'],
    );

    if (userMaps.isEmpty) {
      throw Exception('Only staff can delete lessons');
    }

    // Get lesson to know courseId for updating count
    final lesson = await fetchLessonById(lessonId);
    if (lesson == null) {
      throw Exception('Lesson not found');
    }

    await db.delete(
      'lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
    );

    // Update course lesson count
    if (lesson.courseId.isNotEmpty) {
      await _courseService.updateCourseLessonCount(lesson.courseId);
    }
  }

  // Mark lesson as completed for a student
  Future<void> markAsCompleted(String lessonId, String studentId) async {
    final db = await _dbHelper.database;

    // Check if already completed
    final existing = await db.query(
      'student_progress',
      where: 'lessonId = ? AND studentId = ?',
      whereArgs: [lessonId, studentId],
    );

    if (existing.isEmpty) {
      await db.insert('student_progress', {
        'lessonId': lessonId,
        'studentId': studentId,
        'completedAt': DateTime.now().toIso8601String(),
      });
    }

    // Update lesson completion status
    await db.update(
      'lessons',
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }

  // Toggle lesson lock
  Future<void> toggleLock(String lessonId, String staffId) async {
    final db = await _dbHelper.database;

    // Check if user is staff
    final userMaps = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [staffId, 'staff'],
    );

    if (userMaps.isEmpty) {
      throw Exception('Only staff can lock/unlock lessons');
    }

    // Get current lock status
    final lesson = await fetchLessonById(lessonId);
    if (lesson == null) {
      throw Exception('Lesson not found');
    }

    await db.update(
      'lessons',
      {'isLocked': lesson.isLocked ? 0 : 1},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }

  // Get student progress for a course
  Future<double> getStudentProgress(String courseId, String studentId) async {
    final db = await _dbHelper.database;

    // Get total lessons in course
    final totalMaps = await db.rawQuery(
      'SELECT COUNT(*) as total FROM lessons WHERE courseId = ?',
      [courseId],
    );
    final total = totalMaps.first['total'] as int;

    if (total == 0) return 0.0;

    // Get completed lessons by student
    final completedMaps = await db.rawQuery('''
      SELECT COUNT(*) as completed 
      FROM student_progress sp
      JOIN lessons l ON sp.lessonId = l.id
      WHERE l.courseId = ? AND sp.studentId = ?
    ''', [courseId, studentId]);

    final completed = completedMaps.first['completed'] as int;

    return completed / total;
  }
}