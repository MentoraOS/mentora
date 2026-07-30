import '../engine/'
    'financial_recovery_engine.dart';

import '../events/'
    'financial_recovery_pipeline_event_dispatcher.dart';

import '../orchestrator/'
    'financial_recovery_workflow_orchestrator.dart';

import '../pipeline/'
    'default_financial_recovery_pipeline.dart';
import '../pipeline/'
    'financial_recovery_pipeline.dart';

import '../registry/'
    'financial_recovery_workflow_registry.dart';

import '../strategies/'
    'financial_recovery_strategy_registry.dart';

import '../workflows/'
    'recover_ledger_journal_workflow.dart';
import '../workflows/'
    'recover_partial_settlement_workflow.dart';

import 'financial_recovery_bootstrap.dart';

/// Complete application-level Financial Recovery subsystem.
///
/// The module exposes every architectural layer through one composition root:
///
/// - strategy registry;
/// - generic recovery engine;
/// - observable recovery pipeline;
/// - workflow registry;
/// - concrete recovery workflows;
/// - workflow orchestrator.
///
/// It contains no recovery business logic.
final class FinancialRecoveryModule {
  const FinancialRecoveryModule._({
    required this.strategyRegistry,
    required this.recoveryEngine,
    required this.pipeline,
    required this.workflowRegistry,
    required this.recoverLedgerJournalWorkflow,
    required this.recoverPartialSettlementWorkflow,
    required this.orchestrator,
  });

  /// Registry containing the specialized recovery strategies.
  final FinancialRecoveryStrategyRegistry strategyRegistry;

  /// Generic engine responsible for selecting and executing strategies.
  final FinancialRecoveryEngine recoveryEngine;

  /// Observable execution boundary around the recovery engine.
  final FinancialRecoveryPipeline pipeline;

  /// Registry containing application-level recovery workflows.
  final FinancialRecoveryWorkflowRegistry workflowRegistry;

  /// Workflow responsible for Ledger Journal recovery requests.
  final RecoverLedgerJournalWorkflow recoverLedgerJournalWorkflow;

  /// Workflow responsible for partial-settlement recovery requests.
  final RecoverPartialSettlementWorkflow recoverPartialSettlementWorkflow;

  /// Unique application-level recovery entry point.
  final FinancialRecoveryWorkflowOrchestrator orchestrator;

  /// Initializes the application-level Recovery Module from an existing
  /// strategy registry and Recovery Engine.
  ///
  /// This factory does not reconstruct strategies. It reuses the instances
  /// already assembled by [FinancialRecoveryBootstrap].
  factory FinancialRecoveryModule.initialize({
    required FinancialRecoveryStrategyRegistry strategyRegistry,
    required FinancialRecoveryEngine recoveryEngine,
    FinancialRecoveryPipelineEventDispatcher? eventDispatcher,
    FinancialRecoveryPipelineClock? clock,
    FinancialRecoveryPipelineStopwatchFactory? stopwatchFactory,
  }) {
    return FinancialRecoveryModule._assemble(
      strategyRegistry: strategyRegistry,
      recoveryEngine: recoveryEngine,
      eventDispatcher: eventDispatcher,
      clock: clock,
      stopwatchFactory: stopwatchFactory,
    );
  }

  /// Convenience factory using the result produced by
  /// [FinancialRecoveryBootstrap.build].
  ///
  /// This guarantees that:
  ///
  /// - the exact bootstrap registry is reused;
  /// - the exact bootstrap engine is reused;
  /// - no strategy is reconstructed;
  /// - no duplicate registry is introduced.
  factory FinancialRecoveryModule.fromBootstrap({
    required FinancialRecoveryBootstrapResult bootstrap,
    FinancialRecoveryPipelineEventDispatcher? eventDispatcher,
    FinancialRecoveryPipelineClock? clock,
    FinancialRecoveryPipelineStopwatchFactory? stopwatchFactory,
  }) {
    return FinancialRecoveryModule._assemble(
      strategyRegistry: bootstrap.registry,
      recoveryEngine: bootstrap.engine,
      eventDispatcher: eventDispatcher,
      clock: clock,
      stopwatchFactory: stopwatchFactory,
    );
  }

  factory FinancialRecoveryModule._assemble({
    required FinancialRecoveryStrategyRegistry strategyRegistry,
    required FinancialRecoveryEngine recoveryEngine,
    FinancialRecoveryPipelineEventDispatcher? eventDispatcher,
    FinancialRecoveryPipelineClock? clock,
    FinancialRecoveryPipelineStopwatchFactory? stopwatchFactory,
  }) {
    /*
     * Recovery Pipeline.
     *
     * It wraps the generic Recovery Engine with lifecycle events,
     * observability and execution timing.
     */
    final pipeline = DefaultFinancialRecoveryPipeline(
      recoveryEngine: recoveryEngine,
      eventDispatcher: eventDispatcher,
      clock: clock,
      stopwatchFactory: stopwatchFactory,
    );

    /*
     * Application-level Recovery Workflows.
     *
     * Both workflows reuse the exact same pipeline instance.
     */
    final recoverLedgerJournalWorkflow = RecoverLedgerJournalWorkflow(
      pipeline: pipeline,
    );

    final recoverPartialSettlementWorkflow = RecoverPartialSettlementWorkflow(
      pipeline: pipeline,
    );

    /*
     * Workflow Registry.
     *
     * It owns application-level workflow discovery. It does not contain
     * strategy selection logic.
     */
    final workflowRegistry = FinancialRecoveryWorkflowRegistry();

    workflowRegistry.register(recoverLedgerJournalWorkflow);

    workflowRegistry.register(recoverPartialSettlementWorkflow);

    /*
     * Public Recovery Orchestrator.
     *
     * The rest of the application should normally enter the Recovery
     * subsystem through this orchestrator.
     */
    final orchestrator = FinancialRecoveryWorkflowOrchestrator(
      workflowRegistry: workflowRegistry,
    );

    return FinancialRecoveryModule._(
      strategyRegistry: strategyRegistry,
      recoveryEngine: recoveryEngine,
      pipeline: pipeline,
      workflowRegistry: workflowRegistry,
      recoverLedgerJournalWorkflow: recoverLedgerJournalWorkflow,
      recoverPartialSettlementWorkflow: recoverPartialSettlementWorkflow,
      orchestrator: orchestrator,
    );
  }
}
