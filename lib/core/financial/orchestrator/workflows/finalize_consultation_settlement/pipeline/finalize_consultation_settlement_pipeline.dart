import '../../../../pipeline/pipeline.dart';
import '../../../../splits/engine/split_engine.dart';

import '../../financial_posting/financial_posting_workflow.dart';
import '../../settle_consultation/settle_consultation_workflow.dart';

import '../steps/financial_consistency_validation_step.dart';
import '../steps/financial_posting_step.dart';
import '../steps/posting_validation_step.dart';
import '../steps/settlement_step.dart';
import '../steps/split_calculation_step.dart';

import 'finalize_consultation_settlement_context.dart';

import '../steps/build_consultation_settlement_step.dart';
import '../steps/build_finalize_result_step.dart';
import '../steps/load_existing_settlement_step.dart';

import '../../../../domain/settlement/settlement_repository.dart';

import '../steps/evaluate_settlement_idempotency_step.dart';
import '../steps/apply_settlement_idempotency_decision_step.dart';

import 'steps/complete_settlement_step.dart';
import 'steps/start_settlement_processing_step.dart';

import '../../../../events/settlement/settlement_event_publisher.dart';

final class FinalizeConsultationSettlementPipeline
    implements FinancialPipeline<FinalizeConsultationSettlementContext> {
  FinalizeConsultationSettlementPipeline({
    required SettleConsultationWorkflow settlementWorkflow,
    required SplitEngine splitEngine,
    required FinancialPostingWorkflow financialPostingWorkflow,
    required SettlementRepository settlementRepository,
    required SettlementEventPublisher eventPublisher,
  }) : _steps = List.unmodifiable(
         <FinancialPipelineStep<FinalizeConsultationSettlementContext>>[
           LoadExistingSettlementStep(repository: settlementRepository),

           const EvaluateSettlementIdempotencyStep(),

           const ApplySettlementIdempotencyDecisionStep(),

           SettlementStep(workflow: settlementWorkflow),

           const FinancialConsistencyValidationStep(),

           SplitCalculationStep(splitEngine: splitEngine),

           const BuildConsultationSettlementStep(),

           StartSettlementProcessingStep(
             repository: settlementRepository,
             eventPublisher: eventPublisher,
           ),

           FinancialPostingStep(workflow: financialPostingWorkflow),

           const PostingValidationStep(),

           CompleteSettlementStep(
             repository: settlementRepository,
             eventPublisher: eventPublisher,
           ),

           const BuildFinalizeResultStep(),
         ],
       );

  static const String pipelineId = 'finalize-consultation-settlement';

  final List<FinancialPipelineStep<FinalizeConsultationSettlementContext>>
  _steps;

  @override
  String get id => pipelineId;

  @override
  List<FinancialPipelineStep<FinalizeConsultationSettlementContext>>
  get steps => _steps;
}
