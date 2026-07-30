import 'automation_action.dart';
import 'automation_condition.dart';
import 'automation_id.dart';
import 'automation_status.dart';
import 'automation_trigger.dart';

/// Immutable aggregate describing one enterprise automation definition.
final class Automation {
  Automation({
    required this.id,
    required String name,
    required this.version,
    required this.status,
    required this.trigger,
    List<AutomationCondition> conditions = const <AutomationCondition>[],
    List<AutomationAction> actions = const <AutomationAction>[],
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : name = _requireName(name),
       conditions = List.unmodifiable(conditions),
       actions = List.unmodifiable(actions),
       createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc(),
       metadata = Map.unmodifiable(metadata) {
    if (version < 1) {
      throw ArgumentError.value(
        version,
        'version',
        'The automation version must be greater than or equal to 1.',
      );
    }

    if (this.updatedAt.isBefore(this.createdAt)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'The update date must not be earlier than the creation date.',
      );
    }

    if (status == AutomationStatus.active && this.actions.isEmpty) {
      throw ArgumentError(
        'An active automation must contain at least one action.',
      );
    }
  }

  final AutomationId id;
  final String name;
  final int version;
  final AutomationStatus status;
  final AutomationTrigger trigger;
  final List<AutomationCondition> conditions;
  final List<AutomationAction> actions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, Object?> metadata;

  bool get isDraft => status == AutomationStatus.draft;
  bool get isActive => status == AutomationStatus.active;
  bool get isPaused => status == AutomationStatus.paused;
  bool get isArchived => status == AutomationStatus.archived;

  Automation copyWith({
    String? name,
    int? version,
    AutomationStatus? status,
    AutomationTrigger? trigger,
    List<AutomationCondition>? conditions,
    List<AutomationAction>? actions,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  }) {
    return Automation(
      id: id,
      name: name ?? this.name,
      version: version ?? this.version,
      status: status ?? this.status,
      trigger: trigger ?? this.trigger,
      conditions: conditions ?? this.conditions,
      actions: actions ?? this.actions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  static String _requireName(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'name',
        'The automation name must not be empty.',
      );
    }

    return normalizedValue;
  }
}
