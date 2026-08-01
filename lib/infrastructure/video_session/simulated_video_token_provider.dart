import 'dart:convert';

import 'video_token_provider.dart';

/// ════════════════════════════════════════════════════════════════════
/// DEVELOPMENT ONLY.
///
/// Never usable against a real LiveKit server.
///
/// Replace by ProductionVideoTokenProvider.
/// ════════════════════════════════════════════════════════════════════
///
/// This stand-in DERIVES an unsigned, unmistakably-marked JWT-shaped token
/// from the room and identity — nothing is hard-coded — so the whole token
/// pipeline is exercised end to end. Its signature segment is the literal
/// `DEVELOPMENT_ONLY_UNSIGNED`: no real LiveKit server can ever accept it
/// and no human can ever mistake it for a signed production token. The
/// intended behaviour against real infrastructure is fail-closed: no fake
/// success, ever.
final class SimulatedVideoTokenProvider implements VideoTokenProvider {
  const SimulatedVideoTokenProvider({
    this.serverUrl = 'wss://development-only.invalid/mentora',
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
      'iss': 'mentora-development-only',
      'sub': identity,
      'video': {'room': roomName, 'roomJoin': true},
    });
    return '$header.$payload.DEVELOPMENT_ONLY_UNSIGNED';
  }
}
