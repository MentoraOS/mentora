class TimezoneInfo {
  final String id;

  /// Africa/Bamako
  final String name;

  /// Mali
  final String country;

  /// UTC
  final String abbreviation;

  /// +0
  final Duration offset;

  const TimezoneInfo({
    required this.id,
    required this.name,
    required this.country,
    required this.abbreviation,
    required this.offset,
  });

  bool get isUtc => offset == Duration.zero;

  int get offsetInMinutes => offset.inMinutes;

  int get offsetInHours => offset.inHours;

  String get displayName {
    final sign = offset.isNegative ? '-' : '+';

    final hours = offset.inHours.abs();

    return '$name (UTC$sign$hours)';
  }
}
