import 'recording_readiness.dart';

/// The recording readiness information source — PURE CONTRACT, exactly
/// one method.
///
/// It only represents a source of truth about the recording platform
/// being ready: it never starts anything, contacts no media pipeline
/// and no network. The concrete sources of the future waves plug in by
/// simply implementing this contract — the checker, the engine and the
/// whole preparation platform never change.
abstract interface class RecordingReadinessProvider {
  Future<RecordingReadiness> check();
}

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY — nothing is ever really verified.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in answers fail closed: not available, status unknown.
/// Nothing is ever contacted and nothing is ever invented; the real
/// sources replace it behind the same contract.
final class SimulatedRecordingReadinessProvider
    implements RecordingReadinessProvider {
  const SimulatedRecordingReadinessProvider();

  @override
  Future<RecordingReadiness> check() async {
    return RecordingReadiness(
      available: false,
      status: RecordingReadinessStatus.unknown,
      checkedAt: DateTime.now(),
    );
  }
}
