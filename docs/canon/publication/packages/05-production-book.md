---
doc: canon-book-05-production
title: Production Book — assemblage documentaire (projection)
type: package
titre: canon
statut: "Projeté — R2-Projections Lot 5B (Distribution Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5B"
book_id: "book-production-1.0.0"
note: >-
  PROJECTION. Aucune autorité (N°41) ; aucune copie (N°43) ; ordre déterministe
  (N°44) ; identité documentaire (N°45). Régénération depuis la Source. Évolution :
  Titre VII.
---

# Production Book — `book-production-1.0.0`

> Assemblage du **Titre F5 — Production** avec les Catalogues de production et la
> Canon Release. **Aucune autorité, aucun contenu** (N°41, N°43).

## Manifest

| Champ | Valeur |
|-------|--------|
| `BookId` | `book-production-1.0.0` |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Objet | assembler F5 + catalogues de production + Canon Release |
| Nature | métadonnées d'assemblage |

## Table des matières (ordre déterministe)

1. F5.1 — Runtime · 2. F5.2 — Persistence · 3. F5.3 — Observability · 4. F5.4 — Security · 5. F5.5 — Reliability · 6. F5.6 — Scalability · 7. F5.7 — Operations · 8. F5.8 — Governance · 9. F5.99 — Grand Audit
10. Catalogues de production (Lois, Théorèmes, Chaînes de preuve, Identités, Anti-patterns)
11. Canon Release

## Références (chapitres propriétaires)

- [F5.1](../../source/production/01-runtime.md) · [F5.2](../../source/production/02-persistence.md) · [F5.3](../../source/production/03-observability.md) · [F5.4](../../source/production/04-security.md) · [F5.5](../../source/production/05-reliability.md) · [F5.6](../../source/production/06-scalability.md) · [F5.7](../../source/production/07-operations.md) · [F5.8](../../source/production/08-governance.md) · [F5.99](../../source/production/09-grand-audit.md) — propriétaire : Conseil Constitutionnel.
- [Lois](../../projection/catalogs/09-laws-catalog.md) · [Théorèmes](../../projection/catalogs/10-theorems-catalog.md) · [Chaînes de preuve](../../projection/catalogs/11-proof-chains-catalog.md) · [Identités](../../projection/catalogs/07-identities-catalog.md) · [Anti-patterns](../../projection/catalogs/12-anti-patterns-catalog.md) — projections.
- [Canon Release](../releases/01-canon-release.md) — métadonnées de publication.

## Composition

| Rôle | Documents | Autorité |
|------|-----------|----------|
| Source | `source/production/01..09` (9 chapitres) | F5 (autorité) |
| Projection | `projection/catalogs/07,09,10,11,12` | dérivés |
| Release | `publication/releases/01-canon-release.md` | métadonnées |

## Dépendances

- **Source** : F5 (F1→F4 en amont). **Intégrité** : [Canon Release §7](../releases/01-canon-release.md). Les catalogues indexent les lois R/S/O/T/RY/SC/OP/PG et les théorèmes sans en porter le contenu.

## Vérification

- Liens résolus ; le Grand Audit F5.99 clôt F1→F5 ; rapports : *Lot 5C*.

## Intégrité

Empreintes : [Hash Manifest §7 de la Canon Release](../releases/01-canon-release.md). Ancre : `foundation-v1.0.0` (`8d095ee`).

## Reconstruction

Régénérable depuis `source/production/` + `projection/` + `publication/releases/` (N°43), à l'identique (N°44).
