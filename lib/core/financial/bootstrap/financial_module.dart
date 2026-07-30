import '../fees/engine/fee_engine.dart';
import '../fees/policies/consultation_fee_policy.dart';
import '../fees/policies/fee_policy_registry.dart';

import '../ledger/journal/engine/ledger_journal_engine.dart';
import '../ledger/journal/posting/ledger_journal_factory.dart';
import '../ledger/journal/posting/ledger_journal_posting_bridge.dart';
import '../ledger/journal/posting/'
    'ledger_journal_posting_request_factory.dart';
import '../ledger/journal/reporting/'
    'ledger_journal_reporting_engine.dart';

import '../ledger/repositories/ledger_repository.dart';

import '../orchestrator/adapters/'
    'settlement_posting_adapter.dart';
import '../orchestrator/financial_orchestrator.dart';
import '../orchestrator/registry/'
    'financial_workflow_registry.dart';

import '../orchestrator/workflows/financial_posting/'
    'financial_posting_workflow.dart';

import '../orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_workflow.dart';

import '../orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/'
    'finalize_consultation_settlement_pipeline.dart';

import '../orchestrator/workflows/settle_consultation/'
    'settle_consultation_workflow.dart';

import '../pipeline/default_financial_pipeline_engine.dart';
import '../pipeline/financial_pipeline_engine.dart';

import '../pipeline/events/'
    'financial_pipeline_event_dispatcher.dart';

import '../pipeline/metrics/'
    'financial_pipeline_metrics_listener.dart';
import '../pipeline/metrics/'
    'financial_pipeline_metrics_registry.dart';
import '../pipeline/metrics/'
    'financial_pipeline_step_metrics_listener.dart';
import '../pipeline/metrics/'
    'financial_pipeline_step_metrics_registry.dart';

import '../pipeline/recovery/bootstrap/'
    'financial_recovery_bootstrap.dart';
import '../pipeline/recovery/engine/'
    'financial_recovery_engine.dart';
import '../pipeline/recovery/strategies/'
    'financial_recovery_strategy_registry.dart';
import '../pipeline/recovery/strategies/'
    'recover_ledger_journal_posting_strategy.dart';
import '../pipeline/recovery/strategies/'
    'recover_partial_settlement_strategy.dart';

import '../runtime/engine/financial_runtime.dart';
import '../runtime/engine/'
    'transactional_financial_runtime.dart';

import '../splits/engine/split_engine.dart';

import '../transaction/bootstrap/'
    'financial_transaction_module.dart';
import '../domain/infrastructure/settlement/in_memory_settlement_repository.dart';
import '../orchestrator/workflows/finalize_consultation_settlement/pipeline/settlement_failure_handler.dart';
import 'package:mentora/core/financial/infrastructure/events/settlement/in_memory_settlement_event_dispatcher.dart';
import 'package:mentora/core/financial/events/settlement/settlement_event_publisher.dart';

class FinancialModule {
  const FinancialModule._({
    required this.feePolicyRegistry,
    required this.feeEngine,
    required this.splitEngine,
    required this.settlementPostingAdapter,
    required this.settleConsultationWorkflow,
    required this.financialPostingWorkflow,
    required this.finalizeConsultationSettlementWorkflow,
    required this.workflowRegistry,
    required this.orchestrator,
    required this.pipelineEngine,
    required this.transactionModule,
    required this.financialRuntime,
    required this.pipelineMetricsRegistry,
    required this.pipelineStepMetricsRegistry,
    required this.reportingEngine,
    required this.journalPostingBridge,
    required this.recoveryStrategyRegistry,
    required this.recoveryEngine,
    required this.recoverLedgerJournalPostingStrategy,
    required this.recoverPartialSettlementStrategy,
  });

  final FeePolicyRegistry feePolicyRegistry;
  final FeeEngine feeEngine;

  final SplitEngine splitEngine;

  final SettlementPostingAdapter settlementPostingAdapter;

  final SettleConsultationWorkflow settleConsultationWorkflow;

  final FinancialPostingWorkflow financialPostingWorkflow;

  final FinalizeConsultationSettlementWorkflow
  finalizeConsultationSettlementWorkflow;

  final FinancialWorkflowRegistry workflowRegistry;
  final FinancialOrchestrator orchestrator;

  /// Exact Pipeline Engine used by the Runtime.
  final FinancialPipelineEngine pipelineEngine;

  /// Exact transaction subsystem used by the Runtime.
  final FinancialTransactionModule transactionModule;

  /// Official transaction-aware financial Runtime.
  final FinancialRuntime financialRuntime;

