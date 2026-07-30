import '../money/money.dart';
import 'financial_allocation.dart';

/// Represents the immutable result of a financial allocation.
///
/// It contains:
/// - the original amount;
/// - every generated allocation;
/// - the total allocated amount;
/// - whether the allocation is perfectly balanced.
final class FinancialAllocationResult<T> {
  const FinancialAllocationResult({
    required this.originalAmount,
    required this.allocations,
    required this.totalAllocated,
  });

  /// Original amount before allocation.
  final Money originalAmount;

  /// Generated allocations.
  final List<FinancialAllocation<T>> allocations;

  /// Sum of all allocated amounts.
  final Money totalAllocated;

  /// Returns true when every unit of money has been allocated.
  bool get isBalanced => originalAmount == totalAllocated;

  /// Remaining amount that has not been allocated.
  ///
  /// Normally this should always be zero when the allocator
  /// has completed successfully.
  Money get remainder => originalAmount.subtract(totalAllocated);

  /// Number of generated allocations.
  int get allocationCount => allocations.length;

  /// Returns true when no allocations exist.
  bool get isEmpty => allocations.isEmpty;

  /// Returns true when at least one allocation exists.
  bool get isNotEmpty => allocations.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FinancialAllocationResult<T> &&
            other.originalAmount == originalAmount &&
            other.totalAllocated == totalAllocated &&
            _listEquals(other.allocations, allocations);
  }

  @override
  int get hashCode =>
      Object.hash(originalAmount, totalAllocated, Object.hashAll(allocations));

  @override
  String toString() {
    return 'FinancialAllocationResult<$T>('
        'originalAmount: $originalAmount, '
        'totalAllocated: $totalAllocated, '
        'allocationCount: $allocationCount, '
        'isBalanced: $isBalanced'
        ')';
  }

  static bool _listEquals<E>(List<E> first, List<E> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (int i = 0; i < first.length; i++) {
      if (first[i] != second[i]) {
        return false;
      }
    }

    return true;
  }
}
