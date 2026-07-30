enum LedgerAccountType {
  clientWallet,
  expertWallet,
  escrow,
  platformRevenue,
  tax,
  refund,
  externalProvider,
}

class LedgerAccount {
  final String id;
  final LedgerAccountType type;
  final String ownerId;
  final String currency;

  const LedgerAccount({
    required this.id,
    required this.type,
    required this.ownerId,
    required this.currency,
  });
}
