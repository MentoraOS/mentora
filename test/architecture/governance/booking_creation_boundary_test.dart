import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Booking Creation boundary — ARCH-008', () {
    test('Domain and Application are Firebase and outer-layer free', () {
      final sources = <String>[
        _readLib('domain/booking/booking_creation.dart'),
        _readLib('domain/booking/booking_creation_repository.dart'),
        _readLib(
          'application/booking/booking_creation_application_service.dart',
        ),
        _readLib('application/booking/booking_creation_failure.dart'),
      ].join('\n');
      for (final forbidden in const [
        'package:cloud_firestore/',
        'package:firebase_',
        'package:flutter/',
        '/infrastructure/',
        '/screens/',
        '/core/booking/',
        '/expert_availability/',
        '/scheduling/',
        '/financial/',
        "import '../../core/engines/payment/",
        'PaymentEngine',
        'FinancialLedger',
        'Settlement',
        'EscrowEngine',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('PreConsultation owns no Firestore or persisted schema', () {
      final source = _readLib('screens/pre_consultation_screen.dart');
      for (final forbidden in const [
        'package:cloud_firestore/',
        'FirebaseFirestore',
        "collection('bookings')",
        'FieldValue.serverTimestamp',
        "'pending_payment'",
        "'paymentStatus'",
        "'createdAt'",
      ]) {
        expect(source, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(source, contains('BookingCreationApplicationService'));
    });

    test('adapter is constructed only in the canonical root', () {
      const allowed = 'composition/mentora_composition_root.dart';
      final violations = <String>[];
      final construction = RegExp(r'\bFirestoreBookingCreationRepository\s*\(');
      for (final file in _filesUnderLib()) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class FirestoreBookingCreationRepository',
        );
        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }
      expect(violations, isEmpty);
    });

    test('canonical composition exposes only the Application service', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');
      final main = _readLib('main.dart');
      expect(root, contains('FirestoreBookingCreationRepository('));
      expect(root, contains('BookingCreationApplicationService('));
      expect(
        dependencies,
        contains('final BookingCreationApplicationService bookingCreation;'),
      );
      expect(
        dependencies,
        isNot(contains('FirestoreBookingCreationRepository')),
      );
      expect(
        main,
        contains('Provider<BookingCreationApplicationService>.value('),
      );
    });

    test('boundary does not modify protected Booking capabilities', () {
      final application = _readLib(
        'application/booking/booking_creation_application_service.dart',
      );
      final infrastructure = _readLib(
        'infrastructure/booking/firestore_booking_creation_repository.dart',
      );
      final sources = '$application\n$infrastructure';
      expect(sources, isNot(contains('ExpertBookingOccupancy')));
      expect(sources, isNot(contains('ExpertAvailability')));
      expect(sources, isNot(contains('BookingEngine')));
      expect(sources, isNot(contains('PaymentScreen')));
      expect(sources, isNot(contains('Financial')));
    });
  });
}

String _readLib(String relativePath) =>
    File('${_projectRoot().path}/lib/$relativePath').readAsStringSync();

Iterable<File> _filesUnderLib() {
  return Directory('${_projectRoot().path}/lib')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _relativeLibPath(File file) {
  final root = Directory('${_projectRoot().path}/lib').absolute.path;
  return file.absolute.path
      .substring(root.length)
      .replaceAll('\\', '/')
      .replaceFirst(RegExp(r'^/+'), '');
}

Directory _projectRoot() {
  var current = Directory.current.absolute;
  while (true) {
    if (File('${current.path}/pubspec.yaml').existsSync()) return current;
    final parent = current.parent;
    if (parent.path == current.path) throw StateError('Project root not found');
    current = parent;
  }
}
