import '../models/ledger_account.dart';
import '../models/ledger_account_type.dart';

class DefaultAccounts {
  const DefaultAccounts._();

  static const String platformOwnerId = 'mentora_platform';

  static LedgerAccount platformCash({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'platform_cash_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.asset,
      name: 'Platform Cash $normalizedCurrency',
    );
  }

  static LedgerAccount clearing({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'platform_clearing_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.asset,
      name: 'Payment Clearing $normalizedCurrency',
    );
  }

  static LedgerAccount platformRevenue({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'platform_revenue_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.revenue,
      name: 'Platform Revenue $normalizedCurrency',
    );
  }

  static LedgerAccount commissionRevenue({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'commission_revenue_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.revenue,
      name: 'Commission Revenue $normalizedCurrency',
    );
  }

  static LedgerAccount taxPayable({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'tax_payable_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Tax Payable $normalizedCurrency',
    );
  }

  static LedgerAccount affiliatePayable({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'affiliate_payable_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Affiliate Payable $normalizedCurrency',
    );
  }

  static LedgerAccount partnerPayable({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'partner_payable_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Partner Payable $normalizedCurrency',
    );
  }

  static LedgerAccount refundReserve({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'refund_reserve_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Refund Reserve $normalizedCurrency',
    );
  }

  static LedgerAccount fxReserve({required String currency}) {
    final normalizedCurrency = _normalizeCurrency(currency);

    return LedgerAccount(
      id: 'fx_reserve_$normalizedCurrency',
      ownerId: platformOwnerId,
      currency: normalizedCurrency,
      type: LedgerAccountType.asset,
      name: 'FX Reserve $normalizedCurrency',
    );
  }

  static LedgerAccount clientWallet({
    required String clientId,
    required String currency,
  }) {
    final normalizedCurrency = _normalizeCurrency(currency);
    final normalizedClientId = _normalizeId(clientId);

    return LedgerAccount(
      id:
          'client_wallet_'
          '${normalizedClientId}_'
          '$normalizedCurrency',
      ownerId: clientId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Client Wallet $normalizedCurrency',
    );
  }

  static LedgerAccount expertWallet({
    required String expertId,
    required String currency,
  }) {
    final normalizedCurrency = _normalizeCurrency(currency);
    final normalizedExpertId = _normalizeId(expertId);

    return LedgerAccount(
      id:
          'expert_wallet_'
          '${normalizedExpertId}_'
          '$normalizedCurrency',
      ownerId: expertId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Expert Wallet $normalizedCurrency',
    );
  }

  static LedgerAccount escrow({
    required String consultationId,
    required String currency,
  }) {
    final normalizedCurrency = _normalizeCurrency(currency);
    final normalizedConsultationId = _normalizeId(consultationId);

    return LedgerAccount(
      id:
          'escrow_'
          '${normalizedConsultationId}_'
          '$normalizedCurrency',
      ownerId: consultationId,
      currency: normalizedCurrency,
      type: LedgerAccountType.liability,
      name: 'Consultation Escrow $normalizedCurrency',
    );
  }

  static String _normalizeCurrency(String currency) {
    final normalized = currency.trim().toUpperCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        currency,
        'currency',
        'Currency cannot be empty',
      );
    }

    return normalized;
  }

  static String _normalizeId(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'value',
        'Account owner identifier cannot be empty',
      );
    }

    return normalized.replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
  }
}
