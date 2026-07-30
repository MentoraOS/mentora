import '../../../../domain/settlement/settlement_party.dart';
import '../../../../domain/shared/money/money.dart';

import 'settlement_posting_category.dart';

/// Represents one technical posting line derived from a settlement.
///
/// This model belongs to the orchestration layer, not to the Settlement
/// Domain. It enriches a domain settlement line with the accounting
/// information required by the Ledger.
final class SettlementPostingLine {
  SettlementPostingLine({
    required this.party,
    required this.category,
    required this.amount,
    required String code,
    required String label,
  }) : code = _normalizeRequired(value: code, fieldName: 'code'),
       label = _normalizeRequired(value: label, fieldName: 'label');

  /// Settlement beneficiary represented by this posting line.
  final SettlementParty party;

  /// Stable accounting category carried toward the Ledger boundary.
  final SettlementPostingCategory category;

  /// Amount that must be posted to the Ledger.
  final Money amount;

  /// Stable accounting code used to identify this posting.
  final String code;

  /// Human-readable accounting description.
  final String label;

  bool get isPositive => amount.isPositive;

  bool get isZero => amount.isZero;

  SettlementPostingLine copyWith({
    SettlementParty? party,
    SettlementPostingCategory? category,
    Money? amount,
    String? code,
    String? label,
  }) {
    return SettlementPostingLine(
      party: party ?? this.party,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      code: code ?? this.code,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SettlementPostingLine &&
            other.party == party &&
            other.category == category &&
            other.amount == amount &&
            other.code == code &&
            other.label == label;
  }

  @override
  int get hashCode => Object.hash(party, category, amount, code, label);

  @override
  String toString() {
    return 'SettlementPostingLine('
        'party: $party, '
        'category: $category, '
        'amount: $amount, '
        'code: $code, '
        'label: $label'
        ')';
  }

  static String _normalizeRequired({
    required String value,
    required String fieldName,
  }) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }

    return normalized;
  }
}
