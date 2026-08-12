---
doc: f4-01-application-core-sequence
title: F4.1 — Application Core & la Séquence de Commande (état final ratifié)
type: source
titre: application
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 5A)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 5A"
sources_session:
  - "F4.1 — Application Core Architecture (l'Application Service, LA SÉQUENCE en dix pas, lois A-1→A-10, dispatchers, gardes structurels, 7 anti-patterns applicatifs)"
  - "F4.1.99 — Application Service Constitutional Audit (cinq amendements : ordre Chargement avant Validités ; bloc d'injections ; dispatchers propriétés-gelées/mécanismes-libres ; séparation enveloppe/fait ; 8e anti-pattern la Séquence permutée)"
  - "F4.99 — Grand Application Audit (consulté : ne change ni les dix pas ni les lois A ; ajoute deux Séquences sœurs et annote A-5/A-9 dérivées-retenues — matérialisé au chapitre de clôture, Lot 5C)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F4.1, après les cinq
  amendements de F4.1.99. Ce chapitre possède la Séquence de Commande (dix pas)
  et les lois d'exécution A-1→A-10. Le Grand Audit F4.99 ne modifie NI les dix
  pas NI le contenu des lois A ; il reframe cette séquence comme « Séquence de
  Commande » (l'une de trois : Commande/Réaction/Lecture) et annote A-5/A-9 comme
  dérivées-retenues — ces ajouts et annotations appartiennent à F4.99 (chapitre
  de clôture, Lot 5C) et sont référencés, non anticipés. Langage suivant le
  Dictionnaire (F2.5), blocs suivant F3. Scaffolding de session exclu. Titre VII
  pour toute évolution.
---

# F4.1 — Application Core & la Séquence de Commande

> État **final ratifié** : F4.1 amendé des cinq articles de F4.1.99 (dont l'ordre
> corrigé de la Séquence). C'est **la première des trois Séquences d'exécution** ;
> les deux autres (Réaction, Lecture) et la loi de clôture « trois chemins
> seulement » vivent au [chapitre 05 (Grand Application Audit)](05-grand-application-audit.md).

## 1. L'Application Service — définition constitutionnelle

**Un Application Service est le gardien d'exécution d'UN cas d'usage** : il fait traverser une Command du premier appel jusqu'à la publication des faits, dans un ordre que lui seul connaît. **Il possède** : la Séquence, la transaction, les ports qu'il commande, le journal corrélé de son exécution. **Il ne possédera jamais** : une règle métier, un invariant, un fait (il n'en fabrique aucun), une vérité, un état entre deux appels (il est sans mémoire — ce qui doit se souvenir est un Process). **Il ne contient pas de métier** (le métier vit dans l'unité, les Policies, les Specifications, F3.1.10) ; **il ne décide pas** (il transporte des Décisions ; son seul « branchement » est l'obéissance au refus, pas 7) ; **il n'appelle jamais un autre Application Service** (loi gelée F3.1.10 — les cas d'usage s'enchaînent par faits ou par Process Manager, jamais par empilement).

## 2. LA SÉQUENCE DE COMMANDE — l'exécution canonique d'un Use Case (ordre corrigé par F4.1.99)

Tout cas d'usage de Mentora exécute **exactement ces dix pas, dans cet ordre** :

1. **Réception** — le payload devient une Command typée du dictionnaire ; malformé → `Exception`, fin.
2–3. **Injections** *(bloc à ordre conventionnel — amendement F4.1.99 : les deux pas sont mutuellement indépendants)* — l'**identité** (`ActorRef` établi par la preuve de session, traduit par l'ACL d'entrée ; jamais lue d'un contexte ambiant) et le **temps** (**UN instant capturé, une fois** ; toute la suite vit à cet instant).
4. **Chargement** — le registre, par Identifier ; rien d'autre (aucune recherche métier — R-A). *(Amendement F4.1.99 : le Chargement précède les Validités — dépendance des données : `OpenEncounter` doit connaître les participants, qui vivent dans l'unité.)*
5. **Validités aux sources** — les Queries R-C requises (validité de consentement, cadre, éligibilité), synchrones, l'ayant droit vérifié au dispatch, **sur données injectées ET faits chargés** ; les résultats deviennent des **données** passées au domaine (loi 15).
6. **Acte** — la Command sur l'unité ; l'unité rend sa **Decision** et, si elle agit, fait naître ses faits *en elle*.
7. **Refus** → retour immédiat de la Décision motivée : aucune rétention, aucun fait, journal corrélé du refus. Un refus est une exécution réussie du contrat.
8. **Rétention atomique** — la **Unit of Work** : l'état de **l'unique** unité + **ses faits dans l'Outbox de faits**, retenus **dans le même acte atomique du registre**. La rétention **ne parle à personne** (aucun port, aucun réseau) — loi anti-transactions-longues.
9. **Publication** — le **relais d'Outbox**, *après* la rétention, lit ce qui fut retenu et le porte au routage (at-least-once). La publication fantôme est impossible par construction (un fait publié non retenu n'existe pas : le relais ne lit que le retenu).
10. **Réponse et journal** — la Décision remonte à l'appelant ; l'exécution est journalisée sous son `CorrelationId`.

