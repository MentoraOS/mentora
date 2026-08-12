---
doc: canon-book-01-foundation
title: Foundation Book — assemblage documentaire (projection)
type: package
titre: canon
statut: "Projeté — R2-Projections Lot 5B (Distribution Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5B"
book_id: "book-foundation-1.0.0"
note: >-
  PROJECTION. Un Livre ne possède aucune autorité (N°41) : il référence les
  chapitres propriétaires, il n'en recopie jamais le contenu (N°43). L'ordre des
  chapitres est déterministe (N°44). Identité purement documentaire (N°45).
  Régénération exclusivement depuis la Source. Évolution : Titre VII.
---

# Foundation Book — `book-foundation-1.0.0`

> Assemblage documentaire du **Titre F1 — Foundation** et de sa projection
> nécessaire. **Aucune autorité, aucun contenu** (N°41, N°43) : le Livre pointe.

## Manifest

| Champ | Valeur |
|-------|--------|
| `BookId` (identité documentaire) | `book-foundation-1.0.0` |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Objet | assembler F1 et les projections Foundation pour la lecture |
| Nature | métadonnées d'assemblage ; aucune loi, aucun terme, aucune architecture |

## Table des matières (ordre déterministe)

1. F1 — Foundation Constitution
2. Catalogue des lois (section Foundation)

## Références (chapitres propriétaires)

- [F1 — Foundation Constitution](../../source/foundation/01-foundation-constitution.md) — propriétaire : Conseil Constitutionnel.
- [Catalogue des lois §Foundation](../../projection/catalogs/09-laws-catalog.md) — projection (index).

## Composition

| Rôle | Document | Autorité |
|------|----------|----------|
| Source | `source/foundation/01-foundation-constitution.md` | F1 (autorité) |
| Projection | `projection/catalogs/09-laws-catalog.md` | index dérivé |

## Dépendances

- **Source** : F1 (autorité unique).
- **Intégrité** : [Canon Release — Hash Manifest §7](../releases/01-canon-release.md).
- Aucun autre Livre n'est requis pour lire celui-ci.

## Vérification

- Liens internes résolus (contrôle global du corpus).
- Cohérence lexicale : [Vocabulary Diff](../../projection/glossary/02-vocabulary-diff.md).
- Rapports automatiques : *Compliance Package (Lot 5C)*.

## Intégrité

Empreintes **content-derived** des documents composés : voir le
[Hash Manifest §7 de la Canon Release](../releases/01-canon-release.md) (SHA-1 de
blob git). Ancre : baseline immuable `foundation-v1.0.0` (`8d095ee`).

## Reconstruction

Régénérable **exclusivement depuis la Source** (N°43) : supprimez ce Livre,
régénérez-le depuis `source/foundation/` + `projection/` — résultat identique
(N°44). Le Livre ne détient aucune copie indépendante.
