/// Legacy infrastructure leaks captured during Sprint -1.2 / Lot E.
///
/// IMPORTANT:
/// These entries represent existing architectural debt.
/// They are NOT approved infrastructure dependencies.
///
/// New fingerprints must fail architecture governance.
///
/// Current snapshot:
/// - 46 physical occurrences
/// - 45 unique infrastructure leak fingerprints
abstract final class InfrastructureLeakLegacyBaseline {
  static const Set<String> violations = {
    // Agora
    'agora|screens/video_call_screen.dart|package:agora_rtc_engine/agora_rtc_engine.dart',

    // Firebase Auth
    'firebaseAuth|core/session/session_repository.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|main.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/client_dashboard_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/edit_profile_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/expert_dashboard_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/favorite_experts_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/my_bookings_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/my_payments_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/pre_consultation_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/profile_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/sessions_screen.dart|package:firebase_auth/firebase_auth.dart',
    'firebaseAuth|screens/withdrawal_admin_screen.dart|package:firebase_auth/firebase_auth.dart',

    // Firebase Core
    'firebaseCore|firebase_options.dart|package:firebase_core/firebase_core.dart',
    'firebaseCore|main.dart|package:firebase_core/firebase_core.dart',

    // Firestore
    'firestore|core/bootstrap/workspace_bootstrap.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/di/modules/enterprise_module.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/di/service_locater.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/engines/financial/ledger/financial_ledger_factory.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/engines/financial/ledger/repository/firestore_ledger_repository.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/engines/financial/withdrawals/repository/firestore_withdrawal_repository.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/engines/financial/withdrawals/withdrawal_engine.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/financial/domain/infrastructure/settlement/firestore_settlement_repository.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/session/session_bootstrap.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/session/session_repository.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/workspace/workspace_member_repository.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|core/workspace/workspace_repository.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|main.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/booking_detail_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/client_dashboard_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/edit_profile_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/expert_agenda_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/expert_dashboard_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/expert_detail_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/expert_escrow_list_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/favorite_experts_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/my_bookings_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/my_payments_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/pre_consultation_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/profile_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/session_completed_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/sessions_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/video_call_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/withdrawal_admin_screen.dart|package:cloud_firestore/cloud_firestore.dart',
    'firestore|screens/withdrawal_history_screen.dart|package:cloud_firestore/cloud_firestore.dart',
  };
}
