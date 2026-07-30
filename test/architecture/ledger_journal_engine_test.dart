import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/journal/engine/'
    'engine.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';
import 'package:mentora/core/financial/ledger/validation/'
    'validation.dart';
import 'package:mentora/core/financial/ledger/journal/reversal/reversal.dart';

void main() {
  group('LedgerJournalEngine', () {
    late MemoryLedgerJournalRepository repository;
    late LedgerJournalValidator validator;
    late LedgerJournalEngine engine;
    late LedgerJournalReversalService reversalService;

    setUp(() {
      final accountRegistry = AccountRegistry();

      final chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');

      chartOfAccounts.ensureEscrow(
        consultationId: 'consultation_001',
        currency: 'XOF',
      );

      chartOfAccounts.ensureExpertWallet(
        expertId: 'expert_001',
        currency: 'XOF',
      );

      repository = MemoryLedgerJournalRepository();

      validator = LedgerJournalValidator(
        chartOfAccounts: chartOfAccounts,
        repository: repository,
      );

      reversalService = LedgerJournalReversalService(
        repository: repository,
        validator: validator,
        builder: const LedgerJournalReversalBuilder(),
      );

      engine = LedgerJournalEngine(
        repository: repository,
        validator: validator,
        reversalService: reversalService,
      );
    });

    test('creates a pending journal', () async {
      final journal = _journal();

      final created = await engine.create(journal);

      expect(created, same(journal));
      expect(await repository.findById(journal.journalId), same(journal));
    });

    test('rejects duplicate operation IDs', () async {
      await engine.create(_journal());

      await expectLater(
        () => engine.create(_journal(journalId: 'journal_002')),
        throwsA(isA<LedgerJournalAlreadyExistsException>()),
      );
    });

    test('posts a valid pending journal', () async {
      await engine.create(_journal());

      final posted = await engine.post('journal_001');

      expect(posted.status, LedgerJournalStatus.posted);

      expect(posted.version, 2);

      final stored = await repository.findById('journal_001');

      expect(stored?.status, LedgerJournalStatus.posted);
    });

    test('rejects posting an invalid journal', () async {
      await engine.create(_journal(creditAmountMinor: 9000));

      await expectLater(
        () => engine.post('journal_001'),
        throwsA(isA<LedgerJournalValidationException>()),
      );

      final stored = await repository.findById('journal_001');

      expect(stored?.status, LedgerJournalStatus.pending);

      expect(stored?.version, 1);
    });

    test('cancels a pending journal', () async {
      await engine.create(_journal());

      final cancelled = await engine.cancel('journal_001');

      expect(cancelled.status, LedgerJournalStatus.cancelled);

      expect(cancelled.version, 2);
    });

    test('creates a posted compensating journal when reversing', () async {
      await engine.create(_journal());
      await engine.post('journal_001');

      final result = await engine.reverse(request: _reversalRequest());

      expect(result.originalJournal.status, LedgerJournalStatus.reversed);

      expect(result.reversalJournal.status, LedgerJournalStatus.posted);

      expect(result.reversalJournal.journalId, 'journal_001_reversal');

      expect(result.reversalJournal.operationId, 'operation_001_reversal');

      expect(await repository.count(), 2);
    });

    test('rejects cancelling a posted journal', () async {
      await engine.create(_journal());
      await engine.post('journal_001');

      await expectLater(
        () => engine.cancel('journal_001'),
        throwsA(isA<InvalidLedgerJournalTransitionException>()),
      );
    });

    test('rejects reversing a pending journal', () async {
      await engine.create(_journal());

      await expectLater(
        () => engine.reverse(request: _reversalRequest()),
        throwsA(isA<LedgerJournalReversalInvalidStateException>()),
      );

      expect(await repository.findById('journal_001_reversal'), isNull);
    });

    test('rejects transitions from terminal states', () async {
      await engine.create(_journal());

      await engine.cancel('journal_001');

      await expectLater(
        () => engine.post('journal_001'),
        throwsA(isA<InvalidLedgerJournalTransitionException>()),
      );

      await expectLater(
        () => engine.reverse(
          request: LedgerJournalReversalRequest(
            originalJournalId: 'journal_001',
            reversalJournalId: 'journal_001_reversal',
            reversalOperationId: 'operation_001_reversal',
            reason: 'Client refund approved',
            occurredAt: DateTime.utc(2026, 7, 15, 11),
            createdAt: DateTime.utc(2026, 7, 15, 11, 1),
          ),
        ),
        throwsA(isA<LedgerJournalReversalInvalidStateException>()),
      );
    });

    test('rejects a missing journal', () async {
      await expectLater(
        () => engine.post('missing'),
        throwsA(isA<LedgerJournalMissingException>()),
      );
    });

    test('resolves journal by operation ID', () async {
      await engine.create(_journal());

      final journal = await engine.findByOperationId('operation_001');

      expect(journal?.journalId, 'journal_001');
    });
  });
}

LedgerJournalReversalRequest _reversalRequest() {
  return LedgerJournalReversalRequest(
    originalJournalId: 'journal_001',
    reversalJournalId: 'journal_001_reversal',
    reversalOperationId: 'operation_001_reversal',
    reason: 'Client refund approved',
    occurredAt: DateTime.utc(2026, 7, 15, 11),
    createdAt: DateTime.utc(2026, 7, 15, 11, 1),
  );
}

LedgerJournal _journal({
  String journalId = 'journal_001',
  String operationId = 'operation_001',
  int creditAmountMinor = 10000,
}) {
  final occurredAt = DateTime.utc(2026, 7, 15, 10);

  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(type: 'consultation', id: 'consultation_001'),
    status: LedgerJournalStatus.pending,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    entries: [
      LedgerJournalEntry(
        entryId: '${journalId}_debit',
        accountId: 'escrow_consultation_001_XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Debit escrow',
      ),
      LedgerJournalEntry(
        entryId: '${journalId}_credit',
        accountId: 'expert_wallet_expert_001_XOF',
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: creditAmountMinor,
        currency: 'XOF',
        description: 'Credit expert',
      ),
    ],
  );
}
