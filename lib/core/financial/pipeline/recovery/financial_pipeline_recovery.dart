import '../financial_pipeline_context.dart';
import 'financial_pipeline_compensation_step.dart';

abstract interface class FinancialPipelineRecovery<
  TContext extends FinancialPipelineContext
> {
  // Pipeline identifier.
  String get pipelineId;

  // Ordered rollback steps.
  List<FinancialPipelineCompensationStep<TContext>> get compensationSteps;
}
