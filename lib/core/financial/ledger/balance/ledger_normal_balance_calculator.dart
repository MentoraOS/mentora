import '../models/ledger_account_type.dart';

/// Calculates an account balance according to its normal accounting side.
///
/// Normal debit accounts:
/// - asset;
/// - expense.
///
/// Normal credit accounts:
/// - liability;
/// - equity;
/// - revenue.
final class LedgerNormalBalanceCalculator {
  const LedgerNormalBalanceCalculator();

  int calculate({
    required LedgerAccountType accountType,
    required int debitMinor,
    required int creditMinor,
  }) {
    if (debitMinor < 0) {
      throw ArgumentError.value(
        debitMinor,
        'debitMinor',
        'Debit amount cannot be negative.',
      );
    }

    if (creditMinor < 0) {
      throw ArgumentError.value(
        creditMinor,
        'creditMinor',
        'Credit amount cannot be negative.',
      );
    }

    return switch (accountType) {
      LedgerAccountType.asset ||
      LedgerAccountType.expense => debitMinor - creditMinor,

      LedgerAccountType.liability ||
      LedgerAccountType.equity ||
      LedgerAccountType.revenue => creditMinor - debitMinor,
    };
  }

  bool hasDebitNormalSide(LedgerAccountType accountType) {
    return switch (accountType) {
      LedgerAccountType.asset || LedgerAccountType.expense => true,

      LedgerAccountType.liability ||
      LedgerAccountType.equity ||
      LedgerAccountType.revenue => false,
    };
  }

  bool hasCreditNormalSide(LedgerAccountType accountType) {
    return !hasDebitNormalSide(accountType);
  }
}
