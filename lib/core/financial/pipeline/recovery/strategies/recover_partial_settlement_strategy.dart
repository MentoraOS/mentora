import '../../../ledger/journal/posting/'
    'ledger_journal_posting_bridge.dart';
import '../../../ledger/journal/posting/'
    'ledger_journal_posting_request_factory.dart';

import '../../../ledger/models/'
    'ledger_transaction.dart';
import '../../../ledger/models/'
    'ledger_transaction_status.dart';

import '../../../ledger/repositories/'
    'ledger_repository.dart';

import '../../../orchestrator/adapters/factories/'
    'settlement_component_posting_request_factory.dart';

import '../../../splits/models/'
    'settlement_split_component.dart';

import '../contexts/'
    'ledger_journal_posting_recovery_context.dart';
import '../contexts/'
    'partial_settlement_recovery_context.dart';

import '../results/'
    'partial_settlement_recovery_component_result.dart';

import 'financial_recovery_decision.dart';
import 'financial_recovery_strategy.dart';
import 'financial_recovery_strategy_request.dart';
import 'financial_recovery_strategy_result.dart';
import 'recover_ledger_journal_posting_strategy.dart';
import '../../../ledger/journal/models/'
    'ledger_journal_source.dart';

import '../../../ledger/posting/models/'
    'posting_request.dart';

import '../../../domain/settlement/settlement_id.dart';
import '../../../domain/settlement/settlement_party.dart';
import '../../../domain/shared/money/financial_currency.dart';
import '../../../domain/shared/money/money.dart';

import '../../../orchestrator/workflows/financial_posting/models/'
    'settlement_posting_category.dart';
import '../../../orchestrator/workflows/financial_posting/models/'
    'settlement_posting_instruction.dart';
import '../../../orchestrator/workflows/financial_posting/models/'
    'settlement_posting_line.dart';

import '../../../splits/models/split_destination.dart';

typedef PartialSettlementRecoveryClock = DateTime Function();

