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
    final percentage = (widget.course.progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ─── HEADER ROW ───
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.course.courseName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => Text(
                  "${(_progressAnim.value * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ─── PROGRESS BAR ───
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressAnim.value,
                  minHeight: 9,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blueAccent,
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          /// ─── FOOTER TEXT ───
          Text(
            "${widget.course.completedLessons} of ${widget.course.totalLessons} lessons completed",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}