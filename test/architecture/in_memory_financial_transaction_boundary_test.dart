import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/transaction/boundary/'
    'in_memory_financial_transaction_boundary.dart';
import 'package:mentora/core/financial/transaction/context/'
    'financial_transaction_context.dart';
import 'package:mentora/core/financial/transaction/result/'
    'financial_transaction_result.dart';
import 'package:mentora/core/financial/transaction/state/'
    'financial_transaction_state.dart';

void main() {
  group('InMemoryFinancialTransactionBoundary', () {
    test('should begin, execute and commit a successful transaction', () async {
      final lifecycle = <String>[];

      final boundary = InMemoryFinancialTransactionBoundary(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 2),
      );

      final result = await boundary.execute<int>(
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

      expect(committed.state, FinancialTransactionState.committed);

      expect(committed.isCommitted, isTrue);
      expect(committed.isRolledBack, isFalse);
      expect(committed.isFailed, isFalse);

      expect(committed.duration, const Duration(seconds: 2));

      expect(boundary.hasActiveTransactions, isFalse);
      expect(boundary.activeTransactionIds, isEmpty);
    });

    test('should rollback when the transaction action fails', () async {
      final lifecycle = <String>[];

      final expectedError = StateError('Ledger posting failed.');

      final boundary = InMemoryFinancialTransactionBoundary(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');

          expect(error, same(expectedError));
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await boundary.execute<void>(
        context: _createContext(),
        action: () async {
          lifecycle.add('action');
          throw expectedError;
        },
      );

      expect(lifecycle, ['begin', 'action', 'rollback']);

      expect(result, isA<FinancialTransactionRolledBack<void>>());

      final rolledBack = result as FinancialTransactionRolledBack<void>;

      expect(rolledBack.state, FinancialTransactionState.rolledBack);

      expect(rolledBack.error, same(expectedError));
      expect(rolledBack.stackTrace, isNotNull);

      expect(rolledBack.isCommitted, isFalse);
      expect(rolledBack.isRolledBack, isTrue);
      expect(rolledBack.isFailed, isFalse);

      expect(boundary.hasActiveTransactions, isFalse);
    });

    test('should return failed result when commit fails', () async {
      final lifecycle = <String>[];

      final commitError = StateError('Commit failed.');

      final boundary = InMemoryFinancialTransactionBoundary(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
          throw commitError;
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await boundary.execute<String>(
        context: _createContext(),
        action: () async {
          lifecycle.add('action');
          return 'completed-action';
        },
      );

      expect(lifecycle, ['begin', 'action', 'commit']);

      expect(result, isA<FinancialTransactionFailed<String>>());

      final failed = result as FinancialTransactionFailed<String>;

      expect(failed.state, FinancialTransactionState.failed);

      expect(failed.error, same(commitError));
      expect(failed.originalError, isNull);
      expect(failed.originalStackTrace, isNull);

      expect(failed.isCommitted, isFalse);
      expect(failed.isRolledBack, isFalse);
      expect(failed.isFailed, isTrue);

      expect(boundary.hasActiveTransactions, isFalse);
    });

    test('should preserve action error when rollback also fails', () async {
      final lifecycle = <String>[];

      final actionError = StateError('Pipeline execution failed.');

      final rollbackError = StateError('Rollback failed.');

      final boundary = InMemoryFinancialTransactionBoundary(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');
          throw rollbackError;
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await boundary.execute<void>(
        context: _createContext(),
        action: () async {
          lifecycle.add('action');
          throw actionError;
        },
      );

      expect(lifecycle, ['begin', 'action', 'rollback']);

      expect(result, isA<FinancialTransactionFailed<void>>());

      final failed = result as FinancialTransactionFailed<void>;

      expect(failed.error, same(rollbackError));
      expect(failed.originalError, same(actionError));

      expect(failed.stackTrace, isNotNull);
      expect(failed.originalStackTrace, isNotNull);

      expect(failed.isFailed, isTrue);
      expect(boundary.hasActiveTransactions, isFalse);
    });

    test('should return failed result when begin fails', () async {
      final beginError = StateError('Unable to open transaction.');

      var actionExecuted = false;
      var commitExecuted = false;
      var rollbackExecuted = false;

      final boundary = InMemoryFinancialTransactionBoundary(
        onBegin: (context) async {
          throw beginError;
        },
        onCommit: (context) async {
          commitExecuted = true;
        },
        onRollback: (context, error, stackTrace) async {
          rollbackExecuted = true;
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await boundary.execute<void>(
        context: _createContext(),
        action: () async {
          actionExecuted = true;
        },
      );

      expect(result, isA<FinancialTransactionFailed<void>>());

      final failed = result as FinancialTransactionFailed<void>;

      expect(failed.error, same(beginError));

      expect(actionExecuted, isFalse);
      expect(commitExecuted, isFalse);
      expect(rollbackExecuted, isFalse);

      expect(boundary.hasActiveTransactions, isFalse);
    });

    test('should support void action commit', () async {
      var actionExecuted = false;

      final boundary = InMemoryFinancialTransactionBoundary(
        clock: () => DateTime.utc(2026, 7, 17, 20),
      );

      final result = await boundary.execute<void>(
        context: _createContext(),
        action: () async {
          actionExecuted = true;
        },
      );

      expect(actionExecuted, isTrue);

      expect(result, isA<FinancialTransactionCommitted<void>>());

      final committed = result as FinancialTransactionCommitted<void>;

      expect(committed.isCommitted, isTrue);
      expect(committed.state, FinancialTransactionState.committed);
    });

    test('should preserve all transaction identities and metadata', () async {
      final metadata = <String, Object?>{
        'provider': 'paydunya',
        'country': 'ML',
      };

      final context = FinancialTransactionContext(
        transactionId: 'transaction-777',
        executionId: 'execution-456',
        correlationId: 'consultation-123',
        startedAt: DateTime.utc(2026, 7, 17, 20),
        metadata: metadata,
      );

      final boundary = InMemoryFinancialTransactionBoundary(
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await boundary.execute<int>(
        context: context,
        action: () async => 42,
      );

      metadata['provider'] = 'modified';

      expect(result.transactionId, 'transaction-777');

      expect(result.executionId, 'execution-456');

      expect(result.correlationId, 'consultation-123');

      expect(result.metadata['provider'], 'paydunya');

      expect(result.metadata['country'], 'ML');

      expect(
        () => result.metadata['new-key'] = 'value',
        throwsUnsupportedError,
      );
    });

    test(
      'should expose an active transaction while action is running',
      () async {
        final actionStarted = Completer<void>();
        final releaseAction = Completer<void>();

        final boundary = InMemoryFinancialTransactionBoundary(
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final context = _createContext();

        final transactionFuture = boundary.execute<void>(
          context: context,
          action: () async {
            actionStarted.complete();
            await releaseAction.future;
          },
        );

        await actionStarted.future;

        expect(boundary.hasActiveTransactions, isTrue);

        expect(boundary.activeTransactionIds, contains(context.transactionId));

        releaseAction.complete();

        final result = await transactionFuture;

        expect(result.isCommitted, isTrue);
        expect(boundary.hasActiveTransactions, isFalse);
      },
    );

    test(
      'should reject concurrent execution of the same transaction identifier',
      () async {
        final firstActionStarted = Completer<void>();
        final releaseFirstAction = Completer<void>();

        final boundary = InMemoryFinancialTransactionBoundary(
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final context = _createContext();

        final firstFuture = boundary.execute<void>(
          context: context,
          action: () async {
            firstActionStarted.complete();
            await releaseFirstAction.future;
          },
        );

        await firstActionStarted.future;

        var secondActionExecuted = false;

        final secondResult = await boundary.execute<void>(
          context: context,
          action: () async {
            secondActionExecuted = true;
          },
        );

        expect(secondActionExecuted, isFalse);

        expect(secondResult, isA<FinancialTransactionFailed<void>>());

        final secondFailure = secondResult as FinancialTransactionFailed<void>;

        expect(secondFailure.error, isA<StateError>());

        expect(secondFailure.error.toString(), contains('already active'));

        releaseFirstAction.complete();

        final firstResult = await firstFuture;

        expect(firstResult.isCommitted, isTrue);
        expect(boundary.hasActiveTransactions, isFalse);
      },
    );

    test(
      'should allow different transaction identifiers concurrently',
      () async {
        final bothStarted = Completer<void>();
        final releaseActions = Completer<void>();

        var startedCount = 0;

        Future<void> waitAction() async {
          startedCount++;

          if (startedCount == 2) {
            bothStarted.complete();
          }

          await releaseActions.future;
        }

        final boundary = InMemoryFinancialTransactionBoundary(
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final firstFuture = boundary.execute<void>(
          context: _createContext(transactionId: 'transaction-001'),
          action: waitAction,
        );

        final secondFuture = boundary.execute<void>(
          context: _createContext(transactionId: 'transaction-002'),
          action: waitAction,
        );

        await bothStarted.future;

        expect(
          boundary.activeTransactionIds,
          containsAll(['transaction-001', 'transaction-002']),
        );

        releaseActions.complete();

        final results = await Future.wait([firstFuture, secondFuture]);

        expect(results.every((result) => result.isCommitted), isTrue);

        expect(boundary.hasActiveTransactions, isFalse);
      },
    );

    test(
      'should remove active transaction even after mechanism failure',
      () async {
        final boundary = InMemoryFinancialTransactionBoundary(
          onCommit: (context) async {
            throw StateError('Commit failed.');
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final result = await boundary.execute<void>(
          context: _createContext(),
          action: () async {},
        );

        expect(result.isFailed, isTrue);
        expect(boundary.hasActiveTransactions, isFalse);
        expect(boundary.activeTransactionIds, isEmpty);
      },
    );

    test('should never produce completion before transaction start', () async {
      final startedAt = DateTime.utc(2026, 7, 17, 20);

      final boundary = InMemoryFinancialTransactionBoundary(
        clock: () => DateTime.utc(2026, 7, 17, 19),
      );

      final result = await boundary.execute<void>(
        context: FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          startedAt: startedAt,
        ),
        action: () async {},
      );

      expect(result.completedAt, startedAt);
      expect(result.duration, Duration.zero);
    });
  });
}

FinancialTransactionContext _createContext({
  String transactionId = 'transaction-001',
}) {
  return FinancialTransactionContext(
    transactionId: transactionId,
    executionId: 'execution-001',
    correlationId: 'consultation-001',
    startedAt: DateTime.utc(2026, 7, 17, 20),
    metadata: const {'source': 'transaction-boundary-test'},
  );
}
