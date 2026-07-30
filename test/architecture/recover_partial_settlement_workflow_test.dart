import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'partial_settlement_recovery_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/pipeline/'
    'financial_recovery_pipeline.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_partial_settlement_strategy.dart';

import 'package:mentora/core/financial/pipeline/recovery/workflows/'
    'recover_partial_settlement_workflow.dart';

import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';
import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('RecoverPartialSettlementWorkflow', () {
    late _FakeFinancialRecoveryPipeline pipeline;

    late RecoverPartialSettlementWorkflow workflow;

    late FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
    request;

    late FinancialRecoveryStrategySuccess expectedResult;

    setUp(() {
      expectedResult = FinancialRecoveryStrategySuccess(
        recoveryId: 'partial_recovery_001',
        strategyKey: 'recover.partial.settlement',
        decision: FinancialRecoveryDecision.ignore,
        attempt: 1,
        duration: const Duration(milliseconds: 18),
        completedAt: DateTime.utc(2026, 7, 17, 12),
        metadata: const {'source': 'recover_partial_settlement_workflow_test'},
      );

      pipeline = _FakeFinancialRecoveryPipeline(result: expectedResult);

      workflow = RecoverPartialSettlementWorkflow(pipeline: pipeline);

      request =
          FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>(
            recoveryId: 'partial_recovery_001',
            pipelineId: RecoverPartialSettlementStrategy.supportedPipelineId,
            context: _context(),
            error: StateError('Settlement posting was interrupted.'),
            stackTrace: StackTrace.current,
            attempt: 1,
            requestedAt: DateTime.utc(2026, 7, 17, 11),
            metadata: const {'trigger': 'architecture_test'},
          );
    });

    test('exposes a stable workflow key', () {
      expect(
        workflow.workflowKey,
        RecoverPartialSettlementWorkflow.workflowKeyValue,
      );

      expect(workflow.workflowKey, 'recover.partial.settlement.workflow');
    });

    test('reuses the strategy pipeline identifier', () {
      expect(
        workflow.pipelineId,
        RecoverPartialSettlementStrategy.supportedPipelineId,
      );

      expect(
        RecoverPartialSettlementWorkflow.supportedPipelineId,
        RecoverPartialSettlementStrategy.supportedPipelineId,
      );
    });

    test('supports requests for the partial settlement recovery pipeline', () {
      expect(workflow.supports(request), isTrue);
    });

    test(
      'normalizes the request pipeline identifier when checking support',
      () {
        final paddedRequest =
            FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>(
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
          FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>(
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

      expect(pipeline.typedReceivedRequest.context, same(request.context));
    });

    test(
      'returns the exact result produced by the recovery pipeline',
      () async {
        final result = await workflow.execute(request: request);

        expect(result, same(expectedResult));

        expect(result.decision, FinancialRecoveryDecision.ignore);

        expect(
          result.metadata['source'],
          'recover_partial_settlement_workflow_test',
        );
      },
    );

    test('does not execute the recovery pipeline more than once', () async {
      await workflow.execute(request: request);

      expect(pipeline.callCount, 1);
    });

    test('propagates recovery pipeline errors unchanged', () async {
      final expectedError = StateError(
        'Partial settlement recovery '
        'pipeline crashed.',
      );

      final failingPipeline = _FakeFinancialRecoveryPipeline(
        error: expectedError,
      );

      final failingWorkflow = RecoverPartialSettlementWorkflow(
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

    test('does not transform the partial settlement context', () async {
      await workflow.execute(request: request);

      final receivedContext = pipeline.typedReceivedRequest.context;

      expect(receivedContext, same(request.context));

      expect(receivedContext.operationId, 'settlement_001');

      expect(receivedContext.consultationId, 'consultation_001');

      expect(receivedContext.escrowId, 'escrow_001');

      expect(receivedContext.clientId, 'client_001');

      expect(receivedContext.expertId, 'expert_001');

      expect(receivedContext.split, same(request.context.split));

      expect(receivedContext.split.components, hasLength(4));

      expect(receivedContext.split.isBalanced, isTrue);
    });
  });
}

PartialSettlementRecoveryContext _context() {
  return PartialSettlementRecoveryContext(
    operationId: 'settlement_001',
    consultationId: 'consultation_001',
    escrowId: 'escrow_001',
    clientId: 'client_001',
    expertId: 'expert_001',
    split: _split(),
    occurredAt: DateTime.utc(2026, 7, 17, 10),
    metadata: const {'source': 'recover_partial_settlement_workflow_test'},
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

  FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
  get typedReceivedRequest {
    return receivedRequest!
        as FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>;
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
