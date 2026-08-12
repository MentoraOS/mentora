---
doc: f3-03-aggregates-identity-collaboration
title: F3.2-B — Aggregate Design, Identity & Collaboration (état final ratifié)
type: source
titre: domain
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 4B)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 4B"
sources_session:
  - "F3.2-B — Aggregate Design Identity & Collaboration (Account, Enterprise, Consent, Messaging)"
  - "F3.2-B.99 — Identity & Collaboration Tactical Audit (rédaction définitive de R-A ; règle du contrat commercial ; règle d'identité singleton-par-acteur ; R-B et le regret via UX-06 ; confirmations)"
  - "F3.2.99 — Grand Tactical Audit (confirme les unités des groupes B sans les amender ; R-C réservée au chapitre de clôture)"
note: >-
  Reconstruction fidèle de l'état final ratifié des quatre domaines Identity &
  Collaboration, après F3.2-B.99. Le Grand Audit F3.2.99 confirme ces unités
  sans amendement nouveau (démontré). Ce chapitre possède les designs d'agrégats
  du groupe B ; les raffinements de lois tactiques nés ici (R-A définitive,
  contrat commercial, identité singleton-par-acteur) sont consolidés au chapitre
  de clôture (Lot 4C). R-C n'apparaît pas ici. Langage suivant le Dictionnaire
  (F2.5), blocs suivant F3.1. Scaffolding de session exclu. Titre VII pour toute
  évolution.
---

# F3.2-B — Aggregate Design — Identity & Collaboration

> État **final ratifié** : Account, Enterprise, Consent, Messaging.

## Domaine 6 — Account

**Quatre unités** : `Account`, `AvailabilityFrame`, `Subscription`, `SupportRequest`.

