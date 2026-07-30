import 'financial_identifier.dart';

/// Strongly typed identifier for escrow records.
final class EscrowId extends FinancialIdentifier {
  EscrowId._(String value) : super(value: value, identifierType: 'EscrowId');

  factory EscrowId.fromString(String value) => EscrowId._(value);
}
