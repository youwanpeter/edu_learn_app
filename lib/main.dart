import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/course_viewmodel.dart';
import 'viewmodels/lesson_viewmodel.dart';
import 'services/course_service.dart';
import 'services/lesson_service.dart';
import 'services/progress_service.dart';
import 'models/user.dart';
import 'views/dashboard_view.dart';
import 'views/course/course_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadDashboard(),
        ),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
        ChangeNotifierProvider(create: (_) => LessonViewModel()),
        Provider(create: (_) => CourseService()),
        Provider(create: (_) => LessonService()),
        Provider(create: (_) => ProgressService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const DashboardView(),
      ),
    );
  }
}