- **`Account`** — l'identité et les choix de la personne. NON : Titulaire + plateforme (vérification). Invariant : fermé ⇒ plus rien ne change. **`Person` n'est pas un Aggregate** (la Personne est un *acteur*, F2.5 §9 ; la vérité « qui est la personne dans Mentora » EST le compte). **`Reachability` et `Preferences` restent DANS `Account`** (même acteur, aucun invariant propre au-delà de VO auto-validants). **`Device`** reste **Entity** d'`Account` (même acteur, aucune référence externe : I&A référence SES `Credential`, jamais le Device).
- **`AvailabilityFrame`** — unité propre (le Cadre au Compte ; l'Engagement le consomme en donnée, loi 15). NON : Titulaire ; invariant : fenêtres cohérentes.
- **`Subscription`** — unité propre : cycle `Active → Ended`, **Commissioner du Règlement** via l'ACL du Compte. NON : Titulaire ; plateforme sur les règles ; invariant : une souscription active à la fois (clé R-A).
- **`SupportRequest`** — **promu Aggregate** par le test du NON clandestin (le Requester l'ouvre, la plateforme la traite et la clôt). États : `Opened → Handled`. **Aucun fait publié** (droit, pas devoir ; les dialogues d'aide sont des Conversations).
- **`Workspace` refusé** comme unité, `WorkspaceCreated/Closed` refusés comme faits (corpus P9.6 §3.11 : « aucune donnée métier » ; F2.2 Lot 3 a tué `EspaceDeTravailChangé`).

**VOs** : `Preference` (typée), `NotificationPreference`, `LanguagePreference`, `Timezone`, `ReachabilityChannel`, `AvailabilityWindow`, `VerificationState`. **State machines** : `Account` `Active → Closed` (la fermeture se propage aux unités sœurs par le fait `AccountClosed` — chorégraphie interne ; R-B : revenir = nouvelle personne enregistrée) ; `Subscription` `Active → Ended` (re-souscrire = unité nouvelle, R-B) ; `SupportRequest` `Opened → Handled` ; `AvailabilityFrame` vivant. **Commands** : `RegisterPerson · ChangePreference · ChangeReachability · RegisterDevice/RemoveDevice · CloseAccount (ClosableAccountSpecification) · ChangeAvailabilityFrame · StartSubscription/EndSubscription · OpenSupportRequest/HandleSupportRequest`. **Events** (gelés) : les sept (`PersonRegistered · AccountClosed · PreferenceChanged · ReachabilityChanged · AvailabilityFrameChanged · SubscriptionStarted · SubscriptionEnded`). **Specs** : `ClosableAccountSpecification`, `CoherentFrameSpecification`, `SubscriptionChangeSpecification`. **Policies** : `ReachabilityPolicy`, `SubscriptionPolicy`. **Domain Services** : aucun. **Factory** : `SubscriptionFactory`. **Ports** : quatre registres, R-A sur l'unicité d'abonnement actif.

## Domaine 7 — Enterprise

**Cinq unités**, quatre NON, aucun clandestin :

- **`Organization`** — créée, vit, régit ses invitations émises par référence.
- **`Invitation`** — **Aggregate** (le NON clandestin : l'Organisation émet, le **Membre** accepte ou décline). États : `Issued → Accepted | Declined` (terminaux) ; provenance `OrganizationId`. *(Le retrait d'une invitation émise n'existe pas au langage gelé — capacité **différée** au Titre VII.)*
- **`Membership`** — **Aggregate né par R-B** (l'acceptation est terminale pour l'Invitation ; l'appartenance est une unité nouvelle citant `InvitationId + OrganizationId`). Test décisif : l'appartenance **survit** à son invitation (un état ne survit pas à son porteur, une unité si). États : `Active → Revoked` (terminal ; l'Auteur porté). Naissance publiée par `InvitationAccepted` ; `MembershipRevoked` clôt ; aucun `MembershipEstablished` inventé.
- **`OrganizationVerification`** — **unité de preuve propre** (constatée par un acteur étranger, le Verifier ; append-only ; le vérifié ne tient jamais sa vérification).
- **`Sponsorship`** — Aggregate `Granted → Revoked`, provenance `OrganizationId + MembershipId`, consommé par l'Engagement (éligibilité) et l'Économie.

**VOs** : `InvitationTerms`, `SponsorshipTerms`, `VerificationRecord`. **Events** (gelés) : les huit. **Specs** : `AcceptableInvitationSpecification`, `RevocableMembershipSpecification`. **Policy** : `SponsorshipPolicy`. **Domain Services** : aucun. **Factory** : `MembershipFactory`. **Registres** : R-A sur « une appartenance active par (Organisation, Personne) » — Décision `MembershipAlreadyExists`.

## Domaine 8 — Consent

**`ConsentLedger`** — **une unité par Accordant** : tout ce que cette personne a accordé, refusé, retiré. Frontière minimale qui rend vrais ensemble l'immuabilité de l'histoire, **la porte close du refus définitif** (visible à l'instant de toute sollicitation, sans registre interrogé) et l'absence-vaut-non. Racine à NON multiples licites : l'Accordant (accorder, refuser, retirer) et le **Custodian** (invalider, motivé) — acteurs de la racine, pas d'une Entity.

**Entities** : `ConsentGrant` (`Granted → Withdrawn | Expired | Invalidated`, chaque transition un fait gelé), `ConsentRefusal` (immuable, drapeau définitif par type — la mémoire de la porte). **VOs** : `ConsentScope`, `ConsentType` (définitivité — `ConsentDefinitivenessPolicy`), `GrantDuration`, `ActorRef`, `SampleInstant`. **Events** : les cinq gelés, aucun de plus ; expiration sur instant fourni. **`ConsentValidityQuery` synchrone, servie du Ledger — aucun cache de validité, nulle part, jamais** (Titre VI). **Specs** : `ActiveGrantSpecification`, `DefinitivelyRefusedSpecification`. **Factory** : aucune. **Registre** : `ConsentLedgerRepository` (byGrantorId). **La combinaison des scopes n'est PAS ici** — elle appartient aux consommateurs (la règle du double accord est à la Consultation, `EncounterConsentCombinationPolicy`).

## Domaine 9 — Messaging

**`Conversation`** — **Aggregate né uniquement par l'acte d'une personne** (`OpenConversation`, Interlocutor ; aucun domaine ne le peut : le mur de F2.2 devient un refus de Factory). États : `Open → Closed` (terminal ; reprendre la parole = nouvelle Conversation, R-B). **`Message` : Entity** (ses auteurs sont les Interlocuteurs de SA racine ; aucune référence externe ne le vise ; aucun NON propre ; **jamais adressable directement**). **`ConversationReport` : Entity** (cohérence avec `ReviewReport` ; la police s'exerce SUR l'unité gardée, par le Custodian). Verdict : `ConversationVerdictRendered` (gelé) — l'issue frappe le contenu illicite (`Struck`) sans réécrire l'histoire.

**Contenu privé — structurel** : le contenu vit à l'intérieur ; `MessageSubmitted` publie la métadonnée seule (« sans contenu ») ; `ConversationQuery` restreinte au participant (refus `ConversationNotFound` pour tout autre — l'existence même n'est pas due aux tiers). **VOs** : `MessageContent` (intérieur), `ExcerptEvidence` (porté par l'acte du signaleur — le pont), `InterlocutorRef`. **Specs** : `OpenConversationSpecification` (joignabilité fournie en donnée). **Domain Services** : aucun. **Factory** : `ConversationFactory` (refuse tout commanditaire non-personne). **Registre** : byId + byInterlocutor.

---

# Amendements et raffinements de F3.2-B.99

**Amendements de groupe (confirmés constitutionnels)** : (1) `Invitation` et `Membership` Aggregates distincts (test de survie) ; (2) `SupportRequest` promu Aggregate (la plateforme décide : recevabilité + traitement) ; (3) `Subscription` unité propre ; (4) `Workspace` définitivement exclu ; (5) `ConsentLedger` — une unité par Accordant, la porte du refus définitif dans la frontière ; (6) `Message` jamais adressable directement, naissance des conversations verrouillée en Factory ; (7) capacité « retrait d'invitation » différée au Titre VII ; (8) `OrganizationVerification` unité de preuve propre.

**Raffinements de lois tactiques nés ici** *(consolidés au chapitre de clôture, Lot 4C)* :
- **R-A — rédaction définitive** : *la règle appartient au domaine (Specification nommée) ; la clé appartient au domaine (déclarée, dérivée de la règle) ; l'application appartient au registre (structurelle, à la rétention) ; le refus appartient à la Décision (motivée) ; l'infrastructure exécute la clé, elle ne connaît jamais la règle.*
- **Règle du contrat commercial** : un contrat commercial est une **unité** quand il a un cycle de vie et des refus propres (`Subscription`) ; il est un **Value Object** quand il est les termes figés de l'acte d'une autre unité (`AgreementConditions`). Le critère est le NON et le devenir, jamais la nature « commerciale ».
- **Règle d'identité singleton-par-acteur** : une unité singleton-par-acteur peut porter l'identifiant de son acteur comme identité (référence-comme-identité, sans signification mutable, sans dérivation) — la seule exception écrite à « jamais dérivé », bornée à un par acteur.
- **R-B et le regret** : le regret (« je ferme mon compte, je me ravise ») est tranché par **UX-06** (jamais irréversible en un geste — la confirmation est AVANT le fait) ; le domaine ne connaît que l'acte confirmé, terminal ; le retour est une unité nouvelle à provenance citée. R-B **sans exception**.

> **Zéro Domain Service dans les quatre domaines.**

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F3.2-B** (Account, Enterprise, Consent, Messaging) et **F3.2-B.99** (amendements de groupe + raffinements de lois tactiques). **Démonstration d'absence d'amendement nouveau du Grand Audit F3.2.99** : son §4 recense les unités du groupe B à l'identique (Account 4, Enterprise 5, Consent 1, Messaging 1) et n'en modifie aucune ; sa loi **R-C** est transversale et matérialisée au [chapitre 05 (Grand Audit)](05-grand-tactical-audit.md) — non anticipée ici. Les raffinements de R-A/R-B et les deux règles nouvelles (contrat commercial, identité singleton-par-acteur) sont consolidés au [chapitre 06 (F3.3 §10)](06-tactical-documentation-freeze.md). Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
