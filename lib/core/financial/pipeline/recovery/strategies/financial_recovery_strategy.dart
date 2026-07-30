import '../../financial_pipeline_context.dart';

import 'financial_recovery_strategy_request.dart';
import 'financial_recovery_strategy_result.dart';

// Specialized recovery behavior for a category of financial failures.
//
// A strategy:
// - identifies whether it supports a failed operation;
// - inspects the current financial state;
// - performs the smallest safe recovery action;
// - never silently duplicates an accounting operation.
//
// Examples:
// - recover a transaction posted without a journal;
// - retry a temporarily unavailable payment provider;
// - compensate an interrupted settlement pipeline;
// - escalate an unsafe operation for manual review.
abstract interface class FinancialRecoveryStrategy<
  TContext extends FinancialPipelineContext
> {
  // Stable and unique strategy identifier.
  //
  // Example:
  // ledger.journal.posting.recovery
  String get key;

  // Returns whether this strategy can safely process [request].
  //
  // This method must not produce side effects.
  bool supports(FinancialRecoveryStrategyRequest<TContext> request);

  // Executes one recovery attempt.
  //
  // Implementations must be idempotent. Calling this method again for the
  // same operation must not create duplicate transactions or journals.
  Future<FinancialRecoveryStrategyResult> recover(
    FinancialRecoveryStrategyRequest<TContext> request,
  );
}
