import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';
import 'package:mentora/core/financial/pipeline/recovery/bootstrap/'
    'financial_recovery_module.dart';
import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'ledger_journal_posting_recovery_context.dart';
import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event.dart';
import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event_dispatcher.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_ledger_journal_posting_strategy.dart';
import 'package:mentora/core/phoenix/bootstrap/phoenix_bootstrap.dart';

void main() {
  group('Financial Recovery end-to-end integration', () {
    late List<FinancialRecoveryPipelineEvent> events;
    late FinancialRecoveryModule module;

    setUp(() async {
      PhoenixBootstrap.reset();
      await PhoenixBootstrap.initialize();

      events = <FinancialRecoveryPipelineEvent>[];

      module = FinancialRecoveryModule.initialize(
        strategyRegistry: PhoenixBootstrap.financialRecoveryStrategyRegistry,
        recoveryEngine: PhoenixBootstrap.financialRecoveryEngine,
        eventDispatcher: FinancialRecoveryPipelineEventDispatcher(
          listeners: [events.add],
        ),
        clock: () => DateTime.utc(2026, 7, 16, 12),
      );
    });

    tearDown(PhoenixBootstrap.reset);

    test('routes a missing-journal request through orchestrator, workflow, '
        'pipeline, engine and strategy', () async {
      final transaction = _transaction();
      await PhoenixBootstrap.ledgerRepository.saveTransaction(transaction);

      final result = await module.orchestrator.recover(
        request: _recoveryRequest(),
      );

      expect(result, isA<FinancialRecoveryStrategySuccess>());
      final success = result as FinancialRecoveryStrategySuccess;

      expect(success.decision, FinancialRecoveryDecision.retry);
      expect(
        success.strategyKey,
        RecoverLedgerJournalPostingStrategy.strategyKey,
      );
      expect(
        success.metadata['recoveryAction'],
        'missing_journal_rebuilt_and_posted',
      );

      final journal = await PhoenixBootstrap.journalRepository
          .findByOperationId(transaction.id);

      expect(journal, isNotNull);
      expect(journal!.status, LedgerJournalStatus.posted);
      expect(journal.isBalanced, isTrue);
      expect(journal.version, 2);
      expect(PhoenixBootstrap.ledgerRepository.length, 1);
      expect(await PhoenixBootstrap.journalRepository.count(), 1);

      final summary = await PhoenixBootstrap.ledgerJournalReportingEngine
          .summary(currency: transaction.currency);

      expect(summary.totalJournals, 1);
      expect(summary.postedJournals, 1);
    });

    test('emits started, succeeded and finished events in order', () async {
      final transaction = _transaction();
      await PhoenixBootstrap.ledgerRepository.saveTransaction(transaction);

      await module.orchestrator.recover(request: _recoveryRequest());

      expect(events, hasLength(3));
      expect(events[0], isA<FinancialRecoveryPipelineStarted>());
      expect(events[1], isA<FinancialRecoveryPipelineSucceeded>());
      expect(events[2], isA<FinancialRecoveryPipelineFinished>());

      for (final event in events) {
        expect(event.recoveryId, 'recovery_integration_001');
        expect(
          event.pipelineId,
          RecoverLedgerJournalPostingStrategy.supportedPipelineId,
        );
        expect(event.attempt, 1);
        expect(event.occurredAt, DateTime.utc(2026, 7, 16, 12));
      }
    });

    test(
      'remains idempotent when the same repair is requested twice',
      () async {
        final transaction = _transaction();
        await PhoenixBootstrap.ledgerRepository.saveTransaction(transaction);

        final firstResult = await module.orchestrator.recover(
          request: _recoveryRequest(),
        );
        final secondResult = await module.orchestrator.recover(
          request: _recoveryRequest(
            recoveryId: 'recovery_integration_002',
            attempt: 2,
          ),
        );

        expect(firstResult, isA<FinancialRecoveryStrategySuccess>());
        expect(firstResult.decision, FinancialRecoveryDecision.retry);
        expect(secondResult, isA<FinancialRecoveryStrategySuccess>());
        expect(secondResult.decision, FinancialRecoveryDecision.ignore);
        expect(
          secondResult.metadata['recoveryAction'],
          'journal_already_posted',
        );

        expect(PhoenixBootstrap.ledgerRepository.length, 1);
        expect(await PhoenixBootstrap.journalRepository.count(), 1);

        final journal = await PhoenixBootstrap.journalRepository
            .findByOperationId(transaction.id);
        expect(journal, isNotNull);
        expect(journal!.version, 2);

        expect(events, hasLength(6));
        expect(
          events.whereType<FinancialRecoveryPipelineStarted>(),
          hasLength(2),
        );
        expect(
          events.whereType<FinancialRecoveryPipelineSucceeded>(),
          hasLength(2),
        );
        expect(
          events.whereType<FinancialRecoveryPipelineFinished>(),
          hasLength(2),
        );
      },
    );

    test('rejects an unknown workflow before executing the pipeline', () async {
      final request = _recoveryRequest(pipelineId: 'unknown.pipeline');

      expect(
        () => module.orchestrator.recover(request: request),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('No financial recovery workflow is registered'),
          ),
        ),
      );

      expect(events, isEmpty);
      expect(await PhoenixBootstrap.journalRepository.count(), 0);
      expect(PhoenixBootstrap.ledgerRepository.length, 0);
    });
  });
}

FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
_recoveryRequest({
  String recoveryId = 'recovery_integration_001',
  int attempt = 1,
  String pipelineId = RecoverLedgerJournalPostingStrategy.supportedPipelineId,
}) {
  return FinancialRecoveryStrategyRequest(
    recoveryId: recoveryId,
    pipelineId: pipelineId,
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
        'test': 'financial_recovery_integration',
        'environment': 'test',
      },
    ),
    error: StateError(
      'Ledger transaction persisted but journal posting was interrupted.',
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
