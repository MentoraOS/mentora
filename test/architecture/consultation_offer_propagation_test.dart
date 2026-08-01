import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_creation_application_service.dart';
import 'package:mentora/application/booking/booking_creation_failure.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/scheduling/civil_selection.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_application_service.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/domain/booking/booking_creation_repository.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/domain/expert_catalog/legacy_rate_offer_adapter.dart';
import 'package:mentora/infrastructure/booking/booking_creation_firestore_mapper.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

ExpertCatalogEntry catalogEntry({
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
    // AD-022 C2/C3: the modern creation path revalidates against the
    // authoritative availability and timezone; the commercial assertions
    // below are unchanged.
    availability: const <String, List<String>>{
      'Lundi': ['09:00'],
    },
    expertTimezone: 'Africa/Bamako',
    rate30: rate30,
    rate60: rate60,
    rate120: rate120,
  );
}

void main() {
  const adapter = LegacyRateOfferAdapter();
  const mapper = BookingCreationFirestoreMapper();

  group('AD-021 — commercial truth survives the modern path', () {
    test(
      'the selected offer reaches the Booking commercial snapshot',
      () async {
        // The client selects the 60-minute tier priced at 15,000 by the expert.
        final offers = adapter.offersFor(
          catalogEntry(rate30: 9000, rate60: 15000, rate120: 21000),
        );
        final selected = offers.firstWhere(
          (offer) => offer.durationMinutes == 60,
        );

        final repository = _Repository();
        final service = _service(repository);

        await service.create(
          expertId: 'expert_1',
          expertName: 'Expert',
          occurrence: _occurrence(selected),
          clientNeed: 'Need',
          aiSummary: 'Summary',
          offer: selected,
        );

        final booking = repository.booking!;
        expect(booking.offerId, selected.offerId);
        expect(booking.expertId, selected.expertId);
        expect(booking.durationMinutes, selected.durationMinutes);
        expect(booking.amountMinor, selected.amountMinor);
        expect(booking.currency, selected.currency);

        // …and the same values are what persistence receives.
        final data = mapper.toMap(booking);
        expect(data['offerId'], selected.offerId);
        expect(data['duration'], 60);
        expect(data['amount'], 15000);
        expect(data['currency'], 'XOF');
      },
    );

    test('a 120-minute selection never degrades to 30 minutes', () async {
      final selected = adapter
          .offersFor(catalogEntry(rate30: 25000, rate120: 100000))
          .firstWhere((offer) => offer.durationMinutes == 120);

      final repository = _Repository();
      await _create(_service(repository), offer: selected);

      expect(repository.booking!.durationMinutes, 120);
      expect(repository.booking!.durationMinutes, isNot(30));
      expect(repository.booking!.amountMinor, 100000);
    });

    test('the 15,000 / 50,000 divergence cannot recur', () async {
      // Catalog truth for the selected tier is 15,000.
      final selected = adapter
          .offersFor(catalogEntry(rate60: 15000))
          .firstWhere((offer) => offer.durationMinutes == 60);

      final repository = _Repository();
      await _create(_service(repository), offer: selected);

      final booking = repository.booking!;
      final data = mapper.toMap(booking);

      // Every downstream commercial value equals the catalog truth. No layer
      // substitutes 50,000 or the legacy 15,000 default independently.
      expect(selected.amountMinor, 15000);
      expect(booking.amountMinor, 15000);
      expect(data['amount'], 15000);
      expect(data['amount'], isNot(50000));

      // The value the Payment handoff receives is the same object's value.
      expect(booking.amountMinor, selected.amountMinor);
      expect(booking.currency, selected.currency);
    });

    test('an unusual catalog amount still propagates verbatim', () async {
      final selected = adapter
          .offersFor(catalogEntry(rate60: 37500))
          .firstWhere((offer) => offer.durationMinutes == 60);

      final repository = _Repository();
      await _create(_service(repository), offer: selected);

      expect(repository.booking!.amountMinor, 37500);
      expect(mapper.toMap(repository.booking!)['amount'], 37500);
    });
  });

  group('AD-021 — fail-closed commercial semantics', () {
    test('a cross-expert offer is rejected before persistence', () async {
      final foreign = adapter
          .offersFor(catalogEntry(id: 'expert_2', rate60: 50000))
          .single;

      final repository = _Repository();
      final service = _service(repository);

      await expectLater(
        _create(service, offer: foreign),
        throwsA(isA<BookingCreationExpertMismatchFailure>()),
      );
      expect(repository.calls, 0);
      expect(repository.booking, isNull);
    });

    test('a non-selectable offer is rejected before persistence', () async {
      final repository = _Repository();
      final service = _service(repository);

      await expectLater(
        _create(
          service,
          offer: ConsultationOffer(
            offerId: 'expert:expert_1:consultation:60m',
            expertId: 'expert_1',
            durationMinutes: 60,
            amountMinor: 50000,
            currency: 'XOF',
            clientSelectable: false,
          ),
        ),
        throwsA(isA<BookingCreationOfferUnavailableFailure>()),
      );
      expect(repository.calls, 0);
    });

    test('an expert with no valid rate exposes nothing to select', () {
      expect(adapter.offersFor(catalogEntry()), isEmpty);
      expect(adapter.offersFor(catalogEntry(rate60: 25000.5)), isEmpty);
    });
  });

  group('AD-021 decision 7 — snapshot immutability', () {
    test(
      'a later catalog change does not mutate an existing snapshot',
      () async {
        final before = adapter
            .offersFor(catalogEntry(rate60: 50000))
            .firstWhere((offer) => offer.durationMinutes == 60);

        final repository = _Repository();
        await _create(_service(repository), offer: before);
        final booking = repository.booking!;

        // The expert re-prices the same tier afterwards.
        final after = adapter
            .offersFor(catalogEntry(rate60: 60000))
            .firstWhere((offer) => offer.durationMinutes == 60);

        expect(after.offerId, before.offerId);
        expect(after.amountMinor, 60000);

        // The reservation keeps the commercial truth captured at selection.
        expect(booking.amountMinor, 50000);
        expect(booking.durationMinutes, 60);
        expect(mapper.toMap(booking)['amount'], 50000);
      },
    );
  });
}

