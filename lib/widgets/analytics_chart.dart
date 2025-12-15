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

  final List<FlSpot> _dataPoints = const [
    FlSpot(0, 20),
    FlSpot(1, 35),
    FlSpot(2, 30),
    FlSpot(3, 55),
    FlSpot(4, 48),
    FlSpot(5, 60),
    FlSpot(6, 70),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDayLabel(double value) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[value.toInt()];
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 80,

          /// ─── GRID ───
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withValues(alpha: 0.15),
                strokeWidth: 1,
              );
            },
          ),

          /// ─── AXIS TITLES ───
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _getDayLabel(value),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          borderData: FlBorderData(show: false),

          /// ─── TOUCH INTERACTION ───
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 10,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  return LineTooltipItem(
                    "${spot.y.toInt()} min",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),

          /// ─── LINE DATA ───
          lineBarsData: [
            LineChartBarData(
              spots: _dataPoints,
              isCurved: true,
              barWidth: 4,

              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.blueAccent,
                  );
                },
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.05),
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
