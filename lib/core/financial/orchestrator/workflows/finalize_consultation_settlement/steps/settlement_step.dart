import 'package:mentora/core/financial/pipeline/pipeline.dart';

import '../../settle_consultation/'
    'settle_consultation_workflow.dart';

import '../pipeline/'
    'finalize_consultation_settlement_context.dart';

final class SettlementStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const SettlementStep({required this.workflow});

  final SettleConsultationWorkflow workflow;

  @override
  String get id => 'settlement';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    context.settlementResult = await workflow.execute(
      context.settlementContext,
    );
  }
}
