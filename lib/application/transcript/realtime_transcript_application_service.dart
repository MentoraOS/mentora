import '../../domain/transcript/consultation_audio_stream.dart';
import '../../domain/transcript/transcript_chunk.dart';
import '../../domain/transcript/transcript_provider.dart';
import '../authentication/authentication_session.dart';

/// Orchestrates the real-time transcription of one consultation.
///
/// The ONLY authorized pipeline is fixed by governance: the LiveKit audio
/// bridge feeds this service, which delegates to the TranscriptProvider
/// port, whose implementation routes through the AI gateway to the engine
/// registered for the transcription task. No engine, no RTC and no
/// persistence live here — the transcript stays a living stream.
final class RealtimeTranscriptApplicationService {
  RealtimeTranscriptApplicationService({
    required AuthenticationSession session,
    required TranscriptProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final TranscriptProvider _provider;

  TranscriptStream? _active;

  /// Starts the session's living transcription; one at a time, ever.
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    _requireAuthenticated();
    if (_active != null) {
      throw const TranscriptAlreadyActiveFailure();
    }

    try {
      final stream = await _provider.start(sessionId: sessionId, audio: audio);
      _active = stream;
      return stream;
    } on TranscriptFailure {
      rethrow;
    } catch (error) {
      throw TranscriptUnavailableFailure(cause: error);
    }
  }

  /// The live chunks of the active transcription.
  Stream<TranscriptChunk> chunks() {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const TranscriptUnavailableFailure(
        cause: 'No transcription is running.',
      );
    }
    return active.chunks;
  }

  /// Seals the active transcription and returns its outcome.
  Future<TranscriptResult> stop() async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const TranscriptUnavailableFailure(
        cause: 'No transcription is running.',
      );
    }

    try {
      final result = await active.stop();
      _active = null;
      return result;
    } on TranscriptFailure {
      rethrow;
    } catch (error) {
      _active = null;
      throw TranscriptUnavailableFailure(cause: error);
    }
  }

  void _requireAuthenticated() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const TranscriptUnauthenticatedFailure();
    }
  }
}
