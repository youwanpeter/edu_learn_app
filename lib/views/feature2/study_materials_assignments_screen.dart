import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../viewmodels/feature2_viewmodel.dart';

class StudyMaterialsAssignmentsScreen extends StatefulWidget {
  final String courseId;
  final String userRole;

  const StudyMaterialsAssignmentsScreen({
    super.key,
    required this.courseId,
    required this.userRole,
  });

  @override
  State<StudyMaterialsAssignmentsScreen> createState() =>
      _StudyMaterialsAssignmentsScreenState();
}

class _StudyMaterialsAssignmentsScreenState
    extends State<StudyMaterialsAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Feature2ViewModel>().loadData(widget.courseId);
    });
  }

  bool get canEdit => widget.userRole != 'student';

  // ================= FILE PICKER =================
  Future<String?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final file = File(result.files.single.path!);
    final newPath = '${dir.path}/${result.files.single.name}';
    await file.copy(newPath);
    return newPath;
  }

  // ================= ADD MATERIAL =================
  void _addMaterialDialog() {
    final titleCtrl = TextEditingController();
    String? filePath;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Add Study Material"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(
                  filePath == null ? "Upload Document" : "Document Selected",
                ),
                onPressed: () async {
                  final picked = await _pickFile();
                  if (picked != null) {
                    setState(() => filePath = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || filePath == null) return;

                await context.read<Feature2ViewModel>().addMaterial({
                  'course_id': widget.courseId,
                  'title': titleCtrl.text,
                  'type': 'document',
                  'file_path': filePath,
                  'created_at': DateTime.now().toIso8601String(),
                }, widget.courseId);

                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ADD ASSIGNMENT =================
  void _addAssignmentDialog() {
    final titleCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    String filePath = '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Add Assignment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text("Due Date"),
                subtitle: Text(dueDate.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => dueDate = picked);
                  }
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: Text(filePath.isEmpty ? "Attach File" : "File Attached"),
                onPressed: () async {
                  final picked = await _pickFile();
                  if (picked != null) {
                    setState(() => filePath = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;

                await context.read<Feature2ViewModel>().addAssignment({
                  'course_id': widget.courseId,
                  'title': titleCtrl.text,
                  'due_date': dueDate.toIso8601String(),
                  'attachment_path': filePath,
                  'created_at': DateTime.now().toIso8601String(),
                }, widget.courseId);

                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<Feature2ViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Study Materials & Assignments")),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.menu_book),
                        title: const Text("Add Study Material"),
                        onTap: () {
                          Navigator.pop(context);
                          _addMaterialDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.assignment),
                        title: const Text("Add Assignment"),
                        onTap: () {
                          Navigator.pop(context);
                          _addAssignmentDialog();
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ===== STUDY MATERIALS =====
                const Text(
                  "Study Materials",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (vm.materials.isEmpty)
                  const Text("No study materials available")
                else
                  ...vm.materials.map(
                    (m) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: Text(m.title),
                        subtitle: Text(m.filePath),
                        onTap: () => OpenFilex.open(m.filePath),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ===== ASSIGNMENTS =====
                const Text(
                  "Assignments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (vm.assignments.isEmpty)
                  const Text("No assignments available")
                else
                  ...vm.assignments.map(
                    (a) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.assignment),
                        title: Text(a.title),
                        subtitle: Text(
                          "Due: ${a.dueDate.toLocal().toString().split(' ')[0]}",
                        ),
                        onTap: a.attachmentPath.isNotEmpty
                            ? () => OpenFilex.open(a.attachmentPath)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
