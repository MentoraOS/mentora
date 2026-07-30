import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/journal/models/'
    'models.dart';
import 'package:mentora/core/financial/ledger/journal/repository/'
    'repository.dart';
import 'package:mentora/core/financial/ledger/validation/validation.dart';

void main() {
  group('LedgerJournalValidator', () {
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;
    late MemoryLedgerJournalRepository repository;
    late LedgerJournalValidator validator;

    setUp(() {
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('XOF');

      chartOfAccounts.ensureExpertWallet(
        expertId: 'expert_001',
        currency: 'XOF',
      );

      chartOfAccounts.ensureEscrow(
        consultationId: 'consultation_001',
        currency: 'XOF',
      );

      repository = MemoryLedgerJournalRepository();

      validator = LedgerJournalValidator(
        chartOfAccounts: chartOfAccounts,
        repository: repository,
      );
    });

    test('accepts a valid pending journal', () async {
      final result = await validator.validateForPosting(_journal());

      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });

    test('rejects an unbalanced journal', () async {
      final result = await validator.validateForPosting(
        _journal(creditAmountMinor: 9000),
      );

      expect(result.isInvalid, isTrue);
      expect(
        result.containsCode(LedgerJournalValidationCode.unbalanced),
        isTrue,
      );
    });

    test('rejects multiple currencies', () async {
      final result = await validator.validateForPosting(
        _journal(creditCurrency: 'USD'),
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.multipleCurrencies),
        isTrue,
      );
    });

    test('rejects a journal without a debit entry', () async {
      final journal = _journalWithDirections(
        firstDirection: LedgerJournalEntryDirection.credit,
        secondDirection: LedgerJournalEntryDirection.credit,
      );

      final result = await validator.validateForPosting(journal);

      expect(
        result.containsCode(LedgerJournalValidationCode.missingDebitEntry),
        isTrue,
      );
    });

    test('rejects a journal without a credit entry', () async {
      final journal = _journalWithDirections(
        firstDirection: LedgerJournalEntryDirection.debit,
        secondDirection: LedgerJournalEntryDirection.debit,
      );

      final result = await validator.validateForPosting(journal);

      expect(
        result.containsCode(LedgerJournalValidationCode.missingCreditEntry),
        isTrue,
      );
    });

    test('rejects a journal that is not pending', () async {
      final result = await validator.validateForPosting(
        _journal(status: LedgerJournalStatus.posted),
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.invalidStatus),
        isTrue,
      );
    });

    test('rejects unknown accounts', () async {
      final result = await validator.validateForPosting(
        _journal(debitAccountId: 'missing_account'),
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.unknownAccount),
        isTrue,
      );
    });

    test('rejects a duplicate operation ID', () async {
      await repository.create(_journal(journalId: 'journal_001'));

      final result = await validator.validateForPosting(
        _journal(journalId: 'journal_002'),
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.duplicateOperation),
        isTrue,
      );
    });

    test('can accumulate multiple issues', () async {
      final result = await validator.validateForPosting(
        _journal(
          status: LedgerJournalStatus.posted,
          creditAmountMinor: 9000,
          creditCurrency: 'USD',
          debitAccountId: 'missing_account',
        ),
      );

      expect(result.issues.length, greaterThanOrEqualTo(4));

      expect(
        result.containsCode(LedgerJournalValidationCode.invalidStatus),
        isTrue,
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.unbalanced),
        isTrue,
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.multipleCurrencies),
        isTrue,
      );

      expect(
        result.containsCode(LedgerJournalValidationCode.unknownAccount),
        isTrue,
      );
    });

    test('accepts the same stored journal during posting validation', () async {
      final journal = _journal();

      await repository.create(journal);

      final result = await validator.validateForPosting(journal);

      expect(result.isValid, isTrue);

      expect(
        result.containsCode(LedgerJournalValidationCode.duplicateOperation),
        isFalse,
      );
    });
  });
}

LedgerJournal _journal({
  String journalId = 'journal_001',
  String operationId = 'operation_001',
  LedgerJournalStatus status = LedgerJournalStatus.pending,
  int creditAmountMinor = 10000,
  String creditCurrency = 'XOF',
  String debitAccountId = 'escrow_consultation_001_XOF',
}) {
  final occurredAt = DateTime.utc(2026, 7, 15, 10);

  return LedgerJournal(
    journalId: journalId,
    operationId: operationId,
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(type: 'consultation', id: 'consultation_001'),
    status: status,
    occurredAt: occurredAt,
    createdAt: occurredAt.add(const Duration(minutes: 1)),
    entries: [
      LedgerJournalEntry(
        entryId: '${journalId}_debit',
        accountId: debitAccountId,
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
        currency: creditCurrency,
        description: 'Credit expert',
      ),
    ],
  );
}

LedgerJournal _journalWithDirections({
  required LedgerJournalEntryDirection firstDirection,
  required LedgerJournalEntryDirection secondDirection,
}) {
  final occurredAt = DateTime.utc(2026, 7, 15, 10);

  return LedgerJournal(
    journalId: 'journal_001',
    operationId: 'operation_001',
    workflowKey: 'finalize.consultation.settlement',
    source: LedgerJournalSource(type: 'consultation', id: 'consultation_001'),
    status: LedgerJournalStatus.pending,
    occurredAt: occurredAt,
    createdAt: occurredAt,
    entries: [
      LedgerJournalEntry(
        entryId: 'entry_001',
        accountId: 'escrow_consultation_001_XOF',
        direction: firstDirection,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'First entry',
      ),
      LedgerJournalEntry(
        entryId: 'entry_002',
        accountId: 'expert_wallet_expert_001_XOF',
        direction: secondDirection,
        amountMinor: 10000,
        currency: 'XOF',
        description: 'Second entry',
      ),
    ],
  );
}
