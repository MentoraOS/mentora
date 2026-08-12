---
doc: f3-02-aggregates-customer-journey
title: F3.2-A — Aggregate Design, Customer Journey Core (état final ratifié)
type: source
titre: domain
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 4A)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 4A"
sources_session:
  - "F3.2-A — Aggregate Design Customer Journey Core (Discovery, Professional Identity, Engagement, Consultation, Reputation ; lois tactiques R-A et R-B)"
  - "F3.2-A.99 — Customer Journey Tactical Audit (six amendements : TimeSlotUnavailable ; Structural Registry Invariant précisé ; référence de provenance ; AudienceMeasurement ; Struck / Invalidated ; test de promotion des Entities)"
  - "F3.2.99 — Grand Tactical Audit (confirme les 11 unités du groupe A sans les amender ; naissance de R-C — matérialisée au chapitre de clôture)"
note: >-
  Reconstruction fidèle de l'état final ratifié des cinq domaines du Customer
  Journey Core, après les six amendements de F3.2-A.99. Le Grand Audit F3.2.99
  confirme ces unités sans les modifier. Ce chapitre possède les designs
  d'agrégats du groupe A et fait naître les lois tactiques du registre R-A et
  R-B ; R-C naît au chapitre de clôture (Lot 4C). Langage suivant le
  Dictionnaire (F2.5), blocs suivant F3.1 (chapitre 01). Scaffolding de session
  exclu. Titre VII pour toute évolution.
---

# F3.2-A — Aggregate Design — Customer Journey Core

> État **final ratifié** : Discovery, Professional Identity, Engagement,
> Consultation, Reputation — application stricte de F3.1 amendé.

## Les deux lois tactiques du registre (nées ici)

- **R-A — Invariant structurel de registre** (rédaction précisée par F3.2-A.99) : *un Repository ne protège jamais un invariant métier ; il applique les invariants **structurels** que le domaine a **déclarés**. Toute règle vit dans l'Aggregate, une Policy ou une Specification ; le registre n'en connaît que la **clé**.* L'invariant inter-unités d'une même vérité vit au **registre** : la rétention refuse structurellement le conflit et rend une **Décision motivée**, jamais une exception. *(Les sommes exigent des frontières ; les identités exigent des clés — une somme ne peut jamais être une clé structurelle.)*
- **R-B — Nouvelle unité après état terminal** : *toute mutation après état terminal est une **unité NOUVELLE** qui référence la précédente.* Le devenir d'une chose close est une autre chose (le regret se traite en amont par confirmation UX ; le réessai par provenance).

---

## Domaine 1 — Discovery

- **Aggregate** : **`ClientInterest`** — la relation d'intérêt d'UN client (root, une par personne). Plus petite unité qui rende l'invariant vrai (« écarté = jamais reproposé sans acte nouveau » exige de voir tous les écarts de cette personne). Un seul acteur commande (le Client) — aucun NON clandestin.
- **Entities** : `Favorite` (identité, vie ajout→retrait). **VOs** : `TargetRef`, `DismissalRecord` (immuable — un écart ne se retire que par acte nouveau `KeepSuggestion`), `SearchExpression`, `SuggestionRef` (source citée).
- **State machine** : `Active` → `Closed` (terminal, en réaction au fait `AccountClosed`). Aucune horloge.
- **Commands** : `AddFavorite` (`DuplicateFavorite`) · `RemoveFavorite` (`FavoriteNotFound`) · `ExpressInterest` · `ExpressSearch` · `KeepSuggestion` · `DismissSuggestion` (`SuggestionAlreadyDismissed`) — toutes du Client, toutes rendant une Decision-valeur.
- **Events** (gelés) : `FavoriteAdded/Removed · InterestExpressed · SuggestionKept/Dismissed`.
- **Specification** : `DismissedSuggestionSpecification`. **Policy** : `SuggestionDismissalPolicy` (absolue). **Domain Service** : aucun. **Factory** : aucune. **Port** : `ClientInterestRepository` (`ofClient(ClientId)`, rétention ; aucune recherche de pertinence).

## Domaine 2 — Professional Identity

