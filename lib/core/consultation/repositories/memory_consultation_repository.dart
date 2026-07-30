import '../models/consultation.dart';
import '../models/consultation_result.dart';
import 'consultation_repository.dart';

class MemoryConsultationRepository implements ConsultationRepository {
  final Map<String, Consultation> _consultations = {};

  @override
  Future<ConsultationResult> create(Consultation consultation) async {
    _consultations[consultation.id] = consultation;

    return ConsultationResult(
      success: true,
      message: 'Consultation created',
      consultation: consultation,
    );
  }

  @override
  Future<Consultation?> findById(String consultationId) async {
    return _consultations[consultationId];
  }

  @override
  Future<List<Consultation>> findByExpert(String expertId) async {
    return _consultations.values
        .where((consultation) => consultation.expertId == expertId)
        .toList();
  }

  @override
  Future<List<Consultation>> findByClient(String clientId) async {
    return _consultations.values
        .where((consultation) => consultation.clientId == clientId)
        .toList();
  }

  @override
  Future<ConsultationResult> update(Consultation consultation) async {
    _consultations[consultation.id] = consultation;

    return ConsultationResult(
      success: true,
      message: 'Consultation updated',
      consultation: consultation,
    );
  }

  @override
  Future<void> delete(String consultationId) async {
    _consultations.remove(consultationId);
  }
}
