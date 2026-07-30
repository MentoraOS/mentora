import 'dart:collection';

final class ExpertCatalogEntry {
  ExpertCatalogEntry({
    required this.id,
    required this.name,
    required this.job,
    required this.country,
    required this.rating,
    required this.online,
    required Map<String, List<String>> availability,
    this.consultations,
    this.photoUrl,
    this.experienceYears,
    this.satisfactionRate,
    this.rate30,
    this.rate60,
    this.rate120,
    List<String>? specialities,
    List<String>? languages,
    this.bio,
  }) : availability = immutableAvailability(availability),
       specialities = specialities == null
           ? null
           : List.unmodifiable(specialities),
       languages = languages == null ? null : List.unmodifiable(languages);

  final String id;
  final String name;
  final String job;
  final String country;
  final String rating;
  final bool online;
  final String? consultations;
  final String? photoUrl;
  final String? experienceYears;
  final String? satisfactionRate;
  final num? rate30;
  final num? rate60;
  final num? rate120;
  final List<String>? specialities;
  final List<String>? languages;
  final String? bio;
  final Map<String, List<String>> availability;

  static Map<String, List<String>> immutableAvailability(
    Map<String, List<String>> availability,
  ) {
    return UnmodifiableMapView(<String, List<String>>{
      for (final entry in availability.entries)
        entry.key: List.unmodifiable(entry.value),
    });
  }
}
