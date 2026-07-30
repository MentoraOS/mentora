# Sprint -1.2 / Lot C — Public Module Boundaries

**Status:** READY TO INTEGRATE  
**Product behavior changed:** NO  
**Existing imports rewritten:** NO  
**Strategy:** Facade-first, baseline-aware migration.

## 1. Objective

Introduce stable public entry points for Mentora's critical modules without a Big Bang refactor.

From Lot C onward, new external consumers should prefer:

```dart
import 'package:mentora/core/booking/booking.dart';
import 'package:mentora/core/scheduling/scheduling.dart';
import 'package:mentora/core/payment/payment.dart';
import 'package:mentora/core/consultation/consultation.dart';
import 'package:mentora/core/meeting/meeting.dart';
import 'package:mentora/core/identity/identity.dart';
import 'package:mentora/core/notification/notification.dart';
import 'package:mentora/core/financial/financial.dart';
```

instead of importing implementation files directly.

## 2. Facades Added

| Module | Existing external internal imports | Public facade |
|---|---:|---|
| `booking` | 3 | `lib/core/booking/booking.dart` |
| `scheduling` | 0 | `lib/core/scheduling/scheduling.dart` |
| `payment` | 9 | `lib/core/payment/payment.dart` |
| `consultation` | 3 | `lib/core/consultation/consultation.dart` |
| `meeting` | 0 | `lib/core/meeting/meeting.dart` |
| `identity` | 10 | `lib/core/identity/identity.dart` |
| `notification` | 9 | `lib/core/notification/notification.dart` |
| `financial` | 25 | `lib/core/financial/financial.dart` |

The existing internal imports are grandfathered temporarily and are **not** rewritten in this lot.

## 3. Public API Policy

### Exposed

- models and enums;
- current domain/engine entry points where they already represent the module API;
- repository interfaces;
- provider-neutral services;
- stable financial value objects/identifiers.

### Intentionally hidden

- memory repositories;
- workflow implementations;
- Firestore adapters;
- provider-specific adapters;
- Financial Ledger internals;
- Financial pipeline/recovery/runtime internals;
- implementation-only notification strategies/templates.

## 4. Financial Boundary

`financial.dart` intentionally exposes only stable financial primitives and identifiers.

It does **not** export Ledger, Pipeline, Workflow, Orchestrator, Runtime, Firestore or memory repositories.

The future `MentoraFinancialGateway` is not invented in this lot; its operational contract will be introduced when Payment/Financial integration is implemented with real use-case requirements.

## 5. New Enforcement

```text
ARC-C01  Critical public facades must exist.
ARC-C02  New external imports of critical module internals are forbidden.
ARC-C03  Financial facade cannot export engine/persistence internals.
ARC-C04  Public facades cannot export concrete memory repositories.
```

## 6. Migration Rule

When touching a grandfathered consumer:

1. prefer the public facade when the required symbol is public;
2. if the symbol should not be public, introduce a narrow contract;
3. never expand a facade merely to expose an implementation detail.

## 7. Validation Commands

```powershell
dart format lib/core/booking/booking.dart `
  lib/core/scheduling/scheduling.dart `
  lib/core/payment/payment.dart `
  lib/core/consultation/consultation.dart `
  lib/core/meeting/meeting.dart `
  lib/core/identity/identity.dart `
  lib/core/notification/notification.dart `
  lib/core/financial/financial.dart `
  test/architecture/governance/public_boundary_legacy_baseline.dart `
  test/architecture/governance/public_module_boundaries_test.dart

flutter test test/architecture/governance/public_module_boundaries_test.dart
flutter test test/architecture/governance/architecture_compliance_test.dart
flutter analyze
```

## 8. Definition of Done

```text
Public facade files exist               PASS
No new direct critical internal import  PASS
Financial facade remains narrow         PASS
No memory adapter publicly exported     PASS
Lot B governance remains green          PASS
flutter analyze has no new Lot C issue  PASS
```

**No existing product runtime behavior is intentionally changed by this lot.**
