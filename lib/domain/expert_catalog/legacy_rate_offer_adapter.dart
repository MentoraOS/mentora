import 'consultation_offer.dart';
import 'expert_catalog_entry.dart';

/// The explicit legacy Expert Catalog duration tiers (AD-021 Clarification A).
enum LegacyConsultationTier {
  thirtyMinutes(30),
  sixtyMinutes(60),
  oneHundredTwentyMinutes(120);

  const LegacyConsultationTier(this.durationMinutes);

  final int durationMinutes;
}

/// Reads legacy `rate30` / `rate60` / `rate120` Catalog source data and emits
/// explicit Consultation Offers (AD-021 decisions 13 and 14).
///
/// This is an interoperability bridge, not a publication lifecycle. Per
/// Clarification A an offer is emitted only when the rate field exists on the
/// expert's canonical Catalog source data, its value is valid, expert
/// ownership is known, and the tier is one of the explicit legacy tiers. Per
/// Clarification B a legacy `num` rate converts to `amountMinor` only when it
/// is finite, non-negative and has no fractional component.
///
/// Absent source values remain absent. Invalid values fail closed. No
/// neighbouring tier, first tier, synthetic default or UI placeholder is ever
/// substituted.
final class LegacyRateOfferAdapter {
  const LegacyRateOfferAdapter();

  /// Deterministic, expert-owned, tier-specific offer identity.
  ///
  /// It depends on nothing presentational: no display index, no label, no
  /// formatted price.
  static String offerIdFor({
    required String expertId,
    required LegacyConsultationTier tier,
  }) {
    return 'expert:$expertId:consultation:${tier.durationMinutes}m';
  }

  /// Converts a legacy Catalog rate to `amountMinor`, or `null` when the
  /// source value cannot be represented without rounding, truncation or
  /// approximation (AD-021 Clarification B).
  ///
  /// For `XOF` an integer-valued legacy rate maps 1:1. There is no implicit
  /// multiplication by 100.
  static int? amountMinorFrom(num? rate) {
    if (rate == null) {
      return null;
    }
    if (rate is int) {
      return rate < 0 ? null : rate;
    }

    final value = rate.toDouble();
    if (!value.isFinite || value < 0 || value != value.truncateToDouble()) {
      return null;
    }

    return value.toInt();
  }

  /// Every client-selectable offer this expert currently exposes.
  ///
  /// Returns an empty list when expert ownership is unknown or no valid rate
  /// exists. It never fabricates an offer.
  List<ConsultationOffer> offersFor(ExpertCatalogEntry expert) {
    final expertId = expert.id.trim();
    if (expertId.isEmpty) {
      return const <ConsultationOffer>[];
    }

    final offers = <ConsultationOffer>[];
    for (final tier in LegacyConsultationTier.values) {
      final offer = _offerFor(expertId: expertId, expert: expert, tier: tier);
      if (offer != null) {
        offers.add(offer);
      }
    }

    return List<ConsultationOffer>.unmodifiable(offers);
  }

  ConsultationOffer? _offerFor({
    required String expertId,
    required ExpertCatalogEntry expert,
    required LegacyConsultationTier tier,
  }) {
    final amountMinor = amountMinorFrom(_rateFor(expert, tier));
    if (amountMinor == null) {
      return null;
    }

    return ConsultationOffer(
      offerId: offerIdFor(expertId: expertId, tier: tier),
      expertId: expertId,
      durationMinutes: tier.durationMinutes,
      amountMinor: amountMinor,
      currency: ConsultationOffer.launchCurrency,
      // Clarification A: a valid expert-owned legacy rate is explicit legacy
      // Catalog exposure of that tier, and no explicit publication state
      // exists for it.
      clientSelectable: true,
    );
  }

  num? _rateFor(ExpertCatalogEntry expert, LegacyConsultationTier tier) {
    switch (tier) {
      case LegacyConsultationTier.thirtyMinutes:
        return expert.rate30;
      case LegacyConsultationTier.sixtyMinutes:
        return expert.rate60;
      case LegacyConsultationTier.oneHundredTwentyMinutes:
        return expert.rate120;
    }
  }
}
