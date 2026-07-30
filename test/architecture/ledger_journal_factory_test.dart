import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_entry.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_factory.dart';

import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';

void main() {
  group('LedgerJournalFactory', () {
    const factory = LedgerJournalFactory();

    test('creates a pending journal from a ledger transaction', () {
      final transaction = _transaction();

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'finalize.consultation.settlement',
        source: _source(),
      );

      expect(journal.journalId, 'journal_001');
      expect(journal.operationId, transaction.id);
      expect(journal.workflowKey, 'finalize.consultation.settlement');
      expect(journal.status, LedgerJournalStatus.pending);
      expect(journal.entries, hasLength(2));
      expect(journal.isBalanced, isTrue);
    });

    test('preserves transaction identity as operation identity', () {
      final transaction = _transaction(id: 'posting_operation_123');

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_123',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(journal.operationId, 'posting_operation_123');

      expect(journal.metadata['ledgerTransactionId'], 'posting_operation_123');
    });

    test('preserves ledger entry identifiers', () {
      final transaction = _transaction();

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(journal.entries.map((entry) => entry.entryId).toList(), [
        'ledger_entry_debit',
        'ledger_entry_credit',
      ]);
    });

    test('preserves accounts amounts and currencies', () {
      final transaction = _transaction(amountMinor: 12500, currency: 'USD');

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(journal.entries[0].accountId, 'platform_cash_USD');

      expect(journal.entries[1].accountId, 'client_wallet_client_001_USD');

      expect(journal.entries[0].amountMinor, 12500);

      expect(journal.entries[1].amountMinor, 12500);

      expect(journal.entries.map((entry) => entry.currency).toSet(), {'USD'});
    });

    test('maps debit and credit directions correctly', () {
      final journal = factory.create(
        transaction: _transaction(),
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(journal.entries[0].direction, LedgerJournalEntryDirection.debit);

      expect(journal.entries[1].direction, LedgerJournalEntryDirection.credit);
    });

    test('preserves transaction and custom metadata', () {
      final transaction = _transaction(
        metadata: const {
          'consultationId': 'consultation_001',
          'clientId': 'client_001',
        },
      );

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'finalize.consultation.settlement',
        source: _source(),
        metadata: const {'expertId': 'expert_001', 'bridgeVersion': 1},
      );

      expect(journal.metadata['consultationId'], 'consultation_001');

      expect(journal.metadata['clientId'], 'client_001');

      expect(journal.metadata['expertId'], 'expert_001');

      expect(journal.metadata['bridgeVersion'], 1);

      expect(journal.metadata['ledgerReferenceId'], 'reference_001');

      expect(
        journal.metadata['ledgerTransactionDescription'],
        'Test ledger transaction',
      );

      expect(journal.metadata['journalCreatedBy'], 'ledger_journal_factory');
    });

    test('allows explicit metadata to override transaction metadata', () {
      final transaction = _transaction(metadata: const {'channel': 'mobile'});

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
        metadata: const {'channel': 'admin'},
      );

      expect(journal.metadata['channel'], 'admin');
    });

    test('preserves the transaction description on every journal entry', () {
      final journal = factory.create(
        transaction: _transaction(
          description: 'Consultation settlement posting',
        ),
        journalId: 'journal_001',
        workflowKey: 'finalize.consultation.settlement',
        source: _source(),
      );

      expect(
        journal.entries.every(
          (entry) => entry.description == 'Consultation settlement posting',
        ),
        isTrue,
      );
    });

    test('links every journal entry to the ledger transaction', () {
      final journal = factory.create(
        transaction: _transaction(),
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      for (final entry in journal.entries) {
        expect(entry.metadata['ledgerTransactionId'], 'transaction_001');

        expect(entry.metadata['ledgerReferenceId'], 'reference_001');

        expect(entry.metadata['ledgerEntryId'], entry.entryId);
      }
    });

    test('uses transaction createdAt as default journal dates', () {
      final createdAt = DateTime.utc(2026, 7, 15, 10);

      final journal = factory.create(
        transaction: _transaction(createdAt: createdAt),
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(journal.occurredAt, createdAt);
      expect(journal.createdAt, createdAt);
      expect(journal.occurredAt.isUtc, isTrue);
      expect(journal.createdAt.isUtc, isTrue);
    });

    test('normalizes explicit journal dates to UTC', () {
      final occurredAt = DateTime(2026, 7, 15, 10);

      final createdAt = DateTime(2026, 7, 15, 11);

      final journal = factory.create(
        transaction: _transaction(),
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
        occurredAt: occurredAt,
        createdAt: createdAt,
      );

      expect(journal.occurredAt.isUtc, isTrue);
      expect(journal.createdAt.isUtc, isTrue);
    });

    test('rejects createdAt before occurredAt', () {
      expect(
        () => factory.create(
          transaction: _transaction(),
          journalId: 'journal_001',
          workflowKey: 'wallet.deposit',
          source: _source(),
          occurredAt: DateTime.utc(2026, 7, 15, 12),
          createdAt: DateTime.utc(2026, 7, 15, 11),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty journal identifier', () {
      expect(
        () => factory.create(
          transaction: _transaction(),
          journalId: '   ',
          workflowKey: 'wallet.deposit',
          source: _source(),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty workflow key', () {
      expect(
        () => factory.create(
          transaction: _transaction(),
          journalId: 'journal_001',
          workflowKey: '   ',
          source: _source(),
        ),
        throwsArgumentError,
      );
    });

    test('normalizes journal identifier and workflow key', () {
      final journal = factory.create(
        transaction: _transaction(),
        journalId: ' journal_001 ',
        workflowKey: ' wallet.deposit ',
        source: _source(),
      );

      expect(journal.journalId, 'journal_001');
      expect(journal.workflowKey, 'wallet.deposit');
    });

    test('preserves accounting totals exactly', () {
      final transaction = _transaction(amountMinor: 250000);

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(journal.debitAmountMinor, transaction.totalDebits);

      expect(journal.creditAmountMinor, transaction.totalCredits);

      expect(journal.debitAmountMinor, 250000);
      expect(journal.creditAmountMinor, 250000);
      expect(journal.isBalanced, isTrue);
    });

    test('remains deterministic for the same input', () {
      final transaction = _transaction();
      final source = _source();
      final occurredAt = DateTime.utc(2026, 7, 15, 10);
      final createdAt = DateTime.utc(2026, 7, 15, 11);

      final first = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: source,
        occurredAt: occurredAt,
        createdAt: createdAt,
        metadata: const {'key': 'value'},
      );

      final second = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: source,
        occurredAt: occurredAt,
        createdAt: createdAt,
        metadata: const {'key': 'value'},
      );

      expect(first.journalId, second.journalId);
      expect(first.operationId, second.operationId);
      expect(first.workflowKey, second.workflowKey);
      expect(first.status, second.status);
      expect(first.occurredAt, second.occurredAt);
      expect(first.createdAt, second.createdAt);
      expect(first.metadata, second.metadata);

      expect(
        first.entries.map((entry) => entry.entryId).toList(),
        second.entries.map((entry) => entry.entryId).toList(),
      );

      expect(
        first.entries.map((entry) => entry.direction).toList(),
        second.entries.map((entry) => entry.direction).toList(),
      );
    });

    test('creates immutable journal metadata', () {
      final transactionMetadata = <String, dynamic>{'mutable': 'before'};

      final customMetadata = <String, dynamic>{'custom': 'before'};

      final transaction = _transaction(metadata: transactionMetadata);

      final journal = factory.create(
        transaction: transaction,
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
        metadata: customMetadata,
      );

      transactionMetadata['mutable'] = 'after';
      customMetadata['custom'] = 'after';

      expect(journal.metadata['mutable'], 'before');

      expect(journal.metadata['custom'], 'before');

      expect(() => journal.metadata['new'] = 'value', throwsUnsupportedError);
    });

    test('creates immutable journal entry metadata', () {
      final journal = factory.create(
        transaction: _transaction(),
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(
        () => journal.entries.first.metadata['new'] = 'value',
        throwsUnsupportedError,
      );
    });

    test('creates an immutable journal entry collection', () {
      final journal = factory.create(
        transaction: _transaction(),
        journalId: 'journal_001',
        workflowKey: 'wallet.deposit',
        source: _source(),
      );

      expect(() => journal.entries.clear(), throwsUnsupportedError);
    });
  });
}

LedgerTransaction _transaction({
  String id = 'transaction_001',
  String referenceId = 'reference_001',
  String description = 'Test ledger transaction',
  String currency = 'XOF',
  int amountMinor = 10000,
  DateTime? createdAt,
  Map<String, dynamic> metadata = const {},
}) {
  final transactionCreatedAt = createdAt ?? DateTime.utc(2026, 7, 15, 10);

  return LedgerTransaction(
    id: id,
    referenceId: referenceId,
    description: description,
    currency: currency,
    status: LedgerTransactionStatus.posted,
    createdAt: transactionCreatedAt,
    metadata: metadata,
    entries: [
      LedgerEntry(
        id: 'ledger_entry_debit',
        transactionId: id,
        accountId: 'platform_cash_${currency.toUpperCase()}',
        amountMinor: amountMinor,
        currency: currency.toUpperCase(),
        side: LedgerEntrySide.debit,
        createdAt: transactionCreatedAt,
      ),
      LedgerEntry(
        id: 'ledger_entry_credit',
        transactionId: id,
        accountId:
            'client_wallet_client_001_'
            '${currency.toUpperCase()}',
        amountMinor: amountMinor,
        currency: currency.toUpperCase(),
        side: LedgerEntrySide.credit,
        createdAt: transactionCreatedAt,
      ),
    ],
  );
}

LedgerJournalSource _source() {
  return LedgerJournalSource(type: 'posting', id: 'reference_001');
}
