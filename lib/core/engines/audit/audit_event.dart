import 'audit_action.dart';

class AuditEvent {
  final String actorId;
  final String actorRole;
  final AuditAction action;
  final String targetType;
  final String targetId;
  final DateTime occurredAt;
  final Map<String, dynamic>? metadata;

  const AuditEvent({
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.occurredAt,
    this.metadata,
  });
}
