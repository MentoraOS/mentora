import 'video_session_provider.dart';

/// Live consultation room boundary.
///
/// A vendor-neutral contract over the real-time video room: connect,
/// disconnect, reconnect, toggle microphone and camera, observe the
/// connection and the remote participant. The concrete engine (LiveKit
/// Cloud today) lives exclusively in Infrastructure; nothing here knows
/// which vendor runs the room.
abstract interface class LiveConsultationRoom {
  /// Connects to the room described by the session credentials.
  ///
  /// Throws a [VideoRoomFailure]; a failed connection is never reported as
  /// a success.
  Future<void> connect();

  /// Leaves the room cleanly.
  Future<void> disconnect();

  /// Re-attempts a full connection after a disconnection.
  Future<void> reconnect();

  Future<void> setMicrophoneEnabled(bool enabled);

  Future<void> setCameraEnabled(bool enabled);

  LiveConsultationConnectionState get connectionState;

  bool get microphoneEnabled;

  bool get cameraEnabled;

  /// Identity of the remote participant, or null while alone in the room.
  String? get remoteParticipantIdentity;

  /// Opaque renderable video tracks. The composition edge pairs them with
  /// a matching view builder; upstream layers never interpret them.
  Object? get localVideoTrack;

  Object? get remoteVideoTrack;

  /// Coarse-grained change notifications: connection transitions,
  /// participants joining or leaving, tracks appearing or disappearing.
  Stream<void> get changes;

  /// Releases every underlying resource. The room is unusable afterwards.
  Future<void> dispose();
}

/// Creates one room handle per joined session.
abstract interface class LiveConsultationRoomProvider {
  LiveConsultationRoom createRoom(VideoSessionInfo session);
}

enum LiveConsultationConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Typed failures of the live room — the only four the video layer emits.
sealed class VideoRoomFailure implements Exception {
  const VideoRoomFailure();
}

/// The room could not be reached or the connection was lost for good.
final class ConnectionFailure extends VideoRoomFailure {
  const ConnectionFailure({required this.cause});

  final Object cause;
}

/// The credentials were rejected by the video backend.
final class AuthenticationFailure extends VideoRoomFailure {
  const AuthenticationFailure({required this.cause});

  final Object cause;
}

/// The room does not exist or refuses participants.
final class RoomUnavailableFailure extends VideoRoomFailure {
  const RoomUnavailableFailure({required this.cause});

  final Object cause;
}

final class UnexpectedVideoFailure extends VideoRoomFailure {
  const UnexpectedVideoFailure({required this.cause});

  final Object cause;
}
