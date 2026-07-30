import '../domain/automation.dart';
import '../registry/automation_registry.dart';
import '../repository/automation_repository.dart';
import 'automation_bootstrap.dart';
import 'automation_bootstrap_result.dart';

/// Default implementation of [AutomationBootstrap].
///
/// This bootstrap synchronizes persisted automation definitions from
/// [AutomationRepository] into the runtime [AutomationRegistry].
///
/// Initialization behavior:
/// - the first successful call loads the repository and populates the registry;
/// - subsequent calls return the cached result;
/// - [forceRefresh] reloads the repository and replaces the registry content;
/// - concurrent initialization calls share the same in-flight operation.
final class DefaultAutomationBootstrap implements AutomationBootstrap {
  DefaultAutomationBootstrap({
    required AutomationRepository automationRepository,
    required AutomationRegistry registry,
    DateTime Function()? clock,
  }) : _automationRepository = automationRepository,
       _registry = registry,
       _clock = clock ?? DateTime.now;

  final AutomationRepository _automationRepository;
  final AutomationRegistry _registry;
  final DateTime Function() _clock;

  AutomationBootstrapResult? _lastSuccessfulResult;
  Future<AutomationBootstrapResult>? _initializationInProgress;

  @override
  bool get isInitialized => _lastSuccessfulResult != null;

  @override
  Future<AutomationBootstrapResult> initialize({bool forceRefresh = false}) {
    final Future<AutomationBootstrapResult>? currentInitialization =
        _initializationInProgress;

    if (currentInitialization != null) {
      return currentInitialization;
    }

    final AutomationBootstrapResult? cachedResult = _lastSuccessfulResult;

    if (!forceRefresh && cachedResult != null) {
      return Future<AutomationBootstrapResult>.value(cachedResult);
    }

    final Future<AutomationBootstrapResult> operation = _initializeInternal();

    _initializationInProgress = operation;

    operation.whenComplete(() {
      if (identical(_initializationInProgress, operation)) {
        _initializationInProgress = null;
      }
    });

    return operation;
  }

  Future<AutomationBootstrapResult> _initializeInternal() async {
    final DateTime startedAt = _utcNow();

    final List<Automation> persistedAutomations = await _automationRepository
        .findAll();

    final List<Automation> snapshot = List<Automation>.unmodifiable(
      persistedAutomations,
    );

    _synchronizeRegistry(snapshot);

    final AutomationBootstrapResult result = AutomationBootstrapResult(
      startedAt: startedAt,
      completedAt: _safeCompletedAt(startedAt),
      loadedAutomations: snapshot,
    );

    _lastSuccessfulResult = result;

    return result;
  }

  void _synchronizeRegistry(List<Automation> automations) {
    final List<Automation> previousRegistryState =
        List<Automation>.unmodifiable(_registry.getAll());

    try {
      _registry.clear();
      _registry.registerAll(automations);
    } catch (_) {
      _restoreRegistry(previousRegistryState);
      rethrow;
    }
  }

  void _restoreRegistry(List<Automation> previousRegistryState) {
    _registry.clear();

    if (previousRegistryState.isNotEmpty) {
      _registry.registerAll(previousRegistryState);
    }
  }

  DateTime _safeCompletedAt(DateTime startedAt) {
    final DateTime now = _utcNow();

    if (now.isBefore(startedAt)) {
      return startedAt;
    }

    return now;
  }

  DateTime _utcNow() => _clock().toUtc();
}
