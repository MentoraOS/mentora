# @mentora/contracts-account

The **published language** of the Account context (Story #156): branded identifiers (the Account IS the person — `PersonId` is its identity, RFC-003 P1; `DeviceId`, `SubscriptionId`, `SupportRequestId`), refusal-reason unions per unit, the **eleven ratified command wires** (catalogue 36-46) with per-type validation listing every violation, and the **seven ratified event wires** (catalogue 40-46) with their deterministic serializer (V-1).

- Vocabulary never invented: `DeviceUnavailable`, `ChannelUnavailable`, `WindowUnavailable`, `OfferUnavailable` derive from the ratified `-Unavailable` family; `SubscriptionAlreadyExists` from the `<Truth>AlreadyExists` family (dictionary ruling recorded as pending, same posture as Identity).
- Device and SupportRequest publish nothing: no fact of theirs exists here and none may be added.
- The Subscription/SupportRequest wires are complete from this lot; their units ship with Lot A02.

Reference model: `docs/reference/identity-reference-handbook.md` §2 — copied exactly from `contracts-identity`.
