# Module Cycles

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

The module graph was built from Dart imports resolved inside `lib/`.

## 1. Strongly Connected Component Groups

| ID | Modules | Cycle group | Severity |
| --- | --- | --- | --- |
| CYCLE-01 | 16 | core/bootstrap → core/di → core/engines → core/enterprise → core/events → core/identity → core/permissions → core/repositories → core/routing → core/session → core/workflow → core/workspace → features/enterprise → main.dart → presentation → screens | HIGH |
| CYCLE-02 | 2 | core/escrow → core/financial | CRITICAL |


## 2. Direct Mutual Dependency Pairs

| Module A | Module B | Example files |
| --- | --- | --- |
| core/di | core/workspace | lib/core/di/service_locater.dart, lib/core/workspace/widgets/workspace_switcher.dart |
| core/di | features/enterprise | lib/core/di/service_locater.dart, lib/features/enterprise/presentation/controllers/enterprise_invitation_controller.dart |
| core/enterprise | core/workflow | lib/core/enterprise/engine/atlas_engine.dart, lib/core/workflow/employee_onboarding_workflow.dart |
| core/escrow | core/financial | lib/core/escrow/engine/escrow_engine.dart, lib/core/financial/ledger/posting/services/escrow_posting_service.dart |
| core/routing | features/enterprise | lib/core/routing/app_router.dart, lib/features/enterprise/presentation/screens/enterprise_members_screen.dart |
| core/routing | main.dart | lib/core/routing/app_router.dart, lib/main.dart |
| core/routing | screens | lib/core/routing/app_router.dart, lib/screens/video_call_screen.dart |
| core/workspace | presentation | lib/core/workspace/widgets/workspace_switcher.dart, lib/presentation/controllers/workspace/workspace_controller.dart |


## 3. Critical Financial Cycle

```text
core/financial
    ↕
core/escrow
```

This directly conflicts with the approved decision to absorb Escrow conceptually into Financial rather than maintain two mutually dependent financial ownership areas.

## 4. Large Mixed Cycle Group

The larger SCC contains startup, DI, routing, presentation, Enterprise/Workspace and orchestration/platform modules. It is a structural signal that dependency direction is not currently acyclic at module level.

## 5. Lot A Decision

No cycle is modified here. Lot B should first add detection with a baseline/allow-list so that **new** cycles are immediately blocked.
