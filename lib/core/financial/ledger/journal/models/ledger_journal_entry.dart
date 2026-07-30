// Accounting direction of a ledger journal entry.
enum LedgerJournalEntryDirection { debit, credit }

// Immutable accounting line stored inside a ledger journal.
final class LedgerJournalEntry {
  LedgerJournalEntry({
    required String entryId,
    required String accountId,
    required this.direction,
    required int amountMinor,
    required String currency,
    required String description,
    Map<String, dynamic> metadata = const {},
  }) : entryId = _normalizeRequired(value: entryId, fieldName: 'entryId'),
       accountId = _normalizeRequired(value: accountId, fieldName: 'accountId'),
       amountMinor = _validateAmount(amountMinor),
       currency = _normalizeCurrency(currency),
       description = _normalizeRequired(
         value: description,
         fieldName: 'description',
       ),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata));

  // Unique identifier of this journal line.
  final String entryId;

  // Ledger account affected by this line.
  final String accountId;

  // Debit or credit direction.
  final LedgerJournalEntryDirection direction;

  // Monetary amount expressed in the currency's minor unit.
  //
  // Examples:
  // - 10,000 XOF is stored as 10,000
  // - 100.50 USD is stored as 10,050
  final int amountMinor;

  // Normalized ISO-style currency code.
  final String currency;

  // Human-readable accounting description.
  final String description;

  // Immutable contextual metadata.
  final Map<String, dynamic> metadata;

  bool get isDebit => direction == LedgerJournalEntryDirection.debit;

  bool get isCredit => direction == LedgerJournalEntryDirection.credit;

  static int _validateAmount(int amountMinor) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Ledger journal entry amount must be greater than zero.',
      );
    }

    return amountMinor;
  }

  static String _normalizeCurrency(String value) {
    final normalized = value.trim().toUpperCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'currency',
        'Ledger journal entry currency cannot be empty.',
      );
    }

    return normalized;
  }

  static String _normalizeRequired({
    required String value,
    required String fieldName,
  }) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        'Ledger journal entry $fieldName cannot be empty.',
      );
    }

    return normalized;
  }

  @override
  String toString() {
    return 'LedgerJournalEntry('
        'entryId: $entryId, '
        'accountId: $accountId, '
        'direction: $direction, '
        'amountMinor: $amountMinor, '
        'currency: $currency'
        ')';
  }
}
