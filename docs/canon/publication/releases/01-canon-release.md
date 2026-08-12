---
doc: canon-release-01
title: Canon Release — métadonnées officielles de publication du Corpus Canonique
type: release
titre: canon
statut: "Projeté — R2-Projections Lot 5A (Canon Release)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5A"
canonical_release_id: "canon-release-1.0.0"
corpus_version_id: "foundation-v1.0.0"
source_autorite:
  - "docs/canon/source/ — la Constitution (autorité unique)"
  - "docs/canon/projection/ — Glossaire, Vocabulary Diff, Handbook, Catalogues"
note: >-
  PROJECTION déterministe de la Source et des projections. Ce document porte
  UNIQUEMENT les métadonnées de publication ; il ne contient aucune loi, aucune
  définition, aucune architecture (règle N°36 : une publication assemble des
  vérités déjà présentes, n'en crée aucune). Il DÉCRIT le contenu, jamais le
  contenu lui-même (N°37). Il est entièrement dérivable et régénérable sans perte
  (N°40) ; deux générations depuis la même Source produisent le même résultat
  (N°38) — aucune donnée volatile (aucun horodatage mural). Les empreintes sont
  des SHA-1 de blob git (fonction pure du contenu). Évolution : Titre VII.
---

# Canon Release — `canon-release-1.0.0`

> **Métadonnées officielles de publication** du Corpus Canonique de Mentora, à la
> version de corpus **`foundation-v1.0.0`** (`8d095ee`). Ce document assemble et
> décrit ; il ne crée aucune vérité et ne reproduit aucun contenu constitutionnel
> (règles N°36, N°37).

## 1. Release Manifest

La **Canon Release** publie le Corpus Canonique à sa version de corpus gelée.
Elle assemble deux ensembles, sans en modifier aucun :

| Ensemble | Emplacement | Rôle | Documents |
|----------|-------------|------|-----------|
| **Source** (la Constitution) | [`source/`](../../source/) | autorité unique | 27 chapitres (F1→F5) |
| **Projection** (dérivée) | [`projection/`](../../projection/) | reconstructible depuis la Source | 15 documents |

*La Release n'emballe que des documents déjà ratifiés ou déjà projetés ; elle
n'ajoute rien (N°36).*

## 2. Version Manifest — les cinq identités du Corpus (F5.8.99)

| Identité (F5.8.99) | Valeur | Dérivation |
|--------------------|--------|-----------|
| `CorpusVersionId` | `foundation-v1.0.0` | la photographie ratifiée (`8d095ee`) |
| `CanonicalReleaseId` | `canon-release-1.0.0` | dérivé de la version de corpus (1.0.0) |
| `GlossaryVersionId` | `glossary-1.1.0` | Constitution de la Langue v1.1.0 (F2.5.2) |
| `PublicationId` | `publication-canon-1.0.0` | publication canonique (espèce Canonique, F5.8.99) |
| `DocumentationAuditId` | *(émis au Lot 5C)* | Compliance Package |

*Rappel F5.8.99 : la Source est **intemporelle** ; `foundation-v1.0.0` est un
**instantané daté** d'un corps de lois qui la précède et lui survit. Une Release
(espèce Technique) n'est jamais une Publication Constitutionnelle.*

## 3. Release Metadata

| Champ | Valeur |
|-------|--------|
| Propriétaire | Conseil Constitutionnel de Mentora |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Baseline immuable | tag `foundation-v1.0.0` — jamais modifié |
| Branche de matérialisation | `arch-008-candidate` |
| Méthode | projection déterministe de la Source (aucune autre source) |
| Espèce de publication | **Canonique** (le Corpus publié) — F5.8.99 |
| Nature | métadonnées ; aucune loi, définition ni architecture (N°36) |

## 4. Release Notes

Cette release publie, en projection, l'intégralité du Corpus Canonique gelé
(F1→F5) et ses quatre projections officielles. **Références seules — aucun
contenu reproduit** (N°37) :

- **Source F1→F5** — [Foundation](../../source/foundation/01-foundation-constitution.md) · [Constitution](../../source/constitution/) · [Domaine](../../source/domain/) · [Exécution](../../source/application/) · [Production](../../source/production/) (dont le [Grand Audit F5.99](../../source/production/09-grand-audit.md)).
- **Glossaire officiel** — [glossary/01](../../projection/glossary/01-official-glossary.md) (Lot 1).
- **Vocabulary Diff** — [glossary/02](../../projection/glossary/02-vocabulary-diff.md) (Lot 2).
- **Handbook officiel** — [handbook/01](../../projection/handbook/01-official-handbook.md) (Lot 3).
- **Catalogues (12)** — [catalogs/](../../projection/catalogs/) (Lot 4).

*Aucune vérité nouvelle : la release constate l'état gelé et projeté.*

## 5. Version Matrix

| Composant | Version | Statut | Autorité |
|-----------|---------|--------|----------|
| F1 — Foundation | `foundation-v1.0.0` | gelé | Source |
| F2 — Constitution | `foundation-v1.0.0` | gelé | Source |
| F3 — Domaine | `foundation-v1.0.0` | gelé | Source |
| F4 — Exécution | `foundation-v1.0.0` | gelé | Source |
| F5 — Production | `foundation-v1.0.0` | gelé | Source |
| Glossaire | `glossary-1.1.0` | projeté | Projection |
| Vocabulary Diff | `canon-release-1.0.0` | projeté | Projection |
| Handbook | `canon-release-1.0.0` | projeté | Projection |
| Catalogues | `canon-release-1.0.0` | projeté | Projection |

## 6. Integrity Manifest

**Ancre d'intégrité** : la Source gelée sous le tag **`foundation-v1.0.0`**
(`8d095ee`), baseline **immuable** (jamais modifiée, jamais réécrite — F5.99). La
Source fait foi ; les projections en **dérivent** et sont **reconstructibles**
(PG-6, PG-12). Toute divergence projection ↔ Source est un défaut de la projection
(PG-3), résolu par régénération (N°40). Vérification exécutable : le **Vocabulary
Diff** (intégrité lexicale) et le futur **Compliance Package** (Lot 5C) — fail
closed.

Portée d'intégrité : **42 documents canoniques** = 27 chapitres de Source + 15
documents de projection.

## 7. Hash Manifest

Empreintes **content-derived** (SHA-1 de blob git : `git hash-object <fichier>`) —
fonction pure du contenu, donc reproductibles (N°38). Toute altération d'un
document change son empreinte.

### Source — Constitution (27 chapitres)

| Chapitre | SHA-1 (blob) |
|----------|--------------|
| `source/foundation/01-foundation-constitution.md` | `fa1ab11b2f81a6514ab47ed914aa2c436254652e` |
| `source/constitution/01-domain-landscape.md` | `37ad9209c24c844ff8de0db23315731abc446b91` |
| `source/constitution/02-context-map.md` | `07e9a976bca5f99d6894f6f4b9cbc11052d443dd` |
| `source/constitution/03-language-responsibilities-contracts.md` | `b8c4af0906c6eb34f2168c19c85252639533d4b4` |
| `source/constitution/04-bilingual-dictionary.md` | `14f6c1705d316db28a27001568c38f1e4a012a98` |
| `source/constitution/05-rules-invariants-failure-modes.md` | `6a89536644ab8677aeec5485c988babdaf393738` |
| `source/constitution/06-architecture-constitution.md` | `579039cdd26c3d91ca07f1f055083348fe487e26` |
| `source/domain/01-tactical-building-blocks.md` | `9c37fd809ef0f034fcd438a5f6198ee93009037d` |
| `source/domain/02-aggregates-customer-journey.md` | `69fb901ef60752256bbd79f992ec954f14a80611` |
| `source/domain/03-aggregates-identity-collaboration.md` | `b0ecbe2c486a4a0235cc697d87dd1e069e197211` |
| `source/domain/04-aggregates-platform-infrastructure.md` | `f3fb1ac8e53b8dcd24697344f835c143fb7db701` |
| `source/domain/05-grand-tactical-audit.md` | `27eb7460676c1de28d05cf7991817844e80320f1` |
| `source/domain/06-tactical-documentation-freeze.md` | `418d4930b62cdd252a7e749a7fc63c66b54e0c35` |
| `source/application/01-application-core-sequence.md` | `bd91262dcdbeb861f43f5654ed50e317395d7105` |
| `source/application/02-process-managers.md` | `e1c0fd589222509cdf186ba49dc3a954c39567d9` |
| `source/application/03-circulation.md` | `ad1e275c3fc3fc820bc351c5d12188ffb5b1754b` |
| `source/application/04-infrastructure-composition-runtime.md` | `cac4a9637504e1ca0e370f7b4f9bbdf79b9808cd` |
| `source/application/05-grand-application-audit.md` | `290e771229f9d8ae840e0094e1e5b1a265439285` |
| `source/production/01-runtime.md` | `3c3efa78bb475d938ac71f36abf14ebf2a120923` |
| `source/production/02-persistence.md` | `631b73f8b5c9f6bb5264bae3c20c6b30d8af75ab` |
| `source/production/03-observability.md` | `7a6fc7f30f959ef3dddd65226094645826ef214b` |
| `source/production/04-security.md` | `f0ae7b5489ec8f25eafc1e8776a986409834be3c` |
| `source/production/05-reliability.md` | `f1f901fea68e828942516d8b334de39efcedeab9` |
| `source/production/06-scalability.md` | `a13a468f32ef30accfb426b97227655b6ee35e83` |
| `source/production/07-operations.md` | `378947a8d54a4745bd475b5d8666dea1d60b0267` |
| `source/production/08-governance.md` | `b8a24bf78ffd51e8f9e0fcf288ae689dd7d4249c` |
| `source/production/09-grand-audit.md` | `8fea9de40f0083b78d3bf026614e55a770c07965` |

### Projection — documents dérivés (15)

| Document | SHA-1 (blob) |
|----------|--------------|
| `projection/glossary/01-official-glossary.md` | `4114375296e5815bdcfc51d347e79013755feb0a` |
| `projection/glossary/02-vocabulary-diff.md` | `ebd7651717380403451dfca0b7008783ed1bf08e` |
| `projection/handbook/01-official-handbook.md` | `b73747a4638dfae1eff32e04c80383d67132d573` |
| `projection/catalogs/01-events-catalog.md` | `f1d101a9db611e18d67ac4c009a86d0ae447d398` |
| `projection/catalogs/02-commands-catalog.md` | `6a6cc3fbd4f525da5c9e961a931b71d60dab83f5` |
| `projection/catalogs/03-queries-catalog.md` | `ff6ad765e8e90b048ba19aaddd67e8ea49195d89` |
| `projection/catalogs/04-policies-catalog.md` | `9a73f3beea22d4d3a9f2185d755d2e45f97cb394` |
| `projection/catalogs/05-aggregates-catalog.md` | `385a574694fd3fa15385a6f6e6b9260d021ab27d` |
| `projection/catalogs/06-projections-catalog.md` | `096baab2e2b04b8e9f7dd46d5c03dece561a80dc` |
| `projection/catalogs/07-identities-catalog.md` | `af3a2c477a4a50302e8f8c6adfa88ef55b25eb83` |
| `projection/catalogs/08-state-machines-catalog.md` | `4fab20ef241e70501e1edf5d661c643b1868f290` |
| `projection/catalogs/09-laws-catalog.md` | `9ae02f11f2d56a12d5aa7ba7a45d320525e294cd` |
| `projection/catalogs/10-theorems-catalog.md` | `765e4a6c06604c19ae45bc44a44c81aea3852ffe` |
| `projection/catalogs/11-proof-chains-catalog.md` | `15c1cb6f2c6c4a65c51116fab840f718c19e537a` |
| `projection/catalogs/12-anti-patterns-catalog.md` | `0822be1401cef201e8b9df73f656cdd465cac152` |

## 8. Publication Manifest

La publication canonique s'assemble dans cet ordre (les livres viennent au Lot 5B) :

1. **Source** (F1→F5) — l'autorité, publiée telle quelle.
2. **Projections** — Glossaire → Vocabulary Diff → Handbook → Catalogues.
3. **Livres officiels** (Lot 5B) : Foundation · Constitution · Domain · Application · Production · Projection.
4. **Compliance Package** (Lot 5C) — rapports générés depuis la Source.
5. **Publication Freeze** (Lot 5D) — certificat, signature, sceau, clôture.

**Reconstruction (N°38, N°40)** : *supprimez `publication/` et `projection/`,
régénérez-les depuis `source/` — le résultat est identique, empreintes comprises.*
La Source seule est irréductible ; tout le reste dérive.

---

## Provenance de projection (non normatif)

Projection déterministe de la **Source** (`docs/canon/source/`) et des projections
(`docs/canon/projection/`), jamais du transcript (règle N°31 ; le transcript n'est
plus une autorité). Ce document porte **uniquement les métadonnées** (N°36 : aucune
vérité nouvelle ; N°37 : décrit le contenu, jamais le contenu). Les empreintes sont
des **SHA-1 de blob git**, fonction pure du contenu (N°38 : reproductible ; aucune
donnée volatile, aucun horodatage mural). Toute **signature** (Lot 5D) certifiera
cette **publication**, jamais la Constitution (N°39). Le Package est **entièrement
dérivable** et régénérable sans perte (N°40). Évolution : **Titre VII**.
