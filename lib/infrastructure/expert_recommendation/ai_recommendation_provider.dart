import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../../domain/expert_recommendation/expert_recommendation.dart';
import '../../domain/expert_recommendation/recommendation_provider.dart';

/// The real recommendation provider: turns the expressed need into
/// individual expert proposals by routing through the AI GATEWAY ONLY —
/// never an engine SDK, never a network call, never the search engine,
/// never storage. The gateway routes [AITask.recommendation] to
/// whichever engine is registered for it; this class never knows which.
final class AIRecommendationProvider implements RecommendationProvider {
  const AIRecommendationProvider({required AIGateway gateway})
    : _gateway = gateway;

  final AIGateway _gateway;

  @override
  Future<List<ExpertRecommendation>> recommend({
    required String need,
    List<String> candidateExpertIds = const [],
  }) async {
    final response = await _gateway.execute(
      AIRequest(
        requestId: 'recommendation_${need.hashCode.toUnsigned(20)}',
        task: AITask.recommendation,
        text: buildPrompt(need: need, candidateExpertIds: candidateExpertIds),
        context: {'candidateCount': candidateExpertIds.length},
      ),
    );

    final text = response.text?.trim();
    if (response.status != AIResponseStatus.accepted) {
      throw StateError('The recommendation engine rejected the request.');
    }
    // An engine with nothing relevant proposes nothing.
    if (text == null || text.isEmpty) return const [];

    final recommendations = <ExpertRecommendation>[];
    var lineIndex = 0;
    for (final line in text.split('\n')) {
      if (line.trim().isEmpty) continue;
      final recommendation = parseLine(
        recommendationId: 'rec_${lineIndex++}',
        line: line,
        candidateExpertIds: candidateExpertIds,
        createdAt: DateTime.now(),
      );
      if (recommendation != null) recommendations.add(recommendation);
    }
    return List.unmodifiable(recommendations);
  }

  @override
  Future<bool> health() async => true;

  /// THE recommendation prompt — it belongs HERE, in Infrastructure, and
  /// nowhere else. It instructs the engine to propose ONLY relevant
  /// experts, to NEVER invent one, to NEVER modify any data and to
  /// briefly explain each proposal. The strict output protocol is one
  /// recommendation per line: `CONFIDENCE;EXPERT_ID;TITLE;EXPLANATION`
  /// with CONFIDENCE in LOW, MEDIUM or HIGH; anything else is dropped,
  /// never guessed.
  static String buildPrompt({
    required String need,
    required List<String> candidateExpertIds,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Tu recommandes des experts Mentora pour le besoin exprimé par un '
        'client. Tu proposes UNIQUEMENT des experts pertinents, tu '
        'n’inventes JAMAIS un expert, tu ne modifies JAMAIS leurs '
        'données, et tu expliques brièvement chaque proposition.',
      )
      ..writeln()
      ..writeln('Besoin exprimé : $need');

    if (candidateExpertIds.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(
          'Tu ne peux recommander QUE parmi ces identifiants d’experts : '
          '${candidateExpertIds.join(', ')}. Si aucun n’est pertinent, ne '
          'réponds rien.',
        );
    }

    buffer
      ..writeln()
      ..writeln(
        'Réponds UNIQUEMENT avec une recommandation par ligne, au format '
        'exact : CONFIDENCE;EXPERT_ID;TITLE;EXPLANATION — où CONFIDENCE '
        'vaut LOW, MEDIUM ou HIGH. Aucun autre texte.',
      );
    return buffer.toString();
  }

  /// Parses one engine line into ONE recommendation; unparseable lines —
  /// and, when candidates are known, any expert outside them — are
  /// dropped, never guessed: an expert is never invented.
  static ExpertRecommendation? parseLine({
    required String recommendationId,
    required String line,
    required List<String> candidateExpertIds,
    required DateTime createdAt,
  }) {
    final parts = line.split(';');
    if (parts.length < 4) return null;

    final confidence = switch (parts.first.trim().toUpperCase()) {
      'LOW' => RecommendationConfidence.low,
      'MEDIUM' => RecommendationConfidence.medium,
      'HIGH' => RecommendationConfidence.high,
      _ => null,
    };
    final expertId = parts[1].trim();
    final title = parts[2].trim();
    final explanation = parts.sublist(3).join(';').trim();
    if (confidence == null ||
        expertId.isEmpty ||
        title.isEmpty ||
        explanation.isEmpty) {
      return null;
    }
    if (candidateExpertIds.isNotEmpty &&
        !candidateExpertIds.contains(expertId)) {
      return null;
    }

    return ExpertRecommendation(
      recommendationId: recommendationId,
      expertId: expertId,
      title: title,
      explanation: explanation,
      confidence: confidence,
      createdAt: createdAt,
    );
  }
}
