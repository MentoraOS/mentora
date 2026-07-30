import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'financial_pipeline_compensation_step.dart';
import 'package:mentora/core/financial/pipeline/recovery/'
    'financial_pipeline_recovery.dart';
import 'package:mentora/core/financial/pipeline/recovery/'
    'financial_pipeline_recovery_registry.dart';

void main() {
  group('FinancialPipelineRecoveryRegistry', () {
    test('registers and resolves a recovery', () {
      final registry = FinancialPipelineRecoveryRegistry();

      final recovery = _TestRecovery(pipelineId: 'settlement');

      registry.register(recovery);

      expect(registry.contains('settlement'), isTrue);

      final resolved = registry.find<_TestContext>('settlement');

      expect(resolved, same(recovery));
    });

    test('rejects duplicate registrations', () {
      final registry = FinancialPipelineRecoveryRegistry();

      registry.register(_TestRecovery(pipelineId: 'settlement'));

      expect(
        () => registry.register(_TestRecovery(pipelineId: 'settlement')),
        throwsStateError,
      );
    });

    test('returns null for an unknown pipeline', () {
      final registry = FinancialPipelineRecoveryRegistry();

      expect(registry.find<_TestContext>('unknown'), isNull);
    });

    test('returns sorted pipeline ids', () {
      final registry = FinancialPipelineRecoveryRegistry();

      registry.register(_TestRecovery(pipelineId: 'settlement'));

      registry.register(_TestRecovery(pipelineId: 'refund'));

      expect(registry.registeredPipelineIds, ['refund', 'settlement']);
    });

    test('unregisters one recovery', () {
      final registry = FinancialPipelineRecoveryRegistry();

      registry.register(_TestRecovery(pipelineId: 'settlement'));

      registry.unregister('settlement');

      expect(registry.contains('settlement'), isFalse);
    });

    test('clears every registered recovery', () {
      final registry = FinancialPipelineRecoveryRegistry();

      registry.register(_TestRecovery(pipelineId: 'settlement'));

      registry.register(_TestRecovery(pipelineId: 'refund'));

      registry.clear();

      expect(registry.registeredPipelineIds, isEmpty);
    });
  });
}

final class _TestContext extends FinancialPipelineContext {
  _TestContext();
}

final class _TestRecovery implements FinancialPipelineRecovery<_TestContext> {
  _TestRecovery({required this.pipelineId});

  @override
  final String pipelineId;

  @override
  List<FinancialPipelineCompensationStep<_TestContext>> get compensationSteps =>
      const [];
}
