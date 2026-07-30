import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_entry.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';

import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_general_ledger_engine.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_journal_reporting_engine.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_journal_summary.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_trial_balance_engine.dart';

import 'package:mentora/core/financial/ledger/journal/repository/'
    'memory_ledger_journal_repository.dart';

void main() {
  group('LedgerJournalReportingEngine', () {
    late MemoryLedgerJournalRepository repository;
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;

    late LedgerTrialBalanceEngine trialBalanceEngine;
    late LedgerGeneralLedgerEngine generalLedgerEngine;
    late LedgerJournalReportingEngine reportingEngine;

    setUp(() {
      repository = MemoryLedgerJournalRepository();

      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');
      chartOfAccounts.initializeCurrency('USD');

      chartOfAccounts.ensureExpertWallet(
        expertId: 'expert_001',
        currency: 'XOF',
      );

      trialBalanceEngine = LedgerTrialBalanceEngine(repository: repository);

      generalLedgerEngine = LedgerGeneralLedgerEngine(
        repository: repository,
        chartOfAccounts: chartOfAccounts,
      );

      reportingEngine = LedgerJournalReportingEngine(
        repository: repository,
        trialBalanceEngine: trialBalanceEngine,
        generalLedgerEngine: generalLedgerEngine,
      );
    });

    group('summary()', () {
      test('returns an empty summary when repository is empty', () async {
        final summary = await reportingEngine.summary();

        expect(summary, LedgerJournalSummary.empty);
        expect(summary.isEmpty, isTrue);
        expect(summary.totalJournals, 0);
      });

      test('counts every journal status', () async {
        await repository.create(
          _journal(
            journalId: 'journal_pending',
            operationId: 'operation_pending',
            status: LedgerJournalStatus.pending,
            occurredAt: DateTime.utc(2026, 7, 15, 9),
            entries: _balancedEntries(
              prefix: 'pending',
              amountMinor: 1000,
              currency: 'XOF',
            ),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_posted',
            operationId: 'operation_posted',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _balancedEntries(
              prefix: 'posted',
              amountMinor: 2000,
              currency: 'XOF',
            ),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_cancelled',
            operationId: 'operation_cancelled',
            status: LedgerJournalStatus.cancelled,
            occurredAt: DateTime.utc(2026, 7, 15, 11),
            entries: _balancedEntries(
              prefix: 'cancelled',
              amountMinor: 3000,
              currency: 'XOF',
            ),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_reversed',
            operationId: 'operation_reversed',
            status: LedgerJournalStatus.reversed,
            occurredAt: DateTime.utc(2026, 7, 15, 12),
            entries: _balancedEntries(
              prefix: 'reversed',
              amountMinor: 4000,
              currency: 'XOF',
            ),
          ),
        );

        final summary = await reportingEngine.summary();

        expect(summary.totalJournals, 4);
        expect(summary.pendingJournals, 1);
        expect(summary.postedJournals, 1);
        expect(summary.cancelledJournals, 1);
        expect(summary.reversedJournals, 1);

        expect(summary.countForStatus(LedgerJournalStatus.posted), 1);

        expect(summary.isNotEmpty, isTrue);
      });

      test('filters journal summary by currency', () async {
        await repository.create(
          _journal(
            journalId: 'journal_xof',
            operationId: 'operation_xof',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _balancedEntries(
              prefix: 'xof',
              amountMinor: 10000,
              currency: 'XOF',
            ),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_usd',
            operationId: 'operation_usd',
            status: LedgerJournalStatus.cancelled,
            occurredAt: DateTime.utc(2026, 7, 15, 11),
            entries: _balancedEntries(
              prefix: 'usd',
              amountMinor: 500,
              currency: 'USD',
            ),
          ),
        );

        final xofSummary = await reportingEngine.summary(currency: ' xof ');

        expect(xofSummary.totalJournals, 1);
        expect(xofSummary.postedJournals, 1);
        expect(xofSummary.cancelledJournals, 0);

        final usdSummary = await reportingEngine.summary(currency: 'usd');

        expect(usdSummary.totalJournals, 1);
        expect(usdSummary.postedJournals, 0);
        expect(usdSummary.cancelledJournals, 1);
      });

      test(
        'returns an empty summary when no journal matches currency',
        () async {
          await repository.create(
            _journal(
              journalId: 'journal_xof',
              operationId: 'operation_xof',
              status: LedgerJournalStatus.posted,
              occurredAt: DateTime.utc(2026, 7, 15, 10),
              entries: _balancedEntries(
                prefix: 'xof',
                amountMinor: 1000,
                currency: 'XOF',
              ),
            ),
          );

          final result = await reportingEngine.summary(currency: 'EUR');

          expect(result, LedgerJournalSummary.empty);
        },
      );

      test('rejects an empty summary currency', () async {
        await expectLater(
          () => reportingEngine.summary(currency: '   '),
          throwsArgumentError,
        );
      });
    });

    group('accountActivity()', () {
      test('aggregates debit and credit activity for one account', () async {
        await repository.create(
          _journal(
            journalId: 'journal_deposit',
            operationId: 'operation_deposit',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: [
              _entry(
                entryId: 'cash_debit',
                accountId: 'platform_cash_XOF',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 10000,
                currency: 'XOF',
              ),
              _entry(
                entryId: 'clearing_credit',
                accountId: 'platform_clearing_XOF',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 10000,
                currency: 'XOF',
              ),
            ],
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_withdrawal',
            operationId: 'operation_withdrawal',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 11),
            entries: [
              _entry(
                entryId: 'clearing_debit',
                accountId: 'platform_clearing_XOF',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 2500,
                currency: 'XOF',
              ),
              _entry(
                entryId: 'cash_credit',
                accountId: 'platform_cash_XOF',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 2500,
                currency: 'XOF',
              ),
            ],
          ),
        );

        final activity = await reportingEngine.accountActivity(
          accountId: 'platform_cash_XOF',
        );

        expect(activity.accountId, 'platform_cash_XOF');

        expect(activity.currency, 'XOF');
        expect(activity.entryCount, 2);
        expect(activity.totalDebitMinor, 10000);
        expect(activity.totalCreditMinor, 2500);
        expect(activity.balanceMinor, 7500);
        expect(activity.isDebitBalance, isTrue);
      });

      test('includes reversed journals in account activity', () async {
        await repository.create(
          _journal(
            journalId: 'journal_reversed',
            operationId: 'operation_reversed',
            status: LedgerJournalStatus.reversed,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: [
              _entry(
                entryId: 'reversed_cash_debit',
                accountId: 'platform_cash_XOF',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 5000,
                currency: 'XOF',
              ),
              _entry(
                entryId: 'reversed_clearing_credit',
                accountId: 'platform_clearing_XOF',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 5000,
                currency: 'XOF',
              ),
            ],
          ),
        );

        final activity = await reportingEngine.accountActivity(
          accountId: 'platform_cash_XOF',
        );

        expect(activity.entryCount, 1);
        expect(activity.totalDebitMinor, 5000);
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

        final activity = await reportingEngine.accountActivity(
          accountId: 'platform_cash_XOF',
        );

        expect(activity.entryCount, 1);
        expect(activity.totalDebitMinor, 1000);
        expect(activity.totalCreditMinor, 0);
      });

      test('filters account activity by occurrence period', () async {
        await repository.create(
          _journal(
            journalId: 'journal_before',
            operationId: 'operation_before',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 8),
            entries: _cashEntries(prefix: 'before', amountMinor: 1000),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_inside',
            operationId: 'operation_inside',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _cashEntries(prefix: 'inside', amountMinor: 2000),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_at_end',
            operationId: 'operation_at_end',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 12),
            entries: _cashEntries(prefix: 'at_end', amountMinor: 3000),
          ),
        );

        final activity = await reportingEngine.accountActivity(
          accountId: 'platform_cash_XOF',
          from: DateTime.utc(2026, 7, 15, 9),
          to: DateTime.utc(2026, 7, 15, 12),
        );

        expect(activity.entryCount, 1);
        expect(activity.totalDebitMinor, 2000);
      });

      test('rejects an invalid account activity period', () async {
        await expectLater(
          () => reportingEngine.accountActivity(
            accountId: 'platform_cash_XOF',
            from: DateTime.utc(2026, 7, 15, 12),
            to: DateTime.utc(2026, 7, 15, 10),
          ),
          throwsArgumentError,
        );
      });

      test('rejects an empty account identifier', () async {
        await expectLater(
          () => reportingEngine.accountActivity(accountId: '   '),
          throwsArgumentError,
        );
      });

      test('throws when no accounting activity exists', () async {
        await expectLater(
          () => reportingEngine.accountActivity(accountId: 'platform_cash_XOF'),
          throwsStateError,
        );
      });

      test('rejects multiple currencies for the same account', () async {
        await repository.create(
          _journal(
            journalId: 'journal_xof',
            operationId: 'operation_xof',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: [
              _entry(
                entryId: 'cash_xof_debit',
                accountId: 'shared_cash_account',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 1000,
                currency: 'XOF',
              ),
              _entry(
                entryId: 'clearing_xof_credit',
                accountId: 'clearing_xof',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 1000,
                currency: 'XOF',
              ),
            ],
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_usd',
            operationId: 'operation_usd',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 11),
            entries: [
              _entry(
                entryId: 'cash_usd_debit',
                accountId: 'shared_cash_account',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 500,
                currency: 'USD',
              ),
              _entry(
                entryId: 'clearing_usd_credit',
                accountId: 'clearing_usd',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 500,
                currency: 'USD',
              ),
            ],
          ),
        );

        await expectLater(
          () =>
              reportingEngine.accountActivity(accountId: 'shared_cash_account'),
          throwsStateError,
        );
      });
    });

    group('trialBalance()', () {
      test('produces the complete trial balance', () async {
        await repository.create(
          _journal(
            journalId: 'journal_001',
            operationId: 'operation_001',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _cashEntries(prefix: 'posted', amountMinor: 10000),
          ),
        );

        final balance = await reportingEngine.trialBalance();

        expect(balance.entryCount, 2);
        expect(balance.totalDebitMinor, 10000);
        expect(balance.totalCreditMinor, 10000);
        expect(balance.isBalanced, isTrue);
      });

      test('produces a trial balance for one currency', () async {
        await repository.create(
          _journal(
            journalId: 'journal_xof',
            operationId: 'operation_xof',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _balancedEntries(
              prefix: 'xof',
              amountMinor: 10000,
              currency: 'XOF',
            ),
          ),
        );

        await repository.create(
          _journal(
            journalId: 'journal_usd',
            operationId: 'operation_usd',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 11),
            entries: _balancedEntries(
              prefix: 'usd',
              amountMinor: 500,
              currency: 'USD',
            ),
          ),
        );

        final balance = await reportingEngine.trialBalance(currency: ' xof ');

        expect(balance.currencies, {'XOF'});
        expect(balance.totalDebitMinor, 10000);
        expect(balance.totalCreditMinor, 10000);
        expect(balance.isBalanced, isTrue);
      });
    });

    group('generalLedger()', () {
      test('produces the general ledger for one account', () async {
        await repository.create(
          _journal(
            journalId: 'journal_001',
            operationId: 'operation_001',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _cashEntries(prefix: 'deposit', amountMinor: 10000),
          ),
        );

        final ledger = await reportingEngine.generalLedger(
          accountId: 'platform_cash_XOF',
        );

        expect(ledger.accountId, 'platform_cash_XOF');

        expect(ledger.currency, 'XOF');
        expect(ledger.entryCount, 1);
        expect(ledger.totalDebitMinor, 10000);
        expect(ledger.totalCreditMinor, 0);
        expect(ledger.closingBalanceMinor, 10000);
        expect(ledger.isConsistent, isTrue);
      });

      test('forwards the opening balance', () async {
        await repository.create(
          _journal(
            journalId: 'journal_001',
            operationId: 'operation_001',
            status: LedgerJournalStatus.posted,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: _cashEntries(prefix: 'deposit', amountMinor: 5000),
          ),
        );

        final ledger = await reportingEngine.generalLedger(
          accountId: 'platform_cash_XOF',
          openingBalanceMinor: 20000,
        );

        expect(ledger.openingBalanceMinor, 20000);
        expect(ledger.movementMinor, 5000);
        expect(ledger.closingBalanceMinor, 25000);

        expect(ledger.entries.single.runningBalanceMinor, 25000);

        expect(ledger.isConsistent, isTrue);
      });

      test('propagates an unknown account failure', () async {
        await expectLater(
          () => reportingEngine.generalLedger(accountId: 'missing_account_XOF'),
          throwsStateError,
        );
      });
    });

    test('remains deterministic for the same repository state', () async {
      await repository.create(
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: _cashEntries(prefix: 'deposit', amountMinor: 10000),
        ),
      );

      final firstSummary = await reportingEngine.summary();

      final secondSummary = await reportingEngine.summary();

      final firstBalance = await reportingEngine.trialBalance();

      final secondBalance = await reportingEngine.trialBalance();

      final firstLedger = await reportingEngine.generalLedger(
        accountId: 'platform_cash_XOF',
      );

      final secondLedger = await reportingEngine.generalLedger(
        accountId: 'platform_cash_XOF',
      );

      expect(firstSummary, secondSummary);
      expect(firstBalance, secondBalance);
      expect(firstLedger, secondLedger);
    });
  });
}

