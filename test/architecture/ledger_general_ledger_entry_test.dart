import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_entry.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_general_ledger_entry.dart';

void main() {
  group('LedgerGeneralLedgerEntry', () {
    late DateTime occurredAt;
    late DateTime createdAt;

    setUp(() {
      occurredAt = DateTime.utc(2026, 7, 15, 10);
      createdAt = DateTime.utc(2026, 7, 15, 10, 1);
    });

    test('creates a debit general-ledger entry', () {
      final entry = LedgerGeneralLedgerEntry(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'finalize.consultation.settlement',
        entryId: 'entry_001',
        accountId: 'platform_cash_XOF',
        currency: ' xof ',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        runningBalanceMinor: 10000,
        occurredAt: occurredAt,
        createdAt: createdAt,
        description: 'Consultation settlement',
      );

      expect(entry.journalId, 'journal_001');
      expect(entry.operationId, 'operation_001');
      expect(entry.currency, 'XOF');
      expect(entry.amountMinor, 10000);
      expect(entry.runningBalanceMinor, 10000);

      expect(entry.isDebit, isTrue);
      expect(entry.isCredit, isFalse);
      expect(entry.debitMinor, 10000);
      expect(entry.creditMinor, 0);
    });

    test('creates a credit general-ledger entry', () {
      final entry = LedgerGeneralLedgerEntry(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'finalize.consultation.settlement',
        entryId: 'entry_002',
        accountId: 'platform_revenue_XOF',
        currency: 'XOF',
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: 1500,
        runningBalanceMinor: 1500,
        occurredAt: occurredAt,
        createdAt: createdAt,
        description: 'Platform revenue',
      );

      expect(entry.isDebit, isFalse);
      expect(entry.isCredit, isTrue);
      expect(entry.debitMinor, 0);
      expect(entry.creditMinor, 1500);
    });

    test('normalizes textual values and dates', () {
      final localOccurredAt = DateTime(2026, 7, 15, 10);

      final entry = LedgerGeneralLedgerEntry(
        journalId: ' journal_001 ',
        operationId: ' operation_001 ',
        workflowKey: ' wallet.deposit ',
        entryId: ' entry_001 ',
        accountId: ' platform_cash_USD ',
        currency: ' usd ',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 500,
        runningBalanceMinor: 500,
        occurredAt: localOccurredAt,
        createdAt: localOccurredAt,
        description: ' Deposit ',
      );

      expect(entry.journalId, 'journal_001');
      expect(entry.operationId, 'operation_001');
      expect(entry.workflowKey, 'wallet.deposit');
      expect(entry.entryId, 'entry_001');
      expect(entry.accountId, 'platform_cash_USD');
      expect(entry.currency, 'USD');
      expect(entry.description, 'Deposit');
      expect(entry.occurredAt.isUtc, isTrue);
      expect(entry.createdAt.isUtc, isTrue);
    });

    test('supports immutable copies', () {
      final original = LedgerGeneralLedgerEntry(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'wallet.deposit',
        entryId: 'entry_001',
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 1000,
        runningBalanceMinor: 1000,
        occurredAt: occurredAt,
        createdAt: createdAt,
        description: 'Deposit',
      );

      final updated = original.copyWith(
        runningBalanceMinor: 1500,
        description: 'Updated deposit',
      );

      expect(original.runningBalanceMinor, 1000);
      expect(original.description, 'Deposit');

      expect(updated.runningBalanceMinor, 1500);
      expect(updated.description, 'Updated deposit');
    });

    test('supports value equality', () {
      final first = LedgerGeneralLedgerEntry(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'wallet.deposit',
        entryId: 'entry_001',
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 1000,
        runningBalanceMinor: 1000,
        occurredAt: occurredAt,
        createdAt: createdAt,
        description: 'Deposit',
      );

      final second = LedgerGeneralLedgerEntry(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'wallet.deposit',
        entryId: 'entry_001',
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 1000,
        runningBalanceMinor: 1000,
        occurredAt: occurredAt,
        createdAt: createdAt,
        description: 'Deposit',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('converts to map', () {
      final entry = LedgerGeneralLedgerEntry(
        journalId: 'journal_001',
        operationId: 'operation_001',
        workflowKey: 'wallet.deposit',
        entryId: 'entry_001',
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 1000,
        runningBalanceMinor: 1000,
        occurredAt: occurredAt,
        createdAt: createdAt,
        description: 'Deposit',
      );

      final map = entry.toMap();

      expect(map['journalId'], 'journal_001');
      expect(map['entryId'], 'entry_001');
      expect(map['direction'], 'debit');
      expect(map['debitMinor'], 1000);
      expect(map['creditMinor'], 0);
      expect(map['runningBalanceMinor'], 1000);
    });

    test('rejects a zero amount', () {
      expect(
        () => LedgerGeneralLedgerEntry(
          journalId: 'journal_001',
          operationId: 'operation_001',
          workflowKey: 'wallet.deposit',
          entryId: 'entry_001',
          accountId: 'platform_cash_XOF',
          currency: 'XOF',
          direction: LedgerJournalEntryDirection.debit,
          amountMinor: 0,
          runningBalanceMinor: 0,
          occurredAt: occurredAt,
          createdAt: createdAt,
          description: 'Deposit',
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty identifiers', () {
      expect(
        () => LedgerGeneralLedgerEntry(
          journalId: '   ',
          operationId: 'operation_001',
          workflowKey: 'wallet.deposit',
          entryId: 'entry_001',
          accountId: 'platform_cash_XOF',
          currency: 'XOF',
          direction: LedgerJournalEntryDirection.debit,
          amountMinor: 1000,
          runningBalanceMinor: 1000,
          occurredAt: occurredAt,
          createdAt: createdAt,
          description: 'Deposit',
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty currency', () {
      expect(
        () => LedgerGeneralLedgerEntry(
          journalId: 'journal_001',
          operationId: 'operation_001',
          workflowKey: 'wallet.deposit',
          entryId: 'entry_001',
          accountId: 'platform_cash_XOF',
          currency: '   ',
          direction: LedgerJournalEntryDirection.debit,
          amountMinor: 1000,
          runningBalanceMinor: 1000,
          occurredAt: occurredAt,
          createdAt: createdAt,
          description: 'Deposit',
        ),
        throwsArgumentError,
      );
    });
  });
}
