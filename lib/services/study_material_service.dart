import 'local_db.dart';

class StudyMaterialService {
  Future<List<Map<String, dynamic>>> getMaterials(String courseId) async {
    final db = await LocalDB.db;
    return db.query(
      'study_materials',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  Future<void> addMaterial(Map<String, dynamic> data) async {
    final db = await LocalDB.db;
    await db.insert('study_materials', data);
  }

  Future<void> deleteMaterial(int id) async {
    final db = await LocalDB.db;
    await db.delete('study_materials', where: 'id = ?', whereArgs: [id]);
  }
}
