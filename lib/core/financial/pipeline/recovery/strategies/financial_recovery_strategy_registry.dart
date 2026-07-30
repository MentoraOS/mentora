import '../../financial_pipeline_context.dart';

import 'financial_recovery_strategy.dart';
import 'financial_recovery_strategy_request.dart';

// Registry of specialized financial recovery strategies.
//
// Strategies are registered by a stable unique key and resolved by asking
// each strategy whether it supports a given recovery request.
//
// The registry itself performs no recovery and has no side effects on the
// financial state.
final class FinancialRecoveryStrategyRegistry {
  final Map<String, FinancialRecoveryStrategy<FinancialPipelineContext>>
  _strategies = {};

  // Registers one strategy.
  //
  // Strategy keys are normalized by trimming surrounding whitespace.
  // Duplicate keys are rejected.
  void register<TContext extends FinancialPipelineContext>(
    FinancialRecoveryStrategy<TContext> strategy,
  ) {
    final normalizedKey = _normalizeRequired(strategy.key, 'strategy.key');

    if (_strategies.containsKey(normalizedKey)) {
      throw StateError(
        'A financial recovery strategy is already '
        'registered with key "$normalizedKey".',
      );
    }

    _strategies[normalizedKey] =
        strategy as FinancialRecoveryStrategy<FinancialPipelineContext>;
  }

  // Finds a strategy by its stable key.
  //
  // Returns null when no strategy is registered under [key].
  FinancialRecoveryStrategy<TContext>?
  findByKey<TContext extends FinancialPipelineContext>(String key) {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      return null;
    }

    final strategy = _strategies[normalizedKey];

    if (strategy == null) {
      return null;
    }

    return strategy as FinancialRecoveryStrategy<TContext>;
  }

  // Resolves the first strategy that supports [request].
  //
  // Registration order is preserved by Dart's insertion-ordered map.
  //
  // Returns null when no strategy supports the request.
  FinancialRecoveryStrategy<TContext>? resolve<
    TContext extends FinancialPipelineContext
  >(FinancialRecoveryStrategyRequest<TContext> request) {
    for (final strategy in _strategies.values) {
      final typedStrategy = strategy as FinancialRecoveryStrategy<TContext>;

      if (typedStrategy.supports(request)) {
        return typedStrategy;
      }
    }

    return null;
  }

  // Resolves a supported strategy or throws.
  FinancialRecoveryStrategy<TContext> resolveRequired<
    TContext extends FinancialPipelineContext
  >(FinancialRecoveryStrategyRequest<TContext> request) {
    final strategy = resolve(request);

    if (strategy == null) {
      throw StateError(
        'No financial recovery strategy supports '
        'pipeline "${request.pipelineId}" for recovery '
        '"${request.recoveryId}".',
      );
    }

    return strategy;
  }

  bool contains(String key) {
    return _strategies.containsKey(key.trim());
  }

  // Registered keys in deterministic alphabetical order.
  List<String> get registeredKeys {
    final keys = _strategies.keys.toList()..sort();

    return List.unmodifiable(keys);
  }

  int get length => _strategies.length;

  bool get isEmpty => _strategies.isEmpty;

  bool get isNotEmpty => _strategies.isNotEmpty;

  // Removes and returns the strategy registered under [key].
  FinancialRecoveryStrategy<FinancialPipelineContext>? unregister(String key) {
    return _strategies.remove(key.trim());
  }

  void clear() {
    _strategies.clear();
  }

  String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }

    return normalized;
  }
}
