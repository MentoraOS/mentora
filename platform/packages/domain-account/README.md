# @mentora/domain-account

The Account **domain** (canon F3.2-B, domaine 6) — Lot A01 ships two of its four ratified units:

- `Account` — the person's truth; identity **is** the `PersonId` (RFC-003 P1, singleton-par-acteur); `Active → Closed` (terminal, R-B); typed `Preference`s (the three ratified kinds), `ReachabilityChannel`, `VerificationState` (RFC-003 P6: recorded gap, no ratified command changes it), Entity `Device` (`deviceId`, `registeredAt` — P7, no fact); facts `PersonRegistered`, `PreferenceChanged`, `ReachabilityChanged`, `AccountClosed`. **Version law**: +1 per act, fact or not — `unretainedActs` lets the registry compute the expected previous version (the optimistic guard holds for the state-only device verbs).
- `AvailabilityFrame` — alive, singleton-par-Compte (identity = `PersonId`, P2), born at its first `ChangeAvailabilityFrame`; `CoherentFrameSpecification` (well-formed, non-overlapping); fact `AvailabilityFrameChanged`.
- `ClosableAccountSpecification` (closable iff Active — the sisters follow by choreography, P3), `ReachabilityPolicy` (product allowlist of channels — P5). Zero Domain Service (canon).
- Ports owned here: `AccountRepository`, `AvailabilityFrameRepository` (`retain(unit, context?)` — RFC-001). Memory references exported from the barrel; contract suites on `./account-contract-suite` and `./availability-frame-contract-suite` — written once, replayed here, replayed on PostgreSQL in Lot A04 (its acceptance criterion).

Copied exactly from the reference domain (`docs/reference/identity-reference-handbook.md` §2-§4, §6).
