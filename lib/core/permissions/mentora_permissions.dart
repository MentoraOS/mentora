import '../roles/mentora_roles.dart';

class MentoraPermissionKeys {
  MentoraPermissionKeys._();

  static const String workspaceManageMembers = 'workspace.manage_members';

  static const String workspaceManageBilling = 'workspace.manage_billing';

  static const String workspaceCreateLive = 'workspace.create_live';

  static const String usersManage = 'users.manage';

  static const String expertsManage = 'experts.manage';

  static const String paymentsManage = 'payments.manage';

  static const String platformSettingsManage = 'platform.settings.manage';

  static const String expertDashboardAccess = 'expert.dashboard.access';

  static const String foundationProgramsAccess = 'foundation.programs.access';
}

class MentoraPermissions {
  MentoraPermissions._();

  static bool canAccessExpertDashboard(MentoraRole role) {
    return role == MentoraRole.expert ||
        role == MentoraRole.admin ||
        role == MentoraRole.superAdmin;
  }

  static bool canManageUsers(MentoraRole role) {
    return role == MentoraRole.admin || role == MentoraRole.superAdmin;
  }

  static bool canManageCountry(MentoraRole role) {
    return role == MentoraRole.countryManager ||
        role == MentoraRole.admin ||
        role == MentoraRole.superAdmin;
  }

  static bool canAccessFoundationPrograms(MentoraRole role) {
    return role == MentoraRole.foundationMember ||
        role == MentoraRole.admin ||
        role == MentoraRole.superAdmin;
  }

  static bool canManagePlatformSettings(MentoraRole role) {
    return role == MentoraRole.superAdmin;
  }
}
