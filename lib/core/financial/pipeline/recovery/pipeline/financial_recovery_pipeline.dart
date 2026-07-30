import '../../financial_pipeline_context.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';

/// Execution boundary for the financial recovery subsystem.
///
/// A recovery pipeline surrounds the generic recovery engine and provides
/// the future extension point for:
///
/// - lifecycle events;
/// - metrics;
/// - tracing;
/// - retry supervision;
/// - audit hooks;
/// - operational observability.
///
/// It contains no financial repair logic itself. The actual diagnosis and
/// repair remain the responsibility of FinancialRecoveryStrategy instances.
abstract interface class FinancialRecoveryPipeline {
  /// Executes one financial recovery request.
  ///
  /// Implementations must preserve the original request and return the exact
  /// strategy result produced by the underlying recovery engine.
  Future<FinancialRecoveryStrategyResult> execute<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request});
}
