import '../shared/money/money.dart';
import 'consultation_settlement.dart';
import 'settlement_exception.dart';

/// Validates the business invariants of a consultation settlement.
abstract final class SettlementValidator {
  SettlementValidator._();

  /// Validates a settlement and throws if an invariant is violated.
  static void validate(ConsultationSettlement settlement) {
    if (settlement.isEmpty) {
      throw const SettlementException(
        'A settlement must contain at least one settlement line.',
      );
    }

    final Money firstAmount = settlement.lines.first.amount;

    for (final line in settlement.lines) {
      if (line.amount.currency != firstAmount.currency) {
        throw SettlementException(
          'All settlement lines must use the same currency.',
          details: <String, Object?>{
            'expectedCurrency': firstAmount.currency.code,
            'actualCurrency': line.amount.currency.code,
            'party': line.party.name,
          },
        );
      }
    }
  }

  /// Returns true when the settlement respects all domain invariants.
  static bool isValid(ConsultationSettlement settlement) {
    try {
      validate(settlement);
      return true;
    } on SettlementException {
      return false;
    }
  }
}
