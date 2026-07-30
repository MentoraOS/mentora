import '../models/learning_progress.dart';

class LearningProgressRepository {
  LearningProgressRepository._();

  static final List<LearningProgress> _progress = [
    LearningProgress(
      id: 'progress_leadership',

      userId: 'current_user',

      courseId: 'leadership',

      currentLessonId: 'decision_making',

      progress: 0.65,

      studyTime: const Duration(hours: 3, minutes: 42),

      startedAt: DateTime.now(),

      lastAccessAt: DateTime.now(),
    ),
  ];

  static LearningProgress? findByCourse(String userId, String courseId) {
    try {
      return _progress.firstWhere(
        (progress) =>
            progress.userId == userId && progress.courseId == courseId,
      );
    } catch (_) {
      return null;
    }
  }

  static void saveProgress(LearningProgress progress) {
    final index = _progress.indexWhere((item) => item.id == progress.id);

    if (index == -1) {
      _progress.add(progress);
    } else {
      _progress[index] = progress;
    }
  }
}
