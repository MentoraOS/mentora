import 'network_readiness.dart';

/// The network information source — PURE CONTRACT, exactly one method.
///
/// It only represents a source of network facts: it knows nothing about
/// where those facts come from. The concrete sources of the future
/// waves plug in per target by simply implementing this contract — the
/// checker, the engine and the whole preparation platform never change.
abstract interface class NetworkReadinessProvider {
  Future<NetworkReadiness> check();
}

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY — no real network fact exists yet.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in answers fail closed: not available, quality unknown.
/// Nothing is ever measured and nothing is ever invented; the real
/// per-target sources replace it behind the same contract.
final class SimulatedNetworkReadinessProvider
    implements NetworkReadinessProvider {
  const SimulatedNetworkReadinessProvider();

  @override
  Future<NetworkReadiness> check() async {
    return NetworkReadiness(
      available: false,
      quality: NetworkQuality.unknown,
      checkedAt: DateTime.now(),
    );
  }
}
