/// Describes one operation executed by an automation.
final class AutomationAction {
  AutomationAction({
    required String type,
    Map<String, Object?> configuration = const <String, Object?>{},
    this.continueOnFailure = false,
  }) : type = _requireType(type),
       configuration = Map.unmodifiable(configuration);

  final String type;
  final Map<String, Object?> configuration;
  final bool continueOnFailure;

  AutomationAction copyWith({
    String? type,
    Map<String, Object?>? configuration,
    bool? continueOnFailure,
  }) {
    return AutomationAction(
      type: type ?? this.type,
      configuration: configuration ?? this.configuration,
      continueOnFailure: continueOnFailure ?? this.continueOnFailure,
    );
  }

  static String _requireType(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'type',
        'The automation action type must not be empty.',
      );
    }

    return normalizedValue;
  }
}
