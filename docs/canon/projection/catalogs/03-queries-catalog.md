---
doc: canon-catalog-03-queries
title: Catalogue des requêtes (Queries) — 11 lectures (R-C)
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F3.3 §5 — Query Catalogue (R-C : chaque ligne nomme l'ayant droit) — source/domain/06-tactical-documentation-freeze.md"
  - "F2.5 §6 — Query Dictionary — source/constitution/04-bilingual-dictionary.md"
note: >-
  INDEX exhaustif des 11 lectures. Projection déterministe de la Source. Chaque
  entrée : nom · ayant droit (R-C) · référence. Aucun contenu. Le compte 11 est
  dérivé (F3.3.99 : « 9 » → 11). Toute lecture nomme son ayant droit (R-C) ; une
  lecture sans droit est refusée, motivée. Évolution : Titre VII.
---

# Catalogue des requêtes — 11 Queries (R-C)

**But.** Retrouver toute lecture publiée et son ayant droit. **Portée.** Les 11
lectures (F3.3 §5). **Index seul.** Loi : [R-C](../../source/domain/06-tactical-documentation-freeze.md) — toute Query nomme son ayant droit.

| # | Query | Ayant droit (propriétaire de la lecture) | Source |
|---|-------|------------------------------------------|--------|
| 1 | `ConsentValidityQuery` | tout domaine agissant, pour son propre acte | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 2 | `AgreementStateQuery` | les parties, l'outillage du temps | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 3 | `EncounterStateQuery` | les participants | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 4 | `AvailabilityFrameQuery` | tous (cadre publié) | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 5 | `AvailableFundsQuery` | le Titulaire + conformité | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 6 | `SpecialtyRegistryQuery` | tous | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 7 | `OfferQuery` (offres publiées) | tous | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) · [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) |
| 8 | `PublicProfileQuery` (profils assemblés) | tous | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 9 | `MembershipQuery` | l'Organisation et le Membre | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 10 | `ReachabilityQuery` | la Notification (sanctionnée) + le Titulaire | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |
| 11 | `ConversationQuery` | l'Interlocuteur seul | [F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) |

## Références

[F3.3 §5](../../source/domain/06-tactical-documentation-freeze.md) · [F2.5 §6](../../source/constitution/04-bilingual-dictionary.md) · loi [R-C](../../source/domain/06-tactical-documentation-freeze.md).

## Notes

- Compte **11**, dérivé (F3.3.99 §2 : la ligne groupée « offres publiées / profils assemblés » cachait des lectures). Les **validités** (pas 5 de la Séquence) interrogent la **source**, jamais un Read Model (cache de validité interdit — [A-8](../../source/application/01-application-core-sequence.md), Titre VI).
