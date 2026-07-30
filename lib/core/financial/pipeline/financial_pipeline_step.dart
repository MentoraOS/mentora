import 'financial_pipeline_context.dart';

/// Represents one executable operation inside a financial pipeline.
///
/// Each step has a stable identifier and receives the same typed context
/// shared throughout the pipeline execution.
abstract interface class FinancialPipelineStep<
  TContext extends FinancialPipelineContext
> {
  /// Stable and unique identifier of this step inside its pipeline.
  ///
  /// Examples:
  /// - load-consultation
  /// - calculate-fees
  /// - build-ledger-postings
  /// - post-ledger-transaction
  String get id;

  /// Executes the step using the shared pipeline context.
  Future<void> execute(TContext context);
}
