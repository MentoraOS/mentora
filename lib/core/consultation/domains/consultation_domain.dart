import '../models/consultation.dart';
import '../models/consultation_result.dart';
import '../models/consultation_status.dart';
import '../repositories/consultation_repository.dart';
import '../services/consultation_state_machine.dart';

class ConsultationDomain {
  final ConsultationRepository repository;
  final ConsultationStateMachine stateMachine;

  const ConsultationDomain({
    required this.repository,
    this.stateMachine = const ConsultationStateMachine(),
  });

  Future<ConsultationResult> transitionTo(
    Consultation consultation,
    ConsultationStatus nextStatus,
  ) async {
    if (!_canMoveTo(consultation, nextStatus)) {
      return ConsultationResult(
        success: false,
        message: 'Invalid consultation transition',
        consultation: consultation,
      );
    }

    final updated = Consultation(
      id: consultation.id,
      expertId: consultation.expertId,
      clientId: consultation.clientId,
      scheduledAt: consultation.scheduledAt,
      duration: consultation.duration,
      status: nextStatus,
      type: consultation.type,
    );

    return repository.update(updated);
  }

  Future<ConsultationResult> create(Consultation consultation) {
    return repository.create(consultation);
  }

  Future<Consultation?> findById(String consultationId) {
    return repository.findById(consultationId);
  }

  bool _canMoveTo(Consultation consultation, ConsultationStatus nextStatus) {
    return stateMachine.canTransition(
      from: consultation.status,
      to: nextStatus,
    );
  }

  Future<ConsultationResult> schedule(Consultation consultation) {
    return transitionTo(consultation, ConsultationStatus.scheduled);
  }

  Future<ConsultationResult> start(Consultation consultation) {
    return transitionTo(consultation, ConsultationStatus.inProgress);
  }

  Future<ConsultationResult> complete(Consultation consultation) {
    return transitionTo(consultation, ConsultationStatus.completed);
  }

  Future<ConsultationResult> cancel(Consultation consultation) {
    return transitionTo(consultation, ConsultationStatus.cancelled);
  }
}
