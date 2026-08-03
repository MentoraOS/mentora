import 'package:flutter/widgets.dart';

import '../app/mentora_foundation_app.dart';
import '../core/configuration/app_configuration.dart';
import '../core/di/foundation_services.dart';
import '../core/environment/environment_configuration.dart';
import '../core/errors/foundation_error_handler.dart';
import '../core/lifecycle/application_lifecycle.dart';
import '../core/logging/foundation_logger.dart';
import 'design_kit_bootstrap.dart';
import 'startup_pipeline.dart';

/// Installs the core services: environment, configuration, error
/// boundary, lifecycle. Runs before anything else.
final class CoreBootstrapStep implements StartupStep {
  const CoreBootstrapStep();

  @override
  String get name => 'core';

  @override
  Future<void> run(FoundationServices services) async {
    final environment = EnvironmentConfiguration.fromDefines();
    services.register<EnvironmentConfiguration>(() => environment);
    services.register<AppConfiguration>(
      () => AppConfiguration(
        applicationName: 'Mentora',
        environment: environment.environment,
      ),
    );
    services.register<ApplicationLifecycle>(ApplicationLifecycle.new);
    services.get<FoundationErrorHandler>().install();
  }
}

/// The composition root of the foundation application.
///
/// Builds the container, runs the official startup pipeline (fail
/// closed), and returns the ready services. `launch` is the production
/// path; `initialize` is the testable seam.
final class AppBootstrap {
  final FoundationLogger _logger;

  AppBootstrap({FoundationLogger logger = const ConsoleFoundationLogger()})
    : _logger = logger;

  Future<FoundationServices> initialize() async {
    final services = FoundationServices();
    services.register<FoundationLogger>(() => _logger);
    services.register<FoundationErrorHandler>(
      () => FoundationErrorHandler(logger: _logger),
    );

    final pipeline = StartupPipeline(
      steps: const [CoreBootstrapStep(), DesignKitBootstrapStep()],
      logger: _logger,
    );
    final report = await pipeline.execute(services);
    _logger.log(
      LogLevel.info,
      'Foundation ready (${report.completedSteps.length} steps).',
    );
    return services;
  }

  Future<void> launch() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final services = await initialize();
    services.get<ApplicationLifecycle>().attach(binding);
    runApp(MentoraFoundationApp(services: services));
  }
}
