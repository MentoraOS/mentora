import '../../financial_pipeline_context.dart';

import '../strategies/financial_recovery_decision.dart';
import '../strategies/financial_recovery_strategy.dart';
import '../strategies/financial_recovery_strategy_registry.dart';
import '../strategies/financial_recovery_strategy_request.dart';
import '../strategies/financial_recovery_strategy_result.dart';

import 'financial_recovery_engine.dart';

typedef FinancialRecoveryClock = DateTime Function();

// Default orchestration engine for specialized financial recovery.
//
// This engine is responsible for orchestration only:
// - enforcing the attempt limit;
// - resolving the supporting strategy;
// - executing one strategy attempt;
// - validating the returned result;
// - converting unexpected exceptions into auditable failures.
//
// Recovery business rules remain inside individual strategies.
final class DefaultFinancialRecoveryEngine implements FinancialRecoveryEngine {
  DefaultFinancialRecoveryEngine({
    required this.registry,
    this.maxAttempts = 3,
    FinancialRecoveryClock? clock,
  }) : clock = clock ?? DateTime.now {
    if (maxAttempts < 1) {
      throw ArgumentError.value(
        maxAttempts,
        'maxAttempts',
        'Maximum recovery attempts must be greater than zero.',
      );
    }
  }

  final FinancialRecoveryStrategyRegistry registry;

  // Maximum allowed attempt number for one recovery operation.
  final int maxAttempts;

  // Injectable clock for deterministic tests.
  final FinancialRecoveryClock clock;

  @override
  Future<FinancialRecoveryStrategyResult> recover<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) async {
    if (request.attempt > maxAttempts) {
      return _attemptLimitFailure(request: request);
    }

    final strategy = registry.resolve(request);

    if (strategy == null) {
      return _unsupportedRecoveryFailure(request: request);
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = await strategy.recover(request);

      stopwatch.stop();

      final contractViolation = _findContractViolation(
        request: request,
        strategy: strategy,
        result: result,
      );

      if (contractViolation != null) {
        return FinancialRecoveryStrategyFailure(
          recoveryId: request.recoveryId,
          strategyKey: strategy.key.trim(),
          decision: FinancialRecoveryDecision.terminalFailure,
          attempt: request.attempt,
          duration: stopwatch.elapsed,
          completedAt: clock().toUtc(),
          error: contractViolation,
          stackTrace: StackTrace.current,
          metadata: {
            ...request.metadata,
            'failureCategory': 'strategy_contract_violation',
            'pipelineId': request.pipelineId,
            'maxAttempts': maxAttempts,
          },
        );
      }

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();

      return FinancialRecoveryStrategyFailure(
        recoveryId: request.recoveryId,
        strategyKey: strategy.key.trim(),
        decision: FinancialRecoveryDecision.manualReview,
        attempt: request.attempt,
        duration: stopwatch.elapsed,
        completedAt: clock().toUtc(),
        error: error,
        stackTrace: stackTrace,
        metadata: {
          ...request.metadata,
          'failureCategory': 'unexpected_strategy_exception',
          'pipelineId': request.pipelineId,
          'maxAttempts': maxAttempts,
          'originalErrorType': request.error.runtimeType.toString(),
          'strategyErrorType': error.runtimeType.toString(),
        },
      );
    }
  }

  FinancialRecoveryStrategyFailure _attemptLimitFailure<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) {
    final error = StateError(
      'Recovery "${request.recoveryId}" reached '
      'attempt ${request.attempt}, exceeding the maximum '
      'allowed attempt count of $maxAttempts.',
    );

    return FinancialRecoveryStrategyFailure(
      recoveryId: request.recoveryId,
      strategyKey: 'unresolved',
      decision: FinancialRecoveryDecision.terminalFailure,
      attempt: request.attempt,
      duration: Duration.zero,
      completedAt: clock().toUtc(),
      error: error,
      stackTrace: StackTrace.current,
      metadata: {
        ...request.metadata,
        'failureCategory': 'attempt_limit_exceeded',
        'pipelineId': request.pipelineId,
        'maxAttempts': maxAttempts,
      },
    );
  }

  FinancialRecoveryStrategyFailure _unsupportedRecoveryFailure<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) {
    final error = StateError(
      'No registered financial recovery strategy supports '
      'pipeline "${request.pipelineId}" for recovery '
      '"${request.recoveryId}".',
    );

    return FinancialRecoveryStrategyFailure(
      recoveryId: request.recoveryId,
      strategyKey: 'unresolved',
      decision: FinancialRecoveryDecision.manualReview,
      attempt: request.attempt,
      duration: Duration.zero,
      completedAt: clock().toUtc(),
      error: error,
      stackTrace: StackTrace.current,
      metadata: {
        ...request.metadata,
        'failureCategory': 'unsupported_recovery',
        'pipelineId': request.pipelineId,
        'maxAttempts': maxAttempts,
        'registeredStrategyKeys': registry.registeredKeys,
      },
    );
  }

  StateError?
  _findContractViolation<TContext extends FinancialPipelineContext>({
    required FinancialRecoveryStrategyRequest<TContext> request,
    required FinancialRecoveryStrategy<TContext> strategy,
    required FinancialRecoveryStrategyResult result,
  }) {
    final normalizedStrategyKey = strategy.key.trim();

    if (normalizedStrategyKey.isEmpty) {
      return StateError(
        'The resolved financial recovery strategy '
        'has an empty key.',
      );
    }

    if (result.recoveryId != request.recoveryId) {
      return StateError(
        'Recovery strategy "$normalizedStrategyKey" '
        'returned recoveryId "${result.recoveryId}" '
        'instead of "${request.recoveryId}".',
      );
    }

    if (result.strategyKey.trim() != normalizedStrategyKey) {
      return StateError(
        'Recovery strategy "$normalizedStrategyKey" '
        'returned strategyKey "${result.strategyKey}".',
      );
    }

    if (result.attempt != request.attempt) {
      return StateError(
        'Recovery strategy "$normalizedStrategyKey" '
        'returned attempt ${result.attempt} instead of '
        '${request.attempt}.',
      );
    }

    if (result.duration.isNegative) {
      return StateError(
        'Recovery strategy "$normalizedStrategyKey" '
        'returned a negative duration.',
      );
    }

    return null;
  }
}
