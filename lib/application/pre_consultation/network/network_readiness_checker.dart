import '../consultation_readiness_checker.dart';
import '../consultation_readiness_result.dart';
import 'network_readiness_provider.dart';

/// The network checker — one responsibility: ask the provider, hand the
/// verdict to the engine.
///
/// It TRANSFORMS only: the provider's availability becomes the verdict,
/// verbatim — no computation, no decision, no platform knowledge, no
/// business logic. Provider failures (unavailable, timeout) PROPAGATE
/// untouched: the engine's fail-closed rule keeps the fact FALSE and
/// the other checkers running.
final class NetworkReadinessChecker implements ConsultationReadinessChecker {
  const NetworkReadinessChecker({required NetworkReadinessProvider provider})
    : _provider = provider;

  final NetworkReadinessProvider _provider;

  /// Matches ConsultationReadinessEngine.networkCheckerId — asserted by
  /// test so the two can never drift apart.
  static const String checkerId = 'network';

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
