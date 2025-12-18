import 'package:flutter/material.dart';
import '../models/study_material.dart';
import '../models/assignment.dart';
import '../services/study_material_service.dart';
import '../services/assignment_service.dart';

class Feature2ViewModel extends ChangeNotifier {
  final _materialService = StudyMaterialService();
  final _assignmentService = AssignmentService();

  bool isLoading = false;
  List<StudyMaterial> materials = [];
  List<Assignment> assignments = [];

  Future<void> loadData(String courseId) async {
    isLoading = true;
    notifyListeners();

    materials = (await _materialService.getMaterials(
      courseId,
    )).map((e) => StudyMaterial.fromMap(e)).toList();

    assignments = (await _assignmentService.getAssignments(
      courseId,
    )).map((e) => Assignment.fromMap(e)).toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addMaterial(Map<String, dynamic> data, String courseId) async {
    await _materialService.addMaterial(data);
    await loadData(courseId);
  }

  Future<void> addAssignment(Map<String, dynamic> data, String courseId) async {
    await _assignmentService.addAssignment(data);
    await loadData(courseId);
  }

  Future<void> deleteMaterial(int id, String courseId) async {
    await _materialService.deleteMaterial(id);
    await loadData(courseId);
  }

  Future<void> deleteAssignment(int id, String courseId) async {
    await _assignmentService.deleteAssignment(id);
    await loadData(courseId);
  }
}
