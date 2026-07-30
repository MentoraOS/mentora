import '../../pipeline/financial_pipeline.dart';
import '../../pipeline/financial_pipeline_context.dart';
import '../../pipeline/financial_pipeline_engine.dart';

import '../context/financial_runtime_execution_context.dart';
import '../result/financial_runtime_execution_result.dart';
import 'financial_runtime.dart';

// Default application-level Financial Runtime.
//
// This implementation delegates the actual pipeline execution to the
// existing [FinancialPipelineEngine].
//
// Its current responsibilities are intentionally limited to:
//
// - preserving execution identity;
// - preserving business correlation;
// - preserving attempt information;
// - propagating immutable metadata;
// - measuring the Runtime completion timestamp;
// - wrapping the exact pipeline result.
//
// Future transaction, checkpoint, snapshot, retry and recovery concerns can
// be added behind [FinancialRuntime] without changing its callers.
final class DefaultFinancialRuntime implements FinancialRuntime {
  DefaultFinancialRuntime({
    required FinancialPipelineEngine pipelineEngine,
    DateTime Function()? clock,
  }) : _pipelineEngine = pipelineEngine,
       _clock = clock ?? DateTime.now;

  final FinancialPipelineEngine _pipelineEngine;
  final DateTime Function() _clock;

  @override
  Future<FinancialRuntimeExecutionResult>
  execute<TContext extends FinancialPipelineContext>({
    required FinancialPipeline<TContext> pipeline,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  }) async {
    final pipelineResult = await _pipelineEngine.execute<TContext>(
      pipeline: pipeline,
      context: executionContext.pipelineContext,
    );

    return FinancialRuntimeExecutionResult.fromPipelineResult(
      executionId: executionContext.executionId,
      correlationId: executionContext.correlationId,
      pipelineResult: pipelineResult,
      startedAt: executionContext.startedAt,
      completedAt: _utcNow(),
      attempt: executionContext.attempt,
      metadata: executionContext.metadata,
    );
  }

  DateTime _utcNow() => _clock().toUtc();
}
