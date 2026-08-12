---
doc: canon-glossary-01
title: Glossaire Officiel de Mentora (bilingue FR ↔ EN) — projection déterministe de la Source
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 1 (Glossaire officiel)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 1"
source_autorite:
  - "F2.5 — Dictionnaire bilingue (propriétaire officiel du vocabulaire du métier) — source/constitution/04-bilingual-dictionary.md"
  - "F5.1→F5.8 — vocabulaire de la Production (Runtime, Persistance, Observabilité, Sécurité, Fiabilité, Scalabilité, Opérations, Gouvernance)"
  - "F5.99 — le concept « propriété émergente » et les théorèmes (démonstrations)"
note: >-
  PROJECTION déterministe de la Source (docs/canon/source/), jamais une source
  autonome. Le Glossaire RASSEMBLE les termes ratifiés ; il n'en crée aucun
  (PG-8). Chaque entrée cite son chapitre propriétaire ; le Glossaire est
  reconstructible depuis la Source (PG-6, PG-12) et n'a aucun pouvoir éditorial
  (GOVERNANCE #6, règle N°33 : une démonstration/projection n'est jamais une
  autorité). Le propriétaire officiel du vocabulaire du métier demeure F2.5 ; le
  Glossaire le projette sans le dupliquer en autorité. Les énumérations
  exhaustives (73 faits, 79 commandes, toutes les lois, toutes les identités,
  tous les anti-patterns) appartiennent aux Catalogues (Lot 4) — le Glossaire
  les cite. Toute divergence Glossaire ↔ Source est un défaut du Glossaire (jamais
  de la Source), résolu par le Vocabulary Diff (Lot 2), fail closed. Évolution :
  Titre VII uniquement.
---

# Glossaire Officiel de Mentora

> **Langage unique, sens unique.** Le métier parle français ; le code parle
> anglais ; le Glossaire est le pont unique. *Un concept, une traduction ; jamais
> de synonyme* (F2.5, P1–P2). Ce document **projette** la Constitution
> matérialisée ; il ne la modifie jamais et ne fait jamais autorité contre elle.

## Nature de ce document (projection, jamais source)

Le Glossaire officiel est une **projection déterministe** de la Source
([`source/`](../../source/)) :

- il **rassemble** les termes ratifiés, **il n'en crée aucun** (PG-8) ;
- chaque terme possède **un seul sens officiel** ; toute collision est tranchée
  par un **terme réservé** (PG-9) ;
- il est **reconstructible depuis la Source** (PG-6, PG-12) — toute entrée cite
  son chapitre propriétaire ;
- il n'a **aucun pouvoir éditorial** (règle N°33 : une démonstration/projection
  n'est jamais une autorité — l'autorité appartient exclusivement à la
  Constitution) ;
- le **propriétaire officiel du vocabulaire du métier** demeure
  [F2.5 — Dictionnaire bilingue](../../source/constitution/04-bilingual-dictionary.md) ;
  ce Glossaire le projette sans le dupliquer en autorité.

Les **énumérations exhaustives** (les 73 faits, les 79 commandes, les 16
politiques, les lois R/S/O/T/RY/SC/OP/PG, toutes les identités, tous les
anti-patterns) relèvent des **Catalogues** (Lot 4) ; le Glossaire les nomme et
y renvoie. La **vérification** de ce Glossaire contre la Source est le
**Vocabulary Diff** (Lot 2), fail closed — voir §H.

---

## §A. Les principes du langage (projection de F2.5, P1–P6)

- **P1 — Un concept, une traduction.** Deux traductions = deux vocabulaires =
  dérive certaine ; le Glossaire tranche, une fois.
- **P2 — Jamais de synonyme.** `Agreement` ne devient jamais
  Booking/Reservation/Appointment : le synonyme est la porte du legacy.
