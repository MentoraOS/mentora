import '../domain/automation.dart';
import '../domain/automation_execution.dart';
import '../domain/automation_id.dart';
import '../engine/automation_engine.dart';
import '../engine/automation_execution_context.dart';
import '../engine/automation_execution_result.dart';
import '../registry/automation_registry.dart';
import '../repository/automation_execution_repository.dart';
import 'automation_runtime.dart';
import 'automation_runtime_context.dart';
import 'automation_runtime_result.dart';

/// Default implementation of [AutomationRuntime].
///
/// This runtime coordinates the complete execution lifecycle:
///
/// 1. Resolve the automation from the registry.
/// 2. Create an immutable runtime context.
/// 3. Translate it into an engine execution context.
/// 4. Execute the automation through [AutomationEngine].
/// 5. Convert the engine result into an [AutomationExecution].
/// 6. Persist the execution history.
/// 7. Return a stable [AutomationRuntimeResult].
final class DefaultAutomationRuntime implements AutomationRuntime {
  DefaultAutomationRuntime({
    required AutomationRegistry registry,
    required AutomationEngine engine,
    required AutomationExecutionRepository executionRepository,
    DateTime Function()? clock,
    String Function(
      AutomationId automationId,
      DateTime requestedAt,
      int sequence,
    )?
    executionIdFactory,
  }) : _registry = registry,
       _engine = engine,
       _executionRepository = executionRepository,
       _clock = clock ?? DateTime.now,
       _executionIdFactory = executionIdFactory ?? _defaultExecutionIdFactory;

  final AutomationRegistry _registry;
  final AutomationEngine _engine;
  final AutomationExecutionRepository _executionRepository;
  final DateTime Function() _clock;

  final String Function(
    AutomationId automationId,
    DateTime requestedAt,
    int sequence,
  )
  _executionIdFactory;

  int _executionSequence = 0;

