import 'permission.dart';

class Policy {
  final String id;
  final String roleKey;
  final List<String> permissions;
  final bool enabled;

  const Policy({
    required this.id,
    required this.roleKey,
    required this.permissions,
    this.enabled = true,
  });

  bool allows(String permissionKey) {
    return enabled && permissions.contains(permissionKey);
  }

  bool allowsPermission(Permission permission) {
    return allows(permission.key);
  }
}
