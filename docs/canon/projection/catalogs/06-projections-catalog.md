---
doc: canon-catalog-06-projections
title: Catalogue des projections
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F3.1 §Projection — types (Projection, Read Model, Vue, Snapshot, Cache) — source/domain/01-tactical-building-blocks.md"
  - "F2.5 §6 — Projection Dictionary (projections métier nommées) — source/constitution/04-bilingual-dictionary.md"
  - "F5.2/F5.3/F5.8 — projections d'exploitation & documentaires — source/production/02,03,08"
note: >-
  INDEX des projections. Projection déterministe de la Source. Chaque entrée :
  nom · famille · propriétaire/chapitre · référence. Toute projection est
  recalculable, datée, jamais persistée comme vérité, jamais source d'un refus
  d'acte (P3, S-4). Aucun contenu. Évolution : Titre VII.
---

# Catalogue des projections

**But.** Retrouver toute projection et sa famille. **Portée.** Les familles de
projections et les projections nommées. **Index seul.** Loi cardinale :
[P3](../../source/constitution/06-architecture-constitution.md) — *une projection
ne devient jamais un fait* ; [Checklist Projection](../../source/domain/06-tactical-documentation-freeze.md) (F3.3.99).

## A. Les familles (types — F3.1 §Projection)

| Famille | Est | Source |
|---------|-----|--------|
| **Projection** | dérivation déterministe de faits, recalculable, citée | [F3.1](../../source/domain/01-tactical-building-blocks.md) · [F2 Titre V](../../source/constitution/06-architecture-constitution.md) |
| **Read Model** | une Projection servie, formée pour un lecteur nommé | [F3.1](../../source/domain/01-tactical-building-blocks.md) |
| **Vue** | composition de surfaces (plusieurs Read Models) | [F3.1](../../source/domain/01-tactical-building-blocks.md) |
| **Snapshot** | photographie interne de reconstitution, privée au registre | [F3.1](../../source/domain/01-tactical-building-blocks.md) |
| **Cache** | copie périssable d'une Projection, datée, dite périmée (P17) | [F3.1](../../source/domain/01-tactical-building-blocks.md) |

## B. Projections métier nommées (F2.5 §6, F3.2)

| Projection | Domaine | Source |
|------------|---------|--------|
| `AgreementHonoredProjection` | Engagement | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `NoShowProjection` | Consultation | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `RevenueForecastProjection` | Expert Economy | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `AvailableFunds` | Expert Economy | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| `Opportunity` | Expert Economy | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| `TrustSignalProjection` | Reputation | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `PublicProfileProjection` | Professional Identity | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `CalendarProjection` | Account / Engagement | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `ProfileCompletionProjection` | Professional Identity | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| `FreeSlotsProjection` | Engagement | [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |

## C. Projections d'exploitation (F5)

| Projection | Propriétaire | Source |
|------------|--------------|--------|
| Read Models / vues d'exploitation (dashboards) | Observabilité | [F5.3 §7, O-8](../../source/production/03-observability.md) |
| Métriques, SLI/SLO, Error Budget | Observabilité | [F5.3 §3](../../source/production/03-observability.md) |
| Trace (ombre échantillonnable) | Observabilité | [F5.3 §4](../../source/production/03-observability.md) |
| Capacity (lecture physique), Forecast de coût | Observabilité / Scalabilité | [F5.3 §8](../../source/production/03-observability.md) · [F5.6 SC-7](../../source/production/06-scalability.md) |
| Projections datées mondiales (résidence) | Scalabilité | [F5.6 §3, SC-4](../../source/production/06-scalability.md) |

## D. Projections documentaires (le Corpus Canonique — F5.8)

| Projection documentaire | Propriétaire | Référence |
|-------------------------|--------------|-----------|
| Glossaire officiel | Gouvernance de Production | [glossary/01](../glossary/01-official-glossary.md) |
| Vocabulary Diff | Gouvernance de Production | [glossary/02](../glossary/02-vocabulary-diff.md) |
| Handbook officiel | Gouvernance de Production | [handbook/01](../handbook/01-official-handbook.md) |
| Catalogues (ce lot) | Gouvernance de Production | [catalogs/](.) |

## Références

[F3.1 §Projection](../../source/domain/01-tactical-building-blocks.md) · [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) · [P3](../../source/constitution/06-architecture-constitution.md) · [S-4](../../source/production/02-persistence.md) · [PG-6](../../source/production/08-governance.md).

## Notes

- Toute projection est **reconstructible** depuis la Source (S-4, PG-6) ; une projection sans chemin de reconstruction écrit est présumée propriétaire, donc illégale (S-4). La **Main courante** et l'**Incident** ne sont pas des projections : ce sont des **vérités d'exploitation** (registres) — voir [Catalogue des identités](07-identities-catalog.md).
