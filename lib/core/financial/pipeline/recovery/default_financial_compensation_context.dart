import '../financial_pipeline_context.dart';
import 'financial_pipeline_compensation_context.dart';

final class DefaultFinancialPipelineCompensationContext
    implements FinancialPipelineCompensationContext {
  const DefaultFinancialPipelineCompensationContext({
    required this.originalContext,
    required this.failure,
    required this.stackTrace,
    required this.failedStepId,
  });

  @override
  final FinancialPipelineContext originalContext;

  @override
  final Object? failure;

  @override
  final StackTrace? stackTrace;

  @override
  final String? failedStepId;
}
