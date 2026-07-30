import '../financial_pipeline_context.dart';
import 'financial_pipeline_recovery.dart';

final class FinancialPipelineRecoveryRegistry {
  final Map<String, FinancialPipelineRecovery<FinancialPipelineContext>>
  _recoveries = {};

  void register<TContext extends FinancialPipelineContext>(
    FinancialPipelineRecovery<TContext> recovery,
  ) {
    final pipelineId = recovery.pipelineId.trim();

    if (pipelineId.isEmpty) {
      throw ArgumentError.value(
        recovery.pipelineId,
        'pipelineId',
        'Recovery pipeline identifier must not be empty.',
      );
    }

    if (_recoveries.containsKey(pipelineId)) {
      throw StateError(
        'A recovery is already registered for pipeline '
        '"$pipelineId".',
      );
    }

    _recoveries[pipelineId] =
        recovery as FinancialPipelineRecovery<FinancialPipelineContext>;
  }

  FinancialPipelineRecovery<TContext>?
  find<TContext extends FinancialPipelineContext>(String pipelineId) {
    final recovery = _recoveries[pipelineId.trim()];

    if (recovery == null) {
      return null;
    }

    return recovery as FinancialPipelineRecovery<TContext>;
  }

  bool contains(String pipelineId) {
    return _recoveries.containsKey(pipelineId.trim());
  }

  List<String> get registeredPipelineIds {
    final ids = _recoveries.keys.toList()..sort();
    return List.unmodifiable(ids);
  }

  void unregister(String pipelineId) {
    _recoveries.remove(pipelineId.trim());
  }

  void clear() {
    _recoveries.clear();
  }
}
