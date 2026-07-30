import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'ledger_journal_posting_recovery_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/pipeline/'
    'financial_recovery_pipeline.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_ledger_journal_posting_strategy.dart';

import 'package:mentora/core/financial/pipeline/recovery/workflows/'
    'recover_ledger_journal_workflow.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';

void main() {
  group('RecoverLedgerJournalWorkflow', () {
    late _FakeFinancialRecoveryPipeline pipeline;
    late RecoverLedgerJournalWorkflow workflow;

    late FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
    request;

    late FinancialRecoveryStrategySuccess expectedResult;

    setUp(() {
      expectedResult = FinancialRecoveryStrategySuccess(
        recoveryId: 'recovery_001',
        strategyKey: 'recover.ledger.journal.posting',
        decision: FinancialRecoveryDecision.ignore,
        attempt: 1,
        duration: const Duration(milliseconds: 15),
        completedAt: DateTime.utc(2026, 7, 17, 12),
        metadata: const {'source': 'recover_ledger_journal_workflow_test'},
      );

      pipeline = _FakeFinancialRecoveryPipeline(result: expectedResult);

      workflow = RecoverLedgerJournalWorkflow(pipeline: pipeline);

      request =
          FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>(
            recoveryId: 'recovery_001',
            pipelineId: RecoverLedgerJournalPostingStrategy.supportedPipelineId,
            context: _context(),
            error: StateError('Ledger Journal posting was interrupted.'),
            stackTrace: StackTrace.current,
            attempt: 1,
            requestedAt: DateTime.utc(2026, 7, 17, 11),
            metadata: const {'trigger': 'architecture_test'},
          );
    });

    test('exposes a stable workflow key', () {
      expect(
        workflow.workflowKey,
        RecoverLedgerJournalWorkflow.workflowKeyValue,
      );

      expect(workflow.workflowKey, 'recover.ledger.journal.workflow');
    });

    test('reuses the strategy pipeline identifier', () {
      expect(
        workflow.pipelineId,
        RecoverLedgerJournalPostingStrategy.supportedPipelineId,
      );

      expect(
        RecoverLedgerJournalWorkflow.supportedPipelineId,
        RecoverLedgerJournalPostingStrategy.supportedPipelineId,
      );
    });

    test('supports requests for the Ledger Journal recovery pipeline', () {
      expect(workflow.supports(request), isTrue);
    });

    test(
      'normalizes the request pipeline identifier when checking support',
      () {
        final paddedRequest =
            FinancialRecoveryStrategyRequest<
              LedgerJournalPostingRecoveryContext
            >(
              recoveryId: request.recoveryId,
              pipelineId: '  ${workflow.pipelineId}  ',
              context: request.context,
              error: request.error,
              stackTrace: request.stackTrace,
              attempt: request.attempt,
              requestedAt: request.requestedAt,
              metadata: request.metadata,
            );

        expect(workflow.supports(paddedRequest), isTrue);
      },
    );

    test('rejects requests for another recovery pipeline', () {
      final unsupportedRequest =
          FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>(
            recoveryId: request.recoveryId,
            pipelineId: 'another.recovery.pipeline',
            context: request.context,
            error: request.error,
            stackTrace: request.stackTrace,
            attempt: request.attempt,
            requestedAt: request.requestedAt,
            metadata: request.metadata,
          );

      expect(workflow.supports(unsupportedRequest), isFalse);
    });

    test('delegates the exact request to the recovery pipeline', () async {
      await workflow.execute(request: request);

      expect(pipeline.callCount, 1);

      expect(pipeline.receivedRequest, same(request));
    });

    test(
      'returns the exact result produced by the recovery pipeline',
      () async {
        final result = await workflow.execute(request: request);

        expect(result, same(expectedResult));

        expect(result.decision, FinancialRecoveryDecision.ignore);
      },
    );

    test('does not execute the recovery pipeline more than once', () async {
      await workflow.execute(request: request);

      expect(pipeline.callCount, 1);
    });

    test('propagates recovery pipeline errors unchanged', () async {
      final expectedError = StateError('Recovery pipeline crashed.');

      final failingPipeline = _FakeFinancialRecoveryPipeline(
        error: expectedError,
      );

      final failingWorkflow = RecoverLedgerJournalWorkflow(
        pipeline: failingPipeline,
      );

      Object? capturedError;
      StackTrace? capturedStackTrace;

      try {
        await failingWorkflow.execute(request: request);

        fail(
          'The workflow should have propagated '
          'the recovery pipeline error.',
        );
      } catch (error, stackTrace) {
        capturedError = error;
        capturedStackTrace = stackTrace;
      }

      expect(capturedError, same(expectedError));

      expect(capturedStackTrace, isNotNull);

      expect(failingPipeline.callCount, 1);

      expect(failingPipeline.receivedRequest, same(request));
    });
  });
}

LedgerJournalPostingRecoveryContext _context() {
  return LedgerJournalPostingRecoveryContext(
    transactionId: 'transaction_001',
    journalId: 'journal_001',
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(
      type: 'recovery',
      id: 'recover_ledger_journal_workflow_test',
    ),
    occurredAt: DateTime.utc(2026, 7, 17, 10),
    createdAt: DateTime.utc(2026, 7, 17, 10, 1),
    metadata: const {'consultationId': 'consultation_001'},
  );
}

final class _FakeFinancialRecoveryPipeline
    implements FinancialRecoveryPipeline {
  _FakeFinancialRecoveryPipeline({this.result, this.error})
    : assert(
        result != null || error != null,
        'The fake pipeline requires '
        'either a result or an error.',
      );

  final FinancialRecoveryStrategyResult? result;

  final Object? error;

  Object? receivedRequest;

  int callCount = 0;

  FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
  get typedReceivedRequest {
    return receivedRequest!
        as FinancialRecoveryStrategyRequest<
          LedgerJournalPostingRecoveryContext
        >;
  }

  @override
  Future<FinancialRecoveryStrategyResult> execute<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) async {
    callCount++;

    receivedRequest = request;

    if (error != null) {
      throw error!;
    }

    return result!;
  }
}
