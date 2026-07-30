/// Legacy architecture baseline captured during Sprint -1.2 / Lot A.
///
/// IMPORTANT:
/// These entries are not approved architecture. They are grandfathered
/// violations that existed before enforcement. New violations must fail tests.
abstract final class ArchitectureLegacyBaseline {
  static const Set<String> domainFirebaseImports = {
    'lib/core/financial/domain/infrastructure/settlement/firestore_settlement_repository.dart',
  };

  static const Set<String> domainFlutterUiImports = {};

  static const Set<String> domainAgoraImports = {};

  static const Set<String> presentationFirestoreImports = {
    'lib/screens/booking_detail_screen.dart',
    'lib/screens/client_dashboard_screen.dart',
    'lib/screens/edit_profile_screen.dart',
    'lib/screens/expert_agenda_screen.dart',
    'lib/screens/expert_dashboard_screen.dart',
    'lib/screens/expert_detail_screen.dart',
    'lib/screens/expert_escrow_list_screen.dart',
    'lib/screens/favorite_experts_screen.dart',
    'lib/screens/my_bookings_screen.dart',
    'lib/screens/my_payments_screen.dart',
    'lib/screens/pre_consultation_screen.dart',
    'lib/screens/profile_screen.dart',
    'lib/screens/session_completed_screen.dart',
    'lib/screens/sessions_screen.dart',
    'lib/screens/video_call_screen.dart',
    'lib/screens/withdrawal_admin_screen.dart',
    'lib/screens/withdrawal_history_screen.dart',
  };

  static const Set<String> presentationFirebaseAuthImports = {
    'lib/screens/client_dashboard_screen.dart',
    'lib/screens/edit_profile_screen.dart',
    'lib/screens/expert_dashboard_screen.dart',
    'lib/screens/favorite_experts_screen.dart',
    'lib/screens/my_bookings_screen.dart',
    'lib/screens/my_payments_screen.dart',
    'lib/screens/pre_consultation_screen.dart',
    'lib/screens/profile_screen.dart',
    'lib/screens/sessions_screen.dart',
    'lib/screens/withdrawal_admin_screen.dart',
  };

  static const Set<String> consultationAgoraImports = {};

  static const Set<String> bookingFinancialInternalImports = {};

  static const Set<String> consultationFinancialInternalImports = {};

  static const Set<String> productPspSdkImports = {};

  static const Set<String> productScreensImports = {};

  /// Existing cross-critical-domain internal imports.
  ///
  /// Format: `<source-file>|<import-uri>`.
  static const Set<String> crossCriticalDomainImports = {
    'lib/core/scheduling/engine/scheduling_engine.dart|../../booking/engine/booking_engine.dart',
    'lib/core/scheduling/engine/scheduling_engine.dart|../../booking/models/booking.dart',
    'lib/core/scheduling/engine/scheduling_engine.dart|../../booking/models/booking_result.dart',
    'lib/core/scheduling/engine/scheduling_engine.dart|../../consultation/engine/consultation_engine.dart',
    'lib/core/scheduling/engine/scheduling_engine.dart|../../consultation/models/consultation.dart',
    'lib/core/scheduling/engine/scheduling_engine.dart|../../consultation/models/consultation_result.dart',
  };

  /// Existing module-level strongly connected components.
  ///
  /// Each signature is alphabetically sorted and joined with `|`.
  static const Set<String> moduleCycleSignatures = {
    'core/escrow|core/financial',
    'core/bootstrap|core/di|core/engines|core/enterprise|core/events|core/identity|core/permissions|core/repositories|core/routing|core/session|core/workflow|core/workspace|features/enterprise|main.dart|presentation|screens',
  };
}
