import 'financial_identifier.dart';

/// Strongly typed identifier for settlement records.
final class SettlementId extends FinancialIdentifier {
  SettlementId._(String value)
    : super(value: value, identifierType: 'SettlementId');

  factory SettlementId.fromString(String value) => SettlementId._(value);
}
