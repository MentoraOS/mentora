import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/bootstrap/'
    'financial_module.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';

import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_general_ledger_engine.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_journal_reporting_engine.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_trial_balance_engine.dart';

import 'package:mentora/core/financial/ledger/journal/repository/'
    'memory_ledger_journal_repository.dart';

import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';

import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_request.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/financial_posting_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/financial_posting_result.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_result.dart';

import 'package:mentora/core/financial/pipeline/'
    'default_financial_pipeline_engine.dart';

import 'package:mentora/core/financial/runtime/engine/'
    'transactional_financial_runtime.dart';

import 'package:mentora/core/financial/transaction/boundary/'
    'in_memory_financial_transaction_boundary.dart';

void main() {
  group('FinancialModule', () {
    late List<PostingRequest> capturedRequests;

    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;

    late MemoryLedgerJournalRepository journalRepository;

    late LedgerJournalReportingEngine reportingEngine;

    late FinancialModule module;

    setUp(() {
      capturedRequests = <PostingRequest>[];

      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');

      journalRepository = MemoryLedgerJournalRepository();

      final trialBalanceEngine = LedgerTrialBalanceEngine(
        repository: journalRepository,
      );

      final generalLedgerEngine = LedgerGeneralLedgerEngine(
        repository: journalRepository,
        chartOfAccounts: chartOfAccounts,
      );

      reportingEngine = LedgerJournalReportingEngine(
        repository: journalRepository,
        trialBalanceEngine: trialBalanceEngine,
        generalLedgerEngine: generalLedgerEngine,
      );

      module = FinancialModule.initializeWithPost(
        post: (request) async {
          capturedRequests.add(request);

          return _buildLedgerTransaction(request);
        },
        reportingEngine: reportingEngine,
        executionIdFactory: (context) {
          return 'execution-${context.operationId}';
        },
        correlationIdFactory: (context) {
          return context.operationId;
        },
        attemptFactory: (context) {
          return 1;
        },
        metadataFactory: (context) {
          return const {'environment': 'test'};
        },
      );
    });

    group('assembly', () {
      test('should initialize all financial components', () {
        expect(module.feePolicyRegistry, isNotNull);

        expect(module.feeEngine, isNotNull);
        expect(module.splitEngine, isNotNull);

        expect(module.settlementPostingAdapter, isNotNull);

        expect(module.settleConsultationWorkflow, isNotNull);

        expect(module.financialPostingWorkflow, isNotNull);

        expect(module.finalizeConsultationSettlementWorkflow, isNotNull);

        expect(module.workflowRegistry, isNotNull);

        expect(module.orchestrator, isNotNull);

        expect(module.pipelineMetricsRegistry, isNotNull);

        expect(module.pipelineStepMetricsRegistry, isNotNull);

        expect(module.reportingEngine, same(reportingEngine));
      });

      test('should expose the exact default pipeline engine', () {
        expect(module.pipelineEngine, isA<DefaultFinancialPipelineEngine>());
      });

      test('should expose an in-memory transaction boundary', () {
        expect(
          module.transactionModule.boundary,
          isA<InMemoryFinancialTransactionBoundary>(),
        );
      });

      test('should expose a transactional financial Runtime', () {
        expect(module.financialRuntime, isA<TransactionalFinancialRuntime>());
      });

      test('should not leave an active transaction after assembly', () {
        final boundary =
            module.transactionModule.boundary
                as InMemoryFinancialTransactionBoundary;

        expect(boundary.hasActiveTransactions, isFalse);

        expect(boundary.activeTransactionIds, isEmpty);
      });

      test('should expose the injected reporting engine', () {
        expect(module.reportingEngine, same(reportingEngine));
      });
    });

    group('workflow registry', () {
      test(
        'should register the exact finalize settlement workflow instance',
        () {
          final workflow = module.workflowRegistry
              .resolve<
                SettleConsultationContext,
                FinalizeConsultationSettlementResult
              >(FinalizeConsultationSettlementWorkflow.workflowKey);

          expect(workflow, same(module.finalizeConsultationSettlementWorkflow));
        },
      );

      test(
        'should register the exact settle consultation workflow instance',
        () {
          final workflow = module.workflowRegistry
              .resolve<SettleConsultationContext, SettleConsultationResult>(
                module.settleConsultationWorkflow.key,
              );

          expect(workflow, same(module.settleConsultationWorkflow));
        },
      );

      test('should register the exact financial posting workflow instance', () {
        final workflow = module.workflowRegistry
            .resolve<FinancialPostingContext, FinancialPostingResult>(
              module.financialPostingWorkflow.key,
            );

        expect(workflow, same(module.financialPostingWorkflow));
      });
    });

    group('transactional execution', () {
      test(
        'should execute the complete settlement through the module',
        () async {
          final result = await module.orchestrator
              .executeWorkflow<
                SettleConsultationContext,
                FinalizeConsultationSettlementResult
              >(
                key: FinalizeConsultationSettlementWorkflow.workflowKey,
                context: _buildContext(),
              );

          expect(result.success, isTrue);

          expect(result.operationId, 'settlement_001');

          expect(result.consultationId, 'consultation_001');

          expect(result.feeQuote.grossAmountMinor, 10000);

          expect(result.feeQuote.currency, 'XOF');

          expect(result.split.isBalanced, isTrue);

          expect(result.split.totalMinor, 10000);

          expect(result.ledgerTransactionIds, hasLength(4));

          expect(capturedRequests, hasLength(4));

          final boundary =
              module.transactionModule.boundary
                  as InMemoryFinancialTransactionBoundary;

          expect(boundary.hasActiveTransactions, isFalse);

          expect(boundary.activeTransactionIds, isEmpty);
        },
      );

      test('should map the split into four posting requests', () async {
        await module.orchestrator.executeWorkflow<
          SettleConsultationContext,
          FinalizeConsultationSettlementResult
        >(
          key: FinalizeConsultationSettlementWorkflow.workflowKey,
          context: _buildContext(),
        );

        expect(
          capturedRequests
              .map((request) => request.amountMinor)
              .toList(growable: false),
          containsAll(const [8130, 1500, 270, 100]),
        );
      });

      test('should preserve operation metadata', () async {
        await module.orchestrator.executeWorkflow<
          SettleConsultationContext,
          FinalizeConsultationSettlementResult
        >(
          key: FinalizeConsultationSettlementWorkflow.workflowKey,
          context: _buildContext(),
        );

        expect(capturedRequests, isNotEmpty);

        for (final request in capturedRequests) {
          expect(request.referenceId, 'settlement_001');

          expect(request.metadata['paymentId'], 'payment_001');

          expect(request.metadata['source'], 'financial_module_test');

          expect(request.metadata['escrowId'], 'escrow_001');
        }
      });

      test('should clear transaction state after pipeline failure', () async {
        final expectedError = StateError('Ledger posting failed.');

        final failingModule = FinancialModule.initializeWithPost(
          post: (request) async {
            throw expectedError;
          },
          reportingEngine: reportingEngine,
          executionIdFactory: (context) {
            return 'execution-${context.operationId}';
          },
          correlationIdFactory: (context) {
            return context.operationId;
          },
        );

        final future = failingModule.orchestrator
            .executeWorkflow<
              SettleConsultationContext,
              FinalizeConsultationSettlementResult
            >(
              key: FinalizeConsultationSettlementWorkflow.workflowKey,
              context: _buildContext(),
            );

        await expectLater(future, throwsA(same(expectedError)));

        final boundary =
            failingModule.transactionModule.boundary
                as InMemoryFinancialTransactionBoundary;

        expect(boundary.hasActiveTransactions, isFalse);

        expect(boundary.activeTransactionIds, isEmpty);
      });

      test('should allow a new execution after a failed transaction', () async {
        var postingAttempt = 0;

        final retryModule = FinancialModule.initializeWithPost(
          post: (request) async {
            postingAttempt++;

            if (postingAttempt == 1) {
              throw StateError('Transient posting failure.');
            }

            return _buildLedgerTransaction(request);
          },
          reportingEngine: reportingEngine,
          executionIdFactory: (context) {
            return 'execution-'
                '${context.operationId}-'
                '$postingAttempt';
          },
          correlationIdFactory: (context) {
            return context.operationId;
          },
        );

        await expectLater(
          retryModule.orchestrator.executeWorkflow<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(
            key: FinalizeConsultationSettlementWorkflow.workflowKey,
            context: _buildContext(),
          ),
          throwsA(isA<StateError>()),
        );

        final result = await retryModule.orchestrator
            .executeWorkflow<
              SettleConsultationContext,
              FinalizeConsultationSettlementResult
            >(
              key: FinalizeConsultationSettlementWorkflow.workflowKey,
              context: _buildContext(),
            );

        expect(result.success, isTrue);

        final boundary =
            retryModule.transactionModule.boundary
                as InMemoryFinancialTransactionBoundary;

        expect(boundary.hasActiveTransactions, isFalse);
      });
    });

    group('injected Runtime identities', () {
      test(
        'should invoke execution and correlation factories during settlement',
        () async {
          final observedOperationIds = <String>[];

          final identityModule = FinancialModule.initializeWithPost(
            post: (request) async {
              return _buildLedgerTransaction(request);
            },
            reportingEngine: reportingEngine,
            executionIdFactory: (context) {
              observedOperationIds.add('execution:${context.operationId}');

              return 'execution-${context.operationId}';
            },
            correlationIdFactory: (context) {
              observedOperationIds.add('correlation:${context.operationId}');

              return context.operationId;
            },
            attemptFactory: (context) {
              observedOperationIds.add('attempt:1');

              return 1;
            },
          );

          await identityModule.orchestrator.executeWorkflow<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(
            key: FinalizeConsultationSettlementWorkflow.workflowKey,
            context: _buildContext(),
          );

          expect(observedOperationIds, [
            'execution:settlement_001',
            'correlation:settlement_001',
            'attempt:1',
          ]);
        },
      );

      test('should keep correlation identity stable '
          'while preventing duplicate posting', () async {
        final observedCorrelations = <String>[];

        var executionSequence = 0;

        final identityModule = FinancialModule.initializeWithPost(
          post: (request) async {
            return _buildLedgerTransaction(request);
          },
          reportingEngine: reportingEngine,
          executionIdFactory: (context) {
            executionSequence++;

            return 'execution-'
                '${context.operationId}-'
                '$executionSequence';
          },
          correlationIdFactory: (context) {
            final correlationId = context.operationId;

            observedCorrelations.add(correlationId);

            return correlationId;
          },
          attemptFactory: (context) {
            return executionSequence;
          },
        );

        final firstResult = await identityModule.orchestrator
            .executeWorkflow<
              SettleConsultationContext,
              FinalizeConsultationSettlementResult
            >(
              key: FinalizeConsultationSettlementWorkflow.workflowKey,
              context: _buildContext(),
            );

        expect(firstResult.success, isTrue);

        await expectLater(
          identityModule.orchestrator.executeWorkflow<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(
            key: FinalizeConsultationSettlementWorkflow.workflowKey,
            context: _buildContext(),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.toString(),
              'message',
              contains('already been completed'),
            ),
          ),
        );

        expect(observedCorrelations, const <String>[
          'settlement_001',
          'settlement_001',
        ]);

        expect(executionSequence, 2);
      });
    });
  });
}

