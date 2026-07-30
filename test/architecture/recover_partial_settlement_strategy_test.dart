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

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';

import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_factory.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_bridge.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_request_factory.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_result.dart';

import 'package:mentora/core/financial/ledger/journal/repository/'
    'memory_ledger_journal_repository.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/'
    'ledger_journal_reversal_builder.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/service/'
    'ledger_journal_reversal_service.dart';

import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';

import 'package:mentora/core/financial/ledger/posting/builders/'
    'ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/engine/'
    'posting_engine.dart';
import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/templates/'
    'payment_posting_templates.dart';

import 'package:mentora/core/financial/ledger/repositories/'
    'memory_ledger_repository.dart';

import 'package:mentora/core/financial/ledger/validation/'
    'ledger_journal_validator.dart';

import 'package:mentora/core/financial/orchestrator/adapters/factories/'
    'settlement_component_posting_request_factory.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'partial_settlement_recovery_context.dart';

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

import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';
import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlement_id.dart';
import 'package:mentora/core/financial/domain/settlement/'
    'settlement_party.dart';
import 'package:mentora/core/financial/domain/shared/money/'
    'financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_category.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_instruction.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_line.dart';

void main() {
  group('RecoverPartialSettlementStrategy', () {
    late _RecoveryFixture fixture;
    late DateTime fixedNow;

    setUp(() {
      fixedNow = DateTime.utc(2026, 7, 16, 12);

      fixture = _RecoveryFixture.create(fixedNow: fixedNow);
    });

    test('supports only the partial settlement pipeline', () {
      expect(fixture.strategy.supports(fixture.request()), isTrue);

      expect(
        fixture.strategy.supports(
          fixture.request(pipelineId: 'another.pipeline'),
        ),
        isFalse,
      );
    });

    test(
      'ignores a settlement whose components are already complete',
      () async {
        await fixture.postAllComponentsFully();

        final result = await fixture.strategy.recover(fixture.request());

        expect(result, isA<FinancialRecoveryStrategySuccess>());

        expect(result.decision, FinancialRecoveryDecision.ignore);

        expect(
          result.metadata['recoveryAction'],
          'settlement_already_complete',
        );

        expect(result.metadata['expectedComponentCount'], 4);

        expect(result.metadata['completedComponentCount'], 4);

        expect(result.metadata['alreadyCompleteCount'], 4);

        expect(result.metadata['journalRecoveredCount'], 0);

        expect(result.metadata['componentPostedCount'], 0);

        expect(fixture.ledgerRepository.length, 4);

        expect(await fixture.journalRepository.count(), 4);
      },
    );

    test('posts only one missing settlement component', () async {
      await fixture.postComponentsFully(fixture.components.take(3));

      final missing = fixture.componentByCode('provider_fee');

      final result = await fixture.strategy.recover(fixture.request());

      expect(result, isA<FinancialRecoveryStrategySuccess>());

      expect(result.decision, FinancialRecoveryDecision.retry);

      expect(result.metadata['recoveryAction'], 'partial_settlement_recovered');

      expect(result.metadata['alreadyCompleteCount'], 3);

      expect(result.metadata['journalRecoveredCount'], 0);

      expect(result.metadata['componentPostedCount'], 1);

      final transactionId = fixture.transactionIdFor(missing);

      expect(
        await fixture.ledgerRepository.findTransactionById(transactionId),
        isNotNull,
      );

      expect(
        await fixture.journalRepository.findByOperationId(transactionId),
        isNotNull,
      );

      expect(fixture.ledgerRepository.length, 4);

      expect(await fixture.journalRepository.count(), 4);

      final componentMetadata = fixture.componentMetadataFor(
        result,
        missing.code,
      );

      expect(componentMetadata['action'], 'componentPosted');
    });

    test('posts exactly two missing settlement components', () async {
      await fixture.postComponentsFully(fixture.components.take(2));

      final result = await fixture.strategy.recover(fixture.request());

      expect(result.decision, FinancialRecoveryDecision.retry);

      expect(result.metadata['alreadyCompleteCount'], 2);

      expect(result.metadata['journalRecoveredCount'], 0);

      expect(result.metadata['componentPostedCount'], 2);

      expect(fixture.ledgerRepository.length, 4);

      expect(await fixture.journalRepository.count(), 4);
    });

    test('posts the complete settlement when no component exists', () async {
      expect(fixture.ledgerRepository.isEmpty, isTrue);

      expect(await fixture.journalRepository.count(), 0);

      final result = await fixture.strategy.recover(fixture.request());

      expect(result, isA<FinancialRecoveryStrategySuccess>());

      expect(result.decision, FinancialRecoveryDecision.retry);

      expect(result.metadata['alreadyCompleteCount'], 0);

      expect(result.metadata['journalRecoveredCount'], 0);

      expect(result.metadata['componentPostedCount'], 4);

      expect(fixture.ledgerRepository.length, 4);

      expect(await fixture.journalRepository.count(), 4);

      for (final component in fixture.components) {
        final transactionId = fixture.transactionIdFor(component);

        final transaction = await fixture.ledgerRepository.findTransactionById(
          transactionId,
        );

        final journal = await fixture.journalRepository.findByOperationId(
          transactionId,
        );

        expect(transaction, isNotNull);
        expect(journal, isNotNull);

        expect(transaction!.status, LedgerTransactionStatus.posted);

        expect(journal!.status, LedgerJournalStatus.posted);
      }
    });

    test(
      'recovers a missing journal without reposting its transaction',
      () async {
        final expert = fixture.componentByCode('expert_net');

        final existingTransaction = await fixture.postTransactionOnly(expert);

        await fixture.postComponentsFully(fixture.components.skip(1));

        expect(fixture.ledgerRepository.length, 4);

        expect(await fixture.journalRepository.count(), 3);

        final result = await fixture.strategy.recover(fixture.request());

        expect(result.decision, FinancialRecoveryDecision.retry);

        expect(result.metadata['alreadyCompleteCount'], 3);

        expect(result.metadata['journalRecoveredCount'], 1);

        expect(result.metadata['componentPostedCount'], 0);

        final storedTransaction = await fixture.ledgerRepository
            .findTransactionById(existingTransaction.id);

        expect(storedTransaction, same(existingTransaction));

        expect(fixture.ledgerRepository.length, 4);

        final recoveredJournal = await fixture.journalRepository
            .findByOperationId(existingTransaction.id);

        expect(recoveredJournal, isNotNull);

        expect(recoveredJournal!.status, LedgerJournalStatus.posted);

        expect(recoveredJournal.version, 2);

        final componentMetadata = fixture.componentMetadataFor(
          result,
          expert.code,
        );

        expect(componentMetadata['action'], 'journalRecovered');
      },
    );

    test('posts an existing pending component journal', () async {
      final expert = fixture.componentByCode('expert_net');

      final transaction = await fixture.postTransactionOnly(expert);

      final pendingJournal = await fixture.createPendingJournal(
        component: expert,
        transaction: transaction,
      );

      await fixture.postComponentsFully(fixture.components.skip(1));

      expect(pendingJournal.status, LedgerJournalStatus.pending);

      final result = await fixture.strategy.recover(fixture.request());

      expect(result.decision, FinancialRecoveryDecision.retry);

      expect(result.metadata['alreadyCompleteCount'], 3);

      expect(result.metadata['journalRecoveredCount'], 1);

      expect(result.metadata['componentPostedCount'], 0);

      final storedJournal = await fixture.journalRepository.findById(
        pendingJournal.journalId,
      );

      expect(storedJournal, isNotNull);

      expect(storedJournal!.status, LedgerJournalStatus.posted);

      expect(storedJournal.version, 2);

      expect(fixture.ledgerRepository.length, 4);

      expect(await fixture.journalRepository.count(), 4);
    });

    test(
      'requires manual review for an existing transaction conflict',
      () async {
        final expert = fixture.componentByCode('expert_net');

        final expectedRequest = fixture.postingRequestFor(expert);

        final conflictingRequest = PostingRequest(
          id: expectedRequest.id,
          referenceId: expectedRequest.referenceId,
          type: expectedRequest.type,
          consultationId: expectedRequest.consultationId,
          clientId: expectedRequest.clientId,
          expertId: expectedRequest.expertId,
          amountMinor: expectedRequest.amountMinor + 1,
          currency: expectedRequest.currency,
          createdAt: expectedRequest.createdAt,
          metadata: expectedRequest.metadata,
        );

        await fixture.postingEngine.post(conflictingRequest);

        final result = await fixture.strategy.recover(fixture.request());

        expect(result, isA<FinancialRecoveryStrategyFailure>());

        final failure = result as FinancialRecoveryStrategyFailure;

        expect(failure.decision, FinancialRecoveryDecision.manualReview);

        expect(
          failure.metadata['recoveryAction'],
          'partial_settlement_recovery_failed',
        );

        expect(failure.metadata['failedComponentCode'], expert.code);

        expect(
          failure.metadata['componentRecoveryAction'],
          'existing_transaction_conflict',
        );

        expect(failure.metadata['completedComponentCount'], 0);

        expect(fixture.ledgerRepository.length, 1);

        expect(await fixture.journalRepository.count(), 0);
      },
    );

    test('requires manual review for a reversed component journal', () async {
      final expert = fixture.componentByCode('expert_net');

      final posting = await fixture.postComponentFully(expert);

      final postedJournal = posting.journal;

      final reversedJournal = postedJournal.copyWith(
        status: LedgerJournalStatus.reversed,
        version: postedJournal.version + 1,
      );

      await fixture.journalRepository.update(
        journal: reversedJournal,
        expectedVersion: postedJournal.version,
      );

      final result = await fixture.strategy.recover(fixture.request());

      expect(result, isA<FinancialRecoveryStrategyFailure>());

      final failure = result as FinancialRecoveryStrategyFailure;

      expect(failure.decision, FinancialRecoveryDecision.manualReview);

      expect(failure.metadata['failedComponentCode'], expert.code);

      expect(
        failure.metadata['componentRecoveryAction'],
        'journal_recovery_failed',
      );

      expect(failure.metadata['completedComponentCount'], 0);

      expect(fixture.ledgerRepository.length, 1);

      expect(await fixture.journalRepository.count(), 1);

      final stored = await fixture.journalRepository.findById(
        reversedJournal.journalId,
      );

      expect(stored!.status, LedgerJournalStatus.reversed);
    });

    test(
      'converts a missing component posting error into manual review',
      () async {
        final invalidFixture = _RecoveryFixture.create(
          fixedNow: fixedNow,
          initializeCurrency: false,
        );

        final result = await invalidFixture.strategy.recover(
          invalidFixture.request(),
        );

        expect(result, isA<FinancialRecoveryStrategyFailure>());

        final failure = result as FinancialRecoveryStrategyFailure;

        expect(failure.decision, FinancialRecoveryDecision.manualReview);

        expect(
          failure.metadata['recoveryAction'],
          'partial_settlement_recovery_failed',
        );

        expect(
          failure.metadata['componentRecoveryAction'],
          'missing_component_posting_failed',
        );

        expect(failure.metadata['completedComponentCount'], 1);

        expect(invalidFixture.ledgerRepository.length, 1);

        expect(await invalidFixture.journalRepository.count(), 1);

        /*
 * The first component completed successfully before the next component
 * failed.
 */
        final completedComponent = invalidFixture.components.first;

        final completedTransactionId = invalidFixture.transactionIdFor(
          completedComponent,
        );

        final completedTransaction = await invalidFixture.ledgerRepository
            .findTransactionById(completedTransactionId);

        expect(completedTransaction, isNotNull);

        expect(completedTransaction!.status, LedgerTransactionStatus.posted);

        final completedJournal = await invalidFixture.journalRepository
            .findByOperationId(completedTransactionId);

        expect(completedJournal, isNotNull);

        expect(completedJournal!.status, LedgerJournalStatus.posted);

        expect(completedJournal.version, 2);

        /*
 * The second component is the one whose posting failed.
 */
        final failedComponent = invalidFixture.components[1];

        final failedTransactionId = invalidFixture.transactionIdFor(
          failedComponent,
        );

        final failedTransaction = await invalidFixture.ledgerRepository
            .findTransactionById(failedTransactionId);

        final failedJournal = await invalidFixture.journalRepository
            .findByOperationId(failedTransactionId);

        expect(failedTransaction, isNull);

        expect(failedJournal, isNull);
      },
    );

    test('remains idempotent across repeated recoveries', () async {
      final firstResult = await fixture.strategy.recover(fixture.request());

      final secondResult = await fixture.strategy.recover(
        fixture.request(recoveryId: 'partial_recovery_002', attempt: 2),
      );

      expect(firstResult.decision, FinancialRecoveryDecision.retry);

      expect(firstResult.metadata['componentPostedCount'], 4);

      expect(secondResult.decision, FinancialRecoveryDecision.ignore);

      expect(secondResult.metadata['alreadyCompleteCount'], 4);

      expect(secondResult.metadata['journalRecoveredCount'], 0);

      expect(secondResult.metadata['componentPostedCount'], 0);

      expect(fixture.ledgerRepository.length, 4);

      expect(await fixture.journalRepository.count(), 4);

      for (final component in fixture.components) {
        final transactionId = fixture.transactionIdFor(component);

        final journal = await fixture.journalRepository.findByOperationId(
          transactionId,
        );

        expect(journal, isNotNull);

        expect(journal!.status, LedgerJournalStatus.posted);

        expect(journal.version, 2);
      }
    });
  });
}

