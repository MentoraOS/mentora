# Mentora Genesis Baseline

**Status:** ACCEPTED / READY  
**Baseline date:** 2026-07-30  
**Repository root:** `C:\Users\Utlisateur\StudioProjects\mentora`  
**Canonical branch:** `main`

## Purpose

This document establishes the first formally auditable Git baseline for
Mentora. A repository recovery audit classified the workspace as recovery
scenario E: no recoverable predecessor Git history and no identifiable
original remote were found.

This baseline does not claim or reconstruct any prior Git lineage. The Genesis
commit represents the validated current system state and is the root of
Mentora's institutional repository history.

## Toolchain and dependencies

- Flutter: `3.38.9` stable
- Dart: `3.10.8`
- `firebase_core`: `3.15.2`
- `firebase_auth`: `5.7.0`
- `cloud_firestore`: `5.6.12`

## Architectural state

The baseline contains the current progressive Clean Architecture migration,
including Domain, Application, Infrastructure, Presentation, the canonical
Composition Root, constructor injection, and automated architecture
governance. Existing legacy debt remains descriptive and governed by the
repository's architecture baselines; Genesis does not legitimize new debt.

## ARCH-007 Wave 2B

**Expert Availability Firestore Concurrency**  
**Status:** WAVE 2B — INCORPORATED INTO GENESIS BASELINE  
**Closure:** WAVE 2B FORMALLY CLOSED VIA GENESIS BASELINE

The production boundary is:

`lib/infrastructure/expert_availability/firestore_expert_availability_repository.dart`

The frozen persistence invariants are:

1. the repository reads and validates the current server revision inside a
   Firestore transaction;
2. two clients may load the same initial revision;
3. the first valid writer succeeds and receives a new revision;
4. an existing Expert's top-level `availability` field is replaced exactly;
5. obsolete weekdays do not survive replacement;
6. empty availability persists as the canonical empty map;
7. unrelated Expert document fields remain unchanged;
8. stale writers are rejected with
   `ExpertAvailabilityConcurrencyException`;
9. the rejected writer cannot overwrite the successful writer's data;
10. `availabilityUpdatedAt` uses Firestore server Timestamp semantics;
11. sequential writes using each fresh revision remain valid;
12. production Firebase is never contacted by the integration gate.

Any future change affecting these invariants requires explicit architectural
review and corresponding regression evidence.

## Validation evidence

The following gates were executed against the Genesis candidate:

- Expert Availability targeted tests: `42/42 PASS`
- Architecture governance: `100/100 PASS`
- Full Flutter test suite: `1255/1255 PASS`
- Android + Firestore Emulator integration: `10/10 PASS`
- Compilation errors: `0`
- Analyzer legacy diagnostics: `224` warning/info diagnostics
- Production Firebase contacted: `NO`

Analyzer diagnostics are recorded, not suppressed. A known Android build
diagnostic reports that the project declares NDK `27.0.12077973` while the
`integration_test` plugin recommends `28.2.13676358`; the validated Android
build and all integration tests nevertheless pass.

## Protected Wave 2B artifacts

| File | SHA-256 |
| --- | --- |
| `lib/infrastructure/expert_availability/firestore_expert_availability_repository.dart` | `228ABB57156D0C6200ABFD3AEA124015346B44FA8EB679B083A044C538EA4584` |
| `integration_test/expert_availability_firestore_emulator_test.dart` | `D7D94823BDB13B390E7F11DFFFD2BCA03FC7DD38A8B252D0D20186834141B372` |
| `test/architecture/expert_availability_repository_test.dart` | `1F38DC05F8F1F18F313F0BDA955B898A96D205EDAF1843A69339E9ACE6C03846` |
| `test/architecture/governance/expert_availability_infrastructure_boundary_test.dart` | `C65FA063384C737E071DA4E586476CC8D4330271647E3CDEE6175C054F950324` |

## Repository governance

1. `main` is the canonical branch.
2. No production wave begins from an unaudited working tree.
3. Every wave starts from a known commit SHA.
4. Every wave records its starting SHA, ending SHA, production diff, test
   diff, governance evidence, and validation gates.
5. Generated and transient files never form part of architectural evidence.
6. Production and test changes must remain independently auditable.
7. Architecture baselines must never be rewritten to make tests appear green.
8. A failing mandatory gate blocks wave closure.
9. Git history must not be rewritten after Genesis without explicit governance
   authorization.
10. Any future remote publication must preserve the Genesis commit as the
    repository root.

