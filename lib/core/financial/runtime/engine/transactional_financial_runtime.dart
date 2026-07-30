import '../../pipeline/financial_pipeline.dart';
import '../../pipeline/financial_pipeline_context.dart';
import '../../pipeline/financial_pipeline_engine.dart';
import '../../pipeline/financial_pipeline_result.dart';

import '../../transaction/boundary/financial_transaction_boundary.dart';
import '../../transaction/context/financial_transaction_context.dart';
import '../../transaction/result/financial_transaction_result.dart';

import '../context/financial_runtime_execution_context.dart';
import '../result/financial_runtime_execution_result.dart';
import 'financial_runtime.dart';

/// Creates a transaction identifier for one Runtime execution.
typedef FinancialRuntimeTransactionIdFactory =
    String Function({
      required String executionId,
      required String correlationId,
      required int attempt,
    });

/// Transaction-aware implementation of [FinancialRuntime].
///
/// This Runtime executes every financial pipeline inside a
/// [FinancialTransactionBoundary].
///
/// Its responsibilities are:
///
/// - creating the transaction context;
/// - executing the pipeline inside the transaction boundary;
/// - forcing rollback when the pipeline returns a failure;
/// - preserving the original pipeline result;
/// - distinguishing pipeline failures from infrastructure failures;
/// - preserving execution and correlation identities.
///
/// It contains no financial business logic.
final class TransactionalFinancialRuntime implements FinancialRuntime {
  TransactionalFinancialRuntime({
    required FinancialPipelineEngine pipelineEngine,
    required FinancialTransactionBoundary transactionBoundary,
    FinancialRuntimeTransactionIdFactory? transactionIdFactory,
    DateTime Function()? clock,
  }) : _pipelineEngine = pipelineEngine,
       _transactionBoundary = transactionBoundary,
       _transactionIdFactory =
           transactionIdFactory ?? _defaultTransactionIdFactory,
       _clock = clock ?? DateTime.now;

  final FinancialPipelineEngine _pipelineEngine;

  final FinancialTransactionBoundary _transactionBoundary;

  final FinancialRuntimeTransactionIdFactory _transactionIdFactory;

  final DateTime Function() _clock;

  @override
  Future<FinancialRuntimeExecutionResult>
  execute<TContext extends FinancialPipelineContext>({
    required FinancialPipeline<TContext> pipeline,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  }) async {
    final transactionId = _requireTransactionId(
      _transactionIdFactory(
        executionId: executionContext.executionId,
        correlationId: executionContext.correlationId,
        attempt: executionContext.attempt,
      ),
    );

    final transactionStartedAt = _transactionStartedAtFor(
      executionContext.startedAt,
    );

    final transactionContext = FinancialTransactionContext(
      transactionId: transactionId,
      executionId: executionContext.executionId,
      correlationId: executionContext.correlationId,
      startedAt: transactionStartedAt,
      metadata: executionContext.metadata,
    );

    /*
     * Retains the pipeline result outside the transaction callback.
     *
     * This is essential when commit or rollback fails after the
     * pipeline has already returned a result.
     */
    FinancialPipelineResult? observedPipelineResult;

    FinancialTransactionResult<FinancialPipelineResult> transactionResult;

    try {
      transactionResult = await _transactionBoundary
          .execute<FinancialPipelineResult>(
            context: transactionContext,
            action: () async {
              final pipelineResult = await _pipelineEngine.execute<TContext>(
                pipeline: pipeline,
                context: executionContext.pipelineContext,
              );

              observedPipelineResult = pipelineResult;

              /*
                   * The transaction boundary commits whenever its action
                   * returns normally.
                   *
                   * A FinancialPipelineFailure is a returned value rather
                   * than a thrown exception. We therefore convert it into
                   * an internal transaction signal so the boundary performs
                   * a rollback.
                   */
              if (pipelineResult case final FinancialPipelineFailure failure) {
                throw _PipelineFailureRollbackSignal(failure);
              }

              return pipelineResult;
            },
          );
    } catch (error, stackTrace) {
      /*
       * A concrete transaction provider should normally represent its
       * failures through FinancialTransactionFailed.
       *
       * This safeguard handles providers that unexpectedly throw.
       */
      return FinancialRuntimeInfrastructureFailure(
        executionId: executionContext.executionId,
        correlationId: executionContext.correlationId,
        transactionId: transactionId,
        error: error,
        stackTrace: stackTrace,
        pipelineResult: observedPipelineResult,
        startedAt: executionContext.startedAt,
        completedAt: _runtimeCompletionTimeFor(executionContext.startedAt),
        attempt: executionContext.attempt,
        metadata: executionContext.metadata,
      );
    }

    return _mapTransactionResult(
      transactionResult: transactionResult,
      observedPipelineResult: observedPipelineResult,
      executionContext: executionContext,
    );
  }

