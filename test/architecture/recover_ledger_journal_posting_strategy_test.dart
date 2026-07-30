import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';

import 'package:mentora/core/financial/ledger/journal/engine/'
    'ledger_journal_engine.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';

import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_factory.dart';

import 'package:mentora/core/financial/ledger/journal/repository/'
    'memory_ledger_journal_repository.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/'
    'ledger_journal_reversal_builder.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/service/'
    'ledger_journal_reversal_service.dart';

import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';

import 'package:mentora/core/financial/ledger/repositories/'
    'memory_ledger_repository.dart';

import 'package:mentora/core/financial/ledger/validation/'
    'ledger_journal_validator.dart';

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

void main() {
  group('RecoverLedgerJournalPostingStrategy', () {
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;

    late MemoryLedgerRepository ledgerRepository;

    late MemoryLedgerJournalRepository journalRepository;

    late LedgerJournalValidator journalValidator;

    late LedgerJournalReversalService reversalService;

    late LedgerJournalEngine journalEngine;

    late RecoverLedgerJournalPostingStrategy strategy;

    late DateTime fixedNow;

    setUp(() {
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');

      ledgerRepository = MemoryLedgerRepository();

      journalRepository = MemoryLedgerJournalRepository();

      journalValidator = LedgerJournalValidator(
        chartOfAccounts: chartOfAccounts,
        repository: journalRepository,
      );

      reversalService = LedgerJournalReversalService(
        repository: journalRepository,
        validator: journalValidator,
        builder: const LedgerJournalReversalBuilder(),
      );

      journalEngine = LedgerJournalEngine(
        repository: journalRepository,
        validator: journalValidator,
        reversalService: reversalService,
      );

      fixedNow = DateTime.utc(2026, 7, 16, 12);

      strategy = RecoverLedgerJournalPostingStrategy(
        ledgerRepository: ledgerRepository,
        journalEngine: journalEngine,
        journalFactory: const LedgerJournalFactory(),
        clock: () => fixedNow,
      );
    });

    test('supports only the ledger journal posting pipeline', () {
      expect(strategy.supports(_request()), isTrue);

      expect(
        strategy.supports(_request(pipelineId: 'another.financial.pipeline')),
        isFalse,
      );
    });

    test('returns terminal failure when transaction is missing', () async {
      final result = await strategy.recover(_request());

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.terminalFailure);

      expect(failure.recoveryId, 'recovery_001');

      expect(
        failure.strategyKey,
        RecoverLedgerJournalPostingStrategy.strategyKey,
      );

      expect(failure.completedAt, fixedNow);

      expect(failure.metadata['recoveryAction'], 'transaction_missing');

      expect(failure.metadata['transactionId'], 'transaction_001');

      expect(failure.error, isA<StateError>());

      expect(await journalRepository.count(), 0);

      expect(ledgerRepository.isEmpty, isTrue);
    });

    test('requires manual review when transaction is not posted', () async {
      await ledgerRepository.saveTransaction(
        _transaction(status: LedgerTransactionStatus.pending),
      );

      final result = await strategy.recover(_request());

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.manualReview);

      expect(failure.metadata['recoveryAction'], 'transaction_not_posted');

      expect(failure.metadata['transactionStatus'], 'pending');

      expect(await journalRepository.count(), 0);

      expect(ledgerRepository.length, 1);
    });

    test('rebuilds and posts a missing journal', () async {
      final transaction = _transaction();

      await ledgerRepository.saveTransaction(transaction);

      final result = await strategy.recover(
        _request(metadata: const {'recoveryOrigin': 'automatic_monitor'}),
      );

      expect(result, isA<FinancialRecoveryStrategySuccess>());

      expect(result.decision, FinancialRecoveryDecision.retry);

      expect(result.completedAt, fixedNow);

      expect(
        result.metadata['recoveryAction'],
        'missing_journal_rebuilt_and_posted',
      );

      expect(result.metadata['transactionId'], transaction.id);

      expect(result.metadata['journalId'], 'journal_transaction_001');

      expect(result.metadata['journalStatus'], 'posted');

      expect(result.metadata['recoveryOrigin'], 'automatic_monitor');

      final journal = await journalRepository.findById(
        'journal_transaction_001',
      );

      expect(journal, isNotNull);

      expect(journal!.status, LedgerJournalStatus.posted);

      expect(journal.version, 2);

      expect(journal.operationId, transaction.id);

      expect(journal.workflowKey, 'financial.posting.paymentReleased');

      expect(journal.entries, hasLength(transaction.entries.length));

      expect(journal.debitAmountMinor, transaction.totalDebits);

      expect(journal.creditAmountMinor, transaction.totalCredits);

      expect(journal.isBalanced, isTrue);

      expect(journal.metadata['recoveredFromMissingJournal'], isTrue);

      expect(journal.metadata['recoveryId'], 'recovery_001');

      expect(journal.metadata['recoveryAttempt'], 1);

      expect(
        journal.metadata['recoveryStrategy'],
        RecoverLedgerJournalPostingStrategy.strategyKey,
      );

      /*
           * Recovery must not create a second
           * transaction in the transaction Ledger.
           */
      expect(ledgerRepository.length, 1);

      expect(
        await ledgerRepository.findTransactionById(transaction.id),
        same(transaction),
      );

      expect(await journalRepository.count(), 1);
    });

    test(
      'preserves every transaction entry when rebuilding the journal',
      () async {
        final transaction = _transaction(amountMinor: 25000);

        await ledgerRepository.saveTransaction(transaction);

        await strategy.recover(_request());

        final journal = await journalRepository.findByOperationId(
          transaction.id,
        );

        expect(journal, isNotNull);

        for (final transactionEntry in transaction.entries) {
          final journalEntry = journal!.entries.singleWhere(
            (entry) => entry.entryId == transactionEntry.id,
          );

          expect(journalEntry.accountId, transactionEntry.accountId);

          expect(journalEntry.amountMinor, transactionEntry.amountMinor);

          expect(journalEntry.currency, transactionEntry.currency);

          final expectedDirection =
              transactionEntry.side == LedgerEntrySide.debit
              ? 'debit'
              : 'credit';

          expect(journalEntry.direction.name, expectedDirection);
        }
      },
    );

    test('posts an existing pending journal', () async {
      final transaction = _transaction();

      await ledgerRepository.saveTransaction(transaction);

      final pending = const LedgerJournalFactory().create(
        transaction: transaction,
        journalId: 'journal_transaction_001',
        workflowKey: 'financial.posting.paymentReleased',
        source: _source(),
      );

      await journalEngine.create(pending);

      expect(pending.status, LedgerJournalStatus.pending);

      expect(pending.version, 1);

      final result = await strategy.recover(_request());

      expect(result, isA<FinancialRecoveryStrategySuccess>());

      expect(result.decision, FinancialRecoveryDecision.retry);

      expect(result.metadata['recoveryAction'], 'pending_journal_posted');

      final stored = await journalRepository.findById(pending.journalId);

      expect(stored, isNotNull);

      expect(stored!.status, LedgerJournalStatus.posted);

      expect(stored.version, 2);

      expect(await journalRepository.count(), 1);

      expect(ledgerRepository.length, 1);
    });

    test('ignores an already posted journal idempotently', () async {
      final transaction = _transaction();

      await ledgerRepository.saveTransaction(transaction);

      final pending = const LedgerJournalFactory().create(
        transaction: transaction,
        journalId: 'journal_transaction_001',
        workflowKey: 'financial.posting.paymentReleased',
        source: _source(),
      );

      await journalEngine.create(pending);

      final posted = await journalEngine.post(pending.journalId);

      final result = await strategy.recover(_request());

      expect(result, isA<FinancialRecoveryStrategySuccess>());

      expect(result.decision, FinancialRecoveryDecision.ignore);

      expect(result.metadata['recoveryAction'], 'journal_already_posted');

      final stored = await journalRepository.findById(posted.journalId);

      expect(stored, posted);

      /*
           * No additional journal transition occurred.
           */
      expect(stored!.version, 2);

      expect(await journalRepository.count(), 1);

      expect(ledgerRepository.length, 1);
    });

    test('requires manual review for a cancelled journal', () async {
      final transaction = _transaction();

      await ledgerRepository.saveTransaction(transaction);

      final pending = const LedgerJournalFactory().create(
        transaction: transaction,
        journalId: 'journal_transaction_001',
        workflowKey: 'financial.posting.paymentReleased',
        source: _source(),
      );

      await journalEngine.create(pending);

      final cancelled = await journalEngine.cancel(pending.journalId);

      final result = await strategy.recover(_request());

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.manualReview);

      expect(failure.metadata['recoveryAction'], 'cancelled_journal_detected');

      expect(failure.metadata['journalStatus'], 'cancelled');

      final stored = await journalRepository.findById(cancelled.journalId);

      expect(stored!.status, LedgerJournalStatus.cancelled);

      expect(await journalRepository.count(), 1);

      expect(ledgerRepository.length, 1);
    });

    test('requires manual review for a reversed journal', () async {
      final transaction = _transaction();

      await ledgerRepository.saveTransaction(transaction);

      final pending = const LedgerJournalFactory().create(
        transaction: transaction,
        journalId: 'journal_transaction_001',
        workflowKey: 'financial.posting.paymentReleased',
        source: _source(),
      );

      await journalEngine.create(pending);

      final posted = await journalEngine.post(pending.journalId);

      final reversed = posted.copyWith(
        status: LedgerJournalStatus.reversed,
        version: posted.version + 1,
      );

      await journalRepository.update(
        journal: reversed,
        expectedVersion: posted.version,
      );

      final result = await strategy.recover(_request());

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.manualReview);

      expect(failure.metadata['recoveryAction'], 'reversed_journal_detected');

      expect(failure.metadata['journalStatus'], 'reversed');

      final stored = await journalRepository.findById(reversed.journalId);

      expect(stored!.status, LedgerJournalStatus.reversed);

      expect(stored.version, 3);

      expect(await journalRepository.count(), 1);

      expect(ledgerRepository.length, 1);
    });

    test('remains idempotent across repeated recovery calls', () async {
      final transaction = _transaction();

      await ledgerRepository.saveTransaction(transaction);

      final first = await strategy.recover(_request());

      final second = await strategy.recover(
        _request(recoveryId: 'recovery_002', attempt: 2),
      );

      expect(first.decision, FinancialRecoveryDecision.retry);

      expect(second.decision, FinancialRecoveryDecision.ignore);

      expect(
        first.metadata['recoveryAction'],
        'missing_journal_rebuilt_and_posted',
      );

      expect(second.metadata['recoveryAction'], 'journal_already_posted');

      expect(ledgerRepository.length, 1);

      expect(await journalRepository.count(), 1);

      final stored = await journalRepository.findByOperationId(transaction.id);

      expect(stored, isNotNull);

      expect(stored!.status, LedgerJournalStatus.posted);

      expect(stored.version, 2);
    });
  });
}

FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext> _request({
  String recoveryId = 'recovery_001',
  String pipelineId = RecoverLedgerJournalPostingStrategy.supportedPipelineId,
  int attempt = 1,
  Map<String, dynamic> metadata = const {},
}) {
  return FinancialRecoveryStrategyRequest(
    recoveryId: recoveryId,
    pipelineId: pipelineId,
    context: LedgerJournalPostingRecoveryContext(
      transactionId: 'transaction_001',
      journalId: 'journal_transaction_001',
      workflowKey: 'financial.posting.paymentReleased',
      source: _source(),
      occurredAt: DateTime.utc(2026, 7, 15, 10),
      createdAt: DateTime.utc(2026, 7, 15, 10),
      metadata: const {'contextSource': 'recovery_test'},
    ),
    error: StateError('Journal posting was interrupted.'),
    stackTrace: StackTrace.current,
    attempt: attempt,
    requestedAt: DateTime.utc(2026, 7, 16, 9),
    metadata: metadata,
  );
}

LedgerTransaction _transaction({
  String id = 'transaction_001',
  LedgerTransactionStatus status = LedgerTransactionStatus.posted,
  int amountMinor = 10000,
}) {
  final createdAt = DateTime.utc(2026, 7, 15, 10);

  return LedgerTransaction(
    id: id,
    referenceId: 'paymentReleased:settlement_001',
    description: 'Consultation settlement expert payment',
    currency: 'XOF',
    status: status,
    createdAt: createdAt,
    metadata: const {
      'consultationId': 'consultation_001',
      'expertId': 'expert_001',
    },
    entries: [
      LedgerEntry(
        id: '${id}_debit',
        transactionId: id,
        accountId: 'platform_cash_XOF',
        amountMinor: amountMinor,
        currency: 'XOF',
        side: LedgerEntrySide.debit,
        createdAt: createdAt,
      ),
      LedgerEntry(
        id: '${id}_credit',
        transactionId: id,
        accountId: 'platform_clearing_XOF',
        amountMinor: amountMinor,
        currency: 'XOF',
        side: LedgerEntrySide.credit,
        createdAt: createdAt,
      ),
    ],
  );
}

LedgerJournalSource _source() {
  return LedgerJournalSource(type: 'financial_posting', id: 'settlement_001');
}