BookingCreationApplicationService _service(_Repository repository) {
  return BookingCreationApplicationService(
    session: _Session('client_1'),
    repository: repository,
    selectableOccurrences: SelectableOccurrenceApplicationService(
      expertCatalog: ExpertCatalogApplicationService(
        repository: const _CatalogRepository(),
      ),
      materialization: const CivilOccurrenceMaterializationAdapter(),
    ),
    interpretation: const CivilOccurrenceInterpretationAdapter(
      resolver: LaunchMarketTimezoneResolver(),
    ),
    channelFactory: () => 'mentora_test_channel',
  );
}

/// Monday 3 August 2026 at 09:00 — the canonical AD-022 example — carrying
/// the selected offer's authoritative duration.
CivilSelection _occurrence(ConsultationOffer offer) {
  return CivilSelection(
    year: 2026,
    month: 8,
    day: 3,
    hour: 9,
    minute: 0,
    durationMinutes: offer.durationMinutes,
  );
}

final class _CatalogRepository implements ExpertCatalogRepository {
  const _CatalogRepository();

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value([catalogEntry()]);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    return expertId == 'expert_1' ? catalogEntry() : null;
  }
}

Future<String> _create(
  BookingCreationApplicationService service, {
  required ConsultationOffer offer,
  String expertId = 'expert_1',
}) {
  return service.create(
    expertId: expertId,
    expertName: 'Expert',
    occurrence: _occurrence(offer),
    clientNeed: 'Need',
    aiSummary: 'Summary',
    offer: offer,
  );
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}

final class _Repository implements BookingCreationRepository {
  int calls = 0;
  BookingCreation? booking;

  @override
  Future<String> create(BookingCreation booking) async {
    calls++;
    this.booking = booking;
    return 'booking_1';
  }
}
