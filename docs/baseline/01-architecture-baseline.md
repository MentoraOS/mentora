# Mentora Architecture Baseline

**Sprint:** -1.2 / Lot A — Architecture Baseline  
**Status:** COMPLETE FOR SOURCE SNAPSHOT  
**Mode:** READ-ONLY AUDIT  
**Source:** `mentora(3).zip` source snapshot  
**Purpose:** Descriptive baseline. No code changes were performed.

## 1. Executive Summary

The repository contains **751 Dart files** under `lib/`. The architecture remains strongly `core/`-centric: **654 files** are under `lib/core`, while the main flat screen layer contains **59 Dart files**.

The strongest structural risk is not the absence of architecture; it is the coexistence of several architectures and orchestration systems. The source snapshot also contains direct Firebase/Firestore access from presentation, direct Firebase access in startup, a Financial↔Escrow module cycle, and a large multi-module strongly-connected component involving startup, routing, screens, DI, Enterprise, Workspace and platform modules.

The current test investment is substantial at architecture/platform level (**132 Dart test files**, all under `test/architecture`), but the approved governance rules are not yet represented as dedicated import/dependency gates.

## 2. Repository Metrics

| Metric | Value | Status |
| --- | --- | --- |
| Total Dart files in lib | 751 | BASELINE |
| lib/core | 654 | LEGACY HEAVY |
| lib/screens | 59 | HIGH |
| lib/features | 23 | INFO |
| lib/domain | 3 | NEEDS MIGRATION |
| lib/presentation | 2 | NEEDS MIGRATION |
| Architecture test files | 132 | YELLOW |
| Integration test files discovered | 0 | RED |
| Module-level SCC cycle groups | 2 | RED |
| Direct Firestore .instance files | 25 | RED |
| Direct FirebaseAuth .instance files | 9 | RED |
| Domain infrastructure violations | 1 | RED |
| Presentation Firebase/Agora violations | 28 | RED |


## 3. Main Source Distribution

| Area | Dart files |
| --- | --- |
| core | 654 |
| screens | 59 |
| features | 23 |
| domain | 3 |
| theme | 3 |
| widgets | 3 |
| presentation | 2 |
| ai | 1 |
| config | 1 |
| firebase_options.dart | 1 |
| main.dart | 1 |


## 4. Major Module Distribution

| Module | Dart files |
| --- | --- |
| core/financial | 293 |
| core/engines | 64 |
| screens | 59 |
| core/automation | 31 |
| core/enterprise | 31 |
| features/enterprise | 23 |
| core/identity | 19 |
| core/events | 18 |
| core/notification | 18 |
| core/phoenix | 17 |
| core/business_process | 13 |
| core/meeting | 13 |
| core/workflow | 12 |
| core/shared | 12 |
| core/scheduling | 11 |
| core/learning | 11 |
| core/consultation | 10 |
| core/payment | 9 |
| core/timer | 9 |
| core/booking | 9 |
| core/workspace | 8 |
| core/escrow | 8 |
| core/permissions | 7 |
| core/pricing | 7 |
| core/routing | 6 |
| core/session | 5 |
| theme | 3 |
| widgets | 3 |
| domain | 3 |
| core/services | 3 |
| core/bootstrap | 2 |
| core/di | 2 |
| core/experience | 2 |
| presentation | 2 |
| firebase_options.dart | 1 |
| main.dart | 1 |
| ai | 1 |
| config | 1 |
| core/repositories | 1 |
| core/roles | 1 |
| core/constants | 1 |
| core/config | 1 |


## 5. Top Findings

1. `lib/core` contains 654/751 Dart files and combines product domains, platform capabilities, engines, infrastructure and orchestration.
2. Direct Cloud Firestore imports occur in **33 files**; direct `FirebaseFirestore.instance` appears in **25 files**.
3. Direct Firebase Auth imports occur in **12 files**; direct `FirebaseAuth.instance` appears in **9 files**.
4. Presentation contains **17 Cloud Firestore import files**, **10 FirebaseAuth import files** and **1 Agora import file**.
5. The module graph contains **2 strongly-connected component groups**, including a direct `core/financial ↔ core/escrow` cycle.
6. Financial contains **293 files**, dwarfing Booking (9), Scheduling (11), Payment (9) and Consultation (10).
7. The repository has **132 architecture tests**, but no dedicated automated gates were identified for the eight governance rules targeted by Lot B.
8. The registered production payment path remains incomplete: PSP names exist in models/UI/registry concepts, while the current-state audit found a mock payment provider registered and no production PSP registry entry.
9. Several runtime placeholders remain: `UnsupportedError`, mock/demo references, TODOs and nullable return paths.
10. `main.dart` acts as startup, Firebase adapter, auth observer, Firestore reader, router and presentation shell.

## 6. Product Critical Path

| Stage | Readiness | Observation |
| --- | --- | --- |
| Discovery | PARTIAL | Screens and expert discovery exist; no canonical feature boundary/application layer is established. |
| Scheduling | PARTIAL | 11 Dart files with availability/timezone/orchestration concepts; no dedicated repository structure found. |
| Booking | PARTIAL | 9 Dart files; domain foundation and memory repository exist; production lifecycle/persistence/payment snapshot incomplete. |
| Payment | PARTIAL | 9 core/payment files plus separate payment engines/financial areas; no production PSP registry identified. |
| Consultation | PARTIAL | 10 Dart files with state machine/repository/workflow; end-to-end lifecycle remains under-tested. |
| Financial | LEGACY HEAVY | 293 files in core/financial; mature relative to product, but overlaps with escrow/engines and has placeholders. |
| Review | MISSING | No first-class Review module identified in the source snapshot. |


## 7. CTO Risk Summary

### P0
- Prevent new Presentation → Firestore/FirebaseAuth coupling.
- Prevent new Domain → infrastructure SDK coupling.
- Break or contain the Financial↔Escrow cycle before new financial integration work.
- Prevent new startup/composition responsibilities from entering `main.dart`, Phoenix or scattered DI locations.
- Establish baseline-aware architecture gates before Booking Core expansion.

### P1
- Rationalize Workflow/Automation/Phoenix orchestration boundaries.
- Establish public module façades for Booking, Scheduling, Payment, Consultation and Financial.
- Replace runtime mocks/placeholders on the production path.

## 8. Baseline Principle

```text
CURRENT VIOLATIONS
    → KNOWN LEGACY BASELINE

NEW VIOLATIONS
    → FUTURE CI BLOCKER
```

Critical security, money and data-integrity violations are not automatically grandfathered.

**THIS BASELINE IS DESCRIPTIVE, NOT PRESCRIPTIVE.**
