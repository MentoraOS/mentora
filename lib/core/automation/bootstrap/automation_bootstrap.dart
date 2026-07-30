import 'automation_bootstrap_result.dart';

/// Initializes the Automation Core before it begins processing executions.
///
/// Implementations are responsible for loading persisted automation
/// definitions and making them available to the runtime registry.
abstract interface class AutomationBootstrap {
  /// Whether the Automation Core has already been initialized successfully.
  bool get isInitialized;

  /// Initializes or refreshes the Automation Core registry.
  ///
  /// When [forceRefresh] is false, an implementation may return the previous
  /// successful result without loading the repository again.
  ///
  /// When [forceRefresh] is true, persisted definitions must be reloaded and
  /// the runtime registry synchronized again.
  Future<AutomationBootstrapResult> initialize({bool forceRefresh = false});
}
