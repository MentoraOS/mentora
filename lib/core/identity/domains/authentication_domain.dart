import '../models/auth_tokens.dart';
import '../models/identity.dart';
import '../repositories/authentication_repository.dart';

class AuthenticationDomain {
  final AuthenticationRepository repository;

  const AuthenticationDomain({required this.repository});

  Future<Identity> signInWithEmail({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }

  Future<void> signOut() {
    return repository.signOut();
  }

  Future<AuthTokens> refreshTokens({required String refreshToken}) {
    return repository.refreshTokens(refreshToken: refreshToken);
  }

  Future<Identity?> currentIdentity() {
    return repository.currentIdentity();
  }
}
