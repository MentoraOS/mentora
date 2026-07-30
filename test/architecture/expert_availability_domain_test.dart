import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/expert_availability/expert_availability.dart';

void main() {
  group('ExpertAvailability', () {
    test('is deeply immutable while preserving values and duplicates', () {
      final source = <String, List<String>>{
        'Lundi': <String>['09:00', '08:00', '09:00'],
        'Mardi': <String>[],
      };

      final availability = ExpertAvailability(
        slotsByDay: source,
        revision: '10:20',
      );

      source['Lundi']!.add('10:00');
      source['Mercredi'] = <String>['11:00'];

      expect(availability.slotsByDay, {
        'Lundi': ['09:00', '08:00', '09:00'],
        'Mardi': <String>[],
      });
      expect(
        () => availability.slotsByDay['Mercredi'] = const ['11:00'],
        throwsUnsupportedError,
      );
      expect(
        () => availability.slotsByDay['Lundi']!.add('10:00'),
        throwsUnsupportedError,
      );
    });

    test('has deterministic value semantics', () {
      final left = ExpertAvailability(
        slotsByDay: const {
          'Lundi': ['09:00', '08:00'],
          'Mardi': <String>[],
        },
        revision: '10:20',
      );
      final sameWithDifferentMapOrder = ExpertAvailability(
        slotsByDay: const {
          'Mardi': <String>[],
          'Lundi': ['09:00', '08:00'],
        },
        revision: '10:20',
      );
      final differentSlotOrder = ExpertAvailability(
        slotsByDay: const {
          'Lundi': ['08:00', '09:00'],
          'Mardi': <String>[],
        },
        revision: '10:20',
      );

      expect(left, sameWithDifferentMapOrder);
      expect(left.hashCode, sameWithDifferentMapOrder.hashCode);
      expect(left, isNot(differentSlotOrder));
    });
  });
}
