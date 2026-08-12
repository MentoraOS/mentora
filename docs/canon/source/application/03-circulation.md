---
doc: f4-03-circulation
title: F4.3 — la Circulation applicative (état final ratifié)
type: source
titre: application
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 5B)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 5B"
sources_session:
  - "F4.3 — Messaging, Event Bus & Integration Architecture (la Circulation : quatre familles, Bus muet, routage-projection, enveloppes, intégrations, Inbox/Outbox, livraison, Quarantaine, lois M-1→M-10, 9 anti-patterns)"
  - "F4.3.99 — Circulation Constitutional Audit (amendements : Constitution du versionnement V-1→V-6 ; clés opaques d'enveloppe ; autorité de replay ; Quarantaine sans vérité ; gateway borné à la session ; Decision-réponse non-famille)"
  - "F4.99 — Grand Application Audit (consulté : nomme l'Outbox du propriétaire « Outbox de faits » ; la chaîne entière parcourue sans altération — matérialisé au chapitre de clôture, Lot 5C)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F4.3, après les amendements de
  F4.3.99 (dont la Constitution du versionnement V-1→V-6). Ce chapitre possède la
  Constitution de la Circulation et les lois M-1→M-10 et V-1→V-6. Le terme
  « Messaging » restant réservé au domaine des Conversations (loi 10), l'objet de
  ce chapitre est « la Circulation ». Le Grand Audit F4.99 n'altère pas ces lois :
  il nomme l'Outbox du propriétaire « Outbox de faits » (distinction, ch. de
  clôture, Lot 5C). Scaffolding de session exclu. Titre VII pour toute évolution.
---

# F4.3 — la Circulation applicative

> État **final ratifié** : F4.3 amendé des articles de F4.3.99. **« Messaging »
> est réservé au domaine des Conversations** (loi 10) ; le terme constitutionnel
> de ce chapitre est **la Circulation**.

## 1. Définition constitutionnelle

La Circulation est **l'ensemble des lois garantissant qu'une information quitte son propriétaire, traverse le système et atteint son destinataire sans que la vérité transportée ne soit jamais modifiée, inspectée ou interprétée en chemin**. **Elle possède** : les enveloppes, les tables de routage dérivées des déclarations, les garanties de livraison, la Quarantaine, les traces. **Elle ne possède jamais** : un sens, une vérité, un fait, une décision, une position, un contenu (scellé). **Elle interdit** : toute altération, toute inspection de matière, tout enrichissement en chemin — un transport qui comprend est un transport qui ment un jour.

## 2. Les quatre familles — irréductibles

| | **Command** | **Query** | **Domain Event** | **Message d'intégration** |
|---|---|---|---|---|
| Propriétaire | le domaine cible | le domaine lu | **l'émetteur-constatant** | un dialecte (personne chez nous) |
| Destinataire | UN porteur (table fermée) | UN lecteur | tous les abonnés déclarés | l'ACL de frontière, seule |
| Réponse | une **Decision**, toujours | données ou refus R-C | **aucune, jamais** | un accusé de transport au mieux |
| Durée de vie | transitoire | instantanée | **éternelle** | celle du dialecte |
| Identité | identité d'acte | — | identité de fait | identité du fournisseur, traduite |

**Fusions détruites** : l'événement-commande, la commande-événement, la query-commande, le message externe consommé comme fait. **La cinquième famille chassée** : la **Decision qui revient (Reply)** n'a ni initiateur propre, ni abonné, ni vie propre — *c'est la jambe retour du contrat de Command, pas une famille* (amendement F4.3.99).

## 3. Event Bus — le Bus est MUET

