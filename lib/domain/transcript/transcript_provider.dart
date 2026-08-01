import 'consultation_audio_stream.dart';

/// Transcription engine boundary — CONTRACT ONLY.
///
/// A provider attaches to the consultation's opaque audio stream, runs,
/// and reports lifecycle events. No provider in Mentora today produces
/// any transcription: the simulated implementation only emits simulated
/// lifecycle events, and real engines plug in behind this same port in
/// their own future waves.
abstract interface class TranscriptProvider {
  /// Attaches the provider to one session's audio.
  ///
  /// Fails closed with [TranscriptAlreadyActiveFailure] when a session is
  /// already attached.
  Future<void> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  });

  /// Detaches from the audio; a no-op when nothing runs.
  Future<void> stop();

  /// The provider's lifecycle events.
  Stream<TranscriptEvent> stream();
}

/// Lifecycle-only events: deliberately NO transcription content of any
/// kind — future waves extend this additively.
final class TranscriptEvent {
  final String sessionId;
  final TranscriptEventKind kind;

  const TranscriptEvent({required this.sessionId, required this.kind});
}

enum TranscriptEventKind { started, audioReceived, stopped }

sealed class TranscriptFailure implements Exception {
  const TranscriptFailure();
}

final class TranscriptUnauthenticatedFailure extends TranscriptFailure {
  const TranscriptUnauthenticatedFailure();
}

/// A provider only ever serves one session at a time.
final class TranscriptAlreadyActiveFailure extends TranscriptFailure {
  const TranscriptAlreadyActiveFailure();
}

final class TranscriptUnavailableFailure extends TranscriptFailure {
  const TranscriptUnavailableFailure({required this.cause});

  final Object cause;
}
