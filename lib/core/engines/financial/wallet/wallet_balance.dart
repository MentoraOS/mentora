class WalletBalance {
  final String ownerId;
  final String accountId;
  final int balance;
  final String currency;

  const WalletBalance({
    required this.ownerId,
    required this.accountId,
    required this.balance,
    required this.currency,
  });
}
