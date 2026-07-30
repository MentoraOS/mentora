/// Identifies the accounting purpose of a settlement posting line.
///
/// This orchestration-level type preserves the complete financial meaning
/// of every settlement beneficiary before the instruction reaches the Ledger.
///
/// It is intentionally independent from [PostingType], because the Ledger
/// posting model may evolve separately from the Settlement Domain.
enum SettlementPostingCategory {
  /// Revenue released to the consultation expert.
  expertRevenue,

  /// Commission retained by the Mentora platform.
  platformRevenue,

  /// Tax amount owed to a government authority.
  taxPayable,

  /// Fee retained by the payment provider.
  paymentProviderFee,

  /// Commission owed to an affiliate.
  affiliateCommission,

  /// Commission or revenue share owed to a business partner.
  partnerCommission;

  bool get isExpertRevenue => this == SettlementPostingCategory.expertRevenue;

  bool get isPlatformRevenue =>
      this == SettlementPostingCategory.platformRevenue;

  bool get isTaxPayable => this == SettlementPostingCategory.taxPayable;

  bool get isPaymentProviderFee =>
      this == SettlementPostingCategory.paymentProviderFee;

  bool get isAffiliateCommission =>
      this == SettlementPostingCategory.affiliateCommission;

  bool get isPartnerCommission =>
      this == SettlementPostingCategory.partnerCommission;

  /// Returns true when the line represents platform-owned revenue.
  bool get isInternalRevenue => isPlatformRevenue;

  /// Returns true when the line represents money owed outside the platform.
  bool get isExternalObligation =>
      isTaxPayable ||
      isPaymentProviderFee ||
      isAffiliateCommission ||
      isPartnerCommission;
}
