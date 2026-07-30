import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/infrastructure/profile/profile_firestore_mapper.dart';

void main() {
  group('ProfileFirestoreMapper', () {
    const mapper = ProfileFirestoreMapper();

    test('maps Firestore profile fields without leaking Firebase types', () {
      final profile = mapper.fromMap(
        id: 'user_1',
        data: const <String, dynamic>{
          'firstName': 'Awa',
          'lastName': 'Diallo',
          'email': 'awa@mentora.test',
          'phone': '123',
          'unrelated': 'preserved only in Firestore',
        },
      );

      expect(profile.id, 'user_1');
      expect(profile.firstName, 'Awa');
      expect(profile.lastName, 'Diallo');
      expect(profile.email, 'awa@mentora.test');
      expect(profile.phone, '123');
    });

    test('preserves optional and missing field semantics', () {
      final profile = mapper.fromMap(
        id: 'user_1',
        data: const <String, dynamic>{
          'firstName': '',
          'lastName': null,
          'email': 42,
        },
      );

      expect(profile.firstName, '');
      expect(profile.lastName, isNull);
      expect(profile.email, isNull);
      expect(profile.phone, isNull);
    });

    test('maps profile update to the exact existing Firestore schema', () {
      final data = mapper.updateToMap(
        firstName: 'Awa',
        lastName: 'Diallo',
        phone: '123',
      );

      expect(data.keys, {'firstName', 'lastName', 'phone', 'updatedAt'});
      expect(data['firstName'], 'Awa');
      expect(data['lastName'], 'Diallo');
      expect(data['phone'], '123');
      expect(data['updatedAt'], isA<FieldValue>());
    });
  });
}
