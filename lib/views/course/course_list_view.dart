
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
bool _showAvailableCourses = false;
List<Course> _availableCourses = [];

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
_loadCourses();
});
}

Future<void> _loadCourses() async {
final viewModel = Provider.of<CourseViewModel>(context, listen: false);
await viewModel.loadCourses(widget.user);

// If student, also load available courses
if (widget.user.isStudent) {
_availableCourses = await viewModel.loadAvailableCourses(widget.user.id);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(_getAppBarTitle()),
actions: widget.user.isStaff ? _buildStaffActions() : null,
),
body: Consumer<CourseViewModel>(
builder: (context, viewModel, child) {
return _buildBody(viewModel);
},
),
floatingActionButton: widget.user.isStaff ? _buildFloatingActionButton() : null,
);
}

Widget _buildBody(CourseViewModel viewModel) {
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
onPressed: _loadCourses,
child: const Text('Retry'),
),
],
),
);
}

if (widget.user.isStudent) {
return _buildStudentView(viewModel);
} else {
return _buildStaffView(viewModel);
}
}

Widget _buildStudentView(CourseViewModel viewModel) {
return Column(
children: [
// Toggle between enrolled and available courses
Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Expanded(
child: ChoiceChip.elevated(
label: Text('My Courses (${viewModel.courses.length})'),
selected: !_showAvailableCourses,
onSelected: (selected) {
if (selected) {
setState(() {
_showAvailableCourses = false;
});
}
},
),
),
const SizedBox(width: 8),
Expanded(
child: ChoiceChip.elevated(
label: Text('Available Courses (${_availableCourses.length})'),
selected: _showAvailableCourses,
onSelected: (selected) {
if (selected) {
setState(() {
_showAvailableCourses = true;
});
}
},
),
),
],
),
),

Expanded(
child: RefreshIndicator(
onRefresh: () => _loadCourses(),
child: _showAvailableCourses
? _buildAvailableCoursesList()
    : _buildEnrolledCoursesList(viewModel),
),
),
],
);
}

Widget _buildEnrolledCoursesList(CourseViewModel viewModel) {
if (viewModel.courses.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.school, size: 80, color: Colors.grey),
const SizedBox(height: 16),
const Text(
'No courses enrolled',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
),
const SizedBox(height: 8),
const Text(
'Browse available courses to get started',
textAlign: TextAlign.center,
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 20),
ElevatedButton(
onPressed: () {
setState(() {
_showAvailableCourses = true;
});
},
child: const Text('Browse Available Courses'),
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
return _buildCourseCard(context, course, viewModel);
},
);
}

Widget _buildAvailableCoursesList() {
if (_availableCourses.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.check_circle, size: 80, color: Colors.green),
const SizedBox(height: 16),
const Text(
'No available courses',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
),
const SizedBox(height: 8),
const Text(
'You are enrolled in all available courses',
textAlign: TextAlign.center,
style: TextStyle(color: Colors.grey),
),
],
),
);
}

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: _availableCourses.length,
itemBuilder: (context, index) {
final course = _availableCourses[index];
return Card(
margin: const EdgeInsets.only(bottom: 16),
child: ListTile(
leading: const Icon(Icons.school, color: Colors.blue),
title: Text(course.title),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(course.category),
Text('By ${course.instructorName}'),
],
),
trailing: ElevatedButton(
onPressed: () => _enrollInCourse(context, course.id),
child: const Text('Enroll'),
),
),
);
},
);
}

Widget _buildStaffView(CourseViewModel viewModel) {
if (viewModel.courses.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.school, size: 80, color: Colors.grey),
const SizedBox(height: 16),
const Text(
'No teaching courses',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
),
const SizedBox(height: 8),
const Text(
'Create your first course to start teaching',
textAlign: TextAlign.center,
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 20),
ElevatedButton(
onPressed: () => _navigateToAddCourse(),
child: const Text('Create Your First Course'),
),
],
),
);
}

return RefreshIndicator(
onRefresh: () => _loadCourses(),
child: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: viewModel.courses.length,
itemBuilder: (context, index) {
final course = viewModel.courses[index];
return _buildCourseCard(context, course, viewModel);
},
),
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

// Instructor info (for students)
if (widget.user.isStudent)
Row(
children: [
const Icon(Icons.person, size: 16, color: Colors.grey),
const SizedBox(width: 4),
Text(
'Instructor: ${course.instructorName}',
style: const TextStyle(color: Colors.grey),
),
],
),

const SizedBox(height: 8),

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

if (widget.user.isStaff)
Row(
children: [
IconButton(
icon: const Icon(Icons.edit, size: 20),
onPressed: () => _navigateToEditCourse(course),
color: Colors.blue,
tooltip: 'Edit Course',
),
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

List<Widget> _buildStaffActions() {
return [
IconButton(
icon: const Icon(Icons.refresh),
onPressed: _loadCourses,
tooltip: 'Refresh',
),
];
}

Widget? _buildFloatingActionButton() {
if (widget.user.isStaff) {
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

String _getAppBarTitle() {
if (widget.user.isStudent) {
return _showAvailableCourses ? 'Available Courses' : 'My Courses';
} else {
return 'My Teaching Courses';
}
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
_loadCourses();
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
_loadCourses();
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
final success = await viewModel.deleteCourse(courseId, widget.user);
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

Future<void> _enrollInCourse(BuildContext context, String courseId) async {
final viewModel = Provider.of<CourseViewModel>(context, listen: false);
try {
await viewModel.enrollStudent(courseId, widget.user.id);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Successfully enrolled in course!'),
backgroundColor: Colors.green,
),
);
_loadCourses();
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
