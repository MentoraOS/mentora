class AiBrief {
  final String summary;
  final List<String> objectives;
  final List<String> questions;
  final List<String> documents;
  final List<String> agenda;

  AiBrief({
    required this.summary,
    required this.objectives,
    required this.questions,
    required this.documents,
    required this.agenda,
  });
}

class MentoraAiService {
  Future<AiBrief> generateBrief(String userInput) async {
    await Future.delayed(const Duration(seconds: 1));

    if (userInput.trim().isEmpty) {
      return AiBrief(
        summary: 'Aucun besoin renseigné.',
        objectives: [],
        questions: [],
        documents: [],
        agenda: [],
      );
    }

    return AiBrief(
      summary:
          'Le client souhaite obtenir une expertise personnalisée concernant : "$userInput". '
          'L’objectif est de clarifier la situation, identifier les meilleures options et préparer un plan d’action concret.',

      objectives: [
        'Clarifier le besoin principal du client',
        'Identifier les risques et opportunités',
        'Obtenir des recommandations adaptées',
        'Définir les prochaines actions à réaliser',
      ],

      questions: [
        'Quelle est la meilleure stratégie à adopter ?',
        'Quels sont les pièges à éviter ?',
        'Quel budget ou quelles ressources prévoir ?',
        'Quelles sont les étapes prioritaires après la consultation ?',
      ],

      documents: [
        'Business Plan',
        'Présentation du projet',
        'Étude de marché',
        'Prévisions financières',
      ],

      agenda: [
        '10 min : Présentation du contexte',
        '15 min : Analyse du problème',
        '20 min : Recommandations de l’expert',
        '10 min : Questions/réponses',
        '5 min : Plan d’action final',
      ],
    );
  }
}
