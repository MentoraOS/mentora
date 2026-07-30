import '../exceptions/invalid_financial_identifier_exception.dart';

/// Base value object for strongly typed financial identifiers.
///
/// Equality includes the concrete runtime type, so a [SettlementId] can never
/// compare equal to a [PaymentId], even when both wrap the same text value.
abstract base class FinancialIdentifier {
  FinancialIdentifier({required String value, required String identifierType})
    : value = _validate(value, identifierType);

  /// Canonical identifier value with surrounding whitespace removed.
  final String value;

  static String _validate(String value, String identifierType) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      throw InvalidFinancialIdentifierException(
        identifierType: identifierType,
        value: value,
      );
    }
    return normalized;
  }

  /// Primitive representation used at application and infrastructure edges.
  String toPrimitive() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is FinancialIdentifier &&
          other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => '$runtimeType($value)';
}