**L'effet unique sans mythe** : *exactly-once ne se promet pas, il se produit* — at-least-once (relais) + **Inbox** du consommateur (déduplication par identité de fait, clé R-A) + clés R-A du domaine. Trois étages.

## 3. Rollback, erreurs, refus

**Rollback technique** : légal **uniquement à l'intérieur du pas 8 inachevé** — rien n'était retenu. **Après rétention : plus jamais** — on compense vers l'avant (loi 17). **Exception** (appel malformé, contrat violé) : remonte telle quelle, jamais convertie en refus. **Décision de refus** : une **valeur**, jamais attrapée, transportée avec son Reason. **Panne technique** : `Failure` réessayable — l'idempotence tient parce que la Command porte son **identité d'acte** (replay dédupliqué, retry = acte nouveau).

## 4. Injections

**Le temps** : port `Clock`, capturé au pas 2-3 ; le domaine ne voit que des instants-données. **L'identité** : port d'entrée (session → `ActorRef`) via l'ACL d'I&A ; **aucun « utilisateur courant » ambiant**. **Les Policies** : construites avec leurs paramètres de configuration produit au démarrage (composition root), injectées ; jamais instanciées en chemin.

## 5. Queries R-C

Toute lecture passe par le **Query Dispatch** qui identifie l'ayant droit depuis l'identité injectée, **refuse motivé** si le droit manque (R-C), route vers le Read Model ou la source. **Les validités (pas 5) n'passent jamais par un Read Model** : elles interrogent la source, synchrones — un Read Model de validité serait le cache interdit (Titre VI).

## 6. Les Dispatchers

**Command Dispatcher** : résout une Command vers **l'unique** Application Service qui la porte (table fermée — deux porteurs = erreur détectée au démarrage) ; exige l'identité d'acte ; injecte identité et corrélation ; **zéro logique métier**. **Query Dispatcher** : résout vers son lecteur, **applique R-C** (grille des ayants droit, catalogue F3.3 §5), journalise. **Propriétés gelées, mécanismes libres** *(amendement F4.1.99)* : la Constitution gèle des **propriétés** (table fermée, un porteur par Command, vérifiée au démarrage, lisible) — pas un mécanisme (switch, registre, annotations : libres, sauf la réflexion qui cache la table, interdite comme *forme*).

## 7. Les gardes-fous structurels

Contre le **Repository métier** : les registres n'exposent que byIdentifier + les parcours du catalogue + les clés R-A déclarées (scans d'implémentation). Contre la **logique cachée** : aucun branchement hors du pas 7 — un `if` métier dans un service est ingrammatical. Contre la **fuite de framework** : le domaine ne compile aucun import de framework (scanné) ; les types du dehors meurent aux Adapters. Contre l'**Adapter qui remonte** : un Adapter n'est référencé que par la composition root ; aucun type d'Adapter dans une signature de service ou de domaine. **Pour que l'orchestrateur reste orchestrateur** : la Séquence est fermée — un Application Service est conforme s'il est *ennuyeux* : dix pas, aucun talent.

## 8. Découpage des Use Cases et transactions

**Un cas d'usage = une Command du catalogue** : le découpage est déjà fait par le dictionnaire ; aucun service « gère » un sujet — il exécute UNE commande (`<UseCase>ApplicationService`). **Transactions courtes par construction** : tout ce qui parle (pas 1-5, 9) est hors transaction ; la transaction (pas 8) n'est que l'écriture atomique.

## 9. Observabilité — enveloppe / fait

**CorrelationId** : né au pas 1, injecté partout, **porté par l'ENVELOPPE de transport, jamais par le fait** *(amendement F4.1.99 : l'enveloppe — transport, corrélation, tentatives — et le fait — domaine, pur F3.1.5 — sont deux couches ; l'une ne contamine jamais l'autre)*. **Journal** : un enregistrement par pas de la Séquence — jamais un contenu, jamais un secret (P7). **Métriques** : par cas d'usage — les Reasons donnent des métriques *métier* gratuites (un pic de `TimeSlotUnavailable` est un signal produit).

