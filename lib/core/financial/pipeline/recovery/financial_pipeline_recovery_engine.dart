import '../financial_pipeline_context.dart';
import 'financial_pipeline_recovery.dart';
import 'financial_pipeline_recovery_result.dart';

abstract interface class FinancialPipelineRecoveryEngine {
  Future<FinancialPipelineRecoveryResult>
  recover<TContext extends FinancialPipelineContext>({
    required FinancialPipelineRecovery<TContext> recovery,
    required TContext context,
  });
}
