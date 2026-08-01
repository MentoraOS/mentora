import 'dart:async';

import '../../domain/recording/consultation_recording.dart';
import '../../domain/recording/recording_provider.dart';
import 'consultation_recording_application_service.dart';

/// COORDINATOR, never a decision-maker.
///
/// The orchestrator only connects the foundations already built: it
/// observes the two consents as they are reported to it, waits for the
/// double agreement, calls the recording service's start EXACTLY ONCE
/// with the consents passed through VERBATIM (every business rule —
/// double consent fail-closed, single active lifecycle — stays enforced
/// by the service), then observes the RecordingSession and relays its
/// states. It never validates, never refuses, never modifies a consent,
/// never creates media and never knows the media vendor. One
/// orchestrator per consultation.
final class RecordingOrchestrator {
  RecordingOrchestrator({
    required ConsultationRecordingApplicationService recording,
    required String bookingId,
  }) : _recording = recording,
       _bookingId = bookingId;

  final ConsultationRecordingApplicationService _recording;
  final String _bookingId;

  final StreamController<ConsultationRecording> _updates =
      StreamController<ConsultationRecording>.broadcast();

  RecordingSession? _session;
  StreamSubscription<ConsultationRecording>? _subscription;
  bool _starting = false;

  /// The started lifecycle handle, once the double agreement happened.
  RecordingSession? get session => _session;

  /// The relayed lifecycle states of the started recording. Failures
  /// surface HERE too — fail closed, never silently swallowed.
  Stream<ConsultationRecording> get updates => _updates.stream;

  /// Reports the current consents. The orchestrator only WAITS: without
  /// the double agreement nothing happens, with it the service is asked
  /// to start exactly once — and the service remains the enforcer.
  Future<void> onConsents({
    required bool clientConsent,
    required bool expertConsent,
  }) async {
    if (_session != null || _starting) return;
    if (!(clientConsent && expertConsent)) return;

    _starting = true;
    try {
      final session = await _recording.start(
        bookingId: _bookingId,
        clientConsent: clientConsent,
        expertConsent: expertConsent,
      );
      _session = session;
      _subscription = session.updates.listen(
        (recording) {
          if (!_updates.isClosed) _updates.add(recording);
        },
        onError: (Object error) {
          if (!_updates.isClosed) _updates.addError(error);
        },
      );
    } catch (error) {
      // Relayed, never swallowed; a later double agreement may try again.
      if (!_updates.isClosed) _updates.addError(error);
    } finally {
      _starting = false;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _updates.close();
  }
}
