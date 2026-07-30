import 'financial_identifier.dart';

/// Strongly typed identifier for wallet records.
final class WalletId extends FinancialIdentifier {
  WalletId._(String value) : super(value: value, identifierType: 'WalletId');

  factory WalletId.fromString(String value) => WalletId._(value);
}
