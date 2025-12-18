import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/feature2_viewmodel.dart';

import 'views/dashboard_view.dart';

void main() {
  runApp(const EduLearnApp());
}

class EduLearnApp extends StatelessWidget {
  const EduLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ PROVIDE DASHBOARD VIEWMODEL
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadDashboard(),
        ),

        // ✅ PROVIDE FEATURE 2 VIEWMODEL
        ChangeNotifierProvider(create: (_) => Feature2ViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edu Learn App',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const DashboardView(), // ✅ SAFE NOW
      ),
    );
  }
}
