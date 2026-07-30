// Aggregated activity for a single ledger account.
//
// This is a read-side model used for reporting and analytics.
final class LedgerAccountActivity {
  const LedgerAccountActivity({
    required this.accountId,
    required this.currency,
    required this.entryCount,
    required this.totalDebitMinor,
    required this.totalCreditMinor,
  }) : assert(accountId.length > 1),
       assert(currency.length >= 3),
       assert(entryCount >= 0),
       assert(totalDebitMinor >= 0),
       assert(totalCreditMinor >= 0);

  // Ledger account identifier.
  final String accountId;

  // Currency.
  final String currency;

  // Number of journal entries touching this account.
  final int entryCount;

  // Total debit amount.
  final int totalDebitMinor;

  // Total credit amount.
  final int totalCreditMinor;

  // Net balance.
  //
  // Positive means debit balance.
  // Negative means credit balance.
  int get balanceMinor => totalDebitMinor - totalCreditMinor;

  bool get isDebitBalance => balanceMinor > 0;

  bool get isCreditBalance => balanceMinor < 0;

  bool get isBalanced => balanceMinor == 0;

  LedgerAccountActivity copyWith({
    String? accountId,
    String? currency,
    int? entryCount,
    int? totalDebitMinor,
    int? totalCreditMinor,
  }) {
    return LedgerAccountActivity(
      accountId: accountId ?? this.accountId,
      currency: currency ?? this.currency,
      entryCount: entryCount ?? this.entryCount,
      totalDebitMinor: totalDebitMinor ?? this.totalDebitMinor,
      totalCreditMinor: totalCreditMinor ?? this.totalCreditMinor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'currency': currency,
      'entryCount': entryCount,
      'totalDebitMinor': totalDebitMinor,
      'totalCreditMinor': totalCreditMinor,
      'balanceMinor': balanceMinor,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerAccountActivity &&
            other.accountId == accountId &&
            other.currency == currency &&
            other.entryCount == entryCount &&
            other.totalDebitMinor == totalDebitMinor &&
            other.totalCreditMinor == totalCreditMinor;
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    currency,
    entryCount,
    totalDebitMinor,
    totalCreditMinor,
  );

  @override
  String toString() {
    return 'LedgerAccountActivity('
        'accountId: $accountId, '
        'currency: $currency, '
        'entryCount: $entryCount, '
        'totalDebitMinor: $totalDebitMinor, '
        'totalCreditMinor: $totalCreditMinor, '
        'balanceMinor: $balanceMinor'
        ')';
  }
}
