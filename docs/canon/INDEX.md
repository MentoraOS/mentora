---
doc: canon-index
title: Index canonique
type: apparatus
titre: canon
statut: "R2-Corpus Lot 6C — F1, F2, F3, F4 matérialisés (100 %) ; F5 en cours (F5.1→F5.6 faits)"
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

## Source — le Corpus Canonique (à matérialiser)

| Titre | Emplacement | Statut Lot 1 |
|-------|-------------|--------------|
| **F1 — Foundation** | [`source/foundation/`](source/foundation/) → [01-foundation-constitution.md](source/foundation/01-foundation-constitution.md) | **matérialisé** (Lot 2, verbatim) |
| **F2 — Constitution** | [`source/constitution/`](source/constitution/) → [01](source/constitution/01-domain-landscape.md) · [02](source/constitution/02-context-map.md) · [03](source/constitution/03-language-responsibilities-contracts.md) · [04](source/constitution/04-bilingual-dictionary.md) · [05](source/constitution/05-rules-invariants-failure-modes.md) · [06](source/constitution/06-architecture-constitution.md) | **matérialisé** (Lot 3f : F2.1→F2.9, 100 %) |
| **F3 — Domaine** | [`source/domain/`](source/domain/) → [01](source/domain/01-tactical-building-blocks.md) · [02](source/domain/02-aggregates-customer-journey.md) · [03](source/domain/03-aggregates-identity-collaboration.md) · [04](source/domain/04-aggregates-platform-infrastructure.md) · [05](source/domain/05-grand-tactical-audit.md) · [06](source/domain/06-tactical-documentation-freeze.md) | **matérialisé** (Lot 4C : F3.1→F3.3, 100 %) |
| **F4 — Exécution** | [`source/application/`](source/application/) → [01](source/application/01-application-core-sequence.md) · [02](source/application/02-process-managers.md) · [03](source/application/03-circulation.md) · [04](source/application/04-infrastructure-composition-runtime.md) · [05](source/application/05-grand-application-audit.md) | **matérialisé** (Lot 5C : F4.1→F4.99, 100 %) |
| **F5 — Production** | [`source/production/`](source/production/) → [01](source/production/01-runtime.md) · [02](source/production/02-persistence.md) · [03](source/production/03-observability.md) · [04](source/production/04-security.md) · [05](source/production/05-reliability.md) · [06](source/production/06-scalability.md) | **en cours** (Lot 6C : F5.1→F5.6 faits) |

## Vérification (à matérialiser)

| Objet | Emplacement |
|-------|-------------|
| Audits `.99` (par Titre + Grand Audit F5.99) | [`verification/audits/`](verification/audits/) |
| Constitutional Diff, Vocabulary Diff | [`verification/diffs/`](verification/diffs/) |

## Projection (à matérialiser — Lots ultérieurs)

| Objet | Emplacement |
|-------|-------------|
| Glossaire Officiel | [`projection/glossary/`](projection/glossary/) |
| Handbook Officiel | [`projection/handbook/`](projection/handbook/) |
| Catalogues | [`projection/catalogs/`](projection/catalogs/) |
| Index dérivés | [`projection/indexes/`](projection/indexes/) |

## Publication

| Objet | Emplacement |
|-------|-------------|
| Rapports émis (**PCR-001**, …) | [`publication/reports/`](publication/reports/) |
| Releases | [`publication/releases/`](publication/releases/) |
| Packages (Production Closure Package, …) | [`publication/packages/`](publication/packages/) |

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
