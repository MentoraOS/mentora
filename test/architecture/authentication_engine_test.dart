import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/identity/models/auth_tokens.dart';
import 'package:mentora/core/identity/services/token_service.dart';

void main() {
  group('Authentication Engine - TokenService', () {
    test('should be authenticated when refresh token is valid', () {
      final tokens = AuthTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 10)),
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      const service = TokenService();

      expect(service.isAuthenticated(tokens), isTrue);
    });

    test('should refresh when access token expires soon', () {
      final tokens = AuthTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 3)),
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      const service = TokenService();

      expect(service.shouldRefresh(tokens), isTrue);
    });

    test('should not refresh when refresh token is expired', () {
      final tokens = AuthTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        accessTokenExpiresAt: DateTime.now().subtract(
          const Duration(minutes: 1),
        ),
        refreshTokenExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      const service = TokenService();

      expect(service.canRefresh(tokens), isFalse);
      expect(service.isAuthenticated(tokens), isFalse);
    });
  });
}
