class WorkflowEvent {
  final String name;
  final String workflowName;
  final String? userId;
  final String? workspaceId;
  final DateTime occurredAt;
  final Map<String, dynamic> metadata;

  const WorkflowEvent({
    required this.name,
    required this.workflowName,
    this.userId,
    this.workspaceId,
    required this.occurredAt,
    this.metadata = const {},
  });
}
