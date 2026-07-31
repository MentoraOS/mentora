import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';

ConsultationOffer offerWith({
  String offerId = 'expert:expert_1:consultation:60m',
  String expertId = 'expert_1',
  int durationMinutes = 60,
  int amountMinor = 50000,
  String currency = 'XOF',
  bool clientSelectable = true,
}) {
  return ConsultationOffer(
    offerId: offerId,
    expertId: expertId,
    durationMinutes: durationMinutes,
    amountMinor: amountMinor,
    currency: currency,
    clientSelectable: clientSelectable,
  );
}

void main() {
  group('AD-021 — ConsultationOffer invariants', () {
    test('accepts a complete offer', () {
      final offer = offerWith();

      expect(offer.offerId, 'expert:expert_1:consultation:60m');
      expect(offer.expertId, 'expert_1');
      expect(offer.durationMinutes, 60);
      expect(offer.amountMinor, 50000);
      expect(offer.currency, 'XOF');
      expect(offer.clientSelectable, isTrue);
    });

    test('launch currency is XOF', () {
      expect(ConsultationOffer.launchCurrency, 'XOF');
    });

    test('rejects a blank offerId', () {
      expect(() => offerWith(offerId: ''), throwsArgumentError);
      expect(() => offerWith(offerId: '   '), throwsArgumentError);
    });

    test('rejects a blank expertId', () {
      expect(() => offerWith(expertId: ''), throwsArgumentError);
      expect(() => offerWith(expertId: '   '), throwsArgumentError);
    });

    test('rejects a non-positive duration', () {
      expect(() => offerWith(durationMinutes: 0), throwsArgumentError);
      expect(() => offerWith(durationMinutes: -30), throwsArgumentError);
    });

    test('accepts a zero amount but rejects a negative amount', () {
      expect(offerWith(amountMinor: 0).amountMinor, 0);
      expect(() => offerWith(amountMinor: -1), throwsArgumentError);
    });

    test('rejects a currency that is not an ISO 4217 alphabetic code', () {
      for (final currency in const [
        '',
        '  ',
        'X',
        'XO',
        'XOFF',
        'xof',
        'X0F',
      ]) {
        expect(
          () => offerWith(currency: currency),
          throwsArgumentError,
          reason: currency,
        );
      }
    });

    test('is a value object', () {
      expect(offerWith(), offerWith());
      expect(offerWith().hashCode, offerWith().hashCode);
      expect(offerWith(), isNot(offerWith(amountMinor: 1)));
      expect(offerWith(), isNot(offerWith(clientSelectable: false)));
    });
  });
}
