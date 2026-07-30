import '../shared/money/money.dart';
import '../shared/rates/financial_rate.dart';
import 'settlement_party.dart';

/// Represents a single financial line inside a settlement.
///
/// Each line associates:
/// - a beneficiary;
/// - a financial rate;
/// - the allocated monetary amount.
///
/// Example:
///
/// Expert
///     85%
///     8 500 XOF
///
/// Platform
///     15%
///     1 500 XOF
final class SettlementLine {
  const SettlementLine({
    required this.party,
    required this.rate,
    required this.amount,
  });

  /// Beneficiary of this settlement line.
  final SettlementParty party;

  /// Financial rate applied.
  final FinancialRate rate;

  /// Allocated amount.
  final Money amount;

  /// Returns true when no money has been allocated.
  bool get isZero => amount.isZero;

  /// Returns true when money has been allocated.
  bool get isPositive => !amount.isZero;

  SettlementLine copyWith({
    SettlementParty? party,
    FinancialRate? rate,
    Money? amount,
  }) {
    return SettlementLine(
      party: party ?? this.party,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SettlementLine &&
            other.party == party &&
            other.rate == rate &&
            other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(party, rate, amount);

  @override
  String toString() {
    return 'SettlementLine('
        'party: $party, '
        'rate: $rate, '
        'amount: $amount'
        ')';
  }
}
