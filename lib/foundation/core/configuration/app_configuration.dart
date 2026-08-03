import '../environment/environment_configuration.dart';

/// The immutable application configuration assembled at bootstrap.
/// Facts only — no logic, no mutable state.
final class AppConfiguration {
  final String applicationName;
  final MentoraEnvironment environment;

  const AppConfiguration({
    required this.applicationName,
    required this.environment,
  });
}
