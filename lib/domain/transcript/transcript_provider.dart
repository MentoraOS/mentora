import 'consultation_audio_stream.dart';
import 'transcript_chunk.dart';

/// Real-time transcription boundary.
///
/// The provider attaches to one session's opaque audio and returns the
/// LIVING transcript stream — a continuous flux, never a bag of
/// independent texts. The implementation routes every piece of audio
/// through the AI gateway; no engine name ever crosses this contract, so
/// engines are added by registering another gateway adapter and nothing
/// in the business layers changes.
abstract interface class TranscriptProvider {
  /// Attaches to the session's audio and starts the living stream.
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  });
}

/// One session's continuous transcription flux.
abstract interface class TranscriptStream {
  String get sessionId;

  TranscriptStatus get status;

  /// The live chunks, in speaking order. Errors surface ON this stream —
  /// fail closed, never silently swallowed.
  Stream<TranscriptChunk> get chunks;

  /// Detaches from the audio and seals the flux.
  Future<TranscriptResult> stop();
}

/// The lifecycle of one living stream. Nothing else.
enum TranscriptStatus { transcribing, stopped, failed }

/// The sealed outcome of one transcription session.
final class TranscriptResult {
  final String sessionId;
  final TranscriptStatus status;

  const TranscriptResult({required this.sessionId, required this.status});
}

sealed class TranscriptFailure implements Exception {
  const TranscriptFailure();
}

final class TranscriptUnauthenticatedFailure extends TranscriptFailure {
  const TranscriptUnauthenticatedFailure();
}

/// One live transcription at a time, ever.
final class TranscriptAlreadyActiveFailure extends TranscriptFailure {
  const TranscriptAlreadyActiveFailure();
}

final class TranscriptUnavailableFailure extends TranscriptFailure {
  const TranscriptUnavailableFailure({required this.cause});

  final Object cause;
}
