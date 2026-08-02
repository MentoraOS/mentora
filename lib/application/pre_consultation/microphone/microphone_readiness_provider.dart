import 'microphone_readiness.dart';

/// The microphone information source — PURE CONTRACT, exactly one
/// method.
///
/// It only represents a source of truth about the microphone: it knows
/// no platform, no plugin and no hardware. The concrete sources of the
/// future waves plug in per target by simply implementing this contract
/// — the checker, the engine and the whole preparation platform never
/// change.
abstract interface class MicrophoneReadinessProvider {
  Future<MicrophoneReadiness> check();
}

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY — no real microphone is ever consulted.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in answers fail closed: not available, status unknown.
/// Nothing is ever probed and nothing is ever invented; the real
/// per-target sources replace it behind the same contract.
final class SimulatedMicrophoneReadinessProvider
    implements MicrophoneReadinessProvider {
  const SimulatedMicrophoneReadinessProvider();

  @override
  Future<MicrophoneReadiness> check() async {
    return MicrophoneReadiness(
      available: false,
      status: MicrophoneStatus.unknown,
      checkedAt: DateTime.now(),
    );
  }
}