  FinancialRuntimeExecutionResult
  _mapTransactionResult<TContext extends FinancialPipelineContext>({
    required FinancialTransactionResult<FinancialPipelineResult>
    transactionResult,
    required FinancialPipelineResult? observedPipelineResult,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  }) {
    return switch (transactionResult) {
      FinancialTransactionCommitted<FinancialPipelineResult> committed =>
        _mapCommittedTransaction(
          committed: committed,
          executionContext: executionContext,
        ),

      FinancialTransactionRolledBack<FinancialPipelineResult> rolledBack =>
        _mapRolledBackTransaction(
          rolledBack: rolledBack,
          observedPipelineResult: observedPipelineResult,
          executionContext: executionContext,
        ),

      FinancialTransactionFailed<FinancialPipelineResult> failed =>
        _mapFailedTransaction(
          failed: failed,
          observedPipelineResult: observedPipelineResult,
          executionContext: executionContext,
        ),
    };
  }

  FinancialRuntimeExecutionResult
  _mapCommittedTransaction<TContext extends FinancialPipelineContext>({
    required FinancialTransactionCommitted<FinancialPipelineResult> committed,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  }) {
    final pipelineResult = committed.value;

    if (pipelineResult case final FinancialPipelineFailure failure) {
      /*
       * This situation should never occur with the standard boundary,
       * because pipeline failures are converted to rollback signals.
       *
       * If a custom boundary commits such a failure, the transaction
       * contract has been violated.
       */
      return FinancialRuntimeInfrastructureFailure(
        executionId: executionContext.executionId,
        correlationId: executionContext.correlationId,
        transactionId: committed.transactionId,
        error: StateError(
          'The transaction committed even though the '
          'financial pipeline failed.',
        ),
        stackTrace: StackTrace.current,
        originalError: failure.error,
        originalStackTrace: failure.stackTrace,
        pipelineResult: failure,
        startedAt: executionContext.startedAt,
        completedAt: _normalizeCompletionTime(
          startedAt: executionContext.startedAt,
          completedAt: committed.completedAt,
        ),
        attempt: executionContext.attempt,
        metadata: executionContext.metadata,
      );
    }

    return FinancialRuntimeExecutionResult.fromPipelineResult(
      executionId: executionContext.executionId,
      correlationId: executionContext.correlationId,
      pipelineResult: pipelineResult,
      startedAt: executionContext.startedAt,
      completedAt: _normalizeCompletionTime(
        startedAt: executionContext.startedAt,
        completedAt: committed.completedAt,
      ),
      attempt: executionContext.attempt,
      metadata: executionContext.metadata,
    );
  }

  FinancialRuntimeExecutionResult
  _mapRolledBackTransaction<TContext extends FinancialPipelineContext>({
    required FinancialTransactionRolledBack<FinancialPipelineResult> rolledBack,
    required FinancialPipelineResult? observedPipelineResult,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  }) {
    final rollbackError = rolledBack.error;

    if (rollbackError case final _PipelineFailureRollbackSignal signal) {
      /*
       * The pipeline failed and the transaction rolled back
       * successfully. This is a normal, safely handled pipeline failure.
       */
      return FinancialRuntimeExecutionFailure(
        executionId: executionContext.executionId,
        correlationId: executionContext.correlationId,
        pipelineResult: signal.pipelineFailure,
        startedAt: executionContext.startedAt,
        completedAt: _normalizeCompletionTime(
          startedAt: executionContext.startedAt,
          completedAt: rolledBack.completedAt,
        ),
        attempt: executionContext.attempt,
        metadata: executionContext.metadata,
      );
    }

    /*
     * An unexpected exception escaped pipeline execution before a normal
     * FinancialPipelineResult could be produced.
     *
     * The rollback succeeded, but the Runtime could not classify the
     * operation as a regular pipeline failure.
     */
    return FinancialRuntimeInfrastructureFailure(
      executionId: executionContext.executionId,
      correlationId: executionContext.correlationId,
      transactionId: rolledBack.transactionId,
      error: rollbackError,
      stackTrace: rolledBack.stackTrace,
      pipelineResult: observedPipelineResult,
      startedAt: executionContext.startedAt,
      completedAt: _normalizeCompletionTime(
        startedAt: executionContext.startedAt,
        completedAt: rolledBack.completedAt,
      ),
      attempt: executionContext.attempt,
      metadata: executionContext.metadata,
    );
  }

