class EnterpriseMembership {
  final String id;

  final String userId;
  final String employeeId;
  final String organizationId;
  final String workspaceId;

  final String departmentId;
  final String teamId;
  final String managerId;

  final String role;
  final List<String> permissions;

  final bool active;

  const EnterpriseMembership({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.organizationId,
    required this.workspaceId,
    required this.departmentId,
    required this.teamId,
    required this.managerId,
    required this.role,
    this.permissions = const [],
    this.active = true,
  });
}
