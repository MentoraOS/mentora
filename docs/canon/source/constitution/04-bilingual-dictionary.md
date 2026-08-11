---
doc: f2-04-bilingual-dictionary
title: F2.5.1 + F2.5.2 — Bilingual Architecture Dictionary (FR ↔ EN) — Constitution de la Langue v1.1.0
type: source
titre: constitution
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 3d)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora (Conseil Linguistique)
materialise_par: "R2-Corpus Lot 3d"
sources_session:
  - "F2.5.1 — Bilingual Architecture Dictionary (FR↔EN), Constitution de la Langue v1.0.0 (dictionnaire par domaine, événements, commandes, requêtes, projections, policies, acteurs, types, naming constitution, vocabulaire interdit, 8 réservations de domaine)"
  - "F2.5.2 — Final Constitutional Review (amendements : Denied ; RetentionActive ; AgreementRequestLapsePolicy ; clarification des Domain Services qualifiés — Constitution de la Langue v1.1.0)"
note: >-
  Reconstruction fidèle de l'état final ratifié (Dictionary v1.1.0). Ce chapitre
  est le PROPRIÉTAIRE OFFICIEL du vocabulaire constitutionnel bilingue et des
  termes réservés : les autres chapitres le référencent sans le dupliquer.
  F2.5.1 est le corps du dictionnaire ; F2.5.2 y applique quatre corrections
  (intégrées ci-dessous et signalées). Les amendements §15.1 de F2.5.1
  (Lapsed/Elapsed) sont ratifiés. Scaffolding de session exclu. Titre VII de
  F2.9 pour toute évolution — toute nouvelle traduction est une révision
  constitutionnelle.
---

# F2.5.1 + F2.5.2 — Bilingual Architecture Dictionary (FR ↔ EN)

> **Constitution de la Langue v1.1.0.** Propriétaire officiel du vocabulaire.
> Le métier parle français ; le code parle anglais ; le dictionnaire est le
> pont unique. Toute traduction improvisée est une violation.

## 1. Principes constitutionnels

- **P1 — Un concept, une traduction.** Deux traductions = deux vocabulaires = dérive certaine à 200 développeurs ; le glossaire tranche, une fois.
- **P2 — Jamais de synonyme.** `Agreement` ne deviendra jamais Booking/Reservation/Appointment : le synonyme est la porte du legacy.
- **P3 — Les mots legacy meurent à la frontière.** L'ACL est linguistique (loi 13) ; on traduit, on n'adopte pas.
- **P4 — Le code dérive du dictionnaire.** Toute traduction improvisée est une violation, détectable en revue par simple absence du glossaire.
- **P5 — Toute modification est une révision constitutionnelle** (Titre VII).
- **P6 — API, Events, Commands, Queries, Policies, ACL, Tests parlent le dictionnaire.** Un test qui parle un autre mot teste un autre produit.

## 2. Format officiel (le gabarit vaut pour toute entrée)

**Accord** → **Agreement** · *Domaine* : Engagement · *Définition* : l'accord d'un moment entre un Client et un Expert, de la demande à l'échéance · *Pourquoi* : « agreement » dit la promesse mutuelle — Booking dit un mécanisme, Appointment un calendrier, Reservation un parcours · *Synonymes interdits* : Booking, Reservation, Appointment, Meeting · *Faux amis détruits* : Confirmed ≠ Verified ≠ Adopted ≠ Proved · *Exemple métier* : « L'Accord est confirmé : les conditions sont accomplies. » · *Event* : `AgreementConfirmed` · *Command* : `ConfirmAgreement` · *Query* : `AgreementStateQuery` · *Projection* : `AgreementHonoredProjection` · *Policy* : `AgreementCancellationPolicy` · *Code* : `class AgreementConfirmed`.

## 3. Dictionnaire par domaine (FR → EN ; interdits en italique)