- **P3 — Les mots legacy meurent à la frontière** (l'ACL est linguistique) : on
  traduit, on n'adopte pas.
- **P4 — Le code dérive du Glossaire** ; toute traduction improvisée est une
  violation, détectable par simple absence du Glossaire.
- **P5 — Toute modification est une révision constitutionnelle** (Titre VII).
- **P6 — API, Events, Commands, Queries, Policies, ACL, Tests parlent le
  Glossaire** : un test qui parle un autre mot teste un autre produit.

*Source : [F2.5 §1](../../source/constitution/04-bilingual-dictionary.md).*

---

## §B. Le langage du métier — dictionnaire bilingue par domaine (FR → EN)

Projection de [F2.5 §3](../../source/constitution/04-bilingual-dictionary.md)
(propriétaire officiel). *Interdits en italique ; pour les faits, commandes,
requêtes, projections et politiques exhaustifs, voir F2.5 §4–§6 et les Catalogues
(Lot 4).*

- **Engagement** — Demande d'accord → **AgreementRequest** ; Accord →
  **Agreement** ; Créneau → **TimeSlot** (*Slot nu, Schedule*) ; Acceptation →
  **Acceptance** ; Refus de demande → **Rejection** ; Caducité → **Lapse** ;
  Confirmation → **Confirmation** ; Replanification → **Reschedule** ; Annulation
  → **Cancellation** ; Échéance/échu → **Elapse/Elapsed**.
- **Consultation** — Rencontre → **Encounter** (*Meeting, Call, Session*) ;
  Préparation → **Preparation** ; Ouverture → **Opening** ; Clôture →
  **Closure** ; Interruption → **Interruption** ; Artefact → **Artifact** ;
  remise → **Submission** (*Deposit — réservé Storage*) ; Suite → **FollowUp** ;
  Brief → **Brief** ; Participant → **Participant** (réservé à la Rencontre).
- **Professional Identity** — Déclaration → **Declaration** ; Présentation →
  **Presentation** (*Bio, About*) ; Offre → **Offer** (publiée/retirée →
  **Published/Unpublished**) ; Expertise revendiquée → **ClaimedExpertise** ;
  Portfolio → **Portfolio** ; Masterclass → **Masterclass** ; Référentiel des
  spécialités → **SpecialtyRegistry** ; Spécialité → **Specialty**.
- **Reputation** — Preuve → **Proof** (réservé à ce domaine) ; Avis → **Review**
  (*Rating, Score, Stars*) ; Réponse → **ReviewReply** ; Certification vérifiée →
  **VerifiedCertification** ; Réalisation → **Achievement** ; Signalement →
  **Report** ; Verdict → **Verdict** ; Signal de confiance → **TrustSignal**
  (projection).
- **Expert Economy** — Revenu → **Revenue** (reconnu/ajusté →
  **Recognized/Adjusted**) ; En-attente → **PendingRevenue** ; Disponible →
  **AvailableFunds** (*Wallet, Balance nu*) ; Retrait → **Payout** (*Withdrawal,
  Cashout*) ; Objectif → **Goal** ; Prévision → **Forecast** (projection) ;
  Opportunité → **Opportunity**.
- **Augmentation** — Production → **Production** (délivrée → **Delivered**) ;
  Proposition → **Proposal** ; Marquage IA → **AIAttribution** ; Citation →
  **Citation** ; Incertitude déclarée → **StatedUncertainty** ; Adoption →
  **Adoption** ; Sollicitation → **ProductionRequest**.
- **Account** — Personne → **Person** (*User*) ; Titulaire → **AccountHolder** ;
  Préférence → **Preference** (*Settings*) ; Joignabilité → **Reachability** ;
  Cadre de disponibilité → **AvailabilityFrame** (*Availability nue, Calendar*) ;
  Abonnement → **Subscription** ; Espace de travail → **Workspace** ; Appareil →
  **Device** ; Demande d'aide → **SupportRequest** (*Ticket*) ; Fermeture →
  **Closure** (qualifiée : `AccountClosed`).
- **Discovery** — Intérêt exprimé → **ExpressedInterest** ; Favori →
  **Favorite** ; Suggestion → **Suggestion** (retenue/écartée →
  **Kept/Dismissed**) ; Recherche exprimée → **ExpressedSearch** (*Query nu —
  réservé au type technique*).
- **Enterprise** — Organisation → **Organization** ; Membre → **Member**
  (*Employee*) ; Invitation → **Invitation** (émise/acceptée/déclinée →
  **Issued/Accepted/Declined**) ; Appartenance → **Membership** ; Parrainage →
  **Sponsorship** ; Vérification → **OrganizationVerification**.
- **Consent** *(gelé — intangible)* — Consentement → **Consent** ; **Granted /
  Refused / Withdrawn / Expired / Invalidated** ; Portée → **Scope** ; Accordant
  → **Grantor** ; Sujet → **Subject** ; Gardien → **Custodian** (*Guardian,
  Keeper*).
- **Messaging** — Conversation → **Conversation** (*Chat, Thread*) ; Message →
  **Message** (*DM*) ; Interlocuteur → **Interlocutor** (*Participant — réservé
  Rencontre*) ; Signalement → **ConversationReport**.
- **Identity & Access** — Preuve d'entrée → **Credential** (gelé Foundation
  F1.4.20) ; Facteur → **Factor** ; Session → **Session** (réservé) ; Entrée →
  **Entry** (*Login, SignIn*) ; Révocation → **Revocation**.
