import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/transaction/state/'
    'financial_transaction_state.dart';

void main() {
  group('FinancialTransactionState', () {
    test('should expose the complete transaction lifecycle', () {
      expect(FinancialTransactionState.values, [
        FinancialTransactionState.idle,
        FinancialTransactionState.active,
        FinancialTransactionState.committed,
        FinancialTransactionState.rolledBack,
        FinancialTransactionState.failed,
      ]);
    });
  });
}
