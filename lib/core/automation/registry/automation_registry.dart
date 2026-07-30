import '../domain/automation.dart';
import '../domain/automation_id.dart';

abstract interface class AutomationRegistry {
  /// Registers an automation definition.
  void register(Automation automation);

  /// Registers multiple automation definitions.
  void registerAll(Iterable<Automation> automations);

  /// Resolves an automation by its identifier.
  Automation resolve(AutomationId id);

  /// Returns null if the automation does not exist.
  Automation? tryResolve(AutomationId id);

  /// Returns true if the automation exists.
  bool contains(AutomationId id);

  /// Removes an automation.
  bool unregister(AutomationId id);

  /// Returns all registered automations.
  List<Automation> getAll();

  /// Returns only active automations.
  List<Automation> getActive();

  /// Removes everything.
  void clear();

  /// Number of registered automations.
  int get length;

  bool get isEmpty;

  bool get isNotEmpty;
}
