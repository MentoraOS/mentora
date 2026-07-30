import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'ledger_journal_posting_recovery_context.dart';

void main() {
  group('LedgerJournalPostingRecoveryContext', () {
    test('creates a valid recovery context', () {
      final context = _context();

      expect(context.transactionId, 'transaction_001');

      expect(context.operationId, 'transaction_001');

      expect(context.journalId, 'journal_transaction_001');

      expect(context.workflowKey, 'financial.posting.paymentReleased');

      expect(context.source.type, 'financial_posting');

      expect(context.source.id, 'settlement_001');

      expect(context.metadata['tenantId'], 'tenant_001');
    });

    test('trims required identifiers', () {
      final context = LedgerJournalPostingRecoveryContext(
        transactionId: ' transaction_001 ',
        journalId: ' journal_001 ',
        workflowKey: ' financial.posting.paymentReleased ',
        source: _source(),
      );

      expect(context.transactionId, 'transaction_001');

      expect(context.journalId, 'journal_001');

      expect(context.workflowKey, 'financial.posting.paymentReleased');
    });

    test('uses transaction id as operation id', () {
      final context = _context(transactionId: 'transaction_777');

      expect(context.operationId, context.transactionId);

      expect(context.operationId, 'transaction_777');
    });

    test('converts explicit dates to utc', () {
      final localOccurredAt = DateTime(2026, 7, 15, 10, 30);

      final localCreatedAt = DateTime(2026, 7, 15, 10, 31);

      final context = _context(
        occurredAt: localOccurredAt,
        createdAt: localCreatedAt,
      );

      expect(context.occurredAt, isNotNull);
      expect(context.createdAt, isNotNull);

      expect(context.occurredAt!.isUtc, isTrue);

      expect(context.createdAt!.isUtc, isTrue);

      expect(context.occurredAt, localOccurredAt.toUtc());

      expect(context.createdAt, localCreatedAt.toUtc());
    });

    test('supports absent optional dates', () {
      final context = _context(occurredAt: null, createdAt: null);

      expect(context.occurredAt, isNull);
      expect(context.createdAt, isNull);

      expect(context.hasExplicitOccurredAt, isFalse);

      expect(context.hasExplicitCreatedAt, isFalse);
    });

    test('reports explicitly supplied dates', () {
      final context = _context(
        occurredAt: DateTime.utc(2026, 7, 15, 10),
        createdAt: DateTime.utc(2026, 7, 15, 10, 1),
      );

      expect(context.hasExplicitOccurredAt, isTrue);

      expect(context.hasExplicitCreatedAt, isTrue);
    });

    test('allows createdAt equal to occurredAt', () {
      final date = DateTime.utc(2026, 7, 15, 10);

      expect(
        () => _context(occurredAt: date, createdAt: date),
        returnsNormally,
      );
    });

    test('rejects createdAt before occurredAt', () {
      expect(
        () => _context(
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          createdAt: DateTime.utc(2026, 7, 15, 9, 59),
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty transaction id', () {
      expect(() => _context(transactionId: '   '), throwsArgumentError);
    });

    test('rejects empty journal id', () {
      expect(() => _context(journalId: '   '), throwsArgumentError);
    });

    test('rejects empty workflow key', () {
      expect(() => _context(workflowKey: '   '), throwsArgumentError);
    });

    test('creates a defensive immutable metadata copy', () {
      final originalMetadata = <String, dynamic>{'tenantId': 'tenant_001'};

      final context = _context(metadata: originalMetadata);

      originalMetadata['tenantId'] = 'modified_tenant';

      originalMetadata['newField'] = true;

      expect(context.metadata['tenantId'], 'tenant_001');

      expect(context.metadata.containsKey('newField'), isFalse);

      expect(
        () => context.metadata['another'] = 'value',
        throwsUnsupportedError,
      );
    });

    test('copyWith preserves unchanged values', () {
      final original = _context(
        occurredAt: DateTime.utc(2026, 7, 15, 10),
        createdAt: DateTime.utc(2026, 7, 15, 10, 1),
      );

      final copied = original.copyWith(journalId: 'journal_002');

      expect(copied.transactionId, original.transactionId);

      expect(copied.journalId, 'journal_002');

      expect(copied.workflowKey, original.workflowKey);

      expect(copied.source, same(original.source));

      expect(copied.occurredAt, original.occurredAt);

      expect(copied.createdAt, original.createdAt);

      expect(copied.metadata, original.metadata);
    });

    test('copyWith replaces supplied values', () {
      final newSource = LedgerJournalSource(
        type: 'manual_recovery',
        id: 'operator_001',
      );

      final copied = _context().copyWith(
        transactionId: 'transaction_002',
        journalId: 'journal_002',
        workflowKey: 'financial.posting.refund',
        source: newSource,
        occurredAt: DateTime.utc(2026, 7, 16, 10),
        createdAt: DateTime.utc(2026, 7, 16, 10, 1),
        metadata: const {'recoveredBy': 'operator_001'},
      );

      expect(copied.transactionId, 'transaction_002');

      expect(copied.operationId, 'transaction_002');

      expect(copied.journalId, 'journal_002');

      expect(copied.workflowKey, 'financial.posting.refund');

      expect(copied.source, same(newSource));

      expect(copied.metadata['recoveredBy'], 'operator_001');
    });

    test('toString contains diagnostic identifiers', () {
      final value = _context().toString();

      expect(value, contains('transaction_001'));

      expect(value, contains('journal_transaction_001'));

      expect(value, contains('financial.posting.paymentReleased'));
    });
  });
}

LedgerJournalPostingRecoveryContext _context({
  String transactionId = 'transaction_001',
  String journalId = 'journal_transaction_001',
  String workflowKey = 'financial.posting.paymentReleased',
  LedgerJournalSource? source,
  DateTime? occurredAt,
  DateTime? createdAt,
  Map<String, dynamic> metadata = const {'tenantId': 'tenant_001'},
}) {
  return LedgerJournalPostingRecoveryContext(
    transactionId: transactionId,
    journalId: journalId,
    workflowKey: workflowKey,
    source: source ?? _source(),
    occurredAt: occurredAt,
    createdAt: createdAt,
    metadata: metadata,
  );
}

LedgerJournalSource _source() {
  return LedgerJournalSource(type: 'financial_posting', id: 'settlement_001');
}
