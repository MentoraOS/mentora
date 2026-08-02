import 'ai_execution_trace.dart';

/// The AI observability layer — INTERNAL to the orchestrator (only the
/// orchestrator knows it; no business pipeline, no provider ever does).
///
/// It ONLY observes: it receives a trace, records it in bounded memory
/// and returns it UNCHANGED. Never a decision, never a fallback, never
/// business logic, never persistence — traces live in memory only and
/// the bound keeps millions of daily executions safe. Invisible,
/// replaceable, testable, extensible: richer sinks (dashboards, alerts,
/// monitoring, audit) plug in behind this same surface in their own
/// waves.
final class AIObservability {
  AIObservability({this.capacity = 500});

  /// The maximum number of traces kept alive in memory.
  final int capacity;

  final List<AIExecutionTrace> _traces = [];

  /// Records the trace and returns it — never modified, never blocking.
  AIExecutionTrace observe(AIExecutionTrace trace) {
    _traces.add(trace);
    while (_traces.length > capacity) {
      _traces.removeAt(0);
    }
    return trace;
  }

  /// The observed traces, oldest first, sealed against mutation.
  List<AIExecutionTrace> get traces => List.unmodifiable(_traces);
}
