/// Represents every participant that may receive
/// a portion of a financial settlement.
///
/// New parties can be added in the future without
/// affecting the Settlement Aggregate.
///
/// Examples:
/// - Affiliate commissions
/// - Sales partners
/// - Government taxes
/// - Referral rewards
enum SettlementParty {
  /// Consultation expert.
  expert,

  /// Mentora platform.
  platform,

  /// Government taxes (VAT, GST, etc.).
  tax,

  /// Payment provider fees.
  paymentProvider,

  /// Affiliate commission.
  affiliate,

  /// External business partner.
  partner;

  /// Returns true when this party represents
  /// the consultation expert.
  bool get isExpert => this == expert;

  /// Returns true when this party represents
  /// the Mentora platform.
  bool get isPlatform => this == platform;

  /// Returns true when this party represents
  /// taxes.
  bool get isTax => this == tax;

  /// Returns true when this party represents
  /// the payment provider.
  bool get isPaymentProvider => this == paymentProvider;

  /// Returns true when this party represents
  /// an affiliate.
  bool get isAffiliate => this == affiliate;

  /// Returns true when this party represents
  /// a business partner.
  bool get isPartner => this == partner;

  /// Returns true when this party belongs
  /// to the Mentora ecosystem.
  bool get isInternal => this == expert || this == platform;

  /// Returns true when this party is external
  /// to the Mentora platform.
  bool get isExternal => !isInternal;
}
