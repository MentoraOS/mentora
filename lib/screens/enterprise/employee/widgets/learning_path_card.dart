import 'package:flutter/material.dart';

import '../../../../core/identity/engine/identity_engine.dart';
import '../../../../core/learning/repository/learning_path_repository.dart';

class LearningPathCard extends StatelessWidget {
  const LearningPathCard({super.key});

  @override
  Widget build(BuildContext context) {
    final role = IdentityEngine.role ?? 'employee';
    final paths = LearningPathRepository.pathsForRole(role);

    if (paths.isEmpty) {
      return const SizedBox.shrink();
    }

    final path = paths.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mon parcours recommandé',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            path.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            path.description,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: path.progress,
            backgroundColor: Colors.white24,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 8),
          Text(
            '${(path.progress * 100).round()}% du parcours terminé · ${path.totalCourses} formations',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
