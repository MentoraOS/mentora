import 'ai_provider_registry.dart';
import 'routing_context.dart';
import 'routing_decision.dart';

/// The routing decision contract — INTERNAL to the orchestrator (no
/// business module ever knows it).
///
/// One responsibility: receive the context and the registry, return a
/// decision. That is the whole extension point: routing by cost,
/// language, quality, privacy, availability, latency, budget, fallback
/// or SLA arrive as NEW implementations of this interface — added like
/// simple modules, without modifying the gateway, the orchestrator, the
/// business pipelines or the existing providers. None of those criteria
/// exists today.
abstract interface class RoutingStrategy {
  RoutingDecision decide({
    required RoutingContext context,
    required AIProviderRegistry registry,
  });
}

/// Today's whole intelligence: the provider registered for the task —
/// the exact behavior Mentora already had, now explained and traced.
final class DefaultRoutingStrategy implements RoutingStrategy {
  const DefaultRoutingStrategy();

  static const String _name = 'DefaultRoutingStrategy';

  @override
  RoutingDecision decide({
    required RoutingContext context,
    required AIProviderRegistry registry,
  }) {
    final task = context.task;
    if (task == null) {
      return RoutingDecision(
        provider: null,
        strategy: _name,
        reason: 'No task on the request: the default provider serves it.',
        timestamp: DateTime.now(),
      );
    }

    final provider = registry.providerFor(task);
    if (provider == null) {
      return RoutingDecision(
        provider: null,
        strategy: _name,
        reason:
            'No provider registered for task "${task.name}": the default '
            'provider serves it.',
        timestamp: DateTime.now(),
      );
    }

    return RoutingDecision(
      provider: provider,
      strategy: _name,
      reason: 'Provider registered for task "${task.name}".',
      timestamp: DateTime.now(),
    );
  }
}
