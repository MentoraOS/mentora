import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/balance/'
    'ledger_normal_balance_calculator.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_account_type.dart';

void main() {
  group('LedgerNormalBalanceCalculator', () {
    const calculator = LedgerNormalBalanceCalculator();

    test('calculates an asset using debit minus credit', () {
      final result = calculator.calculate(
        accountType: LedgerAccountType.asset,
        debitMinor: 1000,
        creditMinor: 300,
      );

      expect(result, 700);
    });

    test('calculates an expense using debit minus credit', () {
      final result = calculator.calculate(
        accountType: LedgerAccountType.expense,
        debitMinor: 900,
        creditMinor: 100,
      );

      expect(result, 800);
    });

    test('calculates a liability using credit minus debit', () {
      final result = calculator.calculate(
        accountType: LedgerAccountType.liability,
        debitMinor: 200,
        creditMinor: 1000,
      );

      expect(result, 800);
    });

    test('calculates equity using credit minus debit', () {
      final result = calculator.calculate(
        accountType: LedgerAccountType.equity,
        debitMinor: 100,
        creditMinor: 900,
      );

      expect(result, 800);
    });

    test('calculates revenue using credit minus debit', () {
      final result = calculator.calculate(
        accountType: LedgerAccountType.revenue,
        debitMinor: 300,
        creditMinor: 1200,
      );

      expect(result, 900);
    });

    test('identifies debit-normal accounts', () {
      expect(calculator.hasDebitNormalSide(LedgerAccountType.asset), isTrue);

      expect(calculator.hasDebitNormalSide(LedgerAccountType.expense), isTrue);

      expect(calculator.hasDebitNormalSide(LedgerAccountType.revenue), isFalse);
    });

    test('identifies credit-normal accounts', () {
      expect(
        calculator.hasCreditNormalSide(LedgerAccountType.liability),
        isTrue,
      );

      expect(calculator.hasCreditNormalSide(LedgerAccountType.equity), isTrue);

      expect(calculator.hasCreditNormalSide(LedgerAccountType.asset), isFalse);
    });

    test('supports zero balances', () {
      final result = calculator.calculate(
        accountType: LedgerAccountType.asset,
        debitMinor: 500,
        creditMinor: 500,
      );

      expect(result, 0);
    });

    test('rejects a negative debit amount', () {
      expect(
        () => calculator.calculate(
          accountType: LedgerAccountType.asset,
          debitMinor: -1,
          creditMinor: 0,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a negative credit amount', () {
      expect(
        () => calculator.calculate(
          accountType: LedgerAccountType.revenue,
          debitMinor: 0,
          creditMinor: -1,
        ),
        throwsArgumentError,
      );
    });
  });
}
