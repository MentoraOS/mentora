# Lot B Validation Record

**Sprint:** -1.2 / Lot B  
**Deliverable:** Baseline-aware architecture enforcement suite

## Design Decisions

1. No product file is changed.
2. No pub dependency is added.
3. Existing debt does not make the repository permanently red.
4. New architecture debt fails immediately.
5. Debt removal is accepted automatically.
6. Module-cycle detection uses Tarjan strongly connected components.
7. The module granularity follows the Lot A audit:
   - `core/<module>`
   - `features/<feature>`
   - top-level `screens`, `presentation`, `main.dart`, etc.
8. Cross-domain internal import enforcement is initially scoped to critical Mentora modules.

## Expected Initial Baseline

```text
Domain → Firebase/Firestore       1 grandfathered file
Presentation → Firestore        17 grandfathered files
Presentation → FirebaseAuth     10 grandfathered files
Consultation → Agora             0
Booking → Financial internals    0
Consultation → Financial         0
Product → concrete PSP SDK       0
Product → screens                0
Cross-critical internal imports  6 grandfathered imports
Module cycle groups              2 grandfathered SCCs
```

## Environment Note

The suite was generated from the repository snapshot audited in Lot A.

Flutter CLI execution must be performed on the development machine after integration because the generation environment does not include the Flutter executable.

A local PASS requires:

```bash
flutter test test/architecture/governance/architecture_compliance_test.dart
flutter test
flutter analyze
```
