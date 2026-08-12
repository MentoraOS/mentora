---
doc: canon-book-02-constitution
title: Constitution Book — assemblage documentaire (projection)
type: package
titre: canon
statut: "Projeté — R2-Projections Lot 5B (Distribution Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5B"
book_id: "book-constitution-1.0.0"
note: >-
  PROJECTION. Aucune autorité (N°41) ; aucune copie de contenu (N°43) ; ordre
  déterministe (N°44) ; identité documentaire (N°45). Régénération depuis la
  Source. Évolution : Titre VII.
---

# Constitution Book — `book-constitution-1.0.0`

> Assemblage du **Titre F2 — Constitution stratégique** avec le Glossaire officiel
> et le Vocabulary Diff. **Aucune autorité, aucun contenu** (N°41, N°43).

## Manifest

| Champ | Valeur |
|-------|--------|
| `BookId` | `book-constitution-1.0.0` |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Objet | assembler F2 + langage officiel pour la lecture |
| Nature | métadonnées d'assemblage |

## Table des matières (ordre déterministe)

1. F2.1 — Domain Landscape
2. F2.2 — Context Map
3. F2.3 — Ubiquitous Language, Responsibilities & Contracts
4. F2.5 — Bilingual Dictionary
5. F2.6 — Rules, Invariants & Failure Modes
6. F2.9 — Architecture Constitution (P1-P18)
7. Glossaire officiel
8. Vocabulary Diff

## Références (chapitres propriétaires)

- [F2.1](../../source/constitution/01-domain-landscape.md) · [F2.2](../../source/constitution/02-context-map.md) · [F2.3](../../source/constitution/03-language-responsibilities-contracts.md) · [F2.5](../../source/constitution/04-bilingual-dictionary.md) · [F2.6](../../source/constitution/05-rules-invariants-failure-modes.md) · [F2.9](../../source/constitution/06-architecture-constitution.md) — propriétaire : Conseil Constitutionnel.
- [Glossaire officiel](../../projection/glossary/01-official-glossary.md) · [Vocabulary Diff](../../projection/glossary/02-vocabulary-diff.md) — projections (index).

## Composition

| Rôle | Documents | Autorité |
|------|-----------|----------|
| Source | `source/constitution/01..06` (6 chapitres) | F2 (autorité) |
| Projection | `projection/glossary/01`, `projection/glossary/02` | dérivés |

## Dépendances

- **Source** : F2 (et F1 en amont, autorité). **Intégrité** : [Canon Release §7](../releases/01-canon-release.md).
- Le Glossaire projette F2.5 (propriétaire du vocabulaire) sans le dupliquer en autorité.

## Vérification

- Liens résolus ; cohérence lexicale : [Vocabulary Diff](../../projection/glossary/02-vocabulary-diff.md) ; rapports : *Lot 5C*.

## Intégrité

Empreintes : [Hash Manifest §7 de la Canon Release](../releases/01-canon-release.md). Ancre : `foundation-v1.0.0` (`8d095ee`).

## Reconstruction

Régénérable depuis `source/constitution/` + `projection/glossary/` (N°43), à l'identique (N°44).
