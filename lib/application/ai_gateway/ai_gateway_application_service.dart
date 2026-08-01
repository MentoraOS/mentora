import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../authentication/authentication_session.dart';
import 'ai_orchestrator.dart';
import 'ai_provider_registry.dart';

/// THE gateway: the only implementation of [AIGateway], and the only
/// component allowed to talk to an [AIProvider].
///
/// Its public contract never changes for callers; internally every
/// request flows through the single chain gateway -> AIOrchestrator ->
/// routing strategy -> registry -> provider. All engine selection is
/// centralized there — ONLY the gateway knows the orchestrator exists,
/// and only the orchestrator knows the routing internals.
final class AIGatewayApplicationService implements AIGateway {
  AIGatewayApplicationService({
    required AuthenticationSession session,
    required AIProvider provider,
    Map<AITask, AIProvider> taskProviders = const {},
  }) : _session = session,
       _orchestrator = AIOrchestrator(
         defaultProvider: provider,
         registry: AIProviderRegistry.from(taskProviders),
       );

  final AuthenticationSession _session;
  final AIOrchestrator _orchestrator;

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
      return await _orchestrator.execute(request);
    } on AIFailure {
      rethrow;
    } catch (error) {
      throw AIUnavailableFailure(cause: error);
    }
  }

  /// Whether the engine behind the gateway can currently serve.
  Future<bool> health() async {
    try {
      return await _orchestrator.health();
    } catch (_) {
      // Fail closed: an unreachable provider is an unhealthy provider.
      return false;
    }
  }
}
