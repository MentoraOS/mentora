import 'identity_engine.dart';
import 'mentora_permission.dart';
import '../../../domain/session/session_model.dart';

class AdminAccessGuard {
  AdminAccessGuard._();

  static bool canManageWithdrawals(SessionModel session) {
    return IdentityEngine.can(session, MentoraPermission.managePayments);
  }

  static bool canAccessAdminFinance(SessionModel session) {
    return IdentityEngine.can(session, MentoraPermission.managePayments);
  }

  static bool canAccessAdminPanel(SessionModel session) {
    return IdentityEngine.can(session, MentoraPermission.manageUsers);
  }
}
