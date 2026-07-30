import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/engine/'
    'default_financial_recovery_engine.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_registry.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';

void main() {
  group('DefaultFinancialRecoveryEngine', () {
    late FinancialRecoveryStrategyRegistry registry;

    late DateTime fixedNow;

    late DefaultFinancialRecoveryEngine engine;

    setUp(() {
      registry = FinancialRecoveryStrategyRegistry();

      fixedNow = DateTime.utc(2026, 7, 16, 10, 30);

      engine = DefaultFinancialRecoveryEngine(
        registry: registry,
        maxAttempts: 3,
        clock: () => fixedNow,
      );
    });

    test('resolves and executes a supporting strategy', () async {
      final strategy = _TestRecoveryStrategy(
        key: 'ledger.journal.recovery',
        supportedPipelineId: 'settlement.pipeline',
      );

      registry.register(strategy);

      final request = _request(pipelineId: 'settlement.pipeline');

      final result = await engine.recover(request: request);

      expect(result, isA<FinancialRecoveryStrategySuccess>());

      expect(result.recoveryId, request.recoveryId);

      expect(result.strategyKey, 'ledger.journal.recovery');

      expect(result.decision, FinancialRecoveryDecision.ignore);

      expect(result.attempt, 1);

      expect(strategy.recoveryCallCount, 1);

      expect(strategy.lastRequest, same(request));
    });

    test('returns the valid result produced by the strategy', () async {
      final completedAt = DateTime.utc(2026, 7, 16, 9);

      final strategy = _TestRecoveryStrategy(
        key: 'pipeline.compensation',
        supportedPipelineId: 'settlement.pipeline',
        resultBuilder: (request, key) {
          return FinancialRecoveryStrategySuccess(
            recoveryId: request.recoveryId,
            strategyKey: key,
            decision: FinancialRecoveryDecision.compensate,
            attempt: request.attempt,
            duration: const Duration(milliseconds: 25),
            completedAt: completedAt,
            metadata: const {'compensatedSteps': 3},
          );
        },
      );

      registry.register(strategy);

      final result = await engine.recover(
        request: _request(pipelineId: 'settlement.pipeline'),
      );

      expect(result.decision, FinancialRecoveryDecision.compensate);

      expect(result.duration, const Duration(milliseconds: 25));

      expect(result.completedAt, completedAt);

      expect(result.metadata['compensatedSteps'], 3);
    });

    test('returns terminal failure when attempt limit is exceeded', () async {
      final strategy = _TestRecoveryStrategy(
        key: 'ledger.recovery',
        supportedPipelineId: 'settlement.pipeline',
      );

      registry.register(strategy);

      final result = await engine.recover(
        request: _request(pipelineId: 'settlement.pipeline', attempt: 4),
      );

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      expect(result.decision, FinancialRecoveryDecision.terminalFailure);

      expect(result.strategyKey, 'unresolved');

      expect(result.duration, Duration.zero);

      expect(result.completedAt, fixedNow);

      expect(result.metadata['failureCategory'], 'attempt_limit_exceeded');

      expect(result.metadata['maxAttempts'], 3);

      expect(strategy.recoveryCallCount, 0);
    });

    test('allows the final configured recovery attempt', () async {
      final strategy = _TestRecoveryStrategy(
        key: 'ledger.recovery',
        supportedPipelineId: 'settlement.pipeline',
      );

      registry.register(strategy);

      final result = await engine.recover(
        request: _request(pipelineId: 'settlement.pipeline', attempt: 3),
      );

      expect(result.isSuccess, isTrue);
      expect(result.attempt, 3);
      expect(strategy.recoveryCallCount, 1);
    });

    test(
      'returns manual review when no strategy supports the request',
      () async {
        registry.register(
          _TestRecoveryStrategy(
            key: 'wallet.recovery',
            supportedPipelineId: 'wallet.pipeline',
          ),
        );

        final result = await engine.recover(
          request: _request(pipelineId: 'settlement.pipeline'),
        );

        expect(result, isA<FinancialRecoveryStrategyFailure>());

        expect(result.decision, FinancialRecoveryDecision.manualReview);

        expect(result.strategyKey, 'unresolved');

        expect(result.completedAt, fixedNow);

        expect(result.metadata['failureCategory'], 'unsupported_recovery');

        expect(result.metadata['pipelineId'], 'settlement.pipeline');

        expect(result.metadata['registeredStrategyKeys'], ['wallet.recovery']);
      },
    );

    test('converts unexpected strategy exception into manual review', () async {
      final strategyError = StateError('Temporary provider failure');

      final strategy = _TestRecoveryStrategy(
        key: 'provider.retry',
        supportedPipelineId: 'payment.pipeline',
        errorToThrow: strategyError,
      );

      registry.register(strategy);

      final request = _request(
        pipelineId: 'payment.pipeline',
        metadata: const {'provider': 'test_provider'},
      );

      final result = await engine.recover(request: request);

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.manualReview);

      expect(failure.strategyKey, 'provider.retry');

      expect(failure.error, same(strategyError));

      expect(failure.completedAt, fixedNow);

      expect(
        failure.metadata['failureCategory'],
        'unexpected_strategy_exception',
      );

      expect(failure.metadata['provider'], 'test_provider');

      expect(failure.metadata['pipelineId'], 'payment.pipeline');

      expect(failure.metadata['strategyErrorType'], 'StateError');

      expect(strategy.recoveryCallCount, 1);
    });

    test('detects a mismatched recovery identifier', () async {
      final strategy = _TestRecoveryStrategy(
        key: 'invalid.recovery.id',
        supportedPipelineId: 'settlement.pipeline',
        resultBuilder: (request, key) {
          return FinancialRecoveryStrategySuccess(
            recoveryId: 'another_recovery',
            strategyKey: key,
            decision: FinancialRecoveryDecision.ignore,
            attempt: request.attempt,
            duration: Duration.zero,
            completedAt: request.requestedAt,
          );
        },
      );

      registry.register(strategy);

      final result = await engine.recover(
        request: _request(
          recoveryId: 'recovery_001',
          pipelineId: 'settlement.pipeline',
        ),
      );

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.terminalFailure);

      expect(
        failure.metadata['failureCategory'],
        'strategy_contract_violation',
      );

      expect(failure.error, isA<StateError>());

      expect(failure.error.toString(), contains('another_recovery'));
    });

    test('detects a mismatched strategy key', () async {
      final strategy = _TestRecoveryStrategy(
        key: 'expected.strategy',
        supportedPipelineId: 'settlement.pipeline',
        resultBuilder: (request, key) {
          return FinancialRecoveryStrategySuccess(
            recoveryId: request.recoveryId,
            strategyKey: 'wrong.strategy',
            decision: FinancialRecoveryDecision.ignore,
            attempt: request.attempt,
            duration: Duration.zero,
            completedAt: request.requestedAt,
          );
        },
      );

      registry.register(strategy);

      final result = await engine.recover(
        request: _request(pipelineId: 'settlement.pipeline'),
      );

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      expect(result.decision, FinancialRecoveryDecision.terminalFailure);

      expect(result.metadata['failureCategory'], 'strategy_contract_violation');

      expect(result.errorOrNull, isA<StateError>());
    });

    test('detects a mismatched recovery attempt', () async {
      final strategy = _TestRecoveryStrategy(
        key: 'invalid.attempt.strategy',
        supportedPipelineId: 'settlement.pipeline',
        resultBuilder: (request, key) {
          return FinancialRecoveryStrategySuccess(
            recoveryId: request.recoveryId,
            strategyKey: key,
            decision: FinancialRecoveryDecision.ignore,
            attempt: request.attempt + 1,
            duration: Duration.zero,
            completedAt: request.requestedAt,
          );
        },
      );

      registry.register(strategy);

      final result = await engine.recover(
        request: _request(pipelineId: 'settlement.pipeline', attempt: 1),
      );

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.terminalFailure);

      expect(
        failure.metadata['failureCategory'],
        'strategy_contract_violation',
      );

      expect(failure.error.toString(), contains('attempt 2 instead of 1'));
    });

    test('preserves request metadata in attempt limit failure', () async {
      final result = await engine.recover(
        request: _request(
          attempt: 5,
          metadata: const {
            'operationType': 'consultationSettlement',
            'tenantId': 'tenant_001',
          },
        ),
      );

      expect(result.metadata['operationType'], 'consultationSettlement');

      expect(result.metadata['tenantId'], 'tenant_001');

      expect(result.metadata['failureCategory'], 'attempt_limit_exceeded');
    });

    test('rejects invalid maximum attempt configuration', () {
      expect(
        () =>
            DefaultFinancialRecoveryEngine(registry: registry, maxAttempts: 0),
        throwsArgumentError,
      );

      expect(
        () =>
            DefaultFinancialRecoveryEngine(registry: registry, maxAttempts: -1),
        throwsArgumentError,
      );
    });
  });
}