## 10. Testabilité

Un cas d'usage se teste **sans framework** : doublures des seuls ports (Clock, registres, dispatch), Command en entrée → assertions sur la Décision (valeur), les faits retenus dans l'Outbox, l'ordre des interactions, le journal. L'unité se teste sans aucune doublure (F3.1). **Le test du service est un test de conformité à la Séquence.**

## 11. Architectures concurrentes — détruites

Sans couche applicative (endpoints intelligents) · Mediator à pipeline de behaviors · Chorégraphie intégrale sans services · Transactions distribuées / 2PC · Bus-comme-vérité (publier d'abord) · Framework d'orchestration first — **toutes détruites**. Une seule survit : **la Séquence gardée par des services sans talent.**

## 12. Lois d'exécution A-1 → A-10

- **A-1** Un cas d'usage = une Command = un Application Service = une unité = une transaction.
- **A-2** La Séquence est fermée : dix pas, cet ordre, aucun autre.
- **A-3** La rétention est atomique (état + faits en Outbox) et **ne parle à personne**.
- **A-4** La publication lit la rétention — jamais l'inverse, jamais avant.
- **A-5** L'effet unique = at-least-once + Inbox + clés R-A ; exactly-once ne se promet pas, il se produit. *(F4.99 la marque **dérivée-retenue** : A-5 dérive de M-4 + R-A ; opposable sans refaire la dérivation — ch. de clôture, Lot 5C.)*
- **A-6** Identité, temps, corrélation : **injectés, jamais ambiants** ; un instant par exécution.
- **A-7** Le refus est une valeur transportée ; l'Exception un défaut d'appelant ; la Failure un réessai — trois canaux, jamais mélangés.
- **A-8** Les Dispatchers routent et refusent (R-C, idempotence) — ils ne pensent pas.
- **A-9** Aucun type d'Adapter au-dessus de la composition root ; aucun import de framework dans le domaine (scanné). *(F4.99 la marque **dérivée-retenue** : A-9 dérive de I-2 + I-7.)*
- **A-10** Le journal suit la Séquence, porte la corrélation, et ne contient jamais une matière.

**Interdictions absolues** : App→App ; état dans un service ; `if` métier hors pas 7 ; port dans la transaction ; publication hors relais ; horloge lue ; identité ambiante ; refus avalé ; Read Model de validité ; contenu dans un journal.

**Checklists PR** (s'ajoutent à F3.3 §11) — **Application Service** : □ une Command du catalogue □ les dix pas, dans l'ordre □ zéro branchement hors pas 7 □ ports seuls, typés capacité □ testé par conformité à la Séquence. **Outbox/Inbox** : □ rétention atomique état+faits □ relais at-least-once □ Inbox par identité de fait □ aucune publication directe. **Dispatcher** : □ table fermée, un porteur par Command □ R-C appliquée déclarativement □ identité d'acte exigée. **Observabilité** : □ CorrelationId de bout en bout □ un enregistrement par pas □ zéro matière.

**Anti-Patterns applicatifs (8, s'ajoutent aux 18 tactiques)** : l'endpoint intelligent · le behavior-cerveau · le service bavard (App→App) · la rétention qui parle · la publication fantôme · l'identité ambiante · le gestionnaire d'erreurs qui avale les refus · **la Séquence permutée** *(8e, née de F4.1.99 : valider avant charger, publier avant retenir — solution : l'ordre corrigé, affiché, opposable)*.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F4.1** (l'Application Service, la Séquence en dix pas, lois A-1→A-10) et **F4.1.99** (cinq amendements intégrés : **Chargement (4) avant Validités (5)** ; pas 2-3 = bloc d'injections conventionnel ; dispatchers propriétés-gelées/mécanismes-libres ; séparation enveloppe/fait ; 8ᵉ anti-pattern la Séquence permutée). **Démonstration de la portée du Grand Audit F4.99** (règle N°7) : F4.99 ne change **ni les dix pas ni le contenu des lois A** ; il reframe cette séquence comme la **Séquence de Commande** (l'une des trois — Commande/Réaction/Lecture — la loi de clôture « trois chemins seulement » étant sa propriété) et **annote** A-5/A-9 comme *dérivées-retenues* (annotation, non modification de contenu) ; ces ajouts appartiennent au chapitre de clôture (Lot 5C) et n'y sont pas anticipés. Le scaffolding de session (Phase 0, couverture des 30 questions, scores, décision, État Git, STOP) n'est pas reproduit.
