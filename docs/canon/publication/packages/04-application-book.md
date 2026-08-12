---
doc: canon-book-04-application
title: Application Book — assemblage documentaire (projection)
type: package
titre: canon
statut: "Projeté — R2-Projections Lot 5B (Distribution Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5B"
book_id: "book-application-1.0.0"
note: >-
  PROJECTION. Aucune autorité (N°41) ; aucune copie (N°43) ; ordre déterministe
  (N°44) ; identité documentaire (N°45). Régénération depuis la Source. Évolution :
  Titre VII.
---

# Application Book — `book-application-1.0.0`

> Assemblage du **Titre F4 — Exécution** avec le Handbook et les Catalogues
> d'application. **Aucune autorité, aucun contenu** (N°41, N°43).

## Manifest

| Champ | Valeur |
|-------|--------|
| `BookId` | `book-application-1.0.0` |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Objet | assembler F4 + Handbook + catalogues d'application |
| Nature | métadonnées d'assemblage |

## Table des matières (ordre déterministe)

1. F4.1 — Application Core & la Séquence de Commande
2. F4.2 — Process Managers
3. F4.3 — Circulation (Messaging, Event Bus, Integration)
4. F4.4 — Infrastructure, Composition Root & Runtime
5. F4.99 — Grand Application Audit
6. Handbook officiel
7. Catalogue des lois (section Application) & Anti-patterns (couche application)

## Références (chapitres propriétaires)

- [F4.1](../../source/application/01-application-core-sequence.md) · [F4.2](../../source/application/02-process-managers.md) · [F4.3](../../source/application/03-circulation.md) · [F4.4](../../source/application/04-infrastructure-composition-runtime.md) · [F4.99](../../source/application/05-grand-application-audit.md) — propriétaire : Conseil Constitutionnel.
- [Handbook officiel](../../projection/handbook/01-official-handbook.md) · [Catalogue des lois](../../projection/catalogs/09-laws-catalog.md) · [Anti-patterns](../../projection/catalogs/12-anti-patterns-catalog.md) — projections (index).

## Composition

| Rôle | Documents | Autorité |
|------|-----------|----------|
| Source | `source/application/01..05` (5 chapitres) | F4 (autorité) |
| Projection | `projection/handbook/01`, `projection/catalogs/09`, `projection/catalogs/12` | dérivés |

## Dépendances

- **Source** : F4 (F1/F2/F3 en amont). **Intégrité** : [Canon Release §7](../releases/01-canon-release.md). Le Handbook explique l'application des lois A/P/M/V/I sans les redéfinir.

## Vérification

- Liens résolus ; le Handbook renvoie à la Source ; rapports : *Lot 5C*.

## Intégrité

Empreintes : [Hash Manifest §7 de la Canon Release](../releases/01-canon-release.md). Ancre : `foundation-v1.0.0` (`8d095ee`).

## Reconstruction

Régénérable depuis `source/application/` + `projection/` (N°43), à l'identique (N°44).
