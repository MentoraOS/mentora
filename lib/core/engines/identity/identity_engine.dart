import 'package:mentora/domain/session/session_model.dart';

import 'access_manager.dart';
import 'mentora_permission.dart';
import 'mentora_role.dart';
import 'role_manager.dart';

class IdentityEngine {
  IdentityEngine._();

  static bool can(SessionModel session, MentoraPermission permission) {
    return AccessManager.can(session, permission);
  }

  static bool cannot(SessionModel session, MentoraPermission permission) {
    return AccessManager.cannot(session, permission);
  }

  static bool hasRole(SessionModel session, String role) {
    if (!session.isActive) return false;
    return session.roles.contains(role);
  }

  static bool isActive(SessionModel session) {
    return session.isActive;
  }

  static String countryCode(SessionModel session) {
    return session.countryCode;
  }

  static List<MentoraPermission> permissionsForRole(MentoraRole role) {
    return RoleManager.permissionsOf(role);
  }

  static bool isAdmin(SessionModel session) {
    return can(session, MentoraPermission.manageUsers);
  }

  static bool canManagePayments(SessionModel session) {
    return can(session, MentoraPermission.managePayments);
  }

  static bool canManageCountries(SessionModel session) {
    return can(session, MentoraPermission.manageCountries);
  }

  static bool canAccessAnalytics(SessionModel session) {
    return can(session, MentoraPermission.manageAnalytics) ||
        can(session, MentoraPermission.viewReports);
  }
}
