# @mentora/runtime-relay

The generic Outbox relay engine — the machinery of the Relay executable
species (F5.1 §3: "porte les Outbox de faits et de commandes vers le Bus").
A-4: "la publication lit la rétention — jamais l'inverse, jamais avant";
M-4: every publication is born from an owner's Outbox. **Envelope transport
only**: no domain, no application, no contracts import (asserted by test);
the payload is opaque; no broker vendor — the source and the publisher are
the relay's OWN ports (I-4), implemented below (I-12).

## The road of one envelope

claim (a LEASE-OPTIMIZATION, never a guardian — F5.1 §19: an expired claim
frees the row, "l'Outbox pardonne"; the unique EFFECT is produced by the
consumer Inboxes, A-5) → publish (abstract port) → ACK pending → published
(NEVER a deletion) | failure → bounded retries with exponential backoff +
injected jitter (M-8: "le retry infini est un anti-pattern") | budget spent
→ **Quarantaine**: parked, never deleted, witnessed (error Log + metric +
health snapshot; the full Signal d'exploitation materialization awaits the
Alert tooling — SIGNALED); its exit is a replay tooling act.

## Ordering & starvation

Order is promised PER UNIT SUBJECT only (F4.3 §4): the source's eligibility
contract (proven by the RelayContractSuite) claims oldest-first, one
in-flight envelope per subject, and HOLDS the successors of a struggling
subject — while every other subject keeps flowing (M-8: a poison never
blocks the queue). That structural rule IS the starvation protection.

## Pieces

`PendingScanner` (batch, pagination, stable order) · `ClaimEngine` (claim
duration policy — atomicity is the source's mechanism) · `RelayPublisherPort`
(abstract) · `RelayAck` · `RelayRetryEngine` (technical, bounded, jittered —
deliberately NOT a "Policy") · `RelayQuarantine` · `RelayHealth` (R-6: a
backlog is never a death signal) · `RelayMetrics` · `RelayTracing` (child
span of the CARRIED trace; correlation/causation/traceparent forwarded
untouched — "aucune perte") · `RelayDispatch` (the whole road) ·
`RuntimeRelayModule` (I-11: start/drain/dispose; injected pacer, no overlap)
· testing: `InMemoryRelaySource` (the reference implementation of the source
contract), `MemoryRelayPublisher`, `relayContractSuite` (the promises every
future SQL binding must hold).

The binding of the 2B-1 Agreement Outbox table to `RelaySourcePort` is a
FUTURE lot (it needs an expand migration adding claim/next-attempt columns —
S-7; the 2B-1 rows and their 'pending' status are untouched today).
