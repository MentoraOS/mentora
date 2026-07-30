import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreBookingCreationRepository contract', () {
    final source = File(
      '${_projectRoot().path}/lib/infrastructure/booking/'
      'firestore_booking_creation_repository.dart',
    ).readAsStringSync();

    test('uses an injected Firestore and deterministic slot guard', () {
      expect(source, contains('required FirebaseFirestore firestore'));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, contains("collection('_booking_creation_slots')"));
      expect(source, contains('jsonEncode(<String>['));
      expect(source, contains('booking.expertId'));
      expect(source, contains('booking.bookingDate'));
      expect(source, contains('booking.bookingTime'));
    });

    test('atomically writes guard and Booking or reports conflict', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains('transaction.get(slotGuard)'));
      expect(source, contains('guardSnapshot.exists'));
      expect(source, contains('BookingCreationConflictException'));
      expect(source, contains('transaction.set(bookingDocument'));
      expect(source, contains('transaction.set(slotGuard'));
      expect(source, contains('return bookingDocument.id'));
      expect(source, isNot(contains('.add(')));
    });

    test('wraps Firebase errors without translating them to conflict', () {
      expect(source, contains('on FirebaseException catch (error)'));
      expect(source, contains('BookingCreationRepositoryException('));
      expect(source, contains("error.code == 'unavailable'"));
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
