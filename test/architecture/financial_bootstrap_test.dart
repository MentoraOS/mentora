import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/bootstrap/'
    'financial_bootstrap.dart';

import 'package:mentora/core/financial/fees/engine/'
    'fee_engine.dart';
import 'package:mentora/core/financial/fees/policies/'
    'consultation_fee_policy.dart';
import 'package:mentora/core/financial/fees/policies/'
    'fee_policy_registry.dart';

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

import 'package:mentora/core/financial/orchestrator/adapters/'
    'settlement_posting_adapter.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/'
    'financial_posting_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/'
    'financial_posting_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/'
    'financial_posting_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/'
    'settle_consultation_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/'
    'settle_consultation_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/'
    'settle_consultation_workflow.dart';

void main() {
  group('FinancialBootstrap', () {
    late List<PostingRequest> capturedRequests;

    late SettleConsultationWorkflow settlementWorkflow;
    late FinancialPostingWorkflow financialPostingWorkflow;

    setUp(() {
      capturedRequests = <PostingRequest>[];

      final feePolicyRegistry = FeePolicyRegistry()
        ..register(const ConsultationFeePolicy());

      final feeEngine = FeeEngine(registry: feePolicyRegistry);

      settlementWorkflow = SettleConsultationWorkflow(feeEngine: feeEngine);

      final postingAdapter = SettlementPostingAdapter(
        post: (request) async {
          capturedRequests.add(request);

          return _buildLedgerTransaction(request);
        },
      );

      financialPostingWorkflow = FinancialPostingWorkflow(
        postingPort: postingAdapter,
      );
    });

    test('should register the exact settlement workflow instance', () {
      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: financialPostingWorkflow,
        executionIdFactory: (context) {
          return 'execution-${context.operationId}';
        },
        correlationIdFactory: (context) {
          return context.operationId;
        },
      );

      final registered = registry
          .resolve<SettleConsultationContext, SettleConsultationResult>(
            settlementWorkflow.key,
          );

      expect(registered, same(settlementWorkflow));
    });

    test('should register the exact financial posting workflow instance', () {
      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: financialPostingWorkflow,
        executionIdFactory: (context) {
          return 'execution-${context.operationId}';
        },
        correlationIdFactory: (context) {
          return context.operationId;
        },
      );

      final registered = registry
          .resolve<FinancialPostingContext, FinancialPostingResult>(
            financialPostingWorkflow.key,
          );

      expect(registered, same(financialPostingWorkflow));
    });

    test('should register the finalize consultation settlement workflow', () {
      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: financialPostingWorkflow,
        executionIdFactory: (context) {
          return 'execution-${context.operationId}';
        },
        correlationIdFactory: (context) {
          return context.operationId;
        },
      );

      final registered = registry
          .resolve<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(FinalizeConsultationSettlementWorkflow.workflowKey);

      expect(registered, isA<FinalizeConsultationSettlementWorkflow>());
    });

    test(
      'should execute the complete settlement through the bootstrapped registry',
      () async {
        final registry = FinancialBootstrap.buildRegistry(
          settlementWorkflow: settlementWorkflow,
          financialPostingWorkflow: financialPostingWorkflow,
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
            return const {'source': 'financial-bootstrap-test'};
          },
          runtimeClock: () => DateTime.utc(2026, 7, 18, 12),
          transactionClock: () => DateTime.utc(2026, 7, 18, 12, 0, 1),
        );

        final workflow = registry
            .resolve<
              SettleConsultationContext,
              FinalizeConsultationSettlementResult
            >(FinalizeConsultationSettlementWorkflow.workflowKey);

        final result = await workflow.execute(_buildContext());

        expect(result.success, isTrue);

        expect(result.operationId, 'settlement_001');

        expect(result.consultationId, 'consultation_001');

        expect(result.feeQuote.grossAmountMinor, 10000);

        expect(result.feeQuote.currency, 'XOF');

        expect(result.split.isBalanced, isTrue);

        expect(result.split.totalMinor, 10000);

        expect(result.ledgerTransactionIds, hasLength(4));

        expect(capturedRequests, hasLength(4));
      },
    );

    test('should invoke all injected Runtime identity factories', () async {
      final observedCalls = <String>[];

      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: financialPostingWorkflow,
        executionIdFactory: (context) {
          observedCalls.add('execution:${context.operationId}');

          return 'execution-${context.operationId}';
        },
        correlationIdFactory: (context) {
          observedCalls.add('correlation:${context.operationId}');

          return context.operationId;
        },
        attemptFactory: (context) {
          observedCalls.add('attempt:1');

          return 1;
        },
        metadataFactory: (context) {
          observedCalls.add('metadata');

          return const {'source': 'bootstrap-test'};
        },
      );

      final workflow = registry
          .resolve<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(FinalizeConsultationSettlementWorkflow.workflowKey);

      await workflow.execute(_buildContext());

      expect(observedCalls, [
        'execution:settlement_001',
        'correlation:settlement_001',
        'attempt:1',
        'metadata',
      ]);
    });

    test('should keep correlation identity stable '
        'while preventing duplicate posting', () async {
      final observedCorrelations = <String>[];

      var executionSequence = 0;
      var attemptSequence = 0;

      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: financialPostingWorkflow,
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
          attemptSequence++;

          return attemptSequence;
        },
      );

      final workflow = registry
          .resolve<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(FinalizeConsultationSettlementWorkflow.workflowKey);

      final firstResult = await workflow.execute(_buildContext());

      expect(firstResult.success, isTrue);

      await expectLater(
        workflow.execute(_buildContext()),
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
      expect(attemptSequence, 2);

      // The first settlement produced four postings.
      // The rejected retry must produce none.
      expect(capturedRequests, hasLength(4));
    });

    test(
      'should propagate posting failure after transactional rollback',
      () async {
        final expectedError = StateError('Ledger posting failed.');

        final failingAdapter = SettlementPostingAdapter(
          post: (request) async {
            throw expectedError;
          },
        );

        final failingPostingWorkflow = FinancialPostingWorkflow(
          postingPort: failingAdapter,
        );

        final registry = FinancialBootstrap.buildRegistry(
          settlementWorkflow: settlementWorkflow,
          financialPostingWorkflow: failingPostingWorkflow,
          executionIdFactory: (context) {
            return 'execution-${context.operationId}';
          },
          correlationIdFactory: (context) {
            return context.operationId;
          },
        );

        final workflow = registry
            .resolve<
              SettleConsultationContext,
              FinalizeConsultationSettlementResult
            >(FinalizeConsultationSettlementWorkflow.workflowKey);

        await expectLater(
          workflow.execute(_buildContext()),
          throwsA(same(expectedError)),
        );
      },
    );

    test('should allow a new execution after a failed transaction', () async {
      var postingAttempt = 0;

      final retryAdapter = SettlementPostingAdapter(
        post: (request) async {
          postingAttempt++;

          if (postingAttempt == 1) {
            throw StateError('Transient posting failure.');
          }

          return _buildLedgerTransaction(request);
        },
      );

      final retryPostingWorkflow = FinancialPostingWorkflow(
        postingPort: retryAdapter,
      );

      var executionSequence = 0;
      var attemptSequence = 0;

      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: retryPostingWorkflow,
        executionIdFactory: (context) {
          executionSequence++;

          return 'execution-'
              '${context.operationId}-'
              '$executionSequence';
        },
        correlationIdFactory: (context) {
          return context.operationId;
        },
        attemptFactory: (context) {
          attemptSequence++;

          return attemptSequence;
        },
      );

      final workflow = registry
          .resolve<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(FinalizeConsultationSettlementWorkflow.workflowKey);

      await expectLater(
        workflow.execute(_buildContext()),
        throwsA(isA<StateError>()),
      );

      final result = await workflow.execute(_buildContext());

      expect(result.success, isTrue);

      expect(executionSequence, 2);
      expect(attemptSequence, 2);
    });

    test('should preserve posting request metadata', () async {
      final registry = FinancialBootstrap.buildRegistry(
        settlementWorkflow: settlementWorkflow,
        financialPostingWorkflow: financialPostingWorkflow,
        executionIdFactory: (context) {
          return 'execution-${context.operationId}';
        },
        correlationIdFactory: (context) {
          return context.operationId;
        },
        metadataFactory: (context) {
          return const {'environment': 'test'};
        },
      );

      final workflow = registry
          .resolve<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(FinalizeConsultationSettlementWorkflow.workflowKey);

      await workflow.execute(_buildContext());

      expect(capturedRequests, isNotEmpty);

      for (final request in capturedRequests) {
        expect(request.referenceId, 'settlement_001');

        expect(request.metadata['paymentId'], 'payment_001');

        expect(request.metadata['escrowId'], 'escrow_001');

        expect(request.metadata['source'], 'financial_bootstrap_test');
      }
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
    occurredAt: DateTime.utc(2026, 7, 18, 10),
    metadata: const {'source': 'financial_bootstrap_test'},
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
