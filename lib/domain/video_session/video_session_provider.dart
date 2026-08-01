/// Video session boundary.
///
/// The video backend (LiveKit Cloud, or anything else) is integrated by
/// implementing this port in Infrastructure; the Domain and Application
/// layers never know which vendor runs the room. Same pattern as the
/// Payment and Notification providers.
abstract interface class VideoSessionProvider {
  Future<VideoSessionInfo> createSession(VideoSessionRequest request);

  Future<VideoSessionInfo> joinSession(VideoSessionRequest request);

  Future<void> closeSession(String sessionId);
}

enum VideoParticipantRole { client, expert }

final class VideoSessionRequest {
  final String bookingId;
  final String participantId;
  final VideoParticipantRole role;

  factory VideoSessionRequest({
    required String bookingId,
    required String participantId,
    required VideoParticipantRole role,
  }) {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError.value(bookingId, 'bookingId', 'must not be empty');
    }
    if (participantId.trim().isEmpty) {
      throw ArgumentError.value(
        participantId,
        'participantId',
        'must not be empty',
      );
    }

    return VideoSessionRequest._(
      bookingId: bookingId,
      participantId: participantId,
      role: role,
    );
  }

  const VideoSessionRequest._({
    required this.bookingId,
    required this.participantId,
    required this.role,
  });
}

/// Everything a caller needs to enter the room later. Values are provider
/// tokens/URLs, never reservation truth.
final class VideoSessionInfo {
  final String sessionId;
  final String participantIdentity;
  final VideoParticipantRole role;
  final String serverUrl;
  final String accessToken;

  const VideoSessionInfo({
    required this.sessionId,
    required this.participantIdentity,
    required this.role,
    required this.serverUrl,
    required this.accessToken,
  });
}

/// Thrown when the video backend cannot fulfil the operation. Never a
/// silent fallback.
final class VideoSessionProviderFailure implements Exception {
  const VideoSessionProviderFailure({required this.cause});

  final Object cause;
}
