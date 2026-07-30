import 'dart:collection';

import '../domain/automation.dart';
import '../domain/automation_id.dart';
import '../domain/automation_status.dart';
import 'automation_registry.dart';
import 'automation_registry_exception.dart';

/// In-memory implementation of [AutomationRegistry].
///
/// This implementation:
/// - preserves registration order;
/// - rejects duplicate automation identifiers;
/// - provides constant-time lookup by identifier;
/// - exposes immutable collections;
/// - performs atomic bulk registration.
final class InMemoryAutomationRegistry implements AutomationRegistry {
  InMemoryAutomationRegistry({
    Iterable<Automation> automations = const <Automation>[],
  }) {
    registerAll(automations);
  }

  final LinkedHashMap<AutomationId, Automation> _automations =
      LinkedHashMap<AutomationId, Automation>();

  @override
  int get length => _automations.length;

  @override
  bool get isEmpty => _automations.isEmpty;

  @override
  bool get isNotEmpty => _automations.isNotEmpty;

  @override
  void register(Automation automation) {
    final AutomationId automationId = automation.id;

    if (_automations.containsKey(automationId)) {
      throw AutomationAlreadyRegisteredException(automationId.toString());
    }

    _automations[automationId] = automation;
  }

  @override
  void registerAll(Iterable<Automation> automations) {
    final List<Automation> candidates = List<Automation>.unmodifiable(
      automations,
    );

    if (candidates.isEmpty) {
      return;
    }

    _validateBulkRegistration(candidates);

    for (final Automation automation in candidates) {
      _automations[automation.id] = automation;
    }
  }

  @override
  Automation resolve(AutomationId id) {
    final Automation? automation = _automations[id];

    if (automation == null) {
      throw AutomationNotFoundException(id.toString());
    }

    return automation;
  }

  @override
  Automation? tryResolve(AutomationId id) {
    return _automations[id];
  }

  @override
  bool contains(AutomationId id) {
    return _automations.containsKey(id);
  }

  @override
  bool unregister(AutomationId id) {
    return _automations.remove(id) != null;
  }

  @override
  List<Automation> getAll() {
    return List<Automation>.unmodifiable(_automations.values);
  }

  @override
  List<Automation> getActive() {
    return List<Automation>.unmodifiable(
      _automations.values.where(
        (Automation automation) => automation.status == AutomationStatus.active,
      ),
    );
  }

  @override
  void clear() {
    _automations.clear();
  }

  void _validateBulkRegistration(List<Automation> candidates) {
    final Set<AutomationId> candidateIds = <AutomationId>{};

    for (final Automation automation in candidates) {
      final AutomationId automationId = automation.id;

      if (_automations.containsKey(automationId) ||
          !candidateIds.add(automationId)) {
        throw AutomationAlreadyRegisteredException(automationId.toString());
      }
    }
  }
}
