import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/assignment.dart';
import '../viewmodels/assignment_viewmodel.dart';
import '../widgets/resource_card.dart';

class AssignmentScreen extends StatefulWidget {
  final String lessonId;
  final String userRole;

  const AssignmentScreen({
    super.key,
    required this.lessonId,
    required this.userRole,
  });

  @override
  State<AssignmentScreen> createState() {
    return _AssignmentScreenState();
  }
}

class _AssignmentScreenState extends State<AssignmentScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AssignmentViewModel viewModel =
          Provider.of<AssignmentViewModel>(context, listen: false);
      viewModel.loadAssignments(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canEdit = widget.userRole == 'lecturer';

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () {
                _openAssignmentForm(context, null);
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.01,
        ),
        child: Consumer<AssignmentViewModel>(
          builder: (
            BuildContext context,
            AssignmentViewModel viewModel,
            Widget? child,
          ) {
            List<Assignment> assignments = viewModel.assignments;

            if (assignments.isEmpty) {
              return const Center(
                child: Text("No assignments available"),
              );
            }

            return ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (BuildContext context, int index) {
                Assignment assignment = assignments[index];

                return ResourceCard(
                  title: assignment.title,
                  description: assignment.description,
                  type: assignment.type,
                  canEdit: canEdit,
                  onEdit: () {
                    _openAssignmentForm(context, assignment);
                  },
                  onDelete: () {
                    _confirmDelete(context, assignment);
                  },
                  onDownload: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Assignment download not implemented yet",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openAssignmentForm(
    BuildContext context,
    Assignment? assignment,
  ) {
    TextEditingController titleController =
        TextEditingController(text: assignment?.title ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: assignment?.description ?? '');

    String selectedType = assignment?.type ?? 'pdf';
    String? pickedFilePath;
    Uint8List? pickedFileBytes;
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              title: Text(
                assignment == null ? "Add Assignment" : "Edit Assignment", 
                style: TextStyle(color: Colors.blue.shade900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'pdf',
                          child: Text("PDF"),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text("Video"),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          selectedType = value;
                        }
                      },
                      decoration:
                          const InputDecoration(labelText: "Type"),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text("Select file from device"),
                        ),
                        IconButton(
                          icon: const Icon(Icons.file_upload),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: selectedType == 'pdf'
                                  ? FileType.custom
                                  : FileType.video,
                              allowedExtensions:
                                  selectedType == 'pdf' ? ['pdf'] : null,
                              withData: true,
                            );

                            if (result != null &&
                                result.files.isNotEmpty) {
                              PlatformFile file = result.files.first;
                              pickedFilePath = file.path ?? file.name;
                              pickedFileBytes = file.bytes;
                              setState(() {
                                errorText = null;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (assignment == null && pickedFilePath == null) {
                      setState(() {
                        errorText = "Please select a file";
                      });
                      return;
                    }

                    AssignmentViewModel viewModel =
                        Provider.of<AssignmentViewModel>(
                      context,
                      listen: false,
                    );

                    String finalFilePath =
                        pickedFilePath ?? assignment?.filePath ?? '';

                    if (assignment == null) {
                      viewModel.addAssignment(
                        widget.lessonId,
                        titleController.text,
                        descriptionController.text,
                        selectedType,
                        finalFilePath,
                        fileBytes: pickedFileBytes,
                      );
                    } else {
                      viewModel.updateAssignment(
                        assignment.id,
                        widget.lessonId,
                        titleController.text,
                        descriptionController.text,
                        selectedType,
                        finalFilePath,
                        fileBytes: pickedFileBytes,
                      );
                    }

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          assignment == null
                              ? "Assignment added successfully"
                              : "Assignment updated successfully",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    Assignment assignment,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this assignment?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                AssignmentViewModel viewModel =
                    Provider.of<AssignmentViewModel>(
                  context,
                  listen: false,
                );

                viewModel.deleteAssignment(
                  assignment.id,
                  widget.lessonId,
                );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Assignment deleted successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
