---
doc: f3-01-tactical-building-blocks
title: F3.1 — Tactical Building Blocks (Constitution du modèle tactique, état final ratifié)
type: source
titre: domain
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 4A)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 4A"
sources_session:
  - "F3.1 — Tactical Building Blocks (constitution des seize familles de blocs : Aggregate, Entity, VO, Domain Event, Repository, Factory, Specification, Domain Service, Application Service, Projection, Process, Policy, Decisions/Errors ; matrice d'interaction ; 15 anti-patterns)"
  - "F3.1.99 — Tactical Constitutional Audit (cinq amendements : vérité/unité, NON clandestin des Entities, article des mutations, article de l'Identité, article des machines d'états + temps-en-donnée)"
note: >-
  Reconstruction fidèle de l'état final ratifié. F3.1 est amendé de cinq
  articles par F3.1.99 (intégrés et signalés). Ce chapitre possède la
  Constitution tactique (les familles de blocs et leurs lois). Le langage suit
  le Dictionnaire (F2.5) ; les lois stratégiques P1-P18 restent à F2.9. Les lois
  tactiques du registre R-A/R-B naissent au chapitre 02, R-C au chapitre de
  clôture. Scaffolding de session exclu. Titre VII pour toute évolution.
---

# F3.1 — Tactical Building Blocks
## Constitution du modèle tactique

> État **final ratifié** : F3.1 amendé des cinq articles de F3.1.99.

## Philosophie tactique

F2 a répondu à *qui possède quoi et qui peut dire NON*. Il n'a pas répondu à *comment un NON se tient debout à l'exécution*. Une architecture stratégique sans modèle tactique meurt de trois morts : l'invariant proclamé mais gardé par personne ; la vérité possédée sur le papier mais écrite par tous dans les faits ; le fait fabriqué hors de son constatant. Le tactique existe pour donner à chaque loi de F2 **un lieu d'exécution unique et nommé**. F2 dit la loi ; F3.1 dit qui la fait respecter, où, et comment.

## Aggregate

**Définition (amendée F3.1.99 §1).** L'Aggregate est **l'incarnation exécutable du détenteur du NON**. Il incarne **une UNITÉ de la vérité** ; la vérité du domaine est le **registre de ses unités** ; la frontière de l'unité est **la plus petite qui rende l'invariant vrai à chaque instant observable — tout excédent est injustifié et détruit**. **Responsabilités** : recevoir les commandes qui le visent, refuser (Décision motivée) ou agir, faire naître ses faits à l'instant de l'acte, protéger ses invariants sans aide extérieure. **Frontières** : une unité = une transaction ; il référence toute autre vérité par **Identifier seul**, jamais par objet ; il ne connaît ni les autres Aggregates, ni les surfaces, ni les ports. **Cycle de vie** : naissance par Factory ou constructeur garant, vie par commandes, reconstitution par son registre (sans faits — on ne re-constate pas le passé), fin par fait terminal, jamais par effacement (loi 14). **Qui protège les invariants** : lui, seul, à la source. **Qui publie** : lui — ses faits, nés dedans, après que son registre les a retenus. **Jamais** : ses états internes, ses projections, le contenu privé (P7). *Concurrents détruits* : le modèle anémique (invariant gardé par la discipline des appelants = personne) ; le God Aggregate (deux NON dans une frontière) ; l'event sourcing obligatoire (choix de registre, jamais loi tactique).

## Entity

**Définition.** Une Entity est une identité **intérieure à un Aggregate** : une chose qui a un cycle de vie au sein de la vérité, sans être la vérité. **Quand** : lorsqu'un élément doit être retrouvé, modifié ou clos à travers le temps au sein de la frontière. **Quand PAS** : sans devenir propre → Value Object ; avec un NON propre → Aggregate qui s'ignore. **Identité** : un Identifier stable, jamais recyclé. **Mutation** : uniquement par les méthodes de la racine ; jamais atteinte de l'extérieur, jamais exposée, jamais référencée hors frontière. **Comparaison** : par identité. **Test constitutionnel (amendement F3.1.99 §2)** : *une Entity dont une commande appartient à un acteur étranger à sa racine porte un NON clandestin : c'est un Aggregate qui s'ignore — promotion obligatoire.*

## Value Object

