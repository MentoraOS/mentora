class LearningProgress {
  final String id;

  final String userId;
  final String courseId;

  final String currentLessonId;

  final double progress;

  final Duration studyTime;

  final bool completed;

  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessAt;

  const LearningProgress({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.currentLessonId,
    required this.progress,
    required this.studyTime,
    this.completed = false,
    this.startedAt,
    this.completedAt,
    this.lastAccessAt,
  });
}
