---
doc: canon-index
title: Index canonique
type: apparatus
titre: canon
statut: "R2-Corpus Lot 3e — F1 fait ; F2 en cours (…F2.6-8 faits ; reste F2.9) ; F3→F5 en attente"
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
| **F2 — Constitution** | [`source/constitution/`](source/constitution/) → [01](source/constitution/01-domain-landscape.md) · [02](source/constitution/02-context-map.md) · [03](source/constitution/03-language-responsibilities-contracts.md) · [04](source/constitution/04-bilingual-dictionary.md) · [05](source/constitution/05-rules-invariants-failure-modes.md) | **en cours** (Lot 3e : …F2.6-8 faits) |
| **F3 — Domaine** | [`source/domain/`](source/domain/) | contenant vide |
| **F4 — Exécution** | [`source/application/`](source/application/) | contenant vide |
| **F5 — Production** | [`source/production/`](source/production/) | contenant vide |

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
