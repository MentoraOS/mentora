import 'financial_identifier.dart';

/// Strongly typed identifier for financial-operation records.
final class FinancialOperationId extends FinancialIdentifier {
  FinancialOperationId._(String value)
    : super(value: value, identifierType: 'FinancialOperationId');

  factory FinancialOperationId.fromString(String value) =>
      FinancialOperationId._(value);
}
