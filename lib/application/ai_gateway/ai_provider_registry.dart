import '../../domain/ai_gateway/ai_provider.dart';

/// The engine registry — INTERNAL to the AI gateway (only the gateway
/// may know it).
///
/// Exactly three responsibilities: register, unregister and find the
/// provider serving a task. Nothing else — no selection, no analysis,
/// no fallback: those belong to the routing policy and the
/// orchestrator. Duplicates are refused: one task, one registered
/// engine, replaced only through an explicit unregister.
final class AIProviderRegistry {
  AIProviderRegistry();

  /// Registers every entry of [providers]; duplicates are refused.
  factory AIProviderRegistry.from(Map<AITask, AIProvider> providers) {
    final registry = AIProviderRegistry();
    for (final entry in providers.entries) {
      registry.register(task: entry.key, provider: entry.value);
    }
    return registry;
  }

  final Map<AITask, AIProvider> _providers = {};

  void register({required AITask task, required AIProvider provider}) {
    if (_providers.containsKey(task)) {
      throw ArgumentError.value(
        task,
        'task',
        'already has a registered provider; unregister it first',
      );
    }
    _providers[task] = provider;
  }

  void unregister(AITask task) {
    _providers.remove(task);
  }

  AIProvider? providerFor(AITask task) => _providers[task];
}
