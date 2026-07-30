import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/expert_availability/expert_availability.dart';
import '../../domain/expert_availability/expert_availability_repository.dart';
import 'expert_availability_firestore_mapper.dart';

final class ExpertAvailabilityRevisionGuard {
  const ExpertAvailabilityRevisionGuard();

  void ensureCurrent({
    required String? expectedRevision,
    required String? actualRevision,
  }) {
    if (expectedRevision == actualRevision) return;

    throw ExpertAvailabilityConcurrencyException(
      expectedRevision: expectedRevision,
      actualRevision: actualRevision,
    );
  }
}

final class FirestoreExpertAvailabilityRepository
    implements ExpertAvailabilityRepository {
  const FirestoreExpertAvailabilityRepository({
    required FirebaseFirestore firestore,
    ExpertAvailabilityFirestoreMapper mapper =
        const ExpertAvailabilityFirestoreMapper(),
    ExpertAvailabilityRevisionGuard revisionGuard =
        const ExpertAvailabilityRevisionGuard(),
  }) : _firestore = firestore,
       _mapper = mapper,
       _revisionGuard = revisionGuard;

  final FirebaseFirestore _firestore;
  final ExpertAvailabilityFirestoreMapper _mapper;
  final ExpertAvailabilityRevisionGuard _revisionGuard;

  @override
  Future<ExpertAvailability> loadByExpertId(String expertId) async {
    try {
      final snapshot = await _expertDocument(expertId).get();
      return _fromSnapshot(snapshot);
    } on FormatException catch (error) {
      throw ExpertAvailabilityRepositoryException(
        cause: error,
        malformedData: true,
      );
    } on ExpertAvailabilityRepositoryException {
      rethrow;
    } catch (error) {
      throw ExpertAvailabilityRepositoryException(cause: error);
    }
  }

  @override
  Future<ExpertAvailability> saveByExpertId({
    required String expertId,
    required ExpertAvailability availability,
  }) async {
    final document = _expertDocument(expertId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(document);
        final current = _fromSnapshot(snapshot);

        _revisionGuard.ensureCurrent(
          expectedRevision: availability.revision,
          actualRevision: current.revision,
        );

        final data = _mapper.toMap(availability);
        if (snapshot.exists) {
          transaction.update(document, data);
        } else {
          transaction.set(document, data);
        }
      });

      final persisted = await document.get(
        const GetOptions(source: Source.server),
      );
      return _fromSnapshot(persisted);
    } on ExpertAvailabilityConcurrencyException {
      rethrow;
    } on FormatException catch (error) {
      throw ExpertAvailabilityRepositoryException(
        cause: error,
        malformedData: true,
      );
    } on ExpertAvailabilityRepositoryException {
      rethrow;
    } catch (error) {
      throw ExpertAvailabilityRepositoryException(cause: error);
    }
  }

  DocumentReference<Map<String, dynamic>> _expertDocument(String expertId) {
    return _firestore.collection('experts').doc(expertId);
  }

  ExpertAvailability _fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      return ExpertAvailability(slotsByDay: const <String, List<String>>{});
    }

    return _mapper.fromMap(snapshot.data() ?? const <String, dynamic>{});
  }
}
