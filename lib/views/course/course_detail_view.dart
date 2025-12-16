import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/user.dart';
import '../../viewmodels/course_viewmodel.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import '../widgets/lesson_item.dart';
import '../widgets/role_badge.dart';
import 'add_edit_course_view.dart';
import '../lesson/lesson_list_view.dart';
import '../lesson/add_edit_lesson_view.dart';

class CourseDetailView extends StatefulWidget {
  final String courseId;
  final User user;

  const CourseDetailView({
    Key? key,
    required this.courseId,
    required this.user,
  }) : super(key: key);

  @override
  _CourseDetailViewState createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().selectCourse(widget.courseId);
      context.read<LessonViewModel>().loadLessonsByCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseViewModel = context.watch<CourseViewModel>();
    final lessonViewModel = context.watch<LessonViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(courseViewModel.selectedCourse?.title ?? 'Loading...'),
        actions: _buildAppBarActions(courseViewModel),
      ),
      body: _buildBody(courseViewModel, lessonViewModel),
      floatingActionButton: _buildFloatingActionButton(courseViewModel),
    );
  }

  List<Widget> _buildAppBarActions(CourseViewModel courseViewModel) {
    final course = courseViewModel.selectedCourse;
    if (course == null) return [];

    final canEdit = widget.user.isAdmin ||
        (widget.user.isStaff && widget.user.id == course.instructorId);

    if (canEdit) {
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEditCourse(course),
          tooltip: 'Edit Course',
        ),
      ];
    }
    return [];
  }

  Widget _buildBody(CourseViewModel courseViewModel, LessonViewModel lessonViewModel) {
    if (courseViewModel.isLoading || lessonViewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final course = courseViewModel.selectedCourse;
    if (course == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text(
              'Course not found',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseHeader(course),

          const SizedBox(height: 24),

          _buildLessonsSection(lessonViewModel, course),

          const SizedBox(height: 24),

          _buildEnrollmentSection(course),
        ],
      ),
    );
  }

  Widget _buildCourseHeader(Course course) {
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
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.user.isStudent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getProgressColor(course.progress).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getProgressColor(course.progress),
                    ),
                  ),
                  child: Text(
                    '${(course.progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(course.progress),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  course.category,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RoleBadge(role: 'staff', size: 0.8),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            course.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: Colors.grey.shade200),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.people,
                '${course.enrolledStudents.length}',
                'Students',
                Colors.blue,
              ),
              _buildStatItem(
                Icons.menu_book,
                '${course.totalLessons}',
                'Lessons',
                Colors.green,
              ),
              _buildStatItem(
                Icons.access_time,
                '${course.createdAt.day}/${course.createdAt.month}/${course.createdAt.year}',
                'Created',
                Colors.orange,
              ),
            ],
          ),

          if (widget.user.isStudent)
            Column(
              children: [
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Mark all as complete or continue learning
                    },
                    child: const Text(
                      'Continue Learning',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsSection(LessonViewModel lessonViewModel, Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Course Lessons',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (lessonViewModel.lessons.isNotEmpty)
              TextButton(
                onPressed: () => _navigateToLessonListView(course.id),
                child: const Row(
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (lessonViewModel.error != null)
          Container(
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
                    'Error: ${lessonViewModel.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => lessonViewModel.loadLessonsByCourse(course.id),
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (lessonViewModel.lessons.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No lessons yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.isStaff || widget.user.isAdmin
                      ? 'Add the first lesson to get started'
                      : 'Lessons will appear here soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (widget.user.isStaff || widget.user.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () => _navigateToAddLesson(course.id),
                      child: const Text('Add First Lesson'),
                    ),
                  ),
              ],
            ),
          )
        else
          Column(
            children: [
              ...lessonViewModel.lessons.take(3).map((lesson) {
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
              }).toList(),

              if (lessonViewModel.lessons.length > 3)
                Center(
                  child: TextButton(
                    onPressed: () => _navigateToLessonListView(course.id),
                    child: Text(
                      'Show All ${lessonViewModel.lessons.length} Lessons',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildEnrollmentSection(Course course) {
    final isEnrolled = widget.user.isStudent &&
        course.enrolledStudents.contains(widget.user.id);

    if (!widget.user.isStudent) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isEnrolled ? Icons.check_circle : Icons.pending,
                color: isEnrolled ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEnrolled
                      ? 'You are enrolled in this course'
                      : 'You are not enrolled in this course',
                  style: TextStyle(
                    color: isEnrolled ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
              if (!isEnrolled)
                ElevatedButton(
                  onPressed: () => _enrollInCourse(context, course.id),
                  child: const Text('Enroll Now'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(CourseViewModel courseViewModel) {
    final course = courseViewModel.selectedCourse;
    if (course == null) return null;

    final canAddLesson = widget.user.isAdmin ||
        (widget.user.isStaff && widget.user.id == course.instructorId);

    if (canAddLesson) {
      return FloatingActionButton(
        onPressed: () => _navigateToAddLesson(course.id),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      );
    }
    return null;
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  void _navigateToEditCourse(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCourseView(
          user: widget.user,
          course: course,
        ),
      ),
    ).then((_) {
      context.read<CourseViewModel>().selectCourse(course.id);
    });
  }

  void _navigateToLessonListView(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonListView(
          courseId: courseId,
          user: widget.user,
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
      builder: (context) => LessonDetailSheet(lesson: lesson, user: widget.user),
    );
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
    );
  }

  void _navigateToAddLesson(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLessonView(
          user: widget.user,
          courseId: courseId,
        ),
      ),
    ).then((_) {
      context.read<LessonViewModel>().loadLessonsByCourse(courseId);
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

  void _enrollInCourse(BuildContext context, String courseId) async {
    try {
      await context.read<CourseViewModel>().enrollStudent(courseId, widget.user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully enrolled in course!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to enroll: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class LessonDetailSheet extends StatelessWidget {
  final Lesson lesson;
  final User user;

  const LessonDetailSheet({
    Key? key,
    required this.lesson,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
                    if (user.isStudent && !lesson.isCompleted && !lesson.isLocked)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<LessonViewModel>().markAsCompleted(lesson.id);
                          },
                          child: const Text(
                            'Mark as Complete',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                    if (user.isAdmin || user.isStaff)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditLessonView(
                                  user: user,
                                  lesson: lesson,
                                  courseId: lesson.courseId,
                                ),
                              ),
                            );
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
          // Open URL in browser or PDF viewer
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
}