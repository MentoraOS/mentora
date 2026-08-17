# Supply Chain Policy — Politique officielle des dépendances

**MentoraOS — R5 Phase 2, Lot 5**

|                   |                                                                                                                                                    |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Version**       | 1.0                                                                                                                                                |
| **Propriétaires** | `platform` + `security`                                                                                                                            |
| **Principe**      | Une dépendance n'est jamais mise à jour parce qu'elle est plus récente. Elle est mise à jour parce qu'elle est **gouvernée**.                      |
| **Instruments**   | `.github/dependabot.yml` · `.github/workflows/supply-chain.yml` + `supply-chain-audit.mjs` · la gate (`verify`) · la Nightly · le Release Pipeline |

---

## 1. Politique de versions — la matrice

|                     | **Patch** (x.y.**z**)                              | **Minor** (x.**y**.z)         | **Major** (**x**.y.z)                                               |
| ------------------- | -------------------------------------------------- | ----------------------------- | ------------------------------------------------------------------- |
| Autorisé            | ✅ via train Dependabot hebdo                      | ✅ via train Dependabot hebdo | ❌ jamais automatique — **ADR d'abord**                             |
| Review obligatoire  | ✅ (1 review — aucune PR ne merge seule, Rulesets) | ✅ + lecture du changelog     | ✅ ADR + review Principal-équivalent                                |
| Merge interdit si   | CI rouge                                           | CI rouge ou changelog non lu  | ADR absent ou refusé                                                |
| Validation CI       | gate `verify` complète                             | gate `verify` complète        | gate + **Nightly verte** + release candidate                        |
| Release obligatoire | non (train normal)                                 | non (train normal)            | ✅ passe par une Release Candidate certifiée avant toute production |

**Les flux :**

```
Patch : PR Dependabot → CI (verify) → review → merge → la Nightly confirme la nuit même
Minor : PR Dependabot → CI (verify) → review + changelog → merge → Nightly
Major : besoin identifié (report/advisory) → ADR (motivation, migration, risques)
        → branche de migration → CI + Nightly → Release Candidate certifiée → merge → Release
```

Leçon fondatrice gravée : **Prisma 7** a changé son modèle de configuration en plein lot — l'épinglage au majeur 6 fut une décision, sa levée en sera une autre. Un major s'instruit, il ne se subit pas.

## 2. Stratégie Dependabot

