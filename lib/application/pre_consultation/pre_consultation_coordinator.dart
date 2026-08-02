import 'consultation_readiness_engine.dart';
import 'pre_consultation_readiness.dart';

/// Coordinates ONLY the preparation of one consultation — it prepares,
/// it never decides.
///
/// Exactly two responsibilities: [prepare] delegates ENTIRELY to the
/// readiness engine (which runs the registered checkers, aggregates
/// their verdicts and builds a fresh readiness — all facts FALSE while
/// no checker exists, fail closed), [dispose] releases. A released
/// coordinator prepares nothing — fail closed. Zero business, AI,
/// network or video logic lives here.
final class PreConsultationCoordinator {
  PreConsultationCoordinator({
    required String bookingId,
    ConsultationReadinessEngine? engine,
  }) : _bookingId = bookingId,
       _engine = engine ?? ConsultationReadinessEngine.standard();

  final String _bookingId;
  final ConsultationReadinessEngine _engine;

  PreConsultationReadiness? _readiness;
  bool _disposed = false;

  /// The last assembled preparation state; null before [prepare] or
  /// after [dispose].
  PreConsultationReadiness? get readiness => _readiness;

  /// Delegates the preparation to the engine — nothing else. Every call
  /// is a fresh engine run and a fresh readiness instance. A released
  /// coordinator prepares nothing — fail closed.
  Future<PreConsultationReadiness> prepare() async {
    if (_disposed) {
      throw StateError('This preparation coordinator was released.');
    }
    final readiness = await _engine.prepare(bookingId: _bookingId);
    _readiness = readiness;
    return readiness;
  }

  /// Releases the preparation cleanly.
  void dispose() {
    _disposed = true;
    _readiness = null;
  }
}
