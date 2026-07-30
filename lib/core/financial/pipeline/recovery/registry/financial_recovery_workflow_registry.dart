import '../../financial_pipeline_context.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';

import '../workflows/'
    'financial_recovery_workflow.dart';

/// Registry of application-level financial recovery workflows.
///
/// The registry:
/// - stores workflows by their stable workflow key;
/// - prevents duplicate workflow keys;
/// - prevents duplicate pipeline ownership;
/// - resolves a typed workflow from a recovery request;
/// - contains no recovery or orchestration business logic.
///
/// Workflows remain responsible for validating whether they support a
/// particular typed request.
final class FinancialRecoveryWorkflowRegistry {
  final Map<String, Object> _workflowsByKey = <String, Object>{};

  final Map<String, String> _workflowKeysByPipelineId = <String, String>{};

  /// Registers one typed financial recovery workflow.
  ///
  /// A workflow key and pipeline identifier must both be non-empty.
  ///
  /// Two workflows cannot:
  /// - share the same workflow key;
  /// - claim ownership of the same pipeline identifier.
  void register<TContext extends FinancialPipelineContext>(
    FinancialRecoveryWorkflow<TContext> workflow,
  ) {
    final workflowKey = _normalizeRequired(
      workflow.workflowKey,
      'workflow.workflowKey',
    );

    final pipelineId = _normalizeRequired(
      workflow.pipelineId,
      'workflow.pipelineId',
    );

    if (_workflowsByKey.containsKey(workflowKey)) {
      throw StateError(
        'A financial recovery workflow with key '
        '"$workflowKey" is already registered.',
      );
    }

    final existingWorkflowKey = _workflowKeysByPipelineId[pipelineId];

    if (existingWorkflowKey != null) {
      throw StateError(
        'Financial recovery pipeline "$pipelineId" '
        'is already handled by workflow '
        '"$existingWorkflowKey".',
      );
    }

    _workflowsByKey[workflowKey] = workflow;

    _workflowKeysByPipelineId[pipelineId] = workflowKey;
  }

  /// Returns the workflow registered under [workflowKey].
  ///
  /// Returns null when:
  /// - the key is empty;
  /// - no workflow exists for the key;
  /// - the workflow context type does not match [TContext].
  FinancialRecoveryWorkflow<TContext>?
  findByKey<TContext extends FinancialPipelineContext>(String workflowKey) {
    final normalizedKey = workflowKey.trim();

    if (normalizedKey.isEmpty) {
      return null;
    }

    final workflow = _workflowsByKey[normalizedKey];

    if (workflow is FinancialRecoveryWorkflow<TContext>) {
      return workflow;
    }

    return null;
  }

  /// Returns the workflow responsible for [pipelineId].
  ///
  /// Returns null when:
  /// - the pipeline identifier is empty;
  /// - no workflow owns the pipeline;
  /// - the workflow context type does not match [TContext].
  FinancialRecoveryWorkflow<TContext>? findByPipelineId<
    TContext extends FinancialPipelineContext
  >(String pipelineId) {
    final normalizedPipelineId = pipelineId.trim();

    if (normalizedPipelineId.isEmpty) {
      return null;
    }

    final workflowKey = _workflowKeysByPipelineId[normalizedPipelineId];

    if (workflowKey == null) {
      return null;
    }

    return findByKey<TContext>(workflowKey);
  }

  /// Resolves the typed workflow that supports [request].
  ///
  /// The pipeline identifier is used for the initial lookup. The workflow's
  /// own [FinancialRecoveryWorkflow.supports] method remains the final
  /// authority.
  FinancialRecoveryWorkflow<TContext>? resolve<
    TContext extends FinancialPipelineContext
  >(FinancialRecoveryStrategyRequest<TContext> request) {
    final workflow = findByPipelineId<TContext>(request.pipelineId);

    if (workflow == null) {
      return null;
    }

    if (!workflow.supports(request)) {
      return null;
    }

    return workflow;
  }

  /// Resolves a workflow or throws when none can execute [request].
  FinancialRecoveryWorkflow<TContext> resolveRequired<
    TContext extends FinancialPipelineContext
  >(FinancialRecoveryStrategyRequest<TContext> request) {
    final workflow = resolve(request);

    if (workflow != null) {
      return workflow;
    }

    throw StateError(
      'No financial recovery workflow is registered '
      'for pipeline "${request.pipelineId}" '
      'and context type "$TContext".',
    );
  }

  /// Whether a workflow with [workflowKey] exists.
  bool containsWorkflowKey(String workflowKey) {
    final normalizedKey = workflowKey.trim();

    if (normalizedKey.isEmpty) {
      return false;
    }

    return _workflowsByKey.containsKey(normalizedKey);
  }

  /// Whether a workflow owns [pipelineId].
  bool containsPipelineId(String pipelineId) {
    final normalizedPipelineId = pipelineId.trim();

    if (normalizedPipelineId.isEmpty) {
      return false;
    }

    return _workflowKeysByPipelineId.containsKey(normalizedPipelineId);
  }

  /// Number of registered workflows.
  int get length => _workflowsByKey.length;

  bool get isEmpty => _workflowsByKey.isEmpty;

  bool get isNotEmpty => _workflowsByKey.isNotEmpty;

  /// Immutable snapshot of registered workflow keys.
  List<String> get workflowKeys {
    final keys = _workflowsByKey.keys.toList(growable: false);

    keys.sort();

    return List.unmodifiable(keys);
  }

  /// Immutable snapshot of handled pipeline identifiers.
  List<String> get pipelineIds {
    final ids = _workflowKeysByPipelineId.keys.toList(growable: false);

    ids.sort();

    return List.unmodifiable(ids);
  }

  String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName cannot be empty.',
      );
    }

    return normalized;
  }
}
