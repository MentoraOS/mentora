import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'ledger_journal_posting_recovery_context.dart';
import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'partial_settlement_recovery_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/orchestrator/'
    'financial_recovery_workflow_orchestrator.dart';

import 'package:mentora/core/financial/pipeline/recovery/registry/'
    'financial_recovery_workflow_registry.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_ledger_journal_posting_strategy.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_partial_settlement_strategy.dart';

import 'package:mentora/core/financial/pipeline/recovery/workflows/'
    'financial_recovery_workflow.dart';

import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';
import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('FinancialRecoveryWorkflowOrchestrator', () {
    late FinancialRecoveryWorkflowRegistry registry;

    late FinancialRecoveryWorkflowOrchestrator orchestrator;

    setUp(() {
      registry = FinancialRecoveryWorkflowRegistry();

      orchestrator = FinancialRecoveryWorkflowOrchestrator(
        workflowRegistry: registry,
      );
    });

    test('exposes the exact workflow registry instance', () {
      expect(orchestrator.workflowRegistry, same(registry));
    });

    test('canRecover returns true for a supported Ledger Journal request', () {
      final request = _ledgerJournalRequest();

      final workflow =
          _RecordingRecoveryWorkflow<LedgerJournalPostingRecoveryContext>(
            workflowKey: 'recover.ledger.journal.workflow',
            pipelineId: RecoverLedgerJournalPostingStrategy.supportedPipelineId,
            result: _successResult(
              recoveryId: request.recoveryId,
              strategyKey: 'recover.ledger.journal.posting',
            ),
          );

      registry.register(workflow);

      final canRecover = orchestrator.canRecover(request);

      expect(canRecover, isTrue);

      expect(workflow.supportsCallCount, 1);

      expect(workflow.executeCallCount, 0);

      expect(workflow.receivedSupportsRequest, same(request));
    });

    test(
      'canRecover returns true for a supported partial settlement request',
      () {
        final request = _partialSettlementRequest();

        final workflow =
            _RecordingRecoveryWorkflow<PartialSettlementRecoveryContext>(
              workflowKey: 'recover.partial.settlement.workflow',
              pipelineId: RecoverPartialSettlementStrategy.supportedPipelineId,
              result: _successResult(
                recoveryId: request.recoveryId,
                strategyKey: 'recover.partial.settlement',
              ),
            );

        registry.register(workflow);

        expect(orchestrator.canRecover(request), isTrue);

        expect(workflow.supportsCallCount, 1);

        expect(workflow.executeCallCount, 0);
      },
    );

    test(
      'canRecover returns false when no workflow owns the request pipeline',
      () {
        final request = _ledgerJournalRequest(
          pipelineId: 'unknown.recovery.pipeline',
        );

        expect(orchestrator.canRecover(request), isFalse);
      },
    );

    test(
      'canRecover returns false when the resolved workflow rejects the request',
      () {
        final request = _ledgerJournalRequest();

        final workflow =
            _RecordingRecoveryWorkflow<LedgerJournalPostingRecoveryContext>(
              workflowKey: 'recover.ledger.journal.workflow',
              pipelineId: request.pipelineId,
              supportsRequest: false,
              result: _successResult(
                recoveryId: request.recoveryId,
                strategyKey: 'recover.ledger.journal.posting',
              ),
            );

        registry.register(workflow);

        expect(orchestrator.canRecover(request), isFalse);

        expect(workflow.supportsCallCount, 1);

        expect(workflow.executeCallCount, 0);
      },
    );

    test(
      'resolves and executes the Ledger Journal workflow exactly once',
      () async {
        final request = _ledgerJournalRequest();

        final expectedResult = _successResult(
          recoveryId: request.recoveryId,
          strategyKey: 'recover.ledger.journal.posting',
        );

        final workflow =
            _RecordingRecoveryWorkflow<LedgerJournalPostingRecoveryContext>(
              workflowKey: 'recover.ledger.journal.workflow',
              pipelineId: request.pipelineId,
              result: expectedResult,
            );

        registry.register(workflow);

        final result = await orchestrator.recover(request: request);

        expect(result, same(expectedResult));

        expect(workflow.supportsCallCount, 1);

        expect(workflow.executeCallCount, 1);

        expect(workflow.receivedSupportsRequest, same(request));

        expect(workflow.receivedExecuteRequest, same(request));

        expect(workflow.typedExecuteRequest.context, same(request.context));
      },
    );

    test(
      'resolves and executes the partial settlement workflow exactly once',
      () async {
        final request = _partialSettlementRequest();

        final expectedResult = _successResult(
          recoveryId: request.recoveryId,
          strategyKey: 'recover.partial.settlement',
        );

        final workflow =
            _RecordingRecoveryWorkflow<PartialSettlementRecoveryContext>(
              workflowKey: 'recover.partial.settlement.workflow',
              pipelineId: request.pipelineId,
              result: expectedResult,
            );

        registry.register(workflow);

        final result = await orchestrator.recover(request: request);

        expect(result, same(expectedResult));

        expect(workflow.supportsCallCount, 1);

        expect(workflow.executeCallCount, 1);

        expect(workflow.receivedExecuteRequest, same(request));

        expect(workflow.typedExecuteRequest.context, same(request.context));

        expect(
          workflow.typedExecuteRequest.context.split,
          same(request.context.split),
        );
      },
    );

    test(
      'returns the exact controlled failure produced by the workflow',
      () async {
        final request = _ledgerJournalRequest();

        final recoveryError = StateError(
          'Ledger recovery requires manual review.',
        );

        final recoveryStackTrace = StackTrace.current;

        final expectedResult = FinancialRecoveryStrategyFailure(
          recoveryId: request.recoveryId,
          strategyKey: 'recover.ledger.journal.posting',
          decision: FinancialRecoveryDecision.manualReview,
          attempt: request.attempt,
          duration: const Duration(milliseconds: 25),
          completedAt: DateTime.utc(2026, 7, 17, 12),
          error: recoveryError,
          stackTrace: recoveryStackTrace,
          metadata: const {'reason': 'journal_conflict'},
        );

        final workflow =
            _RecordingRecoveryWorkflow<LedgerJournalPostingRecoveryContext>(
              workflowKey: 'recover.ledger.journal.workflow',
              pipelineId: request.pipelineId,
              result: expectedResult,
            );

        registry.register(workflow);

        final result = await orchestrator.recover(request: request);

        expect(result, same(expectedResult));

        expect(result, isA<FinancialRecoveryStrategyFailure>());

        expect(result.decision, FinancialRecoveryDecision.manualReview);

        expect(workflow.executeCallCount, 1);
      },
    );

    test('throws StateError when no workflow supports the request', () async {
      final request = _ledgerJournalRequest(
        pipelineId: 'unknown.recovery.pipeline',
      );

      await expectLater(
        orchestrator.recover(request: request),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'throws StateError when the registered workflow rejects the request',
      () async {
        final request = _partialSettlementRequest();

        final workflow =
            _RecordingRecoveryWorkflow<PartialSettlementRecoveryContext>(
              workflowKey: 'recover.partial.settlement.workflow',
              pipelineId: request.pipelineId,
              supportsRequest: false,
              result: _successResult(
                recoveryId: request.recoveryId,
                strategyKey: 'recover.partial.settlement',
              ),
            );

        registry.register(workflow);

        await expectLater(
          orchestrator.recover(request: request),
          throwsA(isA<StateError>()),
        );

        expect(workflow.supportsCallCount, 1);

        expect(workflow.executeCallCount, 0);
      },
    );

    test('propagates workflow errors unchanged', () async {
      final request = _partialSettlementRequest();

      final expectedError = StateError('Recovery workflow crashed.');

      final workflow =
          _RecordingRecoveryWorkflow<PartialSettlementRecoveryContext>(
            workflowKey: 'recover.partial.settlement.workflow',
            pipelineId: request.pipelineId,
            error: expectedError,
          );

      registry.register(workflow);

      Object? capturedError;
      StackTrace? capturedStackTrace;

      try {
        await orchestrator.recover(request: request);

        fail(
          'The orchestrator should have '
          'propagated the workflow error.',
        );
      } catch (error, stackTrace) {
        capturedError = error;
        capturedStackTrace = stackTrace;
      }

      expect(capturedError, same(expectedError));

      expect(capturedStackTrace, isNotNull);

      expect(workflow.supportsCallCount, 1);

      expect(workflow.executeCallCount, 1);

      expect(workflow.receivedExecuteRequest, same(request));
    });

    test(
      'selects the workflow matching the request context and pipeline',
      () async {
        final ledgerRequest = _ledgerJournalRequest();

        final settlementRequest = _partialSettlementRequest();

        final ledgerResult = _successResult(
          recoveryId: ledgerRequest.recoveryId,
          strategyKey: 'recover.ledger.journal.posting',
        );

        final settlementResult = _successResult(
          recoveryId: settlementRequest.recoveryId,
          strategyKey: 'recover.partial.settlement',
        );

        final ledgerWorkflow =
            _RecordingRecoveryWorkflow<LedgerJournalPostingRecoveryContext>(
              workflowKey: 'recover.ledger.journal.workflow',
              pipelineId: ledgerRequest.pipelineId,
              result: ledgerResult,
            );

        final settlementWorkflow =
            _RecordingRecoveryWorkflow<PartialSettlementRecoveryContext>(
              workflowKey: 'recover.partial.settlement.workflow',
              pipelineId: settlementRequest.pipelineId,
              result: settlementResult,
            );

        registry.register(ledgerWorkflow);
        registry.register(settlementWorkflow);

        final firstResult = await orchestrator.recover(request: ledgerRequest);

        final secondResult = await orchestrator.recover(
          request: settlementRequest,
        );

        expect(firstResult, same(ledgerResult));

        expect(secondResult, same(settlementResult));

        expect(ledgerWorkflow.executeCallCount, 1);

        expect(settlementWorkflow.executeCallCount, 1);

        expect(ledgerWorkflow.receivedExecuteRequest, same(ledgerRequest));

        expect(
          settlementWorkflow.receivedExecuteRequest,
          same(settlementRequest),
        );
      },
    );
  });
}

FinancialRecoveryStrategySuccess _successResult({
  required String recoveryId,
  required String strategyKey,
}) {
  return FinancialRecoveryStrategySuccess(
    recoveryId: recoveryId,
    strategyKey: strategyKey,
    decision: FinancialRecoveryDecision.ignore,
    attempt: 1,
    duration: const Duration(milliseconds: 15),
    completedAt: DateTime.utc(2026, 7, 17, 12),
    metadata: const {'source': 'financial_recovery_workflow_orchestrator_test'},
  );
}

FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
_ledgerJournalRequest({
  String pipelineId = RecoverLedgerJournalPostingStrategy.supportedPipelineId,
}) {
  return FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>(
    recoveryId: 'ledger_recovery_001',
    pipelineId: pipelineId,
    context: LedgerJournalPostingRecoveryContext(
      transactionId: 'transaction_001',
      journalId: 'journal_001',
      workflowKey: 'finalize.consultation.settlement',
      source: LedgerJournalSource(
        type: 'recovery',
        id: 'financial_recovery_workflow_orchestrator_test',
      ),
      occurredAt: DateTime.utc(2026, 7, 17, 10),
      createdAt: DateTime.utc(2026, 7, 17, 10, 1),
      metadata: const {'consultationId': 'consultation_001'},
    ),
    error: StateError('Ledger Journal posting was interrupted.'),
    stackTrace: StackTrace.current,
    attempt: 1,
    requestedAt: DateTime.utc(2026, 7, 17, 11),
    metadata: const {'trigger': 'architecture_test'},
  );
}

FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
_partialSettlementRequest({
  String pipelineId = RecoverPartialSettlementStrategy.supportedPipelineId,
}) {
  return FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>(
    recoveryId: 'partial_recovery_001',
    pipelineId: pipelineId,
    context: PartialSettlementRecoveryContext(
      operationId: 'settlement_001',
      consultationId: 'consultation_001',
      escrowId: 'escrow_001',
      clientId: 'client_001',
      expertId: 'expert_001',
      split: _split(),
      occurredAt: DateTime.utc(2026, 7, 17, 10),
      metadata: const {
        'source': 'financial_recovery_workflow_orchestrator_test',
      },
    ),
    error: StateError('Settlement posting was interrupted.'),
    stackTrace: StackTrace.current,
    attempt: 1,
    requestedAt: DateTime.utc(2026, 7, 17, 11),
    metadata: const {'trigger': 'architecture_test'},
  );
}

SettlementSplit _split() {
  return const SettlementSplit(
    grossAmountMinor: 10000,
    currency: 'XOF',
    components: [
      SettlementSplitComponent(
        destination: SplitDestination.expertWallet,
        amountMinor: 8130,
        code: 'expert_net',
        label: 'Expert net amount',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.platformRevenue,
        amountMinor: 1500,
        code: 'platform_fee',
        label: 'Platform commission',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.taxPayable,
        amountMinor: 270,
        code: 'tax',
        label: 'Tax payable',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.paymentProviderFee,
        amountMinor: 100,
        code: 'provider_fee',
        label: 'Payment provider fee',
      ),
    ],
  );
}

final class _RecordingRecoveryWorkflow<
  TContext extends FinancialPipelineContext
>
    implements FinancialRecoveryWorkflow<TContext> {
  _RecordingRecoveryWorkflow({
    required this.workflowKey,
    required this.pipelineId,
    this.result,
    this.error,
    this.supportsRequest = true,
  }) : assert(
         result != null || error != null,
         'The recording workflow requires '
         'either a result or an error.',
       );

  @override
  final String workflowKey;

  @override
  final String pipelineId;

  final FinancialRecoveryStrategyResult? result;

  final Object? error;

  final bool supportsRequest;

  int supportsCallCount = 0;

  int executeCallCount = 0;

  Object? receivedSupportsRequest;

  Object? receivedExecuteRequest;

  FinancialRecoveryStrategyRequest<TContext> get typedExecuteRequest {
    return receivedExecuteRequest!
        as FinancialRecoveryStrategyRequest<TContext>;
  }

  @override
  bool supports(FinancialRecoveryStrategyRequest<TContext> request) {
    supportsCallCount++;

    receivedSupportsRequest = request;

    return supportsRequest && request.pipelineId.trim() == pipelineId.trim();
  }

  @override
  Future<FinancialRecoveryStrategyResult> execute({
    required FinancialRecoveryStrategyRequest<TContext> request,
  }) async {
    executeCallCount++;

    receivedExecuteRequest = request;

    if (error != null) {
      throw error!;
    }

    return result!;
  }
}
