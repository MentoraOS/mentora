# Mentora Architecture Baseline — README

**Sprint:** -1.2 / Lot A  
**Audit type:** Read-only source audit  
**Source snapshot:** `mentora(3).zip`  
**Dart source files audited:** 751  
**Test files audited:** 132

## Purpose

This folder captures the architectural debt that already exists before enforcement is introduced.

```text
THIS BASELINE IS DESCRIPTIVE, NOT PRESCRIPTIVE.
```

A legacy violation recorded here is not permission to introduce another one.

## Files

1. `01-architecture-baseline.md`
2. `02-dependency-violations.md`
3. `03-infrastructure-leaks.md`
4. `04-module-cycles.md`
5. `05-repository-runtime-risks.md`
6. `06-architecture-test-coverage.md`
7. `07-product-critical-path-readiness.md`
8. `08-stabilization-backlog.md`

## Audit Operations

The source was scanned without modifying product files.

Checks included:

- Dart file distribution;
- package/import scanning;
- Firebase/Firestore/Auth/Agora usage;
- direct singleton usage;
- domain/presentation boundary leaks;
- module-level import graph;
- strongly connected components;
- direct mutual dependencies;
- TODO/Mock/Demo/UnsupportedError/null-return signals;
- architecture-test inventory;
- critical-path readiness.

## Quality Command Limitation

`flutter analyze` and Flutter test execution could not be run in the audit environment because the Flutter SDK executable is not installed there. This is an environment limitation, not a claim that the repository analysis/tests pass.

When running locally, execute:

```bash
flutter analyze
flutter test
```

and append the results to the baseline before making them CI acceptance criteria.

## Re-run Policy

Lot B should convert the documented baseline into an allow-listed architecture enforcement mechanism:

```text
Existing baseline violation → recorded
New violation → test failure
```
