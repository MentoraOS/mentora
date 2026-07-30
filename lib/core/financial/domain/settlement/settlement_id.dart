import '../shared/identity/financial_identifier.dart';

// Strongly typed identifier for a consultation settlement.
//
// It prevents accidental confusion between settlement identifiers
// and identifiers from other financial domains such as wallets,
// payouts, refunds or transactions.
final class SettlementId extends FinancialIdentifier {
  SettlementId(String value)
    : super(value: value, identifierType: 'SettlementId');

  // Creates a settlement identifier from a raw string.
  factory SettlementId.fromString(String value) {
    return SettlementId(value);
  }
}
