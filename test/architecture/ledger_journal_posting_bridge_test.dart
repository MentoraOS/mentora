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
    'ledger_journal_source.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_factory.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_bridge.dart';
import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_request.dart';
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
import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/templates/'
    'payment_posting_templates.dart';
import 'package:mentora/core/financial/ledger/repositories/'
    'memory_ledger_repository.dart';
import 'package:mentora/core/financial/ledger/validation/'
    'ledger_journal_validator.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_type.dart';

void main() {
  group('LedgerJournalPostingBridge', () {
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;

    late MemoryLedgerRepository ledgerRepository;
    late LedgerEngine ledgerEngine;
    late BalanceEngine balanceEngine;
    late LedgerPostingBuilder postingBuilder;
    late PostingEngine postingEngine;

    late MemoryLedgerJournalRepository journalRepository;
    late LedgerJournalValidator journalValidator;
    late LedgerJournalReversalBuilder reversalBuilder;
    late LedgerJournalReversalService reversalService;
    late LedgerJournalEngine journalEngine;

    late LedgerJournalPostingBridge bridge;

    setUp(() {
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');

      chartOfAccounts.ensureClientWallet(
        clientId: 'client_001',
        currency: 'XOF',
      );

      chartOfAccounts.ensureExpertWallet(
        expertId: 'expert_001',
        currency: 'XOF',
      );

      ledgerRepository = MemoryLedgerRepository();

      ledgerEngine = LedgerEngine(
        chartOfAccounts: chartOfAccounts,
        repository: ledgerRepository,
      );

      balanceEngine = BalanceEngine(
        chartOfAccounts: chartOfAccounts,
        repository: ledgerRepository,
      );

      postingBuilder = LedgerPostingBuilder(
        paymentTemplates: PaymentPostingTemplates(
          chartOfAccounts: chartOfAccounts,
        ),
      );

      postingEngine = PostingEngine(
        builder: postingBuilder,
        ledgerEngine: ledgerEngine,
        balanceEngine: balanceEngine,
      );

      journalRepository = MemoryLedgerJournalRepository();

      journalValidator = LedgerJournalValidator(
        chartOfAccounts: chartOfAccounts,
        repository: journalRepository,
      );

      reversalBuilder = const LedgerJournalReversalBuilder();

      reversalService = LedgerJournalReversalService(
        repository: journalRepository,
        validator: journalValidator,
        builder: reversalBuilder,
      );

      journalEngine = LedgerJournalEngine(
        repository: journalRepository,
        validator: journalValidator,
        reversalService: reversalService,
      );

      bridge = LedgerJournalPostingBridge(
        postingEngine: postingEngine,
        journalFactory: const LedgerJournalFactory(),
        journalEngine: journalEngine,
      );
    });

    test('posts a ledger transaction and its journal', () async {
      final result = await bridge.post(request: _bridgeRequest());

      expect(result.transaction.id, 'posting_001');

      expect(result.journal.journalId, 'journal_posting_001');

      expect(result.journal.operationId, result.transaction.id);

      expect(result.journal.status, LedgerJournalStatus.posted);

      expect(result.journal.entries.length, result.transaction.entries.length);

      expect(result.journal.debitAmountMinor, result.transaction.totalDebits);

      expect(result.journal.creditAmountMinor, result.transaction.totalCredits);

      expect(result.journal.isBalanced, isTrue);
      expect(result.wasAlreadyJournalized, isFalse);
    });

    test('persists the posted journal in repository', () async {
      final result = await bridge.post(request: _bridgeRequest());

      final stored = await journalRepository.findById(result.journal.journalId);

      expect(stored, isNotNull);
      expect(stored, result.journal);
      expect(stored!.status, LedgerJournalStatus.posted);
    });

    test('preserves transaction entries in journal', () async {
      final result = await bridge.post(request: _bridgeRequest());

      expect(
        result.journal.entries.map((entry) => entry.entryId).toSet(),
        result.transaction.entries.map((entry) => entry.id).toSet(),
      );

      for (final journalEntry in result.journal.entries) {
        final transactionEntry = result.transaction.entries.singleWhere(
          (entry) => entry.id == journalEntry.entryId,
        );

        expect(journalEntry.accountId, transactionEntry.accountId);

        expect(journalEntry.amountMinor, transactionEntry.amountMinor);

        expect(journalEntry.currency, transactionEntry.currency);
      }
    });

    test('returns an existing posted journal idempotently', () async {
      final request = _bridgeRequest();

      final first = await bridge.post(request: request);

      final second = await bridge.post(request: request);

      expect(second.transaction.id, first.transaction.id);

      expect(second.journal.journalId, first.journal.journalId);

      expect(second.wasAlreadyJournalized, isTrue);

      final journals = await journalRepository.findAll();

      expect(journals, hasLength(1));
    });

    test(
      'posts an existing pending journal instead of duplicating it',
      () async {
        final transaction = await postingEngine.post(_postingRequest());

        final pending = const LedgerJournalFactory().create(
          transaction: transaction,
          journalId: 'journal_posting_001',
          workflowKey: 'finalize.consultation.settlement',
          source: _source(),
        );

        await journalEngine.create(pending);

        final result = await bridge.post(request: _bridgeRequest());

        expect(result.journal.journalId, pending.journalId);

        expect(result.journal.status, LedgerJournalStatus.posted);

        expect(result.wasAlreadyJournalized, isTrue);

        final journals = await journalRepository.findAll();

        expect(journals, hasLength(1));
      },
    );

    test('rejects an existing cancelled journal', () async {
      final transaction = await postingEngine.post(_postingRequest());

      final pending = const LedgerJournalFactory().create(
        transaction: transaction,
        journalId: 'journal_posting_001',
        workflowKey: 'finalize.consultation.settlement',
        source: _source(),
      );

      await journalEngine.create(pending);
      await journalEngine.cancel(pending.journalId);

      await expectLater(
        () => bridge.post(request: _bridgeRequest()),
        throwsStateError,
      );
    });

    test('rejects an existing reversed journal', () async {
      final transaction = await postingEngine.post(_postingRequest());

      final pending = const LedgerJournalFactory().create(
        transaction: transaction,
        journalId: 'journal_posting_001',
        workflowKey: 'finalize.consultation.settlement',
        source: _source(),
      );

      await journalEngine.create(pending);

      final posted = await journalEngine.post(pending.journalId);

      final reversed = posted.copyWith(
        status: LedgerJournalStatus.reversed,
        version: posted.version + 1,
      );

      await journalRepository.update(
        journal: reversed,
        expectedVersion: posted.version,
      );

      await expectLater(
        () => bridge.post(request: _bridgeRequest()),
        throwsStateError,
      );
    });

    test('rejects an empty journal identifier before posting', () async {
      await expectLater(
        () => bridge.post(request: _bridgeRequest(journalId: '   ')),
        throwsArgumentError,
      );

      final journals = await journalRepository.findAll();

      expect(journals, isEmpty);
    });

    test('rejects an empty workflow key before posting', () async {
      await expectLater(
        () => bridge.post(request: _bridgeRequest(workflowKey: '   ')),
        throwsArgumentError,
      );

      final journals = await journalRepository.findAll();

      expect(journals, isEmpty);
    });

    test('rejects journal createdAt before occurredAt', () async {
      await expectLater(
        () => bridge.post(
          request: _bridgeRequest(
            occurredAt: DateTime.utc(2026, 7, 15, 12),
            createdAt: DateTime.utc(2026, 7, 15, 11),
          ),
        ),
        throwsArgumentError,
      );

      final journals = await journalRepository.findAll();

      expect(journals, isEmpty);
    });

    test('copies bridge metadata into the journal', () async {
      final result = await bridge.post(
        request: _bridgeRequest(
          metadata: const {
            'bridgeVersion': 1,
            'initiatedBy': 'financial_workflow',
          },
        ),
      );

      expect(result.journal.metadata['bridgeVersion'], 1);

      expect(result.journal.metadata['initiatedBy'], 'financial_workflow');

      expect(
        result.journal.metadata['ledgerTransactionId'],
        result.transaction.id,
      );
    });

    test('uses the requested journal dates', () async {
      final occurredAt = DateTime.utc(2026, 7, 15, 10);

      final createdAt = DateTime.utc(2026, 7, 15, 11);

      final result = await bridge.post(
        request: _bridgeRequest(occurredAt: occurredAt, createdAt: createdAt),
      );

      expect(result.journal.occurredAt, occurredAt);

      expect(result.journal.createdAt, createdAt);
    });

    test('creates only one journal for one operation', () async {
      final request = _bridgeRequest();

      await bridge.post(request: request);
      await bridge.post(request: request);
      await bridge.post(request: request);

      final journals = await journalRepository.findAll();

      expect(journals, hasLength(1));

      expect(journals.single.operationId, 'posting_001');
    });
  });
}

LedgerJournalPostingRequest _bridgeRequest({
  String journalId = 'journal_posting_001',
  String workflowKey = 'finalize.consultation.settlement',
  DateTime? occurredAt,
  DateTime? createdAt,
  Map<String, dynamic> metadata = const {},
}) {
  return LedgerJournalPostingRequest(
    postingRequest: _postingRequest(),
    journalId: journalId,
    workflowKey: workflowKey,
    source: _source(),
    occurredAt: occurredAt,
    createdAt: createdAt,
    metadata: metadata,
  );
}

PostingRequest _postingRequest() {
  return PostingRequest(
    id: 'posting_001',
    referenceId: 'consultation_001',
    type: PostingType.paymentAuthorized,
    consultationId: 'consultation_001',
    clientId: 'client_001',
    expertId: 'expert_001',
    amountMinor: 10000,
    currency: 'XOF',
    createdAt: DateTime.utc(2026, 7, 15, 10),
    metadata: const {'test': 'ledger_journal_posting_bridge'},
  );
}

LedgerJournalSource _source() {
  return LedgerJournalSource(type: 'financial_posting', id: 'consultation_001');
}
