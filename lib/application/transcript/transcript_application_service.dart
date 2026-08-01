import '../../domain/transcript/consultation_audio_stream.dart';
import '../../domain/transcript/transcript_provider.dart';
import '../authentication/authentication_session.dart';

/// Orchestrates the transcription foundation: attach one session's opaque
/// audio to the provider behind the port, detach, observe lifecycle
/// events. No audio interpretation, no transcription, no AI lives here —
/// or anywhere in Mentora yet.
final class TranscriptApplicationService {
  const TranscriptApplicationService({
    required AuthenticationSession session,
    required TranscriptProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final TranscriptProvider _provider;

  Future<void> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    _requireAuthenticated();

    try {
      await _provider.start(sessionId: sessionId, audio: audio);
    } on TranscriptFailure {
      rethrow;
    } catch (error) {
      throw TranscriptUnavailableFailure(cause: error);
    }
  }

  Future<void> stop() async {
    _requireAuthenticated();

    try {
      await _provider.stop();
    } on TranscriptFailure {
      rethrow;
    } catch (error) {
      throw TranscriptUnavailableFailure(cause: error);
    }
  }

  Stream<TranscriptEvent> events() {
    _requireAuthenticated();
    return _provider.stream();
  }

  void _requireAuthenticated() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const TranscriptUnauthenticatedFailure();
    }
  }
}
