import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';

import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'ledger_journal_posting_recovery_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_ledger_journal_posting_strategy.dart';

import 'package:mentora/core/phoenix/bootstrap/'
    'phoenix_bootstrap.dart';

void main() {
  group('Phoenix Ledger Journal recovery integration', () {
    setUp(() async {
      PhoenixBootstrap.reset();
      await PhoenixBootstrap.initialize();
    });

    tearDown(() {
      PhoenixBootstrap.reset();
    });

    test('exposes the Ledger Journal recovery infrastructure', () {
      expect(PhoenixBootstrap.financialRecoveryEngine, isNotNull);

      expect(PhoenixBootstrap.financialRecoveryStrategyRegistry, isNotNull);

      expect(PhoenixBootstrap.ledgerJournalPostingRecoveryStrategy, isNotNull);

      expect(
        PhoenixBootstrap.ledgerJournalPostingRecoveryStrategy.supports(
          _recoveryRequest(),
        ),
        isTrue,
      );

      expect(
        PhoenixBootstrap.financialModule.recoverLedgerJournalPostingStrategy,
        same(PhoenixBootstrap.ledgerJournalPostingRecoveryStrategy),
      );
    });

    test(
      'repairs a missing journal through the official recovery engine',
      () async {
        final transaction = _transaction();

        /*
           * Simulate the critical failure window:
           *
           * 1. the LedgerTransaction was successfully persisted;
           * 2. the process stopped before the LedgerJournal was created.
           */
        await PhoenixBootstrap.ledgerRepository.saveTransaction(transaction);

        final journalBeforeRecovery = await PhoenixBootstrap.journalRepository
            .findByOperationId(transaction.id);

        expect(journalBeforeRecovery, isNull);

        final summaryBeforeRecovery = await PhoenixBootstrap
            .ledgerJournalReportingEngine
            .summary(currency: transaction.currency);

        expect(summaryBeforeRecovery.totalJournals, 0);

        /*
           * Execute recovery through:
           *
           * PhoenixBootstrap
           *   → DefaultFinancialRecoveryEngine
           *   → FinancialRecoveryStrategyRegistry
           *   → RecoverLedgerJournalPostingStrategy
           */
        final result = await PhoenixBootstrap.financialRecoveryEngine.recover(
          request: _recoveryRequest(),
        );

        expect(result, isA<FinancialRecoveryStrategySuccess>());

        final success = result as FinancialRecoveryStrategySuccess;

        expect(success.decision, FinancialRecoveryDecision.retry);

        expect(
          success.strategyKey,
          RecoverLedgerJournalPostingStrategy.strategyKey,
        );

        expect(success.recoveryId, 'recovery_integration_001');

        expect(success.attempt, 1);

        expect(
          success.metadata['recoveryAction'],
          'missing_journal_rebuilt_and_posted',
        );

        expect(success.metadata['transactionId'], transaction.id);

        expect(
          success.metadata['journalId'],
          'journal_recovery_integration_001',
        );

        expect(success.metadata['journalStatus'], 'posted');

        /*
           * The original transaction must remain the only transaction.
           *
           * Recovery must never call PostingEngine.post().
           */
        final storedTransaction = await PhoenixBootstrap.ledgerRepository
            .findTransactionById(transaction.id);

        expect(storedTransaction, same(transaction));

        expect(PhoenixBootstrap.ledgerRepository.length, 1);

        /*
           * The missing journal must now exist and be posted.
           */
        final recoveredJournal = await PhoenixBootstrap.journalRepository
            .findByOperationId(transaction.id);

        expect(recoveredJournal, isNotNull);

        expect(recoveredJournal!.journalId, 'journal_recovery_integration_001');

        expect(recoveredJournal.operationId, transaction.id);

        expect(recoveredJournal.status, LedgerJournalStatus.posted);

        expect(recoveredJournal.version, 2);

        expect(recoveredJournal.isBalanced, isTrue);

        expect(recoveredJournal.entries, hasLength(transaction.entries.length));

        expect(
          recoveredJournal.metadata['recoveredFromMissingJournal'],
          isTrue,
        );

        expect(
          recoveredJournal.metadata['recoveryId'],
          'recovery_integration_001',
        );

        /*
           * Because posting and reporting share one repository,
           * Reporting must immediately see the repaired journal.
           */
        final summaryAfterRecovery = await PhoenixBootstrap
            .ledgerJournalReportingEngine
            .summary(currency: transaction.currency);

        expect(summaryAfterRecovery.totalJournals, 1);

        expect(summaryAfterRecovery.postedJournals, 1);

        expect(summaryAfterRecovery.pendingJournals, 0);

        expect(summaryAfterRecovery.cancelledJournals, 0);

        expect(summaryAfterRecovery.reversedJournals, 0);
      },
    );

    test('is idempotent when recovery is executed again', () async {
      final transaction = _transaction();

      await PhoenixBootstrap.ledgerRepository.saveTransaction(transaction);

      final firstResult = await PhoenixBootstrap.financialRecoveryEngine
          .recover(request: _recoveryRequest());

      final secondResult = await PhoenixBootstrap.financialRecoveryEngine
          .recover(
            request: _recoveryRequest(
              recoveryId: 'recovery_integration_002',
              attempt: 2,
            ),
          );

      expect(firstResult, isA<FinancialRecoveryStrategySuccess>());

      expect(firstResult.decision, FinancialRecoveryDecision.retry);

      expect(
        firstResult.metadata['recoveryAction'],
        'missing_journal_rebuilt_and_posted',
      );

      expect(secondResult, isA<FinancialRecoveryStrategySuccess>());

      expect(secondResult.decision, FinancialRecoveryDecision.ignore);

      expect(secondResult.metadata['recoveryAction'], 'journal_already_posted');

      expect(PhoenixBootstrap.ledgerRepository.length, 1);

      expect(await PhoenixBootstrap.journalRepository.count(), 1);

      final journal = await PhoenixBootstrap.journalRepository
          .findByOperationId(transaction.id);

      expect(journal, isNotNull);

      expect(journal!.status, LedgerJournalStatus.posted);

      /*
           * Version remains 2:
           * version 1 = creation;
           * version 2 = posting;
           * second recovery performs no transition.
           */
      expect(journal.version, 2);

      final summary = await PhoenixBootstrap.ledgerJournalReportingEngine
          .summary(currency: transaction.currency);

      expect(summary.totalJournals, 1);

      expect(summary.postedJournals, 1);
    });
  });
}

FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
_recoveryRequest({
  String recoveryId = 'recovery_integration_001',
  int attempt = 1,
}) {
  return FinancialRecoveryStrategyRequest(
    recoveryId: recoveryId,
    pipelineId: RecoverLedgerJournalPostingStrategy.supportedPipelineId,
    context: LedgerJournalPostingRecoveryContext(
      transactionId: 'transaction_recovery_integration_001',
      journalId: 'journal_recovery_integration_001',
      workflowKey: 'financial.posting.paymentReleased',
      source: LedgerJournalSource(
        type: 'financial_recovery',
        id: 'settlement_integration_001',
      ),
      occurredAt: DateTime.utc(2026, 7, 16, 10),
      createdAt: DateTime.utc(2026, 7, 16, 10),
      metadata: const {
        'test': 'phoenix_ledger_journal_recovery_integration',
        'environment': 'test',
      },
    ),
    error: StateError(
      'Ledger transaction persisted but '
      'journal posting was interrupted.',
    ),
    stackTrace: StackTrace.current,
    attempt: attempt,
    requestedAt: DateTime.utc(2026, 7, 16, 11),
    metadata: const {'trigger': 'integration_test'},
  );
}

LedgerTransaction _transaction() {
  final createdAt = DateTime.utc(2026, 7, 16, 10);

  const transactionId = 'transaction_recovery_integration_001';

  return LedgerTransaction(
    id: transactionId,
    referenceId: 'paymentReleased:settlement_integration_001',
    description: 'Recovery integration expert settlement',
    currency: 'XOF',
    status: LedgerTransactionStatus.posted,
    createdAt: createdAt,
    metadata: const {
      'consultationId': 'consultation_integration_001',
      'clientId': 'client_integration_001',
      'expertId': 'expert_integration_001',
    },
    entries: [
      LedgerEntry(
        id: '${transactionId}_debit',
        transactionId: transactionId,
        accountId: 'platform_cash_XOF',
        amountMinor: 10000,
        currency: 'XOF',
        side: LedgerEntrySide.debit,
        createdAt: createdAt,
      ),
      LedgerEntry(
        id: '${transactionId}_credit',
        transactionId: transactionId,
        accountId: 'platform_clearing_XOF',
        amountMinor: 10000,
        currency: 'XOF',
        side: LedgerEntrySide.credit,
        createdAt: createdAt,
      ),
    ],
  );
}
