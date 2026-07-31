import '../../core/scheduling/scheduling.dart';

/// Production [TimezoneResolver] for the verified Mentora launch market.
///
/// Authorized by the AD-020 Clarification (Production TimezoneResolver
/// Authorization) to satisfy AD-022.
///
/// **Support is intentionally restricted.** This resolver interprets only the
/// IANA identities listed in [supportedZones], each of which is a verified
/// fixed-offset zone with no daylight-saving transition. Every other identity
/// — including `Europe/Paris` and every other DST zone — fails closed with
/// [UnsupportedTimezoneException]. Extending Mentora beyond these zones
/// requires a resolver backed by a real IANA/DST database, which is a separate
/// authorized decision.
///
/// The resolver is keyed by [TimezoneId] identity. The IANA name remains the
/// canonical identity even where the current offset happens to equal UTC; the
/// offset is an internal interpretation capability, never an identity
/// (AD-020 decision 12).
///
/// It reads no device timezone, calls no clock, and knows nothing about
/// countries: country-to-timezone inference is forbidden by AD-022
/// Clarification A.
final class LaunchMarketTimezoneResolver implements TimezoneResolver {
  const LaunchMarketTimezoneResolver();

  /// Verified fixed-offset launch-market identities.
  ///
  /// Each entry is an explicit resolver capability, not a mapping derived from
  /// any country, profile or device value.
  static const Map<String, Duration> _offsets = <String, Duration>{
    'Africa/Bamako': Duration.zero,
    'Africa/Dakar': Duration.zero,
    'Africa/Abidjan': Duration.zero,
    TimezoneId.utc: Duration.zero,
  };

  /// The IANA identities this resolver can interpret.
  static Set<String> get supportedZones => _offsets.keys.toSet();

  /// Whether [zone] is interpretable by this resolver.
  static bool supports(TimezoneId zone) => _offsets.containsKey(zone.value);

  @override
  DateTime toUtc({required DateTime localDateTime, required TimezoneId zone}) {
    final offset = _offsetFor(zone);

    // Only the civil (wall-clock) fields are read, so the device timezone
    // cannot influence the result.
    final asIfUtc = DateTime.utc(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
      localDateTime.hour,
      localDateTime.minute,
      localDateTime.second,
      localDateTime.millisecond,
      localDateTime.microsecond,
    );

    return asIfUtc.subtract(offset);
  }

  @override
  DateTime fromUtc({required DateTime utcDateTime, required TimezoneId zone}) {
    if (!utcDateTime.isUtc) {
      throw ArgumentError.value(
        utcDateTime,
        'utcDateTime',
        'must be a UTC instant; a device-local value is not accepted',
      );
    }

    final offset = _offsetFor(zone);

    // The result carries the civil (wall-clock) fields of [zone]. It stays
    // UTC-flagged so no device timezone is applied on the way out.
    return utcDateTime.add(offset);
  }

  Duration _offsetFor(TimezoneId zone) {
    final offset = _offsets[zone.value];
    if (offset == null) {
      throw UnsupportedTimezoneException(zone);
    }

    return offset;
  }
}
