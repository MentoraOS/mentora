# Sprint -1.2 / Lot B — Architecture Test Suite

**Status:** READY TO INTEGRATE  
**Scope:** Test-only architecture enforcement  
**Product code modified:** NO

## Purpose

Lot B transforms the Lot A baseline into executable non-regression gates.

The core policy is:

```text
KNOWN LEGACY VIOLATION
    → tolerated temporarily

NEW VIOLATION
    → TEST FAILURE
```

Removing a legacy violation is always allowed.

## Files

```text
test/architecture/governance/
├── architecture_legacy_baseline.dart
├── architecture_scanner.dart
└── architecture_compliance_test.dart
```

No dependency is added to `pubspec.yaml`. The suite uses only:

- `dart:io`
- `flutter_test`

## Rules enforced

| Rule | Gate |
|---|---|
| ARC-001 | Domain cannot gain Flutter UI imports |
| ARC-002/003 | Domain cannot gain Firebase/Firestore imports |
| ARC-004 | Domain cannot gain Agora imports |
| ARC-005 | Product domains cannot gain concrete PSP SDK imports |
| ARC-006 | Booking cannot import Financial internals |
| ARC-007 | Consultation cannot import Financial internals |
| ARC-008 | Consultation cannot import Agora |
| ARC-009 | Presentation cannot gain Firestore imports |
| ARC-009B | Presentation cannot gain FirebaseAuth imports |
| ARC-011 | Critical product domains cannot import Screens |
| ARC-012 | Cross-critical-domain internal imports cannot increase |
| ARC-013 | Module dependency cycles cannot increase |

## Current grandfathered debt

The baseline currently includes:

- 1 Domain → Firebase/Firestore import;
- 17 Presentation → Firestore import files;
- 10 Presentation → FirebaseAuth import files;
- 6 direct Scheduling → Booking/Consultation internal imports;
- 2 module-level strongly connected component cycle groups.

These entries are debt, not approved architecture.

## How to run

From the Mentora project root:

```bash
flutter test test/architecture/governance/architecture_compliance_test.dart
```

Then run the complete suite:

```bash
flutter test
```

And static analysis:

```bash
flutter analyze
```

## Rule for baseline updates

Do **not** add a new path to `architecture_legacy_baseline.dart` simply to make a test green.

A baseline addition requires an explicit approved architecture exception/ADR.

Debt removal requires no baseline update immediately because tests use subset semantics. Baseline cleanup may follow in a dedicated maintenance change.

## Next Lot

After this suite is green locally:

```text
Sprint -1.2 / Lot C — Public Module Boundaries
```
