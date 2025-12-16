import '../models/assignment.dart';

class AssignmentService {
  static List<Assignment> _assignments = [];

  static List<Assignment> getByLesson(String lessonId) {
    List<Assignment> result = [];
    for (int i = 0; i < _assignments.length; i = i + 1) {
      if (_assignments[i].lessonId == lessonId) {
        result.add(_assignments[i]);
      }
    }
    return result;
  }

  static void add(Assignment assignment) {
    _assignments.add(assignment);
  }

  static void update(Assignment assignment) {
    for (int i = 0; i < _assignments.length; i = i + 1) {
      if (_assignments[i].id == assignment.id) {
        _assignments[i] = assignment;
        break;
      }
    }
  }

  static void delete(String id) {
    _assignments.removeWhere((a) {
      if (a.id == id) {
        return true;
      } else {
        return false;
      }
    });
  }
}
