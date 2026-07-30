class WorkflowContext {
  final String? userId;
  final String? workspaceId;

  final Map<String, dynamic> metadata;

  const WorkflowContext({
    this.userId,
    this.workspaceId,
    this.metadata = const {},
  });

  T? get<T>(String key) {
    return metadata[key] as T?;
  }
}
