import '../../domain/video_session/video_session_provider.dart';
import 'simulated_video_token_provider.dart';
import 'video_token_provider.dart';

/// LiveKit Cloud session adapter.
///
/// Resolves the room and identity conventions and obtains real connection
/// credentials from the [VideoTokenProvider]. The actual room connection is
/// owned by the LiveKit room adapter; Agora's legacy code path is untouched.
///
/// Conventions:
/// - room:      mentora_consultation_{bookingId}
/// - identity:  {bookingId}_{role}_{userId}
final class LiveKitCloudAdapter implements VideoSessionProvider {
  const LiveKitCloudAdapter({
    VideoTokenProvider tokenProvider = const SimulatedVideoTokenProvider(),
  }) : _tokenProvider = tokenProvider;

  final VideoTokenProvider _tokenProvider;

  static String roomNameFor(String bookingId) {
    return 'mentora_consultation_$bookingId';
  }

  static String identityFor(VideoSessionRequest request) {
    return '${request.bookingId}_${request.role.name}_'
        '${request.participantId}';
  }

  @override
  Future<VideoSessionInfo> createSession(VideoSessionRequest request) {
    // LiveKit rooms are created on first join; create and join are the
    // same credential resolution.
    return joinSession(request);
  }

  @override
  Future<VideoSessionInfo> joinSession(VideoSessionRequest request) async {
    try {
      final credentials = await _tokenProvider.credentialsFor(
        roomName: roomNameFor(request.bookingId),
        identity: identityFor(request),
      );

      return VideoSessionInfo(
        sessionId: credentials.roomName,
        participantIdentity: credentials.identity,
        role: request.role,
        serverUrl: credentials.serverUrl,
        accessToken: credentials.jwt,
      );
    } catch (error) {
      throw VideoSessionProviderFailure(cause: error);
    }
  }

  @override
  Future<void> closeSession(String sessionId) async {
    // Leaving is client-side (room disconnect); server-side room teardown
    // belongs to the future token/back-end service.
  }
}