final class _TestContext extends FinancialPipelineContext {
  const _TestContext();
}

typedef _ResultBuilder =
    FinancialRecoveryStrategyResult Function(
      FinancialRecoveryStrategyRequest<_TestContext> request,
      String strategyKey,
    );

final class _TestRecoveryStrategy
    implements FinancialRecoveryStrategy<_TestContext> {
  _TestRecoveryStrategy({
    required this.key,
    required this.supportedPipelineId,
    this.resultBuilder,
    this.errorToThrow,
  });

  @override
  final String key;

  final String supportedPipelineId;

  final _ResultBuilder? resultBuilder;

  final Object? errorToThrow;

  int recoveryCallCount = 0;

  FinancialRecoveryStrategyRequest<_TestContext>? lastRequest;

  @override
  bool supports(FinancialRecoveryStrategyRequest<_TestContext> request) {
    return request.pipelineId == supportedPipelineId;
  }

  @override
  Future<FinancialRecoveryStrategyResult> recover(
    FinancialRecoveryStrategyRequest<_TestContext> request,
  ) async {
    recoveryCallCount++;
    lastRequest = request;

    final configuredError = errorToThrow;

    if (configuredError != null) {
      throw configuredError;
    }

    final configuredBuilder = resultBuilder;

    if (configuredBuilder != null) {
      return configuredBuilder(request, key);
    }

    return FinancialRecoveryStrategySuccess(
      recoveryId: request.recoveryId,
      strategyKey: key,
      decision: FinancialRecoveryDecision.ignore,
      attempt: request.attempt,
      duration: Duration.zero,
      completedAt: request.requestedAt,
      metadata: const {'testStrategy': true},
    );
  }
}

FinancialRecoveryStrategyRequest<_TestContext> _request({
  String recoveryId = 'recovery_001',
  String pipelineId = 'settlement.pipeline',
  int attempt = 1,
  Map<String, dynamic> metadata = const {},
}) {
  return FinancialRecoveryStrategyRequest(
    recoveryId: recoveryId,
    pipelineId: pipelineId,
    context: const _TestContext(),
    error: StateError('Original pipeline failure'),
    stackTrace: StackTrace.current,
    attempt: attempt,
    requestedAt: DateTime.utc(2026, 7, 16, 9),
    metadata: metadata,
  );
}

extension on FinancialRecoveryStrategyResult {
  Object? get errorOrNull {
    final result = this;

    if (result is FinancialRecoveryStrategyFailure) {
      return result.error;
    }

    return null;
  }
}
