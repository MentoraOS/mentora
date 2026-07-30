class AuthTokens {
  final String accessToken;
  final String refreshToken;

  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  bool get isAccessExpired => DateTime.now().isAfter(accessTokenExpiresAt);

  bool get isRefreshExpired => DateTime.now().isAfter(refreshTokenExpiresAt);

  Duration get accessRemaining =>
      accessTokenExpiresAt.difference(DateTime.now());

  Duration get refreshRemaining =>
      refreshTokenExpiresAt.difference(DateTime.now());
}
