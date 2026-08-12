---
doc: canon-index
title: Index canonique
type: apparatus
titre: canon
statut: "R2-Corpus Lot 6E — Source complète : F1, F2, F3, F4, F5 matérialisés (100 %) ; Grand Audit F5.99 clôt F1→F5"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Index canonique

L'index permet de retrouver **chaque document** du Corpus Canonique. Au Lot 1,
il indexe la **structure** (les emplacements réservés) ; il **ne contient encore
aucun contenu**. Il prépare l'arrivée des documents.

## Appareil (racine `canon/`)

| Document | Rôle |
|----------|------|
| [README.md](README.md) | Point d'entrée |
| [MANIFEST.md](MANIFEST.md) | Structure officielle |
| [CONVENTIONS.md](CONVENTIONS.md) | Conventions documentaires |
| [VERSIONING.md](VERSIONING.md) | Rangs de version |
| [PUBLICATION.md](PUBLICATION.md) | Objets de publication |
| [GOVERNANCE.md](GOVERNANCE.md) | Droits et autorités |
| [NAVIGATION.md](NAVIGATION.md) | Parcours du corpus |

## Source — le Corpus Canonique (matérialisée à 100 %)

| Titre | Emplacement | Statut |
|-------|-------------|--------|
| **F1 — Foundation** | [`source/foundation/`](source/foundation/) → [01-foundation-constitution.md](source/foundation/01-foundation-constitution.md) | **matérialisé** (Lot 2, verbatim) |
| **F2 — Constitution** | [`source/constitution/`](source/constitution/) → [01](source/constitution/01-domain-landscape.md) · [02](source/constitution/02-context-map.md) · [03](source/constitution/03-language-responsibilities-contracts.md) · [04](source/constitution/04-bilingual-dictionary.md) · [05](source/constitution/05-rules-invariants-failure-modes.md) · [06](source/constitution/06-architecture-constitution.md) | **matérialisé** (Lot 3f : F2.1→F2.9, 100 %) |
| **F3 — Domaine** | [`source/domain/`](source/domain/) → [01](source/domain/01-tactical-building-blocks.md) · [02](source/domain/02-aggregates-customer-journey.md) · [03](source/domain/03-aggregates-identity-collaboration.md) · [04](source/domain/04-aggregates-platform-infrastructure.md) · [05](source/domain/05-grand-tactical-audit.md) · [06](source/domain/06-tactical-documentation-freeze.md) | **matérialisé** (Lot 4C : F3.1→F3.3, 100 %) |
| **F4 — Exécution** | [`source/application/`](source/application/) → [01](source/application/01-application-core-sequence.md) · [02](source/application/02-process-managers.md) · [03](source/application/03-circulation.md) · [04](source/application/04-infrastructure-composition-runtime.md) · [05](source/application/05-grand-application-audit.md) | **matérialisé** (Lot 5C : F4.1→F4.99, 100 %) |
| **F5 — Production** | [`source/production/`](source/production/) → [01](source/production/01-runtime.md) · [02](source/production/02-persistence.md) · [03](source/production/03-observability.md) · [04](source/production/04-security.md) · [05](source/production/05-reliability.md) · [06](source/production/06-scalability.md) · [07](source/production/07-operations.md) · [08](source/production/08-governance.md) · [09](source/production/09-grand-audit.md) | **matérialisé** (Lot 6E : F5.1→F5.99, 100 %) |

## Vérification (à matérialiser)

| Objet | Emplacement |
|-------|-------------|
| Audits `.99` (par Titre + Grand Audit F5.99) | [`verification/audits/`](verification/audits/) |
| Constitutional Diff, Vocabulary Diff | [`verification/diffs/`](verification/diffs/) |

## Projection (R2-Projections — en cours)

