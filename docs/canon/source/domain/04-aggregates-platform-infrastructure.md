---
doc: f3-04-aggregates-platform-infrastructure
title: F3.2-C — Aggregate Design, Platform & Infrastructure (état final ratifié)
type: source
titre: domain
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 4B)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 4B"
sources_session:
  - "F3.2-C — Aggregate Design Platform & Infrastructure (Expert Economy, Augmentation, Identity & Access, Settlement, Notification, Storage)"
  - "F3.2-C.99 — Platform & Infrastructure Tactical Audit (chaîne d'adoption corrigée ; Retry ≠ Replay ; DestroyRecord refusé ; confirmations)"
  - "F3.2.99 — Grand Tactical Audit (confirme les unités du groupe C ; précisions de provenance cohérentes, non amendantes ; R-C réservée au chapitre de clôture)"
note: >-
  Reconstruction fidèle de l'état final ratifié des six domaines Platform &
  Infrastructure, après F3.2-C.99. Le Grand Audit F3.2.99 confirme ces unités et
  restate les provenances (Deposit←Artifact, Payout via RevenueSource) de façon
  cohérente, sans amendement nouveau (démontré). Ce chapitre possède les designs
  d'agrégats du groupe C ; les raffinements de lois tactiques nés ici (chaîne
  d'adoption, Retry≠Replay) sont consolidés au chapitre de clôture (Lot 4C). R-C
  n'apparaît pas ici. Langage suivant le Dictionnaire (F2.5). Scaffolding de
  session exclu. Titre VII pour toute évolution.
---

# F3.2-C — Aggregate Design — Platform & Infrastructure

> État **final ratifié** : Expert Economy, Augmentation, Identity & Access,
> Settlement, Notification, Storage. Les quinze domaines sont désormais tous
> dessinés tactiquement (5 + 4 + 6).

## Domaine 10 — Expert Economy

