---
doc: canon-book-03-domain
title: Domain Book — assemblage documentaire (projection)
type: package
titre: canon
statut: "Projeté — R2-Projections Lot 5B (Distribution Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5B"
book_id: "book-domain-1.0.0"
note: >-
  PROJECTION. Aucune autorité (N°41) ; aucune copie (N°43) ; ordre déterministe
  (N°44) ; identité documentaire (N°45). Régénération depuis la Source. Évolution :
  Titre VII.
---

# Domain Book — `book-domain-1.0.0`

> Assemblage du **Titre F3 — Domaine tactique** avec les Catalogues du domaine.
> **Aucune autorité, aucun contenu** (N°41, N°43).

## Manifest

| Champ | Valeur |
|-------|--------|
| `BookId` | `book-domain-1.0.0` |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Objet | assembler F3 + catalogues du domaine |
| Nature | métadonnées d'assemblage |

## Table des matières (ordre déterministe)

1. F3.1 — Tactical Building Blocks
2. F3.2-A — Aggregates, Customer Journey
3. F3.2-B — Aggregates, Identity & Collaboration
4. F3.2-C — Aggregates, Platform & Infrastructure
5. F3.2.99 — Grand Tactical Audit
6. F3.3 — Tactical Documentation Freeze
7. Catalogues du domaine (Events, Commands, Queries, Policies, Aggregates, Projections, Identities, State Machines)

## Références (chapitres propriétaires)

- [F3.1](../../source/domain/01-tactical-building-blocks.md) · [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) · [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) · [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) · [F3.2.99](../../source/domain/05-grand-tactical-audit.md) · [F3.3](../../source/domain/06-tactical-documentation-freeze.md) — propriétaire : Conseil Constitutionnel.
- Catalogues : [01](../../projection/catalogs/01-events-catalog.md) · [02](../../projection/catalogs/02-commands-catalog.md) · [03](../../projection/catalogs/03-queries-catalog.md) · [04](../../projection/catalogs/04-policies-catalog.md) · [05](../../projection/catalogs/05-aggregates-catalog.md) · [06](../../projection/catalogs/06-projections-catalog.md) · [07](../../projection/catalogs/07-identities-catalog.md) · [08](../../projection/catalogs/08-state-machines-catalog.md) — projections (index).

## Composition

| Rôle | Documents | Autorité |
|------|-----------|----------|
| Source | `source/domain/01..06` (6 chapitres) | F3 (autorité) |
| Projection | `projection/catalogs/01..08` | dérivés |

## Dépendances

- **Source** : F3 (F1/F2 en amont). **Intégrité** : [Canon Release §7](../releases/01-canon-release.md). Les catalogues indexent F3 sans le dupliquer.

## Vérification

- Liens résolus ; catalogues à comptes dérivés (F3.3) ; rapports : *Lot 5C*.

## Intégrité

Empreintes : [Hash Manifest §7 de la Canon Release](../releases/01-canon-release.md). Ancre : `foundation-v1.0.0` (`8d095ee`).

## Reconstruction

Régénérable depuis `source/domain/` + `projection/catalogs/` (N°43), à l'identique (N°44).
