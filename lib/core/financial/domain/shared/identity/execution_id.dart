import 'financial_identifier.dart';

/// Strongly typed identifier for runtime-execution records.
final class ExecutionId extends FinancialIdentifier {
  ExecutionId._(String value)
    : super(value: value, identifierType: 'ExecutionId');

  factory ExecutionId.fromString(String value) => ExecutionId._(value);
}
