import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/legacy_rate_offer_adapter.dart';

ExpertCatalogEntry entryWith({
  String id = 'expert_1',
  num? rate30,
  num? rate60,
  num? rate120,
}) {
  return ExpertCatalogEntry(
    id: id,
    name: 'Expert',
    job: 'Consultant',
    country: 'ML',
    rating: '4.9',
    online: true,
    availability: const <String, List<String>>{},
    rate30: rate30,
    rate60: rate60,
    rate120: rate120,
  );
}

void main() {
  const adapter = LegacyRateOfferAdapter();

  group('AD-021 Clarification A — legacy tier exposure', () {
    test('rate30 becomes a selectable 30-minute offer', () {
      final offers = adapter.offersFor(entryWith(rate30: 25000));

      expect(offers, hasLength(1));
      expect(offers.single.durationMinutes, 30);
      expect(offers.single.amountMinor, 25000);
      expect(offers.single.currency, 'XOF');
      expect(offers.single.expertId, 'expert_1');
      expect(offers.single.clientSelectable, isTrue);
    });

    test('rate60 becomes a selectable 60-minute offer', () {
      final offers = adapter.offersFor(entryWith(rate60: 50000));

      expect(offers, hasLength(1));
      expect(offers.single.durationMinutes, 60);
      expect(offers.single.amountMinor, 50000);
    });

    test('rate120 becomes a selectable 120-minute offer', () {
      final offers = adapter.offersFor(entryWith(rate120: 100000));

      expect(offers, hasLength(1));
      expect(offers.single.durationMinutes, 120);
      expect(offers.single.amountMinor, 100000);
    });

    test('all three tiers are emitted in canonical order', () {
      final offers = adapter.offersFor(
        entryWith(rate30: 25000, rate60: 50000, rate120: 100000),
      );

      expect(offers.map((offer) => offer.durationMinutes).toList(), const [
        30,
        60,
        120,
      ]);
      expect(offers.map((offer) => offer.amountMinor).toList(), const [
        25000,
        50000,
        100000,
      ]);
    });

    test('an absent rate produces no offer and no neighbouring substitute', () {
      final offers = adapter.offersFor(entryWith(rate60: 50000));

      expect(offers, hasLength(1));
      expect(offers.single.durationMinutes, 60);
      // 30 and 120 are absent: they must not be synthesised from rate60.
      expect(offers.any((offer) => offer.durationMinutes == 30), isFalse);
      expect(offers.any((offer) => offer.durationMinutes == 120), isFalse);
    });

    test('an expert with no rates exposes no offer at all', () {
      expect(adapter.offersFor(entryWith()), isEmpty);
    });

    test('never falls back to the legacy 15,000 or UI placeholder values', () {
      final offers = adapter.offersFor(entryWith());

      expect(offers, isEmpty);
      // No 25000 / 50000 / 100000 placeholder and no 15000 legacy default.
      expect(offers.any((offer) => offer.amountMinor == 15000), isFalse);
      expect(offers.any((offer) => offer.amountMinor == 50000), isFalse);
    });

    test('unknown expert ownership yields no offer', () {
      expect(adapter.offersFor(entryWith(id: '  ', rate60: 50000)), isEmpty);
    });

    test('offers are emitted as an unmodifiable list', () {
      final offers = adapter.offersFor(entryWith(rate60: 50000));

      expect(
        () => offers.add(
          ConsultationOffer(
            offerId: 'x',
            expertId: 'expert_1',
            durationMinutes: 60,
            amountMinor: 1,
            currency: 'XOF',
            clientSelectable: true,
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('AD-021 Decision 14 — deterministic identity', () {
    test('identity is stable for the same expert and tier', () {
      final first = adapter.offersFor(entryWith(rate60: 50000)).single;
      final second = adapter.offersFor(entryWith(rate60: 60000)).single;

      expect(first.offerId, second.offerId);
      expect(first.offerId, 'expert:expert_1:consultation:60m');
    });

    test('identity differs per tier', () {
      final offers = adapter.offersFor(
        entryWith(rate30: 1, rate60: 2, rate120: 3),
      );

      expect(offers.map((offer) => offer.offerId).toSet(), {
        'expert:expert_1:consultation:30m',
        'expert:expert_1:consultation:60m',
        'expert:expert_1:consultation:120m',
      });
    });

    test('identity differs per expert', () {
      final first = adapter.offersFor(entryWith(rate60: 50000)).single;
      final second = adapter
          .offersFor(entryWith(id: 'expert_2', rate60: 50000))
          .single;

      expect(first.offerId, isNot(second.offerId));
    });

    test('identity does not depend on price or display order', () {
      expect(
        LegacyRateOfferAdapter.offerIdFor(
          expertId: 'expert_1',
          tier: LegacyConsultationTier.sixtyMinutes,
        ),
        'expert:expert_1:consultation:60m',
      );
    });
  });

  group('AD-021 Clarification B — legacy XOF rate conversion', () {
    test('an integer rate maps 1:1', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(25000), 25000);
    });

    test('an integer-valued double maps 1:1', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(25000.0), 25000);
    });

    test('zero is valid', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(0), 0);
      expect(LegacyRateOfferAdapter.amountMinorFrom(0.0), 0);
    });

    test('a fractional value is rejected without rounding', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(25000.5), isNull);
      expect(LegacyRateOfferAdapter.amountMinorFrom(0.4), isNull);
      expect(LegacyRateOfferAdapter.amountMinorFrom(0.6), isNull);
    });

    test('a negative value is rejected', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(-1), isNull);
      expect(LegacyRateOfferAdapter.amountMinorFrom(-25000.0), isNull);
    });

    test('NaN and Infinity are rejected', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(double.nan), isNull);
      expect(LegacyRateOfferAdapter.amountMinorFrom(double.infinity), isNull);
      expect(
        LegacyRateOfferAdapter.amountMinorFrom(double.negativeInfinity),
        isNull,
      );
    });

    test('null source stays absent', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(null), isNull);
    });

    test('there is no implicit multiplication by 100', () {
      expect(LegacyRateOfferAdapter.amountMinorFrom(25000), isNot(2500000));
      expect(LegacyRateOfferAdapter.amountMinorFrom(25000), 25000);
    });

    test('an invalid rate fails closed and yields no selectable offer', () {
      expect(adapter.offersFor(entryWith(rate60: 25000.5)), isEmpty);
      expect(adapter.offersFor(entryWith(rate60: -50000)), isEmpty);
      expect(adapter.offersFor(entryWith(rate60: double.nan)), isEmpty);
      expect(adapter.offersFor(entryWith(rate60: double.infinity)), isEmpty);
    });

    test('an invalid tier does not suppress a valid sibling tier', () {
      final offers = adapter.offersFor(
        entryWith(rate30: 25000.5, rate60: 50000),
      );

      expect(offers, hasLength(1));
      expect(offers.single.durationMinutes, 60);
      expect(offers.single.amountMinor, 50000);
    });
  });
}
