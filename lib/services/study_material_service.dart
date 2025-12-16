import '../models/study_materials.dart';

class StudyMaterialService {
  static final List<StudyMaterial> _materials = [
    StudyMaterial(
      id: '1',
      lessonId: 'lesson1',
      title: 'Introduction PDF',
      description: 'Basic introduction notes',
      type: 'pdf',
      filePath: 'intro.pdf',
    ),
    StudyMaterial(
      id: '2',
      lessonId: 'lesson1',
      title: 'Flutter Video',
      description: 'Flutter basics video',
      type: 'video',
      filePath: null,
    ),
  ];

  static List<StudyMaterial> getByLesson(String lessonId) {
    List<StudyMaterial> result = [];

    for (int i = 0; i < _materials.length; i++) {
      StudyMaterial material = _materials[i];
      if (material.lessonId == lessonId) {
        result.add(material);
      }
    }

    return result;
  }

  static void add(StudyMaterial material) {
    _materials.add(material);
  }

  static void update(StudyMaterial material) {
    int index = -1;

    for (int i = 0; i < _materials.length; i++) {
      if (_materials[i].id == material.id) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      _materials[index] = material;
    }
  }

  static void delete(String id) {
    for (int i = 0; i < _materials.length; i++) {
      if (_materials[i].id == id) {
        _materials.removeAt(i);
        break;
      }
    }
  }
}
