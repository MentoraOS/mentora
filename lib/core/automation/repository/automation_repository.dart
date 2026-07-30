import '../domain/automation.dart';
import '../domain/automation_id.dart';

/// Repository responsible for persisting automation definitions.
///
/// Unlike the AutomationRegistry, this repository represents the durable
/// storage of automation definitions.
abstract interface class AutomationRepository {
  /// Creates or updates an automation definition.
  Future<void> save(Automation automation);

  /// Returns the automation identified by [id].
  ///
  /// Returns null if no matching automation exists.
  Future<Automation?> findById(AutomationId id);

  /// Returns all persisted automations.
  Future<List<Automation>> findAll();

  /// Returns true if an automation exists.
  Future<bool> exists(AutomationId id);

  /// Deletes an automation.
  ///
  /// Returns true if an automation was removed.
  Future<bool> delete(AutomationId id);
}
