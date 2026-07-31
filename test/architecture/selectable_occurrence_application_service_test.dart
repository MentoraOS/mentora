import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_failure.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_application_service.dart';
import 'package:mentora/application/scheduling/civil_selection.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_failure.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';

ExpertCatalogEntry expert({
  String id = 'expert_1',
  String? expertTimezone = 'Africa/Bamako',
  Map<String, List<String>> availability = const {
    'Lundi': ['09:00', '10:00'],
  },
}) {
  return ExpertCatalogEntry(
    id: id,
    name: 'Awa',
    job: 'Coach',
    country: 'ML',
    rating: '4.8',
    online: true,
    availability: availability,
    expertTimezone: expertTimezone,
  );
}

ConsultationOffer offer({String expertId = 'expert_1', int duration = 60}) {
  return ConsultationOffer(
    offerId: 'expert:$expertId:consultation:${duration}m',
    expertId: expertId,
    durationMinutes: duration,
    amountMinor: 50000,
    currency: 'XOF',
    clientSelectable: true,
  );
}

SelectableOccurrenceApplicationService service({
  List<ExpertCatalogEntry> experts = const [],
  Object? error,
}) {
  return SelectableOccurrenceApplicationService(
    expertCatalog: ExpertCatalogApplicationService(
      repository: _Repository(experts: experts, error: error),
    ),
    materialization: const CivilOccurrenceMaterializationAdapter(),
  );
}

CivilSelection civil(
  int year,
  int month,
  int day,
  int hour,
  int minute, {
  int duration = 60,
}) {
  return CivilSelection(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    durationMinutes: duration,
  );
}

void main() {
  group('AD-022 Wave C2 — materialization through Application', () {
    test('materializes the authoritative recurring availability', () async {
      final occurrences = await service(experts: [expert()]).materializeMonth(
        expertId: 'expert_1',
        offer: offer(),
        year: 2026,
        month: 8,
      );

      // Five Mondays in August 2026, two ticks each.
      expect(occurrences, hasLength(10));
      expect(occurrences.first, civil(2026, 8, 3, 9, 0));
      expect(occurrences.first.durationMinutes, 60);
    });
  });

  group('AD-022 Wave C2 — Application revalidation', () {
    test('a legitimately offered occurrence is accepted', () async {
      final validated = await service(experts: [expert()]).revalidate(
        expertId: 'expert_1',
        offer: offer(),
        // Monday 3 August 2026 at 09:00 — the canonical example.
        year: 2026,
        month: 8,
        day: 3,
        hour: 9,
        minute: 0,
      );

      expect(validated, civil(2026, 8, 3, 9, 0));
      expect(validated.durationMinutes, 60);
    });

    test('the recurrence holds on a later Monday', () async {
      final validated = await service(experts: [expert()]).revalidate(
        expertId: 'expert_1',
        offer: offer(),
        year: 2026,
        month: 8,
        day: 10,
        hour: 10,
        minute: 0,
      );

      expect(validated, civil(2026, 8, 10, 10, 0));
    });

    test('a well-formed but non-offered time is rejected', () async {
      await expectLater(
        service(experts: [expert()]).revalidate(
          expertId: 'expert_1',
          offer: offer(),
          year: 2026,
          month: 8,
          day: 3,
          hour: 9,
          minute: 30,
        ),
        throwsA(isA<SelectableOccurrenceNotOfferedFailure>()),
      );
    });

    test('a well-formed but non-offered date is rejected', () async {
      // 4 August 2026 is a Tuesday; the expert declares only Mondays.
      await expectLater(
        service(experts: [expert()]).revalidate(
          expertId: 'expert_1',
          offer: offer(),
          year: 2026,
          month: 8,
          day: 4,
          hour: 9,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceNotOfferedFailure>()),
      );
    });

    test('a missing expert fails closed', () async {
      await expectLater(
        service(experts: const []).revalidate(
          expertId: 'expert_1',
          offer: offer(),
          year: 2026,
          month: 8,
          day: 3,
          hour: 9,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceExpertNotFoundFailure>()),
      );
    });

    test('a missing expert timezone fails closed', () async {
      await expectLater(
        service(experts: [expert(expertTimezone: null)]).revalidate(
          expertId: 'expert_1',
          offer: offer(),
          year: 2026,
          month: 8,
          day: 3,
          hour: 9,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
      );
    });

    test('a malformed expert timezone fails closed', () async {
      for (final malformed in const ['Not A Zone', '+00:00', '   ']) {
        await expectLater(
          service(experts: [expert(expertTimezone: malformed)]).revalidate(
            expertId: 'expert_1',
            offer: offer(),
            year: 2026,
            month: 8,
            day: 3,
            hour: 9,
            minute: 0,
          ),
          throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
          reason: malformed,
        );
      }
    });

    test('malformed authoritative availability fails closed', () async {
      await expectLater(
        service(
          experts: [
            expert(
              availability: const {
                'Lundi': ['9:00'],
              },
            ),
          ],
        ).revalidate(
          expertId: 'expert_1',
          offer: offer(),
          year: 2026,
          month: 8,
          day: 3,
          hour: 9,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceMalformedAvailabilityFailure>()),
      );
    });

    test('an offer belonging to another expert is rejected', () async {
      await expectLater(
        service(experts: [expert()]).revalidate(
          expertId: 'expert_1',
          offer: offer(expertId: 'expert_2'),
          year: 2026,
          month: 8,
          day: 3,
          hour: 9,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceOfferMismatchFailure>()),
      );
    });

    test(
      'infrastructure failure stays distinguishable from not-offered',
      () async {
        await expectLater(
          service(error: StateError('offline')).revalidate(
            expertId: 'expert_1',
            offer: offer(),
            year: 2026,
            month: 8,
            day: 3,
            hour: 9,
            minute: 0,
          ),
          throwsA(isA<ExpertCatalogInfrastructureFailure>()),
        );
      },
    );

    test(
      'every C2 failure shares the sealed Application failure type',
      () async {
        await expectLater(
          service(experts: const []).revalidate(
            expertId: 'expert_1',
            offer: offer(),
            year: 2026,
            month: 8,
            day: 3,
            hour: 9,
            minute: 0,
          ),
          throwsA(isA<SelectableOccurrenceFailure>()),
        );
      },
    );
  });
}

final class _Repository implements ExpertCatalogRepository {
  const _Repository({this.experts = const [], this.error});

  final List<ExpertCatalogEntry> experts;
  final Object? error;

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value(experts);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    if (error case final error?) {
      throw ExpertCatalogRepositoryException(cause: error);
    }
    for (final entry in experts) {
      if (entry.id == expertId) return entry;
    }
    return null;
  }
}
