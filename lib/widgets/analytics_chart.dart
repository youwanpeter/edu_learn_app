import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
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
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white70],
            ),
          ),
        ],
      ),
    );
  }
}
