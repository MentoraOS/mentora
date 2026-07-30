import '../../primitives/percentage/percentage.dart';

/// Represents an allocation request before any monetary calculation.
///
/// It specifies:
///
/// - who (or what) receives a share;
/// - which percentage should be applied.
///
/// The actual monetary amount is calculated later by the
/// Financial Allocation Engine.
final class FinancialAllocationRequest<T> {
  const FinancialAllocationRequest({required this.key, required this.rate});

  /// Allocation target.
  final T key;

  /// Percentage assigned to this target.
  final Percentage rate;

  /// Returns true when the requested rate is 0%.
  bool get isZero => rate.isZero;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FinancialAllocationRequest<T> &&
            other.key == key &&
            other.rate == rate;
  }

  @override
  int get hashCode => Object.hash(key, rate);

  @override
  String toString() {
    return 'FinancialAllocationRequest<$T>('
        'key: $key, '
        'rate: $rate'
        ')';
  }
}
