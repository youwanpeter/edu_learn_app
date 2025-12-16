import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../models/user.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import '../widgets/lesson_item.dart';
import 'add_edit_lesson_view.dart';

class LessonListView extends StatefulWidget {
  final String courseId;
  final User user;

  const LessonListView({
    Key? key,
    required this.courseId,
    required this.user,
  }) : super(key: key);

  @override
  _LessonListViewState createState() => _LessonListViewState();
}

class _LessonListViewState extends State<LessonListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonViewModel>().loadLessonsByCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Lessons'),
        actions: _buildAppBarActions(),
      ),
      body: Consumer<LessonViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(viewModel);
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (widget.user.isStaff || widget.user.isAdmin) {
      return [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortOptions,
        ),
      ];
    }
    return [];
  }

  Widget _buildBody(LessonViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadLessonsByCourse(widget.courseId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No lessons available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.isStaff || widget.user.isAdmin
                  ? 'Create the first lesson'
                  : 'Lessons will be added soon',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            if (widget.user.isStaff || widget.user.isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () => _navigateToAddLesson(),
                  child: const Text('Add Lesson'),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatsHeader(viewModel),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.loadLessonsByCourse(widget.courseId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.lessons.length,
              itemBuilder: (context, index) {
                final lesson = viewModel.lessons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LessonItem(
                    lesson: lesson,
                    userRole: widget.user.role,
                    onTap: () => _showLessonDetail(lesson),
                    onEdit: widget.user.isStaff || widget.user.isAdmin
                        ? () => _navigateToEditLesson(lesson)
                        : null,
                    onDelete: widget.user.isAdmin
                        ? () => _deleteLesson(context, lesson.id)
                        : null,
                    onComplete: widget.user.isStudent && !lesson.isLocked
                        ? () => _markAsComplete(context, lesson.id)
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(LessonViewModel viewModel) {
    final totalLessons = viewModel.lessons.length;
    final completedLessons = viewModel.lessons.where((l) => l.isCompleted).length;
    final lockedLessons = viewModel.lessons.where((l) => l.isLocked).length;
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                '$completedLessons/$totalLessons',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Lessons',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                '$lockedLessons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                'Locked',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.user.isStaff || widget.user.isAdmin) {
      return FloatingActionButton(
        onPressed: () => _navigateToAddLesson(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      );
    }
    return null;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Title'),
              onTap: () {
                Navigator.pop(context);
                // Implement sorting
              },
            ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: const Text('Sort by Order'),
              onTap: () {
                Navigator.pop(context);
                // Implement sorting
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Sort by Completion'),
              onTap: () {
                Navigator.pop(context);
                // Implement sorting
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLessonDetail(Lesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: lesson.isCompleted ? Colors.green.shade50 : Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: lesson.isCompleted
                            ? const Icon(Icons.check, size: 20, color: Colors.green)
                            : Text(
                          lesson.order.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (lesson.isLocked)
                        const Icon(Icons.lock, color: Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        Text(
                          lesson.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),

                        if (lesson.videoUrl != null || lesson.pdfUrl != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Attachments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (lesson.videoUrl != null)
                            _buildAttachmentCard(
                              context,
                              'Video Lesson',
                              Icons.video_library,
                              Colors.red,
                              lesson.videoUrl!,
                            ),

                          if (lesson.pdfUrl != null)
                            _buildAttachmentCard(
                              context,
                              'PDF Notes',
                              Icons.picture_as_pdf,
                              Colors.orange,
                              lesson.pdfUrl!,
                            ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      if (widget.user.isStudent && !lesson.isCompleted && !lesson.isLocked)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _markAsComplete(context, lesson.id);
                            },
                            child: const Text(
                              'Mark as Complete',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                      if (widget.user.isAdmin || widget.user.isStaff)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToEditLesson(lesson);
                            },
                            child: const Text(
                              'Edit Lesson',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                      const SizedBox(width: 12),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentCard(BuildContext context, String title, IconData icon, Color color, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          'Click to open',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLessonView(
          user: widget.user,
          courseId: widget.courseId,
        ),
      ),
    ).then((_) {
      context.read<LessonViewModel>().loadLessonsByCourse(widget.courseId);
    });
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
      context.read<LessonViewModel>().loadLessonsByCourse(widget.courseId);
    });
  }

  void _deleteLesson(BuildContext context, String lessonId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as complete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}