import '../chart/chart_of_accounts.dart';

import '../journal/models/ledger_journal.dart';
import '../journal/models/ledger_journal_entry.dart';
import '../journal/models/ledger_journal_status.dart';
import '../journal/repository/ledger_journal_repository.dart';

import 'ledger_journal_validation_issue.dart';
import 'ledger_journal_validation_result.dart';

// Validates whether a ledger journal can be posted.
//
// This component is side-effect free. It only inspects the journal,
// the chart of accounts and the journal repository.
final class LedgerJournalValidator {
  const LedgerJournalValidator({
    required this.chartOfAccounts,
    required this.repository,
  });

  final ChartOfAccounts chartOfAccounts;
  final LedgerJournalRepository repository;

  Future<LedgerJournalValidationResult> validateForPosting(
    LedgerJournal journal,
  ) async {
    final issues = <LedgerJournalValidationIssue>[];

    _validateStatus(journal: journal, issues: issues);

    _validateBalance(journal: journal, issues: issues);

    _validateCurrency(journal: journal, issues: issues);

    _validateDirections(journal: journal, issues: issues);

    _validateAccounts(journal: journal, issues: issues);

    await _validateIdempotency(journal: journal, issues: issues);

    return LedgerJournalValidationResult(issues: issues);
  }

  void _validateStatus({
    required LedgerJournal journal,
    required List<LedgerJournalValidationIssue> issues,
  }) {
    if (journal.status != LedgerJournalStatus.pending) {
      issues.add(
        LedgerJournalValidationIssue(
          code: LedgerJournalValidationCode.invalidStatus,
          field: 'status',
          message: 'Only a pending ledger journal can be posted.',
          metadata: {'actualStatus': journal.status.name},
        ),
      );
    }
  }

  void _validateBalance({
    required LedgerJournal journal,
    required List<LedgerJournalValidationIssue> issues,
  }) {
    if (!journal.isBalanced) {
      issues.add(
        LedgerJournalValidationIssue(
          code: LedgerJournalValidationCode.unbalanced,
          field: 'entries',
          message: 'Ledger journal debit and credit totals must match.',
          metadata: {
            'debitAmountMinor': journal.debitAmountMinor,
            'creditAmountMinor': journal.creditAmountMinor,
          },
        ),
      );
    }
  }

  void _validateCurrency({
    required LedgerJournal journal,
    required List<LedgerJournalValidationIssue> issues,
  }) {
    if (journal.containsMultipleCurrencies) {
      issues.add(
        const LedgerJournalValidationIssue(
          code: LedgerJournalValidationCode.multipleCurrencies,
          field: 'entries.currency',
          message: 'A ledger journal must contain a single currency.',
        ),
      );
    }
  }

  void _validateDirections({
    required LedgerJournal journal,
    required List<LedgerJournalValidationIssue> issues,
  }) {
    final hasDebit = journal.entries.any(
      (entry) => entry.direction == LedgerJournalEntryDirection.debit,
    );

    final hasCredit = journal.entries.any(
      (entry) => entry.direction == LedgerJournalEntryDirection.credit,
    );

    if (!hasDebit) {
      issues.add(
        const LedgerJournalValidationIssue(
          code: LedgerJournalValidationCode.missingDebitEntry,
          field: 'entries',
          message: 'A ledger journal must contain at least one debit entry.',
        ),
      );
    }

    if (!hasCredit) {
      issues.add(
        const LedgerJournalValidationIssue(
          code: LedgerJournalValidationCode.missingCreditEntry,
          field: 'entries',
          message: 'A ledger journal must contain at least one credit entry.',
        ),
      );
    }
  }

  void _validateAccounts({
    required LedgerJournal journal,
    required List<LedgerJournalValidationIssue> issues,
  }) {
    for (final entry in journal.entries) {
      if (!chartOfAccounts.containsAccount(entry.accountId)) {
        issues.add(
          LedgerJournalValidationIssue(
            code: LedgerJournalValidationCode.unknownAccount,
            field: 'entries.accountId',
            message: 'Ledger account "${entry.accountId}" does not exist.',
            metadata: {'entryId': entry.entryId, 'accountId': entry.accountId},
          ),
        );
      }
    }
  }

  Future<void> _validateIdempotency({
    required LedgerJournal journal,
    required List<LedgerJournalValidationIssue> issues,
  }) async {
    final existing = await repository.findByOperationId(journal.operationId);

    if (existing == null) {
      return;
    }

    // The journal already stored for this operation is the
    // journal currently being validated. This is expected
    // when transitioning an existing pending journal to posted.
    if (existing.journalId == journal.journalId) {
      return;
    }

    issues.add(
      LedgerJournalValidationIssue(
        code: LedgerJournalValidationCode.duplicateOperation,
        field: 'operationId',
        message:
            'Another ledger journal already exists for operation '
            '"${journal.operationId}".',
        metadata: {
          'currentJournalId': journal.journalId,
          'existingJournalId': existing.journalId,
        },
      ),
    );
  }
}
