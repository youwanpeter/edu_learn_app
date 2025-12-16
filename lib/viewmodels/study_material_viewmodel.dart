import 'package:flutter/material.dart';
import '../models/study_materials.dart';
import '../services/study_material_service.dart';
import 'dart:typed_data';

class StudyMaterialViewModel extends ChangeNotifier {
  List<StudyMaterial> _materials = [];

  List<StudyMaterial> get materials {
    return _materials;
  }

  void loadMaterials(String lessonId) {
    _materials = StudyMaterialService.getByLesson(lessonId);
    notifyListeners();
  }

  void addMaterial(
    String lessonId,
    String title,
    String description,
    String type,
    String filePath, {
    Uint8List? fileBytes, 
  }) {
    final newMaterial = StudyMaterial(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: lessonId,
      title: title,
      description: description,
      type: type,
      filePath: filePath,
      fileBytes: fileBytes, 
    );

    StudyMaterialService.add(newMaterial);
    loadMaterials(lessonId);
  }

  void updateMaterial(
    String id,
    String lessonId,
    String title,
    String description,
    String type,
    String filePath, {
    Uint8List? fileBytes, 
  }) {
    final updatedMaterial = StudyMaterial(
      id: id,
      lessonId: lessonId,
      title: title,
      description: description,
      type: type,
      filePath: filePath,
      fileBytes: fileBytes, 
    );

    StudyMaterialService.update(updatedMaterial);
    loadMaterials(lessonId);
  }

  void deleteMaterial(String id, String lessonId) {
    StudyMaterialService.delete(id);
    loadMaterials(lessonId);
  }
}