- **Settlement** — Ordre → **SettlementOrder** (*Transaction, Payment nu*) ;
  Exécution → **Execution** ; Compte rendu → **ExecutionReport** ; Canal →
  **SettlementChannel**.
- **Notification** — Signal → **Signal** (*Notification-objet, Push, Alert*) ;
  Livraison → **Delivery** ; Émetteur → **Emitter** (*Sender*) ; Canal de
  joignabilité → **ReachabilityChannel**.
- **Storage** — Dépôt → **Deposit** (réservé) ; Déposant → **Depositor** ; Garde
  → **Custody** ; Restitution → **Return** ; Destruction → **Destruction** ;
  Rétention → **Retention**.

---

## §C. Le langage de la Production — vocabulaire d'infrastructure (F1, F3, F4, F5)

Projection des chapitres propriétaires ; chaque entrée cite sa Source. Bilingue :
concept FR → terme/identité EN.

### Runtime & Flotte (F5.1)

- **le Runtime** → *Runtime* — le **gardien de l'exécutabilité** ; il ne possède
  ni vérité, ni décision, ni position, ni règle. *([F5.1 §1, R-1](../../source/production/01-runtime.md)).*
- **l'Exécutable** → *Executable* — une unité autonome (Root, cycle, ressources,
  identité) ; six espèces (Application, Relay, Scheduler, Worker, Migration,
  Maintenance). *([F5.1 §2–§3](../../source/production/01-runtime.md)).*
- **la Flotte** → *Fleet* (`FleetId`) — l'ensemble des instances d'un exécutable,
  gouvernée par des politiques techniques, **possédée par l'Exploitation** ; elle
  possède un seul acte : **le remplacement**. *([F5.1 §16](../../source/production/01-runtime.md)).*
- **la table des identités de Runtime** → `ExecutableId` (la mission) →
  `ArtifactId` (l'artefact immuable, à provenance de source) → `InstanceId`
  (l'occurrence vivante). *« Replica » est banni.* *([F5.1 §17](../../source/production/01-runtime.md)).*
- **la preuve d'artefact** → *artifact proof* — intégrité + provenance vérifiées
  au Boot, fail closed. *([F5.1 §18, R-5](../../source/production/01-runtime.md)).*

### Persistance (F5.2)

- **le Registre** → *Registry* — la mémoire contractuelle d'une vérité (un
  registre par vérité, possédé par le domaine). *([F5.2 §1, S-1](../../source/production/02-persistence.md)).*
- **le Dépôt** → *Deposit* — l'unité de Storage (la garde de matière). *Le
  Registre garde des vérités, le Dépôt garde de la matière.*
- **la Fiche de Registre** → *Registry Fiche* — objet constitutionnel **à deux
  parties, deux propriétaires** : partie de vérité (domaine) + partie
  d'exploitation (Exploitation, sous Gouvernance). *([F5.2 §10, S-10](../../source/production/02-persistence.md)).*
- **la Perte Déclarée** → *Declared Loss* (`LossDeclarationId`) — l'aveu
  journalisé d'une perte de queue (RPO déclaré, Inventaire par les preuves des
  pairs) ; *jamais silencieuse.* *([F5.2 §6, S-6](../../source/production/02-persistence.md)).*
