import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../viewmodels/assignment_viewmodel.dart';

class AssignmentScreen extends StatefulWidget {
  final String lessonId;
  final String userRole;
  final Function(Assignment) onEdit; // Callback for edit

  const AssignmentScreen({
    super.key,
    required this.lessonId,
    required this.userRole,
    required this.onEdit,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssignmentViewModel>(
        context,
        listen: false,
      ).loadAssignments(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canEdit = widget.userRole == 'admin' || widget.userRole == 'lecturer';

    // NO SCAFFOLD HERE - This prevents the double button glitch
    return Consumer<AssignmentViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.assignments.isEmpty) {
          return Center(
            child: Text(
              "No assignments available",
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.assignments.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildAssignmentCard(
              context,
              viewModel.assignments[index],
              canEdit,
            );
          },
        );
      },
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    Assignment assignment,
    bool canEdit,
  ) {
    bool isPdf = assignment.type == 'pdf';
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
                    assignment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assignment.description,
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
                    // Call the parent's method
                    widget.onEdit(assignment);
                  } else if (value == 'delete') {
                    _confirmDelete(context, assignment);
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

  void _confirmDelete(BuildContext context, Assignment assignment) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Assignment"),
          content: const Text("Are you sure?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Provider.of<AssignmentViewModel>(
                  context,
                  listen: false,
                ).deleteAssignment(assignment.id, widget.lessonId);
                Navigator.pop(dialogContext);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
