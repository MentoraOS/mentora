import '../consultation_readiness_checker.dart';
import '../consultation_readiness_result.dart';
import 'ai_readiness_provider.dart';

/// The AI readiness checker — one responsibility: ask the provider,
/// hand the verdict to the engine.
///
/// It TRANSFORMS only: the provider's availability becomes the verdict,
/// verbatim — no computation, no decision, no AI knowledge, no business
/// logic. It never launches anything. Provider failures (unavailable,
/// timeout) PROPAGATE untouched: the engine's fail-closed rule keeps
/// the fact FALSE and the other checkers running.
final class AIReadinessChecker implements ConsultationReadinessChecker {
  const AIReadinessChecker({required AIReadinessProvider provider})
    : _provider = provider;

  final AIReadinessProvider _provider;

  /// Matches ConsultationReadinessEngine.aiCheckerId — asserted by test
  /// so the two can never drift apart.
  static const String checkerId = 'ai';

  @override
  Future<ConsultationReadinessResult> check() async {
    final readiness = await _provider.check();
    return ConsultationReadinessResult(
      checkerId: checkerId,
      ready: readiness.available,
      checkedAt: readiness.checkedAt,
    );
  }
}
