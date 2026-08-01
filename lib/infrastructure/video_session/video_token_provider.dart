/// Video access-token boundary — Infrastructure only.
///
/// The LiveKit adapter obtains its connection credentials here. The real
/// token backend (a server minting signed LiveKit JWTs) replaces ONLY this
/// provider; nothing else in the video layer changes.
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
