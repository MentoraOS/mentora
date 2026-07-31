import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/expert_catalog/expert_catalog_entry.dart';
import '../../domain/expert_catalog/expert_catalog_repository.dart';
import 'expert_catalog_firestore_mapper.dart';

final class FirestoreExpertCatalogRepository
    implements ExpertCatalogRepository {
  const FirestoreExpertCatalogRepository({
    required FirebaseFirestore firestore,
    ExpertCatalogFirestoreMapper mapper = const ExpertCatalogFirestoreMapper(),
  }) : _firestore = firestore,
       _mapper = mapper;

  final FirebaseFirestore _firestore;
  final ExpertCatalogFirestoreMapper _mapper;

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    try {
      final document = await _firestore
          .collection('experts')
          .doc(expertId)
          .get();

      final data = document.data();
      if (!document.exists || data == null) {
        return null;
      }

      // Identity comes from the authoritative Firestore document id, exactly
      // as the watchExperts path does, and the existing mapper is reused.
      return _mapper.fromMap(documentId: document.id, data: data);
    } on ExpertCatalogRepositoryException {
      rethrow;
    } catch (error) {
      throw ExpertCatalogRepositoryException(cause: error);
    }
  }

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return _firestore
        .collection('experts')
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map(
                  (document) => _mapper.fromMap(
                    documentId: document.id,
                    data: document.data(),
                  ),
                )
                .toList(growable: false);
          } catch (error) {
            throw ExpertCatalogRepositoryException(cause: error);
          }
        })
        .handleError((Object error, StackTrace stackTrace) {
          if (error is ExpertCatalogRepositoryException) {
            Error.throwWithStackTrace(error, stackTrace);
          }

          Error.throwWithStackTrace(
            ExpertCatalogRepositoryException(cause: error),
            stackTrace,
          );
        });
  }
}
