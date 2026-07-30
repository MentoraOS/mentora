import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/profile/profile.dart';
import '../../domain/profile/profile_repository.dart';
import 'profile_firestore_mapper.dart';

final class FirestoreProfileRepository implements ProfileRepository {
  const FirestoreProfileRepository({
    required FirebaseFirestore firestore,
    ProfileFirestoreMapper mapper = const ProfileFirestoreMapper(),
  }) : _firestore = firestore,
       _mapper = mapper;

  final FirebaseFirestore _firestore;
  final ProfileFirestoreMapper _mapper;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  @override
  Future<Profile?> findByUserId(String userId) async {
    try {
      final snapshot = await _users.doc(userId).get();
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return null;
      }

      return _mapper.fromMap(id: snapshot.id, data: data);
    } catch (error) {
      throw ProfileRepositoryException(cause: error);
    }
  }

  @override
  Stream<Profile?> observeByUserId(String userId) {
    return _users
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          try {
            final data = snapshot.data();

            if (!snapshot.exists || data == null) {
              return null;
            }

            return _mapper.fromMap(id: snapshot.id, data: data);
          } catch (error) {
            throw ProfileRepositoryException(cause: error);
          }
        })
        .handleError((Object error, StackTrace stackTrace) {
          if (error is ProfileRepositoryException) {
            Error.throwWithStackTrace(error, stackTrace);
          }

          Error.throwWithStackTrace(
            ProfileRepositoryException(cause: error),
            stackTrace,
          );
        });
  }

  @override
  Future<void> update({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      await _users
          .doc(userId)
          .update(
            _mapper.updateToMap(
              firstName: firstName,
              lastName: lastName,
              phone: phone,
            ),
          );
    } catch (error) {
      throw ProfileRepositoryException(cause: error);
    }
  }
}
