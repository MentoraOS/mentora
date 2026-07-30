class EventMetadata {
  final String correlationId;

  final String? workspaceId;

  final String? organizationId;

  final String? traceId;

  final int version;

  const EventMetadata({
    required this.correlationId,
    this.workspaceId,
    this.organizationId,
    this.traceId,
    this.version = 1,
  });
}
