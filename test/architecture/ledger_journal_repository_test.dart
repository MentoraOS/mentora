import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';

void main() {
  group('MemoryLedgerJournalRepository', () {
    late MemoryLedgerJournalRepository repository;

    setUp(() {
      repository = MemoryLedgerJournalRepository();
    });

    test('creates and resolves a journal by ID', () async {
      final journal = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
      );

      await repository.create(journal);

      expect(await repository.findById('journal_001'), same(journal));

      expect(await repository.count(), 1);
    });

    test('resolves a journal by operation ID', () async {
      final journal = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
      );

      await repository.create(journal);

      expect(
        await repository.findByOperationId('operation_001'),
        same(journal),
      );

      expect(await repository.existsByOperationId('operation_001'), isTrue);
    });

    test('rejects a duplicate journal ID', () async {
      await repository.create(
        _journal(journalId: 'journal_001', operationId: 'operation_001'),
      );

      await expectLater(
        () => repository.create(
          _journal(journalId: 'journal_001', operationId: 'operation_002'),
        ),
        throwsA(isA<DuplicateLedgerJournalIdException>()),
      );
    });

    test('rejects a duplicate operation ID', () async {
      await repository.create(
        _journal(journalId: 'journal_001', operationId: 'operation_001'),
      );

      await expectLater(
        () => repository.create(
          _journal(journalId: 'journal_002', operationId: 'operation_001'),
        ),
        throwsA(isA<DuplicateLedgerOperationException>()),
      );
    });

    test('updates a journal with optimistic versioning', () async {
      final pending = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
      );

      await repository.create(pending);

      final posted = pending.copyWith(
        status: LedgerJournalStatus.posted,
        version: 2,
      );

      await repository.update(journal: posted, expectedVersion: 1);

      final stored = await repository.findById('journal_001');

      expect(stored?.status, LedgerJournalStatus.posted);
      expect(stored?.version, 2);
    });

    test('rejects an update with a stale version', () async {
      final journal = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
      );

      await repository.create(journal);

      await expectLater(
        () => repository.update(
          journal: journal.copyWith(
            status: LedgerJournalStatus.posted,
            version: 2,
          ),
          expectedVersion: 99,
        ),
        throwsA(isA<LedgerJournalVersionConflictException>()),
      );
    });

    test('rejects updating a missing journal', () async {
      await expectLater(
        () => repository.update(
          journal: _journal(
            journalId: 'missing',
            operationId: 'operation_001',
          ).copyWith(version: 2),
          expectedVersion: 1,
        ),
        throwsA(isA<LedgerJournalNotFoundException>()),
      );
    });

    test('filters journals by status', () async {
      final first = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
      );

      final second = _journal(
        journalId: 'journal_002',
        operationId: 'operation_002',
      ).copyWith(status: LedgerJournalStatus.posted, version: 2);

      await repository.create(first);
      await repository.create(second);

      final posted = await repository.findByStatus(LedgerJournalStatus.posted);

      expect(posted, [second]);
    });

    test('filters journals by workflow key', () async {
      final matching = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'finalize.consultation.settlement',
      );

      final other = _journal(
        journalId: 'journal_002',
        operationId: 'operation_002',
        workflowKey: 'refund',
      );

      await repository.create(matching);
      await repository.create(other);

      final result = await repository.findByWorkflowKey(
        'finalize.consultation.settlement',
      );

      expect(result, [matching]);
    });

    test('filters journals by source', () async {
      final matching = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
        sourceId: 'consultation_001',
      );

      final other = _journal(
        journalId: 'journal_002',
        operationId: 'operation_002',
        sourceId: 'consultation_002',
      );

      await repository.create(matching);
      await repository.create(other);

      final result = await repository.findBySource(
        sourceType: ' CONSULTATION ',
        sourceId: ' CONSULTATION_001 ',
      );

      expect(result, [matching]);
    });

    test('filters journals by occurrence interval', () async {
      final first = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
        occurredAt: DateTime.utc(2026, 7, 15, 10),
      );

      final second = _journal(
        journalId: 'journal_002',
        operationId: 'operation_002',
        occurredAt: DateTime.utc(2026, 7, 15, 11),
      );

      final third = _journal(
        journalId: 'journal_003',
        operationId: 'operation_003',
        occurredAt: DateTime.utc(2026, 7, 15, 12),
      );

      await repository.create(first);
      await repository.create(second);
      await repository.create(third);

      final result = await repository.findOccurredBetween(
        from: DateTime.utc(2026, 7, 15, 10),
        to: DateTime.utc(2026, 7, 15, 12),
      );

      expect(result, [first, second]);
    });

    test('returns immutable sorted query results', () async {
      final later = _journal(
        journalId: 'journal_002',
        operationId: 'operation_002',
        occurredAt: DateTime.utc(2026, 7, 15, 12),
      );

      final earlier = _journal(
        journalId: 'journal_001',
        operationId: 'operation_001',
        occurredAt: DateTime.utc(2026, 7, 15, 10),
      );

      await repository.create(later);
      await repository.create(earlier);

      final result = await repository.findAll();

      expect(result, [earlier, later]);

      expect(() => result.clear(), throwsUnsupportedError);
    });
  });
}

LedgerJournal _journal({
  required String journalId,
  required String operationId,
  String workflowKey = 'finalize.consultation.settlement',
  String sourceId = 'consultation_001',
  DateTime? occurredAt,
}) {
  final eventTime = occurredAt ?? DateTime.utc(2026, 7, 15, 10);

  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: workflowKey,
    source: LedgerJournalSource(type: 'consultation', id: sourceId),
    status: LedgerJournalStatus.pending,
    occurredAt: eventTime,
    createdAt: eventTime.add(const Duration(minutes: 1)),
    entries: [
      LedgerJournalEntry(
        entryId: '${journalId}_debit',
        accountId: 'escrow_consultation_001_xof',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Debit escrow',
      ),
      LedgerJournalEntry(
        entryId: '${journalId}_credit',
        accountId: 'expert_wallet_expert_001_xof',
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Credit expert',
      ),
    ],
  );
}
