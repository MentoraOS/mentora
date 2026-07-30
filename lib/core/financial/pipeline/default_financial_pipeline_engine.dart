import 'events/financial_pipeline_event_dispatcher.dart';
import 'events/pipeline_completed_event.dart';
import 'events/pipeline_failed_event.dart';
import 'events/pipeline_started_event.dart';
import 'events/pipeline_step_completed_event.dart';
import 'events/pipeline_step_started_event.dart';

import 'financial_pipeline.dart';
import 'financial_pipeline_context.dart';
import 'financial_pipeline_engine.dart';
import 'financial_pipeline_exception.dart';
import 'financial_pipeline_result.dart';

final class DefaultFinancialPipelineEngine implements FinancialPipelineEngine {
  DefaultFinancialPipelineEngine({
    FinancialPipelineEventDispatcher? eventDispatcher,
    DateTime Function()? clock,
  }) : _eventDispatcher = eventDispatcher ?? FinancialPipelineEventDispatcher(),
       _clock = clock ?? DateTime.now;

  final FinancialPipelineEventDispatcher _eventDispatcher;
  final DateTime Function() _clock;

  @override
  Future<FinancialPipelineResult>
  execute<TContext extends FinancialPipelineContext>({
    required FinancialPipeline<TContext> pipeline,
    required TContext context,
  }) async {
    _validatePipeline(pipeline);

    final stopwatch = Stopwatch()..start();
    var executedSteps = 0;

    _eventDispatcher.dispatch(
      PipelineStartedEvent(pipelineId: pipeline.id, occurredAt: _utcNow()),
    );

    for (final step in pipeline.steps) {
      final stepStopwatch = Stopwatch()..start();

      _eventDispatcher.dispatch(
        PipelineStepStartedEvent(
          pipelineId: pipeline.id,
          stepId: step.id,
          occurredAt: _utcNow(),
        ),
      );

      try {
        await step.execute(context);

        stepStopwatch.stop();
        executedSteps++;

        _eventDispatcher.dispatch(
          PipelineStepCompletedEvent(
            pipelineId: pipeline.id,
            stepId: step.id,
            occurredAt: _utcNow(),
            duration: stepStopwatch.elapsed,
          ),
        );
      } catch (error, stackTrace) {
        stepStopwatch.stop();
        stopwatch.stop();

        _eventDispatcher.dispatch(
          PipelineFailedEvent(
            pipelineId: pipeline.id,
            stepId: step.id,
            occurredAt: _utcNow(),
            executedSteps: executedSteps,
            duration: stopwatch.elapsed,
            failedStepDuration: stepStopwatch.elapsed,
            error: error,
            stackTrace: stackTrace,
          ),
        );

        return FinancialPipelineFailure(
          pipelineId: pipeline.id,
          executedSteps: executedSteps,
          duration: stopwatch.elapsed,
          failedStepId: step.id,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    stopwatch.stop();

    _eventDispatcher.dispatch(
      PipelineCompletedEvent(
        pipelineId: pipeline.id,
        occurredAt: _utcNow(),
        executedSteps: executedSteps,
        duration: stopwatch.elapsed,
      ),
    );

    return FinancialPipelineSuccess(
      pipelineId: pipeline.id,
      executedSteps: executedSteps,
      duration: stopwatch.elapsed,
    );
  }

  DateTime _utcNow() => _clock().toUtc();

  void _validatePipeline<TContext extends FinancialPipelineContext>(
    FinancialPipeline<TContext> pipeline,
  ) {
    if (pipeline.id.trim().isEmpty) {
      throw const InvalidFinancialPipelineException(
        pipelineId: '',
        message: 'The pipeline identifier must not be empty.',
      );
    }

    if (pipeline.steps.isEmpty) {
      throw InvalidFinancialPipelineException(
        pipelineId: pipeline.id,
        message: 'The pipeline must contain at least one step.',
      );
    }

    final stepIds = <String>{};

    for (final step in pipeline.steps) {
      final normalizedStepId = step.id.trim();

      if (normalizedStepId.isEmpty) {
        throw InvalidFinancialPipelineException(
          pipelineId: pipeline.id,
          message: 'A pipeline step identifier must not be empty.',
        );
      }

      if (!stepIds.add(normalizedStepId)) {
        throw InvalidFinancialPipelineException(
          pipelineId: pipeline.id,
          message:
              'The pipeline contains duplicate step identifier '
              '"$normalizedStepId".',
        );
      }
    }
  }
}