- **`FundsLedger`** — **une unité par expert** (singleton-par-acteur ; identité = ExpertId ; nom **soumis à ratification Titre VII**). L'invariant cardinal — **nul Retrait au-delà du Disponible** — est une **somme** sur les faits d'argent ; une somme n'est pas une clé structurelle (R-A ne s'applique pas) : elle exige la frontière qui contient tous ses termes à l'instant du refus. *(Une somme exige une frontière ; une identité exige une clé — un registre qui appliquerait une somme comprendrait le métier, ce que R-A interdit.)*
- **`AvailableFunds`** — **PROJECTION** (dérivation déterministe des faits du Ledger, calculée dedans pour refuser `RequestPayout`, servie dehors par `AvailableFundsQuery`). Jamais une unité (ce serait persister une projection).
- **`PayoutRecord`** — **Entity du Ledger** : le refus « ≤ Disponible » se rend **dans la même transaction** que la demande (un Payout-Aggregate séparé mettrait l'invariant en course). Acteurs licites de la racine (l'Expert demande, le Commissioner rapporte via l'ACL). États : `Requested → Completed | Failed` (terminaux ; réessayer = nouvelle demande, R-B).
- **`Goal`** — unité propre, immuable (déclarée, jamais mutée ; l'objectif « courant » = projection du dernier déclaré). Nouvelle déclaration = nouvelle unité.
- **`Opportunity`** — **PROJECTION** (personne ne la constate ; dérivée, citée, périmée).

**Naissances** : `RevenueRecognized` naît dans le Ledger (`RecognizeRevenue` sur `EncounterClosed`, `RevenueRecognitionPolicy` ; la **décision** de reconnaissance appartient au Ledger — refus si fait générateur absent, doublon par provenance : clé R-A sur `EncounterId`). `RevenueAdjusted` sur `EncounterInterrupted`. `PayoutRequested/Completed/Failed` dans le Ledger. `GoalDeclared` dans sa propre unité. **VOs** : `Money` (devise via configuration GE), `RevenueSource` (provenance `EncounterId`), `AdjustmentReason`, `PayoutDestination`. **Specs** : `PayableAmountSpecification`, `RecognizableRevenueSpecification`. **Policies** : `RevenueRecognitionPolicy`, `PayoutAvailabilityPolicy`. **Factory** : aucune. **Registres** : `FundsLedgerRepository` (byExpertId), `GoalRepository` — R-A sur l'unicité de reconnaissance par rencontre. **Domain Services** : zéro.

## Domaine 11 — Augmentation

**`Production`** — l'unique Aggregate : le registre de « ce que la machine a produit et avait le droit de produire ». Née par `RequestProduction` (**une personne**, jamais un domaine — refus dans la Factory) avec **preuve de consentement fournie en donnée** (fail closed à la naissance, loi 18). États : `Requested → Delivered` (terminal) ; l'indisponibilité de capacité **n'est PAS un état : c'est le silence** (aucune remontée simulée — AE ; l'unité `Requested` sans suite se périme sans fait). **VOs** : `Proposal` (la nature ; le **contenu va en Dépôt** — P7 par transitivité ; l'unité porte la référence), `AIAttribution` (obligatoire), `Citation` (AE-06), `StatedUncertainty` (AE-05), `ConsentEvidence`. **Vérifications structurelles** : l'IA ne décide jamais — la `Production` n'a **aucune commande sortante**, aucun consommateur-domaine ; la proposition n'est jamais un fait ; **l'adoption appartient à une personne**, constatée par le domaine adoptant (`ArtifactSubmitted`, provenance `ProductionId`). **Specs** : `ProducibleSpecification`. **Policy** : la cage AE publiée. **Registre** : byId, byRequester. **Zéro Domain Service.**

## Domaine 12 — Identity & Access

- **`Credential`** — établi par l'ACL du Compte ; états `Active → Revoked` (terminal ; ré-entrer = nouveau Credential, R-B). **Entities** : `Factor` (même acteur, aucune référence entrante). **VOs** : `FactorKind`, `ProofStrength`. **Aucun secret dedans, jamais** (invariant : la matière des facteurs ne quitte pas l'unité — symétrique du contenu des Messages). `Credential` n'est jamais `Person` (le lien preuve↔personne vit dans l'ACL du Compte). R-A : un Credential actif par (personne × facteur-principal). Révocation immédiate (`RevokeCredential` prioritaire par contrat).
- **`Session`** — ouverte sur preuve ; provenance `CredentialId` ; états `Active → Ended | Revoked` (terminaux). **NON propre** (se terminer, être révoquée seule — « déconnecter cet appareil » sans révoquer la preuve ; plusieurs sessions par credential). **Aucun fait publié** (« connecté » n'est jamais un fait métier ; ce qui n'est pas publié ne peut pas fuir). **Faits** : `CredentialEstablished / CredentialRevoked` — références et natures, aucune matière. **Policy** : `ProofRequirementPolicy`.

## Domaine 13 — Settlement

