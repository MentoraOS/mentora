import '../../financial_pipeline_context.dart';

import '../engine/'
    'financial_recovery_engine.dart';

import '../events/'
    'financial_recovery_pipeline_event.dart';
import '../events/'
    'financial_recovery_pipeline_event_dispatcher.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';

import 'financial_recovery_pipeline.dart';

typedef FinancialRecoveryPipelineClock = DateTime Function();

typedef FinancialRecoveryPipelineStopwatchFactory = Stopwatch Function();

/// Default observable execution pipeline for financial recovery requests.
///
/// Responsibilities:
/// - emit deterministic lifecycle events;
/// - delegate recovery execution to FinancialRecoveryEngine;
/// - preserve controlled strategy results;
/// - preserve unexpected technical exceptions;
/// - always emit a finished event.
///
/// It contains no financial repair logic.
final class DefaultFinancialRecoveryPipeline
    implements FinancialRecoveryPipeline {
  DefaultFinancialRecoveryPipeline({
    required this.recoveryEngine,
    FinancialRecoveryPipelineEventDispatcher? eventDispatcher,
    FinancialRecoveryPipelineClock? clock,
    FinancialRecoveryPipelineStopwatchFactory? stopwatchFactory,
  }) : eventDispatcher =
           eventDispatcher ?? FinancialRecoveryPipelineEventDispatcher(),
       clock = clock ?? DateTime.now,
       stopwatchFactory = stopwatchFactory ?? Stopwatch.new;

  final FinancialRecoveryEngine recoveryEngine;

  final FinancialRecoveryPipelineEventDispatcher eventDispatcher;

  final FinancialRecoveryPipelineClock clock;

  final FinancialRecoveryPipelineStopwatchFactory stopwatchFactory;

  @override
  Future<FinancialRecoveryStrategyResult> execute<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) async {
    final stopwatch = stopwatchFactory();

    await eventDispatcher.dispatch(
      FinancialRecoveryPipelineStarted<TContext>(
        request: request,
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: clock().toUtc(),
        metadata: {...request.metadata, 'recoveryPipelinePhase': 'started'},
      ),
    );

    stopwatch.start();

    try {
      final result = await recoveryEngine.recover(request: request);

      stopwatch.stop();

      if (result is FinancialRecoveryStrategySuccess) {
        await eventDispatcher.dispatch(
          FinancialRecoveryPipelineSucceeded<TContext>(
            request: request,
            result: result,
            duration: stopwatch.elapsed,
            recoveryId: request.recoveryId,
            pipelineId: request.pipelineId,
            attempt: request.attempt,
            occurredAt: clock().toUtc(),
            metadata: {
              ...request.metadata,
              'strategyKey': result.strategyKey,
              'decision': result.decision.name,
              'recoveryPipelinePhase': 'succeeded',
            },
          ),
        );
      } else if (result is FinancialRecoveryStrategyFailure) {
        await eventDispatcher.dispatch(
          FinancialRecoveryPipelineFailed<TContext>(
            request: request,
            result: result,
            duration: stopwatch.elapsed,
            recoveryId: request.recoveryId,
            pipelineId: request.pipelineId,
            attempt: request.attempt,
            occurredAt: clock().toUtc(),
            metadata: {
              ...request.metadata,
              'strategyKey': result.strategyKey,
              'decision': result.decision.name,
              'recoveryPipelinePhase': 'failed',
            },
          ),
        );
      }

      return result;
    } catch (error, stackTrace) {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      }

      await eventDispatcher.dispatch(
        FinancialRecoveryPipelineCrashed<TContext>(
          request: request,
          error: error,
          stackTrace: stackTrace,
          duration: stopwatch.elapsed,
          recoveryId: request.recoveryId,
          pipelineId: request.pipelineId,
          attempt: request.attempt,
          occurredAt: clock().toUtc(),
          metadata: {
            ...request.metadata,
            'recoveryPipelinePhase': 'crashed',
            'errorType': error.runtimeType.toString(),
          },
        ),
      );

      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      }

      await eventDispatcher.dispatch(
        FinancialRecoveryPipelineFinished<TContext>(
          request: request,
          duration: stopwatch.elapsed,
          recoveryId: request.recoveryId,
          pipelineId: request.pipelineId,
          attempt: request.attempt,
          occurredAt: clock().toUtc(),
          metadata: {...request.metadata, 'recoveryPipelinePhase': 'finished'},
        ),
      );
    }
  }
}