| Objet | Emplacement | Statut |
|-------|-------------|--------|
| Glossaire Officiel | [`projection/glossary/`](projection/glossary/) → [01](projection/glossary/01-official-glossary.md) | **projeté** (Lot 1) |
| Vocabulary Diff | [`projection/glossary/`](projection/glossary/) → [02](projection/glossary/02-vocabulary-diff.md) | **projeté** (Lot 2) |
| Handbook Officiel | [`projection/handbook/`](projection/handbook/) → [01](projection/handbook/01-official-handbook.md) | **projeté** (Lot 3) |
| Catalogues (12) | [`projection/catalogs/`](projection/catalogs/) → [01](projection/catalogs/01-events-catalog.md) · [02](projection/catalogs/02-commands-catalog.md) · [03](projection/catalogs/03-queries-catalog.md) · [04](projection/catalogs/04-policies-catalog.md) · [05](projection/catalogs/05-aggregates-catalog.md) · [06](projection/catalogs/06-projections-catalog.md) · [07](projection/catalogs/07-identities-catalog.md) · [08](projection/catalogs/08-state-machines-catalog.md) · [09](projection/catalogs/09-laws-catalog.md) · [10](projection/catalogs/10-theorems-catalog.md) · [11](projection/catalogs/11-proof-chains-catalog.md) · [12](projection/catalogs/12-anti-patterns-catalog.md) | **projeté** (Lot 4) |
| Index dérivés | [`projection/indexes/`](projection/indexes/) | à venir |

## Publication (Publication Package — R2-Projections Lot 5 — **CLOSE**)

> **Index officiel de la publication** : [Final Manifest](publication/00-final-manifest.md). Sceau : `9ea3d7ee760aaa4de71377e55d85004991bcefe8`.

| Objet | Emplacement | Statut |
|-------|-------------|--------|
| **Final Manifest** (index de la publication) | [`publication/00-final-manifest.md`](publication/00-final-manifest.md) | **projeté** (Lot 5D) |
| Rapports émis (**PCR-001**, …) | [`publication/reports/`](publication/reports/) | — |
| Canon Release | [`publication/releases/`](publication/releases/) → [01](publication/releases/01-canon-release.md) | **projeté** (Lot 5A) |
| Distribution Package (6 livres) | [`publication/packages/`](publication/packages/) → [01](publication/packages/01-foundation-book.md) · [02](publication/packages/02-constitution-book.md) · [03](publication/packages/03-domain-book.md) · [04](publication/packages/04-application-book.md) · [05](publication/packages/05-production-book.md) · [06](publication/packages/06-projection-book.md) | **projeté** (Lot 5B) |
| Compliance Package (6 rapports) | [`publication/reports/`](publication/reports/) → [01](publication/reports/01-publication-validation-report.md) · [02](publication/reports/02-integrity-report.md) · [03](publication/reports/03-coverage-report.md) · [04](publication/reports/04-traceability-report.md) · [05](publication/reports/05-projection-consistency-report.md) · [06](publication/reports/06-source-consistency-report.md) | **projeté** (Lot 5C) |
| Publication Freeze (5 docs) | [Certificate](publication/releases/02-publication-certificate.md) · [Signature](publication/releases/03-canon-signature.md) · [Stamp](publication/releases/04-release-stamp.md) · [Closure Report](publication/reports/07-publication-closure-report.md) · [Final Manifest](publication/00-final-manifest.md) | **projeté** (Lot 5D — CLOS) |
| Publication Freeze | [`publication/reports/`](publication/reports/) | à venir (Lot 5D) |

## Décisions

| Objet | Emplacement |
|-------|-------------|
| ADR | [`decisions/adr/`](decisions/adr/) |
| RFC | [`decisions/rfc/`](decisions/rfc/) |

## Transverse

| Objet | Emplacement |
|-------|-------------|
| Templates vides | [`templates/`](templates/) |
| Appendices | [`appendices/`](appendices/) |
| Assets | [`assets/`](assets/) |
| Historique | [`history/`](history/) |
