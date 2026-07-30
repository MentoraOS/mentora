class LearningPath {
  final String id;
  final String title;
  final String description;

  final String targetRole;
  final List<String> courseIds;

  final bool mandatory;
  final double progress;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    required this.courseIds,
    this.mandatory = false,
    this.progress = 0,
  });

  int get totalCourses => courseIds.length;
}
