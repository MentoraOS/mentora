import '../../domain/expert_recommendation/expert_recommendation.dart';
import '../../domain/expert_recommendation/recommendation_provider.dart';
import '../authentication/authentication_session.dart';

/// Orchestrates intelligent expert recommendations.
///
/// Exactly four responsibilities: verify the session, build the demand,
/// call the provider, return the proposals. It depends ONLY on the
/// RecommendationProvider port — it never searches experts itself,
/// never reads storage, never talks to the gateway and never knows an
/// engine. The search engine stays the source of truth and this layer
/// never touches it.
final class RecommendationApplicationService {
  const RecommendationApplicationService({
    required AuthenticationSession session,
    required RecommendationProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final RecommendationProvider _provider;

  Future<List<ExpertRecommendation>> recommend({
    required String need,
    List<String> candidateExpertIds = const [],
  }) async {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const RecommendationUnauthenticatedFailure();
    }
    final expressedNeed = need.trim();
    if (expressedNeed.isEmpty) {
      throw const RecommendationInvalidRequestFailure();
    }

    try {
      return await _provider.recommend(
        need: expressedNeed,
        candidateExpertIds: candidateExpertIds,
      );
    } on RecommendationFailure {
      rethrow;
    } catch (error) {
      throw RecommendationUnavailableFailure(cause: error);
    }
  }
}
