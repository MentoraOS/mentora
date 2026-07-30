/// Legacy direct infrastructure singleton access captured during
/// Sprint -1.2 / Lot E.
///
/// IMPORTANT:
/// These entries describe existing technical debt.
/// They are not approved architecture.
///
/// New direct singleton access must fail governance.
abstract final class InfrastructureSingletonLegacyBaseline {
  static const Set<String> violations = {
    // FirebaseAuth.instance
    'firebaseAuth|core/session/session_repository.dart|FirebaseAuth.instance',
    'firebaseAuth|main.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/edit_profile_screen.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/favorite_experts_screen.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/my_bookings_screen.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/my_payments_screen.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/pre_consultation_screen.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/profile_screen.dart|FirebaseAuth.instance',
    'firebaseAuth|screens/sessions_screen.dart|FirebaseAuth.instance',

    // FirebaseFirestore.instance
    'firebaseFirestore|core/bootstrap/workspace_bootstrap.dart|FirebaseFirestore.instance',
    'firebaseFirestore|core/di/modules/enterprise_module.dart|FirebaseFirestore.instance',
    'firebaseFirestore|core/di/service_locater.dart|FirebaseFirestore.instance',
    'firebaseFirestore|core/engines/financial/ledger/financial_ledger_factory.dart|FirebaseFirestore.instance',
    'firebaseFirestore|core/engines/financial/withdrawals/withdrawal_engine.dart|FirebaseFirestore.instance',
    'firebaseFirestore|core/session/session_bootstrap.dart|FirebaseFirestore.instance',
    'firebaseFirestore|core/session/session_repository.dart|FirebaseFirestore.instance',
    'firebaseFirestore|main.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/booking_detail_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/client_dashboard_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/edit_profile_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/expert_agenda_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/expert_dashboard_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/expert_detail_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/expert_escrow_list_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/favorite_experts_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/my_bookings_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/my_payments_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/pre_consultation_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/profile_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/session_completed_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/sessions_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/video_call_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/withdrawal_admin_screen.dart|FirebaseFirestore.instance',
    'firebaseFirestore|screens/withdrawal_history_screen.dart|FirebaseFirestore.instance',
  };
}
