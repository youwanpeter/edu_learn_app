import 'package:flutter/material.dart';
import 'feature2/study_materials_assignments_screen.dart';

class DemoLauncher extends StatefulWidget {
  const DemoLauncher({super.key});

  @override
  State<DemoLauncher> createState() => _DemoLauncherState();
}

class _DemoLauncherState extends State<DemoLauncher> {
  final TextEditingController _courseCtrl = TextEditingController(
    text: "CS101",
  );

  String _role = "student";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demo Launcher (Feature 2)"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Role",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _role,
              items: const [
                DropdownMenuItem(value: "student", child: Text("Student")),
                DropdownMenuItem(value: "lecturer", child: Text("Lecturer")),
                DropdownMenuItem(value: "staff", child: Text("Staff")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) => setState(() => _role = v!),
            ),

            const SizedBox(height: 24),
            const Text(
              "Course ID",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _courseCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. CS101",
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Open Study Materials"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudyMaterialsAssignmentsScreen(
                        courseId: _courseCtrl.text.trim(),
                        userRole: _role,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
