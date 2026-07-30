class LedgerBalance {
  final String accountId;

  final String currency;

  final int debitMinor;

  final int creditMinor;

  final int balanceMinor;

  const LedgerBalance({
    required this.accountId,
    required this.currency,
    required this.debitMinor,
    required this.creditMinor,
    required this.balanceMinor,
  });
}
