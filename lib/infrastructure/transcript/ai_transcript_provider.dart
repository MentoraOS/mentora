import 'dart:async';

import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../../domain/transcript/consultation_audio_stream.dart';
import '../../domain/transcript/transcript_chunk.dart';
import '../../domain/transcript/transcript_provider.dart';

/// The real transcription provider: turns the session's opaque audio into
/// a continuous transcript flux by routing EVERY piece of audio through
/// the AI GATEWAY ONLY — never an engine SDK, never a network call,
/// never a business module. The gateway routes [AITask.transcription] to
/// whichever engine is registered for it; this class never knows which.
final class AITranscriptProvider implements TranscriptProvider {
  const AITranscriptProvider({required AIGateway gateway})
    : _gateway = gateway;

  final AIGateway _gateway;

  @override
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    return _GatewayTranscriptStream(
      gateway: _gateway,
      sessionId: sessionId,
      audio: audio,
    );
  }
}

final class _GatewayTranscriptStream implements TranscriptStream {
  _GatewayTranscriptStream({
    required AIGateway gateway,
    required this.sessionId,
    required ConsultationAudioStream audio,
  }) : _gateway = gateway {
    _subscription = audio.frames.listen(
      _transcribe,
      onError: (Object error) {
        _status = TranscriptStatus.failed;
        if (!_chunks.isClosed) _chunks.addError(error);
      },
    );
  }

  final AIGateway _gateway;

  @override
  final String sessionId;

  final StreamController<TranscriptChunk> _chunks =
      StreamController<TranscriptChunk>.broadcast();

  StreamSubscription<ConsultationAudioFrame>? _subscription;
  TranscriptStatus _status = TranscriptStatus.transcribing;
  int _sequence = 0;

  @override
  TranscriptStatus get status => _status;

  @override
  Stream<TranscriptChunk> get chunks => _chunks.stream;

  @override
  Future<TranscriptResult> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_status == TranscriptStatus.transcribing) {
      _status = TranscriptStatus.stopped;
    }
    await _chunks.close();
    return TranscriptResult(sessionId: sessionId, status: _status);
  }

  Future<void> _transcribe(ConsultationAudioFrame frame) async {
    try {
      final response = await _gateway.execute(
        AIRequest(
          requestId: 'transcript_${sessionId}_${_sequence++}',
          task: AITask.transcription,
          audio: frame.payload,
          context: {
            'sessionId': sessionId,
            'participantIdentity': frame.participantIdentity,
          },
        ),
      );

      final text = response.text?.trim();
      if (response.status != AIResponseStatus.accepted) {
        throw StateError('The transcription engine rejected the audio.');
      }
      // Silence transcribes to nothing: no chunk, not an error.
      if (text == null || text.isEmpty) return;
      if (_chunks.isClosed) return;

      _chunks.add(
        TranscriptChunk(
          sessionId: sessionId,
          participantIdentity: frame.participantIdentity,
          text: text,
          isFinal: true,
          createdAt: DateTime.now(),
        ),
      );
    } catch (error) {
      // Fail closed and visibly: the flux carries the error, the stream
      // is marked failed, and nothing pretends to have transcribed.
      _status = TranscriptStatus.failed;
      if (!_chunks.isClosed) _chunks.addError(error);
    }
  }
}
