import '../../workflow/workflow.dart';
import '../../workflow/workflow_context.dart';
import '../../workflow/workflow_result.dart';

import '../engine/consultation_engine.dart';
import '../models/consultation.dart';

class CreateConsultationWorkflow extends Workflow<Consultation> {
  final ConsultationEngine engine;
  final Consultation consultation;

  const CreateConsultationWorkflow({
    required this.engine,
    required this.consultation,
  });

  @override
  String get name => 'consultation.create';

  @override
  Future<WorkflowResult<Consultation>> execute(WorkflowContext context) async {
    final result = await engine.create(consultation);

    if (!result.success || result.consultation == null) {
      return WorkflowResult.failure(
        message: result.message ?? 'Consultation creation failed',
      );
    }

    return WorkflowResult.success(
      data: result.consultation,
      message: 'Consultation created successfully',
    );
  }
}
