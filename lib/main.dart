import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/study_material_viewmodel.dart';
import 'viewmodels/assignment_viewmodel.dart';
import 'views/study_material_screen.dart';
import 'views/assignment_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyMaterialViewModel()),
        ChangeNotifierProvider(create: (_) => AssignmentViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for testing
    const lessonId = 'lesson1';
    const userRole = 'lecturer';

    return StudyMaterialScreen(lessonId: lessonId, userRole: userRole);
  }
}
