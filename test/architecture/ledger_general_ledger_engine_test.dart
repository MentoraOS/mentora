import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/journal/models/models.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_general_ledger_engine.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';
import 'package:mentora/core/financial/ledger/models/ledger_account_type.dart';

void main() {
  group('LedgerGeneralLedgerEngine', () {
    late MemoryLedgerJournalRepository repository;
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;
    late LedgerGeneralLedgerEngine engine;

    setUp(() {
      repository = MemoryLedgerJournalRepository();

      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');

      chartOfAccounts.ensureExpertWallet(
        expertId: 'expert_001',
        currency: 'XOF',
      );

      engine = LedgerGeneralLedgerEngine(
        repository: repository,
        chartOfAccounts: chartOfAccounts,
      );
    });

    test('builds an empty general ledger', () async {
      final ledger = await engine.generate(accountId: 'platform_cash_XOF');

      expect(ledger.accountId, 'platform_cash_XOF');
      expect(ledger.currency, 'XOF');

      expect(ledger.entries, isEmpty);
      expect(ledger.entryCount, 0);

      expect(ledger.openingBalanceMinor, 0);
      expect(ledger.closingBalanceMinor, 0);

      expect(ledger.totalDebitMinor, 0);
      expect(ledger.totalCreditMinor, 0);

      expect(ledger.movementMinor, 0);
      expect(ledger.isConsistent, isTrue);
    });

    test('generates a general ledger for an asset account', () async {
      await repository.create(
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'cash_debit_001',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
            ),
            _entry(
              entryId: 'clearing_credit_001',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(accountId: 'platform_cash_XOF');

      expect(ledger.entryCount, 1);
      expect(ledger.totalDebitMinor, 10000);
      expect(ledger.totalCreditMinor, 0);

      expect(ledger.openingBalanceMinor, 0);
      expect(ledger.closingBalanceMinor, 10000);
      expect(ledger.movementMinor, 10000);

      expect(ledger.entries.single.runningBalanceMinor, 10000);

      expect(ledger.isConsistent, isTrue);
    });

    test('calculates asset running balances chronologically', () async {
      await repository.create(
        _journal(
          journalId: 'journal_deposit',
          operationId: 'operation_deposit',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'cash_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
            ),
            _entry(
              entryId: 'clearing_credit',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
            ),
          ],
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_withdrawal',
          operationId: 'operation_withdrawal',
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: [
            _entry(
              entryId: 'clearing_debit',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 3000,
            ),
            _entry(
              entryId: 'cash_credit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 3000,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(accountId: 'platform_cash_XOF');

      expect(ledger.entryCount, 2);

      expect(ledger.entries[0].entryId, 'cash_debit');

      expect(ledger.entries[0].runningBalanceMinor, 10000);

      expect(ledger.entries[1].entryId, 'cash_credit');

      expect(ledger.entries[1].runningBalanceMinor, 7000);

      expect(ledger.totalDebitMinor, 10000);
      expect(ledger.totalCreditMinor, 3000);
      expect(ledger.closingBalanceMinor, 7000);
      expect(ledger.isConsistent, isTrue);
    });

    test('generates a general ledger for a liability account', () async {
      await repository.create(
        _journal(
          journalId: 'journal_expert_payment',
          operationId: 'operation_expert_payment',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'cash_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 8000,
            ),
            _entry(
              entryId: 'expert_wallet_credit',
              accountId: 'expert_wallet_expert_001_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 8000,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(
        accountId: 'expert_wallet_expert_001_XOF',
      );

      expect(ledger.entryCount, 1);
      expect(ledger.totalDebitMinor, 0);
      expect(ledger.totalCreditMinor, 8000);

      // Liability normal balance = credit - debit.
      expect(ledger.closingBalanceMinor, 8000);

      expect(ledger.entries.single.runningBalanceMinor, 8000);

      expect(ledger.isConsistent, isTrue);
    });

    test('calculates liability debit movements correctly', () async {
      await repository.create(
        _journal(
          journalId: 'journal_credit_wallet',
          operationId: 'operation_credit_wallet',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'cash_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
            ),
            _entry(
              entryId: 'wallet_credit',
              accountId: 'expert_wallet_expert_001_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
            ),
          ],
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_debit_wallet',
          operationId: 'operation_debit_wallet',
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: [
            _entry(
              entryId: 'wallet_debit',
              accountId: 'expert_wallet_expert_001_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 2500,
            ),
            _entry(
              entryId: 'cash_credit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 2500,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(
        accountId: 'expert_wallet_expert_001_XOF',
      );

      expect(ledger.entries[0].runningBalanceMinor, 10000);

      expect(ledger.entries[1].runningBalanceMinor, 7500);

      expect(ledger.totalDebitMinor, 2500);
      expect(ledger.totalCreditMinor, 10000);
      expect(ledger.closingBalanceMinor, 7500);
    });

    test('generates a general ledger for a revenue account', () async {
      await repository.create(
        _journal(
          journalId: 'journal_revenue',
          operationId: 'operation_revenue',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'cash_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 1500,
            ),
            _entry(
              entryId: 'revenue_credit',
              accountId: 'platform_revenue_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 1500,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(accountId: 'platform_revenue_XOF');

      expect(ledger.totalDebitMinor, 0);
      expect(ledger.totalCreditMinor, 1500);

      // Revenue normal balance = credit - debit.
      expect(ledger.closingBalanceMinor, 1500);

      expect(ledger.entries.single.runningBalanceMinor, 1500);
    });

    test('supports an opening balance', () async {
      await repository.create(
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'cash_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 5000,
            ),
            _entry(
              entryId: 'clearing_credit',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 5000,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(
        accountId: 'platform_cash_XOF',
        openingBalanceMinor: 20000,
      );

      expect(ledger.openingBalanceMinor, 20000);
      expect(ledger.movementMinor, 5000);
      expect(ledger.closingBalanceMinor, 25000);

      expect(ledger.entries.single.runningBalanceMinor, 25000);

      expect(ledger.isConsistent, isTrue);
    });

    test('sorts entries deterministically', () async {
      await repository.create(
        _journal(
          journalId: 'journal_later',
          operationId: 'operation_later',
          occurredAt: DateTime.utc(2026, 7, 15, 12),
          entries: [
            _entry(
              entryId: 'cash_debit_later',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 2000,
            ),
            _entry(
              entryId: 'clearing_credit_later',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 2000,
            ),
          ],
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_earlier',
          operationId: 'operation_earlier',
          occurredAt: DateTime.utc(2026, 7, 15, 9),
          entries: [
            _entry(
              entryId: 'cash_debit_earlier',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 1000,
            ),
            _entry(
              entryId: 'clearing_credit_earlier',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 1000,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(accountId: 'platform_cash_XOF');

      expect(ledger.entries.map((entry) => entry.entryId).toList(), [
        'cash_debit_earlier',
        'cash_debit_later',
      ]);

      expect(ledger.entries[0].runningBalanceMinor, 1000);

      expect(ledger.entries[1].runningBalanceMinor, 3000);
    });

    test('excludes pending and cancelled journals', () async {
      await repository.create(
        _journal(
          journalId: 'journal_posted',
          operationId: 'operation_posted',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: _cashEntries(prefix: 'posted', amountMinor: 1000),
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_pending',
          operationId: 'operation_pending',
          status: LedgerJournalStatus.pending,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: _cashEntries(prefix: 'pending', amountMinor: 2000),
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_cancelled',
          operationId: 'operation_cancelled',
          status: LedgerJournalStatus.cancelled,
          occurredAt: DateTime.utc(2026, 7, 15, 12),
          entries: _cashEntries(prefix: 'cancelled', amountMinor: 3000),
        ),
      );

      final ledger = await engine.generate(accountId: 'platform_cash_XOF');

      expect(ledger.entryCount, 1);
      expect(ledger.totalDebitMinor, 1000);
      expect(ledger.closingBalanceMinor, 1000);

      expect(ledger.entries.single.entryId, 'posted_cash_debit');
    });

    test('includes reversed journals in accounting history', () async {
      await repository.create(
        _journal(
          journalId: 'journal_original',
          operationId: 'operation_original',
          status: LedgerJournalStatus.reversed,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            _entry(
              entryId: 'original_cash_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 5000,
            ),
            _entry(
              entryId: 'original_clearing_credit',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 5000,
            ),
          ],
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_reversal',
          operationId: 'operation_reversal',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: [
            _entry(
              entryId: 'reversal_clearing_debit',
              accountId: 'platform_clearing_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 5000,
            ),
            _entry(
              entryId: 'reversal_cash_credit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 5000,
            ),
          ],
        ),
      );

      final ledger = await engine.generate(accountId: 'platform_cash_XOF');

      expect(ledger.entryCount, 2);

      expect(ledger.entries[0].runningBalanceMinor, 5000);

      expect(ledger.entries[1].runningBalanceMinor, 0);

      expect(ledger.totalDebitMinor, 5000);
      expect(ledger.totalCreditMinor, 5000);
      expect(ledger.closingBalanceMinor, 0);
      expect(ledger.isConsistent, isTrue);
    });

    test('rejects an entry using the wrong currency', () {
      final journal = _journal(
        journalId: 'journal_usd',
        operationId: 'operation_usd',
        occurredAt: DateTime.utc(2026, 7, 15, 10),
        entries: [
          _entry(
            entryId: 'cash_usd_debit',
            accountId: 'platform_cash_XOF',
            direction: LedgerJournalEntryDirection.debit,
            amountMinor: 1000,
            currency: 'USD',
          ),
          _entry(
            entryId: 'clearing_usd_credit',
            accountId: 'platform_clearing_XOF',
            direction: LedgerJournalEntryDirection.credit,
            amountMinor: 1000,
            currency: 'USD',
          ),
        ],
      );

      expect(
        () => engine.buildFromJournals(
          accountId: 'platform_cash_XOF',
          accountCurrency: 'XOF',
          accountType: LedgerAccountType.asset,
          journals: [journal],
        ),
        throwsStateError,
      );
    });

    test('rejects an unknown account', () async {
      await expectLater(
        () => engine.generate(accountId: 'missing_account_XOF'),
        throwsStateError,
      );
    });

    test('rejects an empty account identifier', () async {
      await expectLater(
        () => engine.generate(accountId: '   '),
        throwsArgumentError,
      );
    });

    test('remains deterministic for the same journals', () {
      final journals = [
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: _cashEntries(prefix: 'first', amountMinor: 4000),
        ),
        _journal(
          journalId: 'journal_002',
          operationId: 'operation_002',
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: _cashEntries(prefix: 'second', amountMinor: 6000),
        ),
      ];

      final first = engine.buildFromJournals(
        accountId: 'platform_cash_XOF',
        accountCurrency: 'XOF',
        accountType: LedgerAccountType.asset,
        journals: journals,
      );

      final second = engine.buildFromJournals(
        accountId: 'platform_cash_XOF',
        accountCurrency: 'XOF',
        accountType: LedgerAccountType.asset,
        journals: journals,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);

      expect(first.closingBalanceMinor, 10000);
      expect(first.isConsistent, isTrue);
    });
  });
}

LedgerJournal _journal({
  required String journalId,
  required String operationId,
  required DateTime occurredAt,
  required List<LedgerJournalEntry> entries,
  LedgerJournalStatus status = LedgerJournalStatus.posted,
  String workflowKey = 'test.general.ledger',
}) {
  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: workflowKey,
    source: LedgerJournalSource(type: 'architecture_test', id: journalId),
    status: status,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    entries: entries,
  );
}

LedgerJournalEntry _entry({
  required String entryId,
  required String accountId,
  required LedgerJournalEntryDirection direction,
  required int amountMinor,
  String currency = 'XOF',
}) {
  return LedgerJournalEntry(
    entryId: entryId,
    accountId: accountId,
    direction: direction,
    amountMinor: amountMinor,
    currency: currency,
    description: 'General ledger test entry $entryId',
  );
}

List<LedgerJournalEntry> _cashEntries({
  required String prefix,
  required int amountMinor,
}) {
  return [
    _entry(
      entryId: '${prefix}_cash_debit',
      accountId: 'platform_cash_XOF',
      direction: LedgerJournalEntryDirection.debit,
      amountMinor: amountMinor,
    ),
    _entry(
      entryId: '${prefix}_clearing_credit',
      accountId: 'platform_clearing_XOF',
      direction: LedgerJournalEntryDirection.credit,
      amountMinor: amountMinor,
    ),
  ];
}
