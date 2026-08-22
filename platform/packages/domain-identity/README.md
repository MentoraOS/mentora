# @mentora/domain-identity

The Identity & Access **domain** (canon ch.04, Domaine 12): two ratified units and their law.

- `Credential` — `Active → Revoked` (terminal, R-B); Entity `Factor` (principal + secondaries since MFA); VOs `FactorKind`/`ProofStrength` (guarded opaque values, never an invented enum); **no secret inside, ever**; R-A key declared by `ActiveCredentialUniquenessSpecification`, applied by the registry; facts `CredentialEstablished`/`CredentialRevoked` — references and natures only.
- `Session` — opened on proof, provenance `CredentialId`, `Active → Ended | Revoked`; **no published fact, structurally** (no `pendingFacts` field — locked by the key-surface test).
- `ProofRequirementPolicy` — the ratified judge: allowlist of accepted strengths + the product-declared composition table (MFA); no strength algebra exists in the canon, so none is invented.
- Ports owned here: `CredentialRepository`, `SessionRepository` (`retain(unit, context?)` — RFC-001). Contract suites (`./contract-suite`, `./session-contract-suite`) are written once and replayed on the memory references here and on PostgreSQL in `adapters-persistence-identity` — the latter is the persistence acceptance criterion.

This package is the **reference aggregate model** for Mentora: `docs/reference/identity-reference-handbook.md` §2-§4, §6.
