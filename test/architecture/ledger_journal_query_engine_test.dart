import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/queries/'
    'queries.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';

void main() {
  group('LedgerJournalQueryEngine', () {
    late MemoryLedgerJournalRepository repository;
    late LedgerJournalQueryEngine engine;

    setUp(() async {
      repository = MemoryLedgerJournalRepository();

      engine = LedgerJournalQueryEngine(repository: repository);

      await repository.create(
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          workflowKey: 'finalize.consultation.settlement',
          sourceType: 'consultation',
          sourceId: 'consultation_001',
          status: LedgerJournalStatus.posted,
          currency: 'XOF',
          amountMinor: 10000,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          debitAccountId: 'escrow_001_XOF',
          creditAccountId: 'expert_wallet_001_XOF',
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_002',
          operationId: 'operation_002',
          workflowKey: 'wallet.deposit',
          sourceType: 'wallet',
          sourceId: 'wallet_001',
          status: LedgerJournalStatus.pending,
          currency: 'USD',
          amountMinor: 25000,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          debitAccountId: 'clearing_USD',
          creditAccountId: 'wallet_001_USD',
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_001_reversal',
          operationId: 'operation_001_reversal',
          workflowKey: 'finalize.consultation.settlement.reversal',
          sourceType: 'ledger_reversal',
          sourceId: 'journal_001',
          status: LedgerJournalStatus.posted,
          currency: 'XOF',
          amountMinor: 10000,
          occurredAt: DateTime.utc(2026, 7, 15, 12),
          debitAccountId: 'expert_wallet_001_XOF',
          creditAccountId: 'escrow_001_XOF',
          metadata: const {'reversalOfJournalId': 'journal_001'},
        ),
      );
    });

    test('returns every journal by default', () async {
      final result = await engine.execute(LedgerJournalQuery());

      expect(result.totalCount, 3);
      expect(result.returnedCount, 3);
      expect(result.hasMore, isFalse);

      expect(result.journals.first.journalId, 'journal_001_reversal');
    });

    test('filters by journal ID', () async {
      final result = await engine.execute(
        LedgerJournalQuery(journalId: 'journal_002'),
      );

      expect(result.totalCount, 1);
      expect(result.singleOrNull?.operationId, 'operation_002');
    });

    test('filters by operation ID', () async {
      final result = await engine.execute(
        LedgerJournalQuery(operationId: 'operation_001'),
      );

      expect(result.totalCount, 1);
      expect(result.singleOrNull?.journalId, 'journal_001');
    });

    test('filters by workflow key', () async {
      final result = await engine.execute(
        LedgerJournalQuery(workflowKey: ' WALLET.DEPOSIT '),
      );

      expect(result.totalCount, 1);
      expect(result.singleOrNull?.journalId, 'journal_002');
    });

    test('filters by source', () async {
      final result = await engine.execute(
        LedgerJournalQuery(
          sourceType: ' consultation ',
          sourceId: ' consultation_001 ',
        ),
      );

      expect(result.totalCount, 1);
      expect(result.singleOrNull?.journalId, 'journal_001');
    });

    test('filters by status', () async {
      final result = await engine.execute(
        LedgerJournalQuery(status: LedgerJournalStatus.pending),
      );

      expect(result.totalCount, 1);
      expect(result.singleOrNull?.journalId, 'journal_002');
    });

    test('filters by currency', () async {
      final result = await engine.execute(
        LedgerJournalQuery(currency: ' xof '),
      );

      expect(result.totalCount, 2);
    });

    test('filters by account ID', () async {
      final result = await engine.execute(
        LedgerJournalQuery(accountId: 'escrow_001_XOF'),
      );

      expect(result.totalCount, 2);
    });

    test('filters by occurrence interval', () async {
      final result = await engine.execute(
        LedgerJournalQuery(
          occurredFrom: DateTime.utc(2026, 7, 15, 10),
          occurredTo: DateTime.utc(2026, 7, 15, 12),
        ),
      );

      expect(result.totalCount, 2);

      expect(
        result.journals.map((journal) => journal.journalId),
        containsAll(['journal_001', 'journal_002']),
      );
    });

    test('filters by amount interval', () async {
      final result = await engine.execute(
        LedgerJournalQuery(
          minimumAmountMinor: 20000,
          maximumAmountMinor: 30000,
        ),
      );

      expect(result.totalCount, 1);
      expect(result.singleOrNull?.journalId, 'journal_002');
    });

    test('returns reversal journals only', () async {
      final result = await engine.execute(
        LedgerJournalQuery(reversalsOnly: true),
      );

      expect(result.totalCount, 1);

      expect(result.singleOrNull?.journalId, 'journal_001_reversal');
    });

    test('finds a reversal by original journal ID', () async {
      final result = await engine.execute(
        LedgerJournalQuery(reversalOfJournalId: 'journal_001'),
      );

      expect(result.totalCount, 1);

      expect(result.singleOrNull?.journalId, 'journal_001_reversal');
    });

    test('combines filters using AND semantics', () async {
      final result = await engine.execute(
        LedgerJournalQuery(
          status: LedgerJournalStatus.posted,
          currency: 'XOF',
          accountId: 'escrow_001_XOF',
          reversalsOnly: true,
        ),
      );

      expect(result.totalCount, 1);

      expect(result.singleOrNull?.journalId, 'journal_001_reversal');
    });

    test('sorts journals in ascending order', () async {
      final result = await engine.execute(
        LedgerJournalQuery(
          sortOrder: LedgerJournalSortOrder.occurredAtAscending,
        ),
      );

      expect(result.journals.map((journal) => journal.journalId).toList(), [
        'journal_001',
        'journal_002',
        'journal_001_reversal',
      ]);
    });

    test('supports immutable pagination', () async {
      final firstPage = await engine.execute(
        LedgerJournalQuery(
          sortOrder: LedgerJournalSortOrder.occurredAtAscending,
          offset: 0,
          limit: 2,
        ),
      );

      expect(firstPage.totalCount, 3);
      expect(firstPage.returnedCount, 2);
      expect(firstPage.hasMore, isTrue);
      expect(firstPage.nextOffset, 2);

      final secondPage = await engine.execute(
        LedgerJournalQuery(
          sortOrder: LedgerJournalSortOrder.occurredAtAscending,
          offset: firstPage.nextOffset!,
          limit: 2,
        ),
      );

      expect(secondPage.returnedCount, 1);
      expect(secondPage.hasMore, isFalse);
      expect(secondPage.nextOffset, isNull);

      expect(() => firstPage.journals.clear(), throwsUnsupportedError);
    });

    test('returns an empty page for an excessive offset', () async {
      final result = await engine.execute(LedgerJournalQuery(offset: 100));

      expect(result.totalCount, 3);
      expect(result.journals, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('rejects an invalid date interval', () {
      expect(
        () => LedgerJournalQuery(
          occurredFrom: DateTime.utc(2026, 7, 15, 12),
          occurredTo: DateTime.utc(2026, 7, 15, 10),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an invalid amount interval', () {
      expect(
        () => LedgerJournalQuery(
          minimumAmountMinor: 20000,
          maximumAmountMinor: 10000,
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid pagination values', () {
      expect(() => LedgerJournalQuery(offset: -1), throwsArgumentError);

      expect(() => LedgerJournalQuery(limit: 0), throwsArgumentError);

      expect(() => LedgerJournalQuery(limit: 501), throwsArgumentError);
    });
  });
}

LedgerJournal _journal({
  required String journalId,
  required String operationId,
  required String workflowKey,
  required String sourceType,
  required String sourceId,
  required LedgerJournalStatus status,
  required String currency,
  required int amountMinor,
  required DateTime occurredAt,
  required String debitAccountId,
  required String creditAccountId,
  Map<String, dynamic> metadata = const {},
}) {
  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: workflowKey,
    source: LedgerJournalSource(type: sourceType, id: sourceId),
    status: status,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    entries: [
      LedgerJournalEntry(
        entryId: '${journalId}_debit',
        accountId: debitAccountId,
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: amountMinor,
        currency: currency,
        description: 'Debit entry',
      ),
      LedgerJournalEntry(
        entryId: '${journalId}_credit',
        accountId: creditAccountId,
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: amountMinor,
        currency: currency,
        description: 'Credit entry',
      ),
    ],
    metadata: metadata,
  );
}
