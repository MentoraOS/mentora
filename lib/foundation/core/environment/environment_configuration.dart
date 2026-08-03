/// The official runtime environments. `unconfigured` is a first-class
/// state: an absent define never silently becomes a guess (fail
/// closed) — it becomes an explicit, visible fact.
enum MentoraEnvironment { unconfigured, development, staging, production }

/// Reads the environment from the official `MENTORA_*` defines — the
/// house rule: configuration is injected, never hard-coded.
final class EnvironmentConfiguration {
  final MentoraEnvironment environment;

  const EnvironmentConfiguration({required this.environment});

  static const String _rawEnvironment = String.fromEnvironment('MENTORA_ENV');

  factory EnvironmentConfiguration.fromDefines() {
    return EnvironmentConfiguration(environment: _parse(_rawEnvironment));
  }

  static MentoraEnvironment _parse(String raw) {
    switch (raw) {
      case 'development':
        return MentoraEnvironment.development;
      case 'staging':
        return MentoraEnvironment.staging;
      case 'production':
        return MentoraEnvironment.production;
      default:
        return MentoraEnvironment.unconfigured;
    }
  }

  bool get isProduction => environment == MentoraEnvironment.production;
  bool get isConfigured => environment != MentoraEnvironment.unconfigured;
}
