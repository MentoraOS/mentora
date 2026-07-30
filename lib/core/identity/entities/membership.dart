class Membership {
  final String id;

  final String identityId;
  final String workspaceId;
  final String workspaceType;

  final String role;
  final List<String> permissions;

  final String? organizationId;
  final String? departmentId;
  final String? teamId;

  final bool active;

  const Membership({
    required this.id,
    required this.identityId,
    required this.workspaceId,
    required this.workspaceType,
    required this.role,
    this.permissions = const [],
    this.organizationId,
    this.departmentId,
    this.teamId,
    required this.active,
  });
}
