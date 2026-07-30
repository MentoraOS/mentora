import 'ledger_entry_side.dart';

class LedgerEntry {
  final String id;
  final String transactionId;
  final String accountId;

  // Montant en unité monétaire mineure.
  // Exemple : 10,50 USD = 1050.
  //
  final int amountMinor;

  final String currency;
  final LedgerEntrySide side;
  final DateTime createdAt;

  const LedgerEntry({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.amountMinor,
    required this.currency,
    required this.side,
    required this.createdAt,
  }) : assert(amountMinor > 0, 'Ledger entry amount must be greater than zero');
}
