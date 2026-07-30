import '../engine/learning_engine.dart';

class LearningProgressService {
  LearningProgressService._();

  static void completeCurrentLesson({required String userId}) {
    LearningEngine.completeCurrentLesson(userId: userId);
  }

  static double currentProgress() {
    return LearningEngine.currentProgress?.progress ?? 0;
  }

  static bool courseCompleted() {
    return LearningEngine.currentProgress?.completed ?? false;
  }

  static String? currentLessonId() {
    return LearningEngine.currentProgress?.currentLessonId;
  }
}
