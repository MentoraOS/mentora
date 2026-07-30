import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/balance/'
    'balance_engine.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';

import 'package:mentora/core/financial/ledger/engine/'
    'ledger_engine.dart';

import 'package:mentora/core/financial/ledger/journal/engine/'
    'ledger_journal_engine.dart';

import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_factory.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_bridge.dart';

import 'package:mentora/core/financial/ledger/journal/repository/'
    'memory_ledger_journal_repository.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/'
    'ledger_journal_reversal_builder.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/service/'
    'ledger_journal_reversal_service.dart';

import 'package:mentora/core/financial/ledger/posting/builders/'
    'ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/engine/'
    'posting_engine.dart';
import 'package:mentora/core/financial/ledger/posting/templates/'
    'payment_posting_templates.dart';

import 'package:mentora/core/financial/ledger/repositories/'
    'memory_ledger_repository.dart';

import 'package:mentora/core/financial/ledger/validation/'
    'ledger_journal_validator.dart';

import 'package:mentora/core/financial/pipeline/recovery/bootstrap/'
    'financial_recovery_bootstrap.dart';

import 'package:mentora/core/financial/pipeline/recovery/engine/'
    'default_financial_recovery_engine.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'recover_ledger_journal_posting_strategy.dart';

void main() {
  group('FinancialRecoveryBootstrap', () {
    test('always creates the registry and generic recovery engine', () {
      final recovery = FinancialRecoveryBootstrap.build();

      expect(recovery.registry, isNotNull);

      expect(recovery.engine, isA<DefaultFinancialRecoveryEngine>());

      expect(recovery.recoverLedgerJournalPostingStrategy, isNull);

      expect(recovery.recoverPartialSettlementStrategy, isNull);

      expect(recovery.hasLedgerJournalRecovery, isFalse);

      expect(recovery.hasPartialSettlementRecovery, isFalse);
    });

    test('assembles Ledger Journal recovery when its dependencies exist', () {
      final fixture = _RecoveryBootstrapFixture.create();

      final recovery = FinancialRecoveryBootstrap.build(
        ledgerRepository: fixture.ledgerRepository,
        journalEngine: fixture.journalEngine,
        journalFactory: fixture.journalFactory,
      );

      expect(recovery.engine, isA<DefaultFinancialRecoveryEngine>());

      expect(
        recovery.recoverLedgerJournalPostingStrategy,
        isA<RecoverLedgerJournalPostingStrategy>(),
      );

      expect(recovery.recoverPartialSettlementStrategy, isNull);

      expect(recovery.hasLedgerJournalRecovery, isTrue);

      expect(recovery.hasPartialSettlementRecovery, isFalse);
    });

    test(
      'does not assemble Ledger Journal recovery with incomplete dependencies',
      () {
        final fixture = _RecoveryBootstrapFixture.create();

        final withoutJournalEngine = FinancialRecoveryBootstrap.build(
          ledgerRepository: fixture.ledgerRepository,
          journalFactory: fixture.journalFactory,
        );

        final withoutJournalFactory = FinancialRecoveryBootstrap.build(
          ledgerRepository: fixture.ledgerRepository,
          journalEngine: fixture.journalEngine,
        );

        final withoutLedgerRepository = FinancialRecoveryBootstrap.build(
          journalEngine: fixture.journalEngine,
          journalFactory: fixture.journalFactory,
        );

        expect(
          withoutJournalEngine.recoverLedgerJournalPostingStrategy,
          isNull,
        );

        expect(
          withoutJournalFactory.recoverLedgerJournalPostingStrategy,
          isNull,
        );

        expect(
          withoutLedgerRepository.recoverLedgerJournalPostingStrategy,
          isNull,
        );

        expect(withoutJournalEngine.recoverPartialSettlementStrategy, isNull);

        expect(withoutJournalFactory.recoverPartialSettlementStrategy, isNull);

        expect(
          withoutLedgerRepository.recoverPartialSettlementStrategy,
          isNull,
        );
      },
    );

    test(
      'assembles both recovery strategies with the complete infrastructure',
      () {
        final fixture = _RecoveryBootstrapFixture.create();

        final recovery = FinancialRecoveryBootstrap.build(
          ledgerRepository: fixture.ledgerRepository,
          journalEngine: fixture.journalEngine,
          journalFactory: fixture.journalFactory,
          journalPostingBridge: fixture.journalPostingBridge,
        );

        final journalStrategy = recovery.recoverLedgerJournalPostingStrategy;

        final partialSettlementStrategy =
            recovery.recoverPartialSettlementStrategy;

        expect(journalStrategy, isNotNull);

        expect(partialSettlementStrategy, isNotNull);

        expect(recovery.hasLedgerJournalRecovery, isTrue);

        expect(recovery.hasPartialSettlementRecovery, isTrue);

        expect(
          partialSettlementStrategy!.ledgerRepository,
          same(fixture.ledgerRepository),
        );

        expect(
          partialSettlementStrategy.journalPostingBridge,
          same(fixture.journalPostingBridge),
        );

        /*
         * The partial-settlement strategy must reuse the exact same
         * Ledger Journal strategy instance registered by the bootstrap.
         *
         * Creating a replacement instance here would break the composition
         * root's single-instance guarantee.
         */
        expect(
          partialSettlementStrategy.journalRecoveryStrategy,
          same(journalStrategy),
        );
      },
    );

    test(
      'does not assemble partial settlement recovery without the posting bridge',
      () {
        final fixture = _RecoveryBootstrapFixture.create();

        final recovery = FinancialRecoveryBootstrap.build(
          ledgerRepository: fixture.ledgerRepository,
          journalEngine: fixture.journalEngine,
          journalFactory: fixture.journalFactory,
        );

        expect(recovery.recoverLedgerJournalPostingStrategy, isNotNull);

        expect(recovery.recoverPartialSettlementStrategy, isNull);

        expect(recovery.hasLedgerJournalRecovery, isTrue);

        expect(recovery.hasPartialSettlementRecovery, isFalse);
      },
    );

    test('creates isolated recovery subsystems for separate builds', () {
      final fixture = _RecoveryBootstrapFixture.create();

      final first = FinancialRecoveryBootstrap.build(
        ledgerRepository: fixture.ledgerRepository,
        journalEngine: fixture.journalEngine,
        journalFactory: fixture.journalFactory,
        journalPostingBridge: fixture.journalPostingBridge,
      );

      final second = FinancialRecoveryBootstrap.build(
        ledgerRepository: fixture.ledgerRepository,
        journalEngine: fixture.journalEngine,
        journalFactory: fixture.journalFactory,
        journalPostingBridge: fixture.journalPostingBridge,
      );

      expect(identical(first, second), isFalse);

      expect(identical(first.registry, second.registry), isFalse);

      expect(identical(first.engine, second.engine), isFalse);

      expect(
        identical(
          first.recoverLedgerJournalPostingStrategy,
          second.recoverLedgerJournalPostingStrategy,
        ),
        isFalse,
      );

      expect(
        identical(
          first.recoverPartialSettlementStrategy,
          second.recoverPartialSettlementStrategy,
        ),
        isFalse,
      );
    });
  });
}

