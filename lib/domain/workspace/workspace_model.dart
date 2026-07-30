import 'workspace_type.dart';

class WorkspaceModel {
  final String id;
  final WorkspaceType type;
  final String name;
  final String? organizationId;
  final String? departmentId;
  final String? role;
  final List<String> permissions;
  final bool isActive;

  const WorkspaceModel({
    required this.id,
    required this.type,
    required this.name,
    this.organizationId,
    this.departmentId,
    this.role,
    this.permissions = const [],
    this.isActive = true,
  });
}