**`SettlementOrder`** — l'unique Aggregate : reçu du Commissioner par son ACL ; états `Received → Executed | Failed` (terminaux). **Idempotence et R-B articulées** : la re-soumission de la MÊME identité d'ordre est dédupliquée (clé R-A sur l'identité d'acte) ; le **réessai délibéré après échec est un ordre NOUVEAU**, provenance citée. **Entities** : aucune. **VOs** : `OrderInstruction` (montant, destination — jamais de sens), `SettlementChannel`, `ExecutionReport` (traduit par l'ACL du Commissioner). **Le NON** : technique seulement (ordre malformé refusé à la porte, échec constaté). **Compte rendu au seul Commanditaire** — structurel (`SettlementOrderExecuted/Failed` adressés au seul canal de retour). Aucun montant interprété, aucun dialecte au-delà de l'adapter.

## Domaine 14 — Notification

**`Signal`** — l'unique Aggregate : **la livraison d'un signal remis**. États : `Remitted → Delivered | Undeliverable` (terminaux ; re-signaler = nouveau Signal, R-B). **Entities** : `DeliveryAttempt` (append-only dans l'unité). **VOs** : `SignalEnvelope` (**métadonnées seules — le contenu n'est jamais lu** : transporté scellé), `ReachabilityChannel` (résolu par **l'unique lecture montante sanctionnée** — la Joignabilité du Compte). **Faits** : `SignalDelivered / SignalUndeliverable` — **à l'Émetteur seul**. **Policy consommée** : `ReachabilityPolicy` (possédée par le Compte). Le générique reste muet : ne publie rien au monde, ne lit rien d'autre, ne décide jamais de signaler.

## Domaine 15 — Storage

**`Deposit`** — l'unique Aggregate : la garde d'un dépôt remis. États : `Stored → Destroyed` (terminal — destruction constatée sur **instant fourni** contre la `Retention` portée par l'ordre : la durée est une **donnée du Commanditaire**). **La Restitution n'est pas un état : c'est un acte** — `ReturnDeposit` (au seul Déposant — refus structurel à quiconque d'autre), enregistré (`ReturnRecord`, Entity append-only), fait `DepositReturned` au Déposant seul ; la garde continue après restitution, jusqu'à la rétention. **VOs** : `DepositReference` (opaque), `Retention` (bornes), `CustodySeal` (intégrité — le contenu n'est jamais interprété : aucun contenu métier ne traverse autrement que scellé). **Specs** : `ReturnableDepositSpecification`, `DestroyableDepositSpecification`. **Policy** : `RetentionPolicy` (la grammaire des rétentions admissibles ; les durées restent aux ordres). Provenance : le Dépôt cite l'ordre et le Commanditaire. R-A : identité de dépôt unique. **Append-only** : la destruction est un fait, pas un effacement d'histoire (l'enregistrement de garde survit à la matière détruite — c'est lui, la preuve de conformité). **`DestroyRecord` refusé** (le fait `DepositDestroyed` + l'état terminal suffisent — un enregistrement second serait un doublon du fait).

---

# Amendements et raffinements de F3.2-C.99

**Amendements de groupe (confirmés constitutionnels)** : (1) `FundsLedger` singleton-par-expert, le Disponible calculé dedans et servi en projection ; (2) `PayoutRecord` Entity — l'invariant d'argent dans la transaction, réessai par R-B ; (3) `Goal` unité immuable, `Opportunity` projection ; (4) `Production` née de personne seule, cage AE structurelle ; (5) `Session` sans fait publié, secrets scellés ; (6) idempotence/R-B au Règlement ; (7) Restitution = acte, la garde survit à la matière ; (8) `DestroyRecord` refusé ; (9) ratification demandée : `FundsLedger`.

**Raffinements de lois tactiques nés ici** *(consolidés au chapitre de clôture, Lot 4C)* :
- **Chaîne d'adoption corrigée (LA faille close)** : `Production → Artifact` n'est ni une mutation, ni une copie de vérité, ni une simple référence : c'est un **acte nouveau de la personne — le pont — qui emporte la matière**. L'adoption commande un **Dépôt NOUVEAU, commandité par la Consultation** (qui en devient Déposant et pourra toujours restituer), à **provenance double citée** (`ProductionId` + `DepositId` d'origine). Règle générale : ***un domaine ne copie jamais — une personne emporte, l'adoptant re-dépose.*** (Sans cette correction, la Consultation n'aurait jamais pu relire l'artefact qu'elle possède, la Restitution n'étant due qu'au Déposant.)
- **Retry ≠ Replay** : le **Replay** est la re-livraison de la MÊME intention (at-least-once) → **déduplication structurelle** (clé R-A), aucune unité nouvelle ; le **Retry** est une intention NOUVELLE née d'un échec → l'ordre précédent est terminal (`Failed`), R-B s'applique (chaque tentative délibérée est une unité à provenance citée, lisible dix ans).

> **Zéro Domain Service dans les six domaines.**

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F3.2-C** (les six domaines Platform & Infrastructure) et **F3.2-C.99** (amendements de groupe + raffinements de lois tactiques). **Démonstration d'absence d'amendement nouveau du Grand Audit F3.2.99** : son §4 recense les unités du groupe C à l'identique ; ses précisions de provenance §9 (`Deposit ← Artifact` — l'Artifact cite son Dépôt, le Dépôt cite son Commanditaire ; `Payout` ne cite aucune rencontre, la chaîne d'argent passe par `RevenueSource: EncounterId`) sont des **restatements cohérents** de ce que F3.2-C avait fixé, non des amendements ; sa loi **R-C** est transversale, matérialisée au [chapitre 05 (Grand Audit)](05-grand-tactical-audit.md). Les raffinements (chaîne d'adoption, Retry≠Replay) sont consolidés au [chapitre 06 (F3.3 §10)](06-tactical-documentation-freeze.md). Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
