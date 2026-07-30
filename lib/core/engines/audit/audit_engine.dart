import 'audit_action.dart';
import 'audit_destination.dart';
import 'audit_event.dart';
import 'console_audit_destination.dart';

class AuditEngine {
  AuditEngine._();

  static AuditDestination _destination = ConsoleAuditDestination();

  static void setDestination(AuditDestination destination) {
    _destination = destination;
  }

  static Future<void> record({
    required String actorId,
    required String actorRole,
    required AuditAction action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
  }) async {
    final event = AuditEvent(
      actorId: actorId,
      actorRole: actorRole,
      action: action,
      targetType: targetType,
      targetId: targetId,
      occurredAt: DateTime.now(),
      metadata: metadata,
    );

    await _destination.record(event);
  }
}
