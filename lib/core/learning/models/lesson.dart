enum LessonType { video, live, article, quiz, assignment }

class Lesson {
  final String id;
  final String courseId;

  final String title;
  final String description;

  final LessonType type;

  final int order;

  final Duration duration;

  final bool completed;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    required this.duration,
    this.completed = false,
  });
}
