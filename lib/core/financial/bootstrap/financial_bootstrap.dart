import 'package:mentora/core/financial/events/settlement/settlement_events.dart';

import '../domain/infrastructure/settlement/in_memory_settlement_repository.dart';
import '../domain/settlement/settlement_domain_event.dart';
import '../events/settlement/in_memory_settlement_event_dispatcher.dart';
import '../orchestrator/registry/financial_workflow_registry.dart';
import '../orchestrator/workflows/finalize_consultation_settlement/finalize_consultation_settlement_workflow.dart';
import '../orchestrator/workflows/finalize_consultation_settlement/pipeline/finalize_consultation_settlement_pipeline.dart';
import '../orchestrator/workflows/finalize_consultation_settlement/pipeline/settlement_failure_handler.dart';
import '../orchestrator/workflows/financial_posting/financial_posting_workflow.dart';
import '../orchestrator/workflows/settle_consultation/settle_consultation_workflow.dart';
import '../pipeline/default_financial_pipeline_engine.dart';
import '../runtime/engine/transactional_financial_runtime.dart';
import '../splits/engine/split_engine.dart';
import '../transaction/bootstrap/financial_transaction_module.dart';

class FinancialBootstrap {
  const FinancialBootstrap._();

  static FinancialWorkflowRegistry buildRegistry({
    required SettleConsultationWorkflow settlementWorkflow,
    required FinancialPostingWorkflow financialPostingWorkflow,
    required FinalizeSettlementExecutionIdFactory executionIdFactory,
    required FinalizeSettlementCorrelationIdFactory correlationIdFactory,
    FinalizeSettlementAttemptFactory? attemptFactory,
    FinalizeSettlementMetadataFactory? metadataFactory,
    DateTime Function()? runtimeClock,
    DateTime Function()? transactionClock,
    SettlementEventPublisher? eventPublisher,
  }) {
    final registry = FinancialWorkflowRegistry();

    // Exactly one Pipeline Engine.
    final pipelineEngine = DefaultFinancialPipelineEngine();

    // Exactly one transaction subsystem.
    final transactionModule = FinancialTransactionModule.inMemory(
      clock: transactionClock,
    );

    // The bootstrap uses the same transaction-aware runtime as
    // FinancialModule.
    final financialRuntime = TransactionalFinancialRuntime(
      pipelineEngine: pipelineEngine,
      transactionBoundary: transactionModule.boundary,
      clock: runtimeClock,
    );

    final settlementRepository = InMemorySettlementRepository();

    final settlementFailureHandler = SettlementFailureHandler(
      repository: settlementRepository,
    );

    // Production composition should inject the shared publisher explicitly.
    // The empty in-memory dispatcher preserves backward compatibility for
    // legacy bootstrap callers and tests that do not register handlers yet.
    final resolvedEventPublisher =
        eventPublisher ??
        SettlementEventPublisher(
          dispatcher: InMemorySettlementEventDispatcher(
            handlers: <SettlementEventHandler<SettlementDomainEvent>>[],
          ),
        );

    final settlementPipeline = FinalizeConsultationSettlementPipeline(
      settlementWorkflow: settlementWorkflow,
      splitEngine: const SplitEngine(),
      financialPostingWorkflow: financialPostingWorkflow,
      settlementRepository: settlementRepository,
      eventPublisher: resolvedEventPublisher,
    );

    final finalizeConsultationWorkflow = FinalizeConsultationSettlementWorkflow(
      financialRuntime: financialRuntime,
      pipeline: settlementPipeline,
      executionIdFactory: executionIdFactory,
      correlationIdFactory: correlationIdFactory,
      attemptFactory: attemptFactory,
      metadataFactory: metadataFactory,
      clock: runtimeClock,
      failureHandler: settlementFailureHandler,
    );

    registry.register(settlementWorkflow);
    registry.register(financialPostingWorkflow);
    registry.register(finalizeConsultationWorkflow);

    return registry;
  }
}
