import 'dart:async';

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
/// boundary, lifecycle. Runs before anything else (official stage:
/// Initialisation).
final class CoreBootstrapStep implements StartupStep {
  const CoreBootstrapStep();

  @override
  String get name => 'initialisation';

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

/// Verifies — fail closed — that every official service resolves
/// before anything starts (official stage: Validation). A container
/// that cannot serve its contract never reaches runApp.
final class ValidationBootstrapStep implements StartupStep {
  const ValidationBootstrapStep();

  @override
  String get name => 'validation';

  @override
  Future<void> run(FoundationServices services) async {
    services
      ..get<FoundationLogger>()
      ..get<EnvironmentConfiguration>()
      ..get<AppConfiguration>()
      ..get<ApplicationLifecycle>();
    validateDesignKit(services);
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
      steps: const [
        CoreBootstrapStep(),
        DesignKitBootstrapStep(),
        ValidationBootstrapStep(),
      ],
      logger: _logger,
    );
    final report = await pipeline.execute(services);
    _logger.log(
      LogLevel.info,
      'Foundation ready (${report.completedSteps.length} steps).',
    );
    return services;
  }

  /// The production path (official stages: Injection then Démarrage).
  ///
  /// The whole application runs inside a guarded zone: uncaught async
  /// and zone errors reach the official logger — never the void.
  Future<void> launch() async {
    await runZonedGuarded(() async {
      final binding = WidgetsFlutterBinding.ensureInitialized();
      final services = await initialize();
      services.get<ApplicationLifecycle>().attach(binding);
      runApp(MentoraFoundationApp(services: services));
    }, (error, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Uncaught zone error',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }
}
