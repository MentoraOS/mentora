import 'mentora_permission.dart';
import 'mentora_role.dart';

class RoleManager {
  RoleManager._();

  static List<MentoraPermission> permissionsOf(MentoraRole role) {
    switch (role) {
      case MentoraRole.guest:
        return [];

      case MentoraRole.client:
        return [
          MentoraPermission.createConsultation,
          MentoraPermission.joinConsultation,
          MentoraPermission.uploadDocuments,
        ];

      case MentoraRole.expert:
        return [
          MentoraPermission.joinConsultation,
          MentoraPermission.uploadDocuments,
          MentoraPermission.createCourses,
          MentoraPermission.hostEvents,
        ];

      case MentoraRole.premiumExpert:
        return [
          ...permissionsOf(MentoraRole.expert),
          MentoraPermission.manageAnalytics,
        ];

      case MentoraRole.moderator:
        return [
          MentoraPermission.manageBookings,
          MentoraPermission.viewReports,
        ];

      case MentoraRole.support:
        return [MentoraPermission.viewReports];

      case MentoraRole.foundation:
        return [
          MentoraPermission.manageFoundation,
          MentoraPermission.viewReports,
        ];

      case MentoraRole.countryManager:
        return [
          MentoraPermission.manageUsers,
          MentoraPermission.manageExperts,
          MentoraPermission.manageBookings,
          MentoraPermission.managePayments,
          MentoraPermission.manageCountries,
          MentoraPermission.viewReports,
        ];

      case MentoraRole.admin:
        return [
          MentoraPermission.manageUsers,
          MentoraPermission.manageExperts,
          MentoraPermission.manageBookings,
          MentoraPermission.managePayments,
          MentoraPermission.manageAnalytics,
          MentoraPermission.viewReports,
        ];

      case MentoraRole.superAdmin:
        return MentoraPermission.values;
    }
  }
}
