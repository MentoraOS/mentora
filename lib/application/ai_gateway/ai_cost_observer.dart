import 'ai_cost_record.dart';
import 'ai_usage_record.dart';

/// The cost & usage observation layer — INTERNAL to the orchestrator
/// (only the orchestrator knows it; no business module, no provider).
///
/// It ONLY observes: it receives cost and usage records, keeps them in
/// bounded memory and returns them UNCHANGED. Never a computation,
/// never a decision, never a limitation, never billing, never
/// persistence. The future financial dashboards, usage reports,
/// automatic optimization, per-organization budgets, quotas, budget
/// alerts, economic engine comparison, client re-invoicing and AI ROI
/// consume these records through their own waves.
final class AICostObserver {
  AICostObserver({this.capacity = 500});

  /// The maximum number of records of each kind kept alive in memory.
  final int capacity;

  final List<AICostRecord> _costs = [];
  final List<AIUsageRecord> _usages = [];

  /// Records the cost and returns it — never modified.
  AICostRecord observeCost(AICostRecord record) {
    _costs.add(record);
    while (_costs.length > capacity) {
      _costs.removeAt(0);
    }
    return record;
  }

  /// Records the usage and returns it — never modified.
  AIUsageRecord observeUsage(AIUsageRecord record) {
    _usages.add(record);
    while (_usages.length > capacity) {
      _usages.removeAt(0);
    }
    return record;
  }

  /// The observed records, oldest first, sealed against mutation.
  List<AICostRecord> get costs => List.unmodifiable(_costs);
  List<AIUsageRecord> get usages => List.unmodifiable(_usages);
}
