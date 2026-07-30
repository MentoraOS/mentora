import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/transaction/bootstrap/'
    'financial_transaction_module.dart';
import 'package:mentora/core/financial/transaction/boundary/'
    'financial_transaction_boundary.dart';
import 'package:mentora/core/financial/transaction/boundary/'
    'in_memory_financial_transaction_boundary.dart';
import 'package:mentora/core/financial/transaction/context/'
    'financial_transaction_context.dart';
import 'package:mentora/core/financial/transaction/result/'
    'financial_transaction_result.dart';

void main() {
  group('FinancialTransactionModule', () {
    test('inMemory should assemble the complete transaction module', () {
      final module = FinancialTransactionModule.inMemory();

      expect(module.boundary, isA<InMemoryFinancialTransactionBoundary>());
    });

    test('fromBoundary should reuse the exact boundary instance', () {
      final boundary = _RecordingFinancialTransactionBoundary();

      final module = FinancialTransactionModule.fromBoundary(
        boundary: boundary,
      );

      expect(module.boundary, same(boundary));

      expect(identical(module.boundary, boundary), isTrue);
    });

    test('inMemory boundary should execute and commit a transaction', () async {
      final lifecycle = <String>[];

      final module = FinancialTransactionModule.inMemory(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await module.boundary.execute<int>(
        context: _createContext(),
        action: () async {
          lifecycle.add('action');
          return 125000;
        },
      );

      expect(lifecycle, ['begin', 'action', 'commit']);

      expect(result, isA<FinancialTransactionCommitted<int>>());

      final committed = result as FinancialTransactionCommitted<int>;

      expect(committed.value, 125000);
      expect(committed.isCommitted, isTrue);
    });

    test('inMemory module should propagate rollback result', () async {
      final expectedError = StateError('Pipeline failed.');

      final lifecycle = <String>[];

      final module = FinancialTransactionModule.inMemory(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await module.boundary.execute<void>(
        context: _createContext(),
        action: () async {
          lifecycle.add('action');
          throw expectedError;
        },
      );

      expect(lifecycle, ['begin', 'action', 'rollback']);

      expect(result, isA<FinancialTransactionRolledBack<void>>());

      final rolledBack = result as FinancialTransactionRolledBack<void>;

      expect(rolledBack.error, same(expectedError));

      expect(rolledBack.isRolledBack, isTrue);
    });

    test('inMemory module should propagate commit mechanism failure', () async {
      final commitError = StateError('Commit failed.');

      final module = FinancialTransactionModule.inMemory(
        onCommit: (context) async {
          throw commitError;
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await module.boundary.execute<String>(
        context: _createContext(),
        action: () async => 'action-value',
      );

      expect(result, isA<FinancialTransactionFailed<String>>());

      final failed = result as FinancialTransactionFailed<String>;

      expect(failed.error, same(commitError));
      expect(failed.originalError, isNull);
      expect(failed.isFailed, isTrue);
    });

    test(
      'inMemory module should propagate rollback mechanism failure',
      () async {
        final actionError = StateError('Action failed.');

        final rollbackError = StateError('Rollback failed.');

        final module = FinancialTransactionModule.inMemory(
          onRollback: (context, error, stackTrace) async {
            throw rollbackError;
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final result = await module.boundary.execute<void>(
          context: _createContext(),
          action: () async {
            throw actionError;
          },
        );

        expect(result, isA<FinancialTransactionFailed<void>>());

        final failed = result as FinancialTransactionFailed<void>;

        expect(failed.error, same(rollbackError));

        expect(failed.originalError, same(actionError));

        expect(failed.isFailed, isTrue);
      },
    );

    test('inMemory module should preserve injected completion clock', () async {
      final completionTime = DateTime(2026, 7, 17, 22, 30);

      final module = FinancialTransactionModule.inMemory(
        clock: () => completionTime,
      );

      final result = await module.boundary.execute<int>(
        context: FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17, 20),
        ),
        action: () async => 42,
      );

      expect(result.completedAt, completionTime.toUtc());
    });

    test(
      'fromBoundary module should execute through supplied boundary',
      () async {
        final boundary = _RecordingFinancialTransactionBoundary();

        final module = FinancialTransactionModule.fromBoundary(
          boundary: boundary,
        );

        final context = _createContext();

        final result = await module.boundary.execute<int>(
          context: context,
          action: () async => 99,
        );

        expect(boundary.executionCount, 1);
        expect(boundary.receivedContext, same(context));

        expect(result, isA<FinancialTransactionCommitted<int>>());

        final committed = result as FinancialTransactionCommitted<int>;

        expect(committed.value, 99);
      },
    );
  });
}

FinancialTransactionContext _createContext() {
  return FinancialTransactionContext(
    transactionId: 'transaction-001',
    executionId: 'execution-001',
    correlationId: 'consultation-001',
    startedAt: DateTime.utc(2026, 7, 17, 20),
    metadata: const {'source': 'financial-transaction-module-test'},
  );
}

final class _RecordingFinancialTransactionBoundary
    implements FinancialTransactionBoundary {
  int executionCount = 0;

  FinancialTransactionContext? receivedContext;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    executionCount++;
    receivedContext = context;

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
