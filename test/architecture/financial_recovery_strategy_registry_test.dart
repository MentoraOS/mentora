import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'strategies/financial_recovery_decision.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'strategies/financial_recovery_strategy.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'strategies/financial_recovery_strategy_registry.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'strategies/financial_recovery_strategy_request.dart';

import 'package:mentora/core/financial/pipeline/recovery/'
    'strategies/financial_recovery_strategy_result.dart';

void main() {
  group('FinancialRecoveryStrategyRegistry', () {
    late FinancialRecoveryStrategyRegistry registry;

    setUp(() {
      registry = FinancialRecoveryStrategyRegistry();
    });

    test('registers and finds a strategy by key', () {
      final strategy = _TestStrategy(
        key: 'ledger.journal.recovery',
        supportedPipelineId: 'settlement.pipeline',
      );

      registry.register(strategy);

      final resolved = registry.findByKey<_TestContext>(
        'ledger.journal.recovery',
      );

      expect(resolved, same(strategy));
      expect(registry.length, 1);
      expect(registry.isNotEmpty, isTrue);
    });

    test('normalizes surrounding key whitespace', () {
      final strategy = _TestStrategy(
        key: ' ledger.journal.recovery ',
        supportedPipelineId: 'settlement.pipeline',
      );

      registry.register(strategy);

      expect(registry.contains('ledger.journal.recovery'), isTrue);

      expect(registry.registeredKeys, ['ledger.journal.recovery']);
    });

    test('rejects an empty strategy key', () {
      expect(
        () => registry.register(
          _TestStrategy(key: '   ', supportedPipelineId: 'settlement.pipeline'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate strategy keys', () {
      registry.register(
        _TestStrategy(
          key: 'recovery.strategy',
          supportedPipelineId: 'pipeline.one',
        ),
      );

      expect(
        () => registry.register(
          _TestStrategy(
            key: 'recovery.strategy',
            supportedPipelineId: 'pipeline.two',
          ),
        ),
        throwsStateError,
      );
    });

    test('resolves the first supporting strategy', () {
      final unsupported = _TestStrategy(
        key: 'unsupported',
        supportedPipelineId: 'another.pipeline',
      );

      final supported = _TestStrategy(
        key: 'supported',
        supportedPipelineId: 'settlement.pipeline',
      );

      registry.register(unsupported);
      registry.register(supported);

      final resolved = registry.resolve(
        _request(pipelineId: 'settlement.pipeline'),
      );

      expect(resolved, same(supported));
    });

    test('returns null when no strategy supports request', () {
      registry.register(
        _TestStrategy(
          key: 'wallet.recovery',
          supportedPipelineId: 'wallet.pipeline',
        ),
      );

      final resolved = registry.resolve(
        _request(pipelineId: 'settlement.pipeline'),
      );

      expect(resolved, isNull);
    });

    test('resolveRequired throws when unsupported', () {
      expect(
        () => registry.resolveRequired(
          _request(pipelineId: 'settlement.pipeline'),
        ),
        throwsStateError,
      );
    });

    test('returns registered keys in sorted order', () {
      registry.register(
        _TestStrategy(key: 'z.strategy', supportedPipelineId: 'z'),
      );

      registry.register(
        _TestStrategy(key: 'a.strategy', supportedPipelineId: 'a'),
      );

      expect(registry.registeredKeys, ['a.strategy', 'z.strategy']);
    });

    test('unregisters a strategy', () {
      final strategy = _TestStrategy(
        key: 'strategy',
        supportedPipelineId: 'pipeline',
      );

      registry.register(strategy);

      final removed = registry.unregister('strategy');

      expect(removed, same(strategy));
      expect(registry.isEmpty, isTrue);
    });

    test('clears all strategies', () {
      registry.register(_TestStrategy(key: 'one', supportedPipelineId: 'one'));

      registry.register(_TestStrategy(key: 'two', supportedPipelineId: 'two'));

      registry.clear();

      expect(registry.length, 0);
      expect(registry.registeredKeys, isEmpty);
    });
  });
}

final class _TestContext extends FinancialPipelineContext {
  const _TestContext();
}

final class _TestStrategy implements FinancialRecoveryStrategy<_TestContext> {
  const _TestStrategy({required this.key, required this.supportedPipelineId});

  @override
  final String key;

  final String supportedPipelineId;

  @override
  bool supports(FinancialRecoveryStrategyRequest<_TestContext> request) {
    return request.pipelineId == supportedPipelineId;
  }

  @override
  Future<FinancialRecoveryStrategyResult> recover(
    FinancialRecoveryStrategyRequest<_TestContext> request,
  ) async {
    return FinancialRecoveryStrategySuccess(
      recoveryId: request.recoveryId,
      strategyKey: key,
      decision: FinancialRecoveryDecision.ignore,
      attempt: request.attempt,
      duration: Duration.zero,
      completedAt: request.requestedAt,
    );
  }
}

FinancialRecoveryStrategyRequest<_TestContext> _request({
  String pipelineId = 'pipeline',
}) {
  return FinancialRecoveryStrategyRequest(
    recoveryId: 'recovery_001',
    pipelineId: pipelineId,
    context: const _TestContext(),
    error: StateError('failure'),
    stackTrace: StackTrace.current,
    attempt: 1,
    requestedAt: DateTime.utc(2026, 7, 15, 10),
  );
}
