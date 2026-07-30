import '../../domain/expert_catalog/expert_catalog_entry.dart';

final class ExpertCatalogFirestoreMapper {
  const ExpertCatalogFirestoreMapper();

  ExpertCatalogEntry fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return ExpertCatalogEntry(
      id: documentId,
      name: _stringOrDefault(data['name'], 'Expert'),
      job: _firstString(data['job'], data['title'], fallback: 'Expert Mentora'),
      country: _stringOrDefault(data['country'], ''),
      rating: _stringifiedOrDefault(data['rating'], '0'),
      online: _firstBool(data['online'], data['isAvailable'], fallback: true),
      consultations: _optionalStringified(data['consultations']),
      photoUrl: _optionalString(data['photoUrl']),
      experienceYears: _optionalStringified(
        data['experienceYears'] ?? data['experience'],
      ),
      satisfactionRate: _optionalStringified(data['satisfactionRate']),
      rate30: _optionalNumber(data['rate30']),
      rate60: _optionalNumber(data['rate60']),
      rate120: _optionalNumber(data['rate120']),
      specialities: _firstStringList(data['specialities'], data['skills']),
      languages: _optionalStringList(data['languages']),
      bio: _firstOptionalString(data['bio'], data['about']),
      availability: _availability(data['availability']),
    );
  }

  String _stringOrDefault(Object? value, String fallback) {
    return value is String ? value : fallback;
  }

  String _firstString(
    Object? primary,
    Object? fallbackValue, {
    required String fallback,
  }) {
    if (primary is String) return primary;
    if (fallbackValue is String) return fallbackValue;
    return fallback;
  }

  String? _firstOptionalString(Object? primary, Object? fallback) {
    if (primary is String) return primary;
    if (fallback is String) return fallback;
    return null;
  }

  bool _firstBool(
    Object? primary,
    Object? fallbackValue, {
    required bool fallback,
  }) {
    if (primary is bool) return primary;
    if (fallbackValue is bool) return fallbackValue;
    return fallback;
  }

  String _stringifiedOrDefault(Object? value, String fallback) {
    return value is String || value is num ? value.toString() : fallback;
  }

  String? _optionalStringified(Object? value) {
    return value is String || value is num ? value.toString() : null;
  }

  String? _optionalString(Object? value) {
    return value is String ? value : null;
  }

  num? _optionalNumber(Object? value) {
    return value is num ? value : null;
  }

  List<String>? _firstStringList(Object? primary, Object? fallback) {
    return _optionalStringList(primary) ?? _optionalStringList(fallback);
  }

  List<String>? _optionalStringList(Object? value) {
    if (value is! List) return null;
    return value.whereType<String>().toList(growable: false);
  }

  Map<String, List<String>> _availability(Object? value) {
    if (value is! Map) return const <String, List<String>>{};

    return <String, List<String>>{
      for (final entry in value.entries)
        if (entry.key is String && entry.value is List)
          entry.key as String: (entry.value as List).whereType<String>().toList(
            growable: false,
          ),
    };
  }
}
