# Architecture Test Coverage

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

## 1. Current Test Distribution

- Dart test files discovered: **132**
- Files under `test/architecture`: **132**
- Other Dart test folders: **0 discovered**
- `integration_test` Dart files: **0**

The existing suite strongly tests platform/financial/workflow behavior, but it is not yet a governance enforcement suite for the new Handbook.

## 2. Governance Rule Coverage

| Rule | Existing dedicated gate | Status | Lot B requirement |
| --- | --- | --- | --- |
| Domain → Firebase forbidden | NO dedicated gate identified | MISSING | No dedicated boundary test identified |
| Domain → Flutter UI forbidden | NO dedicated gate identified | MISSING | No dedicated import-boundary test identified |
| Booking → Financial internals forbidden | NO dedicated gate identified | MISSING | No dedicated import-boundary test identified |
| Consultation → Agora forbidden | NO dedicated gate identified | MISSING | No dedicated import-boundary test identified |
| Payment → PSP SDK forbidden | NO dedicated gate identified | MISSING | No dedicated import-boundary test identified |
| Presentation → Firestore forbidden | NO dedicated gate identified | MISSING | No dedicated import-boundary test identified |
| No module dependency cycles | NO dedicated gate identified | MISSING | No graph-based cycle test identified |
| Shared → domain business rules forbidden | NO dedicated gate identified | MISSING | No dedicated shared-kernel boundary test identified |


## 3. Existing Product/Platform Test Signals

Existing test names include Booking domain/workflow, Consultation domain/state machine/settlement, Payment domain, Financial settlement, Automation and Workflow tests. These validate behavior and internal invariants, but they do not replace import/dependency boundary gates.

## 4. Required Lot B Tests

```text
ARC-001 domain_must_not_import_flutter_ui
ARC-002 domain_must_not_import_firebase
ARC-003 domain_must_not_import_firestore
ARC-004 domain_must_not_import_agora
ARC-005 product_domain_must_not_import_psp_sdk
ARC-006 booking_must_not_import_financial_internals
ARC-007 consultation_must_not_import_financial_internals
ARC-008 consultation_must_not_import_agora
ARC-009 presentation_must_not_import_firestore
ARC-010 shared_must_not_gain_domain_business_dependencies
ARC-011 product_domain_must_not_depend_on_screens
ARC-012 forbidden_cross_domain_internal_import
ARC-013 module_dependency_cycles_must_not_increase
```

These tests must be **baseline-aware**: existing legacy violations are recorded; new violations fail CI.
