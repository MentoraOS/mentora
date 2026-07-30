# Dependency Violations

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

Each entry records a currently observed architectural deviation or high-risk coupling. No correction is made in this lot.

| ID | Source/File | Target | Finding | Rule | Severity | Baseline | Future action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DV-001 | lib/core/financial/domain/infrastructure/settlement/firestore_settlement_repository.dart | — | Firebase/Firestore dependency in Domain | DR-001 | CRITICAL | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-002 | lib/screens/video_call_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-003 | lib/screens/video_call_screen.dart | — | Direct Agora dependency in Presentation | OV-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-004 | lib/screens/session_completed_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-005 | lib/screens/favorite_experts_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-006 | lib/screens/favorite_experts_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-007 | lib/screens/expert_detail_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-008 | lib/screens/my_bookings_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-009 | lib/screens/my_bookings_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-010 | lib/screens/sessions_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-011 | lib/screens/sessions_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-012 | lib/screens/edit_profile_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-013 | lib/screens/edit_profile_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-014 | lib/screens/expert_escrow_list_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-015 | lib/screens/profile_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-016 | lib/screens/profile_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-017 | lib/screens/withdrawal_history_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-018 | lib/screens/pre_consultation_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-019 | lib/screens/pre_consultation_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-020 | lib/screens/client_dashboard_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-021 | lib/screens/client_dashboard_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-022 | lib/screens/expert_agenda_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-023 | lib/screens/withdrawal_admin_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-024 | lib/screens/withdrawal_admin_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-025 | lib/screens/my_payments_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-026 | lib/screens/my_payments_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-027 | lib/screens/expert_dashboard_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-028 | lib/screens/expert_dashboard_screen.dart | — | Direct FirebaseAuth dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-029 | lib/screens/booking_detail_screen.dart | — | Direct Firestore dependency in Presentation | DR-003 | HIGH | LEGACY | Migrate behind an application/domain contract in a later stabilization lot. |
| DV-030 | lib/core/scheduling | — | Scheduling directly depends on Booking/Consultation modules → core/booking + core/consultation | OV-001 / DR-005 | HIGH | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |
| DV-031 | lib/core/booking | — | Booking depends directly on generic Workflow core → core/workflow | OV-011 | MEDIUM | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |
| DV-032 | lib/core/consultation | — | Consultation depends directly on generic Workflow core → core/workflow | OV-011 | MEDIUM | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |
| DV-033 | lib/core/meeting | — | Meeting depends directly on generic Workflow core → core/workflow | OV-011 | MEDIUM | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |
| DV-034 | lib/core/financial | — | Financial depends on standalone Escrow → core/escrow | OV-008 | HIGH | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |
| DV-035 | lib/core/escrow | — | Escrow depends back on Financial, forming a cycle → core/financial | OV-008 / DR-005 | CRITICAL | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |
| DV-036 | lib/core/phoenix | — | Phoenix acts as a cross-platform orchestration hub → events/financial/notification/payment/pricing | OV-013 / OV-028 | HIGH | LEGACY | Resolve progressively according to Overlap Register; no new dependency of this type. |


## Severity Summary

| Severity | Count |
| --- | --- |
| CRITICAL | 2 |
| HIGH | 31 |
| MEDIUM | 3 |


## Policy

These entries form the grandfathered baseline for future architecture tests. A grandfathered entry is not approval to reproduce the pattern in new code.
