import 'consultation_readiness_result.dart';

/// One preparation checker — PURE CONTRACT, one responsibility.
///
/// A checker verifies exactly one preparation fact and answers with its
/// verdict. The contract knows nothing about how a check is performed —
/// no platform, no hardware, no vendor, no storage: the concrete
/// checkers of the future waves (connection, devices, permissions, AI
/// availability, diagnostics, accessibility, battery, …) simply
/// implement it and register themselves.
abstract interface class ConsultationReadinessChecker {
  Future<ConsultationReadinessResult> check();
}
