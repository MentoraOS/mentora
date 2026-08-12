---
doc: canon-catalog-02-commands
title: Catalogue des commandes (Commands) — 79 commandes
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F2.5 §5 — Command Dictionary — source/constitution/04-bilingual-dictionary.md"
  - "F3.2-A/B/C — dessins des agrégats (commandes par unité) — source/domain/02..04"
  - "F3.3 §4 — Command Catalogue (compte autoritaire 79, actes sans fait publié) — source/domain/06-tactical-documentation-freeze.md"
note: >-
  INDEX exhaustif des 79 commandes. Projection déterministe de la Source ; aucune
  commande créée. Chaque entrée : nom · domaine propriétaire · aggregate visé ·
  référence. Aucun contenu. Le compte 79 est DÉRIVÉ (F3.3.99 : « 52 » → 79). Les
  commandes déclenchées par le temps (Lapse/Elapse/Expire) et les transitions
  suivent la règle « article des mutations » (F3.1.99 : toute transition est une
  commande nommée) — projetées, jamais inventées. Évolution : Titre VII.
---

# Catalogue des commandes — 79 Commands

**But.** Retrouver toute commande et l'aggregate qu'elle vise. **Portée.** Les 79
commandes (F3.3 §4). **Index seul** : le contrat de chaque commande (Decision,
Reason, préconditions) reste dans la Source. Énumération : [F2.5 §5](../../source/constitution/04-bilingual-dictionary.md) + dessins [02](../../source/domain/02-aggregates-customer-journey.md)/[03](../../source/domain/03-aggregates-identity-collaboration.md)/[04](../../source/domain/04-aggregates-platform-infrastructure.md) + [F3.3 §4](../../source/domain/06-tactical-documentation-freeze.md).

