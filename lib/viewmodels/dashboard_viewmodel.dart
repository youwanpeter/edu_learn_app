import 'package:flutter/material.dart';
import '../models/course_progress.dart';
import '../models/analytics_model.dart';
import '../services/progress_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final ProgressService _service = ProgressService();

  List<CourseProgress> progressList = [];
  AnalyticsData? analytics;

  bool isLoading = false;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    progressList = await _service.fetchProgress();
    analytics = await _service.fetchAnalytics();

    isLoading = false;
    notifyListeners();
  }
}
