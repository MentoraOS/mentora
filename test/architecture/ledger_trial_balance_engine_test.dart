import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_trial_balance_engine.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';

void main() {
  group('LedgerTrialBalanceEngine', () {
    late MemoryLedgerJournalRepository repository;
    late LedgerTrialBalanceEngine engine;

    setUp(() {
      repository = MemoryLedgerJournalRepository();

      engine = LedgerTrialBalanceEngine(repository: repository);
    });

    test('builds an empty trial balance', () async {
      final balance = await engine.build();

      expect(balance.entries, isEmpty);
      expect(balance.accountCount, 0);
      expect(balance.entryCount, 0);
      expect(balance.totalDebitMinor, 0);
      expect(balance.totalCreditMinor, 0);
      expect(balance.isBalanced, isTrue);
    });

    test('aggregates posted journal entries by account', () async {
      await repository.create(
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            LedgerJournalEntry(
              entryId: 'entry_001_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'Debit platform cash',
            ),
            LedgerJournalEntry(
              entryId: 'entry_001_credit',
              accountId: 'expert_wallet_001_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'Credit expert wallet',
            ),
          ],
        ),
      );

      final balance = await engine.build();

      expect(balance.accountCount, 2);
      expect(balance.entryCount, 2);
      expect(balance.totalDebitMinor, 10000);
      expect(balance.totalCreditMinor, 10000);
      expect(balance.isBalanced, isTrue);

      final cash = balance.account('platform_cash_XOF');

      expect(cash, isNotNull);
      expect(cash!.totalDebitMinor, 10000);
      expect(cash.totalCreditMinor, 0);
      expect(cash.entryCount, 1);
    });

    test('combines entries from multiple journals', () async {
      await repository.create(
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            LedgerJournalEntry(
              entryId: 'entry_001_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'First cash debit',
            ),
            LedgerJournalEntry(
              entryId: 'entry_001_credit',
              accountId: 'expert_wallet_001_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'First expert credit',
            ),
          ],
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_002',
          operationId: 'operation_002',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: [
            LedgerJournalEntry(
              entryId: 'entry_002_debit',
              accountId: 'platform_cash_XOF',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 5000,
              currency: 'XOF',
              description: 'Second cash debit',
            ),
            LedgerJournalEntry(
              entryId: 'entry_002_credit',
              accountId: 'platform_revenue_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 5000,
              currency: 'XOF',
              description: 'Revenue credit',
            ),
          ],
        ),
      );

      final balance = await engine.build();

      final cash = balance.account('platform_cash_XOF');

      expect(cash, isNotNull);
      expect(cash!.totalDebitMinor, 15000);
      expect(cash.totalCreditMinor, 0);
      expect(cash.entryCount, 2);

      final expertWallet = balance.account('expert_wallet_001_XOF');

      expect(expertWallet, isNotNull);
      expect(expertWallet!.totalCreditMinor, 10000);

      final revenue = balance.account('platform_revenue_XOF');

      expect(revenue, isNotNull);
      expect(revenue!.totalCreditMinor, 5000);

      expect(balance.accountCount, 3);
      expect(balance.entryCount, 4);
      expect(balance.totalDebitMinor, 15000);
      expect(balance.totalCreditMinor, 15000);
      expect(balance.balanceMinor, 0);
      expect(balance.isBalanced, isTrue);
    });

    test('excludes pending and cancelled journals', () async {
      await repository.create(
        _journal(
          journalId: 'journal_posted',
          operationId: 'operation_posted',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: _balancedEntries(
            prefix: 'posted',
            amountMinor: 1000,
            currency: 'XOF',
          ),
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_pending',
          operationId: 'operation_pending',
          status: LedgerJournalStatus.pending,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: _balancedEntries(
            prefix: 'pending',
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
          occurredAt: DateTime.utc(2026, 7, 15, 12),
          entries: _balancedEntries(
            prefix: 'cancelled',
            amountMinor: 3000,
            currency: 'XOF',
          ),
        ),
      );

      final balance = await engine.build();

      expect(balance.totalDebitMinor, 1000);
      expect(balance.totalCreditMinor, 1000);
      expect(balance.entryCount, 2);
    });

    test(
      'includes reversed originals and posted compensating journals',
      () async {
        await repository.create(
          _journal(
            journalId: 'journal_original',
            operationId: 'operation_original',
            status: LedgerJournalStatus.reversed,
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            entries: [
              LedgerJournalEntry(
                entryId: 'original_debit',
                accountId: 'escrow_XOF',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 10000,
                currency: 'XOF',
                description: 'Original debit',
              ),
              LedgerJournalEntry(
                entryId: 'original_credit',
                accountId: 'expert_wallet_XOF',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 10000,
                currency: 'XOF',
                description: 'Original credit',
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
              LedgerJournalEntry(
                entryId: 'reversal_debit',
                accountId: 'expert_wallet_XOF',
                direction: LedgerJournalEntryDirection.debit,
                amountMinor: 10000,
                currency: 'XOF',
                description: 'Reversal debit',
              ),
              LedgerJournalEntry(
                entryId: 'reversal_credit',
                accountId: 'escrow_XOF',
                direction: LedgerJournalEntryDirection.credit,
                amountMinor: 10000,
                currency: 'XOF',
                description: 'Reversal credit',
              ),
            ],
          ),
        );

        final balance = await engine.build();

        final escrow = balance.account('escrow_XOF');
        final expert = balance.account('expert_wallet_XOF');

        expect(escrow?.balanceMinor, 0);
        expect(expert?.balanceMinor, 0);

        expect(balance.totalDebitMinor, 20000);
        expect(balance.totalCreditMinor, 20000);
        expect(balance.isBalanced, isTrue);
      },
    );

    test('separates the same account by currency', () async {
      await repository.create(
        _journal(
          journalId: 'journal_xof',
          operationId: 'operation_xof',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            LedgerJournalEntry(
              entryId: 'xof_debit',
              accountId: 'platform_cash',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'XOF cash',
            ),
            LedgerJournalEntry(
              entryId: 'xof_credit',
              accountId: 'clearing_XOF',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 10000,
              currency: 'XOF',
              description: 'XOF clearing',
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
            LedgerJournalEntry(
              entryId: 'usd_debit',
              accountId: 'platform_cash',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 500,
              currency: 'USD',
              description: 'USD cash',
            ),
            LedgerJournalEntry(
              entryId: 'usd_credit',
              accountId: 'clearing_USD',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 500,
              currency: 'USD',
              description: 'USD clearing',
            ),
          ],
        ),
      );

      final balance = await engine.build();

      final cashLines = balance.entries
          .where((entry) => entry.accountId == 'platform_cash')
          .toList();

      expect(cashLines, hasLength(2));

      expect(cashLines.map((entry) => entry.currency).toSet(), {'XOF', 'USD'});
    });

    test('builds a balance for one currency', () async {
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

      final balance = await engine.buildForCurrency(' xof ');

      expect(balance.currencies, {'XOF'});
      expect(balance.totalDebitMinor, 10000);
      expect(balance.totalCreditMinor, 10000);
    });

    test('builds a balance for an occurrence period', () async {
      await repository.create(
        _journal(
          journalId: 'journal_early',
          operationId: 'operation_early',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 9),
          entries: _balancedEntries(
            prefix: 'early',
            amountMinor: 1000,
            currency: 'XOF',
          ),
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_inside',
          operationId: 'operation_inside',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: _balancedEntries(
            prefix: 'inside',
            amountMinor: 2000,
            currency: 'XOF',
          ),
        ),
      );

      final balance = await engine.buildForPeriod(
        from: DateTime.utc(2026, 7, 15, 10),
        to: DateTime.utc(2026, 7, 15, 12),
      );

      expect(balance.totalDebitMinor, 2000);
      expect(balance.totalCreditMinor, 2000);
    });

    test('builds a balance for a workflow', () async {
      await repository.create(
        _journal(
          journalId: 'journal_settlement',
          operationId: 'operation_settlement',
          workflowKey: 'finalize.consultation.settlement',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: _balancedEntries(
            prefix: 'settlement',
            amountMinor: 5000,
            currency: 'XOF',
          ),
        ),
      );

      await repository.create(
        _journal(
          journalId: 'journal_deposit',
          operationId: 'operation_deposit',
          workflowKey: 'wallet.deposit',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 11),
          entries: _balancedEntries(
            prefix: 'deposit',
            amountMinor: 9000,
            currency: 'XOF',
          ),
        ),
      );

      final balance = await engine.buildForWorkflow(
        'finalize.consultation.settlement',
      );

      expect(balance.totalDebitMinor, 5000);
      expect(balance.totalCreditMinor, 5000);
    });

    test('sorts entries deterministically', () {
      final balance = engine.buildFromJournals([
        _journal(
          journalId: 'journal_001',
          operationId: 'operation_001',
          status: LedgerJournalStatus.posted,
          occurredAt: DateTime.utc(2026, 7, 15, 10),
          entries: [
            LedgerJournalEntry(
              entryId: 'entry_b',
              accountId: 'account_b',
              direction: LedgerJournalEntryDirection.debit,
              amountMinor: 100,
              currency: 'XOF',
              description: 'B',
            ),
            LedgerJournalEntry(
              entryId: 'entry_a',
              accountId: 'account_a',
              direction: LedgerJournalEntryDirection.credit,
              amountMinor: 100,
              currency: 'XOF',
              description: 'A',
            ),
          ],
        ),
      ]);

      expect(balance.entries.map((entry) => entry.accountId).toList(), [
        'account_a',
        'account_b',
      ]);
    });

    test('rejects an invalid reporting period', () async {
      await expectLater(
        () => engine.buildForPeriod(
          from: DateTime.utc(2026, 7, 15, 12),
          to: DateTime.utc(2026, 7, 15, 10),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty currency', () async {
      await expectLater(
        () => engine.buildForCurrency('   '),
        throwsArgumentError,
      );
    });
  });
}

LedgerJournal _journal({
  required String journalId,
  required String operationId,
  required LedgerJournalStatus status,
  required DateTime occurredAt,
  required List<LedgerJournalEntry> entries,
  String workflowKey = 'test.workflow',
}) {
  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: workflowKey,
    source: LedgerJournalSource(type: 'test', id: journalId),
    status: status,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    entries: entries,
  );
}

List<LedgerJournalEntry> _balancedEntries({
  required String prefix,
  required int amountMinor,
  required String currency,
}) {
  return [
    LedgerJournalEntry(
      entryId: '${prefix}_debit',
      accountId: '${prefix}_debit_account',
      direction: LedgerJournalEntryDirection.debit,
      amountMinor: amountMinor,
      currency: currency,
      description: '$prefix debit',
    ),
    LedgerJournalEntry(
      entryId: '${prefix}_credit',
      accountId: '${prefix}_credit_account',
      direction: LedgerJournalEntryDirection.credit,
      amountMinor: amountMinor,
      currency: currency,
      description: '$prefix credit',
    ),
  ];
}