- **la Réadmission** → **`Readmitted`** — le **troisième membre** de la police du
  registre (avec `Invalidated`, `Struck`) : un fait prouvé chez les pairs est
  réadmis, à provenance marquée. *On ne re-fabrique jamais un fait sans preuve.*
  *([F5.2 §6](../../source/production/02-persistence.md)).*
- **le crypto-shredding** → *crypto-shredding* — la destruction de la **matière**
  d'un fait par destruction de ses **clés** ; la **structure du fait demeure**
  (un fait illisible est encore un fait). *([F5.2 §9, S-9](../../source/production/02-persistence.md)).*

### Observabilité (F5.3)

- **le Journal** → *Journal* — l'émission **applicative probante** (les pas des
  Séquences). *([F5.3 §2, O-2](../../source/production/03-observability.md)).*
- **le Log** → *Log* — l'émission **technique** perdable et bornée. *(À ne pas
  confondre avec le Journal.)*
- **l'Alerte** → *Alert* (`AlertId`) — le mot d'exploitation ; elle constate,
  nomme son runbook, prévient — **jamais ne commande**. *(Distincte du Signal,
  qui va aux personnes.)* *([F5.3 §6, O-5](../../source/production/03-observability.md)).*
- **l'Incident** → *Incident* (`IncidentId`) — une **unité de vérité
  d'exploitation** ; cycle `Ouvert → Maîtrisé → Résolu → Clos` ; *la réouverture
  n'existe pas — un incident rouvert est un incident nouveau à provenance.*
  *([F5.3 §10, O-9](../../source/production/03-observability.md)).*
- **la Main courante** → *Operations Logbook* — le **Registre d'exploitation** :
  la mémoire probante des actes d'exploitation. *([F5.3 §10, O-9](../../source/production/03-observability.md)).*
- **le Runbook** → *Runbook* (`RunbookId`) — document gouverné, versionné, cité
  dans l'incident. *([F5.3 §10](../../source/production/03-observability.md)).*
- **le Relevé d'accès** → *Access Record* — la preuve **probante** de consultation
  des données protégées (Registre à Fiche) ; traité par F5.4. *([F5.3 §2](../../source/production/03-observability.md), [F5.4 P3, T-23](../../source/production/04-security.md)).*
- **le Pipeline de télémétrie** → *Telemetry Pipeline* — outillage d'Exploitation
  (collecte, transport, stockage, purge), mécanismes libres. *([F5.3 §9, O-10](../../source/production/03-observability.md)).*

### Sécurité (F5.4)

- **le vestibule des personnes / le vestibule des machines** → *human vestibule /
  machine vestibule* — jamais mêlés ; *une machine n'est jamais une personne*.
  *([F5.4 P1, T-4](../../source/production/04-security.md)).*
- **la Preuve de machine** → *machine proof* — adossée à la chaîne d'artefact
  (source → artefact → boot prouvé → preuve de machine). *([F5.4 P1](../../source/production/04-security.md)).*
- **le Trust Model** → *Trust Model* — la table de jonction des chaînes de preuve,
  déclarée et boot-vérifiée. *([F5.4 P1, T-5](../../source/production/04-security.md)).*
- **le Break Glass** → *break glass* — élargit des droits pour une fenêtre bornée,
  tracé en Main courante ; **il ne suspend jamais une loi**. *([F5.4 P2, T-15](../../source/production/04-security.md)).*
- **le Secret Zero** → *Secret Zero* — la première confiance, injectée en
  **Cérémonie de Fondation** (présence, double contrôle, journal) ; *rien ne naît
  sans témoins*. *([F5.4 P3, T-20](../../source/production/04-security.md)).*
- **la chaîne d'approvisionnement** → *supply chain* — continue, sans trou :
  Source → Build → Artifact → Signature → SBOM → Attestation → Boot → Preuve de
  machine → Runtime. *([F5.4 P3, T-21](../../source/production/04-security.md)).*
