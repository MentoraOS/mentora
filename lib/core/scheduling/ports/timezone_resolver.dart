/// Timezone identity, expressed as an IANA identifier.
///
/// AD-020: canonical timezone identity uses IANA identifiers such as
/// `Africa/Bamako`, `Africa/Abidjan` or `Europe/Paris`. A fixed UTC offset is
/// not timezone identity and must not be treated as equivalent, because an
/// offset cannot express daylight-saving transitions.
final class TimezoneId {
  /// The only accepted single-component identifier.
  static const String utc = 'UTC';

  final String value;

  factory TimezoneId(String value) {
    final identifier = value.trim();

    if (identifier.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be empty');
    }
    if (!_isIanaIdentifier(identifier)) {
      throw ArgumentError.value(
        value,
        'value',
        'must be an IANA timezone identifier such as Africa/Bamako, '
            'not a UTC offset',
      );
    }

    return TimezoneId._(identifier);
  }

  const TimezoneId._(this.value);

  static bool _isIanaIdentifier(String identifier) {
    if (identifier == utc) {
      return true;
    }
    if (identifier.startsWith('+') || identifier.startsWith('-')) {
      return false;
    }
    if (identifier.contains(' ')) {
      return false;
    }

    return identifier.contains('/');
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TimezoneId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Raised when a resolver cannot interpret the requested timezone identity.
///
/// A resolver MUST fail closed rather than approximate an unsupported zone.
/// It MUST NOT substitute `UTC`, a device timezone, a country-derived zone or
/// any other identity.
final class UnsupportedTimezoneException implements Exception {
  const UnsupportedTimezoneException(this.zone);

  final TimezoneId zone;

  @override
  String toString() {
    return 'UnsupportedTimezoneException: $zone is not supported by this '
        'resolver.';
  }
}

/// Scheduling-owned port resolving expert-local civil time to instants.
///
/// AD-020: Scheduling owns this abstraction; the Domain depends on the port
/// and never on an implementation. Implementations belong to Infrastructure.
///
/// The AD-020 Clarification (Production TimezoneResolver Authorization)
/// authorizes a production implementation of this port for the purpose of
/// satisfying AD-022. An implementation states its own supported identities;
/// this port claims no IANA or DST coverage on their behalf.
///
/// Implementations must reason from [TimezoneId] identity rather than from a
/// fixed offset, and must throw [UnsupportedTimezoneException] for any
/// identity they cannot interpret.
abstract interface class TimezoneResolver {
  /// Resolves a civil (wall-clock) date-time in [zone] to a UTC instant.
  DateTime toUtc({required DateTime localDateTime, required TimezoneId zone});

  /// Projects a UTC instant into civil (wall-clock) time in [zone].
  DateTime fromUtc({required DateTime utcDateTime, required TimezoneId zone});
}
