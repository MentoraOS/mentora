/// Describes the event or signal that starts an automation.
final class AutomationTrigger {
  AutomationTrigger({
    required String type,
    Map<String, Object?> configuration = const <String, Object?>{},
  }) : type = _requireType(type),
       configuration = Map.unmodifiable(configuration);

  final String type;
  final Map<String, Object?> configuration;

  AutomationTrigger copyWith({
    String? type,
    Map<String, Object?>? configuration,
  }) {
    return AutomationTrigger(
      type: type ?? this.type,
      configuration: configuration ?? this.configuration,
    );
  }

  static String _requireType(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'type',
        'The automation trigger type must not be empty.',
      );
    }

    return normalizedValue;
  }
}