  final FinancialPipelineMetricsRegistry pipelineMetricsRegistry;

  final FinancialPipelineStepMetricsRegistry pipelineStepMetricsRegistry;

  final RecoverPartialSettlementStrategy? recoverPartialSettlementStrategy;

  /// Unique public entry point for Ledger reporting.
  final LedgerJournalReportingEngine reportingEngine;

  /// Unified production posting entry point.
  final LedgerJournalPostingBridge? journalPostingBridge;

  /// Registry containing specialized recovery strategies.
  final FinancialRecoveryStrategyRegistry recoveryStrategyRegistry;

  /// Generic recovery execution engine.
  final FinancialRecoveryEngine recoveryEngine;

  /// Concrete Ledger Journal repair strategy.
  final RecoverLedgerJournalPostingStrategy?
  recoverLedgerJournalPostingStrategy;

  /// Production initialization.
  factory FinancialModule.initialize({
    required LedgerJournalPostingBridge journalPostingBridge,
    required LedgerJournalReportingEngine reportingEngine,
    required LedgerRepository ledgerRepository,
    required LedgerJournalEngine journalEngine,
    required LedgerJournalFactory journalFactory,
    required FinalizeSettlementExecutionIdFactory executionIdFactory,
    required FinalizeSettlementCorrelationIdFactory correlationIdFactory,
    FinalizeSettlementAttemptFactory? attemptFactory,
    FinalizeSettlementMetadataFactory? metadataFactory,
    LedgerJournalPostingRequestFactory journalPostingRequestFactory =
        const LedgerJournalPostingRequestFactory(),
    DateTime Function()? runtimeClock,
    DateTime Function()? transactionClock,
  }) {
    return FinancialModule._assemble(
      post: (request) async {
        final journalRequest = journalPostingRequestFactory.create(request);

        final result = await journalPostingBridge.post(request: journalRequest);

        return result.transaction;
      },
      reportingEngine: reportingEngine,
      journalPostingBridge: journalPostingBridge,
      ledgerRepository: ledgerRepository,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      executionIdFactory: executionIdFactory,
      correlationIdFactory: correlationIdFactory,
      attemptFactory: attemptFactory,
      metadataFactory: metadataFactory,
      runtimeClock: runtimeClock,
      transactionClock: transactionClock,
    );
  }

  /// Compatibility initialization for isolated unit tests.
  factory FinancialModule.initializeWithPost({
    required LedgerPostFunction post,
    required LedgerJournalReportingEngine reportingEngine,
    required FinalizeSettlementExecutionIdFactory executionIdFactory,
    required FinalizeSettlementCorrelationIdFactory correlationIdFactory,
    FinalizeSettlementAttemptFactory? attemptFactory,
    FinalizeSettlementMetadataFactory? metadataFactory,
    LedgerJournalPostingBridge? journalPostingBridge,
    LedgerRepository? ledgerRepository,
    LedgerJournalEngine? journalEngine,
    LedgerJournalFactory? journalFactory,
    DateTime Function()? runtimeClock,
    DateTime Function()? transactionClock,
  }) {
    return FinancialModule._assemble(
      post: post,
      reportingEngine: reportingEngine,
      journalPostingBridge: journalPostingBridge,
      ledgerRepository: ledgerRepository,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      executionIdFactory: executionIdFactory,
      correlationIdFactory: correlationIdFactory,
      attemptFactory: attemptFactory,
      metadataFactory: metadataFactory,
      runtimeClock: runtimeClock,
      transactionClock: transactionClock,
    );
  }

