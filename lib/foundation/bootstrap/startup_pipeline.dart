import '../core/di/foundation_services.dart';
import '../core/logging/foundation_logger.dart';

/// One named, ordered step of the startup.
abstract interface class StartupStep {
  String get name;
  Future<void> run(FoundationServices services);
}

/// Raised when a step fails: the pipeline is fail closed — it stops at
/// the failing step, names it, and never continues on a broken base.
final class StartupFailure implements Exception {
  final String stepName;
  final Object cause;

  const StartupFailure({required this.stepName, required this.cause});

  @override
  String toString() => 'StartupFailure(step: $stepName, cause: $cause)';
}

/// What actually ran, in order.
final class StartupReport {
  final List<String> completedSteps;

  const StartupReport({required this.completedSteps});
}

/// Runs the steps strictly in order, logging each one. Fail closed:
/// the first failure stops everything and surfaces the step name.
final class StartupPipeline {
  final List<StartupStep> _steps;
  final FoundationLogger _logger;

  StartupPipeline({
    required List<StartupStep> steps,
    required FoundationLogger logger,
  }) : _steps = List.unmodifiable(steps),
       _logger = logger;

  Future<StartupReport> execute(FoundationServices services) async {
    final completed = <String>[];
    for (final step in _steps) {
      try {
        await step.run(services);
        completed.add(step.name);
        _logger.log(LogLevel.info, 'Startup step completed: ${step.name}');
      } catch (cause) {
        _logger.log(
          LogLevel.error,
          'Startup step failed: ${step.name}',
          error: cause,
        );
        throw StartupFailure(stepName: step.name, cause: cause);
      }
    }
    return StartupReport(completedSteps: completed);
  }
}
