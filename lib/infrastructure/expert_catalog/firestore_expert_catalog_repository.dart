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
