import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/profile/profile.dart';

final class ProfileFirestoreMapper {
  const ProfileFirestoreMapper();

  Profile fromMap({required String id, required Map<String, dynamic> data}) {
    return Profile(
      id: id,
      firstName: _optionalString(data['firstName']),
      lastName: _optionalString(data['lastName']),
      email: _optionalString(data['email']),
      phone: _optionalString(data['phone']),
    );
  }

  Map<String, dynamic> updateToMap({
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String? _optionalString(Object? value) {
    return value is String ? value : null;
  }
}