- **Engagement** : Demande d'accord → **AgreementRequest** ; Accord → **Agreement** ; Créneau → **TimeSlot** (*Slot nu, Schedule*) ; Acceptation → **Acceptance** ; Refus de demande → **Rejection** ; Caducité → **Lapse** ; Confirmation → **Confirmation** ; Replanification → **Reschedule** ; Annulation → **Cancellation** ; Auteur (d'annulation) → **CancelledBy** ; Échéance/échu → **Elapse/Elapsed**.
- **Consultation** : Rencontre → **Encounter** (*Meeting, Call, Session*) ; Préparation → **Preparation** ; Ouverture → **Opening** ; Live → **Live** ; Clôture → **Closure** ; Interruption → **Interruption** ; Artefact → **Artifact** ; remise → **Submission** (*Deposit — réservé Storage*) ; Suite → **FollowUp** ; traitée → **Handled** (*Done*) ; Brief → **Brief** ; Participant → **Participant** (réservé à la Rencontre).
- **Professional Identity** : Déclaration → **Declaration** ; Présentation → **Presentation** (*Bio, About*) ; Offre → **Offer** (publiée/retirée → **Published/Unpublished**, *Withdrawn — réservé Consent*) ; Expertise revendiquée → **ClaimedExpertise** ; Expérience → **Experience** ; Portfolio → **Portfolio** ; Masterclass → **Masterclass** ; Référentiel des spécialités → **SpecialtyRegistry** ; Spécialité → **Specialty**.
- **Reputation** : Preuve → **Proof** (réservé à ce domaine) ; Avis → **Review** (*Rating, Score, Stars*) ; Réponse → **ReviewReply** ; Certification vérifiée → **VerifiedCertification** ; Réalisation → **Achievement** ; Audience mesurée → **MeasuredAudience** ; Signalement → **Report** ; Verdict → **Verdict** ; Signal de confiance → **TrustSignal** (projection).
- **Expert Economy** : Revenu → **Revenue** (reconnu → **Recognized**, ajusté → **Adjusted**) ; En-attente → **PendingRevenue** ; Disponible → **AvailableFunds** (*Wallet, Balance nu*) ; Retrait → **Payout** (*Withdrawal, Cashout*) ; Objectif → **Goal** ; Prévision → **Forecast** (projection) ; Opportunité → **Opportunity**.
- **Augmentation** : Production → **Production** (délivrée → **Delivered**) ; Proposition → **Proposal** ; Marquage IA → **AIAttribution** ; Citation → **Citation** ; Incertitude déclarée → **StatedUncertainty** ; Adoption → **Adoption** ; Sollicitation → **ProductionRequest**.
- **Account** : Personne → **Person** (*User*) ; Titulaire → **AccountHolder** ; Préférence → **Preference** (*Settings*) ; Joignabilité → **Reachability** ; Cadre de disponibilité → **AvailabilityFrame** (*Availability nue, Calendar*) ; Abonnement → **Subscription** ; Espace de travail → **Workspace** ; Appareil → **Device** ; Demande d'aide → **SupportRequest** (*Ticket*) ; Fermeture → **Closure** (qualifiée : `AccountClosed`).
- **Discovery** : Intérêt exprimé → **ExpressedInterest** ; Favori → **Favorite** ; Suggestion → **Suggestion** (retenue → **Kept**, écartée → **Dismissed** ; *Rejected — réservé Engagement*) ; Recherche exprimée → **ExpressedSearch** (*Query nu — réservé au type technique*).
- **Enterprise** : Organisation → **Organization** ; Membre → **Member** (*Employee*) ; Invitation → **Invitation** (émise/acceptée/déclinée → **Issued/Accepted/Declined**) ; Appartenance → **Membership** ; Parrainage → **Sponsorship** ; Vérification → **OrganizationVerification**.
- **Consent** *(gelé par le CTO — intangible)* : Consentement → **Consent** ; **Granted / Refused / Withdrawn / Expired / Invalidated** ; Portée → **Scope** ; Accordant → **Grantor** ; Sujet → **Subject** ; Gardien → **Custodian** (*Guardian, Keeper*).
- **Messaging** : Conversation → **Conversation** (*Chat, Thread*) ; Message → **Message** (*DM*) ; Interlocuteur → **Interlocutor** (*Participant — réservé Rencontre* ; la précision bat l'élégance) ; Signalement de conversation → **ConversationReport**.
- **Identity & Access** : Preuve d'entrée → **Credential** (aligné sur le vocabulaire gelé de la Foundation — F1.4.20) ; Facteur → **Factor** ; Session → **Session** (réservé) ; Entrée → **Entry** (*Login, SignIn*) ; Révocation → **Revocation**.
- **Settlement** : Ordre → **SettlementOrder** (*Transaction, Payment nu*) ; Exécution → **Execution** ; Compte rendu → **ExecutionReport** ; Canal → **SettlementChannel**.
- **Notification** : Signal → **Signal** (*Notification-objet, Push, Alert*) ; Livraison → **Delivery** ; Émetteur → **Emitter** (*Sender — faux ami Messaging*) ; Canal de joignabilité → **ReachabilityChannel**.
- **Storage** : Dépôt → **Deposit** (réservé) ; Déposant → **Depositor** ; Garde → **Custody** ; Restitution → **Return** ; Destruction → **Destruction** ; Rétention → **Retention**.

## 4. Event Dictionary (58 faits — préfixe = propriétaire, participe passé obligatoire)

- **Engagement** — `AgreementRequested · AgreementAccepted · AgreementRejected · AgreementRequestLapsed · AgreementConfirmed · AgreementRescheduled · AgreementCancelled · AgreementElapsed`
- **Consultation** — `EncounterPrepared · EncounterOpened · EncounterClosed · EncounterInterrupted · ArtifactSubmitted · FollowUpOpened · FollowUpHandled`
- **Professional Identity** — `OfferPublished · OfferUnpublished · ExpertiseDeclared · ExperienceDeclared · PortfolioUpdated · MasterclassContentPublished`
- **Reputation** — `ReviewPublished · ReviewReplyPublished · CertificationVerified · AchievementRecorded · ReviewReported · VerdictRendered`
- **Expert Economy** — `RevenueRecognized · RevenueAdjusted · PayoutRequested · PayoutCompleted · PayoutFailed · GoalDeclared`
- **Augmentation** — `ProductionDelivered`
- **Account** — `PersonRegistered · AccountClosed · PreferenceChanged · ReachabilityChanged · AvailabilityFrameChanged · SubscriptionStarted · SubscriptionEnded`
- **Discovery** — `FavoriteAdded · FavoriteRemoved · InterestExpressed · SuggestionKept · SuggestionDismissed`
- **Enterprise** — `OrganizationCreated · InvitationIssued · InvitationAccepted · InvitationDeclined · MembershipRevoked · SponsorshipGranted · SponsorshipRevoked · OrganizationVerified`
- **Consent** — `ConsentGranted · ConsentRefused · ConsentWithdrawn · ConsentExpired · ConsentInvalidated`
- **Messaging** — `ConversationOpened · MessageSubmitted · ConversationClosed · ConversationReported · ConversationVerdictRendered`
- **Identity & Access** — `CredentialEstablished · CredentialRevoked`
- **Settlement** — `SettlementOrderExecuted · SettlementOrderFailed`
- **Notification** — `SignalDelivered · SignalUndeliverable`
- **Storage** — `DepositStored · DepositReturned · DepositDestroyed`

*Synonymes interdits partout : `-Created` pour un fait métier (réservé aux registres), `-Done`, `-Updated` nu (sauf Portfolio, où la mise à jour EST l'acte).*

## 5. Command Dictionary (impératif verbe + vérité ; toutes refusables)

`RequestAgreement · AcceptAgreement · RejectAgreement · ConfirmAgreement · RescheduleAgreement · CancelAgreement` — `OpenEncounter · CloseEncounter · SubmitArtifact · HandleFollowUp` — `DeclareExpertise · PublishOffer · UnpublishOffer · UpdatePortfolio` — `PublishReview · ReplyToReview · ReportReview · RenderVerdict` — `RequestPayout · DeclareGoal` — `RequestProduction` — `ChangePreference · ChangeReachability · ChangeAvailabilityFrame · CloseAccount · StartSubscription · EndSubscription` — `AddFavorite · RemoveFavorite · KeepSuggestion · DismissSuggestion · ExpressInterest` — `CreateOrganization · IssueInvitation · AcceptInvitation · DeclineInvitation · RevokeMembership · GrantSponsorship · RevokeSponsorship` — `GrantConsent · RefuseConsent · WithdrawConsent` — `OpenConversation · SubmitMessage · CloseConversation · ReportConversation` — (via ACL) `EstablishCredential · RevokeCredential · ExecuteSettlementOrder · DeliverSignal · StoreDeposit · ReturnDeposit`.

*Interdits : `Create`/`Delete`/`Update` génériques, `Set`, `Save`, `Handle` nu.*

## 6. Query, Projection & Policy Dictionaries

- **Queries** (à la source, synchrones — loi 15) : `ConsentValidityQuery` · `AgreementStateQuery` · `EncounterStateQuery` · `OfferQuery` · `SpecialtyRegistryQuery` · `AvailableFundsQuery` · `ReachabilityQuery` · `AvailabilityFrameQuery` · `MembershipQuery`.
- **Projections** (dérivations déterministes, jamais persistées comme faits) : Honoré → `AgreementHonoredProjection` ; No-show → `NoShowProjection` ; Prévision → `RevenueForecastProjection` ; Signal de confiance → `TrustSignalProjection` ; Profil assemblé → `PublicProfileProjection` ; Calendrier → `CalendarProjection` (cadre ⊕ accords) ; Complétude → `ProfileCompletionProjection` ; « libre » → `FreeSlotsProjection`.
- **Policies** (publiées d'avance) : `AgreementCancellationPolicy · AgreementRequestLapsePolicy · ReschedulePolicy · EncounterConsentCombinationPolicy · RevenueRecognitionPolicy · PayoutAvailabilityPolicy · ConsentDefinitivenessPolicy · RetentionPolicy · ReachabilityPolicy · SuggestionDismissalPolicy · SponsorshipPolicy · ReviewIntegrityPolicy (RN-02/RT-03)`. *(`AvailabilityPolicy` nu : refusé — trois sens, trois mots.)*

> Correction F2.5.2 : la policy de caducité est **`AgreementRequestLapsePolicy`** (la caducité frappe la Demande, jamais l'Accord ferme — chronologie gelée F2.2.1), cohérente avec le fait `AgreementRequestLapsed`.

## 7. Actor Dictionary

Client → **Client** · Expert → **Expert** · Personne → **Person** · Titulaire → **AccountHolder** · Auteur → **Author** · Demandeur → **Requester** (toujours qualifié : `AgreementRequester`, `SupportRequester`) · Accordant → **Grantor** · Sujet → **Subject** · Commanditaire → **Commissioner** (*Principal — réservé à la Foundation Layout*) · Déposant → **Depositor** · Membre → **Member** · Organisation → **Organization** · Interlocuteur → **Interlocutor** · Gardien → **Custodian** · Vérificateur → **Verifier** · Émetteur → **Emitter**.

## 8. Type Dictionary (langage du code)

Identifiant → **Identifier** (`AgreementId`) · Agrégat → **Aggregate** (nommé par sa vérité nue : `Agreement`, `Encounter`, `ConsentRecord`) · Entité → **Entity** · Objet-valeur → **ValueObject** · Fait → **DomainEvent** · Commande → **Command** · Requête → **Query** · Projection → **Projection** · Photographie → **Snapshot** · Politique → **Policy** · Résultat → **Result** · Motif → **Reason** · Décision → **Decision** · État → **State** (*Status interdit*) · Spécification → **Specification**. Chacun : défini par la Foundation State/Contracts quand elle s'applique, sinon par F2.5.

## 9. Naming Constitution

Events `<Truth><PastParticiple>` · Commands `<Verb><Truth>` · Queries `<Truth><Aspect>Query` · Policies `<Truth><Rule>Policy` · Aggregates `<Truth>` nu · VO `<Notion>` nu · Repositories `<Truth>Repository` · Factories `<Truth>Factory` · Specifications `<Rule>Specification` · Domain Services `<Capability>` verbe-nom, **jamais** `-Manager/-Helper/-Util/-Service` **nu** · Application Services `<UseCase>ApplicationService` · Ports `<Capability>Port` · Adapters `<Provider><Capability>Adapter` (ex. `LivekitRoomAdapter`) · ACL `<Frontier>Acl` (abréviation sanctionnée, la seule) · OHS = le langage publié lui-même, pas un suffixe · Process Managers `<Journey>Process` (l'Effacement : `ErasureProcess`) · Read Models `<Name>ReadModel` · Projections `<Name>Projection` · DTO interdits dans le domaine ; aux bords : `<X>Payload`.

*Interdits transverses : `Base-`, `Abstract-` (préférer le contrat), `Impl`, `Data`, `Info`, `Item`, `Object`, `Common`, `Shared`, `Utils`.*

> Clarification F2.5.2 : l'interdit vise le suffixe **nu et générique** (`AgreementService`, fourre-tout). Un Domain Service **qualifié par sa capacité** (`AgreementSchedulingService`) est **conforme**.

## 10. Forbidden Vocabulary (extraits — liste close au glossaire)

Booking→Agreement · Reservation→Agreement (parcours : « réservation » FR seulement) · Appointment→Agreement · Meeting/Call→Encounter · Session (hors I&A)→Encounter · User→Person · Profile nu→Declaration ou PublicProfileProjection · Wallet→AvailableFunds · Withdrawal→Payout (hors ConsentWithdrawn) · Rating/Score→interdits (RT-03) · Chat/Thread/Inbox→Conversation (l'inbox est une surface) · Feed→interdit (surface) · Dashboard→interdit (surface) · History→les faits, ou une projection nommée · Status→State qualifié · Settings→Preferences · Login→Entry · Upload/Bucket→Deposit/Storage (ACL) · Ticket→SupportRequest · Notification-objet→Signal.

## 11. Les mots réservés (les collisions tranchées)

**Huit réservations de domaine** — un mot EN, un seul propriétaire, partout (y compris dans les composés d'exceptions) :

| Mot réservé | Propriétaire | Le concurrent a été renommé |
|---|---|---|
| **Expired** | Consent (`ConsentExpired`) | la Caducité de l'Engagement devient **Lapse** |
| **Withdrawn** | Consent (`ConsentWithdrawn`) | le Retrait de l'Économie devient **Payout** |
| **Rejected** | Engagement (`AgreementRejected`) | l'écart de la Suggestion devient **Dismissed** |
| **Participant** | Rencontre (Consultation) | l'interlocuteur du Messaging assume son latin, **Interlocutor** |
| **Proof** | Reputation | la preuve d'entrée d'I&A devient **Credential** (alignée sur la Foundation F1.4.20) |
| **Deposit** | Storage | la remise de la Consultation devient **Submission** |
| **Channel** | qualifié des deux côtés | `SettlementChannel` / `ReachabilityChannel` |
| **Principal** | Foundation Layout | le commanditaire devient **Commissioner** |

**Le quintette du refus** — cinq mots, cinq détenteurs (le cinquième créé par F2.5.2) :

| Mot | Réservé à |
|---|---|
| **Rejected** | Engagement (refus d'une Demande) |
| **Refused** | Consent |
| **Declined** | Invitation |
| **Dismissed** | Suggestion |
| **Denied** | **Exceptions uniquement** — le mot transversal du refus de commande, jamais un fait |

**RetentionActive** (F2.5.2) : mot propre de la rétention encore ouverte (`Elapsed` réservé à l'Engagement, `Expired` au Consent) — exception `DepositRetentionActiveException`, reason `RetentionActive`. Règle générale : **les mots réservés le sont partout**, y compris dans les composés d'exceptions.

## 12. Canonical Example & Checklist

Le **Canonical Example** est **Agreement**, déroulé sur toute la pile (Event → Command → Query → Projection → Policy → Exception → Reason → Adapter). Tout nouveau domaine devra se dérouler exactement selon cette structure, ou expliquer au Titre VII pourquoi il ne le peut pas. Les noms de fournisseurs (Stripe, Email, Livekit…) n'apparaissent qu'au rang **Adapter**, jamais ailleurs. La **Checklist** des 18 lois est l'exécutable de revue — sœur des balayages de la Foundation : la loi rendue vérifiable, opposable à toute Pull Request dès la première ligne de F3.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié (Constitution de la Langue **v1.1.0**) :

- **F2.5.1** — corps du dictionnaire : principes P1-P6, gabarit, dictionnaire par domaine, Event Dictionary (58 faits), Command/Query/Projection/Policy Dictionaries, Actor & Type Dictionaries, Naming Constitution, Forbidden Vocabulary, huit réservations de domaine ; amendements §15.1 ratifiés (Caducité→`Lapse`/`AgreementRequestLapsed`, Échéance→`Elapse`/`AgreementElapsed`, Retrait→`Payout`).
- **F2.5.2** — quatre corrections intégrées : (1) **`Denied`** créé, cinquième mot réservé du refus (Exceptions) ; (2) **`RetentionActive`** créé (rétention ouverte), règle « les mots réservés le sont partout » confirmée ; (3) **`AgreementRequestLapsePolicy`** (la caducité frappe la Demande) ; (4) clarification : un Domain Service **qualifié** (`AgreementSchedulingService`) est conforme, l'interdit ne visant que le suffixe nu.

Ce chapitre est le **propriétaire officiel** du vocabulaire : les événements y figurent tels que le Dictionnaire les gèle (correspondance avec les noms FR publiés par F2.2). Le scaffolding de session (Phase 0, audit contradictoire, risques, notes, décision, État Git, STOP) n'est pas reproduit.