final class _RecoveryFixture {
  _RecoveryFixture._({
    required this.fixedNow,
    required this.accountRegistry,
    required this.chartOfAccounts,
    required this.ledgerRepository,
    required this.journalRepository,
    required this.postingEngine,
    required this.journalEngine,
    required this.journalFactory,
    required this.journalPostingBridge,
    required this.journalRecoveryStrategy,
    required this.strategy,
  });

  factory _RecoveryFixture.create({
    required DateTime fixedNow,
    bool initializeCurrency = true,
  }) {
    final accountRegistry = AccountRegistry();

    final chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

    if (initializeCurrency) {
      chartOfAccounts.initializeCurrency('XOF');
    }

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

    final journalRecoveryStrategy = RecoverLedgerJournalPostingStrategy(
      ledgerRepository: ledgerRepository,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      clock: () => fixedNow,
    );

    final strategy = RecoverPartialSettlementStrategy(
      ledgerRepository: ledgerRepository,
      journalPostingBridge: journalPostingBridge,
      journalRecoveryStrategy: journalRecoveryStrategy,
      clock: () => fixedNow,
    );

    return _RecoveryFixture._(
      fixedNow: fixedNow,
      accountRegistry: accountRegistry,
      chartOfAccounts: chartOfAccounts,
      ledgerRepository: ledgerRepository,
      journalRepository: journalRepository,
      postingEngine: postingEngine,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      journalPostingBridge: journalPostingBridge,
      journalRecoveryStrategy: journalRecoveryStrategy,
      strategy: strategy,
    );
  }

