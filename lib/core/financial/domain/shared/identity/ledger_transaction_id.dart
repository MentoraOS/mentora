import 'financial_identifier.dart';

/// Strongly typed identifier for ledger-transaction records.
final class LedgerTransactionId extends FinancialIdentifier {
  LedgerTransactionId._(String value)
    : super(value: value, identifierType: 'LedgerTransactionId');

  factory LedgerTransactionId.fromString(String value) =>
      LedgerTransactionId._(value);
}
