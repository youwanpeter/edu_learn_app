import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/assignment.dart';
import '../services/assignment_service.dart';

class AssignmentViewModel extends ChangeNotifier {
  List<Assignment> _assignments = [];

  bool _isLoaded = false;

  List<Assignment> get assignments {
    return _assignments;
  }

  void loadAssignments(String lessonId) {
    if (_isLoaded == true) {
      return;
    }

    _assignments = <Assignment>[
      Assignment(
        id: 'a1',
        lessonId: lessonId,
        title: 'Sample Assignment 1',
        description: 'This is the first sample assignment',
        type: 'pdf',
        filePath: 'sample1.pdf',
        fileBytes: Uint8List.fromList([0, 1, 2]),
      ),
      Assignment(
        id: 'a2',
        lessonId: lessonId,
        title: 'Sample Assignment 2',
        description: 'This is the second sample assignment',
        type: 'video',
        filePath: 'video_sample.mp4',
        fileBytes: Uint8List.fromList([0, 1, 2]),
      ),
    ];

    _isLoaded = true;
    notifyListeners();
  }

  void addAssignment(
    String lessonId,
    String title,
    String description,
    String type,
    String filePath, {
    Uint8List? fileBytes,
  }) {
    Assignment newAssignment = Assignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: lessonId,
      title: title,
      description: description,
      type: type,
      filePath: filePath,
      fileBytes: fileBytes,
    );

    _assignments.add(newAssignment);
    AssignmentService.add(newAssignment);

    notifyListeners();
  }

  void updateAssignment(
    String id,
    String lessonId,
    String title,
    String description,
    String type,
    String filePath, {
    Uint8List? fileBytes,
  }) {
    int index = -1;

    for (int i = 0; i < _assignments.length; i++) {
      if (_assignments[i].id == id) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      return;
    }

    Assignment updatedAssignment = Assignment(
      id: id,
      lessonId: lessonId,
      title: title,
      description: description,
      type: type,
      filePath: filePath,
      fileBytes: fileBytes,
    );

    _assignments[index] = updatedAssignment;
    AssignmentService.update(updatedAssignment);

    notifyListeners();
  }

  void deleteAssignment(String id, String lessonId) {
    for (int i = 0; i < _assignments.length; i++) {
      if (_assignments[i].id == id) {
        _assignments.removeAt(i);
        break;
      }
    }

    AssignmentService.delete(id);
    notifyListeners();
  }
}
