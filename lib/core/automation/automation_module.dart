import 'bootstrap/automation_bootstrap.dart';
import 'bootstrap/automation_bootstrap_result.dart';
import 'bootstrap/default_automation_bootstrap.dart';
import 'engine/automation_engine.dart';
import 'engine/automation_executor.dart';
import 'registry/automation_registry.dart';
import 'registry/in_memory_automation_registry.dart';
import 'repository/automation_execution_repository.dart';
import 'repository/automation_repository.dart';
import 'repository/in_memory_automation_execution_repository.dart';
import 'repository/in_memory_automation_repository.dart';
import 'runtime/automation_runtime.dart';
import 'runtime/default_automation_runtime.dart';

/// Composition root for the Automation Core.
///
/// [AutomationModule] assembles the dependencies required to register,
/// persist, initialize and execute automations.
///
/// The module contains no business logic. Its sole responsibility is
/// dependency composition and ownership.
final class AutomationModule {
  /// Creates an Automation Core module.
  ///
  /// Any dependency may be replaced for tests or infrastructure-specific
  /// implementations. Dependencies not supplied are created in memory.
  ///
  /// The same resolved instances are injected into all dependent components.
  factory AutomationModule({
    Iterable<AutomationExecutor> executors = const <AutomationExecutor>[],
    AutomationRegistry? registry,
    AutomationRepository? automationRepository,
    AutomationExecutionRepository? executionRepository,
    AutomationEngine? engine,
    AutomationRuntime? runtime,
    AutomationBootstrap? bootstrap,
  }) {
    final AutomationRegistry resolvedRegistry =
        registry ?? InMemoryAutomationRegistry();

    final AutomationRepository resolvedAutomationRepository =
        automationRepository ?? InMemoryAutomationRepository();

    final AutomationExecutionRepository resolvedExecutionRepository =
        executionRepository ?? InMemoryAutomationExecutionRepository();

    final List<AutomationExecutor> resolvedExecutors =
        List<AutomationExecutor>.unmodifiable(executors);

    final AutomationEngine resolvedEngine =
        engine ?? AutomationEngine(executors: resolvedExecutors);

    final AutomationRuntime resolvedRuntime =
        runtime ??
        DefaultAutomationRuntime(
          registry: resolvedRegistry,
          engine: resolvedEngine,
          executionRepository: resolvedExecutionRepository,
        );

    final AutomationBootstrap resolvedBootstrap =
        bootstrap ??
        DefaultAutomationBootstrap(
          automationRepository: resolvedAutomationRepository,
          registry: resolvedRegistry,
        );

    return AutomationModule._(
      registry: resolvedRegistry,
      automationRepository: resolvedAutomationRepository,
      executionRepository: resolvedExecutionRepository,
      engine: resolvedEngine,
      runtime: resolvedRuntime,
      bootstrap: resolvedBootstrap,
    );
  }

  /// Internal constructor receiving already-resolved dependencies.
  const AutomationModule._({
    required this.registry,
    required this.automationRepository,
    required this.executionRepository,
    required this.engine,
    required this.runtime,
    required this.bootstrap,
  });

  /// Runtime registry containing resolvable automation definitions.
  final AutomationRegistry registry;

  /// Repository responsible for persisting automation definitions.
  final AutomationRepository automationRepository;

  /// Repository responsible for persisting automation execution history.
  final AutomationExecutionRepository executionRepository;

  /// Engine responsible for executing automation actions.
  final AutomationEngine engine;

  /// Public runtime used to execute registered automations.
  final AutomationRuntime runtime;

  /// Bootstrap responsible for synchronizing persisted automations
  /// with the runtime registry.
  final AutomationBootstrap bootstrap;

  /// Initializes or refreshes the Automation Core.
  Future<AutomationBootstrapResult> initialize({bool forceRefresh = false}) {
    return bootstrap.initialize(forceRefresh: forceRefresh);
  }
}
