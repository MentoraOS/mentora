import '../ledger/financial_ledger_factory.dart';
import 'wallet_balance.dart';

class WalletEngine {
  WalletEngine._();

  static Future<WalletBalance> expertBalance({
    required String expertId,
    required String currency,
  }) async {
    final ledger = FinancialLedgerFactory.firestore();

    final accountId = 'expert_wallet_$expertId';

    final balance = await ledger.balanceOf(accountId);

    return WalletBalance(
      ownerId: expertId,
      accountId: accountId,
      balance: balance,
      currency: currency,
    );
  }

  static Future<WalletBalance> platformRevenueBalance({
    required String countryCode,
    required String currency,
  }) async {
    final ledger = FinancialLedgerFactory.firestore();

    final accountId = 'platform_revenue_$countryCode';

    final balance = await ledger.balanceOf(accountId);

    return WalletBalance(
      ownerId: 'platform',
      accountId: accountId,
      balance: balance,
      currency: currency,
    );
  }
}
