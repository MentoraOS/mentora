import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';
import 'package:mentora/core/financial/ledger/journal/reversal/'
    'reversal.dart';

import 'package:mentora/core/financial/ledger/validation/'
    'validation.dart';

void main() {
  group('LedgerJournalReversalService', () {
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;

    late MemoryLedgerJournalRepository repository;
    late LedgerJournalValidator validator;

    late LedgerJournalReversalBuilder builder;
    late LedgerJournalReversalService service;

    setUp(() {
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

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

      builder = const LedgerJournalReversalBuilder();

      service = LedgerJournalReversalService(
        repository: repository,
        validator: validator,
        builder: builder,
      );
    });

    test('should create and post a compensating journal', () async {
      final original = _postedJournal();

      await repository.create(original);

      final result = await service.reverse(request: _request());

      expect(result.originalJournal.status, LedgerJournalStatus.reversed);

      expect(result.reversalJournal.status, LedgerJournalStatus.posted);

      expect(result.originalJournal.version, 3);

      expect(result.reversalJournal.version, 2);

      expect(result.isBalanced, isTrue);

      expect(await repository.count(), 2);
    });

    test('should persist both final journal states', () async {
      await repository.create(_postedJournal());

      await service.reverse(request: _request());

      final storedOriginal = await repository.findById('journal_001');

      final storedReversal = await repository.findById('journal_001_reversal');

      expect(storedOriginal?.status, LedgerJournalStatus.reversed);

      expect(storedOriginal?.version, 3);

      expect(storedReversal?.status, LedgerJournalStatus.posted);

      expect(storedReversal?.version, 2);
    });

    test('should invert every debit and credit entry', () async {
      final original = _postedJournal();

      await repository.create(original);

      final result = await service.reverse(request: _request());

      final reversal = result.reversalJournal;

      expect(reversal.entries[0].accountId, original.entries[0].accountId);

      expect(reversal.entries[0].direction, LedgerJournalEntryDirection.credit);

      expect(reversal.entries[1].accountId, original.entries[1].accountId);

      expect(reversal.entries[1].direction, LedgerJournalEntryDirection.debit);

      expect(reversal.entries[0].amountMinor, original.entries[0].amountMinor);

      expect(reversal.entries[1].amountMinor, original.entries[1].amountMinor);
    });

    test('should preserve the accounting balance', () async {
      final original = _postedJournal();

      await repository.create(original);

      final result = await service.reverse(request: _request());

      final reversal = result.reversalJournal;

      expect(reversal.isBalanced, isTrue);

      expect(reversal.debitAmountMinor, original.creditAmountMinor);

      expect(reversal.creditAmountMinor, original.debitAmountMinor);

      expect(reversal.currency, original.currency);
    });

    test('should link both journals through metadata', () async {
      await repository.create(_postedJournal());

      final result = await service.reverse(request: _request());

      final original = result.originalJournal;

      final reversal = result.reversalJournal;

      expect(original.metadata['reversalJournalId'], 'journal_001_reversal');

      expect(
        original.metadata['reversalOperationId'],
        'operation_001_reversal',
      );

      expect(original.metadata['reversalReason'], 'Client refund approved');

      expect(reversal.metadata['reversalOfJournalId'], 'journal_001');

      expect(reversal.metadata['reversalOfOperationId'], 'operation_001');

      expect(reversal.metadata['reversalReason'], 'Client refund approved');

      expect(reversal.metadata['postedBy'], 'ledger_journal_reversal_service');
    });

    test('should reject a missing original journal', () async {
      await expectLater(
        () => service.reverse(request: _request()),
        throwsA(isA<LedgerJournalReversalOriginalNotFoundException>()),
      );

      expect(await repository.count(), 0);
    });

    test('should reject a pending original journal', () async {
      await repository.create(
        _postedJournal().copyWith(
          status: LedgerJournalStatus.pending,
          version: 1,
        ),
      );

      await expectLater(
        () => service.reverse(request: _request()),
        throwsA(isA<LedgerJournalReversalInvalidStateException>()),
      );

      expect(await repository.findById('journal_001_reversal'), isNull);
    });

    test('should reject a cancelled original journal', () async {
      await repository.create(
        _postedJournal().copyWith(status: LedgerJournalStatus.cancelled),
      );

      await expectLater(
        () => service.reverse(request: _request()),
        throwsA(isA<LedgerJournalReversalInvalidStateException>()),
      );
    });

    test('should reject an existing reversal journal ID', () async {
      await repository.create(_postedJournal());

      await repository.create(
        _independentJournal(
          journalId: 'journal_001_reversal',
          operationId: 'another_operation',
        ),
      );

      await expectLater(
        () => service.reverse(request: _request()),
        throwsA(isA<LedgerJournalReversalAlreadyExistsException>()),
      );

      final original = await repository.findById('journal_001');

      expect(original?.status, LedgerJournalStatus.posted);
    });

    test('should reject an existing reversal operation ID', () async {
      await repository.create(_postedJournal());

      await repository.create(
        _independentJournal(
          journalId: 'another_journal',
          operationId: 'operation_001_reversal',
        ),
      );

      await expectLater(
        () => service.reverse(request: _request()),
        throwsA(isA<LedgerJournalReversalAlreadyExistsException>()),
      );

      expect(await repository.findById('journal_001_reversal'), isNull);
    });

    test('should reject reversing the same journal twice', () async {
      await repository.create(_postedJournal());

      await service.reverse(request: _request());

      await expectLater(
        () => service.reverse(
          request: LedgerJournalReversalRequest(
            originalJournalId: 'journal_001',
            reversalJournalId: 'journal_001_second_reversal',
            reversalOperationId: 'operation_001_second_reversal',
            reason: 'Second reversal attempt',
            occurredAt: DateTime.utc(2026, 7, 15, 12),
            createdAt: DateTime.utc(2026, 7, 15, 12, 1),
          ),
        ),
        throwsA(isA<LedgerJournalReversalInvalidStateException>()),
      );

      expect(await repository.count(), 2);
    });

    test('should roll back when reversal validation fails', () async {
      final invalidOriginal = _postedJournal(debitAccountId: 'missing_account');

      await repository.create(invalidOriginal);

      await expectLater(
        () => service.reverse(request: _request()),
        throwsA(isA<LedgerJournalReversalValidationException>()),
      );

      final storedOriginal = await repository.findById('journal_001');

      final storedReversal = await repository.findById('journal_001_reversal');

      expect(storedOriginal?.status, LedgerJournalStatus.posted);

      expect(storedOriginal?.version, 2);

      expect(storedReversal, isNull);

      expect(await repository.count(), 1);
    });

    test('should roll back every change when final commit fails', () async {
      final atomicRepository = _FailingAtomicLedgerJournalRepository(
        failOnUpdateNumber: 2,
      );

      await atomicRepository.create(_postedJournal());

      final atomicValidator = LedgerJournalValidator(
        chartOfAccounts: chartOfAccounts,
        repository: atomicRepository,
      );

      final atomicService = LedgerJournalReversalService(
        repository: atomicRepository,
        validator: atomicValidator,
        builder: const LedgerJournalReversalBuilder(),
      );

      await expectLater(
        () => atomicService.reverse(request: _request()),
        throwsA(isA<StateError>()),
      );

      final storedOriginal = await atomicRepository.findById('journal_001');

      final storedReversal = await atomicRepository.findById(
        'journal_001_reversal',
      );

      expect(storedOriginal?.status, LedgerJournalStatus.posted);

      expect(storedOriginal?.version, 2);

      expect(storedReversal, isNull);

      expect(await atomicRepository.count(), 1);
    });

    test(
      'should reject a request targeting another original journal',
      () async {
        await repository.create(_postedJournal());

        await expectLater(
          () => service.reverse(
            request: _request(originalJournalId: 'another_journal'),
          ),
          throwsA(isA<LedgerJournalReversalOriginalNotFoundException>()),
        );
      },
    );
  });
}

