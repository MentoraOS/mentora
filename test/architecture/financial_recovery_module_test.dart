import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/recovery/bootstrap/'
    'financial_recovery_bootstrap.dart';
import 'package:mentora/core/financial/pipeline/recovery/bootstrap/'
    'financial_recovery_module.dart';
import 'package:mentora/core/financial/pipeline/recovery/workflows/'
    'recover_ledger_journal_workflow.dart';
import 'package:mentora/core/financial/pipeline/recovery/workflows/'
    'recover_partial_settlement_workflow.dart';

void main() {
  group('FinancialRecoveryModule', () {
    late FinancialRecoveryBootstrapResult bootstrap;

    setUp(() {
      bootstrap = FinancialRecoveryBootstrap.build();
    });

    test('assembles the complete recovery application layer', () {
      final module = FinancialRecoveryModule.fromBootstrap(
        bootstrap: bootstrap,
      );

      expect(module.strategyRegistry, same(bootstrap.registry));
      expect(module.recoveryEngine, same(bootstrap.engine));
      expect(module.pipeline, isNotNull);
      expect(module.workflowRegistry.length, 2);
      expect(module.recoverLedgerJournalWorkflow, isNotNull);
      expect(module.recoverPartialSettlementWorkflow, isNotNull);
      expect(module.orchestrator, isNotNull);
    });

    test('reuses the exact bootstrap registry and recovery engine', () {
      final module = FinancialRecoveryModule.fromBootstrap(
        bootstrap: bootstrap,
      );

      expect(module.strategyRegistry, same(bootstrap.registry));
      expect(module.recoveryEngine, same(bootstrap.engine));
    });

    test('registers both official workflows by key and pipeline id', () {
      final module = FinancialRecoveryModule.fromBootstrap(
        bootstrap: bootstrap,
      );

      expect(
        module.workflowRegistry.containsWorkflowKey(
          RecoverLedgerJournalWorkflow.workflowKeyValue,
        ),
        isTrue,
      );
      expect(
        module.workflowRegistry.containsPipelineId(
          RecoverLedgerJournalWorkflow.supportedPipelineId,
        ),
        isTrue,
      );
      expect(
        module.workflowRegistry.containsWorkflowKey(
          RecoverPartialSettlementWorkflow.workflowKeyValue,
        ),
        isTrue,
      );
      expect(
        module.workflowRegistry.containsPipelineId(
          RecoverPartialSettlementWorkflow.supportedPipelineId,
        ),
        isTrue,
      );
    });

    test('both workflows share the module pipeline instance', () {
      final module = FinancialRecoveryModule.fromBootstrap(
        bootstrap: bootstrap,
      );

      expect(
        module.recoverLedgerJournalWorkflow.pipeline,
        same(module.pipeline),
      );
      expect(
        module.recoverPartialSettlementWorkflow.pipeline,
        same(module.pipeline),
      );
    });

    test('orchestrator uses the module workflow registry', () {
      final module = FinancialRecoveryModule.fromBootstrap(
        bootstrap: bootstrap,
      );

      expect(
        module.orchestrator.workflowRegistry,
        same(module.workflowRegistry),
      );
    });
  });
}