final class _RecoveryBootstrapFixture {
  const _RecoveryBootstrapFixture._({
    required this.ledgerRepository,
    required this.journalEngine,
    required this.journalFactory,
    required this.journalPostingBridge,
  });

  factory _RecoveryBootstrapFixture.create() {
    final accountRegistry = AccountRegistry();

    final chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

    chartOfAccounts.initializeCurrency('XOF');

    final ledgerRepository = MemoryLedgerRepository();

    final journalRepository = MemoryLedgerJournalRepository();

    final paymentTemplates = PaymentPostingTemplates(
      chartOfAccounts: chartOfAccounts,
    );

    final ledgerEngine = LedgerEngine(
      repository: ledgerRepository,
      chartOfAccounts: chartOfAccounts,
    );

    final balanceEngine = BalanceEngine(
      repository: ledgerRepository,
      chartOfAccounts: chartOfAccounts,
    );

    final postingEngine = PostingEngine(
      builder: LedgerPostingBuilder(paymentTemplates: paymentTemplates),
      ledgerEngine: ledgerEngine,
      balanceEngine: balanceEngine,
    );

    final journalValidator = LedgerJournalValidator(
      chartOfAccounts: chartOfAccounts,
      repository: journalRepository,
    );

    final reversalService = LedgerJournalReversalService(
      repository: journalRepository,
      validator: journalValidator,
      builder: const LedgerJournalReversalBuilder(),
    );

    final journalEngine = LedgerJournalEngine(
      repository: journalRepository,
      validator: journalValidator,
      reversalService: reversalService,
    );

    const journalFactory = LedgerJournalFactory();

    final journalPostingBridge = LedgerJournalPostingBridge(
      postingEngine: postingEngine,
      journalFactory: journalFactory,
      journalEngine: journalEngine,
    );

    return _RecoveryBootstrapFixture._(
      ledgerRepository: ledgerRepository,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      journalPostingBridge: journalPostingBridge,
    );
  }

  final MemoryLedgerRepository ledgerRepository;

  final LedgerJournalEngine journalEngine;

  final LedgerJournalFactory journalFactory;

  final LedgerJournalPostingBridge journalPostingBridge;
}
