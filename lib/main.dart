import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/study_material_viewmodel.dart';
import 'viewmodels/assignment_viewmodel.dart';
import 'viewmodels/course_viewmodel.dart';
import 'viewmodels/lesson_viewmodel.dart';
import 'models/user.dart';

import 'views/dashboard_view.dart';

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
          create: (_) {
            DashboardViewModel viewModel = DashboardViewModel();
            viewModel.loadDashboard();
            return viewModel;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => StudyMaterialViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => CourseViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => LessonViewModel(),
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const DashboardView(),
      ),
    );
  }
}