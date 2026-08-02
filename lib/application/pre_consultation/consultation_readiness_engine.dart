import 'camera/camera_readiness_checker.dart';
import 'camera/camera_readiness_provider.dart';
import 'consultation_readiness_registry.dart';
import 'network/network_readiness_checker.dart';
import 'network/network_readiness_provider.dart';
import 'permissions/permissions_readiness_checker.dart';
import 'permissions/permissions_readiness_provider.dart';
import 'pre_consultation_composition.dart';
import 'pre_consultation_readiness.dart';

/// The readiness engine — the brain of the preparation, and NOTHING but
/// an orchestrator.
///
/// Exactly three responsibilities: run the registered checkers in their
/// registration order, aggregate their verdicts, and build a NEW
/// [PreConsultationReadiness] through the single preparation
/// composition. It knows only the registry, the checker contract, the
/// result and the readiness model — never a platform, a device, a
/// vendor, an engine or storage. No mutable state, no cache, no
/// singleton: every preparation is a fresh run and a fresh instance.
///
/// Fail closed, locally: with no checker registered every fact stays
/// FALSE; a failing checker invents nothing (its fact stays FALSE) and
/// never blocks the others.
final class ConsultationReadinessEngine {
  const ConsultationReadinessEngine({
    required ConsultationReadinessRegistry registry,
    PreConsultationComposition composition =
        const PreConsultationComposition(),
  }) : _registry = registry,
       _composition = composition;

  /// The standard engine: every existing foundation checker registered,
  /// in order. Today: the network, permissions and camera checkers over
  /// their simulated providers — which answer fail closed until the
  /// real per-target sources exist. The engine's own logic never
  /// changes: it simply runs the registered checkers.
  factory ConsultationReadinessEngine.standard() {
    final registry = ConsultationReadinessRegistry()
      ..register(
        const NetworkReadinessChecker(
          provider: SimulatedNetworkReadinessProvider(),
        ),
      )
      ..register(
        const PermissionsReadinessChecker(
          provider: SimulatedPermissionsReadinessProvider(),
        ),
      )
      ..register(
        const CameraReadinessChecker(
          provider: SimulatedCameraReadinessProvider(),
        ),
      );
    return ConsultationReadinessEngine(registry: registry);
  }

  final ConsultationReadinessRegistry _registry;
  final PreConsultationComposition _composition;

  /// The well-known checker identities mapped onto the readiness facts.
  /// Future checkers answer with one of these; anything else is ignored
  /// — never guessed.
  static const String networkCheckerId = 'network';
  static const String microphoneCheckerId = 'microphone';
  static const String cameraCheckerId = 'camera';
  static const String permissionsCheckerId = 'permissions';
  static const String aiCheckerId = 'ai';
  static const String recordingCheckerId = 'recording';

  Future<PreConsultationReadiness> prepare({required String bookingId}) async {
    final verdicts = <String, bool>{};
    for (final checker in _registry.checkers()) {
      try {
        final result = await checker.check();
        verdicts[result.checkerId] = result.ready;
      } catch (_) {
        // Fail closed, locally: this fact stays FALSE and the remaining
        // checkers keep running — nothing is ever invented.
      }
    }

    return _composition.compose(
      bookingId: bookingId,
      createdAt: DateTime.now(),
      networkReady: verdicts[networkCheckerId] ?? false,
      microphoneReady: verdicts[microphoneCheckerId] ?? false,
      cameraReady: verdicts[cameraCheckerId] ?? false,
      permissionsReady: verdicts[permissionsCheckerId] ?? false,
      aiReady: verdicts[aiCheckerId] ?? false,
      recordingReady: verdicts[recordingCheckerId] ?? false,
    );
  }
}
