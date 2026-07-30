import '../models/lesson.dart';

class LessonRepository {
  LessonRepository._();

  static const List<Lesson> lessons = [
    Lesson(
      id: 'leadership_intro',
      courseId: 'leadership',
      title: 'Introduction au leadership',
      description: 'Comprendre les bases du leadership professionnel.',
      type: LessonType.video,
      order: 1,
      duration: Duration(minutes: 12),
      completed: true,
    ),
    Lesson(
      id: 'leadership_qualities',
      courseId: 'leadership',
      title: 'Les qualités d’un bon leader',
      description: 'Identifier les qualités essentielles d’un leader efficace.',
      type: LessonType.video,
      order: 2,
      duration: Duration(minutes: 18),
      completed: true,
    ),
    Lesson(
      id: 'decision_making',
      courseId: 'leadership',
      title: 'Prise de décision',
      description: 'Apprendre à prendre des décisions stratégiques.',
      type: LessonType.video,
      order: 3,
      duration: Duration(minutes: 25),
    ),
    Lesson(
      id: 'conflict_management',
      courseId: 'leadership',
      title: 'Gestion des conflits',
      description: 'Gérer les désaccords et tensions en entreprise.',
      type: LessonType.video,
      order: 4,
      duration: Duration(minutes: 20),
    ),
    Lesson(
      id: 'leadership_quiz',
      courseId: 'leadership',
      title: 'Quiz final',
      description: 'Valider les acquis de la formation.',
      type: LessonType.quiz,
      order: 5,
      duration: Duration(minutes: 10),
    ),
    Lesson(
      id: 'finance_intro',
      courseId: 'finance_strategique',
      title: 'Introduction à la finance stratégique',
      description: 'Comprendre les bases de la stratégie financière.',
      type: LessonType.video,
      order: 1,
      duration: Duration(minutes: 15),
      completed: true,
    ),
    Lesson(
      id: 'budget_management',
      courseId: 'finance_strategique',
      title: 'Gestion du budget',
      description: 'Apprendre à structurer et suivre un budget.',
      type: LessonType.video,
      order: 2,
      duration: Duration(minutes: 20),
      completed: true,
    ),
    Lesson(
      id: 'financial_decision',
      courseId: 'finance_strategique',
      title: 'Prise de décision financière',
      description: 'Savoir prendre des décisions économiques en entreprise.',
      type: LessonType.video,
      order: 3,
      duration: Duration(minutes: 25),
    ),
    Lesson(
      id: 'financial_risk',
      courseId: 'finance_strategique',
      title: 'Analyse des risques financiers',
      description: 'Identifier et réduire les risques financiers.',
      type: LessonType.video,
      order: 4,
      duration: Duration(minutes: 18),
    ),
    Lesson(
      id: 'finance_quiz',
      courseId: 'finance_strategique',
      title: 'Quiz final',
      description: 'Valider les acquis de la formation Finance stratégique.',
      type: LessonType.quiz,
      order: 5,
      duration: Duration(minutes: 10),
    ),
  ];

  static List<Lesson> lessonsForCourse(String courseId) {
    final result = lessons
        .where((lesson) => lesson.courseId == courseId)
        .toList();

    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  static Lesson? findById(String lessonId) {
    try {
      return lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (_) {
      return null;
    }
  }
}