| # | Commande | Domaine | Aggregate visé | Source |
|---|----------|---------|----------------|--------|
| 1 | `AddFavorite` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 2 | `RemoveFavorite` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 3 | `ExpressInterest` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 4 | `KeepSuggestion` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 5 | `DismissSuggestion` | Discovery | `ClientInterest` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 6 | `DeclareExpertise` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 7 | `DeclareExperience` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 8 | `UpdatePortfolio` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 9 | `PublishMasterclassContent` | Professional Identity | `ProfessionalIdentity` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 10 | `PublishOffer` | Professional Identity | `Offer` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 11 | `UnpublishOffer` | Professional Identity | `Offer` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 12 | `AdmitSpecialty` | Professional Identity | `SpecialtyRegistry` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 13 | `DeprecateSpecialty` | Professional Identity | `SpecialtyRegistry` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 14 | `RequestAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 15 | `AcceptAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 16 | `RejectAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 17 | `ConfirmAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 18 | `RescheduleAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 19 | `CancelAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 20 | `LapseAgreementRequest` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 21 | `ElapseAgreement` | Engagement | `Agreement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 22 | `PrepareEncounter` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 23 | `OpenEncounter` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 24 | `SubmitArtifact` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 25 | `CloseEncounter` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 26 | `InterruptEncounter` | Consultation | `Encounter` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 27 | `OpenFollowUp` | Consultation | `FollowUp` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 28 | `HandleFollowUp` | Consultation | `FollowUp` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 29 | `PublishReview` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 30 | `ReplyToReview` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 31 | `ReportReview` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 32 | `RenderVerdict` | Reputation | `Review` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 33 | `VerifyCertification` | Reputation | `CertificationRecord` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 34 | `RecordAchievement` | Reputation | `AchievementRecord` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 35 | `RecordAudienceMeasurement` | Reputation | `AudienceMeasurement` | [F3.2-A](../../source/domain/02-aggregates-customer-journey.md) |
| 36 | `RegisterPerson` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 37 | `ChangePreference` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 38 | `ChangeReachability` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 39 | `RegisterDevice` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 40 | `RemoveDevice` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 41 | `CloseAccount` | Account | `Account` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 42 | `ChangeAvailabilityFrame` | Account | `AvailabilityFrame` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 43 | `StartSubscription` | Account | `Subscription` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 44 | `EndSubscription` | Account | `Subscription` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 45 | `OpenSupportRequest` | Account | `SupportRequest` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 46 | `HandleSupportRequest` | Account | `SupportRequest` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 47 | `CreateOrganization` | Enterprise | `Organization` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 48 | `IssueInvitation` | Enterprise | `Invitation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 49 | `AcceptInvitation` | Enterprise | `Invitation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 50 | `DeclineInvitation` | Enterprise | `Invitation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 51 | `RevokeMembership` | Enterprise | `Membership` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 52 | `GrantSponsorship` | Enterprise | `Sponsorship` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 53 | `RevokeSponsorship` | Enterprise | `Sponsorship` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 54 | `VerifyOrganization` | Enterprise | `OrganizationVerification` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 55 | `GrantConsent` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 56 | `RefuseConsent` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 57 | `WithdrawConsent` | Consent | `ConsentLedger` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 58 | `InvalidateConsent` | Consent | `ConsentLedger` (Custodian) | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 59 | `ExpireConsent` | Consent | `ConsentLedger` (temps) | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 60 | `OpenConversation` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 61 | `SubmitMessage` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 62 | `CloseConversation` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 63 | `ReportConversation` | Messaging | `Conversation` | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 64 | `RenderConversationVerdict` | Messaging | `Conversation` (Custodian) | [F3.2-B](../../source/domain/03-aggregates-identity-collaboration.md) |
| 65 | `RecognizeRevenue` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 66 | `AdjustRevenue` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 67 | `RequestPayout` | Expert Economy | `FundsLedger` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 68 | `DeclareGoal` | Expert Economy | `Goal` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 69 | `RequestProduction` | Augmentation | `Production` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 70 | `EstablishCredential` | Identity & Access | `Credential` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 71 | `RevokeCredential` | Identity & Access | `Credential` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 72 | `OpenSession` | Identity & Access | `Session` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 73 | `EndSession` | Identity & Access | `Session` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 74 | `RevokeSession` | Identity & Access | `Session` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 75 | `ExecuteSettlementOrder` | Settlement | `SettlementOrder` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 76 | `DeliverSignal` | Notification | `Signal` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 77 | `StoreDeposit` | Storage | `Deposit` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 78 | `ReturnDeposit` | Storage | `Deposit` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |
| 79 | `DestroyDeposit` | Storage | `Deposit` | [F3.2-C](../../source/domain/04-aggregates-platform-infrastructure.md) |

## Références

[F2.5 §5](../../source/constitution/04-bilingual-dictionary.md) · [F3.3 §4](../../source/domain/06-tactical-documentation-freeze.md) · dessins [02](../../source/domain/02-aggregates-customer-journey.md)/[03](../../source/domain/03-aggregates-identity-collaboration.md)/[04](../../source/domain/04-aggregates-platform-infrastructure.md). Vocabulaire : [Glossaire](../glossary/01-official-glossary.md).

## Notes

- Compte **79**, dérivé (F3.3.99 : « 52 » → 79 ; `ExpressSearch` supprimée). Aucune commande CRUD n'existe.
- Commandes déclenchées par le temps (`LapseAgreementRequest`, `ElapseAgreement`, `ExpireConsent`) : outillage du temps, instant fourni en donnée (F4.1 §4).
- Commandes de transition sans fait publié (Session `Open/End/Revoke`, `OpenSupportRequest`/`HandleSupportRequest`) : projetées par la règle « article des mutations » (F3.1.99 §3 : *toute transition est une commande nommée*) et le nommage `<Verb><Truth>` (F2.5 §9) — jamais inventées.
- Reasons (refus) : voir [F2.5 §20](../../source/constitution/04-bilingual-dictionary.md) + `TimeSlotUnavailable`, `MembershipAlreadyExists`, `RetentionActive` (F3.3 §4).
