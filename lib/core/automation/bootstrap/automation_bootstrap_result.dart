import '../domain/automation.dart';

/// Result returned after initializing the Automation Core registry.
final class AutomationBootstrapResult {
  AutomationBootstrapResult({
    required this.startedAt,
    required this.completedAt,
    required Iterable<Automation> loadedAutomations,
  }) : loadedAutomations = List<Automation>.unmodifiable(loadedAutomations) {
    if (completedAt.isBefore(startedAt)) {
      throw ArgumentError(
        'The bootstrap completion time must not be before its start time.',
      );
    }
  }

  /// Time at which initialization started.
  final DateTime startedAt;

  /// Time at which initialization completed.
  final DateTime completedAt;

  /// Automation definitions loaded into the runtime registry.
  final List<Automation> loadedAutomations;

  /// Total number of loaded automation definitions.
  int get loadedCount => loadedAutomations.length;

  /// Duration of the initialization operation.
  Duration get duration => completedAt.difference(startedAt);

  /// Whether no automation definition was loaded.
  bool get isEmpty => loadedAutomations.isEmpty;

  /// Whether at least one automation definition was loaded.
  bool get isNotEmpty => loadedAutomations.isNotEmpty;

  @override
  String toString() {
    return 'AutomationBootstrapResult('
        'loadedCount: $loadedCount, '
        'duration: $duration'
        ')';
  }
}
