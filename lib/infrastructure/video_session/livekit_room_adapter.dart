import 'dart:async';

import 'package:livekit_client/livekit_client.dart' as lk;

import '../../domain/video_session/live_consultation_room.dart';
import '../../domain/video_session/video_session_provider.dart';

/// Real LiveKit Cloud room integration — the only RTC code in Mentora.
///
/// Implements the vendor-neutral [LiveConsultationRoom] over the LiveKit
/// SDK: Room, RoomOptions, ConnectOptions, participants, tracks, room
/// events and connection states. Everything upstream (Application, screens,
/// widgets) only ever sees the Domain contract.
final class LiveKitRoomProvider implements LiveConsultationRoomProvider {
  const LiveKitRoomProvider();

  @override
  LiveConsultationRoom createRoom(VideoSessionInfo session) {
    return LiveKitConsultationRoom(session: session);
  }
}

final class LiveKitConsultationRoom implements LiveConsultationRoom {
  LiveKitConsultationRoom({required VideoSessionInfo session, lk.Room? room})
    : _session = session,
      _room =
          room ??
          lk.Room(
            roomOptions: const lk.RoomOptions(
              adaptiveStream: true,
              dynacast: true,
            ),
          );

  final VideoSessionInfo _session;
  final lk.Room _room;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  lk.EventsListener<lk.RoomEvent>? _listener;
  LiveConsultationConnectionState _state =
      LiveConsultationConnectionState.disconnected;
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;

  @override
  Future<void> connect() async {
    _setState(LiveConsultationConnectionState.connecting);

    try {
      _listener ??= _room.createListener()
        ..on<lk.ParticipantConnectedEvent>((_) => _notify())
        ..on<lk.ParticipantDisconnectedEvent>((_) => _notify())
        ..on<lk.TrackSubscribedEvent>((_) => _notify())
        ..on<lk.TrackUnsubscribedEvent>((_) => _notify())
        // connectionLost → the SDK starts its reconnection cycle.
        ..on<lk.RoomReconnectingEvent>(
          (_) => _setState(LiveConsultationConnectionState.reconnecting),
        )
        // connectionRestored.
        ..on<lk.RoomReconnectedEvent>(
          (_) => _setState(LiveConsultationConnectionState.connected),
        )
        ..on<lk.RoomDisconnectedEvent>(
          (_) => _setState(LiveConsultationConnectionState.disconnected),
        );

      await _room.connect(
        _session.serverUrl,
        _session.accessToken,
        connectOptions: const lk.ConnectOptions(autoSubscribe: true),
      );
      await _room.localParticipant?.setMicrophoneEnabled(_microphoneEnabled);
      await _room.localParticipant?.setCameraEnabled(_cameraEnabled);

      _setState(LiveConsultationConnectionState.connected);
    } catch (error) {
      _setState(LiveConsultationConnectionState.disconnected);
      throw _mapConnectError(error);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _room.disconnect();
    } finally {
      _setState(LiveConsultationConnectionState.disconnected);
    }
  }

  @override
  Future<void> reconnect() async {
    if (_room.connectionState != lk.ConnectionState.disconnected) {
      await _room.disconnect();
    }
    await connect();
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    _microphoneEnabled = enabled;
    await _room.localParticipant?.setMicrophoneEnabled(enabled);
    _notify();
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    _cameraEnabled = enabled;
    await _room.localParticipant?.setCameraEnabled(enabled);
    _notify();
  }

  @override
  LiveConsultationConnectionState get connectionState => _state;

  @override
  bool get microphoneEnabled => _microphoneEnabled;

  @override
  bool get cameraEnabled => _cameraEnabled;

  @override
  String? get remoteParticipantIdentity {
    final participant = _remoteParticipant;
    return participant?.identity;
  }

  @override
  Object? get localVideoTrack {
    for (final publication
        in _room.localParticipant?.videoTrackPublications ??
            const <lk.LocalTrackPublication<lk.LocalVideoTrack>>[]) {
      final track = publication.track;
      if (track != null && !publication.muted) return track;
    }
    return null;
  }

  @override
  Object? get remoteVideoTrack {
    final participant = _remoteParticipant;
    if (participant == null) return null;
    for (final publication in participant.videoTrackPublications) {
      final track = publication.track;
      if (track != null && publication.subscribed && !publication.muted) {
        return track;
      }
    }
    return null;
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> dispose() async {
    await _listener?.dispose();
    await _room.dispose();
    await _changes.close();
  }

  lk.RemoteParticipant? get _remoteParticipant {
    // One-to-one consultation: the first remote participant is the peer.
    for (final participant in _room.remoteParticipants.values) {
      return participant;
    }
    return null;
  }

  void _setState(LiveConsultationConnectionState state) {
    _state = state;
    _notify();
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  /// Maps SDK errors onto the four typed room failures. Never a fake
  /// success: anything unrecognized surfaces as [UnexpectedVideoFailure].
  VideoRoomFailure _mapConnectError(Object error) {
    if (error is VideoRoomFailure) return error;

    final text = error.toString().toLowerCase();
    if (text.contains('token') ||
        text.contains('unauthorized') ||
        text.contains('401') ||
        text.contains('permission')) {
      return AuthenticationFailure(cause: error);
    }
    if (text.contains('not found') || text.contains('room')) {
      return RoomUnavailableFailure(cause: error);
    }
    if (error is lk.ConnectException ||
        text.contains('connect') ||
        text.contains('socket') ||
        text.contains('network') ||
        text.contains('timeout')) {
      return ConnectionFailure(cause: error);
    }
    return UnexpectedVideoFailure(cause: error);
  }
}
