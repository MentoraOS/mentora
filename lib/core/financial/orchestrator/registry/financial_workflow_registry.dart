import '../workflows/financial_workflow.dart';

class FinancialWorkflowRegistry {
  final Map<String, FinancialWorkflow<dynamic, dynamic>> _workflows = {};

  void register<TContext, TResult>(
    FinancialWorkflow<TContext, TResult> workflow,
  ) {
    final normalizedKey = _normalizeKey(workflow.key);

    if (_workflows.containsKey(normalizedKey)) {
      throw StateError(
        'Financial workflow "$normalizedKey" is already registered',
      );
    }

    _workflows[normalizedKey] = workflow;
  }

  FinancialWorkflow<TContext, TResult> resolve<TContext, TResult>(String key) {
    final normalizedKey = _normalizeKey(key);
    final workflow = _workflows[normalizedKey];

    if (workflow == null) {
      throw StateError('No financial workflow registered for "$normalizedKey"');
    }

    if (workflow is! FinancialWorkflow<TContext, TResult>) {
      throw StateError(
        'Financial workflow "$normalizedKey" does not match '
        'the requested context/result types',
      );
    }

    return workflow;
  }

  bool supports(String key) {
    return _workflows.containsKey(_normalizeKey(key));
  }

  void unregister(String key) {
    final normalizedKey = _normalizeKey(key);

    if (!_workflows.containsKey(normalizedKey)) {
      throw StateError(
        'Cannot unregister unknown financial workflow "$normalizedKey"',
      );
    }

    _workflows.remove(normalizedKey);
  }

  void clear() {
    _workflows.clear();
  }

  int get length => _workflows.length;

  List<String> get registeredKeys => List<String>.unmodifiable(_workflows.keys);

  String _normalizeKey(String key) {
    final normalized = key.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        key,
        'key',
        'Financial workflow key cannot be empty',
      );
    }

    return normalized;
  }
}
