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
import 'views/login_view.dart';
import 'views/signup_view.dart';
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
        // Dashboard provider (your friend's code)
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel()..loadDashboard(),
        ),

        // Your Feature 1 providers
        ChangeNotifierProvider(create: (context) => CourseViewModel()),
        ChangeNotifierProvider(create: (context) => LessonViewModel()),

        // Services
        Provider(create: (context) => CourseService()),
        Provider(create: (context) => LessonService()),
        Provider(create: (context) => ProgressService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey.shade50,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const DashboardView(),
          '/login': (context) => LoginView(),
          '/signup': (context) => SignUpView(),
          '/courses': (context) {
            // Create a mock user for testing
            final mockUser = User(
              id: 'student1',
              name: 'Youwan',
              email: 'youwan@example.com',
              role:
                  'student', // Change this to test: 'student', 'staff', or 'admin'
            );
            return CourseListView(user: mockUser);
          },
        },
      ),
    );
  }
}
