# Account Domain Blueprint — EPIC-002, Phase 0 (architecture, zéro code)

**Statut** : PROPOSÉ — à ratifier par le CTO avec la [RFC-003](../canon/decisions/rfc/rfc-003-account-instruction.md) · **Modèle** : le domaine de référence Identity ([handbook](../reference/identity-reference-handbook.md), [bootstrap guide](../reference/new-domain-bootstrap-guide.md)) · **Sources canon** : F3.2-B / F3.2-B.99 (ch. 03 domaine 6), catalogues 01/02/03/04/05/08, dictionnaire ch. 04 §Account, context map ch. 02 (OHS, ACL, arêtes 7-12) · Date : 2026-08-19.

## 1. Vision

Le Compte est **la vérité « qui est la personne dans Mentora »** : son identité, ses choix (préférences typées), sa joignabilité, son cadre de disponibilité, son contrat commercial, ses demandes d'aide. C'est le **seul Open Host Service métier** (ch. 02 : consommateurs nombreux et hétérogènes des identifiants et préférences) et le **propriétaire des deux ACL** qui isolent les génériques : Identity & Access (la preuve) et Settlement (le règlement de l'abonnement).

## 2. Responsabilités (ce qu'Account possède)

| Possède | Ne possède PAS (et qui possède) |
|---|---|
| L'identité de la personne enregistrée, `VerificationState` | La preuve d'entrée, les facteurs, les sessions — **I&A** (le Compte ne voit jamais une matière ni un `Credential` autrement que par référence) |
| Préférences typées, joignabilité (`ReachabilityChannel`), appareils (`Device`) | Le contenu des signaux — **Notification** (lit la joignabilité par l'unique lecture montante sanctionnée) |
| `AvailabilityFrame` (le cadre publié) | Les accords, la consommation du cadre **en donnée** (loi 15) — **Engagement** ; le calendrier assemblé = `CalendarProjection` (projection, jamais une vérité) |
| `Subscription` (Commissioner du Règlement) | L'exécution de l'ordre — **Settlement** (compte rendu au seul commanditaire) |
| `SupportRequest` (état seul) | Les dialogues d'aide — **Messaging** (Conversations) |
| La jonction preuve↔personne (ACL Compte↔Credential) | Les droits métier des autres domaines (chacun refuse chez lui — T-9) |

**Garde-fou §18 de la mission** : aucune responsabilité d'Identity ne migre. Account **commande** `EstablishCredential`/`RevokeCredential` à travers son ACL (M-10, émetteur en liste close) et **lit** rien d'I&A ; I&A ne lit rien d'Account (`PersonId` opaque). Le stand-in ACL de l'e2e gateway est précisément ce qu'A05 remplace.

## 3. Limites (refus explicites)

- Aucune commande/fait/Query hors catalogue (les 11/7/2 ci-dessous et rien d'autre) ; `Workspace` refusé (canon) ; `VerifyAccount` n'existe pas (RFC-003 P6).
- Aucun état hors machines ratifiées (pas de `Pending` de souscription — P4).
- Aucune lecture d'I&A comme fait métier (« connecté » n'est pas une vérité).
- Aucune donnée de surface promue vérité (libellé d'appareil, avatar, etc.).

## 4. Agrégats

| Unité | Identité | Machine | Entities / VOs | Factory | Spécifications | Faits |
|---|---|---|---|---|---|---|
| `Account` | `PersonId` comme identité (singleton-par-acteur — **P1**) | `Active → Closed` (terminal, R-B) | `Device` (Entity : `DeviceId`, `registeredAt` — **P7**) ; `Preference` (typée : `NotificationPreference`, `LanguagePreference`, `Timezone`), `ReachabilityChannel`, `VerificationState` | naissance par `RegisterPerson` (porte de factory) | `ClosableAccountSpecification` | `PersonRegistered`, `PreferenceChanged` (typée), `ReachabilityChanged`, `AccountClosed` |
| `AvailabilityFrame` | singleton-par-Compte (= `PersonId` — **P2**) | vivante (aucun terminal) | `AvailabilityWindow[]` | implicite au premier `ChangeAvailabilityFrame` (**P2**) | `CoherentFrameSpecification` (fenêtres cohérentes) | `AvailabilityFrameChanged` |
| `Subscription` | `SubscriptionId` | `Active → Ended` (terminal, R-B : re-souscrire = unité nouvelle) | termes figés (référence d'offre) | `SubscriptionFactory` | `SubscriptionChangeSpecification` ; **clé R-A** « une souscription active par titulaire » (refus dérivé `SubscriptionAlreadyExists`, famille ratifiée `<Truth>AlreadyExists`) | `SubscriptionStarted`, `SubscriptionEnded` |
| `SupportRequest` | `SupportRequestId` | `Opened → Handled` (terminal) | `SupportRequester` (qualifié), motif (référence) | naissance par `OpenSupportRequest` | — | **aucun** (droit, pas devoir) — structurel : pas de `pendingFacts`, pas de tables outbox/fact-stream (précédent Session) |

**Invariants métier** : fermé ⇒ plus rien ne change (tout `act` sur `Closed` = `TransitionUnavailable`) ; une souscription active à la fois (R-A au registre) ; fenêtres cohérentes (refus motivé à `ChangeAvailabilityFrame`) ; aucune matière, aucun contenu d'aide dans l'unité ; `Device` sans référence entrante.

## 5. Policies & Domain Services

- `ReachabilityPolicy` (possédée par Account, consommée par Notification) — params produit = allowlist de canaux (**P5**) ; juge `ChangeReachability`.
- `SubscriptionPolicy` — params produit = allowlist d'offres (**P5**) ; juge `StartSubscription` avec `SubscriptionChangeSpecification`.
- **Domain Services : zéro** (canon : « Zéro Domain Service dans les quatre domaines »).

## 6. Commands (catalogue 36-46, émetteurs en liste close — M-10)

| # | Command | Unité | Émetteur | Refus possibles |
|---|---|---|---|---|
| 36 | `RegisterPerson` | Account (naissance) | l'entrée (vestibule) — via l'entrée non authentifiée, **avant** `EstablishCredential` (A05) | R-B (identité habitée) |
| 37 | `ChangePreference` | Account | le Titulaire | `TransitionUnavailable` (fermé) |
| 38 | `ChangeReachability` | Account | le Titulaire | policy (canal non admis), fermé |
| 39/40 | `RegisterDevice` / `RemoveDevice` | Account (sans fait) | le Titulaire | fermé ; appareil inconnu |
| 41 | `CloseAccount` | Account | le Titulaire (UX-06 : confirmation AVANT) | `ClosableAccountSpecification` |
| 42 | `ChangeAvailabilityFrame` | AvailabilityFrame | le Titulaire | `CoherentFrameSpecification` |
| 43/44 | `StartSubscription` / `EndSubscription` | Subscription | le Titulaire ; `EndSubscription` aussi par la Réaction `AccountClosed` (**P3**) et par `SettlementOrderFailed` via ACL (**P4**) | R-A `SubscriptionAlreadyExists`, policy |
| 45/46 | `OpenSupportRequest` / `HandleSupportRequest` | SupportRequest (sans fait) | le Requester / la plateforme | `TransitionUnavailable` |

**Droits d'émission** : RFC-002 Option C s'applique (le gateway n'admet que ce dont l'émetteur est tranché) ; Option A (grille d'émission au pas 5) **s'instruit ici** : « le Titulaire » = l'ActorRef injecté doit être l'identité du Compte visé — la première grille d'émission réelle de Mentora (donnée fournie au pas 5 par le porteur, refus à trancher au dictionnaire).

## 7. Events (catalogue 40-46)

`PersonRegistered` (identité, instant, `VerificationState` initial) · `PreferenceChanged` (typée : quelle préférence, nouvelle valeur — jamais de contenu libre) · `ReachabilityChanged` (canal) · `AccountClosed` (motif référence) · `AvailabilityFrameChanged` (fenêtres) · `SubscriptionStarted` (référence d'offre, Commissioner) · `SubscriptionEnded` (motif). Tous : références et natures ; wires dans `contracts-account` avec sérialiseur déterministe (V-1). `RegisterDevice/RemoveDevice`, `Open/HandleSupportRequest` : **sans fait** (canon).

## 8. Read Models & lectures ratifiées (F3.3 §5)

| Query | Ayant droit (grille R-C) | Réponse (⊘) | Source |
|---|---|---|---|
| `AvailabilityFrameQuery` (#4) | **tous** (cadre publié) | les fenêtres ⊘ tout le reste du Compte | photo `AvailabilityFrame`, primaire |
| `ReachabilityQuery` (#10) | **la Notification (sanctionnée) + le Titulaire** | le canal ⊘ préférences, appareils | photo `Account`, primaire |

Raisons de refus de lecture : `RightMissing` / `AccountUnavailable` (précédent signalé Agreement, famille `-Unavailable`). **Aucune autre lecture** (pas de « ProfileQuery » : le profil assemblé est `PublicProfileProjection`, propriété de la Découverte).

## 9. Ports

| Port | Propriétaire | Forme | Implémenté par |
|---|---|---|---|
| `AccountRepository` (`byId`, `retain(unit, ctx?)`) | domaine | précédent I&A | `PrismaAccountRepositoryAdapter` |
| `AvailabilityFrameRepository` (`byId`, `retain`) | domaine | idem | Prisma |
| `SubscriptionRepository` (`byId`, `activeByHolder` — sonde R-A, `retain`) | domaine | idem | Prisma (clé R-A = index unique partiel `WHERE stateKind='Active'`) |
| `SupportRequestRepository` (`byId`, `retain` — état seul) | domaine | précédent Session | Prisma (photo seule) |
| `AvailabilityFrameReadPort`, `ReachabilityReadPort`, `AccountReadRightsPort` | application | précédent `AgreementStateReadPort`/`ReadRightsPort` | `PrismaAccountStateReadAdapter` |
| `IdentityAccessAclPort` (commander `EstablishCredential`/`RevokeCredential`, sceller/désavouer la matière) | application (ACL Compte, A05) | traduction sortante = **ordres**, jamais faits (M-7) | adapter vers le `CommandDispatch` I&A + coffre (le stand-in e2e en est le brouillon) |
| `SettlementAclPort` (commander `SettlementOrder` pour l'abonnement ; recevoir `ExecutionReport`) | application (ACL Compte) | idem | **déféré** : adapter avec Settlement ; adapter « aucun Règlement » déclaré en dev (**P4**) |

## 10. Adapters attendus

`contracts-account` · `domain-account` · `application-account` · `adapters-persistence-account` (schema RC-1 : 4 photos ; fact-stream/outbox/inbox pour Account, AvailabilityFrame, Subscription ; **rien** pour SupportRequest ; migration 0001 manuelle ; `MENTORA_ACCOUNT_DATABASE_URL`, base `mentora_account_test`) · `adapters-account-acl` (I&A + Settlement-null) · entrée : `RegisterPerson` admis à `/entry` (acte non authentifié du vestibule), les autres commandes à `/commands` sous grille d'émission, les 2 lectures à `/queries`.

## 11. Contract Suites

`accountRepositoryContractSuite` (naissance/reconstitution, fermé ⇒ immuable, R-B, version périmée = Failure) · `availabilityFrameRepositoryContractSuite` · `subscriptionRepositoryContractSuite` (**R-A appliquée ET libérée**, sonde `activeByHolder`) · `supportRequestRepositoryContractSuite` (**rétention état-seul**, précédent Session) · rejeu sur mémoire (domaine) et PostgreSQL (adapter) · `relayContractSuite` sur l'outbox Account · suite d'ACL (ordres traduits, jamais de fait) sur doubles.

## 12. Dépendances (noms du canon — les noms de la mission sont traduits)

| Mission | Canon | Relation |
|---|---|---|
| Identity | Identity & Access | **Account → I&A (ACL)** : commande la preuve ; `PersonId` opaque ; I&A ne lit rien d'Account |
| Agreement | Engagement | **Engagement → Compte (le cadre)** : consomme `AvailabilityFrame` **en donnée** (loi 15 : fourni, jamais cherché) — Account ne dépend pas d'Engagement |
| Scheduling | *(pas un domaine)* = `AvailabilityFrame` (Account) + `CalendarProjection` (projection cadre ⊕ accords) | possédé ici ; la projection est une dérivation, jamais persistée comme fait |
| Payments | Settlement (générique) | **Account → Settlement (ACL, abonnement)** ; compte rendu au seul commanditaire |
| Wallet | **vocabulaire interdit** (VD : *Wallet → AvailableFunds*, domaine Économie) | **aucune arête Account ↔ Économie dans le Corpus** ; n'existe pas |
| Notification | Notification (générique) | **Notification → Account (joignabilité)** : l'unique lecture montante sanctionnée (`ReachabilityQuery`, grille R-C) ; `ReachabilityPolicy` possédée ici |

Cycles : zéro (le cycle historique Compte⇄Notification est mort par « connaissance-dans-l'ACL »). Dépendances de build : `contracts-account` ← `contracts`/`kernel` ; `domain-account` ← `contracts-account` ; `application-account` ← `application-kernel`, `domain-account`, **`contracts-identity`** (les wires qu'elle commande via l'ACL) ; persistance ← runtime-*.

## 13. Machines d'état (catalogue §8)

`Account` : `Active → Closed` · `Subscription` : `Active → Ended` · `SupportRequest` : `Opened → Handled` · `AvailabilityFrame` : vivante (changements, aucun terminal). Toute transition absente = `TransitionUnavailable`. R-B partout : revenir = unité nouvelle à provenance citée.

## 14. Chemin critique

**RFC-003 ratifiée** → A01 (Account + AvailabilityFrame, domaine) → A02 (Subscription + SupportRequest, domaine) → A03 (application : porteurs, **les 2 lectures ratifiées**, composition) → A04 (persistance, rejeu des suites) → A05 (ACL I&A : `RegisterPerson`→`EstablishCredential`, `CloseAccount`→`RevokeCredential`, flux fédéré branché, RFC-002 Option A première grille) → entrée gateway + e2e → certificat. A05 est le **point de convergence** avec Identity (#100-#103, flux fédéré) ; Settlement reste un port sans adapter jusqu'à son propre Epic.
