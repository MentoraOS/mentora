import 'consultation_readiness_checker.dart';

/// The checker registry — exactly three responsibilities: register,
/// unregister, list.
///
/// Duplicates are refused, the registration order is preserved, and the
/// exposed view is immutable. No computation, no sorting, no decision,
/// no execution — running the checkers is the engine's job alone.
final class ConsultationReadinessRegistry {
  ConsultationReadinessRegistry();

  final List<ConsultationReadinessChecker> _checkers = [];

  void register(ConsultationReadinessChecker checker) {
    if (_checkers.contains(checker)) {
      throw ArgumentError.value(
        checker,
        'checker',
        'is already registered; unregister it first',
      );
    }
    _checkers.add(checker);
  }

  void unregister(ConsultationReadinessChecker checker) {
    _checkers.remove(checker);
  }

  /// The registered checkers, in registration order, sealed against
  /// mutation.
  List<ConsultationReadinessChecker> checkers() =>
      List.unmodifiable(_checkers);
}