- **la Confiance** → *Trust* — une **propriété démontrée** à chaque traversée,
  jamais un climat, jamais héritée d'une position. *([F5.4 Nature, T-2](../../source/production/04-security.md)).*

### Fiabilité (F5.5)

- **la Fiabilité** → *Reliability* — maintient la Constitution vraie, jamais le
  système vivant à tout prix ; hiérarchie **Fiabilité > Disponibilité**.
  *([F5.5 §2, RY-1/RY-3](../../source/production/05-reliability.md)).*
- **la Dégradation gracieuse** → *graceful degradation* — retire des capacités
  **ou** sert daté-et-avoué ; jamais servir faux en silence. *([F5.5 §4, RY-4](../../source/production/05-reliability.md)).*
- **la Reprise** → *Recovery-as-Reprise* — les cinq temps : Détection → Isolation
  → Restauration → Réconciliation → **Vérification** (fail closed avant retour au
  service). *([F5.5 §6, RY-8](../../source/production/05-reliability.md)).*
- **le Chaos** → *Chaos Engineering* — une **démonstration** déclarée, gouvernée,
  bornée ; il démontre la Constitution, ne la met jamais entre parenthèses.
  *([F5.5 §8, RY-9](../../source/production/05-reliability.md)).*

### Scalabilité (F5.6)

- **la Scalabilité** → *Scalability* — l'**invariance** de la Constitution sous la
  taille ; elle multiplie les mécanismes, ne divise jamais les vérités.
  *([F5.6 §1, SC-1](../../source/production/06-scalability.md)).*
- **la Résidence de vérité** → *truth residence* — toute vérité a une **résidence
  unique** ; les autres régions n'en voient que des projections datées ; *une
  localisation sert des lectures datées, elle ne tranche jamais un acte*.
  *([F5.6 §3, SC-4](../../source/production/06-scalability.md)).*
- **le Tenant** → *Tenant* (`TenantId`, gelé) — une Organisation ou un contexte
  de Workspace ; **jamais un propriétaire nouveau**. *([F5.6 §4, SC-3](../../source/production/06-scalability.md)).*
- **la Cellule** → *Cell* (`CellId`) — un contenant à deux mécanismes : un **rayon
  de panne** et un **périmètre de résidence** ; jamais un propriétaire.
  *([F5.6 §4](../../source/production/06-scalability.md)).*

### Opérations (F5.7)

- **les deux organes** → la **Gouvernance d'exploitation** approuve / l'**Exploitation
  opérante** exécute. *([F5.7 P2, OP-5→OP-12](../../source/production/07-operations.md)).*
- **l'Incident Commander** → *Incident Commander* — **coordonne**, ne **possède**
  jamais un droit métier. *([F5.7 P1](../../source/production/07-operations.md)).*
- **la Validation opérationnelle** → *operational validation*
  (`OperationalValidationId`) — le **sixième acte humain**, après la Vérification
  technique ; jamais un fail-open déguisé. *([F5.7.99](../../source/production/07-operations.md)).*
- **le Handover** → *handover* — explicite, accepté, horodaté ; sinon la
  responsabilité reste au cédant. *([F5.7.99](../../source/production/07-operations.md)).*
- **la Tâche corrective** → *corrective task* (`CorrectiveTaskId`) — objet gouverné
  complet ; **jamais « Action Item »**. *([F5.7.99](../../source/production/07-operations.md)).*

### Gouvernance (F5.8)

- **le Corpus Canonique** → *Canonical Corpus* — la Constitution **publiée** ; il
  ne la remplace jamais. *([F5.8 P1, PG-4](../../source/production/08-governance.md)).*
- **R2-Corpus** → *Corpus Materialization* — matérialise la Constitution ; **il ne
  la modifie jamais** (PG-11) — le présent effort documentaire. *([F5.8 P2](../../source/production/08-governance.md)).*
- **le Constitutional Diff / le Vocabulary Diff** → *un gardien de frontière*,
  déterministe et auto-vérifiable ; il observe, ne décide jamais. *([F5.8 P1, PG-5](../../source/production/08-governance.md), [F5.99 Procès VI](../../source/production/09-grand-audit.md)).*
