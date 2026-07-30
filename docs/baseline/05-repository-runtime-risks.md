# Repository and Runtime Risks

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

## 1. Placeholder / Runtime Risk Summary

| Pattern | Files |
| --- | --- |
| UnsupportedError | 2 |
| TODO | 2 |
| return null | 36 |
| Demo data/reference | 6 |
| Mock class/reference | 2 |


## 2. Detailed Inventory

| Pattern | File |
| --- | --- |
| UnsupportedError | lib/core/financial/orchestrator/adapters/factories/settlement_component_posting_request_factory.dart |
| UnsupportedError | lib/firebase_options.dart |
| TODO | lib/screens/enterprise/employee/widgets/learning_session/lesson_resources.dart |
| TODO | lib/screens/enterprise/employee/widgets/quick_actions_card.dart |
| return null | lib/core/automation/domain/automation_execution.dart |
| return null | lib/core/automation/runtime/default_automation_runtime.dart |
| return null | lib/core/engines/financial/ledger/repository/firestore_ledger_repository.dart |
| return null | lib/core/engines/financial/ledger/repository/in_memory_ledger_repository.dart |
| return null | lib/core/engines/financial/withdrawals/repository/firestore_withdrawal_repository.dart |
| return null | lib/core/enterprise/repository/employee_repository.dart |
| return null | lib/core/enterprise/repository/enterprise_membership_repository.dart |
| return null | lib/core/enterprise/repository/enterprise_permission_repository.dart |
| return null | lib/core/enterprise/repository/enterprise_role_repository.dart |
| return null | lib/core/enterprise/repository/enterprise_workspace_repository.dart |
| return null | lib/core/enterprise/repository/organization_hierarchy_repository.dart |
| return null | lib/core/enterprise/repository/organization_repository.dart |
| return null | lib/core/escrow/repositories/memory_escrow_repository.dart |
| return null | lib/core/financial/domain/infrastructure/settlement/firestore_settlement_repository.dart |
| return null | lib/core/financial/domain/shared/money/financial_currency.dart |
| return null | lib/core/financial/fees/models/fee_breakdown.dart |
| return null | lib/core/financial/ledger/journal/queries/ledger_journal_query.dart |
| return null | lib/core/financial/ledger/journal/queries/ledger_journal_query_result.dart |
| return null | lib/core/financial/ledger/journal/reporting/ledger_trial_balance.dart |
| return null | lib/core/financial/ledger/journal/repository/memory_ledger_journal_repository.dart |
| return null | lib/core/financial/ledger/repositories/memory_ledger_repository.dart |
| return null | lib/core/financial/pipeline/metrics/financial_pipeline_metrics_registry.dart |
| return null | lib/core/financial/pipeline/recovery/engine/default_financial_recovery_engine.dart |
| return null | lib/core/financial/pipeline/recovery/financial_pipeline_recovery_registry.dart |
| return null | lib/core/financial/pipeline/recovery/registry/financial_recovery_workflow_registry.dart |
| return null | lib/core/financial/pipeline/recovery/strategies/financial_recovery_strategy_registry.dart |
| return null | lib/core/financial/pipeline/recovery/strategies/recover_partial_settlement_strategy.dart |
| return null | lib/core/financial/splits/models/settlement_split.dart |
| return null | lib/core/identity/engine/authentication_engine.dart |
| return null | lib/core/learning/repository/learning_path_repository.dart |
| return null | lib/core/learning/repository/learning_progress_repository.dart |
| return null | lib/core/learning/repository/lesson_repository.dart |
| return null | lib/core/notification/factories/notification_factory.dart |
| return null | lib/core/services/cache_service.dart |
| return null | lib/core/session/session_repository.dart |
| return null | lib/core/timer/repositories/memory_timer_repository.dart |
| Demo data/reference | lib/core/enterprise/repository/department_repository.dart |
| Demo data/reference | lib/core/enterprise/repository/employee_repository.dart |
| Demo data/reference | lib/core/enterprise/repository/enterprise_membership_repository.dart |
| Demo data/reference | lib/core/enterprise/repository/organization_hierarchy_repository.dart |
| Demo data/reference | lib/core/enterprise/repository/organization_repository.dart |
| Demo data/reference | lib/core/enterprise/repository/team_repository.dart |
| Mock class/reference | lib/core/engines/payment/providers/mock_payment_provider.dart |
| Mock class/reference | lib/core/engines/payment/registry/payment_provider_registry.dart |


## 3. Repository Findings

- Booking currently has a memory repository implementation rather than a production persistence adapter.
- Consultation, Meeting, Payment, Escrow, Automation, Ledger, Timer and Notification also include in-memory repositories.
- The current payment provider registration identified by the previous repository audit uses a mock implementation.
- Enterprise contains hard-coded `mentora_demo` data and nullable placeholder paths.
- Firestore settlement persistence contains nullable/incomplete paths.
- Two `UnsupportedError` occurrences are present in the source snapshot and must be reviewed before production readiness.

## 4. Production Composition Risk

`main.dart`, DI/bootstrap modules, MentoraOS/Phoenix-related startup concepts, direct Firebase singleton access and repository construction are distributed across multiple areas. This creates a risk of multiple implicit composition roots.

## 5. Future Action

Lot D should establish one composition authority:

```text
main.dart
→ AppBootstrap
→ AppContainer
→ MentoraApp
```

No runtime behavior is changed in Lot A.
