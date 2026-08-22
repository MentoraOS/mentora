# @mentora/contracts-identity

The **published language** of Identity & Access (1B precedent): branded identifiers, refusal-reason unions, the five ratified command wires (catalogue 70-74 — `EstablishCredential`, `RevokeCredential` in `IdentityCommandContract`; `OpenSession`, `EndSession`, `RevokeSession` in `SessionCommandContract`), the two ratified event wires (`CredentialEstablished`, `CredentialRevoked`) with their deterministic serializer, and per-type validation that lists **every** violation.

- Vocabulary is never invented: `SessionRefusalReason` carries `ProofUnavailable` as a documented derivation of the ratified `-Unavailable` family; the R-A credential refusal name is a recorded canon gap.
- Evolution is additive only (V-2): `secondaryFactors?` on `EstablishCredential` is the worked example — absent = the old wire.
- Reference for any new `contracts-<domain>` package: see `docs/reference/identity-reference-handbook.md` §1/§2.
