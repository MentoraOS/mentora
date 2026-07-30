import '../domains/consultation_domain.dart';
import '../models/consultation.dart';
import '../models/consultation_result.dart';
import '../models/consultation_status.dart';

class ConsultationEngine {
  final ConsultationDomain domain;

  const ConsultationEngine({required this.domain});

  Future<ConsultationResult> create(Consultation consultation) {
    return domain.create(consultation);
  }

  Future<ConsultationResult> schedule(Consultation consultation) {
    return domain.schedule(consultation);
  }

  Future<ConsultationResult> start(Consultation consultation) {
    return domain.start(consultation);
  }

  Future<ConsultationResult> complete(Consultation consultation) {
    return domain.complete(consultation);
  }

  Future<ConsultationResult> cancel(Consultation consultation) {
    return domain.cancel(consultation);
  }

  Future<ConsultationResult> transitionTo(
    Consultation consultation,
    ConsultationStatus status,
  ) {
    return domain.transitionTo(consultation, status);
  }
}
