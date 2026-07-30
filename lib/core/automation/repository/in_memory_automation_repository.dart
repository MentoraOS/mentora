import 'dart:collection';

import '../domain/automation.dart';
import '../domain/automation_id.dart';
import 'automation_repository.dart';

/// In-memory implementation of [AutomationRepository].
///
/// Intended for:
/// - unit and architecture tests;
/// - local development;
/// - the first AutomationModule bootstrap.
///
/// Calling [save] with an existing identifier replaces the stored
/// automation while preserving its original insertion position.
final class InMemoryAutomationRepository implements AutomationRepository {
  InMemoryAutomationRepository({
    Iterable<Automation> automations = const <Automation>[],
  }) {
    for (final Automation automation in automations) {
      _automations[automation.id] = automation;
    }
  }

  final LinkedHashMap<AutomationId, Automation> _automations =
      LinkedHashMap<AutomationId, Automation>();

  @override
  Future<void> save(Automation automation) async {
    _automations[automation.id] = automation;
  }

  @override
  Future<Automation?> findById(AutomationId id) async {
    return _automations[id];
  }

  @override
  Future<List<Automation>> findAll() async {
    return List<Automation>.unmodifiable(_automations.values);
  }

  @override
  Future<bool> exists(AutomationId id) async {
    return _automations.containsKey(id);
  }

  @override
  Future<bool> delete(AutomationId id) async {
    return _automations.remove(id) != null;
  }

  /// Removes all persisted automation definitions.
  ///
  /// This method is intentionally outside [AutomationRepository] because
  /// it is mainly useful for tests and local lifecycle management.
  Future<void> clear() async {
    _automations.clear();
  }

  /// Number of persisted automation definitions.
  int get length => _automations.length;

  bool get isEmpty => _automations.isEmpty;

  bool get isNotEmpty => _automations.isNotEmpty;
}
