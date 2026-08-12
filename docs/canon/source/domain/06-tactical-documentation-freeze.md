---
doc: f3-06-tactical-documentation-freeze
title: F3.3 — Tactical Documentation Freeze (état final ratifié)
type: source
titre: domain
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 4C)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 4C"
sources_session:
  - "F3.3 — Tactical Documentation Freeze (glossaire, catalogues d'agrégats/faits/commandes/lectures/politiques/questions/machines/provenances, lois tactiques, checklists, anti-patterns, index, audit qualité)"
  - "F3.3.99 — Documentation Constitutional Audit (six corrections documentaires : transitions au seul §8 ; totaux dérivés 30/73/79/16/11/23/18 ; ExpressSearch supprimée ; Checklist Projection ; 18e anti-pattern ; entrée Ledger)"
note: >-
  Reconstruction fidèle de l'état final ratifié (F3.3 corrigé des six points de
  F3.3.99). Ce chapitre est la DOCUMENTATION CONSTITUTIONNELLE officielle et
  porte l'édition consolidée des lois R-A/R-B/R-C. Les totaux sont DÉRIVÉS des
  énumérations (loi documentaire : le catalogue fait foi, jamais le chiffre). Les
  énumérations exhaustives (58→73 faits, commandes) restent la propriété du
  Dictionnaire (F2.5, chapitre 04) et des dessins (chapitres 02-04) ; ce chapitre
  en donne la structure de catalogue, les comptes autoritaires et les règles
  propres. Scaffolding de session exclu. Titre VII pour toute évolution.
---

# F3.3 — Tactical Documentation Freeze

> **Documentation Constitutionnelle officielle** — la référence opposable de
> toute Pull Request. État final : F3.3 corrigé des six points de F3.3.99.
>
> **Loi documentaire fondatrice** : *une vérité documentaire = un catalogue ;
> les autres la référencent. Le catalogue fait foi, jamais le chiffre : tout
> total est dérivé de son énumération ; aucun total écrit à la main n'est
> propriétaire d'une vérité. Une référence est un numéro, jamais une position.*

## Les comptes officiels (tous dérivés des énumérations)

| Objet | Compte | Propriétaire de l'énumération |
|---|---|---|
| Domaines | **15** | F2.1 (chapitre constitution/01) |
| Aggregates | **30** | chapitres 02-04 (dessins) |
| Domain Events | **73** | Dictionnaire F2.5 (chapitre constitution/04) |
| Commands | **79** | §3 (origines) + actes sans fait publié |
| Queries | **11** | Query Catalogue ci-dessous (R-C) |
| Policies | **16** | Policy Catalogue ci-dessous |
| Specifications | **23** | Specification Catalogue ci-dessous |
| Anti-Patterns | **18** | Anti-Pattern Handbook ci-dessous |

*(Corrections F3.3.99 : « 25 » → 30, « 58 » → 73, « 52 » → 79, « 15 » → 16, « 9 » → 11, 17 → 18 — les totaux écrits à la main étaient les seuls faux ; ils sont désormais dérivés.)*

## 1. Tactical Glossary (fermé)

