import 'mentora_permission.dart';
import '../../../domain/session/session_model.dart';

class AccessManager {
  AccessManager._();

  static bool can(SessionModel session, MentoraPermission permission) {
    return session.permissions.contains(permission.name);
  }

  static bool cannot(SessionModel session, MentoraPermission permission) {
    return !can(session, permission);
  }
}
