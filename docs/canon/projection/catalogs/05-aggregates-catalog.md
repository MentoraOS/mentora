---
doc: canon-catalog-05-aggregates
title: Catalogue des agrégats (Aggregates) — 30 unités
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F3.2-A/B/C — dessins des 30 agrégats — source/domain/02..04"
  - "F3.3 §2 — Aggregate Catalogue (30 unités, répartition) — source/domain/06-tactical-documentation-freeze.md"
note: >-
  INDEX exhaustif des 30 agrégats. Projection déterministe de la Source. Chaque
  entrée : nom · domaine · vérité incarnée (le détenteur du NON) · référence. La
  « vérité » est le libellé constitutionnel de l'unité, jamais un résumé du
  chapitre. Le compte 30 est dérivé (F3.3.99 : « 25 » → 30). Évolution : Titre VII.
---

# Catalogue des agrégats — 30 unités

**But.** Retrouver toute unité, son domaine et sa vérité. **Portée.** Les 30
agrégats (F3.3 §2). **Index seul** : les invariants, clés R-A, Factories et
Repositories restent dans la Source. Répartition (F3.3 §2) : Discovery 1 ·
Prof. Identity 3 · Engagement 1 · Consultation 2 · Reputation 4 · Account 4 ·
Enterprise 5 · Consent 1 · Messaging 1 · Economy 2 · Augmentation 1 · I&A 2 ·
Settlement 1 · Notification 1 · Storage 1.

| # | Aggregate | Domaine | Vérité incarnée (détenteur du NON) | Source |
|---|-----------|---------|-------------------------------------|--------|
| 1 | `ClientInterest` | Discovery | l'intérêt d'un client | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 2 | `ProfessionalIdentity` | Professional Identity | la parole d'un expert | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 3 | `Offer` | Professional Identity | une offre publiable | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 4 | `SpecialtyRegistry` | Professional Identity | le référentiel des spécialités | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 5 | `Agreement` | Engagement | l'accord d'un moment | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 6 | `Encounter` | Consultation | la rencontre | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 7 | `FollowUp` | Consultation | la suite d'une rencontre | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 8 | `Review` | Reputation | l'avis d'un auteur | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 9 | `CertificationRecord` | Reputation | une certification vérifiée | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 10 | `AchievementRecord` | Reputation | une réalisation constatée | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 11 | `AudienceMeasurement` | Reputation | une mesure d'audience (preuve) | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 12 | `Account` | Account | l'identité et les choix de la personne | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 13 | `AvailabilityFrame` | Account | le cadre de disponibilité | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 14 | `Subscription` | Account | l'abonnement | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 15 | `SupportRequest` | Account | la demande d'aide | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 16 | `Organization` | Enterprise | l'organisation | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 17 | `Invitation` | Enterprise | une invitation | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 18 | `Membership` | Enterprise | une appartenance | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 19 | `OrganizationVerification` | Enterprise | une vérification d'organisation (preuve) | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 20 | `Sponsorship` | Enterprise | un parrainage | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 21 | `ConsentLedger` | Consent | tout ce qu'une personne a accordé/refusé/retiré | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 22 | `Conversation` | Messaging | une conversation entre interlocuteurs | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 23 | `FundsLedger` | Expert Economy | les fonds d'un expert (singleton-par-acteur) | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 24 | `Goal` | Expert Economy | un objectif déclaré | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 25 | `Production` | Augmentation | ce que la machine a produit et avait le droit de produire | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 26 | `Credential` | Identity & Access | la preuve d'entrée | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 27 | `Session` | Identity & Access | une présence ouverte sur preuve | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 28 | `SettlementOrder` | Settlement | un ordre de règlement | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 29 | `Signal` | Notification | la livraison d'un signal remis | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 30 | `Deposit` | Storage | la garde d'un dépôt remis | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |

## Références

Dessins : [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) · [B](../../source/domain/03-aggregates-identity-collaboration.md) · [C](../../source/domain/04-aggregates-platform-infrastructure.md). Structure : [F3.3 §2](../../source/domain/06-tactical-documentation-freeze.md). Bloc `Aggregate` : [F3.1](../../source/domain/01-tactical-building-blocks.md).

## Notes

- Compte **30**, dérivé (F3.3.99 : « 25 » → 30). `Person` n'est pas un Aggregate (acteur) ; `AvailableFunds`, `Opportunity`, `TrustSignal` sont des **projections** (voir [Catalogue des projections](06-projections-catalog.md)) ; `PayoutRecord` est une **Entity** du `FundsLedger`. `Workspace` refusé comme unité (F3.2-B).
