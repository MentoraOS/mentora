import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';

void main() {
  group('LedgerJournalSource', () {
    test('normalizes source type and id', () {
      final source = LedgerJournalSource(
        type: ' Consultation ',
        id: ' Consultation_001 ',
      );

      expect(source.type, 'consultation');
      expect(source.id, 'consultation_001');
    });

    test('rejects an empty source type', () {
      expect(
        () => LedgerJournalSource(type: ' ', id: 'consultation_001'),
        throwsArgumentError,
      );
    });
  });

  group('LedgerJournalEntry', () {
    test('normalizes currency and preserves amount', () {
      final entry = LedgerJournalEntry(
        entryId: 'entry_001',
        accountId: 'escrow_consultation_001_xof',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        currency: ' xof ',
        description: 'Release escrow',
      );

      expect(entry.currency, 'XOF');
      expect(entry.amountMinor, 10000);
      expect(entry.isDebit, isTrue);
      expect(entry.isCredit, isFalse);
    });

    test('rejects zero and negative amounts', () {
      expect(
        () => LedgerJournalEntry(
          entryId: 'entry_001',
          accountId: 'account_001',
          direction: LedgerJournalEntryDirection.debit,
          amountMinor: 0,
          currency: 'XOF',
          description: 'Invalid entry',
        ),
        throwsArgumentError,
      );
    });

    test('protects metadata from external mutation', () {
      final metadata = <String, dynamic>{'consultationId': 'consultation_001'};

      final entry = LedgerJournalEntry(
        entryId: 'entry_001',
        accountId: 'account_001',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Entry',
        metadata: metadata,
      );

      metadata['consultationId'] = 'changed';

      expect(entry.metadata['consultationId'], 'consultation_001');

      expect(() => entry.metadata['new'] = 'value', throwsUnsupportedError);
    });
  });

  group('LedgerJournal', () {
    test('creates a balanced journal', () {
      final journal = _balancedJournal();

      expect(journal.isBalanced, isTrue);
      expect(journal.debitAmountMinor, 10000);
      expect(journal.creditAmountMinor, 10000);
      expect(journal.currency, 'XOF');
      expect(journal.containsMultipleCurrencies, isFalse);
      expect(journal.entries, hasLength(2));
    });

    test('detects an unbalanced journal', () {
      final journal = LedgerJournal(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'settlement',
        source: LedgerJournalSource(
          type: 'consultation',
          id: 'consultation_001',
        ),
        status: LedgerJournalStatus.pending,
        occurredAt: DateTime.utc(2026, 7, 15, 10),
        createdAt: DateTime.utc(2026, 7, 15, 10, 1),
        entries: [
          LedgerJournalEntry(
            entryId: 'entry_debit',
            accountId: 'escrow_001_xof',
            direction: LedgerJournalEntryDirection.debit,
            amountMinor: 10000,
            currency: 'XOF',
            description: 'Debit escrow',
          ),
          LedgerJournalEntry(
            entryId: 'entry_credit',
            accountId: 'expert_wallet_001_xof',
            direction: LedgerJournalEntryDirection.credit,
            amountMinor: 9000,
            currency: 'XOF',
            description: 'Credit expert',
          ),
        ],
      );

      expect(journal.isBalanced, isFalse);
    });

    test('rejects a journal with fewer than two entries', () {
      expect(
        () => LedgerJournal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          workflowKey: 'settlement',
          source: LedgerJournalSource(
            type: 'consultation',
            id: 'consultation_001',
          ),
          status: LedgerJournalStatus.pending,
          occurredAt: DateTime.utc(2026, 7, 15),
          createdAt: DateTime.utc(2026, 7, 15),
          entries: [
            LedgerJournalEntry(
              entryId: 'entry_001',
              accountId: 'account_001',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'Single entry',
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate entry identifiers', () {
      expect(
        () => LedgerJournal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          workflowKey: 'settlement',
          source: LedgerJournalSource(
            type: 'consultation',
            id: 'consultation_001',
          ),
          status: LedgerJournalStatus.pending,
          occurredAt: DateTime.utc(2026, 7, 15),
          createdAt: DateTime.utc(2026, 7, 15),
          entries: [
            LedgerJournalEntry(
              entryId: 'duplicate',
              accountId: 'account_001',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'Debit',
            ),
            LedgerJournalEntry(
              entryId: 'duplicate',
              accountId: 'account_002',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'Credit',
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('protects entries from mutation', () {
      final entries = _entries();

      final journal = LedgerJournal(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'settlement',
        source: LedgerJournalSource(
          type: 'consultation',
          id: 'consultation_001',
        ),
        status: LedgerJournalStatus.pending,
        occurredAt: DateTime.utc(2026, 7, 15),
        createdAt: DateTime.utc(2026, 7, 15),
        entries: entries,
      );

      entries.clear();

      expect(journal.entries, hasLength(2));

      expect(
        () => journal.entries.add(
          LedgerJournalEntry(
            entryId: 'entry_003',
            accountId: 'account_003',
            direction: LedgerJournalEntryDirection.credit,
            amountMinor: 100,
            currency: 'XOF',
            description: 'Mutation',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('copyWith preserves identity and updates status', () {
      final pending = _balancedJournal();

      final posted = pending.copyWith(
        status: LedgerJournalStatus.posted,
        version: 2,
      );

      expect(posted.journalId, pending.journalId);
      expect(posted.operationId, pending.operationId);
      expect(posted.entries, pending.entries);
      expect(posted.status, LedgerJournalStatus.posted);
      expect(posted.version, 2);
    });
  });
}

LedgerJournal _balancedJournal() {
  return LedgerJournal(
    journalId: 'journal_001',
    operationId: 'operation_001',
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(type: 'consultation', id: 'consultation_001'),
    status: LedgerJournalStatus.pending,
    occurredAt: DateTime.utc(2026, 7, 15, 10),
    createdAt: DateTime.utc(2026, 7, 15, 10, 1),
    entries: _entries(),
    metadata: const {'expertId': 'expert_001', 'clientId': 'client_001'},
  );
}

List<LedgerJournalEntry> _entries() {
  return [
    LedgerJournalEntry(
      entryId: 'entry_debit',
      accountId: 'escrow_consultation_001_xof',
      direction: LedgerJournalEntryDirection.debit,
      amountMinor: 10000,
      currency: 'XOF',
      description: 'Debit escrow',
    ),
    LedgerJournalEntry(
      entryId: 'entry_credit',
      accountId: 'expert_wallet_expert_001_xof',
      direction: LedgerJournalEntryDirection.credit,
      amountMinor: 10000,
      currency: 'XOF',
      description: 'Credit expert wallet',
    ),
  ];
}
