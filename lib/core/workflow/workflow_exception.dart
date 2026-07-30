class WorkflowException implements Exception {
  final String message;

  const WorkflowException(this.message);

  @override
  String toString() => message;
}
