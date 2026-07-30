import '../financial_pipeline_context.dart';

abstract interface class FinancialPipelineCompensationContext
    implements FinancialPipelineContext {
  FinancialPipelineContext get originalContext;

  Object? get failure;

  StackTrace? get stackTrace;

  String? get failedStepId;
}
