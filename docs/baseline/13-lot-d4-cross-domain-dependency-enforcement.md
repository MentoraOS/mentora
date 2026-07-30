# Sprint -1.2 / Lot D.4 — Cross-Domain Dependency Enforcement

## CTO correction before enforcement

The first D.1/D.3 draft used `availability` and `experience` as canonical owners.
That did not match the approved Architecture Handbook or the actual repository:

- the approved domain is `Scheduling`, not `Availability`;
- `Payment` is a primary product domain;
- `Discovery` and `Review` belong to the approved domain model;
- `Experience` is not an approved replacement for Review;
- the repository contains `lib/core/scheduling` and `lib/core/payment`.

The governance registry and matrix are corrected in this lot before D.4 is activated.

## D.4 baseline

The Lot A snapshot currently contains exactly six forbidden dependencies governed by this matrix:

```text
Scheduling → Booking       3 imports
Scheduling → Consultation  3 imports
```

All six come from:

```text
lib/core/scheduling/engine/scheduling_engine.dart
```

They remain grandfathered temporarily.

Any new forbidden cross-domain direction fails `ARC-D11`.

## Separation of responsibilities

Lot C answers:

> May an external consumer import this module's internals?

Lot D.4 answers:

> Is this source domain allowed to depend on that target domain at all?

Both gates are required.

## Validation

Run:

```powershell
dart format test/architecture/governance/domain_ownership_registry.dart `
  test/architecture/governance/domain_ownership_test.dart `
  test/architecture/governance/dependency_direction_matrix.dart `
  test/architecture/governance/cross_domain_dependency_legacy_baseline.dart `
  test/architecture/governance/cross_domain_dependency_test.dart

flutter analyze test/architecture/governance

flutter test test/architecture/governance/domain_ownership_test.dart

flutter test test/architecture/governance/cross_domain_dependency_test.dart

flutter test test/architecture/governance/public_module_boundaries_test.dart

flutter test test/architecture/governance/architecture_compliance_test.dart
```

Expected new D.4 result:

```text
+3: All tests passed!
```