  factory FinancialModule._assemble({
    required LedgerPostFunction post,
    required LedgerJournalReportingEngine reportingEngine,
    required FinalizeSettlementExecutionIdFactory executionIdFactory,
    required FinalizeSettlementCorrelationIdFactory correlationIdFactory,
    FinalizeSettlementAttemptFactory? attemptFactory,
    FinalizeSettlementMetadataFactory? metadataFactory,
    LedgerJournalPostingBridge? journalPostingBridge,
    LedgerRepository? ledgerRepository,
    LedgerJournalEngine? journalEngine,
    LedgerJournalFactory? journalFactory,
    DateTime Function()? runtimeClock,
    DateTime Function()? transactionClock,
  }) {
    final feePolicyRegistry = FeePolicyRegistry()
      ..register(const ConsultationFeePolicy());

    final feeEngine = FeeEngine(registry: feePolicyRegistry);

    const splitEngine = SplitEngine();

    final settlementPostingAdapter = SettlementPostingAdapter(post: post);

    final settleConsultationWorkflow = SettleConsultationWorkflow(
      feeEngine: feeEngine,
    );

    final financialPostingWorkflow = FinancialPostingWorkflow(
      postingPort: settlementPostingAdapter,
    );

    /*
     * Pipeline metrics infrastructure.
     *
     * These exact registry instances are injected into the listeners
     * and exposed by this module.
     */
    final pipelineMetricsRegistry = FinancialPipelineMetricsRegistry();

    final pipelineStepMetricsRegistry = FinancialPipelineStepMetricsRegistry();

    final pipelineMetricsListener = FinancialPipelineMetricsListener(
      registry: pipelineMetricsRegistry,
    );

    final pipelineStepMetricsListener = FinancialPipelineStepMetricsListener(
      registry: pipelineStepMetricsRegistry,
    );

    final eventDispatcher = FinancialPipelineEventDispatcher(
      listeners: [
        pipelineMetricsListener.call,
        pipelineStepMetricsListener.call,
      ],
    );

    /*
     * A single Pipeline Engine is created.
     *
     * It is reused by the transaction-aware Runtime and never
     * reconstructed later in this composition root.
     */
    final pipelineEngine = DefaultFinancialPipelineEngine(
      eventDispatcher: eventDispatcher,
    );

    /*
     * A single transaction subsystem is created.
     */
    final transactionModule = FinancialTransactionModule.inMemory(
      clock: transactionClock,
    );

    /*
     * Official Runtime used by real financial workflows.
     */
    final financialRuntime = TransactionalFinancialRuntime(
      pipelineEngine: pipelineEngine,
      transactionBoundary: transactionModule.boundary,
      clock: runtimeClock,
    );

    final settlementRepository = InMemorySettlementRepository();

    final settlementFailureHandler = SettlementFailureHandler(
      repository: settlementRepository,
    );

    final settlementEventDispatcher = InMemorySettlementEventDispatcher();

    final settlementEventPublisher = SettlementEventPublisher(
      dispatcher: settlementEventDispatcher,
    );

    final settlementPipeline = FinalizeConsultationSettlementPipeline(
      settlementWorkflow: settleConsultationWorkflow,
      splitEngine: splitEngine,
      financialPostingWorkflow: financialPostingWorkflow,
      settlementRepository: settlementRepository,
      eventPublisher: settlementEventPublisher,
    );

    final finalizeWorkflow = FinalizeConsultationSettlementWorkflow(
      financialRuntime: financialRuntime,
      pipeline: settlementPipeline,
      executionIdFactory: executionIdFactory,
      correlationIdFactory: correlationIdFactory,
      attemptFactory: attemptFactory,
      metadataFactory: metadataFactory,
      clock: runtimeClock,
      failureHandler: settlementFailureHandler,
    );

    final workflowRegistry = FinancialWorkflowRegistry();

    workflowRegistry.register(finalizeWorkflow);

    workflowRegistry.register(settleConsultationWorkflow);

    workflowRegistry.register(financialPostingWorkflow);

    final orchestrator = FinancialOrchestrator(
      feeEngine: feeEngine,
      workflowRegistry: workflowRegistry,
    );

    final recovery = FinancialRecoveryBootstrap.build(
      ledgerRepository: ledgerRepository,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      journalPostingBridge: journalPostingBridge,
    );

    return FinancialModule._(
      feePolicyRegistry: feePolicyRegistry,
      feeEngine: feeEngine,
      splitEngine: splitEngine,
      settlementPostingAdapter: settlementPostingAdapter,
      settleConsultationWorkflow: settleConsultationWorkflow,
      financialPostingWorkflow: financialPostingWorkflow,
      finalizeConsultationSettlementWorkflow: finalizeWorkflow,
      workflowRegistry: workflowRegistry,
      orchestrator: orchestrator,
      pipelineEngine: pipelineEngine,
      transactionModule: transactionModule,
      financialRuntime: financialRuntime,
      pipelineMetricsRegistry: pipelineMetricsRegistry,
      pipelineStepMetricsRegistry: pipelineStepMetricsRegistry,
      reportingEngine: reportingEngine,
      journalPostingBridge: journalPostingBridge,
      recoveryStrategyRegistry: recovery.registry,
      recoveryEngine: recovery.engine,
      recoverLedgerJournalPostingStrategy:
          recovery.recoverLedgerJournalPostingStrategy,
      recoverPartialSettlementStrategy:
          recovery.recoverPartialSettlementStrategy,
    );
  }
}
