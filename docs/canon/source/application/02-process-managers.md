---
doc: f4-02-process-managers
title: F4.2 — Process Managers & Long Running Processes (état final ratifié)
type: source
titre: application
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 5B)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 5B"
sources_session:
  - "F4.2 — Process Managers & Long Running Processes (définition, critère d'existence, machine à 4 terminaux, mémoire, Échéancier, compensation, lois P-1→P-10, 8 anti-patterns)"
  - "F4.2.99 — Process Managers Constitutional Audit (quatre amendements : P-2 précisé « faits du domaine » ; P-4 départagée tentatives parcours/livraison ; P-6 Échéancier = projection d'attentes ; P-8 compensation refusée → Abandoned + Signal)"
  - "F4.99 — Grand Application Audit (consulté : Séquence de Réaction englobe la réaction du PM sans l'altérer ; annote P-3 dérivée ; nomme l'outbox du PM « Outbox de commandes » — matérialisé au chapitre de clôture, Lot 5C)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F4.2, après les quatre
  amendements de F4.2.99. Ce chapitre possède la Constitution des Process
  Managers et les lois P-1→P-10. Le Grand Audit F4.99 n'altère pas ces lois : il
  ENGLOBE la réaction du PM dans la Séquence de Réaction (nouvelle structure,
  règle N°12), ANNOTE P-3 comme dérivée (règle N°11), et NOMME l'outbox du PM
  « Outbox de commandes » (distinction Outbox de faits / de commandes) — ces
  éléments appartiennent à F4.99 (chapitre de clôture, Lot 5C) et sont
  référencés, non anticipés. Scaffolding de session exclu. Titre VII pour toute
  évolution.
---

# F4.2 — Process Managers & Long Running Processes

