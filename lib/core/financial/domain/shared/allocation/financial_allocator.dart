import '../calculation/financial_calculator.dart';
import '../money/money.dart';
import 'financial_allocation.dart';
import 'financial_allocation_request.dart';
import 'financial_allocation_result.dart';
import 'financial_allocation_validator.dart';

/// Central engine responsible for splitting a monetary amount
/// into deterministic financial allocations.
///
/// Guarantees:
/// - no floating-point arithmetic;
/// - preservation of the original currency;
/// - immutable allocation results;
/// - no loss of minor monetary units.
///
/// Any remaining minor units caused by rounding are assigned
/// to the final allocation.
final class FinancialAllocator {
  const FinancialAllocator._();

  /// Allocates [amount] according to the supplied [requests].
  ///
  /// The returned result contains:
  /// - the original amount;
  /// - all generated allocations;
  /// - the total allocated amount;
  /// - balance and remainder information.
  static FinancialAllocationResult<T> allocate<T>({
    required Money amount,
    required List<FinancialAllocationRequest<T>> requests,
  }) {
    // Validate allocation requests before calculation.
    FinancialAllocationValidator.validateRequests(requests);

    final List<FinancialAllocation<T>> allocations = <FinancialAllocation<T>>[];

    int allocatedMinorUnits = 0;

    for (int index = 0; index < requests.length; index++) {
      final FinancialAllocationRequest<T> request = requests[index];

      final bool isLastRequest = index == requests.length - 1;

      late final Money allocationAmount;

      if (isLastRequest) {
        allocationAmount = Money(
          minorUnits: amount.minorUnits - allocatedMinorUnits,
          currency: amount.currency,
        );
      } else {
        allocationAmount = FinancialCalculator.calculatePercentage(
          amount,
          request.rate,
        );

        allocatedMinorUnits += allocationAmount.minorUnits;
      }

      allocations.add(
        FinancialAllocation<T>(
          key: request.key,
          rate: request.rate,
          amount: allocationAmount,
        ),
      );
    }

    final List<FinancialAllocation<T>> immutableAllocations =
        List<FinancialAllocation<T>>.unmodifiable(allocations);

    final Money totalAllocated = total(immutableAllocations);

    final FinancialAllocationResult<T> result = FinancialAllocationResult<T>(
      originalAmount: amount,
      allocations: immutableAllocations,
      totalAllocated: totalAllocated,
    );

    // Validate the generated allocation result.
    FinancialAllocationValidator.validateResult(result);

    return result;
  }

  /// Calculates the total amount represented by [allocations].
  ///
  /// All allocations must use the same currency.
  static Money total<T>(Iterable<FinancialAllocation<T>> allocations) {
    final List<FinancialAllocation<T>> allocationList =
        List<FinancialAllocation<T>>.unmodifiable(allocations);

    if (allocationList.isEmpty) {
      throw ArgumentError('Allocations cannot be empty.');
    }

    Money totalAmount = Money.zero(allocationList.first.amount.currency);

    for (final FinancialAllocation<T> allocation in allocationList) {
      totalAmount = totalAmount.add(allocation.amount);
    }

    return totalAmount;
  }

  /// Verifies that allocations equal the expected amount.
  static bool validate<T>({
    required Money expected,
    required Iterable<FinancialAllocation<T>> allocations,
  }) {
    final List<FinancialAllocation<T>> allocationList =
        List<FinancialAllocation<T>>.unmodifiable(allocations);

    if (allocationList.isEmpty) {
      return expected.minorUnits == 0;
    }

    return total(allocationList) == expected;
  }

  /// Verifies that an allocation result is perfectly balanced.
  static bool validateResult<T>(FinancialAllocationResult<T> result) {
    return result.isBalanced && result.remainder.minorUnits == 0;
  }
}
