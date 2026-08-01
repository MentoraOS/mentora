import 'consultation_recording.dart';

/// Recording boundary.
///
/// The provider starts and seals one consultation's recording; the media
/// vendor behind it is invisible to every layer above. No replay, no
/// player, no download, no storage exists anywhere yet — future
/// capabilities (consent UI, REC indicator, pause/resume, replay,
/// secured sharing, configurable retention, deletion, compliance, cloud
/// storage, export) build on this lifecycle without a redesign.
abstract interface class RecordingProvider {
  /// Starts the reservation's recording and returns the live handle.
  Future<RecordingSession> start({required String bookingId});
}

/// One live recording lifecycle handle.
abstract interface class RecordingSession {
  /// The recording's current facts.
  ConsultationRecording get recording;

  /// Lifecycle transitions as they happen. Errors surface ON this stream
  /// — fail closed, never silently swallowed.
  Stream<ConsultationRecording> get updates;

  /// Seals the recording and returns its outcome.
  Future<RecordingResult> stop();
}

/// The sealed outcome of one recording session.
final class RecordingResult {
  final ConsultationRecording recording;

  const RecordingResult({required this.recording});
}

sealed class RecordingFailure implements Exception {
  const RecordingFailure();
}

final class RecordingUnauthenticatedFailure extends RecordingFailure {
  const RecordingUnauthenticatedFailure();
}

/// BOTH participants must have explicitly consented — no double consent,
/// no recording, ever. Fail closed.
final class RecordingConsentRequiredFailure extends RecordingFailure {
  const RecordingConsentRequiredFailure();
}

/// One live recording at a time, ever.
final class RecordingAlreadyActiveFailure extends RecordingFailure {
  const RecordingAlreadyActiveFailure();
}

final class RecordingUnavailableFailure extends RecordingFailure {
  const RecordingUnavailableFailure({required this.cause});

  final Object cause;
}
