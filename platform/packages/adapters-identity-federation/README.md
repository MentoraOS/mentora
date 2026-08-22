# @mentora/adapters-identity-federation

ADR-0004 (ratified) delivered at **mechanism** level: the federated-proof adapters of the vestibule, over the raw protocol, **zero provider SDK**.

- `oidc/` — PKCE (S256 only), `verifyIdToken` (JWKS, RS256/ES256 through node:crypto; iss/aud/exp/nonce checked, flat motivated rejections), `OidcProviderAdapter` (one mechanism: Google and Apple are configurations).
- `github/` — the one isolated difference: OAuth2 without OIDC, identity from the user surface; only the opaque numeric id survives (S-9).
- `apple/` — the client secret is a **minted ES256 JWT** from a vaulted EC key, never a stored string.
- `registry/` — the closed provider list, `FEDERATED_FACTOR_KIND`, ratified strengths per provider (google/apple `elevated`, github `standard` — the policy decides, not the adapter), `federatedFactorId = <provider>:<subject>`.

Seams are injected (fetch, clock, `SecretResolver`): specs run against **simulated providers** — never the real ones in CI. The **entry flow** (callback → subject → credential → `OpenSession`) lands with the Account ACL (FEATURE-A05): the proof↔person join lives there by canon — nothing here invents it.
