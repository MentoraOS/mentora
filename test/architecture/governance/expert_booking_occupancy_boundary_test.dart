import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expert Booking Occupancy boundary — ARCH-007 Wave 2C', () {
    test('ARC-A54 Domain and Application are Firebase-free', () {
      final violations = <String>[];
      for (final root in const ['domain/booking', 'application/booking']) {
        for (final file in _filesUnder(root)) {
          final source = file.readAsStringSync();
          if (source.contains('package:cloud_firestore/') ||
              source.contains('package:firebase_') ||
              source.contains('FirebaseFirestore') ||
              source.contains('DocumentSnapshot') ||
              source.contains('QuerySnapshot') ||
              source.contains('Timestamp') ||
              source.contains('BuildContext') ||
              source.contains('package:flutter/')) {
            violations.add(_relativeLibPath(file));
          }
        }
      }
      expect(violations, isEmpty);
    });

    test('ARC-A55 Expert Detail has no direct Booking persistence access', () {
      final source = _readLib('screens/expert_detail_screen.dart');
      expect(source, isNot(contains('package:cloud_firestore/')));
      expect(source, isNot(contains('FirebaseFirestore')));
      expect(source, isNot(contains("collection('bookings')")));
      expect(source, isNot(contains("'pending'")));
      expect(source, isNot(contains("'confirmed'")));
      expect(source, isNot(contains("'paid'")));
      expect(source, contains('ExpertBookingOccupancyApplicationService'));
    });

    test('ARC-A56 Firestore adapter is constructed only in canonical root', () {
      const allowed = 'composition/mentora_composition_root.dart';
      final violations = <String>[];
      final construction = RegExp(
        r'\bFirestoreExpertBookingOccupancyRepository\s*\(',
      );
      for (final file in _filesUnder('')) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class FirestoreExpertBookingOccupancyRepository',
        );
        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }
      expect(violations, isEmpty);
    });

    test(
      'ARC-A57 boundary is read-only and does not migrate legacy Booking',
      () {
        final repository = _readLib(
          'domain/booking/expert_booking_occupancy_repository.dart',
        );
        final legacyFiles = _filesUnder('core/booking').toList();
        expect(repository, contains('loadForExpert'));
        expect(repository, isNot(contains('save')));
        expect(repository, isNot(contains('create')));
        expect(legacyFiles, isNotEmpty);
        expect(
          legacyFiles.map((file) => _relativeLibPath(file)),
          contains('core/booking/booking.dart'),
        );
      },
    );

    test('ARC-A58 Composition Root exposes only the Application service', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');
      final main = _readLib('main.dart');
      expect(
        root,
        contains(
          'final expertBookingOccupancy = '
          'ExpertBookingOccupancyApplicationService(',
        ),
      );
      expect(root, contains('expertBookingOccupancy: expertBookingOccupancy,'));
      expect(
        dependencies,
        contains(
          'final ExpertBookingOccupancyApplicationService '
          'expertBookingOccupancy;',
        ),
      );
      expect(
        dependencies,
        isNot(contains('FirestoreExpertBookingOccupancyRepository')),
      );
      expect(
        main,
        contains('Provider<ExpertBookingOccupancyApplicationService>.value('),
      );
    });

    test('ARC-A59 Wave 2B protected boundary remains independent', () {
      final sources = <String>[
        for (final root in const [
          'domain/expert_availability',
          'application/expert_availability',
          'infrastructure/expert_availability',
        ])
          for (final file in _filesUnder(root)) file.readAsStringSync(),
      ].join('\n');
      expect(sources, isNot(contains('ExpertBookingOccupancy')));
      expect(sources, isNot(contains('/booking/')));
    });
  });
}

String _readLib(String relativePath) =>
    File('${_projectRoot().path}/lib/$relativePath').readAsStringSync();

Iterable<File> _filesUnder(String relativePath) {
  final directory = Directory('${_projectRoot().path}/lib/$relativePath');
  if (!directory.existsSync()) return const <File>[];
  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _relativeLibPath(File file) {
  final libPath = Directory('${_projectRoot().path}/lib').absolute.path;
  var path = file.absolute.path.substring(libPath.length);
  while (path.startsWith('/') || path.startsWith('\\')) {
    path = path.substring(1);
  }
  return path.replaceAll('\\', '/');
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
