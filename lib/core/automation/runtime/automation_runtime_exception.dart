/// Base exception for the Automation Runtime.
///
/// These exceptions represent infrastructure or configuration problems.
/// They are different from [AutomationRuntimeFailure], which represents
/// a normal execution outcome.
sealed class AutomationRuntimeException implements Exception {
  const AutomationRuntimeException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the runtime has not been correctly configured.
final class AutomationRuntimeNotInitializedException
    extends AutomationRuntimeException {
  const AutomationRuntimeNotInitializedException()
    : super('The Automation Runtime has not been initialized.');
}

/// Thrown when a required dependency is missing.
final class AutomationRuntimeDependencyException
    extends AutomationRuntimeException {
  const AutomationRuntimeDependencyException(String dependency)
    : super('Required dependency "$dependency" is missing.');
}

/// Thrown when an invalid runtime configuration is detected.
final class AutomationRuntimeConfigurationException
    extends AutomationRuntimeException {
  const AutomationRuntimeConfigurationException(super.message);
}

/// Thrown when the runtime cannot create an execution context.
final class AutomationRuntimeContextException
    extends AutomationRuntimeException {
  const AutomationRuntimeContextException(super.message);
}
