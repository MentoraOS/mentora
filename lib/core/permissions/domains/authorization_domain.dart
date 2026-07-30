import '../models/resource.dart';

class AuthorizationDomain {
  const AuthorizationDomain();

  bool can({
    required String permission,
    required List<String> userPermissions,
    Resource? resource,
    String? userId,
  }) {
    if (!userPermissions.contains(permission)) {
      return false;
    }

    if (resource == null) {
      return true;
    }

    if (resource.ownerId != null && resource.ownerId == userId) {
      return true;
    }

    if (resource.workspaceId != null) {
      return true;
    }

    return true;
  }

  bool canAny({
    required List<String> permissions,
    required List<String> userPermissions,
    Resource? resource,
    String? userId,
  }) {
    return permissions.any(
      (permission) => can(
        permission: permission,
        userPermissions: userPermissions,
        resource: resource,
        userId: userId,
      ),
    );
  }

  bool canAll({
    required List<String> permissions,
    required List<String> userPermissions,
    Resource? resource,
    String? userId,
  }) {
    return permissions.every(
      (permission) => can(
        permission: permission,
        userPermissions: userPermissions,
        resource: resource,
        userId: userId,
      ),
    );
  }
}