Le Bus ne possède **ni les événements** (l'Outbox du propriétaire est la source de vérité de toute publication), **ni les abonnements** (déclarés par les consommateurs, listes closes vérifiées au boot), **ni la sémantique des retries et délais** (politiques de transport bornées) ; il possède **des tuyaux**. *Dumb pipes, smart endpoints* — comme répartition démontrée des NON. **Aucune responsabilité orpheline** : la péremption de transport est une politique d'enveloppe bornée (la validité *métier* reste au propriétaire) ; le Bus vérifie la **forme** de l'enveloppe, jamais la matière.

## 4. Routing — propriétés gelées, mécanismes libres

**Propriétés** : une Command va à **un** porteur (point-à-point, table fermée) ; un fait va à **tous ses abonnés déclarés** (fan-out ; la table de routage est une **projection des abonnements**, reconstruisible) ; **aucun broadcast vers l'inconnu** ; l'ordre n'est garanti que **par sujet d'unité**. **Mécanismes libres** : topics, exchanges, queues, partitions. Tables persistées légales comme **cache d'une projection** ; configuration manuelle interdite (la dérivation est la loi).

## 5. Enveloppes — la frontière transport/domaine

**Dans le Domain Event (gelé F3)** : le fait — identités, natures, instants, auteurs, provenances. **Dans l'Enveloppe** : `MessageId`, `CorrelationId`, **`CausationId`** (le message qui a causé celui-ci — chaîne de causalité, adoptée ici), tentatives de livraison, horodatage de transport, trace. **Clés opaques (précision F4.3.99)** : l'Enveloppe porte des **clés opaques copiées des identifiants du fait** (identité de fait pour la déduplication, clé de sujet pour l'ordre M-6) — un identifiant est un **nom**, pas une vérité ; le transport achemine par des noms qu'il ne comprend pas. **Un Domain Event qui connaît son transport est un fait qui change quand l'infrastructure change** : interdit. L'enveloppe se jette ; le fait demeure.

## 6. Intégrations externes — où meurt le dialecte

**Tout dialecte meurt à l'Adapter, traduit par l'ACL de son commanditaire.** **Un Adapter ne publie JAMAIS de Domain Events** — seul un propriétaire constate ; un webhook de paiement est un rapport étranger, traduit en **compte rendu**, sur lequel le commanditaire **commande** et l'unité constate. **Il produit des Commands, et c'est son unique bouche** : l'ACL traduit l'entrant en Commands du dictionnaire — jamais en faits. *(F4.3.99 : douze intégrations jugées, zéro exception — aucun adapter ne mérite de constater un fait, le constatant existe déjà chez nous.)*

## 7. Inbox / Outbox

*Outbox par domaine* (registre du propriétaire, écriture atomique état+faits) : **la seule constitutionnelle**. *Inbox par consommateur* : **la seule** (chacun son registre d'identités de faits traités ; par *consommateur*, jamais par domaine — deux consommateurs partageraient une mémoire). Les variantes globales/mémoire/broker : mortes (vérité déplacée, amnésie, délégation). *(F4.99 nomme l'Outbox du propriétaire « Outbox de faits » — distinction, ch. de clôture, Lot 5C.)*

## 8. Livraison — ce que Mentora garantit

**At-least-once + effet unique** (relais, Inbox, clés R-A) pour tout ce qui compte. **At-most-once** : les seuls Signals aux personnes (best effort assumé). **Exactly-once** : interdit. **Retry** : politique de transport **bornée**, avec backoff (le retry infini est un anti-pattern). **Replay** : jamais libre — **un acte d'outillage journalisé, à cible nommée** (re-livrer l'Outbox de X vers le consommateur Y — jamais un arrosage), refusable par la cible ; il ne crée rien, il re-porte (amendement F4.3.99). **Dead Letter = la Quarantaine** : un message qui échoue au-delà des bornes est **parqué, journalisé, et signale l'exploitation** (rien ne meurt sans témoin) ; un poison message ne bloque jamais la file des autres.

## 9. La Quarantaine — sans vérité (F4.3.99)

Elle ne détient que des **copies de transport** (enveloppes + matière scellée) ; sa perte ne perd aucun fait (les Outbox des propriétaires les gardent) — le pardon passe. Sortie par **re-livraison journalisée** après correction ; destruction par une **rétention de transport bornée et publiée**, avec journal — **la suppression silencieuse est interdite**.

## 10. Conversations inter-domaines — quatre verbes

Un domaine peut : **publier ses faits** ; **consommer les faits déclarés** ; **lire par Query R-C** ; **être commandé** par les seuls commanditaires légitimes (liste close : une personne par les surfaces, un handler déclaré, un Process Manager déclaré, l'outillage du temps, une ACL de frontière). **Jamais** : l'appel direct d'un domaine par un autre (l'App→App interdit en costume de messagerie) ; l'attente synchrone d'un autre domaine ; la lecture d'intérieurs. **Quatre verbes — publier, consommer, lire, être commandé — et pas un cinquième.**

## 11. Sécurité — chaque couche vérifie ce qu'elle possède

**Domaine** : les refus, R-C. **Application** : l'identité injectée, l'identité d'acte — **l'anti-replay applicatif EST notre idempotence**. **Transport** : signature et checksum des enveloppes, chiffrement en transit, authentification mutuelle. **Infrastructure** : chiffrement au repos, secrets au vestibule. **Le gateway est borné à la session (F4.3.99)** : il vérifie l'identité de transport ; **le droit métier (R-C, refus) ne se juge qu'au dispatch et chez le propriétaire** — un droit jugé au gateway est un droit dupliqué qui divergera.

## 12–13. Observabilité & Crash Recovery

Du geste au dernier Signal : `CorrelationId` + `CausationId` dans les **enveloppes** → le journal des dix pas → les positions des PM → les livraisons et la Quarantaine → les Signals. Une exécution entière se relit par une seule clé. Crash recovery : neuf points rejoués (avant/après publish, avant/après ack, retry, replay, transport, intégration externe, **failover** — le curseur du relais est une position d'outillage reconstruisible) ; aucune perte, aucune duplication, l'ordre par sujet tenu.

## 14. Architectures concurrentes — détruites comme propriétaires

Kafka-First, RabbitMQ-First, MassTransit, NServiceBus, Axon, Mediator, ESB, SOA-orchestrée, Service Bus central, Microservices-Bus : **toutes meurent au même endroit** — chacune veut posséder un des cinq biens inaliénables (les faits, les abonnements, la déduplication, la sémantique des refus, le langage). **Aucune technologie ne peut devenir propriétaire de la Constitution ; toutes peuvent devenir ses tuyaux.**

## 15. Lois M-1 → M-10

- **M-1** Quatre familles de messages, jamais fusionnées ; chaque famille son contrat.
- **M-2** Le Bus est muet : tuyaux chez lui, vérités chez les propriétaires, abonnements chez les consommateurs.
- **M-3** L'enveloppe et le fait sont deux couches — corrélation, causalité, tentatives et clés opaques à l'enveloppe ; le fait ignore son transport, à jamais.
- **M-4** Toute publication naît d'une Outbox de propriétaire ; toute consommation passe une Inbox de consommateur ; l'effet unique est produit, jamais promis.
- **M-5** Les tables (porteurs, abonnements, routage) sont closes, déclarées, dérivées et vérifiées au boot — le routage est une projection.
- **M-6** L'ordre n'est promis que par sujet d'unité.
- **M-7** Les dialectes meurent aux ACL : traduction entrante en Commands, sortante en ordres — jamais en faits.
- **M-8** Les retries sont bornés ; au-delà : Quarantaine + Signal d'exploitation — rien ne meurt sans témoin ; le replay est un acte d'outillage journalisé, à cible nommée.
- **M-9** Chaque couche de sécurité vérifie ce qu'elle possède ; l'anti-replay applicatif est l'idempotence ; le gateway est borné à la session.
- **M-10** Quatre verbes entre domaines — publier, consommer, lire (R-C), être commandé (émetteurs en liste close) — et pas un cinquième.

## 16. Le versionnement des contrats — V-1 → V-6 (né de F4.3.99)

- **V-1** Le **propriétaire du fait possède son contrat et ses générations** ; les consommateurs n'en possèdent jamais un morceau.
- **V-2** L'évolution est **additive** (F3.1.5) : V2 = V1 + champs **optionnels**. Corollaire : **tout consommateur est un lecteur tolérant** — il ignore les champs inconnus ; celui qui casse sur un champ ajouté est fautif, pas la version.
- **V-3** **Supprimer ou renommer n'est pas une version : c'est un CONTRAT NOUVEAU** — révision Titre VII, nom nouveau ou génération majeure à identité propre.
- **V-4** La coexistence se fait par **traduction chez le retardataire, jamais par double publication** du propriétaire (publier le même fait sous deux formes = deux vérités) ; le consommateur non migré reçoit une **traduction de génération** (ACL de consommateur, temporaire, journalisée, à échéance).
- **V-5** La **mort d'une génération est DÉRIVABLE** : les consommateurs étant déclarés (listes closes boot-vérifiées), l'ensemble des dépendants est connu ; une génération meurt quand cet ensemble est vide — le dividende des tables closes.
- **V-6** Le retardataire jamais migré **ne bloque pas éternellement** : échéance de traduction épuisée → arbitrage Titre VII (migrer, assumer la traduction, ou débrancher) — jamais une casse silencieuse, jamais un otage perpétuel.

## 17. Anti-Patterns (9 fiches)

Event God · Bus intelligent · Event métier pollué (transport dans le fait) · Adapter bavard (l'adapter qui publie des faits) · Transport propriétaire · Queue métier (la file devenue état métier) · Retry infini · Replay destructeur (re-livrer sans Inbox) · Envelope contaminant le domaine (CausationId dans un fait).

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F4.3** (la Circulation, lois M-1→M-10) et **F4.3.99** (amendements intégrés : **Constitution du versionnement V-1→V-6** ; clés opaques d'enveloppe ; autorité de replay ; Quarantaine sans vérité ; gateway borné à la session ; Decision-réponse déclarée non-famille). **Portée du Grand Audit F4.99** (règles N°11, N°12) : F4.99 n'altère pas les lois M ni V ; il parcourt la chaîne entière sans la modifier et **nomme** l'Outbox du propriétaire « Outbox de faits » (distinction Outbox de faits / de commandes) — élément appartenant au chapitre de clôture (Lot 5C), non anticipé ici. Le terme « Messaging » demeure réservé aux Conversations (F2.1) ; les entrées de glossaire dues (Circulation, Enveloppe, `CausationId`, Quarantaine, Bus muet) relèvent du Titre VII. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
