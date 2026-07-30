import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/expert_availability/expert_availability.dart';
import 'package:mentora/infrastructure/expert_availability/expert_availability_firestore_mapper.dart';

void main() {
  group('ExpertAvailabilityFirestoreMapper', () {
    const mapper = ExpertAvailabilityFirestoreMapper();

    test('maps a valid multi-day Firestore value without normalization', () {
      final result = mapper.fromMap(<String, dynamic>{
        'availability': <String, List<String>>{
          'Mardi': <String>['14:00', '08:00', '14:00'],
          'Lundi': <String>[],
        },
      });

      expect(result.slotsByDay.keys, orderedEquals(['Mardi', 'Lundi']));
      expect(result.slotsByDay['Mardi'], ['14:00', '08:00', '14:00']);
      expect(result.slotsByDay['Lundi'], isEmpty);
    });

    test('maps an empty map', () {
      final result = mapper.fromMap(<String, dynamic>{
        'availability': <String, List<String>>{},
      });

      expect(result.slotsByDay, isEmpty);
    });

    test('maps absent or null availability to an empty map', () {
      expect(mapper.fromMap(const {}).slotsByDay, isEmpty);
      expect(mapper.fromMap(const {'availability': null}).slotsByDay, isEmpty);
    });

    test('rejects a non-map availability root', () {
      expect(
        () => mapper.fromMap(const {'availability': 'Lundi'}),
        throwsFormatException,
      );
    });

    test('rejects a non-string day key', () {
      expect(
        () => mapper.fromMap(<String, dynamic>{
          'availability': <Object, Object>{
            1: <String>['08:00'],
          },
        }),
        throwsFormatException,
      );
    });

    test('rejects a non-list day value', () {
      expect(
        () => mapper.fromMap(const {
          'availability': <String, Object>{'Lundi': '08:00'},
        }),
        throwsFormatException,
      );
    });

    test('rejects a non-string hour member', () {
      expect(
        () => mapper.fromMap(const {
          'availability': <String, Object>{
            'Lundi': <Object>['08:00', 9],
          },
        }),
        throwsFormatException,
      );
    });

    test('creates a deterministic full-precision revision', () {
      final timestamp = Timestamp(123456789, 987654321);

      final first = mapper.fromMap(<String, dynamic>{
        'availabilityUpdatedAt': timestamp,
      });
      final second = mapper.fromMap(<String, dynamic>{
        'availabilityUpdatedAt': Timestamp(123456789, 987654321),
      });

      expect(first.revision, '123456789:987654321');
      expect(second.revision, first.revision);
    });

    test('maps absent or null timestamp to a null revision', () {
      expect(mapper.fromMap(const {}).revision, isNull);
      expect(
        mapper.fromMap(const {'availabilityUpdatedAt': null}).revision,
        isNull,
      );
    });

    test('rejects an invalid timestamp value', () {
      expect(
        () => mapper.fromMap(const {'availabilityUpdatedAt': 'now'}),
        throwsFormatException,
      );
    });

    test('maps Domain values to the preserved Firestore schema', () {
      final data = mapper.toMap(
        ExpertAvailability(
          slotsByDay: const {
            'Mardi': ['14:00', '08:00', '14:00'],
            'Lundi': <String>[],
          },
          revision: 'old:revision',
        ),
      );

      expect(data.keys, containsAll(['availability', 'availabilityUpdatedAt']));
      expect(data['availability'], {
        'Mardi': ['14:00', '08:00', '14:00'],
        'Lundi': <String>[],
      });
      expect(data['availabilityUpdatedAt'], isA<FieldValue>());
    });

    test('returns deeply immutable Domain availability', () {
      final result = mapper.fromMap(const {
        'availability': <String, List<String>>{
          'Lundi': <String>['08:00'],
        },
      });

      expect(
        () => result.slotsByDay['Mardi'] = const ['09:00'],
        throwsUnsupportedError,
      );
      expect(
        () => result.slotsByDay['Lundi']!.add('09:00'),
        throwsUnsupportedError,
      );
    });
  });
}
