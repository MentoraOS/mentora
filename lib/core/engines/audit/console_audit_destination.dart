import 'audit_destination.dart';
import 'audit_event.dart';

class ConsoleAuditDestination implements AuditDestination {
  @override
  Future<void> record(AuditEvent event) async {
    print(
      '[AUDIT] ${event.action.name} '
      'by ${event.actorId} '
      'on ${event.targetType}/${event.targetId}',
    );
  }
}
