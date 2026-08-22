# @mentora/application-account

The Account **application layer** (Lot A03) — the Golden Pipeline plugged, never reimplemented.

- `definitions/` — **ONE generic plug** (`accountSequenceDefinition`) for the four units: registry seams (`load`, `retain(ctx)` — RFC-001) + use case seams (`map` at pas 5, `act` at pas 6); A-1 guard at reception. Pattern extracted from Identity (where the skeleton was written once per unit).
- `services/` — the eleven boring carriers (catalogue 36-46): births refuse an inhabited Identifier (R-B), transitions refuse absence, the units decide. `ChangeAvailabilityFrame` routes absent ⇒ birth (RFC-003 P2); `ChangeReachability` and `StartSubscription` let the ratified policies judge at the seam.
- `read/` — the **two ratified lectures** (catalogue 03 n°4 `AvailabilityFrameQuery` — ayant droit : tous ; n°10 `ReachabilityQuery` — la Notification sanctionnée + le Titulaire) as real Séquences de Lecture with their R-C grids; responses STRIP the domain. Refusals `RightMissing` / `AccountUnavailable` (signaled precedent).
- `reactions/` — the **declared choreography** (RFC-003 P3/P4): one journey per person whose only memory is its position (the active subscription, learned from `SubscriptionStarted`); `AccountClosed → EndSubscription`, `SettlementReport failed → EndSubscription`; Outbox de commandes drained by the composition's **declared handler**. `SubscriptionEnded` is not consumed (its ratified wire names no person — documented, idempotent consequence).
- `acl/` — `SettlementAclPort` (owned here; orders out, Account-worded reports in — M-7) and the **PROVISIONAL** `DevelopmentNoSettlementAdapter`: named as such, refuses to exist outside `development` (at construction and at composition), records every order in a visible ledger, produces no report — the absence of Settlement is never masked.
- `composition/` — `composeAccount`: Pure DI, 11 carriers ≡ catalogue, 2 readers ≡ lectures, 3 consumed inputs ≡ choreography, Settlement adapter named and guarded; the Subscription's order is commissioned AFTER retention (A-4) by a declared post-retention act, an ACL refusal surfacing as a Failure.

Copied from the reference domain (`docs/reference/identity-reference-handbook.md` §5).
