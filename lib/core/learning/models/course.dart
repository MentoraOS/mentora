class Course {
  final String id;
  final String title;
  final String category;
  final String description;
  final String level;
  final String duration;
  final double progress;

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.level,
    required this.duration,
    this.progress = 0,
  });
}
