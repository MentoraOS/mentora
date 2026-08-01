import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../authentication/authentication_session.dart';

/// THE gateway: the only implementation of [AIGateway], and the only
/// component allowed to talk to an [AIProvider].
///
/// Today it holds exactly one provider (the simulated one). The future
/// best-engine-per-task selection lives HERE the day it exists — callers
/// depend on [AIGateway] and never notice. No selection logic, no engine
/// and no generated content exist in this wave.
final class AIGatewayApplicationService implements AIGateway {
  const AIGatewayApplicationService({
    required AuthenticationSession session,
    required AIProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final AIProvider _provider;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const AIUnauthenticatedFailure();
    }
    if (request.isEmpty) {
      throw const AIInvalidRequestFailure();
    }

    try {
      return await _provider.execute(request);
    } on AIFailure {
      rethrow;
    } catch (error) {
      throw AIUnavailableFailure(cause: error);
    }
  }

  /// Whether the provider behind the gateway can currently serve.
  Future<bool> health() async {
    try {
      return await _provider.health();
    } catch (_) {
      // Fail closed: an unreachable provider is an unhealthy provider.
      return false;
    }
  }
}
