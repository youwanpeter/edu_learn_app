import '../models/course_progress.dart';
import '../models/analytics_model.dart';

class ProgressService {
  Future<List<CourseProgress>> fetchProgress() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      CourseProgress(
        courseName: "Flutter",
        completedLessons: 7,
        totalLessons: 10,
      ),
      CourseProgress(
        courseName: "Algorithms",
        completedLessons: 5,
        totalLessons: 8,
      ),
    ];
  }

  Future<AnalyticsData> fetchAnalytics() async {
    await Future.delayed(const Duration(seconds: 1));

    return AnalyticsData(
      weeklyLearningTime: [20, 40, 30, 60, 50, 45, 70],
      lessonsCompleted: 12,
      averageQuizScore: 82,
    );
  }
}
