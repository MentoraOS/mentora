import 'financial_identifier.dart';

/// Strongly typed identifier for refund records.
final class RefundId extends FinancialIdentifier {
  RefundId._(String value) : super(value: value, identifierType: 'RefundId');

  factory RefundId.fromString(String value) => RefundId._(value);
}
