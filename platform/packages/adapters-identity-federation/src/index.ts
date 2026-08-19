/**
 * @mentora/adapters-identity-federation — ADR-0004 (ratified), delivered
 * at MECHANISM level: the protocol adapters are complete and proven
 * against simulated providers; the ENTRY FLOW (callback → subject →
 * credential → OpenSession) lands with the Account ACL (A05) because the
 * proof↔person join lives THERE (canon ch.04) — nothing here invents it.
 */
export * from './oidc/pkce.js';
export * from './oidc/id-token.js';
export * from './oidc/oidc-provider.js';
export * from './github/github-identity-adapter.js';
export * from './apple/apple-client-secret.js';
export * from './registry/federated-providers.js';
