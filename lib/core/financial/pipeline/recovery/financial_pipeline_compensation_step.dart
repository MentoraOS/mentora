import '../financial_pipeline_context.dart';

abstract interface class FinancialPipelineCompensationStep<
  TContext extends FinancialPipelineContext
> {
  /// Unique identifier.
  String get id;

  /// Compensation logic.
  Future<void> compensate(TContext context);
}
