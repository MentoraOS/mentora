import '../models/consultation.dart';
import '../models/consultation_result.dart';

abstract class ConsultationRepository {
  Future<ConsultationResult> create(Consultation consultation);

  Future<Consultation?> findById(String consultationId);

  Future<List<Consultation>> findByExpert(String expertId);

  Future<List<Consultation>> findByClient(String clientId);

  Future<ConsultationResult> update(Consultation consultation);

  Future<void> delete(String consultationId);
}
