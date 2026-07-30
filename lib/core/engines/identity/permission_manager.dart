import 'package:mentora/domain/session/session_model.dart';
import 'mentora_permission.dart';
import 'mentora_role.dart';
import 'role_manager.dart';

class PermissionManager {
  PermissionManager._();

  static bool hasPermission(
    SessionModel session,
    MentoraPermission permission,
  ) {
    if (!session.isActive) return false;

    final directPermissions = session.permissions;

    if (directPermissions.contains(permission.name)) {
      return true;
    }

    final roles = session.roles.map(_roleFromString).toList();

    for (final role in roles) {
      final rolePermissions = RoleManager.permissionsOf(role);

      if (rolePermissions.contains(permission)) {
        return true;
      }
    }

    return false;
  }

  static MentoraRole _roleFromString(String role) {
    switch (role) {
      case 'client':
        return MentoraRole.client;
      case 'expert':
        return MentoraRole.expert;
      case 'premium_expert':
        return MentoraRole.premiumExpert;
      case 'moderator':
        return MentoraRole.moderator;
      case 'support':
        return MentoraRole.support;
      case 'foundation':
        return MentoraRole.foundation;
      case 'admin':
        return MentoraRole.admin;
      case 'super_admin':
        return MentoraRole.superAdmin;
      case 'country_manager':
        return MentoraRole.countryManager;
      default:
        return MentoraRole.guest;
    }
  }
}
