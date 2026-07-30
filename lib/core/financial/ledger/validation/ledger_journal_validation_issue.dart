// Machine-readable validation codes for ledger journals.
enum LedgerJournalValidationCode {
  unbalanced,
  multipleCurrencies,
  missingDebitEntry,
  missingCreditEntry,
  invalidStatus,
  unknownAccount,
  duplicateOperation,
}

// One validation issue detected on a ledger journal.
final class LedgerJournalValidationIssue {
  const LedgerJournalValidationIssue({
    required this.code,
    required this.message,
    this.field,
    this.metadata = const {},
  });

  final LedgerJournalValidationCode code;
  final String message;
  final String? field;
  final Map<String, dynamic> metadata;

  @override
  String toString() {
    return 'LedgerJournalValidationIssue('
        'code: $code, '
        'field: $field, '
        'message: $message'
        ')';
  }
}
