import 'dart:async';

import 'financial_recovery_pipeline_event.dart';

/// Listener invoked whenever the Financial Recovery Pipeline emits an event.
///
/// A listener may be synchronous or asynchronous.
typedef FinancialRecoveryPipelineEventListener =
    FutureOr<void> Function(FinancialRecoveryPipelineEvent event);

/// Dispatches Financial Recovery Pipeline lifecycle events.
///
/// Responsibilities:
/// - preserve listener registration order;
/// - await asynchronous listeners before continuing;
/// - propagate listener failures unchanged;
/// - remain independent from metrics, reporting and audit implementations.
///
/// The dispatcher contains no recovery business logic.
final class FinancialRecoveryPipelineEventDispatcher {
  FinancialRecoveryPipelineEventDispatcher({
    Iterable<FinancialRecoveryPipelineEventListener> listeners = const [],
  }) : _listeners = List.unmodifiable(listeners);

  final List<FinancialRecoveryPipelineEventListener> _listeners;

  /// Number of registered listeners.
  int get listenerCount => _listeners.length;

  bool get hasListeners => _listeners.isNotEmpty;

  bool get isEmpty => _listeners.isEmpty;

  /// Dispatches [event] sequentially to every registered listener.
  ///
  /// Sequential dispatch is intentional:
  /// - listener ordering remains deterministic;
  /// - audit and metrics listeners observe the same lifecycle order;
  /// - a listener failure prevents later listeners from receiving a
  ///   potentially misleading event.
  Future<void> dispatch(FinancialRecoveryPipelineEvent event) async {
    for (final listener in _listeners) {
      await listener(event);
    }
  }
}
