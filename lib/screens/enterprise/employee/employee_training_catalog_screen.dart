import 'package:flutter/material.dart';
import '../../../core/learning/models/course.dart';
import 'employee_course_details_screen.dart';
import '../../../core/learning/repository/training_repository.dart';
import '../../../core/routing/app_router.dart';

class EmployeeTrainingCatalogScreen extends StatelessWidget {
  const EmployeeTrainingCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071B5B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Catalogue formations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Formations recommandées',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          ...TrainingRepository.courses.map(
            (course) => TrainingCourseCard(course: course),
          ),
        ],
      ),
    );
  }
}

class TrainingCourseCard extends StatelessWidget {
  final Course course;

  const TrainingCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        AppRouter.openEmployeeCourseDetails(context, course);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book, color: Colors.orangeAccent, size: 32),
            const SizedBox(height: 14),
            Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${course.category} • ${course.duration} • ${course.level}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: course.progress,
              backgroundColor: Colors.white24,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 8),
            Text(
              '${(course.progress * 100).round()}% terminé',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