SettleConsultationContext _buildContext() {
  return SettleConsultationContext(
    operationId: 'settlement_001',
    consultationId: 'consultation_001',
    paymentId: 'payment_001',
    escrowId: 'escrow_001',
    clientId: 'client_001',
    expertId: 'expert_001',
    grossAmountMinor: 10000,
    currency: 'XOF',
    occurredAt: DateTime.utc(2026, 7, 13, 10),
    metadata: const {'source': 'financial_module_test'},
  );
}

LedgerTransaction _buildLedgerTransaction(PostingRequest request) {
  return LedgerTransaction(
    id: request.id,
    referenceId: '${request.type.name}:${request.referenceId}',
    description: request.type.name,
    currency: request.currency,
    status: LedgerTransactionStatus.posted,
    createdAt: request.createdAt,
    metadata: request.metadata,
    entries: [
      LedgerEntry(
        id: '${request.id}_debit',
        transactionId: request.id,
        accountId: 'test_escrow',
        amountMinor: request.amountMinor,
        currency: request.currency,
        side: LedgerEntrySide.debit,
        createdAt: request.createdAt,
      ),
      LedgerEntry(
        id: '${request.id}_credit',
        transactionId: request.id,
        accountId: 'test_destination',
        amountMinor: request.amountMinor,
        currency: request.currency,
        side: LedgerEntrySide.credit,
        createdAt: request.createdAt,
      ),
    ],
  );
}