  final DateTime fixedNow;

  final AccountRegistry accountRegistry;
  final ChartOfAccounts chartOfAccounts;

  final MemoryLedgerRepository ledgerRepository;

  final MemoryLedgerJournalRepository journalRepository;

  final PostingEngine postingEngine;

  final LedgerJournalEngine journalEngine;

  final LedgerJournalFactory journalFactory;

  final LedgerJournalPostingBridge journalPostingBridge;

  final RecoverLedgerJournalPostingStrategy journalRecoveryStrategy;

  final RecoverPartialSettlementStrategy strategy;

  static const componentRequestFactory =
      SettlementComponentPostingRequestFactory();

  static const journalRequestFactory = LedgerJournalPostingRequestFactory();

  SettlementSplit get split => _split();

  List<SettlementSplitComponent> get components {
    return split.components;
  }

  SettlementSplitComponent componentByCode(String code) {
    final component = split.byCode(code);

    if (component == null) {
      throw StateError('Unknown test component "$code".');
    }

    return component;
  }

  SettlementPostingLine _postingLineFor(SettlementSplitComponent component) {
    return SettlementPostingLine(
      party: _partyFor(component.destination),
      category: _categoryFor(component.destination),
      amount: Money(
        minorUnits: component.amountMinor,
        currency: FinancialCurrency.xof,
      ),
      code: component.code,
      label: component.label,
    );
  }

