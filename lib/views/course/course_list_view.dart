import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../viewmodels/course_viewmodel.dart';
import 'add_edit_course_view.dart';
import 'course_detail_view.dart';

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
        actions: _buildAppBarActions(),
      ),
      body: Consumer<CourseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.courses.isEmpty) {
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptySubMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (widget.user.isStaff || widget.user.isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () => _navigateToAddCourse(),
                        child: const Text('Create Your First Course'),
                      ),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadCourses(widget.user),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.courses.length,
              itemBuilder: (context, index) {
                final course = viewModel.courses[index];
                return _buildCourseCard(context, course, viewModel);
              },
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, CourseViewModel viewModel) {
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, color: Colors.blue, size: 24),
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

            // Category
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

            // Description
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Footer
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
                        onPressed: () => _navigateToEditCourse(course),
                        color: Colors.blue,
                        tooltip: 'Edit Course',
                      ),
                      if (widget.user.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteCourse(context, course.id, viewModel),
                          color: Colors.red,
                          tooltip: 'Delete Course',
                        ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // View Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToCourseDetail(course.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  foregroundColor: Colors.blue,
                ),
                child: const Text('View Details'),
              ),
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

  List<Widget> _buildAppBarActions() {
    if (widget.user.isAdmin) {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _searchCourses,
          tooltip: 'Search Courses',
        ),
      ];
    }
    return [];
  }

  Widget? _buildFloatingActionButton() {
    if (widget.user.isStaff || widget.user.isAdmin) {
      return FloatingActionButton(
        onPressed: _navigateToAddCourse,
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Course',
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

  void _navigateToCourseDetail(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailView(
          courseId: courseId,
          user: widget.user,
        ),
      ),
    );
  }

  void _navigateToAddCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCourseView(
          user: widget.user,
        ),
      ),
    ).then((_) {
      Provider.of<CourseViewModel>(context, listen: false).loadCourses(widget.user);
    });
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
      Provider.of<CourseViewModel>(context, listen: false).loadCourses(widget.user);
    });
  }

  Future<void> _deleteCourse(BuildContext context, String courseId, CourseViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course? All lessons will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.deleteCourse(courseId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: ${viewModel.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchCourses() {
    showSearch(
      context: context,
      delegate: _CourseSearchDelegate(widget.user),
    );
  }
}

class _CourseSearchDelegate extends SearchDelegate {
  final User user;

  _CourseSearchDelegate(this.user);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final viewModel = Provider.of<CourseViewModel>(context, listen: false);
    final filteredCourses = viewModel.courses.where((course) {
      return course.title.toLowerCase().contains(query.toLowerCase()) ||
          course.description.toLowerCase().contains(query.toLowerCase()) ||
          course.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No courses found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: Text(course.title),
            subtitle: Text(course.category),
            trailing: user.isStudent
                ? Text('${(course.progress * 100).toInt()}%')
                : null,
            onTap: () {
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailView(
                    courseId: course.id,
                    user: user,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}