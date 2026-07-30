import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/permissions/domains/authorization_domain.dart';
import 'package:mentora/core/permissions/mentora_permissions.dart';

void main() {
  group('Permission Engine V2 - AuthorizationDomain', () {
    test('should allow when user has permission', () {
      const domain = AuthorizationDomain();

      final result = domain.can(
        permission: MentoraPermissionKeys.workspaceManageMembers,
        userPermissions: [MentoraPermissionKeys.workspaceManageMembers],
      );

      expect(result, isTrue);
    });

    test('should deny when user does not have permission', () {
      const domain = AuthorizationDomain();

      final result = domain.can(
        permission: MentoraPermissionKeys.workspaceManageMembers,
        userPermissions: [MentoraPermissionKeys.workspaceManageBilling],
      );

      expect(result, isFalse);
    });

    test('should allow canAny when at least one permission matches', () {
      const domain = AuthorizationDomain();

      final result = domain.canAny(
        permissions: [
          MentoraPermissionKeys.workspaceManageMembers,
          MentoraPermissionKeys.paymentsManage,
        ],
        userPermissions: [MentoraPermissionKeys.paymentsManage],
      );

      expect(result, isTrue);
    });

    test('should deny canAll when one permission is missing', () {
      const domain = AuthorizationDomain();

      final result = domain.canAll(
        permissions: [
          MentoraPermissionKeys.workspaceManageMembers,
          MentoraPermissionKeys.paymentsManage,
        ],
        userPermissions: [MentoraPermissionKeys.workspaceManageMembers],
      );

      expect(result, isFalse);
    });
  });
}