> État **final ratifié** : F4.2 amendé des quatre articles de F4.2.99. Parcours
> canoniques : `ErasureProcess` (l'effacement transverse) et
> `NoShowSettlementProcess` (l'accord échu dont la rencontre ne s'ouvre jamais).

## 1. Le Process Manager — définition constitutionnelle

**Un Process Manager est la mémoire de position d'UN parcours nommé** : il consomme des faits, émet des Commands, et ne se souvient que d'où le parcours en est. **Il possède** : son identité de parcours (`ProcessId`), sa position, ses attentes nommées et leurs échéances, la chaîne de corrélation et les provenances du parcours. **Il ne possédera jamais** : une vérité (sinon il serait un domaine) ; un invariant ; un registre métier ; des décisions métier ; **des Domain Events (il n'en publie JAMAIS** — il commande, les propriétaires constatent) ; un appel direct d'Aggregate (JAMAIS — il passe par le Command Dispatch). **Il n'est pas** : un Aggregate (pas de vérité), un Application Service (il traverse les transactions et le temps), un Domain Service (aucun savoir métier), un Workflow Engine (un parcours chacun).

## 2. Quand il est AUTORISÉ — le critère (précisé par F4.2.99)

> **Un Process Manager existe si et seulement si un parcours exige une POSITION DE PARCOURS qui survive entre deux FAITS DU DOMAINE** *(précision F4.2.99 : « faits du domaine » — les tentatives de **livraison** sont la mémoire du transport, jamais un parcours ; seuls les faits du domaine ouvrent, déplacent ou ferment une position)*.

Le critère est **mécanique** : *comptez ce qu'il faut retenir entre deux faits du domaine — zéro : chorégraphie ; sinon : un PM nommé.* Corollaire anti-dérive : **la chorégraphie ne devient jamais implicitement une orchestration** — trois handlers coordonnés par effets de bord sont un PM clandestin.

## 3. Quand il est INTERDIT

Remplacer un Aggregate (une position qui refuse est une vérité déguisée) ; une Policy ; une Specification (un PM ne sait pas, il se souvient) ; une Projection (une position ne se lit que pour l'outillage) ; une transaction (un parcours n'est jamais atomique) ; une règle métier (la compensation qu'il émet est **déclarée** en Commands du dictionnaire).

## 4. Orchestration ou chorégraphie — le critère

**Chorégraphie par défaut** tant que la suite tient dans une réaction **sans mémoire**. **Orchestration dès qu'une position doit survivre** (effacement : N domaines à commander, accusés à joindre ; no-show : échéance + jonction). Le critère est mécanique, pas esthétique.

## 5. Cycle de vie — quatre terminaux

**Machine officielle** : **`Active` → `Completed` | `Compensated` | `Cancelled` | `Abandoned`** — quatre terminaux (achevé ; défait vers l'avant ; annulé par une personne ; renoncé par politique après épuisement), R-B applicable (re-tenter = nouveau parcours à provenance citée). `Started/Running` fusionnés en `Active` ; `Waiting/Sleeping/TimedOut/Failed/Paused` morts (l'attente est une donnée ; `Paused` est un acte d'exploitation sur une définition, jamais une position). Toute transition journalisée avec sa cause.

## 6. Mémoire — la règle (départagée par F4.2.99)

**Autorisé** : `ProcessId`, chaîne de corrélation, position courante, attentes nommées + échéances, identifiants et provenances du parcours, **tentatives de parcours** (« trois compensations refusées puis abandon », bornées par une Policy publiée — c'est de la position). **Interdit** : toute vérité ou copie métier (re-demandée aux sources, loi 15), toute projection, tout cache, et **les tentatives de livraison** *(départage F4.2.99 : les tentatives de livraison sont de l'enveloppe, jamais une position)*. **Le test du pardon** : *si la perte de cette mémoire exigeait de demander pardon à un domaine, c'était une vérité — elle était volée.*

## 7. Le temps — l'Échéancier (requalifié par F4.2.99)

Les durées sont des **paramètres de configuration produit** (Policies de parcours). **L'Échéancier** — outillage d'exécution auprès duquel le PM enregistre `(ProcessId, attente, instant)` et qui, l'instant venu, **émet la commande de réveil portant l'instant en donnée**. **Requalification F4.2.99 : l'Échéancier est une PROJECTION D'ATTENTES** — son registre est **intégralement reconstruisible** depuis les positions des PM et les échéances en attente des unités ; il ne possède aucune échéance, il les *sert* ; perdu, il se ré-hydrate. Personne ne « constate un timeout » : le PM réveillé **interroge les sources** et transitionne ; zéro horloge lue.

## 8. Compensation — vers l'avant (complétée par F4.2.99)

Rollback distribué, 2PC, undo, delete/update : tous morts (lois 14/17). **Mentora compense toujours vers l'avant** : la compensation est une **suite de Commands du dictionnaire**, **déclarée d'avance** dans la définition du parcours, exécutée par la Séquence normale, refusable. **Complétion F4.2.99** : *une compensation refusée se réessaie dans les bornes d'une Policy de parcours ; les bornes épuisées, le parcours passe à `Abandoned` et émet un **Signal d'exploitation** (via la Notification, à l'opérateur) — jamais un forçage, jamais un silence.* L'abandon alerté est la fin constitutionnelle de toute escalade.

## 9. Crash recovery

**Le mécanisme unique** : la réaction d'un PM est atomique — *(fait consommé via Inbox) + (position mise à jour + Commands émises dans son outbox)* en une écriture ; les relais portent ensuite. *(F4.99 nomme cet outbox « Outbox de commandes » — distinction de langue, ch. de clôture, Lot 5C.)* Les crashs (après commande émise → relais reprend ; avant enregistrement → re-livraison déterministe ; après publication → identité d'acte déduplique ; avant compensation → position « due », ré-émission idempotente ; pendant attente → Échéancier re-réveille). **La reprise ne re-décide jamais — elle re-livre** ; tout ce qui re-livre est dédupliqué (les trois étages de F4.1).

## 10. Plusieurs Process Managers

**Jamais** : communication directe, état partagé, appel mutuel, réveil mutuel, remplacement à chaud. **Toujours** : un parcours = une définition = des instances par sujet (`ProcessId` = identité du sujet — singleton-par-sujet) ; deux parcours s'influencent **uniquement par les faits du domaine**.

## 11. Événements — l'abonnement fermé

Un PM écoute **une liste close de faits nommés, déclarée dans sa définition, vérifiée au démarrage** (fail closed au boot). **Jamais tout le bus** — un écouteur universel est un God Saga en incubation. Tout le reste est structurellement ignoré — jamais reçu.

## 12–13. Observabilité & Testabilité

Observabilité : le journal de position (chaque transition, sa cause, son instant fourni), la chaîne de corrélation (l'enveloppe, jamais le fait), les métriques d'âge (instances actives, âge, attentes échues non traitées — LA métrique de santé). Testabilité : un PM est **une fonction pure de réaction** `(position, fait, instant, policies) → (position′, commandes)` — testée en valeurs, sans infrastructure ; le déterminisme EST le test de reprise.

## 14. Architectures concurrentes — détruites

God Saga · Workflow Engine · Orchestrateur métier · State Machine Framework (si le DSL cache la liste close) · Cron distribué · Event Handler géant (le PM clandestin) · Process partagé · Process central — **toutes détruites**. Les produits du marché (Temporal, Camunda, Conductor, sagas…) peuvent vivre comme **mécanismes derrière les ports** si les propriétés gelées restent lisibles chez nous : *la Constitution ne se délègue jamais ; elle s'outille.*

## 15. Lois d'exécution P-1 → P-10

- **P-1** Un parcours = une définition nommée = des instances par sujet ; un PM ne possède que sa position.
- **P-2** Il existe si et seulement si une position doit survivre entre deux **faits du domaine** ; sinon, chorégraphie.
- **P-3** Il ne publie jamais un fait ; il commande par le Dispatch, et les propriétaires constatent. *(F4.99 l'annote **dérivée** de F3.1.5 — annotation, ch. de clôture, Lot 5C.)*
- **P-4** Sa mémoire est perdable sans pardon : identifiants, position, attentes, corrélation, **tentatives de parcours** — jamais une vérité, jamais les tentatives de livraison.
- **P-5** Ses abonnements sont une liste close, déclarée, vérifiée au démarrage.
- **P-6** Ses durées sont des paramètres publiés ; ses réveils portent l'instant ; il ne lit jamais l'horloge ; **l'Échéancier est une projection d'attentes, jamais propriétaire d'une échéance**.
- **P-7** Sa réaction est atomique (Inbox + position + outbox) et déterministe — la reprise re-livre, ne re-décide pas.
- **P-8** Ses compensations sont déclarées d'avance, en Commands du dictionnaire, refusables ; toujours vers l'avant ; **une compensation refusée → bornes de Policy → `Abandoned` + Signal d'exploitation** ; jamais un forçage, jamais un silence.
- **P-9** Quatre terminaux (`Completed`, `Compensated`, `Cancelled`, `Abandoned`) ; R-B pour re-tenter ; toute transition journalisée avec sa cause.
- **P-10** Deux parcours ne se parlent jamais — ils s'entendent par les faits du domaine.

## 16–17. Checklists & Anti-Patterns

**Checklists** : nouveau Process Manager (test P-2 démontré ; définition : faits écoutés, positions, transitions, compensations, durées-paramètres ; mémoire P-4 ; quatre terminaux) ; nouveau timeout ; nouvelle compensation ; nouvelle reprise (aucune — P-7 générique) ; nouveau réveil ; nouvelle orchestration. **Anti-Patterns (8 fiches)** : God Saga · Workflow omniscient · Rollback distribué · le PM qui décide · le PM qui possède une vérité · l'état partagé · le timeout caché · le PM qui appelle un PM.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F4.2** (Process Managers, lois P-1→P-10) et **F4.2.99** (quatre amendements intégrés : P-2 précisé « faits du domaine » ; P-4 départagée tentatives parcours/livraison ; P-6 Échéancier = projection d'attentes reconstruisible ; P-8 compensation refusée → `Abandoned` + Signal d'exploitation). **Portée du Grand Audit F4.99** (règles N°11, N°12) : F4.99 n'altère pas les lois P ; il **englobe** la réaction du PM dans la **Séquence de Réaction** (nouvelle structure), **annote** P-3 comme dérivée de F3.1.5, et **nomme** l'outbox du PM « Outbox de commandes » (distinction Outbox de faits / de commandes) — ces éléments appartiennent au chapitre de clôture (Lot 5C) et n'y sont pas anticipés. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
