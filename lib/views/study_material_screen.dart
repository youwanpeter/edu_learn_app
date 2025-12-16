import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/study_materials.dart';
import '../viewmodels/study_material_viewmodel.dart';
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
  State<StudyMaterialScreen> createState() {
    return _StudyMaterialScreenState();
  }
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen>
    with TickerProviderStateMixin {

  String _searchQuery = '';
  String _selectFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      StudyMaterialViewModel viewModel =
          Provider.of<StudyMaterialViewModel>(context, listen: false);
      viewModel.loadMaterials(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canEdit = widget.userRole == 'lecturer';

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 0, 0),
                Color.fromARGB(255, 138, 4, 4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Lesson Resources",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Text(
                "Study Materials",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: _tabController.index == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 18,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Assessments",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: _tabController.index == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 18,
                ),
              ),
            ),
          ],
          onTap: (value) {
            setState(() {});
          },
        ),
      ),

      floatingActionButton: canEdit && _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _openMaterialForm(context, null);
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.025,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: w * 0.6,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search by title",
                          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: h * 0.025,
                            horizontal: w * 0.04,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.04),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    DropdownButton<String>(
                      value: _selectFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text("All"),
                        ),
                        DropdownMenuItem(
                          value: 'pdf',
                          child: Text("PDF"),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text("Video"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectFilter = value!;
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(height: h * 0.03),

                Expanded(
                  child: Consumer<StudyMaterialViewModel>(
                    builder: (
                      BuildContext context,
                      StudyMaterialViewModel viewModel,
                      Widget? child,
                    ) {
                      List<StudyMaterial> materials = viewModel.materials;

                      List<StudyMaterial> filteredMaterials =
                          materials.where((material) {
                        bool matchesSearch = material.title
                            .toLowerCase()
                            .contains(_searchQuery);

                        bool matchesFilter = _selectFilter == 'all' ||
                            material.type == _selectFilter;

                        return matchesSearch && matchesFilter;
                      }).toList();

                      if (filteredMaterials.isEmpty) {
                        return const Center(
                          child: Text("No matching study materials"),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredMaterials.length,
                        itemBuilder: (BuildContext context, int index) {
                          StudyMaterial material = filteredMaterials[index];

                          return Container(
                            margin: EdgeInsets.only(bottom: h * 0.015),
                            padding: EdgeInsets.all(w * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w * 0.04),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  material.type == 'pdf'
                                      ? Icons.picture_as_pdf
                                      : Icons.play_circle,
                                  size: w * 0.08,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: w * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        material.title,
                                        style: TextStyle(
                                          fontSize: w * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: h * 0.005),
                                      Text(
                                        material.description,
                                        style: TextStyle(
                                          fontSize: w * 0.035,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (canEdit)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, size: w * 0.06, color: Colors.blueAccent),
                                        onPressed: () {
                                          _openMaterialForm(context, material);
                                        },
                                      ),
                                      IconButton(
                                        icon:
                                            Icon(Icons.delete, size: w * 0.06, color: Colors.blueAccent),
                                        onPressed: () {
                                          _confirmDelete(context, material);
                                        },
                                      ),
                                    ],
                                  )
                                else
                                  IconButton(
                                    icon: Icon(Icons.download, size: w * 0.06, color: Colors.blueAccent),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "File download not implemented yet"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          AssignmentScreen(
            lessonId: widget.lessonId,
            userRole: widget.userRole,
          ),
        ],
      ),
    );
  }

  void _openMaterialForm(BuildContext context, StudyMaterial? material) {
    TextEditingController titleController =
        TextEditingController(text: material?.title ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: material?.description ?? '');

    String selectedType = material?.type ?? 'pdf';
    String? pickedFilePath;
    Uint8List? pickedFileBytes;
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(material == null ? "Add Material" : "Edit Material",
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
                      onChanged: (value) {
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
                    if (material == null && pickedFilePath == null) {
                      setState(() {
                        errorText = "Please select a file";
                      });
                      return;
                    }

                    StudyMaterialViewModel viewModel =
                        Provider.of<StudyMaterialViewModel>(
                      context,
                      listen: false,
                    );

                    String finalFilePath =
                        pickedFilePath ?? material?.filePath ?? '';

                    if (material == null) {
                      viewModel.addMaterial(
                        widget.lessonId,
                        titleController.text,
                        descriptionController.text,
                        selectedType,
                        finalFilePath,
                        fileBytes: pickedFileBytes,
                      );

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Material added successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      viewModel.updateMaterial(
                        material.id,
                        widget.lessonId,
                        titleController.text,
                        descriptionController.text,
                        selectedType,
                        finalFilePath,
                        fileBytes: pickedFileBytes,
                      );

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Material updated successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
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

  void _confirmDelete(BuildContext context, StudyMaterial material) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content:
              const Text("Are you sure you want to delete this material?"),
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
                StudyMaterialViewModel viewModel =
                    Provider.of<StudyMaterialViewModel>(
                  context,
                  listen: false,
                );
                viewModel.deleteMaterial(
                  material.id,
                  widget.lessonId,
                );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Material deleted successfully"),
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