- **Aggregates** : **`ProfessionalIdentity`** (une par expert — la parole) ; **`Offer`** (unité propre — référencée de l'extérieur par `OfferId`, invariant de complétude publiable) ; **`SpecialtyRegistry`** (unité de gouvernance — le référentiel ; commandé par la gouvernance produit, servi par `SpecialtyRegistryQuery` ; aucun événement — le registre se lit).
- **Entities** de `ProfessionalIdentity` : `PortfolioItem`, `MasterclassContent`. **VOs** : `Presentation`, `ClaimedExpertise`, `ExperienceEntry`, `OfferTerms` (dont `Price`/`Money` — l'offre présentée porte son tarif : une *déclaration* ; le *sens* économique reste à l'Économie), `Specialty`.
- **State machines** : Identity — vivante (pas d'états : des versions de déclaration). `Offer` : `Unpublished` ⇄ `Published` (aucun terminal propre — meurt avec le compte). Registry : croissance, dépréciation possible, jamais de retrait.
- **Commands** : `DeclareExpertise` (`UnknownSpecialty`) · `DeclareExperience` · `UpdatePortfolio` · `PublishMasterclassContent` · `PublishOffer` (`OfferIncomplete`) · `UnpublishOffer` · gouvernance : `AdmitSpecialty`, `DeprecateSpecialty`. **Events** (gelés) : `ExpertiseDeclared · ExperienceDeclared · PortfolioUpdated · MasterclassContentPublished · OfferPublished · OfferUnpublished`.
- **Specs** : `PublishableOfferSpecification`, `KnownSpecialtySpecification`. **Domain Service** : aucun. **Factories** : `OfferFactory` (naissance = cohérence terms+specialty+identité) ; Identity naît par constructeur au fait `PersonRegistered`+rôle expert. **Ports** : `ProfessionalIdentityRepository`, `OfferRepository`, `SpecialtyRegistryRepository`.
- **Test de promotion des Entities de la parole (F3.2-A.99)** : `PortfolioItem`/`MasterclassContent` restent Entities aujourd'hui ; **promotion obligatoire le jour où un tiers commande** (modération) **ou une référence externe vise l'élément**. Aucune anticipation (l'abstraction prématurée est interdite).

## Domaine 3 — Engagement

- **Aggregate** : **`Agreement`** — né à la Demande (la demande est sa jeunesse ; la scission est interdite). Root unique ; **deux acteurs refusants** (Client, Expert) sur la MÊME vérité — licite pour une racine. Invariant principal : la machine d'états gelée + l'**unicité inter-unités** au registre (R-A) : deux Agreements confirmés ne visent jamais (même expert, créneaux chevauchants) → Décision **`TimeSlotUnavailable`** *(amendement F3.2-A.99 : remplace `SlotAlreadyEngaged` ; « Slot » nu et « Conflict » sont interdits ; `TimeSlotUnavailable` = VO officiel + famille `-Unavailable`)*.
- **Entities** : aucune. **VOs** : `TimeSlot`, `AgreementConditions` (les conditions convenues — vérité nouvelle citant `OfferId` : ce n'est pas une copie de l'Offre, c'est le fait de ce qui fut convenu), `CancellationRecord` (auteur + instant + motif), `RescheduleRecord`.
- **State machine** (chronologie gelée, temps en donnée) : `Requested` →Accept→ `Accepted` →Confirm→ `Confirmed` →Reschedule*→ `Confirmed` ; `Requested` →Reject→ **`Rejected`** ; `Requested`/`Accepted` →Lapse(instant fourni)→ **`Lapsed`** ; `Confirmed` →Cancel→ **`Cancelled`** ; `Confirmed` →Elapse(instant fourni)→ **`Elapsed`**. Quatre terminaux irréversibles (revenir = nouvelle Demande, R-B). Transitions interdites : Confirmed→Rejected, tout→Requested, terminal→quoi que ce soit.
- **Commands** : `RequestAgreement` (Client ; `OutsideAvailabilityFrame` — le Cadre **fourni en donnée**, loi 15) · `AcceptAgreement`/`RejectAgreement` (Expert) · `ConfirmAgreement` (Commissioner d'exécution, portant le compte rendu d'encaissement traduit ; `ConfirmationConditionsMissing`) · `RescheduleAgreement` (parties, Policy) · `CancelAgreement` (parties, Policy, auteur porté) · `LapseAgreementRequest`/`ElapseAgreement` (outillage du temps, instant en donnée). **Events** : les huit gelés.
- **Specs** : `SlotWithinFrameSpecification`, `ConfirmableAgreementSpecification`, `OverlappingSlotSpecification` (servie au registre pour R-A). **Policies** : `AgreementCancellationPolicy`, `ReschedulePolicy`, `AgreementRequestLapsePolicy`, `ConfirmationPolicy`. **Domain Service** : aucun (faux service supprimé — le chevauchement est au registre). **Factory** : `AgreementFactory` (naissance = Demande cohérente ; n'appelle aucun port, reçoit l'extrait d'Offre en données). **Port** : `AgreementRepository` (byId, byExpert-and-window ; rétention à refus structurel, R-A).
- **Failures** : encaissement indisponible → l'Accord **reste `Accepted`**, jamais affiché confirmé ; jamais de rollback (compensation par `CancelAgreement` motivé).

## Domaine 4 — Consultation

- **Aggregates** : **`Encounter`** (une par Accord échu — unicité par `AgreementId` au registre, R-A) et **`FollowUp`** (unité nouvelle par R-B : la Clôture est terminale ; la Suite naît à la clôture et vit après). **Référence de provenance (amendement F3.2-A.99)** : `FollowUp` porte **`EncounterId` + `AgreementId`**, tous deux posés à la naissance, immuables — citation de provenance (identifiants stables), jamais copie de mutable.
- **Entities** de `Encounter` : `Artifact` (identité, nature du dictionnaire ; **contenu jamais dans l'unité publiée : la matière va en Dépôt (Storage), l'Artifact porte la référence**), `Brief`. **VOs** : `ParticipantRef`, `ArtifactNature`, `ConsentEvidence` (accords actifs **fournis en données** par l'Application Service depuis la source), `Instant`.
- **State machines** : Encounter — `Prepared` → `Opened` → **`Closed`** | **`Interrupted`** (deux terminaux ; Interrupted jamais requalifié). FollowUp — `Opened` → **`Handled`**. L'ouverture exige le fait `AgreementElapsed` (fourni) et les consentements actifs (fournis).
- **Commands** : `PrepareEncounter` · `OpenEncounter` (`ConsentMissing`, accord non échu) · `SubmitArtifact` (refus après terminal) · `CloseEncounter` · `InterruptEncounter` · `OpenFollowUp` (naît de la clôture avec suites, commandée par l'Expert) · `HandleFollowUp`. **Events** (gelés) : `EncounterPrepared/Opened/Closed/Interrupted · ArtifactSubmitted` (nature seule) · `FollowUpOpened/Handled`. Le no-show reste une projection.
- **Specs** : `OpenableEncounterSpecification`, `RecordingPermittedSpecification` (l'accord de TOUS — règle de combinaison possédée ici, F2.6). **Policy** : `EncounterConsentCombinationPolicy`. **Domain Service** : aucun. **Factory** : `EncounterFactory`. **Ports** : `EncounterRepository` (byId, byAgreementId — unicité structurelle), `FollowUpRepository`.
- **Failures** : garde indisponible → `SubmitArtifact` d'enregistrement **refusée avant de commencer** (loi 18) ; interruption → `RevenueAdjusted` en aval par l'Économie.

## Domaine 5 — Reputation

- **Aggregates** : **quatre unités de preuve**, append-only après naissance — **`Review`** (contenu de l'Auteur ; unicité par (Auteur, `EncounterId`) au registre — `ReviewAlreadyExists`, R-A), **`CertificationRecord`** (acte du Vérificateur), **`AchievementRecord`**, **`AudienceMeasurement`**. Le `TrustSignal` et le Profil assemblé sont des **projections**, non conçues.
  - **`AudienceMeasurement` (amendement F3.2-A.99)** : registre de preuve **append-only** ; commande `RecordAudienceMeasurement` (commanditée par l'outillage de mesure du gardien, derrière son port) ; constatant : le registre de preuve ; **trois refus réels** (échantillon malformé, doublon par identité d'échantillon, source non citée) ; invariants : append-only, source citée, identité d'échantillon unique (clé structurelle) ; **aucun événement publié** (publier est un droit, pas un devoir ; les mesures nourrissent les projections dépliables).
- **Entities** de `Review` : `ReviewReply` (la parole du Sujet, annexée, une par avis — jamais mutante après publication), `ReviewReport` (signalement : identité du signaleur **privée au registre**, extrait porté par l'acte du signaleur — le pont). **VOs** : `ReviewContent` (immuable à jamais — RN-02), `VerdictRecord` (motivé), `MeasurementSample`.
- **State machine** : Review — **`Published` → `Struck`** (terminal, par Verdict qui retire pour cause légale — RN-02 respecté). **Partage des mots de police (amendement F3.2-A.99)** : **`Struck`** = retrait par Verdict (*struck from the register*, motivé, tracé, sans réécriture) ; **`Invalidated`** = vice ab initio (le fait n'aurait jamais dû naître) — deux concepts, deux mots. Les trois autres unités : nées, éternelles.
- **Commands** : `PublishReview` (Auteur ; validité : clôture réelle de SA rencontre — vérifiée à la source, fournie en donnée) · `ReplyToReview` (Sujet) · `ReportReview` (toute personne lésée) · `RenderVerdict` (Custodian — police du registre) · `VerifyCertification` (Verifier) · `RecordAchievement` · `RecordAudienceMeasurement`. **Events** (gelés) : `ReviewPublished · ReviewReplyPublished · ReviewReported · VerdictRendered · CertificationVerified · AchievementRecorded`.
- **Specs** : `ReviewEligibilitySpecification`, `AdjudicableReportSpecification`. **Policy** : `ReviewIntegrityPolicy` (RN-02/RT-03). **Domain Service** : aucun. **Factory** : `ReviewFactory`. **Ports** : quatre registres, rétention à refus structurel pour Review.
- **Failures** : écriture par le Sujet → refus (attendu, moteur du produit) ; fraude → police (`RenderVerdict`), jamais d'effacement.

---

# Les six amendements de F3.2-A.99

1. **`TimeSlotUnavailable`** remplace `SlotAlreadyEngaged` (démonstration mécanique du nommage).
2. **Structural Registry Invariant** — R-A dans sa rédaction précisée (le registre applique une clé déclarée, ne juge pas).
3. **Référence de provenance** : `FollowUp` porte `EncounterId` + `AgreementId` ; la chaîne d'identifiants stables cités à la naissance est légale, la copie de mutable interdite.
4. **`AudienceMeasurement`** : registre de preuve append-only, sans événement publié, refusant par trois motifs réels.
5. **`Struck`** ratifié ; partage des mots de police : `Invalidated` = vice ab initio, `Struck` = retrait par Verdict.
6. **Test de promotion des Entities de la parole** (PortfolioItem, MasterclassContent) : promotion le jour où un tiers commande ou une référence externe vise ; aucune anticipation.

> **Zéro Domain Service dans les cinq domaines** — résultat, non manque : le savoir a partout trouvé un foyer.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F3.2-A** (les cinq domaines du Customer Journey Core ; naissance de R-A et R-B) et **F3.2-A.99** (six amendements intégrés et récapitulés). Le Grand Audit **F3.2.99** a re-jugé ces onze unités (Discovery 1, Professional Identity 3, Engagement 1, Consultation 2, Reputation 4) et les a confirmées **sans amendement** ; sa loi **R-C** (toute Query nomme son ayant droit) et ses précisions de provenance sont matérialisées au [chapitre 05 (Grand Audit)](05-grand-tactical-audit.md). Les ratifications Titre VII nées du dessin (`FundsLedger` — hors groupe A ; grille R-C ; capacité d'invitation différée) sont consolidées au gel documentaire. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
