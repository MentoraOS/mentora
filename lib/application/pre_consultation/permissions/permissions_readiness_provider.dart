import 'permissions_readiness.dart';

/// The permissions information source — PURE CONTRACT, exactly one
/// method.
///
/// It only represents a source of truth about permissions: it knows no
/// platform and no system permission. The concrete sources of the
/// future waves plug in per target by simply implementing this contract
/// — the checker, the engine and the whole preparation platform never
/// change.
abstract interface class PermissionsReadinessProvider {
  Future<PermissionsReadiness> check();
}

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY — no real permission is ever consulted.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in answers fail closed: not granted, status unknown. No
/// permission is ever considered granted until a future implementation
/// has proven it; the real per-target sources replace it behind the
/// same contract.
final class SimulatedPermissionsReadinessProvider
    implements PermissionsReadinessProvider {
  const SimulatedPermissionsReadinessProvider();

  @override
  Future<PermissionsReadiness> check() async {
    return PermissionsReadiness(
      granted: false,
      status: PermissionsStatus.unknown,
      checkedAt: DateTime.now(),
    );
  }
}