LedgerJournal _postedJournal({
  String debitAccountId = 'escrow_consultation_001_XOF',
}) {
  final occurredAt = DateTime.utc(2026, 7, 15, 10);

  return LedgerJournal(
    journalId: 'journal_001',
    operationId: 'operation_001',
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(type: 'consultation', id: 'consultation_001'),
    status: LedgerJournalStatus.posted,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    version: 2,
    entries: [
      LedgerJournalEntry(
        entryId: 'entry_debit',
        accountId: debitAccountId,
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Debit consultation escrow',
      ),
      LedgerJournalEntry(
        entryId: 'entry_credit',
        accountId: 'expert_wallet_expert_001_XOF',
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Credit expert wallet',
      ),
    ],
    metadata: const {
      'consultationId': 'consultation_001',
      'expertId': 'expert_001',
    },
  );
}

LedgerJournal _independentJournal({
  required String journalId,
  required String operationId,
}) {
  final occurredAt = DateTime.utc(2026, 7, 15, 9);

  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: 'independent.operation',
    source: LedgerJournalSource(type: 'system', id: journalId),
    status: LedgerJournalStatus.pending,
    occurredAt: occurredAt,
    createdAt: occurredAt,
    entries: [
      LedgerJournalEntry(
        entryId: '${journalId}_debit',
        accountId: 'escrow_consultation_001_XOF',
        direction: LedgerJournalEntryDirection.debit,
        amountMinor: 100,
        currency: 'XOF',
        description: 'Independent debit',
      ),
      LedgerJournalEntry(
        entryId: '${journalId}_credit',
        accountId: 'expert_wallet_expert_001_XOF',
        direction: LedgerJournalEntryDirection.credit,
        amountMinor: 100,
        currency: 'XOF',
        description: 'Independent credit',
      ),
    ],
  );
}

