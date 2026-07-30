import 'package:flutter/material.dart';
import '../../enterprise/employee/widgets/learning_session/lesson_header.dart';
import '../../enterprise/employee/widgets/learning_session/lesson_player.dart';
import '../../enterprise/employee/widgets/learning_session/lesson_resources.dart';
import '../../enterprise/employee/widgets/learning_session/lesson_notes.dart';
import '../../enterprise/employee/widgets/learning_session/lesson_ai_assistant.dart';
import '../../enterprise/employee/widgets/learning_session/lesson_navigation.dart';

class EmployeeLearningSessionScreen extends StatelessWidget {
  const EmployeeLearningSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071B5B),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Learning Session"),
      ),

      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            LessonHeader(),

            SizedBox(height: 20),

            LessonPlayer(),

            SizedBox(height: 24),

            LessonResources(),

            SizedBox(height: 24),

            LessonNotes(),

            SizedBox(height: 24),

            LessonAIAssistant(),

            SizedBox(height: 24),

            LessonNavigation(),
          ],
        ),
      ),
    );
  }
}
