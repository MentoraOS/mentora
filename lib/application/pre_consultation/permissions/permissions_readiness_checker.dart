import '../consultation_readiness_checker.dart';
import '../consultation_readiness_result.dart';
import 'permissions_readiness_provider.dart';

/// The permissions checker — one responsibility: ask the provider, hand
/// the verdict to the engine.
///
/// It TRANSFORMS only: the provider's grant becomes the verdict,
/// verbatim — no computation, no decision, no platform knowledge, no
/// business logic. Provider failures (unavailable, timeout) PROPAGATE
/// untouched: the engine's fail-closed rule keeps the fact FALSE and
/// the other checkers running.
final class PermissionsReadinessChecker
    implements ConsultationReadinessChecker {
  const PermissionsReadinessChecker({
    required PermissionsReadinessProvider provider,
  }) : _provider = provider;

  final PermissionsReadinessProvider _provider;

  /// Matches ConsultationReadinessEngine.permissionsCheckerId — asserted
  /// by test so the two can never drift apart.
  static const String checkerId = 'permissions';

  @override
  Future<ConsultationReadinessResult> check() async {
    final readiness = await _provider.check();
    return ConsultationReadinessResult(
      checkerId: checkerId,
      ready: readiness.granted,
      checkedAt: readiness.checkedAt,
    );
  }
}
