import 'local_db.dart';

class AssignmentService {
  Future<List<Map<String, dynamic>>> getAssignments(String courseId) async {
    final db = await LocalDB.db;
    return db.query(
      'assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  Future<void> addAssignment(Map<String, dynamic> data) async {
    final db = await LocalDB.db;
    await db.insert('assignments', data);
  }

  Future<void> deleteAssignment(int id) async {
    final db = await LocalDB.db;
    await db.delete('assignments', where: 'id = ?', whereArgs: [id]);
  }
}
