/// One aggregated account line inside a trial balance.
///
/// A trial balance entry groups every posted journal entry for one
/// accounting account and one currency.
final class LedgerTrialBalanceEntry {
  const LedgerTrialBalanceEntry({
    required this.accountId,
    required this.currency,
    required this.totalDebitMinor,
    required this.totalCreditMinor,
    required this.entryCount,
  }) : assert(accountId.length > 1),
       assert(currency.length >= 3),
       assert(totalDebitMinor >= 0),
       assert(totalCreditMinor >= 0),
       assert(entryCount >= 0);

  /// Accounting account identifier.
  final String accountId;

  /// Currency of the aggregated amounts.
  final String currency;

  /// Sum of debit entries for this account.
  final int totalDebitMinor;

  /// Sum of credit entries for this account.
  final int totalCreditMinor;

  /// Number of journal entries included in the aggregation.
  final int entryCount;

  /// Debit minus credit.
  ///
  /// Positive values represent a debit balance.
  /// Negative values represent a credit balance.
  int get balanceMinor => totalDebitMinor - totalCreditMinor;

  bool get hasDebitBalance => balanceMinor > 0;

  bool get hasCreditBalance => balanceMinor < 0;

  bool get isZeroBalance => balanceMinor == 0;

  LedgerTrialBalanceEntry copyWith({
    String? accountId,
    String? currency,
    int? totalDebitMinor,
    int? totalCreditMinor,
    int? entryCount,
  }) {
    return LedgerTrialBalanceEntry(
      accountId: accountId ?? this.accountId,
      currency: currency ?? this.currency,
      totalDebitMinor: totalDebitMinor ?? this.totalDebitMinor,
      totalCreditMinor: totalCreditMinor ?? this.totalCreditMinor,
      entryCount: entryCount ?? this.entryCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'currency': currency,
      'totalDebitMinor': totalDebitMinor,
      'totalCreditMinor': totalCreditMinor,
      'entryCount': entryCount,
      'balanceMinor': balanceMinor,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerTrialBalanceEntry &&
            other.accountId == accountId &&
            other.currency == currency &&
            other.totalDebitMinor == totalDebitMinor &&
            other.totalCreditMinor == totalCreditMinor &&
            other.entryCount == entryCount;
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    currency,
    totalDebitMinor,
    totalCreditMinor,
    entryCount,
  );

  @override
  String toString() {
    return 'LedgerTrialBalanceEntry('
        'accountId: $accountId, '
        'currency: $currency, '
        'totalDebitMinor: $totalDebitMinor, '
        'totalCreditMinor: $totalCreditMinor, '
        'entryCount: $entryCount, '
        'balanceMinor: $balanceMinor'
        ')';
  }
}
