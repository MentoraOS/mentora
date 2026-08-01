import '../../domain/ai_gateway/ai_provider.dart';
import 'ai_provider_registry.dart';
import 'routing_context.dart';
import 'routing_strategy.dart';

/// The brain behind the gateway — INTERNAL to it (only the gateway may
/// know the orchestrator; no business module ever does; and only the
/// orchestrator knows the routing strategy, context and decision).
///
/// Exactly one flow: receive the request, build the RoutingContext, ask
/// the RoutingStrategy for a RoutingDecision, obtain the provider (the
/// default one when the strategy has no opinion), delegate, return the
/// response VERBATIM. Never an analysis, never a transformation, never
/// business logic. Every decision is explainable, traceable,
/// replaceable and testable; richer strategies plug in as simple
/// modules and nothing external ever changes.
final class AIOrchestrator {
  AIOrchestrator({
    required AIProvider defaultProvider,
    required AIProviderRegistry registry,
    RoutingStrategy strategy = const DefaultRoutingStrategy(),
  }) : _defaultProvider = defaultProvider,
       _registry = registry,
       _strategy = strategy;

  final AIProvider _defaultProvider;
  final AIProviderRegistry _registry;
  final RoutingStrategy _strategy;

  Future<AIResponse> execute(AIRequest request) {
    final decision = _strategy.decide(
      context: RoutingContext.fromRequest(request),
      registry: _registry,
    );
    final provider = decision.provider ?? _defaultProvider;
    return provider.execute(request);
  }

  /// Whether the default provider can currently serve.
  Future<bool> health() => _defaultProvider.health();
}