LedgerJournalReversalRequest _request({
  String originalJournalId = 'journal_001',
  String reversalJournalId = 'journal_001_reversal',
  String reversalOperationId = 'operation_001_reversal',
}) {
  return LedgerJournalReversalRequest(
    originalJournalId: originalJournalId,
    reversalJournalId: reversalJournalId,
    reversalOperationId: reversalOperationId,
    reason: 'Client refund approved',
    occurredAt: DateTime.utc(2026, 7, 15, 11),
    createdAt: DateTime.utc(2026, 7, 15, 11, 1),
    metadata: const {'approvedBy': 'admin_001', 'refundId': 'refund_001'},
  );
}

/// Repository used to prove that a failed write inside a transaction
/// does not modify the committed state.
final class _FailingAtomicLedgerJournalRepository
    implements LedgerJournalRepository {
  _FailingAtomicLedgerJournalRepository({required this.failOnUpdateNumber});

  final int failOnUpdateNumber;

  final MemoryLedgerJournalRepository _store = MemoryLedgerJournalRepository();

  @override
  Future<void> create(LedgerJournal journal) {
    return _store.create(journal);
  }

  @override
  Future<void> update({
    required LedgerJournal journal,
    required int expectedVersion,
  }) {
    return _store.update(journal: journal, expectedVersion: expectedVersion);
  }

  @override
  Future<LedgerJournal?> findById(String journalId) {
    return _store.findById(journalId);
  }

  @override
  Future<LedgerJournal?> findByOperationId(String operationId) {
    return _store.findByOperationId(operationId);
  }

  @override
  Future<List<LedgerJournal>> findAll() {
    return _store.findAll();
  }

  @override
  Future<List<LedgerJournal>> findByStatus(LedgerJournalStatus status) {
    return _store.findByStatus(status);
  }

  @override
  Future<List<LedgerJournal>> findByWorkflowKey(String workflowKey) {
    return _store.findByWorkflowKey(workflowKey);
  }

  @override
  Future<List<LedgerJournal>> findBySource({
    required String sourceType,
    required String sourceId,
  }) {
    return _store.findBySource(sourceType: sourceType, sourceId: sourceId);
  }

  @override
  Future<List<LedgerJournal>> findOccurredBetween({
    required DateTime from,
    required DateTime to,
  }) {
    return _store.findOccurredBetween(from: from, to: to);
  }

  @override
  Future<bool> existsByOperationId(String operationId) {
    return _store.existsByOperationId(operationId);
  }

  @override
  Future<int> count() {
    return _store.count();
  }

  @override
  Future<T> runInTransaction<T>(
    Future<T> Function(LedgerJournalRepository repository) action,
  ) async {
    final staged = MemoryLedgerJournalRepository();

    final committedJournals = await _store.findAll();

    for (final journal in committedJournals) {
      await staged.create(journal);
    }

    final failingView = _FailingUpdateRepositoryView(
      delegate: staged,
      failOnUpdateNumber: failOnUpdateNumber,
    );

    final result = await action(failingView);

    final stagedJournals = await staged.findAll();

    _store.clear();

    for (final journal in stagedJournals) {
      await _store.create(journal);
    }

    return result;
  }
}

/// Transactional view that fails on a selected update call.
final class _FailingUpdateRepositoryView implements LedgerJournalRepository {
  _FailingUpdateRepositoryView({
    required this.delegate,
    required this.failOnUpdateNumber,
  });

  final LedgerJournalRepository delegate;
  final int failOnUpdateNumber;

  int _updateCount = 0;

  @override
  Future<void> update({
    required LedgerJournal journal,
    required int expectedVersion,
  }) async {
    _updateCount++;

    if (_updateCount == failOnUpdateNumber) {
      throw StateError('Simulated transactional update failure.');
    }

    await delegate.update(journal: journal, expectedVersion: expectedVersion);
  }

  @override
  Future<void> create(LedgerJournal journal) {
    return delegate.create(journal);
  }

  @override
  Future<LedgerJournal?> findById(String journalId) {
    return delegate.findById(journalId);
  }

  @override
  Future<LedgerJournal?> findByOperationId(String operationId) {
    return delegate.findByOperationId(operationId);
  }

  @override
  Future<List<LedgerJournal>> findAll() {
    return delegate.findAll();
  }

  @override
  Future<List<LedgerJournal>> findByStatus(LedgerJournalStatus status) {
    return delegate.findByStatus(status);
  }

  @override
  Future<List<LedgerJournal>> findByWorkflowKey(String workflowKey) {
    return delegate.findByWorkflowKey(workflowKey);
  }

  @override
  Future<List<LedgerJournal>> findBySource({
    required String sourceType,
    required String sourceId,
  }) {
    return delegate.findBySource(sourceType: sourceType, sourceId: sourceId);
  }

  @override
  Future<List<LedgerJournal>> findOccurredBetween({
    required DateTime from,
    required DateTime to,
  }) {
    return delegate.findOccurredBetween(from: from, to: to);
  }

  @override
  Future<bool> existsByOperationId(String operationId) {
    return delegate.existsByOperationId(operationId);
  }

  @override
  Future<int> count() {
    return delegate.count();
  }

  @override
  Future<T> runInTransaction<T>(
    Future<T> Function(LedgerJournalRepository repository) action,
  ) {
    return delegate.runInTransaction(action);
  }
}
