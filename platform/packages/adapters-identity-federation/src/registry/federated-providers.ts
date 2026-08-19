/**
 * The DECLARED federation registry (ADR-0004 §2): the closed provider
 * list, the FactorKind of the federated proof, and each provider's
 * ratified ProofStrength — "évalué par fournisseur (Apple/Google :
 * élevé ; GitHub : standard) — la ProofRequirementPolicy décide, pas
 * l'adapter". A provider outside this table does not exist (fail closed).
 * The factor NAME of a federated proof is `<provider>:<subject>` — a
 * reference, never material (nothing to put in a vault: the provider
 * holds the proof; we hold its name).
 */

export const FEDERATED_FACTOR_KIND = 'federated';

export const FEDERATED_PROVIDERS = ['google', 'github', 'apple'] as const;
export type FederatedProvider = (typeof FEDERATED_PROVIDERS)[number];

export const FEDERATED_STRENGTHS: Readonly<Record<FederatedProvider, string>> = {
  google: 'elevated',
  apple: 'elevated',
  github: 'standard',
};

/** The factor name (reference) of a federated subject — ACL joins live on it (A05). */
export const federatedFactorId = (provider: FederatedProvider, subject: string): string =>
  `${provider}:${subject}`;

/** Well-known OIDC endpoints of the two OIDC providers (GitHub differs — its own adapter). */
export const OIDC_ENDPOINTS = {
  google: {
    issuer: 'https://accounts.google.com',
    authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenEndpoint: 'https://oauth2.googleapis.com/token',
    jwksUri: 'https://www.googleapis.com/oauth2/v3/certs',
  },
  apple: {
    issuer: 'https://appleid.apple.com',
    authorizationEndpoint: 'https://appleid.apple.com/auth/authorize',
    tokenEndpoint: 'https://appleid.apple.com/auth/token',
    jwksUri: 'https://appleid.apple.com/auth/keys',
  },
} as const;
