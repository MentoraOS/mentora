import 'video_token_provider.dart';

/// Production LiveKit token service — SKELETON, backend not connected.
///
/// GOVERNANCE RULE (ARC-LK01): this class is the ONLY component of Mentora
/// allowed to communicate with the LiveKit token backend. No other adapter,
/// no screen and no Application service may ever reach that backend.
///
/// ## What the backend must provide (nothing else)
///
/// For a request carrying the `bookingId`, the `participantRole` and the
/// caller's authenticated identity, the backend returns:
///
/// - `serverUrl`  — the LiveKit Cloud endpoint to connect to
/// - `jwt`        — the SIGNED LiveKit access token
/// - `roomName`   — `mentora_consultation_{bookingId}`
/// - `identity`   — `{bookingId}_{role}_{userId}`
/// - `expiration` — carried as the JWT `exp` claim
/// - `permissions`— carried as the JWT `video` grant claims
///
/// ## What the backend must enforce (the contract, not implemented here)
///
/// - verify the caller belongs to the reservation (client or expert)
/// - verify the booking is `confirmed` or `paid` — nothing else joins
/// - create the LiveKit JWT for exactly that room and identity
/// - limit the token permissions according to the participant role
/// - sign the token with the LiveKit server credentials
/// - return the credentials above
///
/// No endpoint, no HTTP call and no invented API live here: the concrete
/// transport is decided the day the backend exists, and only the body of
/// this class changes. Everything upstream — LiveKitCloudAdapter, the
/// Application service, the screens — stays untouched.
final class ProductionVideoTokenProvider implements VideoTokenProvider {
  const ProductionVideoTokenProvider();

  @override
  Future<VideoAccessCredentials> credentialsFor({
    required String roomName,
    required String identity,
  }) async {
    throw LiveKitTokenBackendNotConnectedError();
  }
}

/// The LiveKit token backend does not exist yet; joining through the
/// production provider fails closed until it is connected.
final class LiveKitTokenBackendNotConnectedError extends UnimplementedError {
  LiveKitTokenBackendNotConnectedError()
    : super(
        'The LiveKit token backend is not connected yet. '
        'ProductionVideoTokenProvider is a skeleton: implement it against '
        'the real token service, then swap it in for '
        'SimulatedVideoTokenProvider at the composition root.',
      );
}
