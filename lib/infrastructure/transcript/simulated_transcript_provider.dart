import 'dart:async';

import '../../domain/transcript/consultation_audio_stream.dart';
import '../../domain/transcript/transcript_provider.dart';

/// Simulated transcription provider: emits ONLY simulated lifecycle
/// events (started, audioReceived, stopped). No transcription content is
/// ever produced — a real engine replaces this class behind the same
/// port in its own wave.
final class SimulatedTranscriptProvider implements TranscriptProvider {
  final StreamController<TranscriptEvent> _events =
      StreamController<TranscriptEvent>.broadcast();

  StreamSubscription<ConsultationAudioFrame>? _subscription;
  String? _sessionId;

  @override
  Future<void> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    if (_sessionId != null) {
      throw const TranscriptAlreadyActiveFailure();
    }

    _sessionId = sessionId;
    _emit(sessionId, TranscriptEventKind.started);
    _subscription = audio.frames.listen(
      // The frame stays opaque: its arrival is acknowledged, nothing more.
      (_) => _emit(sessionId, TranscriptEventKind.audioReceived),
    );
  }

  @override
  Future<void> stop() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;

    await _subscription?.cancel();
    _subscription = null;
    _sessionId = null;
    _emit(sessionId, TranscriptEventKind.stopped);
  }

  @override
  Stream<TranscriptEvent> stream() => _events.stream;

  void _emit(String sessionId, TranscriptEventKind kind) {
    if (_events.isClosed) return;
    _events.add(TranscriptEvent(sessionId: sessionId, kind: kind));
  }
}
