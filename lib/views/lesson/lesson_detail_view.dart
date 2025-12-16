import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../models/user.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import 'add_edit_lesson_view.dart';

class LessonDetailView extends StatefulWidget {
  final String lessonId;
  final User user;

  const LessonDetailView({
    Key? key,
    required this.lessonId,
    required this.user,
  }) : super(key: key);

  @override
  _LessonDetailViewState createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonViewModel>().selectLesson(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LessonViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.selectedLesson?.title ?? 'Loading...'),
        actions: _buildAppBarActions(viewModel),
      ),
      body: _buildBody(viewModel),
      floatingActionButton: _buildFloatingActionButton(viewModel),
    );
  }

  List<Widget> _buildAppBarActions(LessonViewModel viewModel) {
    final lesson = viewModel.selectedLesson;
    if (lesson == null) return [];

    final canEdit = widget.user.isStaff || widget.user.isAdmin;

    if (canEdit) {
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEditLesson(lesson),
          tooltip: 'Edit Lesson',
        ),
        if (widget.user.isAdmin)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteLesson(context, lesson.id),
            tooltip: 'Delete Lesson',
          ),
      ];
    }
    return [];
  }

  Widget _buildBody(LessonViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final lesson = viewModel.selectedLesson;
    if (lesson == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text(
              'Lesson not found',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLessonHeader(lesson),

          const SizedBox(height: 24),

          _buildContentSection(lesson),

          const SizedBox(height: 24),

          if (lesson.videoUrl != null || lesson.pdfUrl != null)
            _buildAttachmentsSection(lesson),

          const SizedBox(height: 32),

          _buildActionButtons(viewModel, lesson),
        ],
      ),
    );
  }

  Widget _buildLessonHeader(Lesson lesson) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: lesson.isCompleted ? Colors.green.shade50 : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: lesson.isCompleted
                    ? const Icon(Icons.check, size: 30, color: Colors.green)
                    : Text(
                  lesson.order.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildStatusBadge(
                lesson.isCompleted ? 'Completed' : 'In Progress',
                lesson.isCompleted ? Colors.green : Colors.blue,
                lesson.isCompleted ? Icons.check_circle : Icons.play_circle,
              ),
              const SizedBox(width: 8),
              if (lesson.isLocked)
                _buildStatusBadge(
                  'Locked',
                  Colors.orange,
                  Icons.lock,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lesson Content',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            lesson.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        if (lesson.videoUrl != null)
          _buildAttachmentCard(
            'Video Lesson',
            Icons.video_library,
            Colors.red,
            'Watch the video tutorial',
            lesson.videoUrl!,
          ),

        if (lesson.pdfUrl != null)
          _buildAttachmentCard(
            'PDF Notes',
            Icons.picture_as_pdf,
            Colors.orange,
            'Download the study material',
            lesson.pdfUrl!,
          ),
      ],
    );
  }

  Widget _buildAttachmentCard(String title, IconData icon, Color color, String subtitle, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.open_in_new, color: color, size: 18),
        ),
        onTap: () {
          // Open URL
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: $title'),
              backgroundColor: color,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(LessonViewModel viewModel, Lesson lesson) {
    return Column(
      children: [
        if (widget.user.isStudent && !lesson.isCompleted && !lesson.isLocked)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _markAsComplete(context, lesson.id),
              child: const Text(
                'Mark as Complete',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

        if (widget.user.isStaff || widget.user.isAdmin)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _navigateToEditLesson(lesson),
              child: const Text(
                'Edit Lesson',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

        const SizedBox(height: 12),

        if (widget.user.isAdmin)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _deleteLesson(context, lesson.id),
              child: const Text(
                'Delete Lesson',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(LessonViewModel viewModel) {
    final lesson = viewModel.selectedLesson;
    if (lesson == null) return null;

    final canEdit = widget.user.isStaff || widget.user.isAdmin;

    if (canEdit && lesson.isLocked) {
      return FloatingActionButton(
        onPressed: () => _toggleLock(context, lesson.id),
        child: const Icon(Icons.lock_open),
        backgroundColor: Colors.orange,
      );
    } else if (canEdit && !lesson.isLocked) {
      return FloatingActionButton(
        onPressed: () => _toggleLock(context, lesson.id),
        child: const Icon(Icons.lock),
        backgroundColor: Colors.orange,
      );
    }
    return null;
  }

  void _navigateToEditLesson(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLessonView(
          user: widget.user,
          lesson: lesson,
          courseId: lesson.courseId,
        ),
      ),
    ).then((_) {
      context.read<LessonViewModel>().selectLesson(lesson.id);
    });
  }

  void _deleteLesson(BuildContext context, String lessonId) async {
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<LessonViewModel>().deleteLesson(lessonId);
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

  void _markAsComplete(BuildContext context, String lessonId) async {
    try {
      await context.read<LessonViewModel>().markAsCompleted(lessonId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as complete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleLock(BuildContext context, String lessonId) async {
    try {
      await context.read<LessonViewModel>().toggleLock(lessonId);
      final lesson = context.read<LessonViewModel>().selectedLesson;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lesson?.isLocked == true
              ? 'Lesson locked'
              : 'Lesson unlocked'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle lock: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}