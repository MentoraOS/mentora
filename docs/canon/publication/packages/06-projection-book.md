---
doc: canon-book-06-projection
title: Projection Book — assemblage documentaire (projection)
type: package
titre: canon
statut: "Projeté — R2-Projections Lot 5B (Distribution Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5B"
book_id: "book-projection-1.0.0"
note: >-
  PROJECTION de projections. Aucune autorité (N°41) ; aucune copie de leur contenu
  (N°43) ; ordre déterministe (N°44) ; identité documentaire (N°45). Toutes les
  pièces dérivent de la Source. Évolution : Titre VII.
---

# Projection Book — `book-projection-1.0.0`

> Assemblage des **projections officielles** : Glossaire, Vocabulary Diff,
> Handbook, Catalogues, Canon Release — **sans recopier leur contenu** (N°43).
> Aucune Source ici : toutes les pièces sont dérivées.

## Manifest

| Champ | Valeur |
|-------|--------|
| `BookId` | `book-projection-1.0.0` |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Objet | rassembler les projections pour la lecture |
| Nature | métadonnées d'assemblage ; aucune Source, aucun contenu |

## Table des matières (ordre déterministe)

1. Glossaire officiel
2. Vocabulary Diff
3. Handbook officiel
4. Catalogues (01 → 12)
5. Canon Release

## Références (documents projetés)

- [Glossaire officiel](../../projection/glossary/01-official-glossary.md) · [Vocabulary Diff](../../projection/glossary/02-vocabulary-diff.md) · [Handbook officiel](../../projection/handbook/01-official-handbook.md).
- Catalogues : [01](../../projection/catalogs/01-events-catalog.md) · [02](../../projection/catalogs/02-commands-catalog.md) · [03](../../projection/catalogs/03-queries-catalog.md) · [04](../../projection/catalogs/04-policies-catalog.md) · [05](../../projection/catalogs/05-aggregates-catalog.md) · [06](../../projection/catalogs/06-projections-catalog.md) · [07](../../projection/catalogs/07-identities-catalog.md) · [08](../../projection/catalogs/08-state-machines-catalog.md) · [09](../../projection/catalogs/09-laws-catalog.md) · [10](../../projection/catalogs/10-theorems-catalog.md) · [11](../../projection/catalogs/11-proof-chains-catalog.md) · [12](../../projection/catalogs/12-anti-patterns-catalog.md).
- [Canon Release](../releases/01-canon-release.md).

*Propriétaire de chaque projection : la Gouvernance de Production (F5.8) ; l'autorité constitutionnelle demeure la Source (N°41).*

## Composition

| Rôle | Documents |
|------|-----------|
| Projection | `projection/glossary/01,02`, `projection/handbook/01`, `projection/catalogs/01..12` |
| Release | `publication/releases/01-canon-release.md` |

## Dépendances

- **Source** : F1→F5 (autorité indirecte — chaque projection en dérive). **Intégrité** : [Canon Release §7](../releases/01-canon-release.md).

## Vérification

- Liens résolus ; cohérence lexicale : [Vocabulary Diff](../../projection/glossary/02-vocabulary-diff.md) ; rapports : *Lot 5C*.

## Intégrité

Empreintes : [Hash Manifest §7 de la Canon Release](../releases/01-canon-release.md). Ancre : `foundation-v1.0.0` (`8d095ee`).

## Reconstruction

Toutes les pièces sont **entièrement dérivables** de la Source (N°40) ; supprimez
`projection/` + `publication/`, régénérez depuis `source/` — résultat identique
(N°43, N°44).
