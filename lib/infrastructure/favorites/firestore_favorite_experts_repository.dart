import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/favorites/favorite_expert.dart';
import '../../domain/favorites/favorite_experts_repository.dart';
import 'favorite_experts_firestore_mapper.dart';

final class FirestoreFavoriteExpertsRepository
    implements FavoriteExpertsRepository {
  const FirestoreFavoriteExpertsRepository({
    required FirebaseFirestore firestore,
    FavoriteExpertsFirestoreMapper mapper =
        const FavoriteExpertsFirestoreMapper(),
  }) : _firestore = firestore,
       _mapper = mapper;

  final FirebaseFirestore _firestore;
  final FavoriteExpertsFirestoreMapper _mapper;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> get _experts {
    return _firestore.collection('experts');
  }

  @override
  Stream<List<FavoriteExpert>> observeByUserId(String userId) {
    late StreamController<List<FavoriteExpert>> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    userSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    expertsSubscription;

    void addRepositoryError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(
          FavoriteExpertsRepositoryException(cause: error),
          stackTrace,
        );
      }
    }

    controller = StreamController<List<FavoriteExpert>>(
      onListen: () {
        userSubscription = _users.doc(userId).snapshots().listen((
          snapshot,
        ) async {
          try {
            await expertsSubscription?.cancel();
            expertsSubscription = null;

            final favoriteIds = _mapper.favoriteIdsFromUserMap(snapshot.data());

            if (favoriteIds.isEmpty) {
              controller.add(const <FavoriteExpert>[]);
              return;
            }

            expertsSubscription = _experts
                .where(FieldPath.documentId, whereIn: favoriteIds)
                .snapshots()
                .listen((snapshot) {
                  try {
                    controller.add(
                      snapshot.docs
                          .map(
                            (document) => _mapper.expertFromMap(
                              id: document.id,
                              data: document.data(),
                            ),
                          )
                          .toList(growable: false),
                    );
                  } catch (error, stackTrace) {
                    addRepositoryError(error, stackTrace);
                  }
                }, onError: addRepositoryError);
          } catch (error, stackTrace) {
            addRepositoryError(error, stackTrace);
          }
        }, onError: addRepositoryError);
      },
      onCancel: () async {
        await userSubscription?.cancel();
        await expertsSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> remove({
    required String userId,
    required String expertId,
  }) async {
    try {
      await _users.doc(userId).update(_mapper.removalToMap(expertId));
    } catch (error) {
      throw FavoriteExpertsRepositoryException(cause: error);
    }
  }
}
