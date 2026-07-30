import 'ledger_trial_balance_entry.dart';

/// Represents a complete accounting trial balance.
///
/// A valid trial balance must satisfy:
///
/// total debits == total credits
final class LedgerTrialBalance {
  LedgerTrialBalance({required List<LedgerTrialBalanceEntry> entries})
    : entries = List.unmodifiable(entries);

  /// Aggregated account balances.
  final List<LedgerTrialBalanceEntry> entries;

  /// Number of accounts.
  int get accountCount => entries.length;

  /// Number of journal entries represented.
  int get entryCount => entries.fold(0, (sum, entry) => sum + entry.entryCount);

  /// Total debits.
  int get totalDebitMinor =>
      entries.fold(0, (sum, entry) => sum + entry.totalDebitMinor);

  /// Total credits.
  int get totalCreditMinor =>
      entries.fold(0, (sum, entry) => sum + entry.totalCreditMinor);

  /// Debit minus credit.
  int get balanceMinor => totalDebitMinor - totalCreditMinor;

  /// Whether the ledger is perfectly balanced.
  bool get isBalanced => totalDebitMinor == totalCreditMinor;

  /// All currencies represented.
  Set<String> get currencies => entries.map((entry) => entry.currency).toSet();

  LedgerTrialBalanceEntry? account(String accountId) {
    for (final entry in entries) {
      if (entry.accountId == accountId) {
        return entry;
      }
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'accountCount': accountCount,
      'entryCount': entryCount,
      'totalDebitMinor': totalDebitMinor,
      'totalCreditMinor': totalCreditMinor,
      'balanceMinor': balanceMinor,
      'isBalanced': isBalanced,
      'currencies': currencies.toList(),
    };
  }

  @override
  String toString() {
    return 'LedgerTrialBalance('
        'accounts: $accountCount, '
        'entries: $entryCount, '
        'debit: $totalDebitMinor, '
        'credit: $totalCreditMinor, '
        'balanced: $isBalanced'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerTrialBalance && _listEquals(other.entries, entries);
  }

  @override
  int get hashCode => Object.hashAll(entries);

  static bool _listEquals(
    List<LedgerTrialBalanceEntry> a,
    List<LedgerTrialBalanceEntry> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }
}
