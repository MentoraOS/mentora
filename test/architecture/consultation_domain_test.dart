import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/consultation/domains/consultation_domain.dart';
import 'package:mentora/core/consultation/models/consultation.dart';
import 'package:mentora/core/consultation/models/consultation_status.dart';
import 'package:mentora/core/consultation/models/consultation_type.dart';
import 'package:mentora/core/consultation/repositories/memory_consultation_repository.dart';

void main() {
  group('Consultation Domain', () {
    test('should follow valid consultation lifecycle', () async {
      final repository = MemoryConsultationRepository();

      final domain = ConsultationDomain(repository: repository);

      final consultation = Consultation(
        id: 'consultation_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        scheduledAt: DateTime(2026, 7, 7, 10),
        duration: const Duration(minutes: 30),
        status: ConsultationStatus.draft,
        type: ConsultationType.scheduled,
      );

      final createResult = await domain.create(consultation);
      expect(createResult.success, isTrue);

      final scheduleResult = await domain.schedule(consultation);
      expect(scheduleResult.success, isTrue);
      expect(scheduleResult.consultation?.status, ConsultationStatus.scheduled);

      final scheduled = scheduleResult.consultation!;

      final waitingExpertResult = await domain.transitionTo(
        scheduled,
        ConsultationStatus.waitingExpert,
      );

      expect(waitingExpertResult.success, isTrue);

      final waitingExpert = waitingExpertResult.consultation!;

      final readyResult = await domain.transitionTo(
        waitingExpert,
        ConsultationStatus.ready,
      );

      expect(readyResult.success, isTrue);

      final ready = readyResult.consultation!;

      final startResult = await domain.start(ready);

      expect(startResult.success, isTrue);
      expect(startResult.consultation?.status, ConsultationStatus.inProgress);
    });
  });
}
