import 'package:flutter/material.dart';
import '../models/course_progress.dart';

class ProgressCard extends StatefulWidget {
  final CourseProgress course;

  const ProgressCard({super.key, required this.course});

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.course.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.courseName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          /// 🔥 Animated Progress
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressAnim.value,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blueAccent,
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          Text(
            "${widget.course.completedLessons}/${widget.course.totalLessons} lessons completed",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
