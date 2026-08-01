import '../../domain/recording/consultation_recording.dart';
import '../../domain/recording/recording_provider.dart';
import '../authentication/authentication_session.dart';

/// Orchestrates the consultation recording lifecycle.
///
/// Mentora owns this lifecycle; the media vendor behind the
/// RecordingProvider port only produces media. THE rule of this
/// boundary: no recording ever starts without the EXPLICIT consent of
/// BOTH participants — consent is an input of this service (asked by a
/// future consent UI), and a missing one fails closed before anything
/// else. No persistence, no media handling, no replay lives here.
final class ConsultationRecordingApplicationService {
  ConsultationRecordingApplicationService({
    required AuthenticationSession session,
    required RecordingProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final RecordingProvider _provider;

  RecordingSession? _active;

  /// Starts the reservation's recording — ONLY with the double consent.
  Future<RecordingSession> start({
    required String bookingId,
    required bool clientConsent,
    required bool expertConsent,
  }) async {
    _requireAuthenticated();
    if (!clientConsent || !expertConsent) {
      throw const RecordingConsentRequiredFailure();
    }
    if (_active != null) {
      throw const RecordingAlreadyActiveFailure();
    }

    try {
      final session = await _provider.start(bookingId: bookingId);
      _active = session;
      return session;
    } on RecordingFailure {
      rethrow;
    } catch (error) {
      throw RecordingUnavailableFailure(cause: error);
    }
  }

  /// The active recording's current facts.
  ConsultationRecording recording() {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const RecordingUnavailableFailure(
        cause: 'No recording is running.',
      );
    }
    return active.recording;
  }

  /// Seals the active recording and returns its outcome.
  Future<RecordingResult> stop() async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const RecordingUnavailableFailure(
        cause: 'No recording is running.',
      );
    }

    try {
      final result = await active.stop();
      _active = null;
      return result;
    } on RecordingFailure {
      rethrow;
    } catch (error) {
      _active = null;
      throw RecordingUnavailableFailure(cause: error);
    }
  }

  void _requireAuthenticated() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const RecordingUnauthenticatedFailure();
    }
  }
}