- **le Production Board** → *Production Board* — gouverne les publications, jamais
  les lois. *([F5.8 P2, PG-13](../../source/production/08-governance.md)).*

### Concept transversal (F5.99)

- **la propriété émergente** → *emergent property* — ce qui **agit sans posséder**
  et se reconstruit depuis les registres ; cinq exactement (Fiabilité,
  Scalabilité, Opérations, Apprentissage, Gouvernance). *Terme réservé* (voir §D).
  *([F5.99 §2, Procès I](../../source/production/09-grand-audit.md)).*
- **le gardien de frontière** → *boundary guardian* — ce qui garde une frontière
  (un Diff garde une transformation ; une frontière garde un NON ; le Glossaire
  garde le sens). *([F5.99 Procès VI–VIII](../../source/production/09-grand-audit.md)).*

---

## §D. Les termes réservés (collisions tranchées — un mot, un propriétaire, partout)

Projection unifiée des réservations du corpus entier. *Un mot réservé l'est
partout, y compris dans les composés d'exceptions.*

### Les huit réservations de domaine (F2.5 §11)

| Mot réservé | Propriétaire | Le concurrent renommé |
|---|---|---|
| **Expired** | Consent (`ConsentExpired`) | la Caducité de l'Engagement → **Lapse** |
| **Withdrawn** | Consent (`ConsentWithdrawn`) | le Retrait de l'Économie → **Payout** |
| **Rejected** | Engagement (`AgreementRejected`) | l'écart de la Suggestion → **Dismissed** |
| **Participant** | Rencontre (Consultation) | l'interlocuteur du Messaging → **Interlocutor** |
| **Proof** | Reputation | la preuve d'entrée d'I&A → **Credential** |
| **Deposit** | Storage | la remise de la Consultation → **Submission** |
| **Channel** | qualifié des deux côtés | `SettlementChannel` / `ReachabilityChannel` |
| **Principal** | **Foundation Layout** | le commanditaire → **Commissioner** |

### Le quintette du refus (F2.5 §11)

