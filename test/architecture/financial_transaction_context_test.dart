import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/transaction/context/'
    'financial_transaction_context.dart';
import 'package:mentora/core/financial/transaction/isolation/'
    'financial_transaction_isolation_level.dart';

void main() {
  group('FinancialTransactionContext', () {
    test(
      'should preserve transaction, execution and correlation identities',
      () {
        final context = FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17, 20),
        );

        expect(context.transactionId, 'transaction-001');

        expect(context.executionId, 'execution-001');

        expect(context.correlationId, 'consultation-001');

        expect(context.startedAt, DateTime.utc(2026, 7, 17, 20));

        expect(
          context.isolationLevel,
          FinancialTransactionIsolationLevel.platformDefault,
        );

        expect(context.metadata, isEmpty);
      },
    );

    test('should trim all identifiers', () {
      final context = FinancialTransactionContext(
        transactionId: '  transaction-001  ',
        executionId: '  execution-001  ',
        correlationId: '  consultation-001  ',
        startedAt: DateTime.utc(2026, 7, 17),
      );

      expect(context.transactionId, 'transaction-001');

      expect(context.executionId, 'execution-001');

      expect(context.correlationId, 'consultation-001');
    });

    test('should normalize startedAt to UTC', () {
      final localStartedAt = DateTime(2026, 7, 17, 20, 30);

      final context = FinancialTransactionContext(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        startedAt: localStartedAt,
      );

      expect(context.startedAt.isUtc, isTrue);

      expect(context.startedAt, localStartedAt.toUtc());
    });

    test('should preserve the requested isolation level', () {
      final context = FinancialTransactionContext(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        startedAt: DateTime.utc(2026, 7, 17),
        isolationLevel: FinancialTransactionIsolationLevel.serializable,
      );

      expect(
        context.isolationLevel,
        FinancialTransactionIsolationLevel.serializable,
      );
    });

    test('should expose immutable metadata', () {
      final sourceMetadata = <String, Object?>{
        'workflow': 'finalize-consultation-settlement',
        'provider': 'paydunya',
      };

      final context = FinancialTransactionContext(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        startedAt: DateTime.utc(2026, 7, 17),
        metadata: sourceMetadata,
      );

      sourceMetadata['provider'] = 'modified';

      expect(context.metadata['workflow'], 'finalize-consultation-settlement');

      expect(context.metadata['provider'], 'paydunya');

      expect(
        () => context.metadata['new-key'] = 'value',
        throwsUnsupportedError,
      );
    });

    test('should reject an empty transaction identifier', () {
      expect(
        () => FinancialTransactionContext(
          transactionId: '   ',
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an empty execution identifier', () {
      expect(
        () => FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: '',
          correlationId: 'consultation-001',
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an empty correlation identifier', () {
      expect(
        () => FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: '   ',
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('copyWith should replace only explicitly provided values', () {
      final original = FinancialTransactionContext(
        transactionId: 'transaction-001',
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        startedAt: DateTime.utc(2026, 7, 17),
        isolationLevel: FinancialTransactionIsolationLevel.readCommitted,
        metadata: const {'country': 'ML'},
      );

      final copy = original.copyWith(
        transactionId: 'transaction-002',
        isolationLevel: FinancialTransactionIsolationLevel.serializable,
      );

      expect(copy.transactionId, 'transaction-002');

      expect(copy.executionId, original.executionId);

      expect(copy.correlationId, original.correlationId);

      expect(copy.startedAt, original.startedAt);

      expect(
        copy.isolationLevel,
        FinancialTransactionIsolationLevel.serializable,
      );

      expect(copy.metadata, original.metadata);
    });

    test(
      'two transactions may share one correlation but keep unique identities',
      () {
        final first = FinancialTransactionContext(
          transactionId: 'transaction-001',
          executionId: 'execution-001',
          correlationId: 'consultation-777',
          startedAt: DateTime.utc(2026, 7, 17, 20),
        );

        final second = FinancialTransactionContext(
          transactionId: 'transaction-002',
          executionId: 'execution-002',
          correlationId: 'consultation-777',
          startedAt: DateTime.utc(2026, 7, 17, 20, 5),
        );

        expect(first.transactionId, isNot(second.transactionId));

        expect(first.executionId, isNot(second.executionId));

        expect(first.correlationId, second.correlationId);
      },
    );
  });
}
