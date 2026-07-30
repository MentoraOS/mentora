# Product Critical Path Readiness

**Sprint:** -1.2 / Lot A  
**Mode:** READ-ONLY

## 1. Readiness Matrix

| Stage | Status | Evidence / interpretation |
| --- | --- | --- |
| Discovery | PARTIAL | Screens and expert discovery exist; no canonical feature boundary/application layer is established. |
| Scheduling | PARTIAL | 11 Dart files with availability/timezone/orchestration concepts; no dedicated repository structure found. |
| Booking | PARTIAL | 9 Dart files; domain foundation and memory repository exist; production lifecycle/persistence/payment snapshot incomplete. |
| Payment | PARTIAL | 9 core/payment files plus separate payment engines/financial areas; no production PSP registry identified. |
| Consultation | PARTIAL | 10 Dart files with state machine/repository/workflow; end-to-end lifecycle remains under-tested. |
| Financial | LEGACY HEAVY | 293 files in core/financial; mature relative to product, but overlaps with escrow/engines and has placeholders. |
| Review | MISSING | No first-class Review module identified in the source snapshot. |


## 2. Core Imbalance

The primary product journey has small domain foundations relative to the platform core:

| Module | Dart files |
|---|---:|
| Booking | 9 |
| Scheduling | 11 |
| Payment | 9 |
| Consultation | 10 |
| Financial | 293 |

This is the key reason the architecture roadmap freezes broad Financial expansion and prioritizes product completion.

## 3. End-to-End Test Gap

No dedicated integration-test suite was discovered. The snapshot therefore lacks a single automated proof of:

```text
Discovery
→ Scheduling
→ Booking
→ Payment
→ Consultation
→ Settlement
→ Review
```

## 4. Gate Before Booking Core

Before major Booking Core expansion, Lot B should block new architecture regressions. We do **not** need to remove every legacy violation first.
