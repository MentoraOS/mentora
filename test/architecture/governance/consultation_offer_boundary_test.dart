import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readLib(String relativePath) {
  final file = File('lib/$relativePath');
  expect(file.existsSync(), isTrue, reason: 'missing lib/$relativePath');
  return file.readAsStringSync();
}

Iterable<File> _filesUnderLib(String relativeDirectory) {
  final directory = Directory('lib/$relativeDirectory');
  if (!directory.existsSync()) {
    return const <File>[];
  }
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

void main() {
  group('Consultation Offer boundary — ARCH-009B / AD-021', () {
    test('the offer contract is pure Domain, free of outer layers', () {
      final sources = <String>[
        _readLib('domain/expert_catalog/consultation_offer.dart'),
        _readLib('domain/expert_catalog/legacy_rate_offer_adapter.dart'),
      ].join('\n');

      for (final forbidden in const [
        'package:flutter/',
        'package:firebase_',
        'package:cloud_firestore/',
        'dart:io',
        'dart:ui',
        '/screens/',
        '/widgets/',
        '/presentation/',
        '/infrastructure/',
        '/application/',
        '/core/routing/',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the offer contract does not depend on Financial Core', () {
      final sources = <String>[
        _readLib('domain/expert_catalog/consultation_offer.dart'),
        _readLib('domain/expert_catalog/legacy_rate_offer_adapter.dart'),
        _readLib('domain/booking/booking_creation.dart'),
      ].join('\n');

      for (final forbidden in const [
        '/core/financial/',
        '/core/escrow/',
        '/core/payment/',
        'FinancialCurrency',
        'FinancialAmount',
        'LedgerJournal',
        'EscrowEngine',
        'SettlementEngine',
        'WalletEngine',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Scheduling acquires no commercial ownership', () {
      final sources = _filesUnderLib(
        'core/scheduling',
      ).map((file) => file.readAsStringSync()).join('\n');

      for (final forbidden in const [
        'ConsultationOffer',
        'offerId',
        'amountMinor',
        'currency',
        'clientSelectable',
        'expert_catalog',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Booking Creation owns no consultation price or duration default', () {
      final source = _readLib('domain/booking/booking_creation.dart');

      expect(source, isNot(contains('15000')));
      expect(source, isNot(contains('50000')));
      expect(source, isNot(contains('durationMinutes = 30')));
      expect(source, isNot(contains('amount = ')));
      // The snapshot must be required input, not a default.
      expect(source, contains('required int durationMinutes'));
      expect(source, contains('required int amountMinor'));
      expect(source, contains('required String currency'));
      expect(source, contains('required String offerId'));
    });

    test('the modern Payment path defines no consultation price', () {
      final source = _readLib('screens/payment_screen.dart');

      expect(source, isNot(contains('consultationPrice')));
      expect(source, isNot(contains('50000')));
      expect(source, isNot(contains('15000')));
      // Payment consumes the authoritative values it is given.
      expect(source, contains('required this.amountMinor'));
      expect(source, contains('required this.currency'));
      expect(source, contains('widget.amountMinor'));
    });

    test('the expert profile defines no commercial fallback', () {
      final source = _readLib('screens/expert_detail_screen.dart');

      for (final forbidden in const [
        'rate30 ??',
        'rate60 ??',
        'rate120 ??',
        '?? 25000',
        '?? 50000',
        '?? 100000',
        'selectedIndex',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(source, contains('LegacyRateOfferAdapter'));
    });

    test('the selected offer is transported, not reconstructed', () {
      final router = _readLib('core/routing/app_router.dart');
      final preConsultation = _readLib('screens/pre_consultation_screen.dart');

      expect(router, contains('required ConsultationOffer offer'));
      expect(router, contains('required int amountMinor'));
      expect(router, contains('required String currency'));
      expect(preConsultation, contains('offer: widget.offer'));
      expect(preConsultation, contains('widget.offer.amountMinor'));
      expect(preConsultation, contains('widget.offer.currency'));
    });

    test('Presentation performs no commercial arithmetic', () {
      final sources = <String>[
        _readLib('screens/expert_detail_screen.dart'),
        _readLib('screens/pre_consultation_screen.dart'),
        _readLib('screens/payment_screen.dart'),
      ].join('\n');

      for (final forbidden in const [
        'amountMinor *',
        'amountMinor +',
        'amountMinor -',
        'amountMinor /',
        'amountMinor ~/',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Financial Core remains untouched by the offer contract', () {
      // Financial Core owns amountMinor for financial facts; Marketplace must
      // not reach into it, and must not be reached from it.
      final financial = _filesUnderLib(
        'core/financial',
      ).map((file) => file.readAsStringSync()).join('\n');

      expect(financial, isNot(contains('ConsultationOffer')));
      expect(financial, isNot(contains('expert_catalog')));
      expect(financial, isNot(contains('BookingCreation')));
    });
  });
}
