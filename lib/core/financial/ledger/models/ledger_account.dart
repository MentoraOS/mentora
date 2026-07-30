import 'ledger_account_type.dart';

class LedgerAccount {
  final String id;
  final String ownerId;
  final String currency;
  final LedgerAccountType type;
  final String name;
  final bool active;

  const LedgerAccount({
    required this.id,
    required this.ownerId,
    required this.currency,
    required this.type,
    required this.name,
    this.active = true,
  });
}
