import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../viewmodels/course_viewmodel.dart';
import '../../models/course.dart'; // ADD THIS LINE

class CourseListView extends StatefulWidget {
  final User user;

  const CourseListView({super.key, required this.user});

  @override
  State<CourseListView> createState() => _CourseListViewState();
}

class _CourseListViewState extends State<CourseListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseViewModel>(context, listen: false)
          .loadCourses(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CourseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadCourses(widget.user),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyMessage(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptySubMessage(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (widget.user.isStaff || widget.user.isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Add course
                        },
                        child: const Text('Create Your First Course'),
                      ),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.courses.length,
            itemBuilder: (context, index) {
              final course = viewModel.courses[index];
              return _buildCourseCard(course);
            },
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.user.isStudent)
                  Chip(
                    label: Text('${(course.progress * 100).toInt()}%'),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.category,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildInfoItem(Icons.people, '${course.enrolledStudents.length}'),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.menu_book, '${course.totalLessons} lessons'),
                const Spacer(),

                if (widget.user.isStudent)
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: Colors.grey[200],
                      color: _getProgressColor(course.progress),
                      minHeight: 8,
                    ),
                  ),

                if (widget.user.isStaff || widget.user.isAdmin)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          _showEditDialog(course);
                        },
                        color: Colors.blue,
                      ),
                      if (widget.user.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            _showDeleteDialog(course.id);
                          },
                          color: Colors.red,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.user.isStaff || widget.user.isAdmin) {
      return FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getTitle() {
    if (widget.user.isStudent) return 'My Courses';
    if (widget.user.isStaff) return 'My Teaching Courses';
    return 'All Courses';
  }

  String _getEmptyMessage() {
    if (widget.user.isStudent) return 'No courses enrolled';
    if (widget.user.isStaff) return 'No teaching courses';
    return 'No courses available';
  }

  String _getEmptySubMessage() {
    if (widget.user.isStudent) return 'Browse courses to get started';
    if (widget.user.isStaff) return 'Create courses to start teaching';
    return 'Create the first course to begin';
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Course Title'),
              onChanged: (value) {},
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) {},
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add course
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Course Title',
                hintText: course.title,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: course.description,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement update course
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // TODO: Implement delete course
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}