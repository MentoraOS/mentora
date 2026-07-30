import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/infrastructure/favorites/favorite_experts_firestore_mapper.dart';

void main() {
  group('FavoriteExpertsFirestoreMapper', () {
    const mapper = FavoriteExpertsFirestoreMapper();

    test('maps the persisted favorite expert identifiers', () {
      final ids = mapper.favoriteIdsFromUserMap(const <String, dynamic>{
        'favoriteExperts': <String>['expert_1', 'expert_2'],
      });

      expect(ids, ['expert_1', 'expert_2']);
    });

    test('maps absent favorites to an empty list', () {
      expect(mapper.favoriteIdsFromUserMap(null), isEmpty);
      expect(mapper.favoriteIdsFromUserMap(const {}), isEmpty);
    });

    test('maps an expert card using the existing display defaults', () {
      final expert = mapper.expertFromMap(
        id: 'expert_1',
        data: const <String, dynamic>{'rating': 4.8},
      );

      expect(expert.id, 'expert_1');
      expect(expert.name, 'Expert');
      expect(expert.title, 'Expert Mentora');
      expect(expert.country, '');
      expect(expert.rating, '4.8');
      expect(expert.price, '500 FCFA/min');
    });

    test('maps removal to the exact existing Firestore operation', () {
      final data = mapper.removalToMap('expert_1');

      expect(data.keys, {'favoriteExperts'});
      expect(data['favoriteExperts'], isA<FieldValue>());
    });
  });
}
