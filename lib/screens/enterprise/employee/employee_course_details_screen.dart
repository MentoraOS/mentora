import 'package:flutter/material.dart';
import '../../../core/learning/engine/learning_engine.dart';
import 'package:provider/provider.dart';
import '../../../application/authentication/authentication_session.dart';
import '../../../core/learning/models/course.dart';
import '../../../core/routing/app_router.dart';

class EmployeeCourseDetailsScreen extends StatelessWidget {
  final Course course;

  const EmployeeCourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071B5B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Détails formation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.menu_book, color: Colors.orangeAccent, size: 56),
          const SizedBox(height: 20),

          Text(
            course.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${course.category} • ${course.duration} • ${course.level}',
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 24),

          Text(
            course.description,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),

          const SizedBox(height: 30),

          LinearProgressIndicator(
            value: course.progress,
            backgroundColor: Colors.white24,
            color: Colors.orangeAccent,
          ),

          const SizedBox(height: 10),

          Text(
            '${(course.progress * 100).round()}% terminé',
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                final userId = context
                    .read<AuthenticationSession>()
                    .currentUserId;

                if (userId == null || userId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Utilisateur introuvable')),
                  );
                  return;
                }

                LearningEngine.continueCourse(userId: userId, course: course);

                AppRouter.openEmployeeCourseCurriculum(context, course);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continuer la formation'),
            ),
          ),
        ],
      ),
    );
  }
}
