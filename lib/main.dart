import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/study_material_viewmodel.dart';
import 'viewmodels/assignment_viewmodel.dart';
import 'viewmodels/course_viewmodel.dart';
import 'viewmodels/lesson_viewmodel.dart';
import 'services/database_helper.dart';

import 'views/dashboard_view.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.insertInitialData();

  print('✅ Database initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dashboard
        ChangeNotifierProvider(
          create: (_) {
            final viewModel = DashboardViewModel();
            viewModel.loadDashboard();
            return viewModel;
          },
        ),

        // Study Materials
        ChangeNotifierProvider(
          create: (_) => StudyMaterialViewModel(),
        ),

        // Assignments
        ChangeNotifierProvider(
          create: (_) => AssignmentViewModel(),
        ),

        // Courses - FIXED: Initialize here
        ChangeNotifierProvider(
          create: (_) => CourseViewModel(),
        ),

        // Lessons
        ChangeNotifierProvider(
          create: (_) => LessonViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const DashboardView(),
      ),
    );
  }
}