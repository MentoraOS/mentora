import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/session/session_model.dart';
import '../../domain/session/session_repository.dart';

final class FirebaseSessionRepository implements SessionRepository {
  FirebaseSessionRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<SessionModel?> fetchCurrentSession() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data() ?? <String, dynamic>{};

    return SessionModel.fromMap(
      id: user.uid,
      data: {...data, 'email': user.email ?? data['email'] ?? ''},
    );
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }
}
