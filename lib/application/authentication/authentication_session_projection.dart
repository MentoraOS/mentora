import '../../domain/session/session_model.dart';

abstract interface class AuthenticationSessionProjection {
  void project(SessionModel session);

  void clear();
}
