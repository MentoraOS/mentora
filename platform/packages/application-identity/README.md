# @mentora/application-identity

The Identity & Access **application layer**: the Golden Pipeline is plugged, never reimplemented.

- `definitions/` — one `SequenceDefinition` per unit (`identity-sequence-definition.ts`, `session-sequence-definition.ts`): receive (published validation, A-1 guard), load by Identifier, validate (the wire→domain seam + injected instant), act (the unit or the factory decides), retain with the RFC-001 context.
- `services/` — one boring carrier per ratified command (A-1): Establish/RevokeCredential, Open/End/RevokeSession.
- `read/ports/` — the two **capability** read ports of the M-10 gate (`CredentialStateReadPort` with factor references, `SessionStateReadPort`). No I&A Query is ratified (F3.3 §5): the query table is **closed and empty by constitutional state**, declared and boot-validated in the composition.
- `composition/identity-composition.ts` — `composeIdentityAccess`: Pure DI, policies built from product params, tables compared to `IDENTITY_COMMAND_TYPES`/`SESSION_COMMAND_TYPES`, fail closed.

Reference for any new `application-<domain>`: `docs/reference/identity-reference-handbook.md` §5.
