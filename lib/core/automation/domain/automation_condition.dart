/// Describes one condition evaluated before automation actions are executed.
final class AutomationCondition {
  AutomationCondition({
    required String type,
    Map<String, Object?> configuration = const <String, Object?>{},
    this.negated = false,
  }) : type = _requireType(type),
       configuration = Map.unmodifiable(configuration);

  final String type;
  final Map<String, Object?> configuration;
  final bool negated;

  AutomationCondition copyWith({
    String? type,
    Map<String, Object?>? configuration,
    bool? negated,
  }) {
    return AutomationCondition(
      type: type ?? this.type,
      configuration: configuration ?? this.configuration,
      negated: negated ?? this.negated,
    );
  }

  static String _requireType(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'type',
        'The automation condition type must not be empty.',
      );
    }

    return normalizedValue;
  }
}
