import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/consultation/domains/consultation_domain.dart';
import 'package:mentora/core/consultation/engine/consultation_engine.dart';
import 'package:mentora/core/consultation/models/consultation.dart';
import 'package:mentora/core/consultation/models/consultation_status.dart';
import 'package:mentora/core/consultation/models/consultation_type.dart';
import 'package:mentora/core/consultation/repositories/memory_consultation_repository.dart';
import 'package:mentora/core/consultation/workflows/create_consultation_workflow.dart';
import 'package:mentora/core/workflow/workflow_context.dart';
import 'package:mentora/core/workflow/workflow_state.dart';

void main() {
  group('Create Consultation Workflow', () {
    test('should create consultation successfully', () async {
      final repository = MemoryConsultationRepository();

      final domain = ConsultationDomain(repository: repository);

      final engine = ConsultationEngine(domain: domain);

      final consultation = Consultation(
        id: 'consultation_workflow_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        scheduledAt: DateTime(2026, 7, 7, 10),
        duration: const Duration(minutes: 30),
        status: ConsultationStatus.draft,
        type: ConsultationType.scheduled,
      );

      final workflow = CreateConsultationWorkflow(
        engine: engine,
        consultation: consultation,
      );

      final result = await workflow.execute(
        const WorkflowContext(
          userId: 'client_001',
          workspaceId: 'workspace_001',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.state, WorkflowState.completed);
      expect(result.data?.id, 'consultation_workflow_001');
    });
  });
}
