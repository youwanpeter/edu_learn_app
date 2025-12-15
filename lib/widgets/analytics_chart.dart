import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsChart extends StatefulWidget {
  const AnalyticsChart({super.key});

  @override
  State<AnalyticsChart> createState() => _AnalyticsChartState();
}

class _AnalyticsChartState extends State<AnalyticsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 20),
                FlSpot(1, 35),
                FlSpot(2, 30),
                FlSpot(3, 55),
                FlSpot(4, 48),
                FlSpot(5, 60),
                FlSpot(6, 70),
              ],
              isCurved: true,
              barWidth: 4,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.white70],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
