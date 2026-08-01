import '../../domain/ai_gateway/ai_provider.dart';
import 'ai_provider_registry.dart';

/// The engine selection policy — INTERNAL to the AI gateway (only the
/// gateway may know it).
///
/// One responsibility: choose the best provider for a request. The
/// request and the registry are the whole selection context, which is
/// what later allows richer policies — routing by cost, by language, by
/// latency, by quality, by availability, budget limiting, automatic
/// fallback, load balancing, performance metrics — as NEW
/// implementations of this contract, without touching the orchestrator,
/// the gateway or any caller. None of those criteria is implemented
/// today.
abstract interface class AIRoutingPolicy {
  /// The provider serving [request], or null when the policy has no
  /// opinion (the orchestrator then uses its default provider).
  AIProvider? select({
    required AIRequest request,
    required AIProviderRegistry registry,
  });
}

/// Today's whole policy: the provider registered for the request's task.
final class TaskRoutingPolicy implements AIRoutingPolicy {
  const TaskRoutingPolicy();

  @override
  AIProvider? select({
    required AIRequest request,
    required AIProviderRegistry registry,
  }) {
    final task = request.task;
    if (task == null) return null;
    return registry.providerFor(task);
  }
}
