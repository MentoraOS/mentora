# Infrastructure Leaks

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

## 1. SDK Import Inventory

| Technology | File | Observed layer |
| --- | --- | --- |
| Firebase Core | lib/firebase_options.dart | Mixed/Legacy |
| Firebase Core | lib/main.dart | Application Shell |
| Firebase Auth | lib/core/session/session_repository.dart | Mixed/Legacy |
| Firebase Auth | lib/main.dart | Application Shell |
| Firebase Auth | lib/screens/client_dashboard_screen.dart | Presentation |
| Firebase Auth | lib/screens/edit_profile_screen.dart | Presentation |
| Firebase Auth | lib/screens/expert_dashboard_screen.dart | Presentation |
| Firebase Auth | lib/screens/favorite_experts_screen.dart | Presentation |
| Firebase Auth | lib/screens/my_bookings_screen.dart | Presentation |
| Firebase Auth | lib/screens/my_payments_screen.dart | Presentation |
| Firebase Auth | lib/screens/pre_consultation_screen.dart | Presentation |
| Firebase Auth | lib/screens/profile_screen.dart | Presentation |
| Firebase Auth | lib/screens/sessions_screen.dart | Presentation |
| Firebase Auth | lib/screens/withdrawal_admin_screen.dart | Presentation |
| Cloud Firestore | lib/core/bootstrap/workspace_bootstrap.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/di/modules/enterprise_module.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/di/service_locater.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/engines/financial/ledger/financial_ledger_factory.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/engines/financial/ledger/repository/firestore_ledger_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/engines/financial/withdrawals/repository/firestore_withdrawal_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/engines/financial/withdrawals/withdrawal_engine.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/financial/domain/infrastructure/settlement/firestore_settlement_repository.dart | Domain |
| Cloud Firestore | lib/core/session/session_bootstrap.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/session/session_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/workspace/workspace_member_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/core/workspace/workspace_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/features/enterprise/data/gateways/firestore_enterprise_gateway.dart | Mixed/Legacy |
| Cloud Firestore | lib/features/enterprise/data/repositories/firestore_enterprise_invitation_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/features/enterprise/data/repositories/firestore_enterprise_member_repository.dart | Mixed/Legacy |
| Cloud Firestore | lib/main.dart | Application Shell |
| Cloud Firestore | lib/screens/booking_detail_screen.dart | Presentation |
| Cloud Firestore | lib/screens/client_dashboard_screen.dart | Presentation |
| Cloud Firestore | lib/screens/edit_profile_screen.dart | Presentation |
| Cloud Firestore | lib/screens/expert_agenda_screen.dart | Presentation |
| Cloud Firestore | lib/screens/expert_dashboard_screen.dart | Presentation |
| Cloud Firestore | lib/screens/expert_detail_screen.dart | Presentation |
| Cloud Firestore | lib/screens/expert_escrow_list_screen.dart | Presentation |
| Cloud Firestore | lib/screens/favorite_experts_screen.dart | Presentation |
| Cloud Firestore | lib/screens/my_bookings_screen.dart | Presentation |
| Cloud Firestore | lib/screens/my_payments_screen.dart | Presentation |
| Cloud Firestore | lib/screens/pre_consultation_screen.dart | Presentation |
| Cloud Firestore | lib/screens/profile_screen.dart | Presentation |
| Cloud Firestore | lib/screens/session_completed_screen.dart | Presentation |
| Cloud Firestore | lib/screens/sessions_screen.dart | Presentation |
| Cloud Firestore | lib/screens/video_call_screen.dart | Presentation |
| Cloud Firestore | lib/screens/withdrawal_admin_screen.dart | Presentation |
| Cloud Firestore | lib/screens/withdrawal_history_screen.dart | Presentation |
| Agora | lib/screens/video_call_screen.dart | Presentation |


## 2. Direct Singleton Access

### FirebaseFirestore.instance

| File | Occurrences |
| --- | --- |
| lib/main.dart | 2 |
| lib/screens/video_call_screen.dart | 1 |
| lib/screens/session_completed_screen.dart | 2 |
| lib/screens/favorite_experts_screen.dart | 3 |
| lib/screens/expert_detail_screen.dart | 1 |
| lib/screens/my_bookings_screen.dart | 1 |
| lib/screens/sessions_screen.dart | 1 |
| lib/screens/edit_profile_screen.dart | 2 |
| lib/screens/expert_escrow_list_screen.dart | 1 |
| lib/screens/profile_screen.dart | 1 |
| lib/screens/withdrawal_history_screen.dart | 1 |
| lib/screens/pre_consultation_screen.dart | 2 |
| lib/screens/client_dashboard_screen.dart | 1 |
| lib/screens/expert_agenda_screen.dart | 1 |
| lib/screens/withdrawal_admin_screen.dart | 1 |
| lib/screens/my_payments_screen.dart | 1 |
| lib/screens/expert_dashboard_screen.dart | 2 |
| lib/screens/booking_detail_screen.dart | 1 |
| lib/core/bootstrap/workspace_bootstrap.dart | 1 |
| lib/core/session/session_repository.dart | 1 |
| lib/core/session/session_bootstrap.dart | 1 |
| lib/core/di/service_locater.dart | 3 |
| lib/core/di/modules/enterprise_module.dart | 3 |
| lib/core/engines/financial/withdrawals/withdrawal_engine.dart | 1 |
| lib/core/engines/financial/ledger/financial_ledger_factory.dart | 1 |


### FirebaseAuth.instance

| File | Occurrences |
| --- | --- |
| lib/main.dart | 4 |
| lib/screens/favorite_experts_screen.dart | 2 |
| lib/screens/my_bookings_screen.dart | 1 |
| lib/screens/sessions_screen.dart | 1 |
| lib/screens/edit_profile_screen.dart | 2 |
| lib/screens/profile_screen.dart | 2 |
| lib/screens/pre_consultation_screen.dart | 1 |
| lib/screens/my_payments_screen.dart | 1 |
| lib/core/session/session_repository.dart | 1 |


## 3. Presentation Summary

- Cloud Firestore imports in Presentation: **17 files**
- FirebaseAuth imports in Presentation: **10 files**
- Agora imports in Presentation: **1 file**

## 4. Domain Summary

The strict domain scan found **1 infrastructure-boundary violation(s)**. The concrete violation is listed in the dependency register.

## 5. PSP Observation

PSP names such as PayDunya, CinetPay, Stripe, Flutterwave, Paystack, Orange Money and Wave appear in model/registry/UI concepts. This audit did **not** find concrete package imports for those PSP SDKs; therefore these occurrences are names/configuration concepts, not proof of SDK leakage.

