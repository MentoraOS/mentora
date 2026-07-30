import 'consultation.dart';

class ConsultationResult {
  final bool success;

  final String? message;

  final Consultation? consultation;

  const ConsultationResult({
    required this.success,
    this.message,
    this.consultation,
  });
}
