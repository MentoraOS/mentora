class EventContext {
  final String userId;

  final String? organizationId;

  final String? workspaceId;

  final String? locale;

  final String? timezone;

  const EventContext({
    required this.userId,
    this.organizationId,
    this.workspaceId,
    this.locale,
    this.timezone,
  });
}
