import 'audit_event.dart';

abstract class AuditDestination {
  Future<void> record(AuditEvent event);
}
