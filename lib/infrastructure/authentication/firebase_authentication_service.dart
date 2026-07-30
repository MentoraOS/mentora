import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/identity/identity.dart';

final class FirebaseAuthenticationService implements AuthenticationService {
  FirebaseAuthenticationService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthenticationFailure(
          code: AuthenticationFailureCode.unknown,
          message: 'Firebase Auth did not return a user.',
        );
      }

      await _firestore.collection('users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user.uid;
    } on FirebaseAuthException catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthenticationFailure(
          code: AuthenticationFailureCode.unknown,
          message: 'Firebase Auth did not return a user.',
        );
      }

      return user.uid;
    } on FirebaseAuthException catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  AuthenticationFailure _mapFailure(FirebaseAuthException error) {
    final code = switch (error.code) {
      'email-already-in-use' => AuthenticationFailureCode.emailAlreadyInUse,
      'weak-password' => AuthenticationFailureCode.weakPassword,
      'invalid-email' => AuthenticationFailureCode.invalidEmail,
      'user-not-found' => AuthenticationFailureCode.userNotFound,
      'wrong-password' => AuthenticationFailureCode.wrongPassword,
      'invalid-credential' => AuthenticationFailureCode.invalidCredential,
      _ => AuthenticationFailureCode.unknown,
    };

    return AuthenticationFailure(code: code, message: error.message);
  }
}
