# Production Readiness Checklist — Mentora

**Statut** : standard officiel (CTO, 2026-08-19) · S'applique à un **domaine** (avant « Production Ready » au certificat) et à un **exécutable** (avant tout déploiement hors dev). Chaque ligne a une preuve observable ; « je pense que » n'est pas une preuve.

## 1. Exécutabilité (boot = exécutabilité, CI = conformité — I-10)
- [ ] Le Root boote **fail closed** : configuration complète validée (rapport COMPLET des violations), validateurs (`database-reachable`, `identity-database-reachable`, …) verts, sinon `BOOT REFUSED` et exit 1.
- [ ] Ordre de vie I-11 respecté : construire → démarrer → drainer → libérer, mort en ordre inverse ; SIGINT/SIGTERM drainent une fois.
- [ ] `/live`, `/ready`, `/health` servent les verdicts déclarés ; readiness couvre **chaque** moteur de registre et la source du relais.

## 2. Données
- [ ] Migrations déployées par le mécanisme (`prisma migrate deploy`), jamais par le boot ; chaque migration est expand-only et réversible par fenêtre.
- [ ] Photo + delta(0) reconstruit chaque unité ; checksum vérifié à chaque lecture ; corruption = `PERSIST.CORRUPTION` jamais une unité menteuse.
- [ ] Outbox : aucune ligne en quarantaine inexpliquée ; backlog observable (`pending/retrying/quarantined/oldest`).
- [ ] Lectures de validité sur le **primaire** (S-5).

## 3. Sécurité
- [ ] Aucun secret dans le dépôt, la config, les logs, les tests : références de coffre seules (I-8) ; secret scanning + push protection actifs.
- [ ] Matière de preuve : un lieu (coffre), sens unique (scrypt), désaveu au recovery ; scan « zéro matière » vert.
- [ ] Gate : 401 transport / 409 refus / 400 violations / 404 porte fermée — voix plate sur les preuves.
- [ ] Fournisseurs fédérés : secrets au coffre (rotation 90 j), PKCE S256, JWKS vérifié, aucun SDK.
- [ ] Revue security formelle du périmètre **réalisée** (story dédiée) — sinon le certificat dit PARTIAL.

## 4. Observabilité & corrélation
- [ ] Corrélation acceptée ou frappée à l'entrée, échoée, présente dans journaux, outbox, enveloppe du relais (RFC-001, « aucune perte »).
- [ ] Trois registres séparés (runtime / journal de Séquence / transport) reliés par la clé ; aucune donnée métier dans les logs techniques.
- [ ] Métriques du relais et santé exposées ; puits de télémétrie = adapter interchangeable (O-10).

## 5. Supply chain & release
- [ ] Dépendances gouvernées (Dependabot trains, majors = ADR) ; aucune dépendance nouvelle sans décision ; `supply-chain-audit` vert.
- [ ] SBOM à partir du lockfile (syft épinglé, SHA vérifié), `release-manifest.json`, canaux candidate/official ; provenance attestée.
- [ ] Workflows épinglés par SHA ; nightly froide verte (Run1 ≡ Run2).

## 6. Conformité & documentation
- [ ] Domain Checklist cochée avec preuves ; Definition of Done satisfaite ; certificat d'Epic à jour sur l'état réel (PARTIAL/FAIL justifiés).
- [ ] ADR/RFC ratifiées pour tout comportement non dicté par le Canon ; aucun STOP ouvert sans dossier d'instruction.
- [ ] README des paquets, handbook de référence et ce document **liés** depuis la documentation officielle.

## 7. Exploitation
- [ ] Runbooks : démarrage, drainage, rotation des secrets, quarantaine du relais, rejeu d'outbox (acte d'outillage journalisé, à cible nommée — M-8).
- [ ] Séparation des espèces d'exécutable en production (Application ≠ Relay — l'exécutable mixte est toléré en dev seulement, F5.1 §3).
- [ ] Environnements `dev/staging/prod` avec relecteurs et secrets distincts ; lockdown d'urgence documenté.
