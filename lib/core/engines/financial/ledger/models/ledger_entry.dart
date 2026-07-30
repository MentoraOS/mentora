enum LedgerEntryType { debit, credit }

class LedgerEntry {
  final String accountId;
  final LedgerEntryType type;
  final int amount;

  const LedgerEntry({
    required this.accountId,
    required this.type,
    required this.amount,
  });
}
