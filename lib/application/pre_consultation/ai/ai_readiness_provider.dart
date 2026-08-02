import 'ai_readiness.dart';

/// The AI readiness information source — PURE CONTRACT, exactly one
/// method.
///
/// It only represents a source of truth about the AI platform being
/// ready: it never runs anything, contacts no model, no engine and no
/// network. The concrete sources of the future waves plug in by simply
/// implementing this contract — the checker, the engine and the whole
/// preparation platform never change.
abstract interface class AIReadinessProvider {
  Future<AIReadiness> check();
}

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY — nothing is ever really verified.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in answers fail closed: not available, status unknown.
/// Nothing is ever contacted and nothing is ever invented; the real
/// sources replace it behind the same contract.
final class SimulatedAIReadinessProvider implements AIReadinessProvider {
  const SimulatedAIReadinessProvider();

  @override
  Future<AIReadiness> check() async {
    return AIReadiness(
      available: false,
      status: AIReadinessStatus.unknown,
      checkedAt: DateTime.now(),
    );
  }
}
