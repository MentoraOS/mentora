import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../authentication/authentication_session.dart';

/// THE gateway: the only implementation of [AIGateway], and the only
/// component allowed to talk to an [AIProvider].
///
/// Routing is BY TASK: each registered [AITask] maps to the engine
/// serving it; a request without a task goes to the default provider.
/// The future best-engine-per-task selection refines this map HERE —
/// callers depend on [AIGateway] and never notice.
final class AIGatewayApplicationService implements AIGateway {
  const AIGatewayApplicationService({
    required AuthenticationSession session,
    required AIProvider provider,
    Map<AITask, AIProvider> taskProviders = const {},
  }) : _session = session,
       _provider = provider,
       _taskProviders = taskProviders;

  final AuthenticationSession _session;

  /// The default engine for task-less requests.
  final AIProvider _provider;

  /// One engine per routed task.
  final Map<AITask, AIProvider> _taskProviders;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const AIUnauthenticatedFailure();
    }
    if (request.isEmpty) {
      throw const AIInvalidRequestFailure();
    }

    final provider = switch (request.task) {
      null => _provider,
      final task => _taskProviders[task] ?? _provider,
    };

    try {
      return await provider.execute(request);
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
