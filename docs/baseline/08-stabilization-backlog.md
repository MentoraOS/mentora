# Stabilization Backlog

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

Items below are derived from observed source evidence. This is not a request to execute them during Lot A.

| ID | Problem | Module | Risk | Evidence | Target lot | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| STAB-001 | Introduce baseline-aware architecture rule scanner/tests | Architecture | New regressions remain possible | This baseline | Lot B | P0 |
| STAB-002 | Block new Presentation → Firestore imports | Presentation | UI/data-access coupling | 17 presentation Firestore import files | Lot B/E | P0 |
| STAB-003 | Block new Presentation → FirebaseAuth imports | Presentation/Identity | Identity source-of-truth fragmentation | 10 presentation FirebaseAuth import files | Lot B/E | P0 |
| STAB-004 | Block Domain → infrastructure SDK imports | Domain | Framework/provider leakage | Domain infrastructure violation detected | Lot B/E | P0 |
| STAB-005 | Contain Financial↔Escrow dependency cycle | Financial/Escrow | Money ownership/cycle risk | Direct mutual dependency | Lot B then migration | P0 |
| STAB-006 | Add cycle non-regression gate | Repository | Dependency direction can worsen | 2 SCC cycle groups | Lot B | P0 |
| STAB-007 | Create Booking public boundary | Booking | Internal imports remain uncontrolled | Booking currently core/workflow-coupled | Lot C | P0 |
| STAB-008 | Create Scheduling public boundary | Scheduling | Scheduling directly depends on Booking/Consultation | Module graph | Lot C | P0 |
| STAB-009 | Create Payment/Financial gateway boundary | Payment/Financial | Payment/Financial overlap | Multiple payment/financial modules | Lot C | P0 |
| STAB-010 | Create Consultation/Meeting boundary | Consultation/Meeting | Technical/provider leakage risk | Agora exists at screen layer; Meeting abstraction exists separately | Lot C/E | P0 |
| STAB-011 | Establish single composition root | App bootstrap | Startup responsibilities scattered | main.dart + DI/bootstrap/Phoenix/routing cycle | Lot D | P0 |
| STAB-012 | Review MockPaymentProvider production registration | Payment | Production transaction risk | Mock provider found by current-state audit | Lot E | P0 |
| STAB-013 | Review UnsupportedError and nullable runtime paths | Financial/Enterprise/etc. | Runtime failure risk | 2 UnsupportedError files + 36 return-null files | Lot E | P1 |
| STAB-014 | Freeze new Workflow/Business Process/Phoenix responsibilities | Platform | Orchestration overlap | Workflow/BusinessProcess/Phoenix coupling | All -1.2 lots | P1 |
| STAB-015 | Add CI architecture gate | CI | Rules are documentation-only without automation | No new governance gate yet | Lot F | P0 |


## Execution Order

```text
Lot B — Architecture Test Suite
Lot C — Public Module Boundaries
Lot D — Composition Root Stabilization
Lot E — Infrastructure Leak Control
Lot F — CI Architecture Gate
```

P0 work blocks architectural regression. P1 work is stabilization debt that can proceed after the P0 gates exist.
