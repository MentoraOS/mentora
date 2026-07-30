import '../../financial_pipeline_context.dart';

import '../strategies/financial_recovery_strategy_request.dart';
import '../strategies/financial_recovery_strategy_result.dart';

// Public execution contract for automatic financial recovery.
//
// The engine:
// - resolves the appropriate recovery strategy;
// - enforces the configured attempt limit;
// - executes exactly one recovery attempt;
// - converts unexpected failures into auditable results.
//
// It does not know the details of Ledger, Wallet, Escrow or payment
// providers. Those responsibilities belong to specialized strategies.

abstract interface class FinancialRecoveryEngine {
  Future<FinancialRecoveryStrategyResult> recover<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request});
}
