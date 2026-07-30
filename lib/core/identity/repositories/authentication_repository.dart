import '../models/auth_tokens.dart';
import '../models/identity.dart';

abstract class AuthenticationRepository {
  Future<Identity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AuthTokens> refreshTokens({required String refreshToken});

  Future<Identity?> currentIdentity();
}
