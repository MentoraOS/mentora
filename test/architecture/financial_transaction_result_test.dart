import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/transaction/result/'
    'financial_transaction_result.dart';
import 'package:mentora/core/financial/transaction/state/'
    'financial_transaction_state.dart';

void main() {
  group('FinancialTransactionResult', () {
    test('should create a committed transaction result', () {
      final result = FinancialTransactionCommitted<String>(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        value: 'committed-value',
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 2),
      );

      expect(result.state, FinancialTransactionState.committed);

      expect(result.isCommitted, isTrue);
      expect(result.isRolledBack, isFalse);
      expect(result.isFailed, isFalse);

      expect(result.transactionId, 'transaction-001');

      expect(result.executionId, 'execution-001');

      expect(result.correlationId, 'consultation-001');

      expect(result.value, 'committed-value');

      expect(result.duration, const Duration(seconds: 2));
    });

    test('should create a rolled-back transaction result', () {
      final error = StateError('Ledger posting failed.');

      final stackTrace = StackTrace.current;

      final result = FinancialTransactionRolledBack<void>(
        transactionId: 'transaction-002',
        executionId: 'execution-002',
        correlationId: 'consultation-001',
        error: error,
        stackTrace: stackTrace,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      expect(result.state, FinancialTransactionState.rolledBack);

      expect(result.isCommitted, isFalse);
      expect(result.isRolledBack, isTrue);
      expect(result.isFailed, isFalse);

      expect(result.error, same(error));
      expect(result.stackTrace, same(stackTrace));
    });

    test('should create a failed transaction result', () {
      final transactionError = StateError('Rollback failed.');

      final transactionStackTrace = StackTrace.current;

      final originalError = StateError('Pipeline failed.');

      final originalStackTrace = StackTrace.current;

      final result = FinancialTransactionFailed<void>(
        transactionId: 'transaction-003',
        executionId: 'execution-003',
        correlationId: 'consultation-001',
        error: transactionError,
        stackTrace: transactionStackTrace,
        originalError: originalError,
        originalStackTrace: originalStackTrace,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      expect(result.state, FinancialTransactionState.failed);

      expect(result.isCommitted, isFalse);
      expect(result.isRolledBack, isFalse);
      expect(result.isFailed, isTrue);

      expect(result.error, same(transactionError));

      expect(result.stackTrace, same(transactionStackTrace));

      expect(result.originalError, same(originalError));

      expect(result.originalStackTrace, same(originalStackTrace));
    });

    test('should trim transaction identities', () {
      final result = FinancialTransactionCommitted<void>(
        transactionId: '  transaction-001  ',
        executionId: '  execution-001  ',
        correlationId: '  consultation-001  ',
        value: null,
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
      );

      expect(result.transactionId, 'transaction-001');

      expect(result.executionId, 'execution-001');

      expect(result.correlationId, 'consultation-001');
    });

    test('should normalize transaction timestamps to UTC', () {
      final startedAt = DateTime(2026, 7, 17, 20);

      final completedAt = startedAt.add(const Duration(seconds: 3));

      final result = FinancialTransactionCommitted<void>(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        value: null,
        startedAt: startedAt,
        completedAt: completedAt,
      );

      expect(result.startedAt.isUtc, isTrue);
      expect(result.completedAt.isUtc, isTrue);

      expect(result.startedAt, startedAt.toUtc());

      expect(result.completedAt, completedAt.toUtc());
    });

    test('should expose immutable metadata', () {
      final sourceMetadata = <String, Object?>{
        'provider': 'paydunya',
        'country': 'ML',
      };

      final result = FinancialTransactionCommitted<void>(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        value: null,
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
        metadata: sourceMetadata,
      );

      sourceMetadata['provider'] = 'modified';

      expect(result.metadata['provider'], 'paydunya');

      expect(result.metadata['country'], 'ML');

      expect(
        () => result.metadata['new-key'] = 'value',
        throwsUnsupportedError,
      );
    });

    test('should reject an empty transaction identifier', () {
      expect(
        () => FinancialTransactionCommitted<void>(
          transactionId: '   ',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          value: null,
          startedAt: DateTime.utc(2026, 7, 17),
          completedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an empty execution identifier', () {
      expect(
        () => FinancialTransactionCommitted<void>(
          transactionId: 'transaction-001',
          executionId: '',
          correlationId: 'consultation-001',
          value: null,
          startedAt: DateTime.utc(2026, 7, 17),
          completedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an empty correlation identifier', () {
      expect(
        () => FinancialTransactionCommitted<void>(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: '  ',
          value: null,
          startedAt: DateTime.utc(2026, 7, 17),
          completedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject completion before transaction start', () {
      expect(
        () => FinancialTransactionCommitted<void>(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          value: null,
          startedAt: DateTime.utc(2026, 7, 17, 20),
          completedAt: DateTime.utc(2026, 7, 17, 19),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('committed result should preserve generic action value', () {
      final result = FinancialTransactionCommitted<int>(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        value: 125000,
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
      );

      expect(result.value, 125000);
      expect(result.value, isA<int>());
    });

    test('failed transaction may exist without an original action error', () {
      final error = StateError('Commit failed after successful action.');

      final result = FinancialTransactionFailed<String>(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        error: error,
        stackTrace: StackTrace.current,
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
      );

      expect(result.originalError, isNull);
      expect(result.originalStackTrace, isNull);
      expect(result.error, same(error));
    });
  });
}
