import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../models/user.dart';
import '../../viewmodels/lesson_viewmodel.dart';

class AddEditLessonView extends StatefulWidget {
  final User user;
  final String courseId;
  final Lesson? lesson;

  const AddEditLessonView({
    Key? key,
    required this.user,
    required this.courseId,
    this.lesson,
  }) : super(key: key);

  @override
  _AddEditLessonViewState createState() => _AddEditLessonViewState();
}

class _AddEditLessonViewState extends State<AddEditLessonView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _videoUrlController;
  late TextEditingController _pdfUrlController;
  late TextEditingController _orderController;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson?.title ?? '');
    _contentController = TextEditingController(text: widget.lesson?.content ?? '');
    _videoUrlController = TextEditingController(text: widget.lesson?.videoUrl ?? '');
    _pdfUrlController = TextEditingController(text: widget.lesson?.pdfUrl ?? '');
    _orderController = TextEditingController(text: widget.lesson?.order.toString() ?? '1');
    _isLocked = widget.lesson?.isLocked ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _pdfUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lesson != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Lesson' : 'Create Lesson'),
        actions: [
          if (isEdit && widget.user.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteLesson,
              tooltip: 'Delete Lesson',
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
              'Lesson Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _titleController,
              label: 'Lesson Title',
              icon: Icons.title,
              hint: 'Enter lesson title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _orderController,
              label: 'Order Number',
              icon: Icons.numbers,
              hint: '1, 2, 3, ...',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter order number';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _contentController,
              label: 'Lesson Content',
              icon: Icons.description,
              hint: 'Enter detailed lesson content',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter lesson content';
                }
                return null;
              },
              maxLines: 8,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _videoUrlController,
              label: 'Video URL (Optional)',
              icon: Icons.video_library,
              hint: 'https://example.com/video.mp4',
              validator: (value) => null,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _pdfUrlController,
              label: 'PDF URL (Optional)',
              icon: Icons.picture_as_pdf,
              hint: 'https://example.com/notes.pdf',
              validator: (value) => null,
            ),

            const SizedBox(height: 24),

            _buildLockSwitch(),

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
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLockSwitch() {
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
                color: _isLocked ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isLocked ? Icons.lock : Icons.lock_open,
                color: _isLocked ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lesson Access',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _isLocked
                        ? 'Students cannot access this lesson'
                        : 'Students can access this lesson',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isLocked,
              activeColor: Colors.orange,
              inactiveThumbColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _isLocked = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<LessonViewModel>(
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
              widget.lesson != null ? 'Update Lesson' : 'Create Lesson',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorSection() {
    return Consumer<LessonViewModel>(
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

    final viewModel = context.read<LessonViewModel>();
    final order = int.tryParse(_orderController.text) ?? 1;

    try {
      if (widget.lesson != null) {
        final updatedLesson = widget.lesson!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
          pdfUrl: _pdfUrlController.text.isNotEmpty ? _pdfUrlController.text : null,
          order: order,
          isLocked: _isLocked,
        );
        await viewModel.updateLesson(updatedLesson);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final newLesson = Lesson(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          courseId: widget.courseId,
          title: _titleController.text,
          content: _contentController.text,
          videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
          pdfUrl: _pdfUrlController.text.isNotEmpty ? _pdfUrlController.text : null,
          order: order,
          isLocked: _isLocked,
          createdAt: DateTime.now(),
        );
        await viewModel.addLesson(newLesson);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      // Error is already shown by viewModel
    }
  }

  void _deleteLesson() async {
    if (widget.lesson == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson? This action cannot be undone.'),
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
            child: const Text('Delete Lesson'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<LessonViewModel>().deleteLesson(widget.lesson!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}