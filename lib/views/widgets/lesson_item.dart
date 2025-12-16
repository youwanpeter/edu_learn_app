import 'package:flutter/material.dart';
import '../../models/lesson.dart';

class LessonItem extends StatelessWidget {
  final Lesson lesson;
  final String userRole;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const LessonItem({
    Key? key,
    required this.lesson,
    required this.userRole,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: lesson.isCompleted
              ? Border.all(color: Colors.green.shade100, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Lesson number/status
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: _getLessonColor(lesson),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.order.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(lesson),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    _getLessonIcon(lesson),
                    size: 16,
                    color: _getTextColor(lesson),
                  ),
                ],
              ),
            ),

            // Lesson content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: lesson.isLocked ? Colors.grey : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lesson.isCompleted)
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        if (lesson.isLocked)
                          const Icon(Icons.lock, color: Colors.orange, size: 18),
                      ],
                    ),

                    const SizedBox(height: 4),

                    if (lesson.videoUrl != null || lesson.pdfUrl != null)
                      Wrap(
                        spacing: 8,
                        children: [
                          if (lesson.videoUrl != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.video_library, size: 10, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Video',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (lesson.pdfUrl != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.picture_as_pdf, size: 10, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    Text(
                      lesson.content.length > 80
                          ? '${lesson.content.substring(0, 80)}...'
                          : lesson.content,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  if (userRole == 'student' && !lesson.isCompleted && !lesson.isLocked && onComplete != null)
                    IconButton(
                      icon: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 16, color: Colors.green),
                      ),
                      onPressed: onComplete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  if ((userRole == 'staff' || userRole == 'admin') && onEdit != null)
                    IconButton(
                      icon: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  if (userRole == 'admin' && onDelete != null)
                    IconButton(
                      icon: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete, size: 16, color: Colors.red),
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLessonColor(Lesson lesson) {
    if (lesson.isCompleted) return Colors.green.shade100;
    if (lesson.isLocked) return Colors.orange.shade100;
    return Colors.blue.shade100;
  }

  Color _getTextColor(Lesson lesson) {
    if (lesson.isCompleted) return Colors.green.shade800;
    if (lesson.isLocked) return Colors.orange.shade800;
    return Colors.blue.shade800;
  }

  IconData _getLessonIcon(Lesson lesson) {
    if (lesson.isCompleted) return Icons.check;
    if (lesson.isLocked) return Icons.lock;
    return Icons.play_circle_filled;
  }
}