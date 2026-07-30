enum EnterpriseProjectStatus { planned, active, paused, completed, archived }

class EnterpriseProject {
  final String id;
  final String workspaceId;
  final String organizationId;
  final String departmentId;
  final String ownerId;

  final String name;
  final String description;

  final EnterpriseProjectStatus status;

  final DateTime createdAt;
  final DateTime? dueDate;

  const EnterpriseProject({
    required this.id,
    required this.workspaceId,
    required this.organizationId,
    required this.departmentId,
    required this.ownerId,
    required this.name,
    required this.description,
    this.status = EnterpriseProjectStatus.planned,
    required this.createdAt,
    this.dueDate,
  });
}
