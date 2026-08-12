---
doc: canon-glossary-02
title: Vocabulary Diff — gardien de l'intégrité lexicale du Corpus (projection déterministe de la Source)
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 2 (Vocabulary Diff)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 2"
source_autorite:
  - "F2.3 — Ubiquitous Language • Domain Responsibilities • Public Contracts (renommage Signalement→Notification ; lois 10-13) — source/constitution/03-language-responsibilities-contracts.md"
  - "F2.5 — Dictionnaire bilingue (huit réservations, quintette du refus, vocabulaire interdit) — source/constitution/04-bilingual-dictionary.md"
  - "F2.2.99 / F3.3.99 — purges lexicales tactiques (faux événements, totaux dérivés, entrée Ledger)"
  - "F4.99 — Outbox qualifié — source/application/05-grand-application-audit.md"
  - "F5.1→F5.8 (.99) — réservations de la Production (Replica, Snapshot/Journal/Export, Recovery, Review, Publication, Capacity, Matière/Fait/Personne)"
  - "F5.99 Procès V & VIII — scories lexicales et « propriété émergente » (dettes)"
note: >-
  PROJECTION déterministe de la Source (docs/canon/source/), jamais une source.
  Le Vocabulary Diff est le gardien de l'intégrité lexicale : il prouve « un mot =
  un sens = un propriétaire ». Il ne crée aucun terme, ne change aucun
  propriétaire, ne résout aucune divergence (il la signale). Chaque entrée porte
  un identifiant permanent VD-NNNN (jamais réutilisé, survit aux renommages) et
  cite son chapitre propriétaire. Toute divergence Source ↔ projection est
  signalée, jamais corrigée ici. Extraction exclusivement depuis la Source
  matérialisée (règle N°31 ; le transcript n'est plus une autorité). Aucune
  mémoire, aucune interprétation, aucune harmonisation, aucune reformulation.
  Évolution : Titre VII uniquement.
---

# Vocabulary Diff — gardien de l'intégrité lexicale du Corpus

> **Un mot = un sens = un propriétaire.** Ce document **projette** les décisions
> lexicales de la Source ; il ne les modifie jamais et n'a aucun pouvoir éditorial
> (PG-5, PG-8 ; règle N°33). Toute **divergence** est **signalée, jamais
> résolue** ici (la résolution appartient à la Source, par Titre VII).

## Nature & règles (projection, jamais source)

- Le Vocabulary Diff **rassemble et compare** les termes ratifiés ; il n'en crée
  aucun et ne change aucun propriétaire.
- Chaque entrée porte un **identifiant permanent `VD-NNNN`** : il **ne change
  jamais**, **n'est jamais réutilisé**, **survit aux renommages** — il sert aux
  audits, RFC, scripts, changelogs et revues.
- **Une entrée ne disparaît jamais** ; elle est **historisée** (§H).
- Une **divergence** est **signalée** (marquée ⚠), **jamais corrigée** ici.
- Chaque entrée **référence son chapitre propriétaire** et son document source.
- La **vérification** exécutable (liens, `git diff --check`, un-mot-un-sens) est
  faite avant chaque commit ; le **résultat** est au rapport officiel.

Traçabilité de chaque entrée : *terme · propriétaire · chapitre propriétaire ·
statut · (si applicable) terme remplacé · (si applicable) terme de remplacement.*

---

## A. Nouveaux termes

Termes constitutionnels **officiellement apparus** dans la Source (chapitres qui
ont signalé leurs « entrées de glossaire dues »). Regroupés, jamais inventés.

| ID | Terme (FR → EN / identité) | Propriétaire | Chapitre | Statut |
|----|----|----|----|----|
| VD-0001 | la Flotte → *Fleet* (`FleetId`) | Exploitation | [F5.1 §16](../../source/production/01-runtime.md) | actif |
| VD-0002 | `ExecutableId` → `ArtifactId` → `InstanceId` | Runtime | [F5.1 §17](../../source/production/01-runtime.md) | actif |
| VD-0003 | la preuve d'artefact → *artifact proof* | Runtime (Boot) | [F5.1 §18](../../source/production/01-runtime.md) | actif |
| VD-0004 | le Registre → *Registry* | domaine (par vérité) | [F5.2 §1](../../source/production/02-persistence.md) | actif |
| VD-0005 | la Fiche de Registre → *Registry Fiche* | domaine + Exploitation | [F5.2 §10](../../source/production/02-persistence.md) | actif |
| VD-0006 | la Perte Déclarée → *Declared Loss* (`LossDeclarationId`) | Exploitation | [F5.2 §6](../../source/production/02-persistence.md) | actif |
| VD-0007 | la Réadmission → **`Readmitted`** | police du registre | [F5.2 §6](../../source/production/02-persistence.md) | actif |
| VD-0008 | le crypto-shredding | Persistance | [F5.2 §9](../../source/production/02-persistence.md) | actif |
| VD-0009 | le Log → *Log* | technique | [F5.3 §2](../../source/production/03-observability.md) | actif |
| VD-0010 | l'Alerte → *Alert* (`AlertId`) | Exploitation | [F5.3 §6](../../source/production/03-observability.md) | actif |
| VD-0011 | l'Incident → *Incident* (`IncidentId`) | Exploitation | [F5.3 §10](../../source/production/03-observability.md) | actif |
| VD-0012 | la Main courante → *Operations Logbook* | Exploitation | [F5.3 §10](../../source/production/03-observability.md) | actif |
| VD-0013 | le Runbook → *Runbook* (`RunbookId`) | Gouvernance d'exploitation | [F5.3 §10](../../source/production/03-observability.md) | actif |
| VD-0014 | le Relevé d'accès → *Access Record* | propriétaire de la donnée protégée | [F5.3 §2](../../source/production/03-observability.md) · [F5.4 T-23](../../source/production/04-security.md) | actif |
| VD-0015 | le Pipeline de télémétrie → *Telemetry Pipeline* | Exploitation | [F5.3 §9](../../source/production/03-observability.md) | actif |
| VD-0016 | le vestibule des machines / la Preuve de machine | Sécurité (infra) | [F5.4 P1](../../source/production/04-security.md) | actif |
| VD-0017 | le Trust Model | Sécurité | [F5.4 P1](../../source/production/04-security.md) | actif |
| VD-0018 | le Secret Zero (Cérémonie de Fondation) | Sécurité | [F5.4 P3](../../source/production/04-security.md) | actif |
| VD-0019 | la Reprise → *Reprise* (`ReprisePlanId`) | Fiabilité | [F5.5 §6](../../source/production/05-reliability.md) | actif |
| VD-0020 | le Chaos → *Chaos Engineering* (`ChaosExperimentId`) | Fiabilité | [F5.5 §8](../../source/production/05-reliability.md) | actif |
| VD-0021 | la Résidence de vérité → *truth residence* | Scalabilité | [F5.6 §3](../../source/production/06-scalability.md) | actif |
| VD-0022 | la Cellule → *Cell* (`CellId`) | Exploitation | [F5.6 §4](../../source/production/06-scalability.md) | actif |
| VD-0023 | la Validation opérationnelle (`OperationalValidationId`) | Gouvernance d'exploitation | [F5.7.99](../../source/production/07-operations.md) | actif |
| VD-0024 | le Handover → *handover* | Exploitation | [F5.7.99](../../source/production/07-operations.md) | actif |
| VD-0025 | la Tâche corrective → *corrective task* (`CorrectiveTaskId`) | Exploitation | [F5.7.99](../../source/production/07-operations.md) | actif |
| VD-0026 | le Corpus Canonique → *Canonical Corpus* | Gouvernance de Production | [F5.8 §P1](../../source/production/08-governance.md) | actif |
| VD-0027 | R2-Corpus → *Corpus Materialization* | Gouvernance de Production | [F5.8 §P2](../../source/production/08-governance.md) | actif |
| VD-0028 | la propriété émergente → *emergent property* | Grand Audit F5.99 | [F5.99 §2](../../source/production/09-grand-audit.md) | actif — à inscrire (voir VD-0097) |
| VD-0029 | l'entrée Ledger (`FundsLedger`, `ConsentLedger`) | domaines (Economy, Consent) | [F3.3.99](../../source/domain/06-tactical-documentation-freeze.md) | actif — terme qualifié |

---

## B. Renommages (ratifiés — jamais supprimés)

| ID | Terme remplacé | → Terme de remplacement | Propriétaire | Chapitre | Statut |
|----|----|----|----|----|----|
| VD-0030 | domaine « Signalement » (générique de livraison) | **Notification** | Notification | [F2.3](../../source/constitution/03-language-responsibilities-contracts.md) | renommé — « Signalement » appartient désormais à la seule Réputation |
| VD-0031 | Caducité | **Lapse** (`AgreementRequestLapsed`) | Engagement | [F2.5 §15.1](../../source/constitution/04-bilingual-dictionary.md) | renommé (Expired réservé à Consent) |
| VD-0032 | Échéance / échu | **Elapse / Elapsed** (`AgreementElapsed`) | Engagement | [F2.5 §15.1](../../source/constitution/04-bilingual-dictionary.md) | renommé |
| VD-0033 | Retrait (de l'Économie) | **Payout** | Expert Economy | [F2.5 §15.1](../../source/constitution/04-bilingual-dictionary.md) | renommé (Withdrawn réservé à Consent) |
| VD-0034 | l'écart de la Suggestion | **Dismissed** | Discovery | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | renommé (Rejected réservé à Engagement) |
| VD-0035 | l'interlocuteur du Messaging | **Interlocutor** | Messaging | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | renommé (Participant réservé à la Rencontre) |
| VD-0036 | la preuve d'entrée d'I&A | **Credential** | Identity & Access | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) · F1.4.20 | renommé (Proof réservé à Reputation) |
| VD-0037 | la remise de la Consultation | **Submission** | Consultation | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | renommé (Deposit réservé à Storage) |
| VD-0038 | le commanditaire | **Commissioner** | acteur | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | renommé (Principal réservé à Foundation Layout) |
| VD-0039 | « Snapshot » (double technique de sauvegarde) | **Image de sauvegarde** | Persistance | [F5.2 §6](../../source/production/02-persistence.md) | renommé (Snapshot réservé F3.1.11) |
| VD-0040 | « Journal » (double technique de moteur) | **journal de moteur** (= Log) | Persistance/technique | [F5.2 §6](../../source/production/02-persistence.md) | renommé (Journal réservé applicatif) |
| VD-0041 | « Export » (double technique) | **Copie d'exploitation** | Exploitation | [F5.2.99](../../source/production/02-persistence.md) | renommé (Export réservé à la personne, P9.6) |
| VD-0042 | « Recovery » (nu) | **Remplacement** / **Restauration** / **Reprise** | Flotte / Persistance / Fiabilité | [F5.5 §9](../../source/production/05-reliability.md) | renommé (trois mots réservés) |
| VD-0043 | variante de source « VerditTranché » | **`SignalementTranché`** | Reputation (événement, F2.2) | [F2.3 (divergence)](../../source/constitution/03-language-responsibilities-contracts.md) | ⚠ divergence réconciliée au propriétaire des événements (F2.2), signalée sans autre modification |

---

## C. Termes réservés (un mot, un propriétaire, partout)

| ID | Terme réservé | Propriétaire | Chapitre | Statut |
|----|----|----|----|----|
| VD-0044 | **Expired** | Consent (`ConsentExpired`) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0045 | **Withdrawn** | Consent (`ConsentWithdrawn`) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0046 | **Rejected** | Engagement (`AgreementRejected`) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0047 | **Refused** | Consent (`ConsentRefused`) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé (quintette du refus) |
| VD-0048 | **Declined** | Invitation (Enterprise) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé (quintette du refus) |
| VD-0049 | **Dismissed** | Suggestion (Discovery) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé (quintette du refus) |
| VD-0050 | **Denied** | Exceptions uniquement (jamais un fait) | [F2.5.2 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé (5ᵉ mot du refus, créé F2.5.2) |
| VD-0051 | **Participant** | Rencontre (Consultation) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0052 | **Proof** | Reputation | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0053 | **Deposit** | Storage | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0054 | **Channel** | qualifié des deux côtés (`SettlementChannel` / `ReachabilityChannel`) | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé (composition obligatoire) |
| VD-0055 | **Principal** | Foundation Layout | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé |
| VD-0056 | **Session** | Identity & Access | [F2.3](../../source/constitution/03-language-responsibilities-contracts.md) · [F5.3 §10](../../source/production/03-observability.md) | réservé (`SessionId` interdit en télémétrie) |
| VD-0057 | **Credential** | Identity & Access (personnes) | [F2.5 §3](../../source/constitution/04-bilingual-dictionary.md) · [F5.4 P1](../../source/production/04-security.md) | réservé (jamais les machines) |
| VD-0058 | **Messaging** | domaine des Conversations (loi 10) | [F4.3](../../source/application/03-circulation.md) | réservé |
| VD-0059 | **Snapshot** | voix tactique (F3.1.11) | [F5.2 §6](../../source/production/02-persistence.md) | réservé |
| VD-0060 | **Journal** | applicatif probant (F4.1 / F5.3) | [F5.3 §2](../../source/production/03-observability.md) | réservé |
| VD-0061 | **Export** | droit de la personne (P9.6) | [F5.2.99](../../source/production/02-persistence.md) | réservé |
| VD-0062 | **RetentionActive** | rétention encore ouverte | [F2.5.2 §11](../../source/constitution/04-bilingual-dictionary.md) | réservé (créé F2.5.2) |
| VD-0063 | **Matière personnelle** / **Fait personnel** / **Personne concernée** | Storage / registres / Compte-Consent | [F5.4.99](../../source/production/04-security.md) | réservé (« donnée personnelle » nu banni — voir VD-0075) |
| VD-0064 | **Ledger** (toujours qualifié : `FundsLedger`, `ConsentLedger`) | Economy, Consent | [F3.3.99](../../source/domain/06-tactical-documentation-freeze.md) | réservé — composition obligatoire (entrée ratifiée F3.3.99) |
| VD-0065 | **Outbox** (toujours qualifié : Outbox de faits / de commandes) | domaine (pas 8) / Réaction (pas 4) | [F4.99](../../source/application/05-grand-application-audit.md) | réservé — le mot nu est banni (voir VD-0074) |

---

## D. Termes interdits (avec remplacement officiel & chapitre propriétaire)

| ID | Mot interdit | → Remplacement officiel | Chapitre propriétaire | Statut |
|----|----|----|----|----|
| VD-0066 | Booking / Reservation / Appointment | **Agreement** (« réservation » FR = parcours seul) | [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0067 | Meeting / Call / session (hors I&A) | **Encounter** | [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0068 | User | **Person** | [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0069 | Wallet / Balance nu | **AvailableFunds** ; Withdrawal → **Payout** | [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0070 | Rating / Score / Stars | interdits (RT-03) | [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0071 | Chat / Thread / Inbox · Feed · Dashboard · History · Status · Settings · Login · Ticket · Notification-objet | Conversation · (surfaces interdites) · les faits/projection · State qualifié · Preferences · Entry · SupportRequest · Signal | [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0072 | API / base / service / backend / cache / token / push / upload (hors outillage) | (le langage ignore la technique) | [F2.3](../../source/constitution/03-language-responsibilities-contracts.md) | interdit |
| VD-0073 | **Replica** | une instance (`InstanceId`) | [F5.1 §17](../../source/production/01-runtime.md) | interdit (synonyme nu, loi 10) |
| VD-0074 | **Outbox** nu | Outbox de faits / Outbox de commandes | [F4.99](../../source/application/05-grand-application-audit.md) | interdit nu (qualification obligatoire) |
| VD-0075 | **donnée personnelle** nu | Matière / Fait / Personne (VD-0063) | [F5.4.99](../../source/production/04-security.md) | interdit nu |
| VD-0076 | **Recovery** nu | Remplacement / Restauration / Reprise (VD-0042) | [F5.5 §9](../../source/production/05-reliability.md) | interdit nu |
| VD-0077 | **Review** nu | quatre espèces (Operational / Security / Documentation / Follow-up Review) | [F5.7.99](../../source/production/07-operations.md) | interdit nu — ⚠ voir ambiguïté « Review » (§E) |
| VD-0078 | **Publication** nue | Constitutionnelle / Canonique / Technique | [F5.8.99](../../source/production/08-governance.md) | interdit nu — ⚠ voir ambiguïté « Publication » (§E) |
| VD-0079 | **Gouvernance** nue | constitutionnelle / d'exploitation | [F5.4 P4](../../source/production/04-security.md) | interdit nu |
| VD-0080 | **Capacity** nu (limite d'offre) | lecture physique ; la limite d'offre est une **Policy** | [F5.6 SC-7](../../source/production/06-scalability.md) | interdit nu |
| VD-0081 | **Action Item** | Tâche corrective (`CorrectiveTaskId`) | [F5.7.99](../../source/production/07-operations.md) | interdit |
| VD-0082 | Create / Update / Delete génériques · Set · Save · Handle nu · `-Manager`/`-Helper`/`-Util`/`-Service` nu · Base-/Abstract-/Impl/Data/Info/Item/Object/Common/Shared/Utils | (verbe + vérité ; capacité qualifiée) | [F2.5 §5, §9](../../source/constitution/04-bilingual-dictionary.md) | interdit |

---

## E. Synonymes interdits

| ID | Synonyme interdit | Terme officiel unique | Chapitre | Statut |
|----|----|----|----|----|
| VD-0083 | `-Created` (pour un fait métier), `-Done`, `-Updated` nu | le participe passé du fait (sauf Portfolio) | [F2.5 §4](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0084 | Confirmed ≠ Verified ≠ Adopted ≠ Proved | quatre sens distincts, jamais interchangeables | [F2.5 §2](../../source/constitution/04-bilingual-dictionary.md) | faux amis détruits |
| VD-0085 | Sender | **Emitter** (faux ami Messaging → Notification) | [F2.5 §3](../../source/constitution/04-bilingual-dictionary.md) | interdit |
| VD-0086 | Rejected / Refused / Declined / Dismissed / Denied comme synonymes | cinq mots, cinq propriétaires — jamais synonymes | [F2.5 §11](../../source/constitution/04-bilingual-dictionary.md) | le refus n'a pas de synonyme |
| VD-0087 | Remplacement / Restauration / Reprise comme synonymes | trois actes distincts (Flotte / Persistance / Fiabilité) | [F5.5 §9](../../source/production/05-reliability.md) | jamais interchangeables |

### Ambiguïtés signalées (jamais résolues ici — la Source tranche par Titre VII)

- ⚠ **Review** — la Source l'emploie sous **deux sens** : *Avis* (Reputation :
  « Avis → **Review** », [F2.5 §3](../../source/constitution/04-bilingual-dictionary.md))
  et *revue d'exploitation* (F5.7 : « Review banni nu, quatre espèces »,
  [F5.7.99](../../source/production/07-operations.md)). **Ambiguïté signalée** ;
  résolution due au Titre VII (VD-0077).
- ⚠ **Publication** — trois espèces (Constitutionnelle / Canonique / Technique,
  [F5.8.99](../../source/production/08-governance.md)) ; le Procès V a relevé
  l'ambiguïté `OperationalPublicationId` vs `CanonicalPublicationId`
  ([F5.99](../../source/production/09-grand-audit.md)). **Ambiguïté signalée** ;
  résolution due (voir dette VD-0093).

---

## F. Corrections lexicales (validées — aucune invention)

| ID | Correction | Chapitre | Statut |
|----|----|----|----|
| VD-0088 | `Denied` créé (5ᵉ mot du refus) ; `RetentionActive` créé ; `AgreementRequestLapsePolicy` (la caducité frappe la Demande, jamais l'Accord ferme) ; Domain Service **qualifié** conforme (l'interdit ne vise que le suffixe nu) | [F2.5.2](../../source/constitution/04-bilingual-dictionary.md) | validée |
| VD-0089 | `SignalDeConfianceMisÀJour` **supprimé** (un signal de confiance est une projection, jamais un fait) ; trois faux événements supprimés ; police des registres généralisée (`AvisSignalé` / `SignalementTranché`) ; `RetraitÉchoué` et `SuiteTraitée` ajoutés | [F2.2.99](../../source/constitution/02-context-map.md) | validée |
| VD-0090 | totaux **dérivés** de leurs énumérations (30 / 73 / 79 / 16 / 11 / 23 / 18 — les six chiffres jadis écrits à la main étaient les seuls faux) ; `ExpressSearch` supprimée ; entrée `Ledger` ; 18ᵉ anti-pattern | [F3.3.99](../../source/domain/06-tactical-documentation-freeze.md) | validée |
| VD-0091 | `Nonce`/`Salt` = mécanismes cryptographiques (jamais nommables dans une vérité) ; l'Attestation produite au Build, vérifiée au Boot ; la Certificate Authority = mécanisme ; le Relevé d'accès = Registre probant à Fiche | [F5.4 P3 (revue)](../../source/production/04-security.md) | validée |
| VD-0092 | « Capacity » nu = lecture physique (la limite d'offre est une Policy) ; démarcation résidence / localisation (une localisation ne tranche jamais un acte) | [F5.6.99](../../source/production/06-scalability.md) | validée |

---

## G. Dettes lexicales (reconnues — projetées sans être résolues)

*Règle N°29 : une dette n'est jamais une exception. PG-14 / PG-17 : toute dette
est visible, gouvernée jusqu'à disparition. Ces items sont **projetés tels
quels** ; leur résolution appartient à la Source (Titre VII) et à la fusion du
Glossaire.*

| ID | Dette lexicale | Origine | Statut |
|----|----|----|----|
| VD-0093 | Désambiguïser `OperationalPublicationId` vs `CanonicalPublicationId` ; confirmer `OperationalTaskId` = `CorrectiveTaskId` (un seul objet) | [F5.99 Procès V](../../source/production/09-grand-audit.md) | ouverte |
| VD-0094 | Bannir `PrincipalId` (collision Foundation Layout — l'acteur est `ActorRef` ou Preuve de machine) | [F5.99 Procès V](../../source/production/09-grand-audit.md) | ouverte |
| VD-0095 | Refuser comme identités constitutionnelles : `SnapshotId`, `BackupId`, `TrustChainId`, `DocumentationSignatureId`, `DiffId` (mécanismes / attributs / actes) | [F5.99 Procès V](../../source/production/09-grand-audit.md) | ouverte |
| VD-0096 | Expliciter `FleetId` comme identité (déjà énoncé — VD-0001) | [F5.99 Procès V](../../source/production/09-grand-audit.md) | ouverte |
| VD-0097 | Inscrire **« propriété émergente »** comme terme réservé (cinq verdicts du Procès I en dépendent) | [F5.99 Procès VIII](../../source/production/09-grand-audit.md) | ouverte (voir VD-0028) |
| VD-0098 | La fusion du Glossaire officiel et le passage du Vocabulary Diff sur le corpus existant (purge des scories, inscription des termes réservés accumulés) | [F5.8 §dettes](../../source/production/08-governance.md) | ouverte |

---

## H. Historique (mémoire des évolutions lexicales)

*Une entrée ne disparaît jamais ; l'histoire est conservée (le passé n'est jamais
réécrit — F5.99 Procès IX).*

| ID | Évolution | Chapitre | Version |
|----|----|----|----|
| VD-0099 | Constitution de la Langue **v1.0.0** (dictionnaire, 8 réservations, Event Dictionary) | [F2.5.1](../../source/constitution/04-bilingual-dictionary.md) | v1.0.0 |
| VD-0100 | Constitution de la Langue **v1.1.0** (`Denied`, `RetentionActive`, `AgreementRequestLapsePolicy`, Domain Service qualifié) | [F2.5.2](../../source/constitution/04-bilingual-dictionary.md) | v1.1.0 |
| VD-0101 | Domaine 14 **« Signalement » → « Notification »** ; « Signalement » réservé à la Réputation | [F2.1](../../source/constitution/01-domain-landscape.md) → [F2.3](../../source/constitution/03-language-responsibilities-contracts.md) | — |
| VD-0102 | Purge tactique : faux événements supprimés, police des registres généralisée, totaux dérivés | [F2.2.99](../../source/constitution/02-context-map.md) / [F3.3.99](../../source/domain/06-tactical-documentation-freeze.md) | — |
| VD-0103 | Réservations de la Production : Snapshot / Journal / Export (F5.2.99) ; Recovery → 3 mots (F5.5.99) ; Matière/Fait/Personne (F5.4.99) | [F5.2.99](../../source/production/02-persistence.md) · [F5.5.99](../../source/production/05-reliability.md) · [F5.4.99](../../source/production/04-security.md) | — |
| VD-0104 | Bannissements nus : Review (F5.7.99), Publication (F5.8.99), Capacity (F5.6), Gouvernance (F5.4), Replica (F5.1.99), Outbox (F4.99) | [F5.1](../../source/production/01-runtime.md)→[F5.8](../../source/production/08-governance.md) | — |
| VD-0105 | Scories lexicales relevées (Procès V) ; « propriété émergente » à inscrire (Procès VIII) | [F5.99](../../source/production/09-grand-audit.md) | — |

---

## Divergences signalées (récapitulatif — jamais corrigées ici)

- ⚠ **VD-0043** — la source combinée F2.3 écrivait « VerditTranché » ; réconcilié
  au propriétaire des événements (**`SignalementTranché`**, F2.2) — signalé sans
  autre modification.
- ⚠ **VD-0077** (ambiguïté « Review », §E) — « Review » à deux sens (Avis /
  revue d'exploitation).
- ⚠ **VD-0078 / VD-0093** — « Publication » à désambiguïser (opérationnelle /
  canonique).

Ces divergences relèvent de la Source (Titre VII) et de la fusion du Glossaire ;
le Vocabulary Diff les **signale**, il ne les **résout** jamais.

---

## Provenance de projection (non normatif)

Projection déterministe de la **Source matérialisée** (`docs/canon/source/`),
jamais du transcript (règle N°31 : le Corpus Canonique est l'unique référence ; le
transcript n'est plus une autorité). Les entrées sont **extraites** des chapitres
propriétaires — [F2.1](../../source/constitution/01-domain-landscape.md),
[F2.2](../../source/constitution/02-context-map.md),
[F2.3](../../source/constitution/03-language-responsibilities-contracts.md),
[F2.5](../../source/constitution/04-bilingual-dictionary.md),
[F3.3](../../source/domain/06-tactical-documentation-freeze.md),
[F4.3](../../source/application/03-circulation.md),
[F4.99](../../source/application/05-grand-application-audit.md),
[F5.1](../../source/production/01-runtime.md) →
[F5.8](../../source/production/08-governance.md),
[F5.99](../../source/production/09-grand-audit.md) — **sans invention, sans
harmonisation, sans reformulation, sans correction éditoriale**. Chaque
identifiant `VD-NNNN` est **permanent** (jamais réutilisé, survit aux renommages).
**Aucun terme créé, aucun propriétaire changé** ; toute divergence est **signalée,
jamais corrigée** (la résolution appartient à la Source, par Titre VII, et à la
fusion du Glossaire — dette VD-0098). Ce document projette la Source ; il ne la
modifie jamais et n'a aucun pouvoir éditorial (PG-5, PG-8 ; GOVERNANCE #6 ; règle
N°33).
