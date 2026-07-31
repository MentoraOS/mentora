/// A consultation offer owned by an expert (AD-021).
///
/// Expert Profile/Catalog owns the offer definition and its publication
/// eligibility. This is the single commercial source consumed by the booking
/// funnel: Scheduling may read [durationMinutes] only, Booking copies the
/// commercial snapshot, and Payment consumes [amountMinor] and [currency]
/// without recomputing them.
///
/// The offer carries no Financial Core type. [amountMinor] is Consultation
/// Offer commercial contract data, not financial authority.
final class ConsultationOffer {
  /// Current Marketplace launch currency (AD-021 decision 3).
  static const String launchCurrency = 'XOF';

  final String offerId;

  final String expertId;

  final int durationMinutes;

  /// Commercial amount in the minor unit of [currency].
  final int amountMinor;

  /// ISO 4217 alphabetic code.
  final String currency;

  /// Whether the Expert Catalog exposes this offer for client selection.
  ///
  /// A non-selectable offer must never be silently substituted by a
  /// neighbouring tier, a first tier or a synthetic default.
  final bool clientSelectable;

  factory ConsultationOffer({
    required String offerId,
    required String expertId,
    required int durationMinutes,
    required int amountMinor,
    required String currency,
    required bool clientSelectable,
  }) {
    if (offerId.trim().isEmpty) {
      throw ArgumentError.value(offerId, 'offerId', 'must not be empty');
    }
    if (expertId.trim().isEmpty) {
      throw ArgumentError.value(expertId, 'expertId', 'must not be empty');
    }
    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'must be strictly positive',
      );
    }
    if (amountMinor < 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'must not be negative',
      );
    }
    if (!_isIso4217(currency)) {
      throw ArgumentError.value(
        currency,
        'currency',
        'must be an ISO 4217 alphabetic code such as XOF',
      );
    }

    return ConsultationOffer._(
      offerId: offerId,
      expertId: expertId,
      durationMinutes: durationMinutes,
      amountMinor: amountMinor,
      currency: currency,
      clientSelectable: clientSelectable,
    );
  }

  const ConsultationOffer._({
    required this.offerId,
    required this.expertId,
    required this.durationMinutes,
    required this.amountMinor,
    required this.currency,
    required this.clientSelectable,
  });

  static bool _isIso4217(String currency) {
    if (currency.length != 3) {
      return false;
    }

    for (final unit in currency.codeUnits) {
      if (unit < 0x41 || unit > 0x5A) {
        return false;
      }
    }

    return true;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ConsultationOffer &&
            other.offerId == offerId &&
            other.expertId == expertId &&
            other.durationMinutes == durationMinutes &&
            other.amountMinor == amountMinor &&
            other.currency == currency &&
            other.clientSelectable == clientSelectable;
  }

  @override
  int get hashCode => Object.hash(
    offerId,
    expertId,
    durationMinutes,
    amountMinor,
    currency,
    clientSelectable,
  );

  @override
  String toString() {
    return 'ConsultationOffer($offerId, $expertId, ${durationMinutes}m, '
        '$amountMinor $currency, selectable: $clientSelectable)';
  }
}
