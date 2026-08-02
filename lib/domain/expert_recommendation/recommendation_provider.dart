import 'expert_recommendation.dart';

/// Expert recommendation boundary — CONTRACT ONLY, exactly two methods.
///
/// The provider receives the client's expressed need (and, from future
/// waves, the candidate expert identities produced by the search
/// engine) and returns proposals. It never searches, never reads
/// storage, never modifies expert data. The implementation routes
/// through the AI gateway; engines are added by registering another
/// gateway adapter and nothing in the business layers changes. Future
/// capabilities — personalization, user learning, contextual,
/// geographic and multilingual recommendations, memory-informed and
/// performance-informed proposals, hybrid search+AI, A/B testing,
/// continuous optimization — build behind this same contract.
abstract interface class RecommendationProvider {
  /// Proposes experts for the expressed [need]. When [candidateExpertIds]
  /// is provided (by future hybrid waves), proposals outside it are
  /// impossible — an expert is NEVER invented.
  Future<List<ExpertRecommendation>> recommend({
    required String need,
    List<String> candidateExpertIds,
  });

  /// Whether the engine behind the provider can currently serve.
  Future<bool> health();
}

sealed class RecommendationFailure implements Exception {
  const RecommendationFailure();
}

final class RecommendationUnauthenticatedFailure
    extends RecommendationFailure {
  const RecommendationUnauthenticatedFailure();
}

/// A recommendation needs an expressed need — an empty one fails closed.
final class RecommendationInvalidRequestFailure
    extends RecommendationFailure {
  const RecommendationInvalidRequestFailure();
}

final class RecommendationUnavailableFailure extends RecommendationFailure {
  const RecommendationUnavailableFailure({required this.cause});

  final Object cause;
}
