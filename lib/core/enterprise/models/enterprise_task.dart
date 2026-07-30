enum EnterpriseTaskStatus { todo, inProgress, blocked, completed, archived }

enum EnterpriseTaskPriority { low, normal, high, urgent }

class EnterpriseTask {
  final String id;
  final String projectId;
  final String workspaceId;
  final String organizationId;
  final String assignedToId;
  final String createdById;

  final String title;
  final String description;

  final EnterpriseTaskStatus status;
  final EnterpriseTaskPriority priority;

  final DateTime createdAt;
  final DateTime? dueDate;

  const EnterpriseTask({
    required this.id,
    required this.projectId,
    required this.workspaceId,
    required this.organizationId,
    required this.assignedToId,
    required this.createdById,
    required this.title,
    required this.description,
    this.status = EnterpriseTaskStatus.todo,
    this.priority = EnterpriseTaskPriority.normal,
    required this.createdAt,
    this.dueDate,
  });
}
