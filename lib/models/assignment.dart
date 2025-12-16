import 'dart:typed_data';

class Assignment {
  String id;
  String lessonId;
  String title;
  String description;
  String type;
  String filePath;
  Uint8List? fileBytes;

  Assignment({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.type,
    required this.filePath,
    this.fileBytes,
  });
}
