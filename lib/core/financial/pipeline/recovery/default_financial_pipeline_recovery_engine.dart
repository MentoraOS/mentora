import '../financial_pipeline_context.dart';

import 'financial_pipeline_recovery.dart';
import 'financial_pipeline_recovery_engine.dart';
import 'financial_pipeline_recovery_result.dart';

final class DefaultFinancialPipelineRecoveryEngine
    implements FinancialPipelineRecoveryEngine {
  const DefaultFinancialPipelineRecoveryEngine();

  @override
  Future<FinancialPipelineRecoveryResult>
  recover<TContext extends FinancialPipelineContext>({
    required FinancialPipelineRecovery<TContext> recovery,
    required TContext context,
  }) async {
    _validateRecovery(recovery);

    final stopwatch = Stopwatch()..start();
    var executedCompensations = 0;

    for (final compensation in recovery.compensationSteps.reversed) {
      try {
        await compensation.compensate(context);
        executedCompensations++;
      } catch (error, stackTrace) {
        stopwatch.stop();

        return FinancialPipelineRecoveryFailure(
          pipelineId: recovery.pipelineId,
          executedCompensations: executedCompensations,
          duration: stopwatch.elapsed,
          failedCompensationId: compensation.id,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    stopwatch.stop();

    return FinancialPipelineRecoverySuccess(
      pipelineId: recovery.pipelineId,
      executedCompensations: executedCompensations,
      duration: stopwatch.elapsed,
    );
  }

  void _validateRecovery<TContext extends FinancialPipelineContext>(
    FinancialPipelineRecovery<TContext> recovery,
  ) {
    if (recovery.pipelineId.trim().isEmpty) {
      throw ArgumentError.value(
        recovery.pipelineId,
        'pipelineId',
        'Recovery pipeline identifier must not be empty.',
      );
    }

    final compensationIds = <String>{};

    for (final compensation in recovery.compensationSteps) {
      final normalizedId = compensation.id.trim();

      if (normalizedId.isEmpty) {
        throw ArgumentError.value(
          compensation.id,
          'compensationStep.id',
          'Compensation identifier must not be empty.',
        );
      }

      if (!compensationIds.add(normalizedId)) {
        throw StateError(
          'The recovery for pipeline '
          '"${recovery.pipelineId}" contains duplicate '
          'compensation identifier "$normalizedId".',
        );
      }
    }
  }
}
