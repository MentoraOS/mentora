import 'workspace_type.dart';

class WorkspaceMembership {
  final String workspaceId;
  final WorkspaceType workspaceType;

  final String workspaceName;

  final String? organizationId;
  final String? departmentId;

  final String role;

  final List<String> permissions;

  const WorkspaceMembership({
    required this.workspaceId,
    required this.workspaceType,
    required this.workspaceName,
    this.organizationId,
    this.departmentId,
    required this.role,
    this.permissions = const [],
  });
}