| Mot | Réservé à |
|---|---|
| **Rejected** | Engagement (refus d'une Demande) |
| **Refused** | Consent |
| **Declined** | Invitation |
| **Dismissed** | Suggestion |
| **Denied** | Exceptions uniquement (le refus de commande transversal, jamais un fait) |

Plus **RetentionActive** (F2.5.2) — mot propre de la rétention encore ouverte.

### Les réservations de la Production (F5)

| Mot | Sens réservé | Le double technique |
|---|---|---|
| **Snapshot** | voix tactique (F3.1.11) | l'**Image de sauvegarde** (F5.2) |
| **Journal** | applicatif probant (F4.1 / F5.3) | le **journal de moteur** (= Log) |
| **Export** | droit de la personne (P9.6) | la **Copie d'exploitation** (F5.2) |
| **Session** | Identity & Access | jamais en télémétrie (F5.3 : `SessionId` réservé) |
| **Credential** | personnes (I&A) | jamais les machines (Preuve de machine) |
| **Recovery** *(banni nu)* | — | **Remplacement** (Flotte) / **Restauration** (Persistance) / **Reprise** (Fiabilité) (F5.5 §9) |
| **Capacity** *(nu)* | lecture physique (F5.6) | une limite d'offre est une **Policy** du produit (SC-7) |
| **Review** *(banni nu)* | — | quatre espèces qualifiées (F5.7.99 ; voir Vocabulary Diff, Lot 2) |
| **Publication** *(bannie nue)* | — | **Constitutionnelle** / **Canonique** / **Technique** (F5.8.99) |
| **propriété émergente** | concept de F5.99 (agir sans posséder) | à inscrire comme terme réservé (voir §H) |

Réservations de sécurité (F5.4.99) : **Matière personnelle** (Storage,
destructible) / **Fait personnel** (registres, immuable, crypto-shreddable) /
**Personne concernée** (Compte/Consent) — *« donnée personnelle » nu est banni* ;
`Nonce`/`Salt` sont des **mécanismes cryptographiques**, jamais nommables dans une
vérité.

---

## §E. Le vocabulaire interdit (extraits — liste close au Catalogue, Lot 4)

Projection de [F2.5 §10](../../source/constitution/04-bilingual-dictionary.md) +
les bannissements de la Production.

Booking / Reservation / Appointment → **Agreement** · Meeting / Call → **Encounter**
· User → **Person** · Wallet → **AvailableFunds** · Withdrawal → **Payout** (hors
`ConsentWithdrawn`) · Rating / Score → interdits · Chat / Thread / Inbox →
**Conversation** · Feed / Dashboard → interdits (surfaces) · History → les faits,
ou une projection nommée · Status → **State** qualifié · Settings → **Preferences**
· Login → **Entry** · Ticket → **SupportRequest** · Notification-objet →
**Signal** · **Replica** → une instance (`InstanceId` ; F5.1) · **Recovery** nu,
**Review** nu, **Publication** nue, **Capacity** nu, **Gouvernance** nue (qualifier
constitutionnelle / d'exploitation ; F5.4/F5.8) · `Create`/`Update`/`Delete`
génériques, `Set`, `Save`, `Handle` nu, `-Manager`/`-Helper`/`-Util`/`-Service`
nu.

---

## §F. Les théorèmes (démonstrations nommées — jamais des lois : règle N°33)

Le Glossaire **nomme** les théorèmes du corpus ; ce sont des **démonstrations**
(règle N°33 : elles prouvent et relient, elles ne décident jamais). Leur
propriétaire est le [Grand Audit F5.99](../../source/production/09-grand-audit.md).

- **le théorème fondamental du Titre Production** — la Production ne corrige
  jamais le métier (résiste sous cinq angles : ni correction, ni possession, ni
  NON, ni consensus, ni autorité temporelle).
- **le Théorème de Résidence de vérité** (A) et **le Théorème d'Absence de
  consensus global** (B) — **A ⟹ B** (un théorème et son corollaire).
- **le Théorème de la Chaîne de Démonstration unique** — toute entité a origine,
  propagation, terminaison et reconstruction.
- **le Théorème des identités** — objet gouverné à cycle de vie → identité ; tout
  le reste → pas d'identité.
- **le Théorème du Diff** — un Diff est un gardien de frontière, déterministe donc
  auto-vérifiable.
- **le Théorème de la frontière** — toute frontière garde un NON (redécouverte de
  *« qui a le droit de dire NON ? »*, F2.1).
- **le Théorème du langage** — le langage constitutionnel est la première
  frontière ; une ambiguïté lexicale est déjà une fuite d'autorité.
- **le Théorème du graphe** — la Constitution est un graphe orienté sans cycle
  d'autorité (référence ≠ autorité).
- **le Théorème des catastrophes** — les catastrophes détruisent les mécanismes,
  jamais les autorités.
- **le Théorème de nécessité** — la Constitution est une découverte, non une
  invention.
- **le Théorème final** — une Constitution est achevée quand chacune de ses
  vérités se redécouvre, se démontre, se reconstruit et se vérifie indépendamment,
  sans contradiction systémique.

---

## §G. Les identités (renvoi au Catalogue, Lot 4)

Le Glossaire nomme les **familles** d'identités ; l'énumération exhaustive et le
**Théorème des identités** (objet gouverné à cycle de vie → identité) sont du
Catalogue des identités (Lot 4).

- **Runtime** : `ExecutableId`, `ArtifactId`, `InstanceId`, `FleetId`.
- **Persistance** : la Fiche de Registre, `LossDeclarationId`, `Readmitted`,
  `RestorePlanId`.
- **Observabilité** : `IncidentId`, `AlertId`, `RunbookId`, la Main courante.
- **Sécurité** : `CredentialId`, `SessionId`, `RevocationId`, `SecurityPolicyId`,
  `ThreatModelId`, `RiskId`, `ControlId`, `VulnerabilityId`, `SecurityReviewId`,
  `DisclosureId`.
- **Fiabilité** : `ChaosExperimentId`, `FaultInjectionId`, `ReprisePlanId`,
  `ReliabilityPolicyId`, `DegradationPolicyId`, `IsolationPolicyId`,
  `LoadSheddingPolicyId`.
- **Scalabilité** : `CellId`, `RegionId`, `PlacementId`, `CapacityPlanId`.
- **Opérations** : `OperationalDecisionId`, `OperationalValidationId`,
  `ChangePlanId`, `MaintenancePlanId`, `PostmortemId`, `RCAId`,
  `CorrectiveTaskId`, `OperationalReviewId`.
- **Gouvernance** : `CorpusVersionId`, `PublicationId`, `GlossaryVersionId`,
  `CanonicalReleaseId`, `DocumentationAuditId`, `PublicationPackageId`.

*Refusés comme identités constitutionnelles (F5.99 Procès V, voir §H) :
`SnapshotId`, `BackupId`, `TrustChainId`, `DocumentationSignatureId`, `DiffId`
(mécanismes / attributs / actes) ; `PrincipalId` (collision Foundation).*

---

## §H. Dettes lexicales à résoudre par le Vocabulary Diff (Lot 2)

*Honnêteté du Glossaire (PG-14, PG-17 : toute dette est visible, jamais cachée ;
règle N°29 : une dette n'est jamais une exception).* Le présent Glossaire
**inscrit** les termes ratifiés ; leur **vérification** systématique contre la
Source, fail closed, est l'objet du **Vocabulary Diff (Lot 2)**. Restent à
purger/vérifier les cinq scories relevées par le Procès V et l'inscription
signalée par le Procès VIII :

1. **`propriété émergente`** — inscrit ici comme concept réservé (§C, §D) ; le
   Vocabulary Diff confirmera son sens unique dans tout le corpus (cinq verdicts
   du Procès I en dépendent).
2. **`PrincipalId`** — banni (collision avec Foundation Layout) ; l'acteur est
   `ActorRef` ou Preuve de machine.
3. **`SnapshotId`, `BackupId`, `TrustChainId`, `DocumentationSignatureId`,
   `DiffId`** — refusés comme identités constitutionnelles (mécanismes, attributs,
   actes de vérification).
4. **`FleetId`** — à expliciter comme identité (déjà projeté §C/§G).
5. **`OperationalPublicationId` vs `CanonicalPublicationId`** — désambiguïsation
   de « Publication » (trois espèces) ; et confirmation `OperationalTaskId` =
   `CorrectiveTaskId` (un seul objet).

Ces items ne sont pas des défauts de la Source : le Procès VIII a démontré que le
**système lexical est fermé** (tout nouveau mot rencontre son gardien) ; la
**purge actuelle** du Glossaire est le travail du Vocabulary Diff (Lot 2).

---

## Provenance de projection (non normatif)

Projection déterministe de la Source matérialisée (F1 → F5), jamais du transcript
(règle N°31 : le Corpus Canonique est l'unique référence documentaire). Le
**vocabulaire du métier** (§A, §B, §D-domaine, §E) est projeté de son propriétaire
officiel [F2.5](../../source/constitution/04-bilingual-dictionary.md) sans le
dupliquer en autorité. Le **vocabulaire de la Production** (§C, §D-production, §G)
est projeté des chapitres [F5.1](../../source/production/01-runtime.md) →
[F5.8](../../source/production/08-governance.md), chacun ayant signalé ses
« entrées de glossaire dues ». Les **théorèmes** (§F) sont nommés depuis le
[Grand Audit F5.99](../../source/production/09-grand-audit.md) comme
**démonstrations**, jamais comme lois (règle N°33). Les **énumérations
exhaustives** (73 faits, 79 commandes, 16 politiques, lois, identités,
anti-patterns) sont renvoyées aux **Catalogues (Lot 4)**. La **vérification**
Glossaire ↔ Source, fail closed, est le **Vocabulary Diff (Lot 2)** — les dettes
lexicales sont listées §H, visibles et gouvernées (PG-14). Ce Glossaire n'a
**aucun pouvoir éditorial** (GOVERNANCE #6) : il rassemble, il n'invente pas
(PG-8) ; toute évolution passe par le **Titre VII**.