Chaque terme renvoie à son propriétaire constitutionnel : **Aggregate** (unité d'une vérité, F3.1.2/F3.1.99) · **Entity** (identité intérieure, F3.1.3) · **Value Object** (F3.1.4) · **Domain Event** (F3.1.5) · **Command** (P4) · **Decision** / **Reason** / **Exception** (F3.1.14, F2.5.2) · **Policy** (F3.1.13) · **Specification** (F3.1.8) · **Repository** (F3.1.6) · **Factory** (F3.1.7) · **Domain Service** (F3.1.9 — zéro dans les 15) · **Application Service** (F3.1.10) · **Process** (F3.1.12) · **Projection / Read Model / Snapshot** (F3.1.11) · **Port / Adapter** · **Query** (lecture avec ayant droit nommé, R-C) · **Registry / Singleton** (F3.2-B.99 §11) · **Provenance** (F3.2-A.99 §4) · **R-A / R-B / R-C** (§10). **Entrée ajoutée par F3.3.99** : ***Ledger*** — *registre-unité singleton-par-acteur, append-only, dont la frontière contient un invariant d'ensemble (une porte, une somme)* ; réf. `ConsentLedger`, `FundsLedger`. Le Glossaire est **fermé** : aucun terme employé sans définition.

## 2. Aggregate Catalogue — les 30 unités

Les trente unités et leurs propriétés (vérité, NON, invariant-clef, Factory, Repository, clé R-A) sont dessinées aux chapitres **02** (Customer Journey, 11), **03** (Identity & Collaboration, 11) et **04** (Platform & Infrastructure, 8). Répartition : Discovery 1 · Prof. Identity 3 · Engagement 1 · Consultation 2 · Reputation 4 · Account 4 · Enterprise 5 · Consent 1 · Messaging 1 · Economy 2 · Augmentation 1 · I&A 2 · Settlement 1 · Notification 1 · Storage 1.

## 3. Event Catalogue — les 73 faits

Grille commune : *constatant* = l'unité propriétaire ; *versionnement* = additif seul ; *contenu interdit partout* = tout contenu privé (P7), tout secret, toute matière — les faits portent identités, natures, instants, auteurs, provenances. **Les transitions d'états ne sont PAS ici** : elles appartiennent au seul **State Machine Catalogue (§8)** — correction F3.3.99 §1 (une règle définie deux fois divergera un jour). L'énumération exhaustive des 73 faits est celle du Dictionnaire (chapitre 04) ; ce catalogue en donne les consommateurs autorisés / interdits par domaine, référencés aux dessins 02-04.

## 4. Command Catalogue — les 79 commandes

Grille commune : toute Command rend une **Decision** (acceptée, ou Refusal + Reason) ; les préconditions inter-domaines arrivent **en données** (validées aux sources, loi 15). Les 79 commandes sont les origines nommées au §3 plus les actes sans fait publié (`OpenSupportRequest`/`HandleSupportRequest`, `RegisterDevice`/`RemoveDevice`, `AdmitSpecialty`/`DeprecateSpecialty`, `RecordAudienceMeasurement`, `RequestProduction`, `ReturnDeposit`, `EstablishCredential`/`RevokeCredential`, `ExecuteSettlementOrder`, `DeliverSignal`, `StoreDeposit`, `DestroyDeposit`). **`ExpressSearch` supprimée** (correction F3.3.99 §4 : commande sans fait gelé ni changement d'état — `ExpressedSearch` demeure un concept-VO du lexique). **Aucune commande CRUD n'existe.** Reasons : la famille du dictionnaire F2.5.2 §20 + `TimeSlotUnavailable`, `MembershipAlreadyExists`, `RetentionActive`.

## 5. Query Catalogue — les 11 lectures (R-C : chaque ligne nomme l'ayant droit)

| Query | Ayant droit | Retourne ⊘ interdit |
|---|---|---|
| `ConsentValidityQuery` | tout domaine agissant, **pour son propre acte** | validité d'un accord ⊘ l'histoire d'autrui, tout profilage |
| `AgreementStateQuery` | les parties, l'outillage du temps | l'état ⊘ les conditions à des tiers |
| `EncounterStateQuery` | les participants | état + natures d'artefacts ⊘ contenu |
| `AvailabilityFrameQuery` | tous (le cadre publié sert la réservation) | fenêtres ⊘ raisons |
| `AvailableFundsQuery` | **le Titulaire** + conformité | le Disponible ⊘ tout tiers |
| `SpecialtyRegistryQuery` | tous | le Référentiel |
| Offres publiées / profils assemblés | tous | l'offre, la projection publique |
| `MembershipQuery` | l'Organisation et le Membre | appartenances ⊘ tiers |
| `ReachabilityQuery` | la Notification (lecture sanctionnée) + le Titulaire | canaux ⊘ tout autre |
| `ConversationQuery` | l'Interlocuteur seul | ses conversations ⊘ l'existence même aux tiers |

*(La ligne groupée de la source cachait trois lectures — correction F3.3.99 §2 : onze, dérivées de l'énumération.)*

## 6. Policy Catalogue — les 16 politiques

`AgreementCancellationPolicy` · `ReschedulePolicy` · `AgreementRequestLapsePolicy` · `ConfirmationPolicy` (Engagement) — `EncounterConsentCombinationPolicy` (Consultation) — `ReviewIntegrityPolicy` (Réputation) — `RevenueRecognitionPolicy` · `PayoutAvailabilityPolicy` (Économie) — `ConsentDefinitivenessPolicy` (Consent) — `ReachabilityPolicy` · `SubscriptionPolicy` (Compte) — `SuggestionDismissalPolicy` (Découverte) — `SponsorshipPolicy` (Enterprise) — `RetentionPolicy` (Storage) — `ProofRequirementPolicy` (I&A) — **la cage AE publiée** (Augmentation). Chaque ligne : paramètres = configuration produit ; aucune ne possède une vérité. *(La cage AE comptait — correction F3.3.99 §2 : seize.)*

## 7. Specification Catalogue — les 23 questions

`DismissedSuggestion` · `PublishableOffer` · `KnownSpecialty` · `SlotWithinFrame` · `ConfirmableAgreement` · `OverlappingSlot` (sert la clé R-A) · `OpenableEncounter` · `RecordingPermitted` · `ReviewEligibility` · `AdjudicableReport` · `ClosableAccount` · `CoherentFrame` · `SubscriptionChange` · `AcceptableInvitation` · `RevocableMembership` · `ActiveGrant` · `DefinitivelyRefused` · `OpenConversation` · `PayableAmount` · `RecognizableRevenue` · `Producible` · `ReturnableDeposit` · `DestroyableDeposit`. Composition : et/ou/non, nommée ; paramètres étrangers **fournis en données**, jamais cherchés.

## 8. State Machine Catalogue — les quinze (SEUL propriétaire des transitions)

| Machine | initial → … → terminaux (interdits notables) |
|---|---|
| Agreement | Requested → Accepted → Confirmed (⇄Rescheduled) → **Cancelled \| Elapsed** ; Requested→**Rejected\|Lapsed** ; Accepted→**Lapsed** (⊘ Confirmed→Rejected, terminal→*) |
| Encounter / FollowUp | Prepared→Opened→**Closed\|Interrupted** (⊘ requalification) / Opened→**Handled** |
| Review | Published→**Struck** (par Verdict seul) ; autres preuves : nées, éternelles |
| Account / Subscription / SupportRequest | Active→**Closed** / Active→**Ended** / Opened→**Handled** |
| Vivantes (fin par chaîne `AccountClosed`) | AvailabilityFrame · ProfessionalIdentity · ClientInterest · FundsLedger · SpecialtyRegistry — leurs Entities portent les cycles (PayoutRecord : Requested→**Completed\|Failed**) |
| Invitation / Membership | Issued→**Accepted\|Declined** / Active→**Revoked** |
| ConsentGrant | Granted→**Withdrawn\|Expired\|Invalidated** ; Refusal : né, définitif selon type |
| Conversation | Open→**Closed** |
| Credential / Session | Active→**Revoked** / Active→**Ended\|Revoked** |
| SettlementOrder / Signal / Deposit / Production | Received→**Executed\|Failed** / Remitted→**Delivered\|Undeliverable** / Stored→**Destroyed** / Requested→**Delivered** |

Lois transversales : état initial nommé, terminaux irréversibles (R-B), **aucune transition sans commande, aucune commande d'état sans fait gelé ou droit au silence**, temps toujours fourni.

## 9. Provenance Catalogue

`Offer → Agreement` (conditions figées) → `Encounter` (AgreementId) → `FollowUp` (EncounterId + AgreementId) — `Production → Artifact` (adoption : ProductionId + Dépôt d'origine) → `Deposit` **nouveau du domaine adoptant** — `Invitation → Membership` (InvitationId + OrganizationId) → `Sponsorship` (OrganizationId + MembershipId) — `EncounterClosed → RevenueRecognized` (RevenueSource : EncounterId) → somme du Ledger → `PayoutRecord` (interne) → `SettlementOrder` (réessai = ordre nouveau citant l'échec) — `Signal ← Émetteur` — `Subscription(n+1) ← Subscription(n)`. Trois lois : identité citée stable posée à la naissance ; jamais de copie mutable ; toute chaîne se lit sans jointure.

## 10. Tactical Rules — édition officielle (consolidation R-A / R-B / R-C)

- **R-A — Structural Registry Invariant.** *La règle au domaine (Specification) ; la clé déclarée par le domaine ; l'application au registre, structurelle, à la rétention ; le refus en Décision motivée ; l'infrastructure exécute la clé et ignore la règle.* Exemples : créneau confirmé, appartenance active, abonnement actif, reconnaissance par rencontre, identité d'ordre, credential actif. Contre-exemples : la somme comme clé (les sommes exigent des frontières) ; le trigger SQL (loi invisible) ; le service de réservation (agrégat clandestin).
- **R-B — Nouvelle unité après terminal.** *Tout devenir qui reprend après un terminal est une unité nouvelle, à provenance citée.* Exemples : FollowUp, re-souscription, réessai de retrait/ordre, nouvelle Demande. Contre-exemples : la « réouverture » (le regret se traite AVANT le fait — UX-06) ; le replay (même identité = déduplication, pas d'unité nouvelle).
- **R-C — Ayant droit de lecture.** *Toute Query publiée nomme son ayant droit ; une lecture sans droit est refusée, motivée.* Exemples : §5. Erreur classique : « c'est juste une lecture » — une lecture est un contrat.

## 11. Architectural Checklists — les 15 (opposables en PR)

**Aggregate · Event · Command · Query · Policy · Specification · Process · Repository · Factory · State Machine · Provenance · R-A · R-B · R-C**, plus la **Checklist Projection** (ajoutée par F3.3.99 §7) : □ recalculable depuis des faits nommés □ sources citées □ jamais persistée comme vérité □ jamais décisionnelle (l'acte re-vérifie à la source) □ datée et dite périmée si servie. Les quinze checklists couvrent les quinze objets qu'une PR peut introduire ; chaque case est binaire.

## 12. Anti-Pattern Handbook — les 18

Les quinze de F3.1.17 (aggregate anémique, God, Entity intelligente, VO mutable, obsession primitive, repository métier, factory universelle, spec géante, service fourre-tout, app-service omniscient, projection persistée, read model mutable, process omniscient, événement-commande, cache de validité) **plus trois nés des audits F3.2/F3.3.99** : (16) **le service de réservation** (l'état verrouillé hors registre ; solution : clé déclarée) ; (17) **la copie de matière par domaine** (deux gardes pour un contenu ; solution : la personne emporte, l'adoptant re-dépose) ; (18) **l'Entity au NON clandestin** (une Entity dont une commande vient d'un autre détenteur de NON ; solution : promotion en unité, provenance citée — ajoutée par F3.3.99 §8).

## 13. Constitutional Index

Le chemin de trente secondes : **un mot** → Glossaire (§1) → sa loi (F2.9 / R-A-B-C §10) → son propriétaire (Catalogue §2) → ses faits (§3) / commandes (§4) / lectures (§5) → sa Checklist (§11) → son anti-pattern (§12). Chaque catalogue référence F2 et F3 par numéro de section.

## 14. Loi des totaux dérivés (audit qualité)

*Le catalogue fait foi, jamais le chiffre ; aucun total manuel n'est propriétaire d'une vérité ; un catalogue qui change change son total sans réécrire la Constitution.* Les six totaux jadis écrits à la main (25, 58, 52, 15, 9, 17) étaient les seuls faux ; ils sont désormais **dérivés** de leurs énumérations (30, 73, 79, 16, 11, 18). Ratifications Titre VII consolidées et closes : `FundsLedger`, grille R-C (§5), capacité « retrait d'invitation » différée.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F3.3** (le gel documentaire tactique) et **F3.3.99** (six corrections documentaires intégrées) : (1) le State Machine Catalogue §8 devient seul propriétaire des transitions ; (2) totaux dérivés — **30** unités, **73** faits, **79** commandes, **16** politiques, **11** lectures, **23** questions, **18** anti-patterns ; (3) `ExpressSearch` supprimée ; (4) Checklist Projection ajoutée (15 checklists) ; (5) 18ᵉ anti-pattern (l'Entity au NON clandestin) ; (6) Glossaire fermé par l'entrée « Ledger ». Les énumérations exhaustives des faits et commandes restent la propriété du Dictionnaire (F2.5) et des dessins (chapitres 02-04) ; ce chapitre en donne la structure de catalogue, les comptes autoritaires et ses règles propres (Query/R-C, checklists, anti-patterns, lois tactiques consolidées). Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
