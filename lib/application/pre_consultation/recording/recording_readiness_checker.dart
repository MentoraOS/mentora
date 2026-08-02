import '../consultation_readiness_checker.dart';
import '../consultation_readiness_result.dart';
import 'recording_readiness_provider.dart';

/// The recording readiness checker — one responsibility: ask the
/// provider, hand the verdict to the engine.
///
/// It TRANSFORMS only: the provider's availability becomes the verdict,
/// verbatim — no computation, no decision, no media knowledge, no
/// business logic. It never starts anything. Provider failures
/// (unavailable, timeout) PROPAGATE untouched: the engine's fail-closed
/// rule keeps the fact FALSE and the other checkers running.
final class RecordingReadinessChecker implements ConsultationReadinessChecker {
  const RecordingReadinessChecker({
    required RecordingReadinessProvider provider,
  }) : _provider = provider;

  final RecordingReadinessProvider _provider;

  /// Matches ConsultationReadinessEngine.recordingCheckerId — asserted
  /// by test so the two can never drift apart.
  static const String checkerId = 'recording';

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
