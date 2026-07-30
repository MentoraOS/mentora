/// Existing cross-domain dependencies that violate the approved direction.
///
/// Captured from the Lot A repository snapshot.
/// These are debt, not approved architecture.
///
/// Format:
/// `<source-domain>|<target-domain>|<source-file>|<import-uri>`
abstract final class CrossDomainDependencyLegacyBaseline {
  static const Set<String> violations = {
    'scheduling|booking|lib/core/scheduling/engine/scheduling_engine.dart|../../booking/engine/booking_engine.dart',
    'scheduling|booking|lib/core/scheduling/engine/scheduling_engine.dart|../../booking/models/booking.dart',
    'scheduling|booking|lib/core/scheduling/engine/scheduling_engine.dart|../../booking/models/booking_result.dart',
    'scheduling|consultation|lib/core/scheduling/engine/scheduling_engine.dart|../../consultation/engine/consultation_engine.dart',
    'scheduling|consultation|lib/core/scheduling/engine/scheduling_engine.dart|../../consultation/models/consultation.dart',
    'scheduling|consultation|lib/core/scheduling/engine/scheduling_engine.dart|../../consultation/models/consultation_result.dart',
  };
}
