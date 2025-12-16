import 'dart:typed_data';

class StudyMaterial {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final String type;
  final String? filePath;    
  final Uint8List? fileBytes; 

  StudyMaterial({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.type,
    this.filePath,
    this.fileBytes,
  });

  StudyMaterial copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    String? type,
    String? filePath,
    Uint8List? fileBytes,
  }) {
    return StudyMaterial(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileBytes: fileBytes ?? this.fileBytes,
    );
  }
}
