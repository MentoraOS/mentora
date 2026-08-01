/// Video access-token boundary — Infrastructure only. PRODUCTION-READY.
///
/// The LiveKit adapter obtains its connection credentials here and nowhere
/// else. This contract is final: the real token backend replaces ONLY the
/// implementation (SimulatedVideoTokenProvider →
/// ProductionVideoTokenProvider → LiveKit backend) and no other layer
/// changes.
///
/// The backend answer maps onto [VideoAccessCredentials]: `serverUrl`,
/// `jwt`, `roomName`, `identity`. `expiration` and `permissions` travel
/// INSIDE the signed JWT (`exp` and `video` grant claims); the
/// `participantRole` and `bookingId` are inputs, already encoded in the
/// room and identity conventions. Nothing else is exchanged.
abstract interface class VideoTokenProvider {
  Future<VideoAccessCredentials> credentialsFor({
    required String roomName,
    required String identity,
  });
}

/// Everything needed to enter one room as one identity.
final class VideoAccessCredentials {
  final String serverUrl;
  final String roomName;
  final String identity;
  final String jwt;

  const VideoAccessCredentials({
    required this.serverUrl,
    required this.roomName,
    required this.identity,
    required this.jwt,
  });
}
