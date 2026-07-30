import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/reversal/'
    'reversal.dart';

void main() {
  group('LedgerJournalReversalBuilder', () {
    const builder = LedgerJournalReversalBuilder();

    test('builds a balanced compensating journal', () {
      final original = _postedJournal();

      final result = builder.build(original: original, request: _request());

      final reversal = result.reversalJournal;

      expect(reversal.isBalanced, isTrue);
      expect(reversal.status, LedgerJournalStatus.pending);
      expect(reversal.version, 1);
      expect(reversal.entries, hasLength(2));

      expect(reversal.debitAmountMinor, original.creditAmountMinor);

      expect(reversal.creditAmountMinor, original.debitAmountMinor);
    });

    test('inverts debit and credit directions', () {
      final result = builder.build(
        original: _postedJournal(),
        request: _request(),
      );

      final entries = result.reversalJournal.entries;

      expect(entries[0].direction, LedgerJournalEntryDirection.credit);

      expect(entries[1].direction, LedgerJournalEntryDirection.debit);
    });

    test('preserves accounts amounts and currency', () {
      final original = _postedJournal();

      final reversal = builder
          .build(original: original, request: _request())
          .reversalJournal;

      for (var index = 0; index < original.entries.length; index++) {
        expect(
          reversal.entries[index].accountId,
          original.entries[index].accountId,
        );

        expect(
          reversal.entries[index].amountMinor,
          original.entries[index].amountMinor,
        );

        expect(
          reversal.entries[index].currency,
          original.entries[index].currency,
        );
      }
    });

    test('links the reversal to the original journal', () {
      final original = _postedJournal();

      final reversal = builder
          .build(original: original, request: _request())
          .reversalJournal;

      expect(reversal.source.type, 'ledger_reversal');

      expect(reversal.source.id, original.journalId);

      expect(reversal.metadata['reversalOfJournalId'], original.journalId);

      expect(reversal.metadata['reversalOfOperationId'], original.operationId);

      expect(reversal.metadata['reversalReason'], 'Client refund approved');
    });

    test('links every reversal entry to its source', () {
      final original = _postedJournal();

      final reversal = builder
          .build(original: original, request: _request())
          .reversalJournal;

      for (var index = 0; index < original.entries.length; index++) {
        expect(
          reversal.entries[index].metadata['reversalOfEntryId'],
          original.entries[index].entryId,
        );
      }
    });

    test('remains deterministic for the same input', () {
      final original = _postedJournal();
      final request = _request();

      final first = builder.build(original: original, request: request);

      final second = builder.build(original: original, request: request);

      expect(first.reversalJournal.journalId, second.reversalJournal.journalId);

      expect(
        first.reversalJournal.operationId,
        second.reversalJournal.operationId,
      );

      expect(
        first.reversalJournal.entries.map((entry) => entry.entryId),
        second.reversalJournal.entries.map((entry) => entry.entryId),
      );
    });

    test('rejects reversing a pending journal', () {
      final pending = _postedJournal().copyWith(
        status: LedgerJournalStatus.pending,
      );

      expect(
        () => builder.build(original: pending, request: _request()),
        throwsStateError,
      );
    });

    test('rejects a mismatched original journal ID', () {
      expect(
        () => builder.build(
          original: _postedJournal(),
          request: _request(originalJournalId: 'another_journal'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects reuse of the original operation ID', () {
      expect(
        () => builder.build(
          original: _postedJournal(),
          request: _request(reversalOperationId: 'operation_001'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects identical journal identifiers', () {
      expect(
        () => LedgerJournalReversalRequest(
          originalJournalId: 'journal_001',
          reversalJournalId: 'journal_001',
          reversalOperationId: 'operation_001_reversal',
          reason: 'Refund',
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          createdAt: DateTime.utc(2026, 7, 15, 11, 1),
        ),
        throwsArgumentError,
      );
    });
  });
}

LedgerJournal _postedJournal() {
  final occurredAt = DateTime.utc(2026, 7, 15, 10);

  return LedgerJournal(
    journalId: 'journal_001',
    operationId: 'operation_001',
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(type: 'consultation', id: 'consultation_001'),
    status: LedgerJournalStatus.posted,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    version: 2,
    entries: [
      LedgerJournalEntry(
        entryId: 'entry_debit',
        accountId: 'escrow_consultation_001_XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Debit escrow',
      ),
      LedgerJournalEntry(
        entryId: 'entry_credit',
        accountId: 'expert_wallet_expert_001_XOF',
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Credit expert wallet',
      ),
    ],
    metadata: const {'consultationId': 'consultation_001'},
  );
}

LedgerJournalReversalRequest _request({
  String originalJournalId = 'journal_001',
  String reversalJournalId = 'journal_001_reversal',
  String reversalOperationId = 'operation_001_reversal',
}) {
  return LedgerJournalReversalRequest(
    originalJournalId: originalJournalId,
    reversalJournalId: reversalJournalId,
    reversalOperationId: reversalOperationId,
    reason: 'Client refund approved',
    occurredAt: DateTime.utc(2026, 7, 15, 11),
    createdAt: DateTime.utc(2026, 7, 15, 11, 1),
    metadata: const {'approvedBy': 'admin_001'},
  );
}
