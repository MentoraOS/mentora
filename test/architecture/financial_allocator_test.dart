import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/shared/allocation/financial_allocation_request.dart';
import 'package:mentora/core/financial/domain/shared/allocation/financial_allocator.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';

void main() {
  group('FinancialAllocator', () {
    test('allocates 100% correctly', () {
      final Money amount = Money(
        minorUnits: 10000,
        currency: FinancialCurrency.xof,
      );

      final result = FinancialAllocator.allocate<String>(
        amount: amount,
        requests: [
          FinancialAllocationRequest(
            key: 'expert',
            rate: Percentage.oneHundred,
          ),
        ],
      );

      expect(result.isBalanced, isTrue);
      expect(result.remainder.minorUnits, 0);
      expect(result.totalAllocated.minorUnits, 10000);
      expect(result.allocations.length, 1);
      expect(result.allocations.first.amount.minorUnits, 10000);
    });

    test('allocates 85/15 correctly', () {
      final Money amount = Money(
        minorUnits: 10000,
        currency: FinancialCurrency.xof,
      );

      final result = FinancialAllocator.allocate<String>(
        amount: amount,
        requests: [
          FinancialAllocationRequest(
            key: 'expert',
            rate: Percentage.fromWholePercent(85),
          ),
          FinancialAllocationRequest(
            key: 'platform',
            rate: Percentage.fromWholePercent(15),
          ),
        ],
      );

      expect(result.isBalanced, isTrue);

      expect(result.allocations[0].amount.minorUnits, 8500);

      expect(result.allocations[1].amount.minorUnits, 1500);

      expect(result.totalAllocated.minorUnits, 10000);
    });

    test('never loses one minor unit', () {
      final Money amount = Money(
        minorUnits: 100,
        currency: FinancialCurrency.xof,
      );

      final result = FinancialAllocator.allocate<String>(
        amount: amount,
        requests: [
          FinancialAllocationRequest(
            key: 'A',
            rate: Percentage.fromWholePercent(33),
          ),
          FinancialAllocationRequest(
            key: 'B',
            rate: Percentage.fromWholePercent(33),
          ),
          FinancialAllocationRequest(
            key: 'C',
            rate: Percentage.fromWholePercent(34),
          ),
        ],
      );

      expect(result.isBalanced, isTrue);

      expect(result.totalAllocated.minorUnits, 100);

      expect(result.remainder.minorUnits, 0);
    });

    test('validateResult returns true', () {
      final Money amount = Money(
        minorUnits: 10000,
        currency: FinancialCurrency.xof,
      );

      final result = FinancialAllocator.allocate<String>(
        amount: amount,
        requests: [
          FinancialAllocationRequest(
            key: 'expert',
            rate: Percentage.oneHundred,
          ),
        ],
      );

      expect(FinancialAllocator.validateResult(result), isTrue);
    });
  });
}
