import 'package:flutter/material.dart';
import '../../../core/learning/models/lesson.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/learning/models/course.dart';
import '../../../core/learning/repository/lesson_repository.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/learning/engine/learning_engine.dart';

class EmployeeCourseCurriculumScreen extends StatelessWidget {
  final Course course;

  const EmployeeCourseCurriculumScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final lessons = LessonRepository.lessonsForCourse(course.id);
    final currentProgress = LearningEngine.currentProgress;

    debugPrint(course.id);
    debugPrint(lessons.length.toString());

    return Scaffold(
      backgroundColor: const Color(0xff071B5B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Programme'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            course.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${((currentProgress?.progress ?? course.progress) * 100).round()}% terminé',
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: currentProgress?.progress ?? course.progress,
            backgroundColor: Colors.white24,
            color: Colors.orangeAccent,
          ),

          const SizedBox(height: 28),

          ...lessons.map((lesson) {
            LessonStatus status;

            final currentIndex = lessons.indexWhere(
              (item) => item.id == currentProgress?.currentLessonId,
            );

            final lessonIndex = lessons.indexWhere(
              (item) => item.id == lesson.id,
            );

            if (lessonIndex < currentIndex) {
              status = LessonStatus.completed;
            } else if (lesson.id == currentProgress?.currentLessonId) {
              status = LessonStatus.current;
            } else {
              status = LessonStatus.locked;
            }

            return CurriculumLessonTile(
              number: lesson.order.toString().padLeft(2, '0'),
              title: lesson.title,
              duration: '${lesson.duration.inMinutes} min',
              status: status,
              onTap: status == LessonStatus.locked
                  ? null
                  : () {
                      AppRouter.openEmployeeLearningSession(context, lesson);
                    },
            );
          }).toList(),
        ],
      ),
    );
  }
}

enum LessonStatus { completed, current, locked }

class CurriculumLessonTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String number;
  final String title;
  final String duration;
  final LessonStatus status;

  const CurriculumLessonTile({
    super.key,
    required this.number,
    required this.title,
    required this.duration,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case LessonStatus.completed:
        icon = Icons.check_circle;
        color = Colors.greenAccent;
        label = 'Terminée';
        break;
      case LessonStatus.current:
        icon = Icons.play_circle_fill;
        color = Colors.orangeAccent;
        label = 'En cours';
        break;
      case LessonStatus.locked:
        icon = Icons.lock;
        color = Colors.white38;
        label = 'Verrouillée';
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration • $label',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