// Repairs a settlement whose accounting components were only partially
// posted.
//
// For every expected split component, this strategy:
//
// 1. derives its deterministic transaction identifier;
// 2. checks whether the LedgerTransaction already exists;
// 3. repairs its Journal when the transaction exists;
// 4. posts only the component when the transaction is absent;
// 5. never reposts an already existing transaction.
//
// This preserves settlement idempotence and prevents double payments.
final class RecoverPartialSettlementStrategy
    implements FinancialRecoveryStrategy<PartialSettlementRecoveryContext> {
  RecoverPartialSettlementStrategy({
    required this.ledgerRepository,
    required this.journalPostingBridge,
    required this.journalRecoveryStrategy,
    this.componentRequestFactory =
        const SettlementComponentPostingRequestFactory(),
    this.journalRequestFactory = const LedgerJournalPostingRequestFactory(),
    PartialSettlementRecoveryClock? clock,
  }) : clock = clock ?? DateTime.now;

  static const String strategyKey = 'settlement.partial.recovery';

  static const String supportedPipelineId = 'settlement.partial.posting';

  final LedgerRepository ledgerRepository;

  final LedgerJournalPostingBridge journalPostingBridge;

  final RecoverLedgerJournalPostingStrategy journalRecoveryStrategy;

  final SettlementComponentPostingRequestFactory componentRequestFactory;

  final LedgerJournalPostingRequestFactory journalRequestFactory;

  final PartialSettlementRecoveryClock clock;

  @override
  String get key => strategyKey;

  @override
  bool supports(
    FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext> request,
  ) {
    return request.pipelineId.trim() == supportedPipelineId;
  }

  @override
  Future<FinancialRecoveryStrategyResult> recover(
    FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext> request,
  ) async {
    final stopwatch = Stopwatch()..start();

    final completedComponents = <PartialSettlementRecoveryComponentResult>[];

    for (final component in request.context.split.components) {
      final result = await _recoverComponent(
        request: request,
        component: component,
      );

      if (result is _PartialSettlementComponentFailure) {
        stopwatch.stop();

        return FinancialRecoveryStrategyFailure(
          recoveryId: request.recoveryId,
          strategyKey: strategyKey,
          decision: result.decision,
          attempt: request.attempt,
          duration: stopwatch.elapsed,
          completedAt: clock().toUtc(),
          error: result.error,
          stackTrace: result.stackTrace,
          metadata: {
            ...request.metadata,
            'pipelineId': request.pipelineId,
            'recoveryAction': 'partial_settlement_recovery_failed',
            'operationId': request.context.operationId,
            'failedComponentCode': component.code,
            'failedTransactionId': request.context
                .transactionIdForComponentCode(component.code),
            'expectedComponentCount': request.context.componentCount,
            'completedComponentCount': completedComponents.length,
            'completedComponents': completedComponents
                .map((item) => item.toMetadata())
                .toList(growable: false),
            ...result.metadata,
          },
        );
      }

      completedComponents.add(
        (result as _PartialSettlementComponentSuccess).result,
      );
    }

    stopwatch.stop();

    final alreadyCompleteCount = completedComponents
        .where((result) => result.wasAlreadyComplete)
        .length;

    final journalRecoveredCount = completedComponents
        .where((result) => result.wasJournalRecovered)
        .length;

    final componentPostedCount = completedComponents
        .where((result) => result.wasComponentPosted)
        .length;

    final performedRecovery =
        journalRecoveredCount > 0 || componentPostedCount > 0;

    return FinancialRecoveryStrategySuccess(
      recoveryId: request.recoveryId,
      strategyKey: strategyKey,
      decision: performedRecovery
          ? FinancialRecoveryDecision.retry
          : FinancialRecoveryDecision.ignore,
      attempt: request.attempt,
      duration: stopwatch.elapsed,
      completedAt: clock().toUtc(),
      metadata: {
        ...request.metadata,
        'pipelineId': request.pipelineId,
        'recoveryAction': performedRecovery
            ? 'partial_settlement_recovered'
            : 'settlement_already_complete',
        'operationId': request.context.operationId,
        'currency': request.context.currency,
        'totalMinor': request.context.totalMinor,
        'expectedComponentCount': request.context.componentCount,
        'completedComponentCount': completedComponents.length,
        'alreadyCompleteCount': alreadyCompleteCount,
        'journalRecoveredCount': journalRecoveredCount,
        'componentPostedCount': componentPostedCount,
        'components': completedComponents
            .map((result) => result.toMetadata())
            .toList(growable: false),
      },
    );
  }

  Future<_PartialSettlementComponentOutcome> _recoverComponent({
    required FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
    request,
    required SettlementSplitComponent component,
  }) async {
    final context = request.context;

    final instruction = _buildPostingInstruction(
      request: request,
      component: component,
    );

    final postingRequest = componentRequestFactory.create(
      instruction: instruction,
      line: instruction.lines.single,
    );

    final transactionId = postingRequest.id;

    final journalId = componentRequestFactory.journalIdFor(
      operationId: context.operationId,
      lineCode: component.code,
    );

    final existingTransaction = await ledgerRepository.findTransactionById(
      transactionId,
    );

    if (existingTransaction == null) {
      return _postMissingComponent(
        request: request,
        component: component,
        transactionId: transactionId,
        postingRequest: postingRequest,
      );
    }

    final transactionIssue = _validateExistingTransaction(
      transaction: existingTransaction,
      expectedAmountMinor: component.amountMinor,
      expectedCurrency: context.currency,
    );

    if (transactionIssue != null) {
      return _PartialSettlementComponentFailure(
        decision: FinancialRecoveryDecision.manualReview,
        error: StateError(transactionIssue),
        stackTrace: StackTrace.current,
        metadata: {
          'componentRecoveryAction': 'existing_transaction_conflict',
          'transactionId': transactionId,
          'journalId': journalId,
          'transactionStatus': existingTransaction.status.name,
        },
      );
    }

    /*
     * The transaction already exists.
     *
     * Delegate Journal inspection and repair to the existing specialized
     * strategy instead of duplicating its state-machine logic here.
     */
    final journalRecoveryResult = await journalRecoveryStrategy.recover(
      FinancialRecoveryStrategyRequest(
        recoveryId: '${request.recoveryId}:$transactionId:journal',
        pipelineId: RecoverLedgerJournalPostingStrategy.supportedPipelineId,
        context: LedgerJournalPostingRecoveryContext(
          transactionId: transactionId,
          journalId: journalId,
          workflowKey: 'financial.posting.${postingRequest.type.name}',
          source: _journalSourceFor(
            operationId: context.operationId,
            componentCode: component.code,
          ),
          occurredAt: context.occurredAt,
          createdAt: context.occurredAt,
          metadata: {
            ...context.metadata,
            ...request.metadata,
            'parentRecoveryId': request.recoveryId,
            'splitCode': component.code,
            'splitDestination': component.destination.name,
          },
        ),
        error: request.error,
        stackTrace: request.stackTrace,
        attempt: request.attempt,
        requestedAt: request.requestedAt,
        metadata: {
          'parentRecoveryId': request.recoveryId,
          'parentRecoveryStrategy': strategyKey,
        },
      ),
    );

    if (journalRecoveryResult is FinancialRecoveryStrategyFailure) {
      return _PartialSettlementComponentFailure(
        decision: journalRecoveryResult.decision,
        error: journalRecoveryResult.error,
        stackTrace: journalRecoveryResult.stackTrace,
        metadata: {
          'componentRecoveryAction': 'journal_recovery_failed',
          'transactionId': transactionId,
          'journalId': journalId,
          'journalRecoveryMetadata': journalRecoveryResult.metadata,
        },
      );
    }

    final journalSuccess =
        journalRecoveryResult as FinancialRecoveryStrategySuccess;

    final action = journalSuccess.decision == FinancialRecoveryDecision.ignore
        ? PartialSettlementRecoveryComponentAction.alreadyComplete
        : PartialSettlementRecoveryComponentAction.journalRecovered;

    return _PartialSettlementComponentSuccess(
      PartialSettlementRecoveryComponentResult(
        componentCode: component.code,
        destination: component.destination,
        amountMinor: component.amountMinor,
        currency: context.currency,
        transactionId: transactionId,
        journalId: journalId,
        action: action,
        metadata: {
          'journalRecoveryAction': journalSuccess.metadata['recoveryAction'],
          'journalRecoveryId': journalSuccess.recoveryId,
        },
      ),
    );
  }

  SettlementPostingInstruction _buildPostingInstruction({
    required FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
    request,
    required SettlementSplitComponent component,
  }) {
    final context = request.context;

    final line = SettlementPostingLine(
      party: _partyFor(component.destination),
      category: _categoryFor(component.destination),
      amount: Money(
        minorUnits: component.amountMinor,
        currency: FinancialCurrency.fromCode(context.currency),
      ),
      code: component.code,
      label: component.label,
    );

    return SettlementPostingInstruction(
      settlementId: SettlementId(context.operationId),
      operationId: context.operationId,
      consultationId: context.consultationId,
      escrowId: context.escrowId,
      clientId: context.clientId,
      expertId: context.expertId,
      lines: <SettlementPostingLine>[line],
      occurredAt: context.occurredAt.toUtc(),
      metadata: <String, Object?>{
        ...context.metadata,
        ...request.metadata,
        'partialSettlementRecoveryId': request.recoveryId,
        'partialSettlementRecoveryAttempt': request.attempt,
        'partialSettlementRecoveryStrategy': strategyKey,
      },
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

  Future<_PartialSettlementComponentOutcome> _postMissingComponent({
    required FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
    request,
    required SettlementSplitComponent component,
    required String transactionId,
    required PostingRequest postingRequest,
  }) async {
    final journalRequest = journalRequestFactory.create(postingRequest);

    try {
      final postingResult = await journalPostingBridge.post(
        request: journalRequest,
      );

      return _PartialSettlementComponentSuccess(
        PartialSettlementRecoveryComponentResult(
          componentCode: component.code,
          destination: component.destination,
          amountMinor: component.amountMinor,
          currency: request.context.currency,
          transactionId: postingResult.transaction.id,
          journalId: postingResult.journal.journalId,
          action: PartialSettlementRecoveryComponentAction.componentPosted,
          metadata: {
            'componentRecoveryAction': 'missing_component_posted',
            'transactionStatus': postingResult.transaction.status.name,
            'journalStatus': postingResult.journal.status.name,
          },
        ),
      );
    } catch (error, stackTrace) {
      return _PartialSettlementComponentFailure(
        decision: FinancialRecoveryDecision.manualReview,
        error: error,
        stackTrace: stackTrace,
        metadata: {
          'componentRecoveryAction': 'missing_component_posting_failed',
          'transactionId': transactionId,
          'journalId': journalRequest.journalId,
          'componentCode': component.code,
        },
      );
    }
  }

  String? _validateExistingTransaction({
    required LedgerTransaction transaction,
    required int expectedAmountMinor,
    required String expectedCurrency,
  }) {
    if (transaction.status != LedgerTransactionStatus.posted) {
      return 'Ledger transaction "${transaction.id}" has status '
          '"${transaction.status.name}". A partial settlement recovery '
          'cannot reuse a transaction that is not posted.';
    }

    if (transaction.currency.trim().toUpperCase() !=
        expectedCurrency.trim().toUpperCase()) {
      return 'Ledger transaction "${transaction.id}" uses currency '
          '"${transaction.currency}" instead of "$expectedCurrency".';
    }

    if (transaction.totalDebits != expectedAmountMinor ||
        transaction.totalCredits != expectedAmountMinor) {
      return 'Ledger transaction "${transaction.id}" does not match '
          'the expected component amount $expectedAmountMinor.';
    }

    if (!transaction.isBalanced) {
      return 'Ledger transaction "${transaction.id}" is not balanced.';
    }

    return null;
  }

  LedgerJournalSource _journalSourceFor({
    required String operationId,
    required String componentCode,
  }) {
    /*
     * Kept in one helper so the source contract remains deterministic.
     */
    return LedgerJournalSource(
      type: 'partial_settlement_recovery',
      id: '${operationId}_${componentCode.trim().toLowerCase()}',
    );
  }
}

sealed class _PartialSettlementComponentOutcome {
  const _PartialSettlementComponentOutcome();
}

final class _PartialSettlementComponentSuccess
    extends _PartialSettlementComponentOutcome {
  const _PartialSettlementComponentSuccess(this.result);

  final PartialSettlementRecoveryComponentResult result;
}

final class _PartialSettlementComponentFailure
    extends _PartialSettlementComponentOutcome {
  const _PartialSettlementComponentFailure({
    required this.decision,
    required this.error,
    required this.stackTrace,
    this.metadata = const {},
  });

  final FinancialRecoveryDecision decision;
  final Object error;
  final StackTrace stackTrace;
  final Map<String, dynamic> metadata;
}
