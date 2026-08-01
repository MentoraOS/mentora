import '../../domain/video_session/video_session_provider.dart';

/// LiveKit Cloud adapter — THE only place where LiveKit will ever exist.
///
/// This wave is the architectural foundation: behaviour is simulated and no
/// SDK is integrated. The real LiveKit Cloud integration (server URL, token
/// service, room lifecycle) replaces the bodies below in its own wave;
/// nothing upstream changes. Agora's legacy code path is untouched.
final class LiveKitCloudAdapter implements VideoSessionProvider {
  const LiveKitCloudAdapter();

  static const String _simulatedServerUrl =
      'wss://simulated.livekit.cloud/mentora';

  @override
  Future<VideoSessionInfo> createSession(VideoSessionRequest request) async {
    return _info(request);
  }

  @override
  Future<VideoSessionInfo> joinSession(VideoSessionRequest request) async {
    // Simulated create-or-join: one deterministic room per booking.
    return _info(request);
  }

  @override
  Future<void> closeSession(String sessionId) async {
    // Simulated: nothing to tear down yet.
  }

  VideoSessionInfo _info(VideoSessionRequest request) {
    return VideoSessionInfo(
      sessionId: 'mentora_consultation_${request.bookingId}',
      participantIdentity: request.participantId,
      role: request.role,
      serverUrl: _simulatedServerUrl,
      accessToken:
          'simulated:${request.bookingId}:${request.participantId}:'
          '${request.role.name}',
    );
  }
}
