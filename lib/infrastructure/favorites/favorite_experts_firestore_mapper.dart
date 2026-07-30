import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/favorites/favorite_expert.dart';

final class FavoriteExpertsFirestoreMapper {
  const FavoriteExpertsFirestoreMapper();

  List<String> favoriteIdsFromUserMap(Map<String, dynamic>? data) {
    return List<String>.from(data?['favoriteExperts'] ?? const <String>[]);
  }

  FavoriteExpert expertFromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoriteExpert(
      id: id,
      name: _stringOrDefault(data['name'], 'Expert'),
      title: _stringOrDefault(data['title'], 'Expert Mentora'),
      country: _stringOrDefault(data['country'], ''),
      rating: data['rating']?.toString() ?? '0',
      price: _stringOrDefault(data['price'], '500 FCFA/min'),
    );
  }

  Map<String, dynamic> removalToMap(String expertId) {
    return <String, dynamic>{
      'favoriteExperts': FieldValue.arrayRemove(<String>[expertId]),
    };
  }

  String _stringOrDefault(Object? value, String fallback) {
    return value is String ? value : fallback;
  }
}