LedgerJournal _journal({
  required String journalId,
  required String operationId,
  required LedgerJournalStatus status,
  required DateTime occurredAt,
  required List<LedgerJournalEntry> entries,
  String workflowKey = 'test.reporting',
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
  required String currency,
}) {
  return LedgerJournalEntry(
    entryId: entryId,
    accountId: accountId,
    direction: direction,
    amountMinor: amountMinor,
    currency: currency,
    description: 'Reporting test entry $entryId',
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
      currency: 'XOF',
    ),
    _entry(
      entryId: '${prefix}_clearing_credit',
      accountId: 'platform_clearing_XOF',
      direction: LedgerJournalEntryDirection.credit,
      amountMinor: amountMinor,
      currency: 'XOF',
    ),
  ];
}

List<LedgerJournalEntry> _balancedEntries({
  required String prefix,
  required int amountMinor,
  required String currency,
}) {
  return [
    _entry(
      entryId: '${prefix}_debit',
      accountId: '${prefix}debit_account$currency',
      direction: LedgerJournalEntryDirection.debit,
      amountMinor: amountMinor,
      currency: currency,
    ),
    _entry(
      entryId: '${prefix}_credit',
      accountId: '${prefix}credit_account$currency',
      direction: LedgerJournalEntryDirection.credit,
      amountMinor: amountMinor,
      currency: currency,
    ),
  ];
}