**Cadence : hebdomadaire** (lundi 06:00 UTC). Comparaison : _quotidienne_ = bruit maximal, charge de review insoutenable à 2, gain sécurité nul (les advisories ont leur canal propre, immédiat) ; _mensuelle_ = correctifs qui dorment 4 semaines, trains énormes durs à réviser ; _hebdomadaire_ = alignée sur les rituels (Weekly), trains petits, la Nightly borne la dérive à 24 h. **Grouping : un train patch+minor par écosystème** (≤ 2 PR/semaine — jamais 50) ; comparaison : _grouped-by-update-type_ (retenu — un train se lit et se teste d'un bloc) vs _ecosystem seul_ (mélange patch et majors : illisible) vs _security grouping_ (inutile : les security updates arrivent déjà en PR individuelles prioritaires). **Majors npm : ignorés dans Dependabot** — visibles via le supply-chain report, traités par ADR. Majors d'actions GitHub : PR individuelles (rares, chacune change un contrat de workflow).

## 3. Security Advisories — traitement particulier

| Aspect                | Règle                                                                                                                            |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Priorité              | **Immédiate** — un advisory ne connaît pas le lundi ; P1 par défaut, P0 si exploitable en l'état de la plateforme                |
| Review                | `security` (+ propriétaire du paquet touché) — dans la journée ouvrée                                                            |
| Merge                 | Dès CI verte ; si le fix est un **major**, l'ADR est instruit en accéléré le jour même — jamais sauté                            |
| Rollback              | Binaires seulement (loi de release) ; si la version corrigée régresse, retour à N-1 + mitigation compensatoire documentée        |
| Communication         | Issue dédiée + note au Weekly ; si des données ont pu être exposées → procédure **Emergency Lockdown** (Lot 4 GitHub Governance) |
| Prérequis d'exécution | Activer _Dependabot security updates_ + _alerts_ dans les settings (acte de la séance de gouvernance authentifiée)               |

## 4. Gouvernance Supply Chain — la matrice des composants critiques

| Composant                               | Source officielle                          | Version épinglée                                                        | Politique de mise à jour                                                                   | Responsable             |
| --------------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------- |
| Node                                    | nodejs.org (`.nvmrc`)                      | 22.23.2                                                                 | Patch LTS : train normal ; ligne majeure : ADR                                             | `platform`              |
| pnpm                                    | `packageManager` (corepack)                | 9.12.3                                                                  | Minor : train ; major : ADR                                                                | `platform`              |
| Corepack                                | npm registry, épinglé aux workflows        | 0.31.0                                                                  | Revue trimestrielle (hors Dependabot — surveillé par le report)                            | `platform`              |
| Turbo                                   | npm (devDep racine)                        | 2.3.3                                                                   | Train Dependabot                                                                           | `platform`              |
| TypeScript / eslint / vitest / prettier | **catalog** pnpm-workspace (source unique) | 5.6.3 / 9.15.0 / 2.1.5 / 3.3.3                                          | Train Dependabot (le catalog = un seul point de montée)                                    | `platform` + `qa`       |
| Prisma / @prisma/client                 | npm                                        | **6.19.3 — majeur 6 épinglé par décision**                              | Patch/minor : train ; **majeur 7+ : ADR obligatoire** (leçon fondatrice)                   | `backend` + `platform`  |
| Actions GitHub (×6)                     | github.com/actions                         | SHA 40 hex + commentaire de version                                     | Dependabot (trains) ; **le SHA-pinning est une LOI — le report échoue si violée**          | `platform`              |
| Image PostgreSQL CI                     | pgvector/pgvector                          | tag `pg16` (pas de digest)                                              | Cible d'amélioration : épingler par digest (enregistré, report la surveille)               | `platform`              |
| Syft                                    | github.com/anchore/syft                    | 1.51.0 + SHA-256 officiel vérifié au run                                | Revue trimestrielle (hors Dependabot — report)                                             | `platform` + `security` |
| Compose dev hérité                      | `platform/infra/docker-compose.dev.yml`    | tags divers, composants **non ratifiés** (redis, rabbitmq, opensearch…) | **GELÉ hors gouvernance Dependabot à dessein** — lot d'hygiène R5 avant toute légitimation | `platform`              |

## 5. Comparaison des outils — pourquoi Dependabot

| Critère                                               | **Dependabot** (retenu)                                        | Renovate                                                                  | Mend / Snyk            |
| ----------------------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------- |
| Surface d'accès au dépôt privé                        | **Native GitHub — zéro app tierce, zéro token supplémentaire** | App hébergée Mend (accès tiers au code) ou self-hosted (infra à posséder) | App commerciale tierce |
| pnpm + catalog                                        | ✅ supporté                                                    | ✅ (plus fin)                                                             | partiel                |
| Grouping                                              | ✅ suffisant pour nos 2 trains                                 | ✅ supérieur (regex managers…)                                            | —                      |
| Binaires épinglés hors gestionnaires (corepack, syft) | ❌ non suivi → **couvert par notre supply-chain report**       | ✅ (regex managers) — le seul vrai avantage                               | —                      |
| Coût / maintenance                                    | 0                                                              | config riche à entretenir, ou infra                                       | licence                |
| Security advisories                                   | ✅ intégré GitHub Advisory DB                                  | via config                                                                | ✅                     |

**Verdict** : Dependabot — l'outil **natif** est le seul qui n'élargit pas la surface d'accès au dépôt (principe supply-chain premier) ; sa seule lacune réelle (les binaires épinglés à la main) est comblée par notre rapport premier-parti. Renovate reste documenté comme option future si les regex managers deviennent nécessaires (réévaluation par ADR).

## 6. Le Supply Chain Report

`supply-chain.yml` (hebdo lundi 06:30 UTC — après le train Dependabot —, dispatch, et PR touchant lockfile/workflows/dependabot) exécute l'outil premier-parti et publie **`supply-chain-report.json`** : dépendances critiques et versions, composants épinglés/non épinglés, actions et leur statut SHA, images docker et leur statut digest, mises à jour disponibles (`pnpm outdated`, informatif), niveau de risque (LOW/MEDIUM/HIGH), résultat global. **Loi bloquante unique : une action non épinglée par SHA = FAIL.** Permissions : `contents: read` seul.

---

_La Supply Chain est un actif de production : traçable (ce document + les rapports), reproductible (lockfile gelé, épinglages vérifiés), attestable (Release Pipeline : SBOM + provenance), gouvernée (cette politique). Toute évolution de cette politique passe par PR revue `platform` + `security`._
