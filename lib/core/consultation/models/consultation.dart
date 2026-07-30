import '../../consultation/models/consultation_status.dart';
import '../../consultation/models/consultation_type.dart';

class Consultation {
  final String id;

  final String expertId;

  final String clientId;

  final DateTime scheduledAt;

  final Duration duration;

  final ConsultationStatus status;

  final ConsultationType type;

  const Consultation({
    required this.id,
    required this.expertId,
    required this.clientId,
    required this.scheduledAt,
    required this.duration,
    required this.status,
    required this.type,
  });

  bool get isActive => status == ConsultationStatus.inProgress;

  bool get isCompleted => status == ConsultationStatus.completed;

  bool get isCancelled => status == ConsultationStatus.cancelled;
}
