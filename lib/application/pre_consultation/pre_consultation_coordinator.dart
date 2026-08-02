import 'pre_consultation_composition.dart';
import 'pre_consultation_readiness.dart';

/// Coordinates ONLY the preparation of one consultation — it prepares,
/// it never decides.
///
/// Exactly two responsibilities: [prepare] assembles the current
/// readiness through the single composition, [dispose] releases it.
/// Today no verification exists yet, so every flag composes fail closed
/// to FALSE; the future preparation components (network, camera,
/// microphone, permissions, AI, consents, checklist, onboarding) report
/// their facts here through their own waves — this coordinator only
/// coordinates them, with zero business, AI, network or video logic.
final class PreConsultationCoordinator {
  PreConsultationCoordinator({
    required String bookingId,
    PreConsultationComposition composition =
        const PreConsultationComposition(),
  }) : _bookingId = bookingId,
       _composition = composition;

  final String _bookingId;
  final PreConsultationComposition _composition;

  PreConsultationReadiness? _readiness;
  bool _disposed = false;

  /// The assembled preparation state; null before [prepare] or after
  /// [dispose].
  PreConsultationReadiness? get readiness => _readiness;

  /// Assembles the preparation state. A released coordinator prepares
  /// nothing — fail closed.
  PreConsultationReadiness prepare() {
    if (_disposed) {
      throw StateError('This preparation coordinator was released.');
    }
    return _readiness ??= _composition.compose(
      bookingId: _bookingId,
      createdAt: DateTime.now(),
    );
  }

  /// Releases the preparation cleanly.
  void dispose() {
    _disposed = true;
    _readiness = null;
  }
}
