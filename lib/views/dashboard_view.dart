import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_footer.dart';
import '../widgets/progress_card.dart';
import '../widgets/analytics_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          /// ===== HEADER =====
          const DashboardHeader(),

          /// ===== BODY =====
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ---- Courses Section ----
                        const Text(
                          "Your Courses",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (vm.progressList.isEmpty)
                          const Text(
                            "No progress data available",
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ...vm.progressList.map(
                            (course) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: ProgressCard(course: course),
                            ),
                          ),

                        const SizedBox(height: 28),

                        /// ---- Analytics Section ----
                        const Text(
                          "Weekly Analytics",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Chart
                        Container(
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 0, 0),
                                Color.fromARGB(255, 138, 4, 4),
                              ],
                            ),
                          ),
                          child: const AnalyticsChart(),
                        ),

                        const SizedBox(height: 20),

                        /// ---- Stats ----
                        if (vm.analytics != null)
                          Row(
                            children: [
                              _StatTile(
                                icon: Icons.book_rounded,
                                label: "Lessons",
                                value: vm.analytics!.lessonsCompleted
                                    .toString(),
                              ),
                              const SizedBox(width: 12),
                              _StatTile(
                                icon: Icons.star_rounded,
                                label: "Quiz Avg",
                                value: "${vm.analytics!.averageQuizScore}%",
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),

          /// ===== FOOTER =====
          const DashboardFooter(currentIndex: 0),
        ],
      ),
    );
  }
}

/// ================= STAT TILE =================
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
