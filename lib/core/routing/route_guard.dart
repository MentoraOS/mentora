import '../../application/authentication/authentication_session.dart';

class RouteGuard {
  RouteGuard._();

  static bool isAuthenticated(AuthenticationSession session) {
    return session.isAuthenticated;
  }

  static bool isAdmin(AuthenticationSession session) {
    return session.isAdmin;
  }

  static bool isExpert(AuthenticationSession session) {
    return session.isExpert;
  }

  static bool isClient(AuthenticationSession session) {
    return session.isClient;
  }
}
