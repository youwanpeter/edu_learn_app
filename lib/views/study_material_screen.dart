import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/study_materials.dart';
import '../models/assignment.dart';
import '../viewmodels/study_material_viewmodel.dart';
import '../viewmodels/assignment_viewmodel.dart';
import 'assignment_screen.dart';

class StudyMaterialScreen extends StatefulWidget {
  final String lessonId;
  final String userRole;

  const StudyMaterialScreen({
    super.key,
    required this.lessonId,
    required this.userRole,
  });

  @override
  State<StudyMaterialScreen> createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudyMaterialViewModel>(
        context,
        listen: false,
      ).loadMaterials(widget.lessonId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit =
        widget.userRole == 'admin' || widget.userRole == 'lecturer';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Lesson Resources",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "Study Materials"),
                Tab(text: "Assessments"),
              ],
            ),
          ),
        ),
      ),
      // --- UPDATED BUTTON LABEL HERE ---
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  _openMaterialSheet(context, null);
                } else {
                  _openAssignmentSheet(context, null);
                }
              },
              backgroundColor: theme.colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                // Renamed based on which tab is active
                _tabController.index == 0
                    ? "Add Study Material"
                    : "Add Assignment",
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Materials
          Consumer<StudyMaterialViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.materials.isEmpty) {
                return _buildEmptyState("No study materials yet");
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.materials.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildMaterialCard(
                    context,
                    viewModel.materials[index],
                    canEdit,
                  );
                },
              );
            },
          ),
          // Tab 2: Assessments
          AssignmentScreen(
            lessonId: widget.lessonId,
            userRole: widget.userRole,
            onEdit: (assignment) => _openAssignmentSheet(context, assignment),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(
    BuildContext context,
    StudyMaterial material,
    bool canEdit,
  ) {
    bool isPdf = material.type == 'pdf';
    Color iconColor = isPdf ? Colors.redAccent : Colors.blueAccent;
    IconData iconData = isPdf
        ? Icons.picture_as_pdf_rounded
        : Icons.play_circle_fill_rounded;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    material.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (canEdit)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _openMaterialSheet(context, material);
                  } else if (value == 'delete') {
                    _confirmDeleteMaterial(context, material);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text("Edit")),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _openMaterialSheet(BuildContext context, StudyMaterial? material) {
    final titleController = TextEditingController(text: material?.title ?? '');
    final descController = TextEditingController(
      text: material?.description ?? '',
    );
    String selectedType = material?.type ?? 'pdf';
    String? pickedFilePath;
    Uint8List? pickedFileBytes;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- UPDATED TITLE HERE TOO ---
                  Text(
                    material == null
                        ? "Add Study Material"
                        : "Edit Study Material",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'pdf', child: Text("PDF")),
                      DropdownMenuItem(value: 'video', child: Text("Video")),
                    ],
                    onChanged: (val) =>
                        setSheetState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: selectedType == 'pdf'
                                ? FileType.custom
                                : FileType.video,
                            allowedExtensions: selectedType == 'pdf'
                                ? ['pdf']
                                : null,
                            withData: true,
                          );
                      if (result != null) {
                        setSheetState(() {
                          pickedFilePath = result.files.first.name;
                          pickedFileBytes = result.files.first.bytes;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Text(
                        pickedFilePath ??
                            (material?.filePath != null
                                ? "Current: ${material!.filePath!.split('/').last}"
                                : "Select File"),
                      ),
                    ),
                  ),
                  if (errorText != null)
                    Text(errorText!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (material == null && pickedFilePath == null) {
                        setSheetState(() => errorText = "File required");
                        return;
                      }
                      final vm = Provider.of<StudyMaterialViewModel>(
                        context,
                        listen: false,
                      );
                      String path = pickedFilePath ?? material?.filePath ?? '';
                      if (material == null) {
                        vm.addMaterial(
                          widget.lessonId,
                          titleController.text,
                          descController.text,
                          selectedType,
                          path,
                          fileBytes: pickedFileBytes,
                        );
                      } else {
                        vm.updateMaterial(
                          material.id,
                          widget.lessonId,
                          titleController.text,
                          descController.text,
                          selectedType,
                          path,
                          fileBytes: pickedFileBytes,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAssignmentSheet(BuildContext context, Assignment? assignment) {
    final titleController = TextEditingController(
      text: assignment?.title ?? '',
    );
    final descController = TextEditingController(
      text: assignment?.description ?? '',
    );
    String selectedType = assignment?.type ?? 'pdf';
    String? pickedFilePath;
    Uint8List? pickedFileBytes;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    assignment == null ? "Add Assignment" : "Edit Assignment",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'pdf', child: Text("PDF")),
                      DropdownMenuItem(value: 'video', child: Text("Video")),
                    ],
                    onChanged: (val) =>
                        setSheetState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: selectedType == 'pdf'
                                ? FileType.custom
                                : FileType.video,
                            allowedExtensions: selectedType == 'pdf'
                                ? ['pdf']
                                : null,
                            withData: true,
                          );
                      if (result != null) {
                        setSheetState(() {
                          pickedFilePath = result.files.first.name;
                          pickedFileBytes = result.files.first.bytes;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Text(
                        pickedFilePath ??
                            (assignment?.filePath != null
                                ? "Current: ${assignment!.filePath!.split('/').last}"
                                : "Select File"),
                      ),
                    ),
                  ),
                  if (errorText != null)
                    Text(errorText!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (assignment == null && pickedFilePath == null) {
                        setSheetState(() => errorText = "File required");
                        return;
                      }
                      final vm = Provider.of<AssignmentViewModel>(
                        context,
                        listen: false,
                      );
                      String path =
                          pickedFilePath ?? assignment?.filePath ?? '';
                      if (assignment == null) {
                        vm.addAssignment(
                          widget.lessonId,
                          titleController.text,
                          descController.text,
                          selectedType,
                          path,
                          fileBytes: pickedFileBytes,
                        );
                      } else {
                        vm.updateAssignment(
                          assignment.id,
                          widget.lessonId,
                          titleController.text,
                          descController.text,
                          selectedType,
                          path,
                          fileBytes: pickedFileBytes,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMaterial(BuildContext context, StudyMaterial material) {
    Provider.of<StudyMaterialViewModel>(
      context,
      listen: false,
    ).deleteMaterial(material.id, widget.lessonId);
  }
}
