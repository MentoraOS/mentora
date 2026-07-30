import 'ledger_journal_validation_issue.dart';

// Immutable result returned by [LedgerJournalValidator].

final class LedgerJournalValidationResult {
  LedgerJournalValidationResult({
    required List<LedgerJournalValidationIssue> issues,
  }) : issues = List.unmodifiable(issues);

  const LedgerJournalValidationResult.valid() : issues = const [];

  final List<LedgerJournalValidationIssue> issues;

  bool get isValid => issues.isEmpty;

  bool get isInvalid => !isValid;

  bool containsCode(LedgerJournalValidationCode code) {
    return issues.any((issue) => issue.code == code);
  }
}
