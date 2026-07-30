import 'financial_identifier.dart';

/// Strongly typed identifier for payout records.
final class PayoutId extends FinancialIdentifier {
  PayoutId._(String value) : super(value: value, identifierType: 'PayoutId');

  factory PayoutId.fromString(String value) => PayoutId._(value);
}
