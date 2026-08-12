---
doc: canon-catalog-01-events
title: Catalogue des faits métier (Domain Events) — 73 faits
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F2.5 §4 — Event Dictionary (énumération exhaustive des 73 faits) — source/constitution/04-bilingual-dictionary.md"
  - "F3.2-A/B/C — dessins des agrégats propriétaires — source/domain/02..04"
  - "F3.3 §3 — Event Catalogue (structure, comptes autoritaires) — source/domain/06-tactical-documentation-freeze.md"
note: >-
  INDEX exhaustif des 73 faits métier. Projection déterministe de la Source ; il
  ne crée aucun fait, il pointe vers son propriétaire. Chaque entrée : nom · domaine
  propriétaire · aggregate propriétaire · référence canonique. Aucun contenu, aucune
  interprétation, aucun résumé. Le compte 73 est DÉRIVÉ de l'énumération (F3.3 :
  le catalogue fait foi, jamais le chiffre). Évolution : Titre VII.
---

# Catalogue des faits métier — 73 Domain Events

**But.** Retrouver immédiatement n'importe quel fait métier, son domaine et son
aggregate propriétaire. **Portée.** Les 73 faits gelés (F2.5 §4). **Ce catalogue
indexe ; il ne recopie pas** — le contenu et la grammaire des faits restent dans la
Source. Propriétaire de l'énumération : [F2.5 §4](../../source/constitution/04-bilingual-dictionary.md) ; dessins : [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) · [B](../../source/domain/03-aggregates-identity-collaboration.md) · [C](../../source/domain/04-aggregates-platform-infrastructure.md).

| # | Fait | Domaine | Aggregate propriétaire | Source |
|---|------|---------|------------------------|--------|
| 1 | `FavoriteAdded` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 2 | `FavoriteRemoved` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 3 | `InterestExpressed` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 4 | `SuggestionKept` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 5 | `SuggestionDismissed` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 6 | `ExpertiseDeclared` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 7 | `ExperienceDeclared` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 8 | `PortfolioUpdated` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 9 | `MasterclassContentPublished` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 10 | `OfferPublished` | Professional Identity | `Offer` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 11 | `OfferUnpublished` | Professional Identity | `Offer` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 12 | `AgreementRequested` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 13 | `AgreementAccepted` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 14 | `AgreementRejected` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 15 | `AgreementRequestLapsed` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 16 | `AgreementConfirmed` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 17 | `AgreementRescheduled` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 18 | `AgreementCancelled` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 19 | `AgreementElapsed` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 20 | `EncounterPrepared` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 21 | `EncounterOpened` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 22 | `EncounterClosed` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 23 | `EncounterInterrupted` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 24 | `ArtifactSubmitted` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 25 | `FollowUpOpened` | Consultation | `FollowUp` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 26 | `FollowUpHandled` | Consultation | `FollowUp` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 27 | `ReviewPublished` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 28 | `ReviewReplyPublished` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 29 | `ReviewReported` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 30 | `VerdictRendered` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 31 | `CertificationVerified` | Reputation | `CertificationRecord` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 32 | `AchievementRecorded` | Reputation | `AchievementRecord` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 33 | `RevenueRecognized` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 34 | `RevenueAdjusted` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 35 | `PayoutRequested` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 36 | `PayoutCompleted` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 37 | `PayoutFailed` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 38 | `GoalDeclared` | Expert Economy | `Goal` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 39 | `ProductionDelivered` | Augmentation | `Production` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 40 | `PersonRegistered` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 41 | `AccountClosed` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 42 | `PreferenceChanged` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 43 | `ReachabilityChanged` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 44 | `AvailabilityFrameChanged` | Account | `AvailabilityFrame` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 45 | `SubscriptionStarted` | Account | `Subscription` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 46 | `SubscriptionEnded` | Account | `Subscription` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 47 | `OrganizationCreated` | Enterprise | `Organization` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 48 | `InvitationIssued` | Enterprise | `Invitation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 49 | `InvitationAccepted` | Enterprise | `Invitation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 50 | `InvitationDeclined` | Enterprise | `Invitation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 51 | `MembershipRevoked` | Enterprise | `Membership` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 52 | `SponsorshipGranted` | Enterprise | `Sponsorship` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 53 | `SponsorshipRevoked` | Enterprise | `Sponsorship` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 54 | `OrganizationVerified` | Enterprise | `OrganizationVerification` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 55 | `ConsentGranted` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 56 | `ConsentRefused` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 57 | `ConsentWithdrawn` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 58 | `ConsentExpired` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 59 | `ConsentInvalidated` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 60 | `ConversationOpened` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 61 | `MessageSubmitted` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 62 | `ConversationClosed` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 63 | `ConversationReported` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 64 | `ConversationVerdictRendered` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 65 | `CredentialEstablished` | Identity & Access | `Credential` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 66 | `CredentialRevoked` | Identity & Access | `Credential` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 67 | `SettlementOrderExecuted` | Settlement | `SettlementOrder` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 68 | `SettlementOrderFailed` | Settlement | `SettlementOrder` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 69 | `SignalDelivered` | Notification | `Signal` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 70 | `SignalUndeliverable` | Notification | `Signal` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 71 | `DepositStored` | Storage | `Deposit` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 72 | `DepositReturned` | Storage | `Deposit` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 73 | `DepositDestroyed` | Storage | `Deposit` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |

## Références

Énumération : [F2.5 §4](../../source/constitution/04-bilingual-dictionary.md). Structure & comptes : [F3.3 §3](../../source/domain/06-tactical-documentation-freeze.md). Vocabulaire : [Glossaire](../glossary/01-official-glossary.md).

## Notes

- Compte **73**, dérivé de l'énumération (F3.3.99 : « 58 » → 73 ; le catalogue fait foi, jamais le chiffre).
- `AudienceMeasurement` (Reputation) est un registre de preuve **sans fait publié** (F3.2-A) — il n'a donc pas d'entrée ici. Les transitions d'états ne figurent pas ici : voir le [Catalogue des machines d'états](08-state-machines-catalog.md).