  @override
  Future<AutomationRuntimeResult> execute(
    AutomationId automationId, {
    Map<String, Object?> input = const <String, Object?>{},
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    final DateTime requestedAt = _utcNow();

    final Automation? automation = _registry.tryResolve(automationId);

    if (automation == null) {
      return AutomationRuntimeNotFound(
        automationId: automationId,
        requestedAt: requestedAt,
        completedAt: _utcNow(),
      );
    }

    try {
      final AutomationRuntimeContext runtimeContext = _createRuntimeContext(
        automation: automation,
        input: input,
        metadata: metadata,
        requestedAt: requestedAt,
      );

      final AutomationExecutionContext executionContext =
          _createExecutionContext(runtimeContext);

      final AutomationExecutionResult engineResult = await _engine.execute(
        executionContext,
      );

      return await _handleEngineResult(
        runtimeContext: runtimeContext,
        engineResult: engineResult,
      );
    } catch (error, stackTrace) {
      return AutomationRuntimeFailure(
        automationId: automationId,
        requestedAt: requestedAt,
        completedAt: _utcNow(),
        message: _normalizeErrorMessage(error),
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  AutomationRuntimeContext _createRuntimeContext({
    required Automation automation,
    required Map<String, Object?> input,
    required Map<String, Object?> metadata,
    required DateTime requestedAt,
  }) {
    return AutomationRuntimeContext(
      automationId: automation.id,
      automation: automation,
      input: input,
      metadata: metadata,
      requestedAt: requestedAt,
    );
  }

  AutomationExecutionContext _createExecutionContext(
    AutomationRuntimeContext runtimeContext,
  ) {
    return AutomationExecutionContext(
      executionId: _createExecutionId(
        automationId: runtimeContext.automationId,
        requestedAt: runtimeContext.requestedAt,
      ),
      automation: runtimeContext.automation,
      startedAt: runtimeContext.requestedAt,
      attempt: 1,
      input: runtimeContext.input,
      metadata: runtimeContext.metadata,
    );
  }

  Future<AutomationRuntimeResult> _handleEngineResult({
    required AutomationRuntimeContext runtimeContext,
    required AutomationExecutionResult engineResult,
  }) {
    return switch (engineResult) {
      AutomationExecutionSuccess success => _handleSuccess(
        runtimeContext: runtimeContext,
        result: success,
      ),
      AutomationExecutionFailure failure => _handleFailure(
        runtimeContext: runtimeContext,
        result: failure,
      ),
      AutomationExecutionSkipped skipped => _handleSkipped(
        runtimeContext: runtimeContext,
        result: skipped,
      ),
    };
  }

  Future<AutomationRuntimeResult> _handleSuccess({
    required AutomationRuntimeContext runtimeContext,
    required AutomationExecutionSuccess result,
  }) async {
    final AutomationExecution execution = AutomationExecution(
      executionId: result.executionId,
      automationId: runtimeContext.automationId,
      automationVersion: runtimeContext.automation.version,
      status: AutomationExecutionStatus.succeeded,
      startedAt: result.startedAt,
      completedAt: result.completedAt,
      input: runtimeContext.input,
      output: result.output,
      metadata: runtimeContext.metadata,
    );

    final AutomationRuntimeFailure? persistenceFailure =
        await _tryPersistExecution(
          execution: execution,
          automationId: runtimeContext.automationId,
          requestedAt: runtimeContext.requestedAt,
          failureMessage:
              'The automation completed successfully, but its execution '
              'record could not be persisted.',
        );

    if (persistenceFailure != null) {
      return persistenceFailure;
    }

    return AutomationRuntimeSuccess(
      automationId: runtimeContext.automationId,
      requestedAt: runtimeContext.requestedAt,
      completedAt: result.completedAt,
      execution: execution,
    );
  }

  Future<AutomationRuntimeResult> _handleFailure({
    required AutomationRuntimeContext runtimeContext,
    required AutomationExecutionFailure result,
  }) async {
    final String errorMessage = _normalizeErrorMessage(result.error);

    final AutomationExecution execution = AutomationExecution(
      executionId: result.executionId,
      automationId: runtimeContext.automationId,
      automationVersion: runtimeContext.automation.version,
      status: AutomationExecutionStatus.failed,
      startedAt: result.startedAt,
      completedAt: result.completedAt,
      input: runtimeContext.input,
      errorMessage: errorMessage,
      metadata: <String, Object?>{
        ...runtimeContext.metadata,
        ...result.metadata,
      },
    );

    final AutomationRuntimeFailure? persistenceFailure =
        await _tryPersistExecution(
          execution: execution,
          automationId: runtimeContext.automationId,
          requestedAt: runtimeContext.requestedAt,
          failureMessage:
              'The automation failed and its execution record could not '
              'be persisted.',
        );

    if (persistenceFailure != null) {
      return persistenceFailure;
    }

    return AutomationRuntimeFailure(
      automationId: runtimeContext.automationId,
      requestedAt: runtimeContext.requestedAt,
      completedAt: result.completedAt,
      message: errorMessage,
      cause: result.error,
      stackTrace: result.stackTrace,
    );
  }

  Future<AutomationRuntimeResult> _handleSkipped({
    required AutomationRuntimeContext runtimeContext,
    required AutomationExecutionSkipped result,
  }) async {
    final AutomationExecution execution = AutomationExecution(
      executionId: result.executionId,
      automationId: runtimeContext.automationId,
      automationVersion: runtimeContext.automation.version,
      status: AutomationExecutionStatus.cancelled,
      startedAt: result.startedAt,
      completedAt: result.completedAt,
      input: runtimeContext.input,
      metadata: <String, Object?>{
        ...runtimeContext.metadata,
        'skipReason': result.reason,
      },
    );

    final AutomationRuntimeFailure? persistenceFailure =
        await _tryPersistExecution(
          execution: execution,
          automationId: runtimeContext.automationId,
          requestedAt: runtimeContext.requestedAt,
          failureMessage:
              'The automation was skipped, but its execution record could '
              'not be persisted.',
        );

    if (persistenceFailure != null) {
      return persistenceFailure;
    }

    return AutomationRuntimeFailure(
      automationId: runtimeContext.automationId,
      requestedAt: runtimeContext.requestedAt,
      completedAt: result.completedAt,
      message: 'Automation execution skipped: ${result.reason}',
    );
  }

  Future<AutomationRuntimeFailure?> _tryPersistExecution({
    required AutomationExecution execution,
    required AutomationId automationId,
    required DateTime requestedAt,
    required String failureMessage,
  }) async {
    try {
      await _executionRepository.save(execution);
      return null;
    } catch (error, stackTrace) {
      return AutomationRuntimeFailure(
        automationId: automationId,
        requestedAt: requestedAt,
        completedAt: _safeCompletedAt(requestedAt),
        message: failureMessage,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _createExecutionId({
    required AutomationId automationId,
    required DateTime requestedAt,
  }) {
    _executionSequence++;

    final String executionId = _executionIdFactory(
      automationId,
      requestedAt,
      _executionSequence,
    ).trim();

    if (executionId.isEmpty) {
      throw StateError(
        'The automation execution identifier factory returned an empty '
        'identifier.',
      );
    }

    return executionId;
  }

  DateTime _safeCompletedAt(DateTime requestedAt) {
    final DateTime now = _utcNow();

    if (now.isBefore(requestedAt)) {
      return requestedAt;
    }

    return now;
  }

  DateTime _utcNow() => _clock().toUtc();

  static String _defaultExecutionIdFactory(
    AutomationId automationId,
    DateTime requestedAt,
    int sequence,
  ) {
    return '${automationId.value}-'
        '${requestedAt.microsecondsSinceEpoch}-'
        '$sequence';
  }

  static String _normalizeErrorMessage(Object error) {
    final String message = error.toString().trim();

    if (message.isEmpty) {
      return 'Unknown automation execution failure.';
    }

    return message;
  }
}
