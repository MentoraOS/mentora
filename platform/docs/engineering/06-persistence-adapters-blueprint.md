# 06 — Persistence Adapters Blueprint (Lot 2A-2)

> **Statut : BLUEPRINT — aucune implémentation.** Validé contre R2 chapitre par
> chapitre ; l'implémentation n'ouvre que sur autorisation explicite du CTO.
> Autorité : la Foundation gelée (`docs/canon/`, tag `foundation-v1.0.0`).

## 1. Vision

Le Repository reste **la façade du port du domaine** — `AgreementRepository`
(1A) : `byId`, `byExpertAndWindow`, `retain`. Le port ne bouge pas d'une
ligne (F4.4 §3 : « *son évolution appartient au propriétaire du Port — jamais
l'implémenteur* »). Toute la mécanique vit EN DESSOUS, répartie en composants
spécialisés, remplaçables moteur par moteur (S-1 : « *le Registre est le
contrat du propriétaire, **le moteur un mécanisme*** » ; S-2 : « *les
dialectes meurent à l'adapter, tous ; le port ne parle que le dictionnaire* »).
Remplacer PostgreSQL par CockroachDB/MySQL/SQLite = réécrire l'intérieur du
package adapter, zéro ligne au-dessus.

**Deux réconciliations de vocabulaire (R2 gagne) posées d'entrée :**

1. **« Event Store + réhydratation par replay » → « Snapshot privé + delta »**
   (F5.2 §12, verbatim : « *reconstruction = **Snapshot privé + delta*** » ;
   F3.1.11 : le Snapshot est « *photographie interne de reconstitution,
   **privée au registre*** » — jamais un contrat, jamais servie). Le domaine
   gelé (1A) reconstitue par `Agreement.fromSnapshot(...)` et n'a **pas** de
   méthode d'application de faits : la reconstitution par rejeu de faits
   exigerait une évolution du domaine (Titre VII). Le blueprint retient donc :
   **snapshot privé écrit À CHAQUE rétention (delta = 0 par construction)** +
   **flux de faits append-only** conservé pour la provenance (O-4 : « *la
   chaîne éternelle… c'est la provenance des faits* »), la Réadmission (S-6)
   et l'alimentation du relais d'Outbox. La formule ratifiée reste vraie ;
   le delta est vide aujourd'hui, et pourra cesser de l'être si le Titre VII
   dote un jour le domaine de l'application de faits.
2. **« Replay »** : au sens R2, le replay est un **acte d'outillage de
   re-livraison** — « *jamais libre — un acte d'outillage journalisé, à cible
   nommée… refusable par la cible ; **il ne crée rien, il re-porte*** »
   (F4.3 §8). Il re-porte des faits déjà retenus vers un consommateur nommé.
   Ce n'est **pas** une reconstruction d'état. Les deux sens sont traités à
   leur place (§7 flux de lecture ; §9 outillage).

## 2. Arborescence cible

```
packages/adapters-persistence-agreement/
├── prisma/            schema.prisma + migrations expand-contract (S-7) —
│                      HÉBERGÉES ici, EXÉCUTÉES par l'exécutable Migration
├── src/
│   ├── repository/    PrismaAgreementRepositoryAdapter — la façade du port
│   ├── mapper/        domaine ⇄ lignes : snapshot-mapper (privé),
│   │                  fact-mapper (fait domaine → fait WIRE publié, 1B)
│   ├── snapshot/      la photographie privée : format versionné + checksum
│   ├── fact-stream/   le registre append-only des faits (« event-store » du
│   │                  mandat, nommé dans la langue du Corpus)
│   ├── outbox/        l'Outbox de faits (lignes wire + ENVELOPPE, M-3)
│   ├── concurrency/   version optimiste + clé R-A structurelle (« optimistic-
│   │                  lock » du mandat — pas un verrou : une comparaison)
│   ├── retention/     l'acte atomique unique (pas 8) — la « transaction/ »
│   │                  du mandat, nommée par son acte constitutionnel
│   ├── serializer/    canonique/checksum via @mentora/runtime-serialization ;
│   │                  wire via les sérialiseurs de @mentora/contracts-agreement (V-1)
│   ├── read/          implémentations d'AgreementStateReadPort + RightsPort
│   ├── projection/    VIDE — points d'extension documentés (STOP 1C-6)
│   └── fiche/         la Fiche de Registre (S-10) — opposable, vérifiée en CI
└── testing/           doubles + harnais d'intégration (PG réel via compose)
```

Dépendances : `domain-agreement` (le port + snapshot door), `contracts` +
`contracts-agreement` (langage publié, enveloppes), `application-agreement`
(ports de lecture), `kernel`, `runtime-serialization`, `runtime-logging`,
`@prisma/client` (SEUL import vendeur, confiné — A-9/I-7). Interdits : tout
import par un package domaine/application (I-1 : l'infrastructure « *n'est
connue de rien* ») ; tout framework dans une signature de port.

## 3. Composants

### 3.1 repository/ — `PrismaAgreementRepositoryAdapter`
- **Responsabilité** : implémenter les 3 méthodes du port, rien d'autre
  (« *les registres n'exposent que byIdentifier + les parcours du catalogue +
  les clés R-A déclarées* » — F4.1 §7). Un adapter « *sert une seule
  frontière et ne crée ni fait, ni Decision, ni vérité* » (I-4).
- **Propriétaire** : l'infrastructure ; le CONTRAT reste au domaine.
- **Flux `byId`** : lire la ligne snapshot → vérifier checksum → désérialiser
  (VersionedPayload) → `Agreement.fromSnapshot(...)` → `some(unit)` | `none`.
  Corruption (checksum faux, forme invalide) = **Exception** (le registre
  corrompu est un défaut, 1A : « corrupt = Exception »), jamais un `none`.
- **Flux `byExpertAndWindow`** : le parcours R-A déclaré — index sur
  (expertId, slot) des unités Confirmed chevauchant la fenêtre → liste
  reconstituée. Aucune recherche métier libre.
- **Flux `retain`** : §4.

### 3.2 mapper/
- **snapshot-mapper** : unité → `AgreementSnapshot` (porte privée 1A) →
  JSON canonique → VersionedPayload{version: 1} → checksum FNV-1a. Privé :
  ne traverse jamais le port, jamais une réponse (F3.1.11).
- **fact-mapper** : fait domaine (pendingFacts) → **fait WIRE publié**
  (contrats 1B — le langage que le relais portera au routage). La
  sérialisation wire appartient aux sérialiseurs déterministes de
  `contracts-agreement` (V-1 : « *le propriétaire du fait possède son
  contrat* ») — l'adapter les APPELLE, ne les redéfinit pas.
  L'ENVELOPPE (M-3 : MessageId, CorrelationId, CausationId, tentatives,
  horodatage transport) est fabriquée ici, à la rétention, JAMAIS dans le
  fait (« *l'une ne contamine jamais l'autre* »).
- Interdit : mapper vers un « DTO de domaine » — l'unité entre et sort par
  ses portes (snapshot/factory), entière ou pas du tout (S-2).

### 3.3 snapshot/
- **Fréquence** : à CHAQUE rétention (la ligne d'état EST la photographie ;
  delta = 0). Pas de « fréquence configurable » : un knob de fréquence sans
  rejeu domanial serait un flag technique sans effet légal.
- **Format** : VersionedPayload canonique + checksum ; **version 1**.
- **Compatibilité/évolution** : ADDITIVE seulement (esprit V-2) ; un champ
  nouveau est optionnel avec défaut à la lecture. Un changement CASSANT =
  migration expand-contract (S-7) transformant les lignes — structure,
  jamais le sens.
- **Invalidation** : n'existe pas — le snapshot est écrasé par la rétention
  suivante (une photographie par unité, la plus récente fait foi).
- **Reconstruction** : `fromSnapshot` (delta vide). Le flux de faits reste
  la référence probante si une réparation outillée (Migration) devait
  reconstruire des photographies — acte gouverné, jamais silencieux.

### 3.4 fact-stream/
- **Stockage** : append-only, une ligne par fait : (agreementId, sequence)
  = identité du fait (1A), type, payload wire canonique, occurredAtMs,
  provenance. **Unique(agreementId, sequence)** = idempotence structurelle
  (une re-écriture du même fait est refusée par la clé, absorbée par la
  rétention idempotente).
- **Ordre** : par sujet d'unité seulement (M-2/F4.3 §4 : « *l'ordre n'est
  garanti que par sujet d'unité* ») — `sequence` croissante par agreementId.
- **Relecture** : par identifiant, ordonnée par sequence — sert la
  provenance, l'audit (« *l'audit se refait sans traces* », O-4), la
  Réadmission S-6 et le replay-outillage (re-porter vers une cible nommée).
- **Corruption/récupération** : checksum par ligne ; une ligne corrompue =
  Exception + Signal d'exploitation ; la récupération est un acte gouverné
  (S-6 : Perte Déclarée, Réadmission par la police, à provenance marquée —
  « *rien n'est re-fabriqué sans preuve* »).
- Jamais un UPDATE, jamais un DELETE de faits (S-9) ; l'effacement légal =
  crypto-shredding par clés de personne, en Commands de police tracées.

### 3.5 outbox/
- **Écriture** : DANS la transaction de rétention, une ligne par fait :
  enveloppe complète + payload wire + statut (pending). A-3 : état + faits,
  UN acte ; A-4 : « *la publication lit la rétention — jamais l'inverse,
  jamais avant* » ; M-4 : « *toute publication naît d'une Outbox de
  propriétaire* ». **Aucune publication directe, jamais** — le RELAIS
  (exécutable Relay, F5.1 §3) lit les pending, porte au routage
  at-least-once, marque porté. La publication fantôme est impossible par
  construction (« *un fait publié non retenu n'existe pas* »).
- **Retries/quarantaine** : la politique de transport du relais, bornée,
  avec backoff (M-8) ; au-delà des bornes → **Quarantaine** : parqué,
  journalisé, Signal d'exploitation — « *rien ne meurt sans témoin* » ; un
  message poison ne bloque jamais la file. Le replay = acte d'outillage
  journalisé, à cible nommée, refusable (F4.3 §8).
- Le relais est un EXÉCUTABLE (pas ce package) ; l'outbox/ ne fournit que
  les lignes et leurs requêtes de lecture/marquage.

### 3.6 concurrency/ — « optimistic-lock » réconcilié
- **Pas un verrou.** S-3 verbatim : « *un conflit de concurrence est une
  **Failure**, jamais une Decision* » ; F5.2 §4 : « *un conflit optimiste
  (deux Séquences, une version) est une Failure transitoire* » ; F5.1 §19 :
  « *aucun invariant métier ne repose jamais sur un lease* ».
- **Mécanique** : la ligne snapshot porte `version` (1A : le champ existe
  sur l'unité, F5.2 §4). `retain` fait un UPDATE conditionnel
  `WHERE version = expected` (ou INSERT pour une naissance,
  unique(agreementId)) ; 0 ligne touchée → **Failure transitoire**
  (`retryable: true`) → le pipeline 1C-2 ré-entre au pas 4 (Loading) dans
  son budget technique. Jamais un refus métier.
- **Clé R-A structurelle** : contrainte d'EXCLUSION PostgreSQL sur
  (expertId, plage du créneau) des unités Confirmed — la règle vit au
  domaine (OverlappingSlotSpecification), la CLÉ est appliquée par le
  registre, le REFUS est une Décision motivée `TimeSlotUnavailable`
  (F3.2-A/R-A) — violation d'exclusion → refus structurel, PAS une Failure.
  Distinction des deux collisions : version = Failure ; clé R-A = Refus.

### 3.7 retention/ — l'acte atomique (la « transaction » du mandat)
- S-3 : « *la transaction appartient à la Séquence ; le registre fournit
  l'atomicité état+faits et l'isolation des clés R-A* ». Interdiction
  absolue F4.1 : « *port dans la transaction* » — la rétention NE PARLE À
  PERSONNE (A-3) : aucun port, aucun réseau, aucun appel sortant.
- **Flux d'une rétention** (une transaction sérialisable-suffisante) :
  1. garde de version (§3.6) — échec → rollback → Failure transitoire ;
  2. append des pendingFacts au fact-stream (séquencés) ;
  3. upsert de la ligne snapshot (photographie + version incrémentée) ;
  4. insert des lignes Outbox (enveloppes + wire) ;
  5. contraintes déclarées (clé R-A) — violation → rollback → Refus
     `TimeSlotUnavailable` ;
  6. COMMIT → retour `ok(void)` ; l'Application rappelle `retained()` (1A).
  Toute autre erreur moteur → rollback → Failure décrite (R-10 : une
  défaillance est une Failure, jamais une Decision).

### 3.8 serializer/
- Snapshot/fact-stream : `canonicalJson` + `VersionedPayload` + FNV-1a de
  `@mentora/runtime-serialization` (déterminisme : même unité → mêmes
  octets ; le checksum démontre, ne décide jamais).
- Wire (Outbox, fact-stream payloads) : les sérialiseurs déterministes de
  `@mentora/contracts-agreement` (V-1). Compression : `CompressionStrategy`
  (identité aujourd'hui ; un codec réel serait une ressource I-11).

### 3.9 read/ — les ports de lecture (1C-4)
- `AgreementStateReadPort.stateOf` : lecture de la ligne snapshot →
  `AgreementStateView` (la ligne de Read Model — l'unité ne sort jamais).
  S-5 : « *la validité se lit où la lecture-de-ses-écritures est garantie —
  jamais sur un réplica en retard* » → ces lectures frappent le primaire.
- `AgreementReadRightsPort.holdsStateRight` : parties depuis la ligne +
  l'acteur outillage déclaré — le mécanisme sous le port (F4.1.99).

### 3.10 projection/ — VIDE (STOP 1C-6 intact)
- Aucune table, aucun updater. **Points d'extension documentés seulement** :
  (a) le fact-stream append-only est la source rejouable de toute future
  projection ; (b) le relais publie les faits → un futur consommateur de
  projection sera une **Séquence de Réaction** (kernel 1C-5) avec sa propre
  Inbox (M-4) ; (c) rien d'autre tant que le CTO n'a pas ratifié sources et
  propriétaires (décisions Titre VII listées au STOP 1C-6).

### 3.11 prisma/ (migrations)
- Schema + migrations **expand-contract, réversibles par fenêtre** (S-7),
  versionnées avec le package ; **exécutées par l'exécutable Migration**
  (espèce F5.1 : « *ne touche jamais le sens* ») — jamais au boot de
  l'application (le boot valide, ne migre pas). Seed : dev/spec seulement —
  S-9 : « *les vraies données ne quittent jamais la production* » ; les
  environnements inférieurs reçoivent du dérivé anonyme par construction.
- Bootstrap dev : docker-compose (0A) + migration + seed de spec.

### 3.12 fiche/ — la Fiche de Registre (S-10)
Deux parties, deux propriétaires, opposable, vérifiée en CI :
- **Vérité** (domaine) : la vérité Agreement ; clés R-A déclarées
  (expert × créneau confirmé chevauchant) ; rétention ; politique
  d'effacement (structure immuable, matière crypto-shreddable).
- **Exploitation** (sous Gouvernance) : moteur (PostgreSQL, remplaçable),
  RPO/RTO, frontière de partition (max(unité, portée R-A) — S-8), dérivés
  reconstruisibles (la ligne snapshot, les index).

## 4. Diagrammes

**Écriture (RequestAgreement, bout en bout)**
```
RequestAgreement (wire)
  → CommandDispatch (1C-7 : table fermée, identité d'acte exigée)
  → RequestAgreementApplicationService (1C-3 : une délégation)
  → SequenceExecutor (1C-2 : les 10 pas gelés)
      pas 4  Loading        → repository.byId ── snapshot row → fromSnapshot
      pas 5  Validités      → couture wire→domaine (instant injecté)
      pas 6  Acte           → Factory/unité → Decision + pendingFacts
      pas 8  AtomicRetention→ repository.retain
                              ┌─ TX ──────────────────────────────┐
                              │ version guard (S-3)               │
                              │ fact-stream append (idempotent)   │
                              │ snapshot upsert (photo privée)    │
                              │ outbox insert (enveloppe + wire)  │
                              │ clé R-A (exclusion) → refus ?     │
                              └─ COMMIT ──────────────────────────┘
      pas 9  Publication    → STRUCTUREL (le RELAIS lit l'outbox,
                              at-least-once, plus tard, ailleurs)
      pas 10 Réponse+Journal
  → Decision (executed | refused | abandoned)
```

**Lecture / reconstruction (le « replay » d'état n'existe pas)**
```
byId → snapshot row → checksum → VersionedPayload → fromSnapshot → unité
        (delta = 0 par construction ; « Snapshot privé + delta », F5.2)

replay (R2) = outillage : fact-stream/outbox → re-porter des faits déjà
              retenus vers UNE cible nommée, journalisé, refusable (F4.3 §8)
```

## 5. Concurrence — les trois collisions, trois réponses

| Collision | Garde | Réponse |
|---|---|---|
| Deux rétentions, une version | UPDATE conditionnel sur `version` | **Failure transitoire** (S-3) → retry pipeline |
| Deux créneaux confirmés chevauchants | Contrainte d'exclusion (la clé R-A) | **Refus** `TimeSlotUnavailable` (Décision motivée) |
| Double naissance d'un Identifier | unique(agreementId) | **Refus** `TransitionUnavailable` (R-B, comme 1C-3) |

Aucun verrou pessimiste, aucun lease gardien d'invariant (F5.1 §19).

## 6. Stratégie d'erreur

Trois canaux, jamais mélangés (A-7) : refus structurels = Décisions
motivées (les deux clés) ; défaillances moteur (connexion, timeout,
sérialisation) = **Failures décrites** (R-10), retryables ; corruption de
ligne (checksum, forme) = **Exception** + Signal — jamais un silence, jamais
un `none` menteur.

## 7. Stratégie de tests (>95 %)

- **Unitaires** (sans PG) : mappers (aller-retour snapshot byte-identique,
  fait domaine → wire conforme aux validateurs 1B), sérialisation
  déterministe, checksums, classement des erreurs moteur → canaux.
- **Intégration** (PG réel, docker-compose 0A ; jamais de vraies données —
  S-9) : cycle complet retain→byId→retained ; byExpertAndWindow ;
  contrat du port rejoué via `describeContract` (0C, F4.4 I-10) contre
  l'adapter ET le double en mémoire — les mêmes promesses.
- **Concurrence** : deux retains parallèles même version → exactement une
  Failure ; chevauchement R-A → exactement un refus ; naissance double.
- **Transaction** : panne injectée entre append et outbox → rollback total
  (rien de partiel n'existe) ; l'outbox n'est jamais visible avant commit.
- **Rejouabilité/corruption** : ligne altérée → Exception + rien servi ;
  fact-stream relu = ordre par sujet strict.
- **Migration** : expand-contract appliquée/renversée sur base de spec.

## 8. Risques

Le relais (exécutable) et l'Échéancier n'existent pas encore — l'outbox
s'accumulera en pending jusqu'au lot exécutables ; assumé et documenté.
L'évolution du format snapshot au-delà de l'additif exigera l'exécutable
Migration. La reconstruction par delta réel attend une capacité domaniale
d'application de faits (Titre VII) — non requise aujourd'hui.

## 9. Roadmap d'implémentation (sur autorisation explicite)

1. **2A-2a** : schema.prisma + retention/ + concurrency/ + mapper/ +
   repository/ (le cœur : retain/byId/byExpertAndWindow), tests unitaires +
   intégration + concurrence. 2. **2A-2b** : outbox/ requêtes du relais +
   fact-stream relecture + fiche/ + read/ (ports 1C-4) + tests transaction/
   corruption. 3. **2A-3** : le premier exécutable (Root réel, boot F5.1,
   relais d'Outbox comme deuxième exécutable).
