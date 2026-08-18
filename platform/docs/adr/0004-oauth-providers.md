# ADR-0004 — Fournisseurs OAuth externes (Google, Apple, GitHub)

**Statut : ACCEPTÉE — ratifiée par le CTO le 2026-08-18.** · Story : #108 (FEATURE-006, Sprint 4) · Propriétaires : `security` + `backend`

> **Ratification** — Architecture retenue telle que proposée : **OIDC Authorization Code + PKCE**, fournisseurs **Google, GitHub, Apple** (ordre de livraison Google → GitHub → Apple), **aucun SDK fournisseur**, tous les fournisseurs sont des **adaptateurs** (`adapters-identity-federation`), le domaine reste totalement indépendant. Le code OAuth reste hors périmètre jusqu'au Sprint 4 (FEATURE-006).

## Contexte

Le domaine I&A ratifié modélise la preuve par `Credential`/`Factor`/`FactorKind`/`ProofStrength` — sans nommer de fournisseur. Un login social est, au sens du canon, **un FactorKind dont la vérification est déléguée à un fournisseur externe** : l'assertion du fournisseur est la preuve ; l'unité n'en garde que références et nature (aucun jeton, aucune matière — l'invariant « aucun secret dans l'unité » s'applique intégralement). Le lien preuve↔personne reste dans l'ACL du Compte. Candidats ordonnés par le CTO : **Google, Apple, GitHub**.

## Contraintes (lois citées)

I-7/A-9 : les types du fournisseur meurent dans l'adapter (une assertion Google ne remonte jamais au-dessus du Root) ; I-8 : client secrets au coffre, référencés par nom, jamais commités (Environment Secrets, plan Lot 4) ; supply-chain-policy : dépendance nouvelle = décision — **aucun SDK fournisseur** si le protocole standard suffit ; M-10 : le gateway vérifie la session issue du flux, jamais des « scopes » fournisseur comme droits métier ; S-9/PII : seuls l'identifiant opaque du sujet (`sub`) et la nature du facteur sont retenus.

## Décision proposée

1. **Un seul mécanisme, trois configurations** : adapter générique **OIDC Authorization Code + PKCE** (Google et Apple sont OIDC ; GitHub, OAuth2 pur, exige un sous-adapter dédié pour l'identité — différence isolée dans l'adapter).
2. **FactorKind `federated`** avec `provider ∈ {google, apple, github}` en VO ; `ProofStrength` évalué par fournisseur (Apple/Google : élevé ; GitHub : standard) — la `ProofRequirementPolicy` décide, pas l'adapter.
3. **Zéro SDK fournisseur** : implémentation sur le protocole (fetch + vérification de signature JWKS), dans `adapters-identity-federation` ; toute bibliothèque éventuelle (ex. validation JOSE) passe par la politique dépendances normale.
4. **Flux** : callback → adapter vérifie l'assertion → `EstablishCredential` (premier lien, via ACL Compte) ou preuve d'un Credential existant → `OpenSession`. Le refus fournisseur = **Refus** ratifié, jamais une exception.
5. **Ordre de livraison** : Google → GitHub → Apple (Apple impose un secret JWT signé à rotation — le plus exigeant côté coffre, en dernier).

## Conséquences

Trois paires client-id/secret au coffre (rotation 90 j, criticité 🟠, catalogue Lot 4 à étendre) ; page de conformité « Sign in with Apple » requise côté produit ; tests d'intégration avec fournisseurs simulés (jamais les vrais en CI). Alternatives rejetées : SDKs fournisseurs (surface supply-chain, lock-in) ; un adapter par fournisseur sans socle commun (triplication) ; IdP intermédiaire type Auth0 (dépendance structurelle non nécessaire, coût, données hors périmètre).

**Décision CTO (2026-08-18)** : **ratifiée sans amendement.** Le CTO n'est plus à solliciter sur cette ADR ; le code de la story #96+ (mécanismes) et de la fédération arrive au Sprint 4, jamais avant.
