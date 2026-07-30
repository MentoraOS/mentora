import '../../primitives/percentage/percentage.dart';
import 'allocation_exception.dart';
import 'financial_allocation_request.dart';
import 'financial_allocation_result.dart';

/// Central validator for financial allocation operations.
///
/// It validates allocation requests before calculation and verifies
/// generated allocation results after calculation.
final class FinancialAllocationValidator {
  const FinancialAllocationValidator._();

  /// Validates a complete collection of allocation requests.
  ///
  /// Guarantees that:
  /// - at least one request exists;
  /// - every key is unique;
  /// - every rate is between 0% and 100%;
  /// - all rates total exactly 100%.
  static void validateRequests<T>(
    Iterable<FinancialAllocationRequest<T>> requests,
  ) {
    final List<FinancialAllocationRequest<T>> requestList =
        List<FinancialAllocationRequest<T>>.unmodifiable(requests);

    if (requestList.isEmpty) {
      throw const FinancialAllocationException(
        message: 'Allocation requests cannot be empty.',
      );
    }

    _validateUniqueKeys(requestList);
    _validateRates(requestList);
    _validateRateTotal(requestList);
  }

  /// Validates the result produced by the allocation engine.
  ///
  /// Guarantees that:
  /// - at least one allocation exists;
  /// - all allocated amounts use the original currency;
  /// - the allocated total equals the original amount.
  static void validateResult<T>(FinancialAllocationResult<T> result) {
    if (result.allocations.isEmpty) {
      throw const FinancialAllocationException(
        message: 'Allocation result cannot be empty.',
      );
    }

    for (final allocation in result.allocations) {
      if (allocation.amount.currency != result.originalAmount.currency) {
        throw FinancialAllocationException(
          message: 'Every allocation must use the original currency.',
          details: <String, Object?>{
            'expectedCurrency': result.originalAmount.currency.toString(),
            'actualCurrency': allocation.amount.currency.toString(),
            'allocationKey': allocation.key.toString(),
          },
        );
      }
    }

    if (result.totalAllocated.currency != result.originalAmount.currency) {
      throw FinancialAllocationException(
        message: 'The allocated total must use the original currency.',
        details: <String, Object?>{
          'expectedCurrency': result.originalAmount.currency.toString(),
          'actualCurrency': result.totalAllocated.currency.toString(),
        },
      );
    }

    if (!result.isBalanced) {
      throw FinancialAllocationException(
        message: 'The allocation result must equal the original amount.',
        details: <String, Object?>{
          'originalMinorUnits': result.originalAmount.minorUnits,
          'allocatedMinorUnits': result.totalAllocated.minorUnits,
        },
      );
    }
  }

  /// Returns true when requests satisfy every allocation invariant.
  static bool areRequestsValid<T>(
    Iterable<FinancialAllocationRequest<T>> requests,
  ) {
    try {
      validateRequests(requests);
      return true;
    } on FinancialAllocationException {
      return false;
    }
  }

  /// Returns true when the result satisfies every allocation invariant.
  static bool isResultValid<T>(FinancialAllocationResult<T> result) {
    try {
      validateResult(result);
      return true;
    } on FinancialAllocationException {
      return false;
    }
  }

  static void _validateUniqueKeys<T>(
    List<FinancialAllocationRequest<T>> requests,
  ) {
    final Set<T> encounteredKeys = <T>{};

    for (final request in requests) {
      if (!encounteredKeys.add(request.key)) {
        throw FinancialAllocationException(
          message: 'Allocation request keys must be unique.',
          details: <String, Object?>{'duplicateKey': request.key.toString()},
        );
      }
    }
  }

  static void _validateRates<T>(List<FinancialAllocationRequest<T>> requests) {
    for (final request in requests) {
      final int partsPerMillion = request.rate.partsPerMillion;

      if (partsPerMillion < Percentage.zero.partsPerMillion ||
          partsPerMillion > Percentage.partsPerMillionInOneHundredPercent) {
        throw FinancialAllocationException(
          message: 'Every allocation rate must be between 0% and 100%.',
          details: <String, Object?>{
            'allocationKey': request.key.toString(),
            'actualPartsPerMillion': partsPerMillion,
          },
        );
      }
    }
  }

  static void _validateRateTotal<T>(
    List<FinancialAllocationRequest<T>> requests,
  ) {
    final int totalPartsPerMillion = requests.fold<int>(0, (
      int currentTotal,
      FinancialAllocationRequest<T> request,
    ) {
      return currentTotal + request.rate.partsPerMillion;
    });

    if (totalPartsPerMillion != Percentage.partsPerMillionInOneHundredPercent) {
      throw FinancialAllocationException(
        message: 'Allocation rates must total exactly 100%.',
        details: <String, Object?>{
          'expectedPartsPerMillion':
              Percentage.partsPerMillionInOneHundredPercent,
          'actualPartsPerMillion': totalPartsPerMillion,
        },
      );
    }
  }
}
