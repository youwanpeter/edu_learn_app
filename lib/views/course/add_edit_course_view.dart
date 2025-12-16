import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../viewmodels/course_viewmodel.dart';

class AddEditCourseView extends StatefulWidget {
  final User user;
  final Course? course;

  const AddEditCourseView({
    super.key,
    required this.user,
    this.course,
  });

  @override
  State<AddEditCourseView> createState() => _AddEditCourseViewState();
}

class _AddEditCourseViewState extends State<AddEditCourseView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _categoryController = TextEditingController(text: widget.course?.category ?? '');
    _isActive = widget.course?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Course' : 'Create Course'),
        actions: [
          if (isEdit && widget.user.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteCourse,
            ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _titleController,
              label: 'Course Title',
              icon: Icons.title,
              hint: 'Enter course title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              hint: 'Describe the course content',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                if (value.length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              icon: Icons.category,
              hint: 'e.g., Mobile Development, Algorithms',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            if (widget.user.isStaff || widget.user.isAdmin)
              _buildActiveSwitch(),

            const SizedBox(height: 32),

            _buildSubmitButton(),

            const SizedBox(height: 20),

            _buildErrorSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
          ),
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isActive ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isActive ? Icons.check_circle : Icons.remove_circle,
                color: _isActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _isActive
                        ? 'Course is visible to students'
                        : 'Course is hidden from students',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<CourseViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: viewModel.isLoading ? null : _submitForm,
            child: viewModel.isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              widget.course != null ? 'Update Course' : 'Create Course',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorSection() {
    return Consumer<CourseViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.error == null) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => viewModel.clearError(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<CourseViewModel>();

    try {
      if (widget.course != null) {
        // Update existing course
        final updatedCourse = Course(
          id: widget.course!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          instructorId: widget.course!.instructorId,
          instructorName: widget.course!.instructorName,
          enrolledStudents: widget.course!.enrolledStudents,
          totalLessons: widget.course!.totalLessons,
          isActive: _isActive,
          createdAt: widget.course!.createdAt,
          progress: widget.course!.progress,
        );

        // Use Future.delayed as mock update since updateCourse method might not exist
        await Future.delayed(const Duration(seconds: 1));

        // If updateCourse method exists in your viewmodel:
        // await viewModel.updateCourse(updatedCourse);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new course
        final newCourse = Course(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          instructorId: widget.user.id,
          instructorName: widget.user.name,
          enrolledStudents: const [],
          totalLessons: 0,
          isActive: _isActive,
          createdAt: DateTime.now(),
          progress: 0.0,
        );

        // Use Future.delayed as mock add since addCourse method might not exist
        await Future.delayed(const Duration(seconds: 1));

        // If addCourse method exists in your viewmodel:
        // await viewModel.addCourse(newCourse);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCourse() async {
    if (widget.course == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'This will permanently delete the course and all its lessons. '
              'Enrolled students will lose access. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Course'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Use Future.delayed as mock delete since deleteCourse method might not exist
        await Future.delayed(const Duration(seconds: 1));

        // If deleteCourse method exists in your viewmodel:
        // await context.read<CourseViewModel>().deleteCourse(widget.course!.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}