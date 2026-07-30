/// Immutable value object identifying an automation definition.
final class AutomationId {
  factory AutomationId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'value',
        'The automation identifier must not be empty.',
      );
    }

    return AutomationId._(normalizedValue);
  }

  const AutomationId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AutomationId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
