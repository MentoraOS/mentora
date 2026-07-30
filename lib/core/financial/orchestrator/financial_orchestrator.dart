import '../fees/engine/fee_engine.dart';
import '../fees/models/fee_quote.dart';

import 'registry/financial_workflow_registry.dart';

class FinancialOrchestrator {
  final FeeEngine feeEngine;

  final FinancialWorkflowRegistry workflowRegistry;

  const FinancialOrchestrator({
    required this.feeEngine,
    required this.workflowRegistry,
  });

  /// API historique conservée pendant la migration.
  FeeQuote calculateConsultationFees({
    required int grossAmountMinor,
    required String currency,
  }) {
    return feeEngine.calculate(
      policyKey: 'consultation',
      grossAmountMinor: grossAmountMinor,
      currency: currency,
    );
  }

  /// Nouvelle API générique orientée workflows.
  Future<TResult> executeWorkflow<TContext, TResult>({
    required String key,
    required TContext context,
  }) async {
    final workflow = workflowRegistry.resolve<TContext, TResult>(key);

    return workflow.execute(context);
  }
}
