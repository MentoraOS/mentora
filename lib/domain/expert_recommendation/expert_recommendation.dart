/// One intelligent expert recommendation — a PROPOSAL from the AI
/// layer.
///
/// The search engine remains the source of truth; this object never
/// replaces it and never modifies expert data. Immutable, exactly these
/// six facts. Confidence is qualitative ONLY — a number never appears
/// here.
final class ExpertRecommendation {
  final String recommendationId;
  final String expertId;
  final String title;
  final String explanation;
  final RecommendationConfidence confidence;
  final DateTime createdAt;

  factory ExpertRecommendation({
    required String recommendationId,
    required String expertId,
    required String title,
    required String explanation,
    required RecommendationConfidence confidence,
    required DateTime createdAt,
  }) {
    if (expertId.trim().isEmpty) {
      throw ArgumentError.value(expertId, 'expertId', 'must not be empty');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    if (explanation.trim().isEmpty) {
      throw ArgumentError.value(
        explanation,
        'explanation',
        'must not be empty',
      );
    }

    return ExpertRecommendation._(
      recommendationId: recommendationId,
      expertId: expertId,
      title: title,
      explanation: explanation,
      confidence: confidence,
      createdAt: createdAt,
    );
  }

  const ExpertRecommendation._({
    required this.recommendationId,
    required this.expertId,
    required this.title,
    required this.explanation,
    required this.confidence,
    required this.createdAt,
  });
}

/// The only confidence levels. Nothing else — no number, ever.
enum RecommendationConfidence { low, medium, high }
