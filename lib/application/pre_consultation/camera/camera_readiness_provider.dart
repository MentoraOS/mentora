import 'camera_readiness.dart';

/// The camera information source — PURE CONTRACT, exactly one method.
///
/// It only represents a source of truth about the camera: it knows no
/// platform, no plugin and no hardware. The concrete sources of the
/// future waves plug in per target by simply implementing this contract
/// — the checker, the engine and the whole preparation platform never
/// change.
abstract interface class CameraReadinessProvider {
  Future<CameraReadiness> check();
}

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY — no real camera is ever consulted.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in answers fail closed: not available, status unknown.
/// Nothing is ever probed and nothing is ever invented; the real
/// per-target sources replace it behind the same contract.
final class SimulatedCameraReadinessProvider
    implements CameraReadinessProvider {
  const SimulatedCameraReadinessProvider();

  @override
  Future<CameraReadiness> check() async {
    return CameraReadiness(
      available: false,
      status: CameraStatus.unknown,
      checkedAt: DateTime.now(),
    );
  }
}
