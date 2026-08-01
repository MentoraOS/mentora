import '../../domain/ai_gateway/ai_provider.dart';
import 'ai_provider_registry.dart';
import 'ai_routing_policy.dart';

/// The brain behind the gateway — INTERNAL to it (only the gateway may
/// know the orchestrator; no business module ever does).
///
/// Exactly one flow: receive the request, ask the routing policy, obtain
/// the provider (the default one when the policy has no opinion),
/// delegate, return the response VERBATIM. Never an analysis, never a
/// transformation, never business logic. Engines — any of them, from
/// any vendor to local models — are interchangeable behind the registry
/// and the policy; the gateway stays the single door and no caller ever
/// changes.
final class AIOrchestrator {
  AIOrchestrator({
    required AIProvider defaultProvider,
    required AIProviderRegistry registry,
    required AIRoutingPolicy policy,
  }) : _defaultProvider = defaultProvider,
       _registry = registry,
       _policy = policy;

  final AIProvider _defaultProvider;
  final AIProviderRegistry _registry;
  final AIRoutingPolicy _policy;

  Future<AIResponse> execute(AIRequest request) {
    final provider =
        _policy.select(request: request, registry: _registry) ??
        _defaultProvider;
    return provider.execute(request);
  }

  /// Whether the default provider can currently serve.
  Future<bool> health() => _defaultProvider.health();
}
