import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/transaction/boundary/'
    'financial_transaction_boundary.dart';
import 'package:mentora/core/financial/transaction/context/'
    'financial_transaction_context.dart';
import 'package:mentora/core/financial/transaction/result/'
    'financial_transaction_result.dart';

void main() {
  group('FinancialTransactionBoundary', () {
    test('should allow a committed generic result', () async {
      final boundary = _CommittedFinancialTransactionBoundary();

      final context = FinancialTransactionContext(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        startedAt: DateTime.utc(2026, 7, 17, 20),
      );

      final result = await boundary.execute<int>(
        context: context,
        action: () async => 125000,
      );

      expect(result, isA<FinancialTransactionCommitted<int>>());

      final committed = result as FinancialTransactionCommitted<int>;

      expect(committed.value, 125000);
      expect(committed.transactionId, context.transactionId);
      expect(committed.executionId, context.executionId);
      expect(committed.correlationId, context.correlationId);
    });

    test('should support void transaction actions', () async {
      final boundary = _CommittedFinancialTransactionBoundary();

      var executed = false;

      final result = await boundary.execute<void>(
        context: FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        action: () async {
          executed = true;
        },
      );

      expect(executed, isTrue);

      expect(result, isA<FinancialTransactionCommitted<void>>());
    });

    test('should allow a rolled-back generic result', () async {
      final expectedError = StateError('Financial action failed.');

      final boundary = _RolledBackFinancialTransactionBoundary(
        error: expectedError,
      );

      final result = await boundary.execute<String>(
        context: FinancialTransactionContext(
          transactionId: 'transaction-002',
          executionId: 'execution-002',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        action: () async => 'unreachable',
      );

      expect(result, isA<FinancialTransactionRolledBack<String>>());

      final rolledBack = result as FinancialTransactionRolledBack<String>;

      expect(rolledBack.error, same(expectedError));
    });

    test('should allow a failed transaction mechanism result', () async {
      final transactionError = StateError('Commit failed.');

      final boundary = _FailedFinancialTransactionBoundary(
        error: transactionError,
      );

      final result = await boundary.execute<double>(
        context: FinancialTransactionContext(
          transactionId: 'transaction-003',
          executionId: 'execution-003',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        action: () async => 10.5,
      );

      expect(result, isA<FinancialTransactionFailed<double>>());

      final failed = result as FinancialTransactionFailed<double>;

      expect(failed.error, same(transactionError));
    });
  });
}

final class _CommittedFinancialTransactionBoundary
    implements FinancialTransactionBoundary {
  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    final value = await action();

    return FinancialTransactionCommitted<T>(
      transactionId: context.transactionId,
      executionId: context.executionId,
      correlationId: context.correlationId,
      value: value,
      startedAt: context.startedAt,
      completedAt: context.startedAt,
      metadata: context.metadata,
    );
  }
}

final class _RolledBackFinancialTransactionBoundary
    implements FinancialTransactionBoundary {
  _RolledBackFinancialTransactionBoundary({required this.error});

  final Object error;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    return FinancialTransactionRolledBack<T>(
      transactionId: context.transactionId,
      executionId: context.executionId,
      correlationId: context.correlationId,
      error: error,
      stackTrace: StackTrace.current,
      startedAt: context.startedAt,
      completedAt: context.startedAt,
      metadata: context.metadata,
    );
  }
}

final class _FailedFinancialTransactionBoundary
    implements FinancialTransactionBoundary {
  _FailedFinancialTransactionBoundary({required this.error});

  final Object error;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    return FinancialTransactionFailed<T>(
      transactionId: context.transactionId,
      executionId: context.executionId,
      correlationId: context.correlationId,
      error: error,
      stackTrace: StackTrace.current,
      startedAt: context.startedAt,
      completedAt: context.startedAt,
      metadata: context.metadata,
    );
  }
}
