import 'dart:async';

import 'package:livekit_client/livekit_client.dart' as lk;

import '../../domain/transcript/consultation_audio_stream.dart';

/// Bridges a LiveKit room's audio onto the opaque Domain audio transport.
///
/// The ONLY thing this adapter does is forward vendor-native audio track
/// handles as opaque [ConsultationAudioFrame]s: no decoding, no
/// conversion, no interpretation, no storage. A future transcription
/// engine consumes the frames in its own Infrastructure adapter; nothing
/// upstream ever sees LiveKit.
final class LiveKitAudioStreamAdapter implements ConsultationAudioStream {
  LiveKitAudioStreamAdapter({required lk.Room room, required String sessionId})
    : _room = room,
      _sessionId = sessionId {
    _listener = _room.createListener()
      ..on<lk.TrackSubscribedEvent>((event) {
        _forward(event.track, event.participant.identity);
      });
  }

  final lk.Room _room;
  final String _sessionId;
  final StreamController<ConsultationAudioFrame> _frames =
      StreamController<ConsultationAudioFrame>.broadcast();

  lk.EventsListener<lk.RoomEvent>? _listener;

  @override
  Stream<ConsultationAudioFrame> get frames => _frames.stream;

  /// Forwards the audio tracks already present in the room; new ones flow
  /// through the subscription events.
  void emitCurrentTracks() {
    for (final participant in _room.remoteParticipants.values) {
      for (final publication in participant.audioTrackPublications) {
        _forward(publication.track, participant.identity);
      }
    }
  }

  Future<void> dispose() async {
    await _listener?.dispose();
    await _frames.close();
  }

  void _forward(Object? track, String participantIdentity) {
    if (track is! lk.AudioTrack || _frames.isClosed) return;
    _frames.add(
      ConsultationAudioFrame(
        sessionId: _sessionId,
        participantIdentity: participantIdentity,
        payload: track,
      ),
    );
  }
}
