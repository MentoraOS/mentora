import 'dart:convert';

import 'video_token_provider.dart';

/// Development stand-in for the real token backend.
///
/// It DERIVES an unsigned JWT-shaped token from the room and identity —
/// nothing is hard-coded — so the whole pipeline exercises real token
/// plumbing. A real LiveKit server rejects the fake signature, which is the
/// intended fail-closed behaviour: no fake success, ever. The production
/// token service implements [VideoTokenProvider] and replaces this class.
final class SimulatedVideoTokenProvider implements VideoTokenProvider {
  const SimulatedVideoTokenProvider({
    this.serverUrl = 'wss://fake.livekit.cloud/mentora',
  });

  final String serverUrl;

  @override
  Future<VideoAccessCredentials> credentialsFor({
    required String roomName,
    required String identity,
  }) async {
    return VideoAccessCredentials(
      serverUrl: serverUrl,
      roomName: roomName,
      identity: identity,
      jwt: _unsignedJwt(roomName: roomName, identity: identity),
    );
  }

  static String _unsignedJwt({
    required String roomName,
    required String identity,
  }) {
    String encode(Map<String, Object> claims) {
      return base64Url.encode(utf8.encode(jsonEncode(claims)));
    }

    final header = encode({'alg': 'none', 'typ': 'JWT'});
    final payload = encode({
      'iss': 'mentora-fake-token-provider',
      'sub': identity,
      'video': {'room': roomName, 'roomJoin': true},
    });
    return '$header.$payload.unsigned';
  }
}
