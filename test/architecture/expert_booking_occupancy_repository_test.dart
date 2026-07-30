import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreExpertBookingOccupancyRepository contract', () {
    final source = File(
      '${_projectRoot().path}/lib/infrastructure/booking/'
      'firestore_expert_booking_occupancy_repository.dart',
    ).readAsStringSync();

    test('filters exactly the requested Expert and Genesis statuses', () {
      expect(source, contains(".where('expertId', isEqualTo: expertId)"));
      expect(
        source,
        contains(
          ".where('status', whereIn: const ['pending', 'confirmed', 'paid'])",
        ),
      );
      expect(source, isNot(contains("'completed'")));
      expect(source, isNot(contains("'cancelled'")));
    });

    test('is read-only, injected, and maps every returned document', () {
      expect(source, contains('required FirebaseFirestore firestore'));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, contains(".collection('bookings')"));
      expect(source, contains('.get()'));
      expect(source, contains('_mapper.fromMap(document.data())'));
      expect(source, isNot(contains('.set(')));
      expect(source, isNot(contains('.update(')));
      expect(source, isNot(contains('.delete(')));
    });
  });
}

Directory _projectRoot() {
  var current = Directory.current.absolute;
  while (true) {
    if (File('${current.path}/pubspec.yaml').existsSync() &&
        Directory('${current.path}/lib').existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError('Project root not found.');
    }
    current = parent;
  }
}
