import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/infrastructure/expert_catalog/expert_catalog_firestore_mapper.dart';

ExpertCatalogEntry mapped(Map<String, dynamic> data) {
  return const ExpertCatalogFirestoreMapper().fromMap(
    documentId: 'expert_1',
    data: data,
  );
}

void main() {
  group('AD-022 Clarification A — expert timezone identity', () {
    test('a declared identity is preserved verbatim', () {
      final expert = mapped(<String, dynamic>{
        'name': 'Awa',
        'country': 'ML',
        'expertTimezone': 'Africa/Bamako',
      });

      expect(expert.expertTimezone, 'Africa/Bamako');
    });

    test('the identity is not replaced by an offset', () {
      final expert = mapped(<String, dynamic>{
        'expertTimezone': 'Africa/Abidjan',
      });

      expect(expert.expertTimezone, 'Africa/Abidjan');
      expect(expert.expertTimezone, isNot('UTC'));
      expect(expert.expertTimezone, isNot('+00:00'));
    });

    test('a missing identity stays absent', () {
      final expert = mapped(<String, dynamic>{'name': 'Awa'});

      expect(expert.expertTimezone, isNull);
    });

    test('a blank identity is absence, not an identity', () {
      expect(
        mapped(<String, dynamic>{'expertTimezone': ''}).expertTimezone,
        isNull,
      );
      expect(
        mapped(<String, dynamic>{'expertTimezone': '   '}).expertTimezone,
        isNull,
      );
    });

    test('a non-string value stays absent', () {
      expect(
        mapped(<String, dynamic>{'expertTimezone': 42}).expertTimezone,
        isNull,
      );
      expect(
        mapped(<String, dynamic>{'expertTimezone': true}).expertTimezone,
        isNull,
      );
    });

    test('country never creates a timezone', () {
      for (final country in const ['ML', 'SN', 'CI', 'FR']) {
        final expert = mapped(<String, dynamic>{'country': country});

        expect(expert.country, country);
        expect(
          expert.expertTimezone,
          isNull,
          reason: '$country must not derive a timezone',
        );
      }
    });

    test('a legacy expert record without the field remains readable', () {
      final expert = mapped(<String, dynamic>{
        'name': 'Awa',
        'job': 'Coach',
        'country': 'ML',
        'rating': 4.8,
        'rate60': 50000,
        'availability': <String, dynamic>{
          'Lundi': <String>['09:00'],
        },
      });

      expect(expert.id, 'expert_1');
      expect(expert.name, 'Awa');
      expect(expert.job, 'Coach');
      expect(expert.rate60, 50000);
      expect(expert.availability, {
        'Lundi': ['09:00'],
      });
      expect(expert.expertTimezone, isNull);
    });

    test('one malformed identity does not poison the catalog read', () {
      // The value is carried as an opaque identity; validity is established
      // where Scheduling interprets it, so reading never throws here.
      final expert = mapped(<String, dynamic>{
        'name': 'Awa',
        'expertTimezone': 'Not A Zone',
      });

      expect(expert.name, 'Awa');
      expect(expert.expertTimezone, 'Not A Zone');
    });

    test('the entity accepts an absent identity without defaulting', () {
      final expert = ExpertCatalogEntry(
        id: 'expert_1',
        name: 'Awa',
        job: 'Coach',
        country: 'ML',
        rating: '4.8',
        online: true,
        availability: const <String, List<String>>{},
      );

      expect(expert.expertTimezone, isNull);
    });
  });
}
