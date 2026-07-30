import '../models/learning_path.dart';

class LearningPathRepository {
  LearningPathRepository._();

  static const List<LearningPath> paths = [
    LearningPath(
      id: 'finance_member_path',
      title: 'Parcours Finance Member',
      description:
          'Un parcours conçu pour renforcer les compétences financières, communicationnelles et professionnelles des membres Finance.',
      targetRole: 'finance_member',
      courseIds: [
        'leadership',
        'finance_strategique',
        'communication_entreprise',
      ],
      mandatory: true,
      progress: 0.52,
    ),

    LearningPath(
      id: 'finance_manager_path',
      title: 'Parcours Finance Manager',
      description:
          'Un parcours avancé pour piloter les finances, gérer les budgets et accompagner les décisions stratégiques.',
      targetRole: 'finance_manager',
      courseIds: [
        'finance_strategique',
        'leadership',
        'communication_entreprise',
      ],
      mandatory: true,
      progress: 0.38,
    ),

    LearningPath(
      id: 'hr_admin_path',
      title: 'Parcours RH Admin',
      description:
          'Un parcours pour gérer les collaborateurs, les formations, l’intégration et la communication RH.',
      targetRole: 'hr_admin',
      courseIds: ['communication_entreprise', 'leadership'],
      mandatory: true,
      progress: 0.25,
    ),

    LearningPath(
      id: 'director_path',
      title: 'Parcours Directeur',
      description:
          'Un parcours stratégique pour dirigeants : leadership, pilotage, finance et vision organisationnelle.',
      targetRole: 'director',
      courseIds: [
        'leadership',
        'finance_strategique',
        'communication_entreprise',
      ],
      mandatory: false,
      progress: 0.18,
    ),
  ];

  static List<LearningPath> pathsForRole(String role) {
    return paths.where((path) => path.targetRole == role).toList();
  }

  static LearningPath? findById(String id) {
    try {
      return paths.firstWhere((path) => path.id == id);
    } catch (_) {
      return null;
    }
  }
}
