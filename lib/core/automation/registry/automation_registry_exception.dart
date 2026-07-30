class AutomationRegistryException implements Exception {
  const AutomationRegistryException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AutomationAlreadyRegisteredException
    extends AutomationRegistryException {
  const AutomationAlreadyRegisteredException(String automationId)
    : super('Automation "$automationId" is already registered.');
}

final class AutomationNotFoundException extends AutomationRegistryException {
  const AutomationNotFoundException(String automationId)
    : super('Automation "$automationId" was not found.');
}