  FinancialRuntimeExecutionResult
  _mapFailedTransaction<TContext extends FinancialPipelineContext>({
    required FinancialTransactionFailed<FinancialPipelineResult> failed,
    required FinancialPipelineResult? observedPipelineResult,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  }) {
    var pipelineResult = observedPipelineResult;

    Object? originalError = failed.originalError;

    StackTrace? originalStackTrace = failed.originalStackTrace;

    /*
     * When rollback fails, the transaction boundary preserves the internal
     * rollback signal as the original action error.
     *
     * We unwrap it so consumers receive the real pipeline error rather than
     * an internal Runtime implementation detail.
     */
    if (failed.originalError case final _PipelineFailureRollbackSignal signal) {
      pipelineResult = signal.pipelineFailure;
      originalError = signal.pipelineFailure.error;
      originalStackTrace = signal.pipelineFailure.stackTrace;
    }

    return FinancialRuntimeInfrastructureFailure(
      executionId: executionContext.executionId,
      correlationId: executionContext.correlationId,
      transactionId: failed.transactionId,
      error: failed.error,
      stackTrace: failed.stackTrace,
      originalError: originalError,
      originalStackTrace: originalStackTrace,
      pipelineResult: pipelineResult,
      startedAt: executionContext.startedAt,
      completedAt: _normalizeCompletionTime(
        startedAt: executionContext.startedAt,
        completedAt: failed.completedAt,
      ),
      attempt: executionContext.attempt,
      metadata: executionContext.metadata,
    );
  }

  DateTime _transactionStartedAtFor(DateTime runtimeStartedAt) {
    final now = _utcNow();
    final normalizedRuntimeStartedAt = runtimeStartedAt.toUtc();

    if (now.isBefore(normalizedRuntimeStartedAt)) {
      return normalizedRuntimeStartedAt;
    }

    return now;
  }

  DateTime _runtimeCompletionTimeFor(DateTime runtimeStartedAt) {
    return _normalizeCompletionTime(
      startedAt: runtimeStartedAt,
      completedAt: _utcNow(),
    );
  }

  DateTime _normalizeCompletionTime({
    required DateTime startedAt,
    required DateTime completedAt,
  }) {
    final normalizedStartedAt = startedAt.toUtc();

    final normalizedCompletedAt = completedAt.toUtc();

    if (normalizedCompletedAt.isBefore(normalizedStartedAt)) {
      return normalizedStartedAt;
    }

    return normalizedCompletedAt;
  }

  DateTime _utcNow() => _clock().toUtc();

  static String _defaultTransactionIdFactory({
    required String executionId,
    required String correlationId,
    required int attempt,
  }) {
    return '$executionId:transaction:$attempt';
  }

  static String _requireTransactionId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'transactionId',
        'The generated transaction identifier '
            'must not be empty.',
      );
    }

    return normalizedValue;
  }
}

/// Internal signal used only to force a transaction rollback when the
/// Financial Pipeline Engine returns a [FinancialPipelineFailure].
///
/// This signal must never escape the Transactional Financial Runtime.
final class _PipelineFailureRollbackSignal implements Exception {
  const _PipelineFailureRollbackSignal(this.pipelineFailure);

  final FinancialPipelineFailure pipelineFailure;

  @override
  String toString() {
    return 'Financial pipeline "${pipelineFailure.pipelineId}" '
        'failed at step "${pipelineFailure.failedStepId}".';
  }
}