  SettlementParty _partyFor(SplitDestination destination) {
    return switch (destination) {
      SplitDestination.expertWallet => SettlementParty.expert,
      SplitDestination.platformRevenue => SettlementParty.platform,
      SplitDestination.taxPayable => SettlementParty.tax,
      SplitDestination.paymentProviderFee => SettlementParty.paymentProvider,
    };
  }

  SettlementPostingCategory _categoryFor(SplitDestination destination) {
    return switch (destination) {
      SplitDestination.expertWallet => SettlementPostingCategory.expertRevenue,
      SplitDestination.platformRevenue =>
        SettlementPostingCategory.platformRevenue,
      SplitDestination.taxPayable => SettlementPostingCategory.taxPayable,
      SplitDestination.paymentProviderFee =>
        SettlementPostingCategory.paymentProviderFee,
    };
  }

  String transactionIdFor(SettlementSplitComponent component) {
    return componentRequestFactory.transactionIdFor(
      operationId: 'settlement_001',
      lineCode: component.code,
    );
  }

  PostingRequest postingRequestFor(SettlementSplitComponent component) {
    final line = _postingLineFor(component);

    final instruction = SettlementPostingInstruction(
      settlementId: SettlementId('settlement_001'),
      operationId: 'settlement_001',
      consultationId: 'consultation_001',
      escrowId: 'escrow_001',
      clientId: 'client_001',
      expertId: 'expert_001',
      lines: <SettlementPostingLine>[line],
      occurredAt: DateTime.utc(2026, 7, 16, 10),
      metadata: const <String, Object?>{
        'source': 'recover_partial_settlement_strategy_test',
      },
    );

    return componentRequestFactory.create(instruction: instruction, line: line);
  }

