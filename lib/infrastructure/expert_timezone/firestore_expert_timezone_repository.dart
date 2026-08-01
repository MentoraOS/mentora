import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/expert_timezone/expert_timezone_declaration_repository.dart';

/// Persists the expert's declared timezone identity on the Catalog document.
///
/// The identity lives at `experts/{expertId}.expertTimezone` — the exact
/// field the Expert Catalog mapper already reads (Wave A) — so a declaration
/// becomes immediately authoritative for the C2/C3 booking funnel. The write
/// merges: availability and profile fields are untouched.
final class FirestoreExpertTimezoneRepository
    implements ExpertTimezoneDeclarationRepository {
  const FirestoreExpertTimezoneRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<String?> loadByExpertId(String expertId) async {
    try {
      final snapshot = await _document(expertId).get();
      final value = snapshot.data()?['expertTimezone'];
      if (value is! String || value.trim().isEmpty) {
        return null;
      }
      return value;
    } catch (error) {
      throw ExpertTimezoneRepositoryException(cause: error);
    }
  }

  @override
  Future<void> saveByExpertId({
    required String expertId,
    required String timezone,
  }) async {
    try {
      await _document(expertId).set(<String, dynamic>{
        'expertTimezone': timezone,
      }, SetOptions(merge: true));
    } catch (error) {
      throw ExpertTimezoneRepositoryException(cause: error);
    }
  }

  DocumentReference<Map<String, dynamic>> _document(String expertId) {
    return _firestore.collection('experts').doc(expertId);
  }
}
