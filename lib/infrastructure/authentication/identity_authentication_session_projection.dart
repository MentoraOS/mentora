import '../../application/authentication/authentication_session_projection.dart';
import '../../core/identity/identity.dart';
import '../../domain/session/session_model.dart';

final class IdentityAuthenticationSessionProjection
    implements AuthenticationSessionProjection {
  const IdentityAuthenticationSessionProjection();

  @override
  void project(SessionModel session) {
    final names = session.name.split(' ');
    IdentityEngine.setIdentity(
      Identity(
        id: session.id,
        email: session.email,
        firstName: names.isNotEmpty ? names.first : '',
        lastName: names.length > 1 ? names.sublist(1).join(' ') : '',
        verified: session.isVerified,
      ),
    );
  }

  @override
  void clear() {
    IdentityEngine.clear();
  }
}
