import 'financial_identifier.dart';

/// Strongly typed identifier for payment records.
final class PaymentId extends FinancialIdentifier {
  PaymentId._(String value) : super(value: value, identifierType: 'PaymentId');

  factory PaymentId.fromString(String value) => PaymentId._(value);
}
