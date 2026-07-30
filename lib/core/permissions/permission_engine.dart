import '../../application/authentication/authentication_session.dart';
import '../identity/engine/identity_engine.dart';
import 'domains/authorization_domain.dart';
import 'mentora_permissions.dart';
import 'models/resource.dart';

class PermissionEngine {
  PermissionEngine._();

  static const AuthorizationDomain _authorizationDomain = AuthorizationDomain();

  static bool has(AuthenticationSession session, String permission) {
    if (!session.isAuthenticated || !session.isActive) return false;
    return session.currentPermissions.contains(permission);
  }

  static bool hasAny(AuthenticationSession session, List<String> permissions) {
    return permissions.any((permission) => has(session, permission));
  }

  static bool hasIdentityPermission(String permission) {
    return IdentityEngine.hasPermission(permission);
  }

  static bool canManageMembers({
    required AuthenticationSession session,
    List<String> workspacePermissions = const [],
  }) {
    return hasGlobalWorkspaceOrIdentityPermission(
      session,
      MentoraPermissionKeys.workspaceManageMembers,
      workspacePermissions: workspacePermissions,
    );
  }

  static bool hasGlobalWorkspaceOrIdentityPermission(
    AuthenticationSession session,
    String permission, {
    List<String> workspacePermissions = const [],
  }) {
    return has(session, permission) ||
        hasWorkspacePermission(session, permission, workspacePermissions) ||
        hasIdentityPermission(permission);
  }

  static bool hasWorkspacePermission(
    AuthenticationSession session,
    String permission,
    List<String> workspacePermissions,
  ) {
    if (!session.isAuthenticated) return false;
    return workspacePermissions.contains(permission);
  }

  static bool can({
    required AuthenticationSession session,
    required String permission,
    Resource? resource,
    String? userId,
  }) {
    return _authorizationDomain.can(
      permission: permission,
      userPermissions: session.currentPermissions,
      resource: resource,
      userId: userId,
    );
  }

  static bool canAnyAdvanced({
    required AuthenticationSession session,
    required List<String> permissions,
    Resource? resource,
    String? userId,
  }) {
    return _authorizationDomain.canAny(
      permissions: permissions,
      userPermissions: session.currentPermissions,
      resource: resource,
      userId: userId,
    );
  }

  static bool canAllAdvanced({
    required AuthenticationSession session,
    required List<String> permissions,
    Resource? resource,
    String? userId,
  }) {
    return _authorizationDomain.canAll(
      permissions: permissions,
      userPermissions: session.currentPermissions,
      resource: resource,
      userId: userId,
    );
  }

  static bool canManageMembersAdvanced({
    required AuthenticationSession session,
    Resource? resource,
    String? userId,
  }) {
    return can(
      session: session,
      permission: MentoraPermissionKeys.workspaceManageMembers,
      resource: resource,
      userId: userId,
    );
  }

  static bool canManageBillingAdvanced({
    required AuthenticationSession session,
    Resource? resource,
    String? userId,
  }) {
    return can(
      session: session,
      permission: MentoraPermissionKeys.workspaceManageBilling,
      resource: resource,
      userId: userId,
    );
  }

  static bool canManagePaymentsAdvanced({
    required AuthenticationSession session,
    Resource? resource,
    String? userId,
  }) {
    return can(
      session: session,
      permission: MentoraPermissionKeys.paymentsManage,
      resource: resource,
      userId: userId,
    );
  }

  static bool canManageUsersAdvanced({
    required AuthenticationSession session,
    Resource? resource,
    String? userId,
  }) {
    return can(
      session: session,
      permission: MentoraPermissionKeys.usersManage,
      resource: resource,
      userId: userId,
    );
  }

  static bool canManageExpertsAdvanced({
    required AuthenticationSession session,
    Resource? resource,
    String? userId,
  }) {
    return can(
      session: session,
      permission: MentoraPermissionKeys.expertsManage,
      resource: resource,
      userId: userId,
    );
  }

  static bool canManagePayments(AuthenticationSession session) {
    return has(session, MentoraPermissionKeys.paymentsManage);
  }

  static bool canManageUsers(AuthenticationSession session) {
    return has(session, MentoraPermissionKeys.usersManage);
  }

  static bool canManageExperts(AuthenticationSession session) {
    return has(session, MentoraPermissionKeys.expertsManage);
  }

  static bool canOpenAdmin(AuthenticationSession session) => session.isAdmin;
}
