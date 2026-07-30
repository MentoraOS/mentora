import '../models/ledger_account.dart';
import 'account_registry.dart';
import 'default_accounts.dart';

class ChartOfAccounts {
  final AccountRegistry registry;

  const ChartOfAccounts({required this.registry});

  void initializeCurrency(String currency) {
    registry.registerAll([
      DefaultAccounts.platformCash(currency: currency),
      DefaultAccounts.clearing(currency: currency),
      DefaultAccounts.platformRevenue(currency: currency),
      DefaultAccounts.commissionRevenue(currency: currency),
      DefaultAccounts.taxPayable(currency: currency),
      DefaultAccounts.affiliatePayable(currency: currency),
      DefaultAccounts.partnerPayable(currency: currency),
      DefaultAccounts.refundReserve(currency: currency),
      DefaultAccounts.fxReserve(currency: currency),
    ]);
  }

  LedgerAccount ensureClientWallet({
    required String clientId,
    required String currency,
  }) {
    final account = DefaultAccounts.clientWallet(
      clientId: clientId,
      currency: currency,
    );

    registry.register(account);

    return registry.getRequired(account.id);
  }

  LedgerAccount ensureExpertWallet({
    required String expertId,
    required String currency,
  }) {
    final account = DefaultAccounts.expertWallet(
      expertId: expertId,
      currency: currency,
    );

    registry.register(account);

    return registry.getRequired(account.id);
  }

  LedgerAccount ensureEscrow({
    required String consultationId,
    required String currency,
  }) {
    final account = DefaultAccounts.escrow(
      consultationId: consultationId,
      currency: currency,
    );

    registry.register(account);

    return registry.getRequired(account.id);
  }

  LedgerAccount platformCash(String currency) {
    return registry.getRequired(
      DefaultAccounts.platformCash(currency: currency).id,
    );
  }

  LedgerAccount clearing(String currency) {
    return registry.getRequired(
      DefaultAccounts.clearing(currency: currency).id,
    );
  }

  LedgerAccount platformRevenue(String currency) {
    return registry.getRequired(
      DefaultAccounts.platformRevenue(currency: currency).id,
    );
  }

  LedgerAccount commissionRevenue(String currency) {
    return registry.getRequired(
      DefaultAccounts.commissionRevenue(currency: currency).id,
    );
  }

  LedgerAccount taxPayable(String currency) {
    return registry.getRequired(
      DefaultAccounts.taxPayable(currency: currency).id,
    );
  }

  LedgerAccount affiliatePayable(String currency) {
    return registry.getRequired(
      DefaultAccounts.affiliatePayable(currency: currency).id,
    );
  }

  LedgerAccount partnerPayable(String currency) {
    return registry.getRequired(
      DefaultAccounts.partnerPayable(currency: currency).id,
    );
  }

  /// Compte utilisé pour les frais dus au prestataire de paiement.
  ///
  /// Tant qu’un compte PSP dédié n’existe pas dans DefaultAccounts,
  /// ces frais transitent par le compte de clearing.
  LedgerAccount paymentProviderPayable(String currency) {
    return clearing(currency);
  }

  LedgerAccount refundReserve(String currency) {
    return registry.getRequired(
      DefaultAccounts.refundReserve(currency: currency).id,
    );
  }

  LedgerAccount getRequiredAccount(String accountId) {
    return registry.getRequired(accountId);
  }

  bool containsAccount(String accountId) {
    return registry.contains(accountId);
  }
}
