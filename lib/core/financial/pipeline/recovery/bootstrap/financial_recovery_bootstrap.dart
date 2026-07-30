import '../../../ledger/journal/engine/'
    'ledger_journal_engine.dart';
import '../../../ledger/journal/posting/'
    'ledger_journal_factory.dart';
import '../../../ledger/journal/posting/'
    'ledger_journal_posting_bridge.dart';
import '../../../ledger/repositories/'
    'ledger_repository.dart';

import '../engine/'
    'default_financial_recovery_engine.dart';
import '../engine/'
    'financial_recovery_engine.dart';

import '../strategies/'
    'financial_recovery_strategy_registry.dart';
import '../strategies/'
    'recover_ledger_journal_posting_strategy.dart';
import '../strategies/'
    'recover_partial_settlement_strategy.dart';

/// Assembled financial recovery subsystem.
///
/// The result exposes:
/// - the strategy registry;
/// - the generic recovery engine;
/// - concrete strategies when their dependencies are available.
final class FinancialRecoveryBootstrapResult {
  const FinancialRecoveryBootstrapResult({
    required this.registry,
    required this.engine,
    required this.recoverLedgerJournalPostingStrategy,
    required this.recoverPartialSettlementStrategy,
  });

  final FinancialRecoveryStrategyRegistry registry;

  final FinancialRecoveryEngine engine;

  final RecoverLedgerJournalPostingStrategy?
  recoverLedgerJournalPostingStrategy;

  final RecoverPartialSettlementStrategy? recoverPartialSettlementStrategy;

  bool get hasLedgerJournalRecovery =>
      recoverLedgerJournalPostingStrategy != null;

  bool get hasPartialSettlementRecovery =>
      recoverPartialSettlementStrategy != null;
}

/// Composition root dedicated to the financial Recovery subsystem.
///
/// It contains no financial business logic. Its only responsibility is to:
///
/// 1. construct strategies whose dependencies are available;
/// 2. register those strategies once;
/// 3. create the generic recovery engine with that registry.
///
/// New recovery strategies should be assembled here rather than directly
/// inside FinancialModule.
final class FinancialRecoveryBootstrap {
  const FinancialRecoveryBootstrap._();

  static FinancialRecoveryBootstrapResult build({
    LedgerRepository? ledgerRepository,
    LedgerJournalEngine? journalEngine,
    LedgerJournalFactory? journalFactory,
    LedgerJournalPostingBridge? journalPostingBridge,
  }) {
    final registry = FinancialRecoveryStrategyRegistry();

    RecoverLedgerJournalPostingStrategy? ledgerJournalStrategy;

    RecoverPartialSettlementStrategy? partialSettlementStrategy;

    final hasJournalInfrastructure =
        ledgerRepository != null &&
        journalEngine != null &&
        journalFactory != null;

    if (hasJournalInfrastructure) {
      ledgerJournalStrategy = RecoverLedgerJournalPostingStrategy(
        ledgerRepository: ledgerRepository,
        journalEngine: journalEngine,
        journalFactory: journalFactory,
      );

      registry.register(ledgerJournalStrategy);

      /*
       * Partial-settlement recovery additionally requires the unified
       * posting bridge because missing components must create both:
       *
       * - a LedgerTransaction;
       * - its corresponding LedgerJournal.
       */
      if (journalPostingBridge != null) {
        partialSettlementStrategy = RecoverPartialSettlementStrategy(
          ledgerRepository: ledgerRepository,
          journalPostingBridge: journalPostingBridge,
          journalRecoveryStrategy: ledgerJournalStrategy,
        );

        registry.register(partialSettlementStrategy);
      }
    }

    final engine = DefaultFinancialRecoveryEngine(registry: registry);

    return FinancialRecoveryBootstrapResult(
      registry: registry,
      engine: engine,
      recoverLedgerJournalPostingStrategy: ledgerJournalStrategy,
      recoverPartialSettlementStrategy: partialSettlementStrategy,
    );
  }
}
