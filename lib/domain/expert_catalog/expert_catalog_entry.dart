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
    this.expertTimezone,
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

  /// The expert's declared timezone identity, as a named IANA identifier
  /// (AD-022 Clarification A).
  ///
  /// Expert Catalog OWNS this identity; Scheduling INTERPRETS it; Booking
  /// snapshots it. Expert Catalog performs no timezone conversion.
  ///
  /// Nullable at the persistence/read boundary so legacy expert records
  /// remain readable. Absence stays absence: it is never defaulted to `UTC`,
  /// never derived from [country], never taken from the device, and never
  /// taken from a launch-market default. Modern reservation eligibility fails
  /// closed on absence in a later wave.
  ///
  /// The value is an opaque identity here. Validity is established where the
  /// identity is interpreted, so one malformed expert document cannot poison
  /// catalog reads for every other expert.
  final String? expertTimezone;
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
