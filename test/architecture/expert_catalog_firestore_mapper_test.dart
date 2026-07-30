import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/infrastructure/expert_catalog/expert_catalog_firestore_mapper.dart';

void main() {
  group('ExpertCatalogFirestoreMapper', () {
    const mapper = ExpertCatalogFirestoreMapper();

    test('uses the Firestore document id as canonical identity', () {
      final expert = mapper.fromMap(
        documentId: 'document_id',
        data: const <String, dynamic>{
          'id': 'legacy_id',
          'expertId': 'legacy_expert_id',
        },
      );

      expect(expert.id, 'document_id');
    });

    test('maps canonical public catalog fields', () {
      final expert = mapper.fromMap(
        documentId: 'expert_1',
        data: const <String, dynamic>{
          'name': 'Awa',
          'job': 'Coach',
          'country': 'ML',
          'rating': 4.8,
          'consultations': 42,
          'online': false,
          'photoUrl': 'https://example.test/awa.png',
          'experienceYears': 8,
          'satisfactionRate': 97,
          'rate30': 25000,
          'rate60': 50000,
          'rate120': 100000,
          'specialities': <String>['Business'],
          'languages': <String>['Français'],
          'bio': 'Coach business',
          'availability': <String, List<String>>{
            'Lundi': <String>['08:00'],
          },
        },
      );

      expect(expert.name, 'Awa');
      expect(expert.job, 'Coach');
      expect(expert.country, 'ML');
      expect(expert.rating, '4.8');
      expect(expert.consultations, '42');
      expect(expert.online, isFalse);
      expect(expert.photoUrl, 'https://example.test/awa.png');
      expect(expert.experienceYears, '8');
      expect(expert.satisfactionRate, '97');
      expect(expert.rate30, 25000);
      expect(expert.rate60, 50000);
      expect(expert.rate120, 100000);
      expect(expert.specialities, ['Business']);
      expect(expert.languages, ['Français']);
      expect(expert.bio, 'Coach business');
      expect(expert.availability, {
        'Lundi': ['08:00'],
      });
    });

    test('normalizes every observed legacy synonym', () {
      final expert = mapper.fromMap(
        documentId: 'expert_1',
        data: const <String, dynamic>{
          'title': 'Mentor',
          'isAvailable': false,
          'experience': 5,
          'skills': <String>['Tech'],
          'about': 'Legacy biography',
        },
      );

      expect(expert.job, 'Mentor');
      expect(expert.online, isFalse);
      expect(expert.experienceYears, '5');
      expect(expert.specialities, ['Tech']);
      expect(expert.bio, 'Legacy biography');
    });

    test('preserves numeric and string display values deterministically', () {
      final expert = mapper.fromMap(
        documentId: 'expert_1',
        data: const <String, dynamic>{
          'rating': '4.9',
          'consultations': '120',
          'experienceYears': '10',
          'satisfactionRate': '98',
        },
      );

      expect(expert.rating, '4.9');
      expect(expert.consultations, '120');
      expect(expert.experienceYears, '10');
      expect(expert.satisfactionRate, '98');
    });

    test('uses existing defaults for missing optional values', () {
      final expert = mapper.fromMap(
        documentId: 'expert_1',
        data: const <String, dynamic>{},
      );

      expect(expert.name, 'Expert');
      expect(expert.job, 'Expert Mentora');
      expect(expert.country, '');
      expect(expert.rating, '0');
      expect(expert.online, isTrue);
      expect(expert.consultations, isNull);
      expect(expert.photoUrl, isNull);
      expect(expert.specialities, isNull);
      expect(expert.languages, isNull);
      expect(expert.bio, isNull);
      expect(expert.availability, isEmpty);
    });

    test('rejects malformed values at the mapper boundary', () {
      final expert = mapper.fromMap(
        documentId: 'expert_1',
        data: const <String, dynamic>{
          'name': 42,
          'rating': <String>[],
          'online': 'yes',
          'rate30': '25000',
          'specialities': <Object>['Business', 42],
          'languages': 'Français',
          'availability': <String, Object>{
            'Lundi': <Object>['08:00', 9],
            'Mardi': '14:00',
          },
        },
      );

      expect(expert.name, 'Expert');
      expect(expert.rating, '0');
      expect(expert.online, isTrue);
      expect(expert.rate30, isNull);
      expect(expert.specialities, ['Business']);
      expect(expert.languages, isNull);
      expect(expert.availability, {
        'Lundi': ['08:00'],
      });
    });

    test('returns immutable catalog collections', () {
      final expert = mapper.fromMap(
        documentId: 'expert_1',
        data: const <String, dynamic>{
          'specialities': <String>['Business'],
          'availability': <String, List<String>>{
            'Lundi': <String>['08:00'],
          },
        },
      );

      expect(() => expert.specialities!.add('Tech'), throwsUnsupportedError);
      expect(
        () => expert.availability['Mardi'] = const ['09:00'],
        throwsUnsupportedError,
      );
      expect(
        () => expert.availability['Lundi']!.add('09:00'),
        throwsUnsupportedError,
      );
    });
  });
}
