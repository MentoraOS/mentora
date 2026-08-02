import '../../domain/ai_gateway/ai_provider.dart';
import 'ai_execution_trace.dart';
import 'ai_observability.dart';
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
    AIObservability? observability,
  }) : _defaultProvider = defaultProvider,
       _registry = registry,
       _strategy = strategy,
       _observability = observability ?? AIObservability();

  final AIProvider _defaultProvider;
  final AIProviderRegistry _registry;
  final RoutingStrategy _strategy;
  final AIObservability _observability;

  Future<AIResponse> execute(AIRequest request) async {
    final decision = _strategy.decide(
      context: RoutingContext.fromRequest(request),
      registry: _registry,
    );
    final provider = decision.provider ?? _defaultProvider;

    // Observability ONLY observes: the trace is opened before the call,
    // completed after success or error, and the result — response or
    // error — stays exactly what it was.
    final trace = _observability.observe(
      AIExecutionTrace(
        requestId: request.requestId,
        provider: provider.providerType.name,
        task: request.task,
        strategy: decision.strategy,
        startedAt: DateTime.now(),
        finishedAt: null,
        status: AIExecutionStatus.started,
      ),
    );

    try {
      final response = await provider.execute(request);
      _observability.observe(
        trace.finished(
          status: AIExecutionStatus.succeeded,
          finishedAt: DateTime.now(),
        ),
      );
      return response;
    } catch (error) {
      _observability.observe(
        trace.finished(
          status: AIExecutionStatus.failed,
          finishedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// Whether the default provider can currently serve.
  Future<bool> health() => _defaultProvider.health();
}
