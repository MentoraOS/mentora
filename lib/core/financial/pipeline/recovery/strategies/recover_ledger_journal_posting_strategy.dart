import '../../../ledger/journal/engine/'
    'ledger_journal_engine.dart';
import '../../../ledger/journal/engine/'
    'ledger_journal_engine_exception.dart';

import '../../../ledger/journal/models/'
    'ledger_journal.dart';
import '../../../ledger/journal/models/'
    'ledger_journal_status.dart';

import '../../../ledger/journal/posting/'
    'ledger_journal_factory.dart';

import '../../../ledger/models/'
    'ledger_transaction.dart';
import '../../../ledger/models/'
    'ledger_transaction_status.dart';

import '../../../ledger/repositories/'
    'ledger_repository.dart';

import '../contexts/'
    'ledger_journal_posting_recovery_context.dart';

import 'financial_recovery_decision.dart';
import 'financial_recovery_strategy.dart';
import 'financial_recovery_strategy_request.dart';
import 'financial_recovery_strategy_result.dart';

typedef FinancialRecoveryStrategyClock = DateTime Function();

/// Repairs the Journal projection of an already-persisted Ledger transaction.
///
/// Supported recovery scenarios:
///
/// - transaction missing:
///   terminal failure;
///
/// - journal missing:
///   rebuild, create and post the journal;
///
/// - journal pending:
///   post the existing journal;
///
/// - journal already posted:
///   return an idempotent no-op success;
///
/// - journal cancelled or reversed:
///   require manual review.
///
/// This strategy never calls PostingEngine and therefore never creates
/// another LedgerTransaction.
final class RecoverLedgerJournalPostingStrategy
    implements FinancialRecoveryStrategy<LedgerJournalPostingRecoveryContext> {
  RecoverLedgerJournalPostingStrategy({
    required this.ledgerRepository,
    required this.journalEngine,
    required this.journalFactory,
    FinancialRecoveryStrategyClock? clock,
  }) : clock = clock ?? DateTime.now;

  static const String strategyKey = 'ledger.journal.posting.recovery';

  static const String supportedPipelineId = 'ledger.journal.posting';

  @override
  String get key => strategyKey;

  final LedgerRepository ledgerRepository;

  final LedgerJournalEngine journalEngine;

  final LedgerJournalFactory journalFactory;

  final FinancialRecoveryStrategyClock clock;

  @override
  bool supports(
    FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
    request,
  ) {
    return request.pipelineId.trim() == supportedPipelineId;
  }

  @override
  Future<FinancialRecoveryStrategyResult> recover(
    FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
    request,
  ) async {
    final stopwatch = Stopwatch()..start();

    final context = request.context;

    final transaction = await ledgerRepository.findTransactionById(
      context.transactionId,
    );

    if (transaction == null) {
      stopwatch.stop();

      return _failure(
        request: request,
        decision: FinancialRecoveryDecision.terminalFailure,
        duration: stopwatch.elapsed,
        error: StateError(
          'Ledger transaction '
          '"${context.transactionId}" was not found. '
          'The Journal cannot be reconstructed.',
        ),
        metadata: {
          'recoveryAction': 'transaction_missing',
          'transactionId': context.transactionId,
          'journalId': context.journalId,
        },
      );
    }

    if (transaction.status != LedgerTransactionStatus.posted) {
      stopwatch.stop();

      return _failure(
        request: request,
        decision: FinancialRecoveryDecision.manualReview,
        duration: stopwatch.elapsed,
        error: StateError(
          'Ledger transaction '
          '"${transaction.id}" has status '
          '"${transaction.status.name}". '
          'Only posted transactions may be journalized.',
        ),
        metadata: {
          'recoveryAction': 'transaction_not_posted',
          'transactionId': transaction.id,
          'transactionStatus': transaction.status.name,
          'journalId': context.journalId,
        },
      );
    }

    final existingJournal = await journalEngine.findByOperationId(
      transaction.id,
    );

    if (existingJournal != null) {
      return _recoverExistingJournal(
        request: request,
        transaction: transaction,
        journal: existingJournal,
        stopwatch: stopwatch,
      );
    }

    return _rebuildMissingJournal(
      request: request,
      transaction: transaction,
      stopwatch: stopwatch,
    );
  }

  Future<FinancialRecoveryStrategyResult> _recoverExistingJournal({
    required FinancialRecoveryStrategyRequest<
      LedgerJournalPostingRecoveryContext
    >
    request,
    required LedgerTransaction transaction,
    required LedgerJournal journal,
    required Stopwatch stopwatch,
  }) async {
    switch (journal.status) {
      case LedgerJournalStatus.posted:
        stopwatch.stop();

        return _success(
          request: request,
          decision: FinancialRecoveryDecision.ignore,
          duration: stopwatch.elapsed,
          metadata: {
            'recoveryAction': 'journal_already_posted',
            'transactionId': transaction.id,
            'journalId': journal.journalId,
            'journalStatus': journal.status.name,
            'journalVersion': journal.version,
          },
        );

      case LedgerJournalStatus.pending:
        final postedJournal = await journalEngine.post(journal.journalId);

        stopwatch.stop();

        return _success(
          request: request,
          decision: FinancialRecoveryDecision.retry,
          duration: stopwatch.elapsed,
          metadata: {
            'recoveryAction': 'pending_journal_posted',
            'transactionId': transaction.id,
            'journalId': postedJournal.journalId,
            'journalStatus': postedJournal.status.name,
            'journalVersion': postedJournal.version,
          },
        );

      case LedgerJournalStatus.cancelled:
        stopwatch.stop();

        return _failure(
          request: request,
          decision: FinancialRecoveryDecision.manualReview,
          duration: stopwatch.elapsed,
          error: StateError(
            'Journal "${journal.journalId}" for '
            'transaction "${transaction.id}" is '
            'cancelled and cannot be posted automatically.',
          ),
          metadata: {
            'recoveryAction': 'cancelled_journal_detected',
            'transactionId': transaction.id,
            'journalId': journal.journalId,
            'journalStatus': journal.status.name,
            'journalVersion': journal.version,
          },
        );

      case LedgerJournalStatus.reversed:
        stopwatch.stop();

        return _failure(
          request: request,
          decision: FinancialRecoveryDecision.manualReview,
          duration: stopwatch.elapsed,
          error: StateError(
            'Journal "${journal.journalId}" for '
            'transaction "${transaction.id}" is '
            'reversed and requires manual investigation.',
          ),
          metadata: {
            'recoveryAction': 'reversed_journal_detected',
            'transactionId': transaction.id,
            'journalId': journal.journalId,
            'journalStatus': journal.status.name,
            'journalVersion': journal.version,
          },
        );
    }
  }

  Future<FinancialRecoveryStrategyResult> _rebuildMissingJournal({
    required FinancialRecoveryStrategyRequest<
      LedgerJournalPostingRecoveryContext
    >
    request,
    required LedgerTransaction transaction,
    required Stopwatch stopwatch,
  }) async {
    final context = request.context;

    final pendingJournal = journalFactory.create(
      transaction: transaction,
      journalId: context.journalId,
      workflowKey: context.workflowKey,
      source: context.source,
      occurredAt: context.occurredAt,
      createdAt: context.createdAt,
      metadata: {
        ...context.metadata,
        ...request.metadata,
        'recoveryId': request.recoveryId,
        'recoveryAttempt': request.attempt,
        'recoveryStrategy': strategyKey,
        'recoveredFromMissingJournal': true,
      },
    );

    try {
      final created = await journalEngine.create(pendingJournal);

      final posted = await journalEngine.post(created.journalId);

      stopwatch.stop();

      return _success(
        request: request,
        decision: FinancialRecoveryDecision.retry,
        duration: stopwatch.elapsed,
        metadata: {
          'recoveryAction': 'missing_journal_rebuilt_and_posted',
          'transactionId': transaction.id,
          'journalId': posted.journalId,
          'journalStatus': posted.status.name,
          'journalVersion': posted.version,
        },
      );
    } on LedgerJournalAlreadyExistsException {
      /*
       * A concurrent recovery may have created the Journal after our initial
       * lookup but before create().
       *
       * Resolve the newly created Journal and continue idempotently.
       */
      final concurrentJournal = await journalEngine.findByOperationId(
        transaction.id,
      );

      if (concurrentJournal == null) {
        rethrow;
      }

      return _recoverExistingJournal(
        request: request,
        transaction: transaction,
        journal: concurrentJournal,
        stopwatch: stopwatch,
      );
    }
  }

  FinancialRecoveryStrategySuccess _success({
    required FinancialRecoveryStrategyRequest<
      LedgerJournalPostingRecoveryContext
    >
    request,
    required FinancialRecoveryDecision decision,
    required Duration duration,
    required Map<String, dynamic> metadata,
  }) {
    return FinancialRecoveryStrategySuccess(
      recoveryId: request.recoveryId,
      strategyKey: strategyKey,
      decision: decision,
      attempt: request.attempt,
      duration: duration,
      completedAt: clock().toUtc(),
      metadata: {
        ...request.metadata,
        ...metadata,
        'pipelineId': request.pipelineId,
      },
    );
  }

  FinancialRecoveryStrategyFailure _failure({
    required FinancialRecoveryStrategyRequest<
      LedgerJournalPostingRecoveryContext
    >
    request,
    required FinancialRecoveryDecision decision,
    required Duration duration,
    required Object error,
    required Map<String, dynamic> metadata,
  }) {
    return FinancialRecoveryStrategyFailure(
      recoveryId: request.recoveryId,
      strategyKey: strategyKey,
      decision: decision,
      attempt: request.attempt,
      duration: duration,
      completedAt: clock().toUtc(),
      error: error,
      stackTrace: StackTrace.current,
      metadata: {
        ...request.metadata,
        ...metadata,
        'pipelineId': request.pipelineId,
      },
    );
  }
}
