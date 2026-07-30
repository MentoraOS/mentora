import 'financial_pipeline_event.dart';
import 'financial_pipeline_event_listener.dart';

final class FinancialPipelineEventDispatcher {
  FinancialPipelineEventDispatcher({
    Iterable<FinancialPipelineEventListener> listeners = const [],
  }) : _listeners = List.of(listeners);

  final List<FinancialPipelineEventListener> _listeners;

  void addListener(FinancialPipelineEventListener listener) {
    _listeners.add(listener);
  }

  void removeListener(FinancialPipelineEventListener listener) {
    _listeners.remove(listener);
  }

  void dispatch(FinancialPipelineEvent event) {
    for (final listener in List.of(_listeners)) {
      try {
        listener(event);
      } catch (_) {
        // An observability listener must never interrupt
        // the financial pipeline execution.
      }
    }
  }
}
