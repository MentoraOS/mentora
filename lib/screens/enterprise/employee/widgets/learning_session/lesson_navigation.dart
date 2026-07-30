import 'package:flutter/material.dart';

import '../../../../../core/learning/services/learning_progress_service.dart';
import 'package:provider/provider.dart';
import '../../../../../application/authentication/authentication_session.dart';

class LessonNavigation extends StatelessWidget {
  const LessonNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
                label: const Text('Leçon précédente'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Leçon suivante'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
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

              LearningProgressService.completeCurrentLesson(userId: userId);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leçon marquée comme terminée')),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context);
              });
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Marquer comme terminé'),
          ),
        ),
      ],
    );
  }
}
