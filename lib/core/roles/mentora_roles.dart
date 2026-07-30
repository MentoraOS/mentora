enum MentoraRole {
  guest,
  client,
  expert,
  admin,
  superAdmin,
  foundationMember,
  countryManager,
}

class MentoraRoles {
  MentoraRoles._();

  static String toValue(MentoraRole role) {
    switch (role) {
      case MentoraRole.guest:
        return 'guest';
      case MentoraRole.client:
        return 'client';
      case MentoraRole.expert:
        return 'expert';
      case MentoraRole.admin:
        return 'admin';
      case MentoraRole.superAdmin:
        return 'super_admin';
      case MentoraRole.foundationMember:
        return 'foundation_member';
      case MentoraRole.countryManager:
        return 'country_manager';
    }
  }

  static MentoraRole fromValue(String? value) {
    switch (value) {
      case 'client':
        return MentoraRole.client;
      case 'expert':
        return MentoraRole.expert;
      case 'admin':
        return MentoraRole.admin;
      case 'super_admin':
        return MentoraRole.superAdmin;
      case 'foundation_member':
        return MentoraRole.foundationMember;
      case 'country_manager':
        return MentoraRole.countryManager;
      default:
        return MentoraRole.guest;
    }
  }
}
