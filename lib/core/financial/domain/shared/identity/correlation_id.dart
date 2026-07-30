import 'financial_identifier.dart';

/// Strongly typed identifier for correlation records.
final class CorrelationId extends FinancialIdentifier {
  CorrelationId._(String value)
    : super(value: value, identifierType: 'CorrelationId');

  factory CorrelationId.fromString(String value) => CorrelationId._(value);
}
