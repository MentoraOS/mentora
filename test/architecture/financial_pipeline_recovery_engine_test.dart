import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'default_financial_pipeline_recovery_engine.dart';
import 'package:mentora/core/financial/pipeline/recovery/'
    'financial_pipeline_compensation_step.dart';
import 'package:mentora/core/financial/pipeline/recovery/'
    'financial_pipeline_recovery.dart';
import 'package:mentora/core/financial/pipeline/recovery/'
    'financial_pipeline_recovery_result.dart';

void main() {
  group('DefaultFinancialPipelineRecoveryEngine', () {
    const engine = DefaultFinancialPipelineRecoveryEngine();

    test('executes compensations in reverse order', () async {
      final context = _TestRecoveryContext();

      final recovery = _TestRecovery(
        pipelineId: 'settlement',
        compensationSteps: const [
          _RecordingCompensation(
            id: 'rollback-settlement',
            value: 'settlement',
          ),
          _RecordingCompensation(id: 'rollback-split', value: 'split'),
          _RecordingCompensation(id: 'rollback-ledger', value: 'ledger'),
        ],
      );

      final result = await engine.recover(recovery: recovery, context: context);

      expect(context.executions, ['ledger', 'split', 'settlement']);

      expect(result, isA<FinancialPipelineRecoverySuccess>());

      final success = result as FinancialPipelineRecoverySuccess;

      expect(success.pipelineId, 'settlement');
      expect(success.executedCompensations, 3);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
    });

    test('stops when a compensation fails', () async {
      final context = _TestRecoveryContext();

      final recovery = _TestRecovery(
        pipelineId: 'settlement',
        compensationSteps: const [
          _RecordingCompensation(
            id: 'rollback-settlement',
            value: 'settlement',
          ),
          _FailingCompensation(id: 'rollback-split'),
          _RecordingCompensation(id: 'rollback-ledger', value: 'ledger'),
        ],
      );

      final result = await engine.recover(recovery: recovery, context: context);

      // Reverse order:
      // rollback-ledger succeeds,
      // rollback-split fails,
      // rollback-settlement is never executed.
      expect(context.executions, ['ledger']);

      expect(result, isA<FinancialPipelineRecoveryFailure>());

      final failure = result as FinancialPipelineRecoveryFailure;

      expect(failure.pipelineId, 'settlement');
      expect(failure.executedCompensations, 1);
      expect(failure.failedCompensationId, 'rollback-split');
      expect(failure.error, isA<StateError>());
      expect(failure.stackTrace, isNotNull);
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
    });

    test('supports a recovery without compensations', () async {
      final result = await engine.recover(
        recovery: _TestRecovery(
          pipelineId: 'settlement',
          compensationSteps: const [],
        ),
        context: _TestRecoveryContext(),
      );

      expect(result, isA<FinancialPipelineRecoverySuccess>());

      expect(result.executedCompensations, 0);
    });

    test('rejects an empty pipeline id', () {
      expect(
        () => engine.recover(
          recovery: _TestRecovery(pipelineId: ' ', compensationSteps: const []),
          context: _TestRecoveryContext(),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty compensation id', () {
      expect(
        () => engine.recover(
          recovery: _TestRecovery(
            pipelineId: 'settlement',
            compensationSteps: const [
              _RecordingCompensation(id: ' ', value: 'invalid'),
            ],
          ),
          context: _TestRecoveryContext(),
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate compensation ids', () {
      expect(
        () => engine.recover(
          recovery: _TestRecovery(
            pipelineId: 'settlement',
            compensationSteps: const [
              _RecordingCompensation(id: 'rollback-ledger', value: 'first'),
              _RecordingCompensation(id: 'rollback-ledger', value: 'second'),
            ],
          ),
          context: _TestRecoveryContext(),
        ),
        throwsStateError,
      );
    });
  });
}

final class _TestRecoveryContext extends FinancialPipelineContext {
  _TestRecoveryContext();

  final List<String> executions = [];
}

final class _TestRecovery
    implements FinancialPipelineRecovery<_TestRecoveryContext> {
  _TestRecovery({
    required this.pipelineId,
    required List<FinancialPipelineCompensationStep<_TestRecoveryContext>>
    compensationSteps,
  }) : compensationSteps = List.unmodifiable(compensationSteps);

  @override
  final String pipelineId;

  @override
  final List<FinancialPipelineCompensationStep<_TestRecoveryContext>>
  compensationSteps;
}

final class _RecordingCompensation
    implements FinancialPipelineCompensationStep<_TestRecoveryContext> {
  const _RecordingCompensation({required this.id, required this.value});

  @override
  final String id;

  final String value;

  @override
  Future<void> compensate(_TestRecoveryContext context) async {
    context.executions.add(value);
  }
}

final class _FailingCompensation
    implements FinancialPipelineCompensationStep<_TestRecoveryContext> {
  const _FailingCompensation({required this.id});

  @override
  final String id;

  @override
  Future<void> compensate(_TestRecoveryContext context) async {
    throw StateError('Simulated compensation failure.');
  }
}