**Définition.** Le VO est une notion sans identité : il **est** sa valeur. **Immutabilité** : totale — un VO ne change pas, il est remplacé. **Égalité** : par valeur, champ à champ. **Validation** : à la construction, fail closed — **un VO invalide n'existe pas** (première ligne de défense des invariants). **Composition** : les VO se composent en VO ; un Aggregate est fait d'Entities et de VO, jamais de primitives nues. **Promotion en Aggregate** : uniquement quand la notion acquiert un NON propre ; **jamais** pour la persistance, un id technique, ou la taille. *Concurrent détruit* : le VO mutable « pour la performance » (une Entity clandestine, l'égalité par valeur devient un mensonge).

## Domain Event

**Définition** : le Fait de F2, au rang tactique. **Naissance** : dans l'Aggregate, à l'instant de l'acte ou de la décision — jamais fabriqué par un orchestrateur, un adapter ou un test. **Publication** : après que le registre a retenu la vérité (l'ordre est constitutionnel ; la rétention du fait et de l'état est **un seul acte du registre**). **Immutabilité** : totale, contenu privé exclu (P7). **Consommation** : at-least-once, idempotente par identité de fait (loi 14) ; un consommateur ne déduit jamais l'état — il interroge la source pour la validité (loi 15). **Versionnement** : additif ; renommer ou retirer = révision Titre VII. *Concurrents détruits* : l'événement-commande (« PleaseConfirmAgreement » — un fait constate, une commande demande) ; l'événement d'état (« AgreementUpdated » — ne constate aucun acte nommé).

## Repository

**Définition.** Le Repository est **le registre d'un Aggregate** : une collection à sémantique métier — retenir, retrouver par Identifier, parcourir ce que le domaine a le droit de parcourir. **Ce qu'il n'est jamais** : un moteur de requêtes d'affichage (Read Models), un lieu de logique métier (l'Aggregate), un traducteur d'infrastructure (l'implémentation, derrière le port). **Pourquoi sans logique** : une règle dans le registre est une règle contournée dès qu'un second chemin d'accès existe. **Pourquoi au domaine** : son interface est un **Port possédé par le domaine** ; l'implémentation vit dehors et se remplace sans deuil. *Concurrent détruit* : le Repository métier (« findEligibleExpertsForPayout » — l'éligibilité est une Specification, le registre ne juge pas).

## Factory

**Obligatoire** quand : la naissance établit des invariants entre plusieurs composants ; ou quand la création est un **acte métier** distinct (créer ≠ reconstituer). **Interdite** quand un constructeur garantit seul les invariants. **Pourquoi un constructeur ne suffit pas toujours** : il ne peut ni consulter une Policy publiée, ni distinguer naissance et reconstitution, ni refuser avec Reason. **La Factory ne publie jamais** (elle arme le premier fait ; l'unité le porte ; l'Application Service le publie après rétention) et **n'appelle jamais un port** (le dehors nécessaire arrive **en paramètres**). *Concurrent détruit* : la Factory universelle (« DomainObjectFactory »).

## Specification

**Définition.** Une Specification est un **prédicat métier nommé, composable, réutilisable**. **Pourquoi une règle n'est pas toujours un invariant** : l'invariant refuse à la source et ne se contourne pas ; la Specification répond, et sa réponse peut servir un refus, une Policy, une projection, un test. **Composition** : et/ou/non — des composites nommés. **Réutilisation** : entre Aggregate, Policy et tests du même domaine — jamais entre domaines (une question traversière est un fait publié qu'on interroge). *Concurrent détruit* : la Specification géante.

## Domain Service

**Appartient au domaine** : un savoir métier sans foyer dans un seul Aggregate — un calcul sur plusieurs vérités **lues** (jamais mutées), une capacité nommée (`<Capability>Service` qualifié). **Appartient à l'Aggregate** : tout ce qui touche SA vérité (le premier réflexe est toujours l'Aggregate). **Appartient à l'Application Service** : l'orchestration, les ports, la transaction — jamais le savoir. **Interdiction des fourre-tout** : `<Truth>Service` nu est interdit. *Concurrent détruit* : le Domain Service mutateur (deux mutations = deux commandes ; le service qui mute autrui est un God Aggregate sans frontière).

## Application Service

**Responsabilité** : le cas d'usage — recevoir la Command, vérifier la validité **aux sources** (loi 15), charger par le registre, faire agir l'Aggregate, retenir, publier les faits, commander les génériques par ports/ACL, rendre la Décision. **Orchestration, jamais décision métier**. **Transactions** : une transaction = un Aggregate ; deux vérités = deux cas d'usage reliés par faits ou par Process. **Interdictions** : contenir un invariant ; fabriquer un fait ; avaler un refus ; **appeler un autre Application Service**. *Concurrent détruit* : l'Application Service omniscient (un Process clandestin sans position rejouable).

## Projection

| Bloc | Est | N'est jamais |
|---|---|---|
| **Projection** | dérivation déterministe de faits, recalculable, citée (F2 Titre V) | persistée comme vérité ; source d'un refus d'acte |
| **Read Model** | une Projection servie, formée pour un lecteur nommé | un état mutable ; un canal d'écriture |
| **Vue** | composition de surfaces (plusieurs Read Models) | un objet du domaine |
| **Snapshot** | photographie interne de reconstitution, privée au registre | un contrat ; une donnée servie |
| **Cache** | copie périssable d'une Projection, datée, dite périmée (P17) | un cache de **validité** (loi 15 — interdit absolu) |

*Concurrent détruit* : le Read Model enrichi en écriture (« on corrige la projection à la main » = un fait clandestin sans constatant). **Précision F3.1.99** : une surface peut **guider** par projection (griser un bouton), mais l'acte re-vérifie toujours à la source.

## Process

**Définition.** Un Process réagit à des faits, émet des commandes, et **ne possède aucune vérité** : sa mémoire est sa position dans un parcours — procédurale, reconstruisible depuis les faits, jetable. **Quand** : un parcours transverse réel, nommé, à étapes (`ErasureProcess`). **Jamais** : pour épargner deux consommateurs de faits ; pour « coordonner » ce qui n'a pas d'étapes ; ni comme domaine. **Pourquoi sans vérité** : s'il en possédait une, il serait un domaine et émettrait des faits, ce qui lui est interdit : un Process commande, les propriétaires constatent. *Concurrent détruit* : le Process omniscient (le chef d'orchestre : quinze vérités, un scribe, un point de mort).

## Policy Objects — comparaison

| Question | Réponse |
|---|---|
| La règle est une **loi constitutionnelle** ? | **Rule** — vit dans F2.6/F2.7 ; le code la cite, ne la redéfinit pas |
| La règle est **publiée d'avance**, avec paramètres du produit ? | **Policy Object** — réification d'une politique de F2.5 ; rend une Décision motivée ; ses paramètres sont de la configuration |
| La règle est une **question réutilisable** ? | **Specification** |
| La règle est un **savoir calculatoire** multi-vérités en lecture ? | **Domain Service** |
| La règle est **inviolable à chaque instant** ? | **Invariant** — dans l'Aggregate, sans porte |

Une Policy consulte des Specifications ; une Specification ne consulte jamais une Policy. L'Aggregate applique les deux ; aucun des deux n'agit seul.

## Domain Errors & Decisions

**Decision** : l'issue de toute Command — acceptée ou refusée, toujours motivée (**Reason**) ; un objet de retour de plein rang, jamais une exception. **Refusal** : la Décision négative — métier, attendue, saine. **Exception** : le refus immédiat d'un appel malformé ou impossible — `<Truth><Reason>Exception`, jamais persistée, jamais un fait. **Violation** : la tentative contre une loi ou un invariant — matière de police, tracée. **Failure** : l'incapacité technique — réessayable, sans sens métier. *Concurrent détruit* : le refus jeté en exception (l'exception fait du refus un accident ; or le refus est la moitié du contrat P4 — il se rend, motivé, comme une valeur).

## Matrice d'interaction des blocs

| Bloc → connaît | Aggregate | Entity | VO | Event | Repo (port) | Factory | Spec | Policy | Dom.Service | App.Service | Projection | Process |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Aggregate** | Id seul | crée/possède | possède | **fait naître** | — | — | applique | applique | — | — | — | — |
| **Entity** | sa racine | — | possède | — | — | — | — | — | — | — | — | — |
| **VO** | — | — | compose | — | — | — | — | — | — | — | — | — |
| **Factory** | crée | — | crée | arme le 1er | — | — | applique | consulte | — | — | — | — |
| **Dom.Service** | lit | — | lit | — | — | — | applique | — | — | — | — | — |
| **App.Service** | commande | — | — | publie (après rétention) | appelle | appelle | — | — | appelle | **jamais un autre** | — | — |
| **Projection** | — | — | lit | consomme | — | — | peut citer | — | — | — | — | — |
| **Process** | Id seul | — | — | consomme | — | — | — | consulte | — | commande via | — | — |

**Qui refuse qui** : l'Aggregate refuse les Commands ; la Factory refuse les naissances ; le VO refuse d'exister invalide ; l'Exception refuse l'appel malformé — quatre refus, quatre portes, aucune autre.

## Naming Constitution (tactique — complète F2.5.1 §11)

Aggregates `<Truth>` nu · Entities `<Notion>` nu (intérieures, jamais exportées) · VO `<Notion>` nu · Repositories `<Truth>Repository` · Factories `<Truth>Factory` · Specifications `<Question>Specification` · Policies `<Truth><Rule>Policy` · Domain Services `<Capability>Service` qualifié · Application Services `<UseCase>ApplicationService` · Read Models `<Name>ReadModel` · Snapshots `<Truth>Snapshot` · Processes `<Journey>Process` · Exceptions `<Truth><Reason>Exception` · Reasons `<Reason>` nominal · Decisions `<Command>Decision` · Violations `<Law>Violation`. Interdits : Manager, Helper, Util, Impl, Base-, Common, Shared, Data, Info.

## Anti-Patterns — quinze, détruits

1. **Aggregate anémique** — l'invariant gardé par personne. 2. **God Aggregate** — deux NON, une frontière. 3. **Entity intelligente** — le dedans qui connaît le dehors. 4. **VO mutable** — l'égalité mensongère. 5. **Obsession primitive** — l'invariant repoussé à l'usage, c'est-à-dire nulle part. 6. **Repository métier** — le registre qui juge. 7. **Factory universelle** — la naissance sans garant nommé. 8. **Specification géante** — la question innommable. 9. **Service fourre-tout** — le savoir sans foyer. 10. **Application Service omniscient** — le Process clandestin. 11. **Projection persistée comme vérité** — le fait sans constatant. 12. **Read Model mutable** — l'écriture par la fenêtre. 13. **Process omniscient** — le scribe universel. 14. **Événement-commande** — l'ordre irréfusable déguisé en constat. 15. **Cache de validité** — le NON périmé qui autorise. Chacun meurt au même test : *qui protège l'invariant, qui détient le NON, qui a constaté ?*

---

# Les cinq amendements de F3.1.99

Cinq coups portés par l'audit, absorbés comme amendements (aucun ne déplace un bloc ; chacun ferme une porte) :

1. **Vérité / unité** — l'Aggregate incarne une **unité** de la vérité ; la vérité du domaine est le registre de ses unités ; la frontière de l'unité est la plus petite qui rende l'invariant vrai. *(Intégré à la définition de l'Aggregate ci-dessus.)*
2. **NON clandestin des Entities** — une Entity dont une commande appartient à un acteur étranger à sa racine est un Aggregate qui s'ignore : **promotion obligatoire**. *(Intégré à l'Entity ci-dessus ; l'exemple « Invitation » de F3.1 tombe et sera une unité propre en F3.2-B.)*
3. **Article des mutations** — toute mutation porte un **verbe du dictionnaire (Command)**, rend une **Decision**, et **fait naître un fait** si elle change la vérité. Aucun setter public, aucune mutation silencieuse. Naissance, évolution, fermeture : trois moments, trois familles de verbes, aucun quatrième.
4. **Article de l'Identité** — un **Identifier** est opaque, stable, jamais recyclé, jamais dérivé d'une donnée mutable, jamais porteur de sens ; l'unicité vit dans le registre de l'unité ; la comparaison est l'égalité stricte ; les identités externes sont des traductions d'ACL, jamais l'identité.
5. **Article des machines d'états et du temps-en-donnée** — les états d'une unité forment un **ensemble fermé** du dictionnaire ; toute transition est une **commande nommée qui fait naître un fait** (aucune transition silencieuse) ; les états terminaux sont **irréversibles** (on ne réactive pas : on fait naître une unité nouvelle) ; aucun état inatteignable ni sans sortie autre que terminale ; **le type rend les états impossibles inexprimables**. Et : **l'horloge n'entre jamais dans l'unité** — l'échéance (`Elapsed`, `Lapsed`, `Expired`, `RetentionActive`) se constate sur un **instant reçu en donnée**, porté par une commande d'outillage du temps ; l'unité juge l'instant, elle ne le lit pas.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F3.1** (les seize familles de blocs, la matrice d'interaction, les quinze anti-patterns) et **F3.1.99** (cinq amendements intégrés et récapitulés ci-dessus). Les définitions constitutionnelles des blocs suivent le Dictionnaire (F2.5) et les lois P1-P18 (F2.9). Les lois tactiques du registre **R-A** et **R-B** naissent au chapitre 02 (F3.2-A) ; **R-C** au chapitre de clôture tactique (Lot 4C). Le scaffolding de session (Phase 0, notation, décision, État Git, STOP) n'est pas reproduit.