  Future<LedgerJournalPostingResult> postComponentFully(
    SettlementSplitComponent component,
  ) {
    final postingRequest = postingRequestFor(component);

    return journalPostingBridge.post(
      request: journalRequestFactory.create(postingRequest),
    );
  }

  Future<void> postComponentsFully(
    Iterable<SettlementSplitComponent> selectedComponents,
  ) async {
    for (final component in selectedComponents) {
      await postComponentFully(component);
    }
  }

  Future<void> postAllComponentsFully() {
    return postComponentsFully(components);
  }

  Future<LedgerTransaction> postTransactionOnly(
    SettlementSplitComponent component,
  ) {
    return postingEngine.post(postingRequestFor(component));
  }

  Future<LedgerJournal> createPendingJournal({
    required SettlementSplitComponent component,
    required LedgerTransaction transaction,
  }) async {
    final postingRequest = postingRequestFor(component);

    final journalRequest = journalRequestFactory.create(postingRequest);

    final pending = journalFactory.create(
      transaction: transaction,
      journalId: journalRequest.journalId,
      workflowKey: journalRequest.workflowKey,
      source: journalRequest.source,
      occurredAt: journalRequest.occurredAt,
      createdAt: journalRequest.createdAt,
      metadata: journalRequest.metadata,
    );

    await journalEngine.create(pending);

    return pending;
  }

  FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext> request({
    String recoveryId = 'partial_recovery_001',
    String pipelineId = RecoverPartialSettlementStrategy.supportedPipelineId,
    int attempt = 1,
  }) {
    return FinancialRecoveryStrategyRequest(
      recoveryId: recoveryId,
      pipelineId: pipelineId,
      context: PartialSettlementRecoveryContext(
        operationId: 'settlement_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        split: split,
        occurredAt: DateTime.utc(2026, 7, 16, 10),
        metadata: const {'source': 'partial_settlement_recovery_test'},
      ),
      error: StateError('Settlement posting was interrupted.'),
      stackTrace: StackTrace.current,
      attempt: attempt,
      requestedAt: DateTime.utc(2026, 7, 16, 11),
      metadata: const {'trigger': 'architecture_test'},
    );
  }

  Map<String, dynamic> componentMetadataFor(
    FinancialRecoveryStrategyResult result,
    String componentCode,
  ) {
    final rawComponents = result.metadata['components'];

    if (rawComponents is! List) {
      throw StateError('Recovery result contains no component list.');
    }

    for (final rawComponent in rawComponents) {
      final component = Map<String, dynamic>.from(rawComponent as Map);

      if (component['componentCode'] == componentCode.trim().toLowerCase()) {
        return component;
      }
    }

    throw StateError(
      'Recovery result contains no component '
      '"$componentCode".',
    );
  }
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
