---
doc: canon-handbook-01
title: Handbook Officiel de Mentora — guide pratique d'application de la Constitution
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 3 (Handbook officiel)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 3"
source_autorite:
  - "F1 → F5 (docs/canon/source/) — la Constitution ; seule autorité"
  - "F2.5 — Dictionnaire ; F3.1 — blocs tactiques ; F4.1 — la Séquence ; F5.1→F5.8 — Production ; F5.99 — théorèmes"
public:
  - "développeurs, architectes, reviewers, QA, DevOps, Tech Leads, nouveaux membres"
note: >-
  PROJECTION de la Source (docs/canon/source/), jamais une source. Le Handbook
  répond à « comment appliquer correctement la Constitution ? », jamais à « quelle
  est la Constitution ? ». Il n'a aucun pouvoir éditorial (PG-5, PG-8 ; règle
  N°33) : il n'écrit aucune règle, aucune loi, aucun terme, aucun propriétaire,
  aucune décision, aucune architecture — il explique, guide, illustre, oriente. Il
  ne reformule jamais une règle : il renvoie à la Source. Toute règle citée l'est
  avec un lien vers son chapitre propriétaire ; en cas de doute, la Source tranche.
  Extraction exclusivement depuis la Source matérialisée (le transcript n'est plus
  une autorité). Évolution : Titre VII uniquement.
---

# Handbook Officiel de Mentora

> **Un guide, jamais une loi.** Ce Handbook explique **comment appliquer** la
> Constitution. Il ne la réécrit pas, ne la remplace pas, ne décide pas. *La seule
> autorité est [`source/`](../../source/).* En cas de divergence, la Source a
> raison et le Handbook est corrigé (PG-3).

## Comment se servir de ce guide

Chaque chapitre suit la même trame : **le but · quand l'utiliser · comment
l'utiliser · erreurs fréquentes · bonnes pratiques · références vers la Source.**
Aucune nouvelle règle n'y apparaît : chaque affirmation normative est un **renvoi**
à un chapitre de la Source. Si vous cherchez *ce que dit* la loi, ouvrez la
Source ; si vous cherchez *comment la tenir*, restez ici.

---

## Chapitre A — Comprendre la Constitution

**But.** Situer les cinq Titres et leur rôle, sans les réécrire.

**Comment.** La Constitution se lit **du général au particulier** — chaque Titre
présuppose le précédent (l'ordre est *logique*, jamais éditorial —
[F5.99 Procès XII](../../source/production/09-grand-audit.md)) :

| Titre | Rôle (ce qu'il répond) | Où |
|-------|------------------------|----|
| **F1 — Foundation** | la fondation technique gelée (tokens, registry, composition, layout ; graphe d'imports DAG) | [foundation/](../../source/foundation/01-foundation-constitution.md) |
| **F2 — Constitution stratégique** | *qui possède quoi, qui peut dire NON* — 15 domaines, la carte de contexte, le langage, les 18 lois | [constitution/](../../source/constitution/) |
| **F3 — Domaine tactique** | *comment un NON tient debout à l'exécution* — 30 aggregates, les blocs, R-A/R-B/R-C | [domain/](../../source/domain/) |
| **F4 — Exécution** | *comment l'idée devient acte* — les trois Séquences, les Process, la Circulation, lois A/P/M/V/I | [application/](../../source/application/) |
| **F5 — Production** | *comment les autorités survivent aux pannes* — Runtime→Gouvernance, lois R/S/O/T/RY/SC/OP/PG | [production/](../../source/production/) |

**Les Grands Audits (`.99`)** ne portent aucune loi : ils **prouvent** la
cohérence (le [Grand Audit F5.99](../../source/production/09-grand-audit.md) clôt
F1→F5 comme une seule Constitution).

**Erreurs fréquentes.** Lire F3 avant F2 (on cherche le *comment* avant le *qui*) ;
croire qu'un Titre postérieur peut amender un antérieur (seul le **Titre VII** le
peut).

**Bonne pratique.** Toujours partir du **propriétaire** : *qui a le droit de dire
NON ?* ([F2.1](../../source/constitution/01-domain-landscape.md),
[F5.99 Procès VII](../../source/production/09-grand-audit.md)).

---

## Chapitre B — Comment lire le Corpus

**But.** Trouver vite la bonne pièce.

**Où se trouve quoi :**

| Vous cherchez… | Ouvrez… |
|---|---|
| **les lois stratégiques** (P1–P18) | [F2.6/F2.9](../../source/constitution/06-architecture-constitution.md) |
| **les lois tactiques** (R-A, R-B, R-C) | [F3.3 §10](../../source/domain/06-tactical-documentation-freeze.md) |
| **les lois d'exécution** (A, P, M, V, I) | [F4.1](../../source/application/01-application-core-sequence.md) → [F4.99](../../source/application/05-grand-application-audit.md) |
| **les lois de production** (R, S, O, T, RY, SC, OP, PG) | [F5.1](../../source/production/01-runtime.md) → [F5.8](../../source/production/08-governance.md) |
| **les théorèmes** | [F5.99 §3](../../source/production/09-grand-audit.md) |
| **les événements, commandes, requêtes, projections, policies** | [F2.5 §4–§6](../../source/constitution/04-bilingual-dictionary.md) ; [F3.2](../../source/domain/02-aggregates-customer-journey.md) |
| **le vocabulaire officiel** | [Glossaire](../glossary/01-official-glossary.md) ; [Vocabulary Diff](../glossary/02-vocabulary-diff.md) |
| **les énumérations exhaustives** (catalogues) | *Catalogues (Lot 4, à venir)* |

**L'épine du Corpus** : *Structure → Source → Vérification → Projection →
Publication*. La **Source** fait foi ; tout le reste (Glossaire, Handbook,
Catalogues) en **dérive** et ne peut jamais la contredire
([PG-2/PG-3](../../source/production/08-governance.md)).

**Erreur fréquente.** Citer un total écrit à la main : *le catalogue fait foi,
jamais le chiffre* ([F3.3.99](../../source/domain/06-tactical-documentation-freeze.md)).

---

## Chapitre C — Cycle de développement

**But.** Situer un travail dans la chaîne constitutionnelle.

**Le cycle recommandé** (chaque étape s'appuie sur le Titre correspondant) :

```
Idée → Architecture → Domain → Application → Infrastructure → Production → Projection → Publication
```

| Étape | Ce qu'on y fait | Titre de référence |
|---|---|---|
| **Idée** | poser le besoin en termes de vérité et de propriétaire | [F2.1](../../source/constitution/01-domain-landscape.md) |
| **Architecture** | placer la vérité sur la carte, vérifier les dépendances | [F2.2](../../source/constitution/02-context-map.md) |
| **Domain** | modéliser l'unité, l'invariant, la clé R-A | [F3.1](../../source/domain/01-tactical-building-blocks.md) |
| **Application** | exécuter par la Séquence, les Process, la Circulation | [F4.1](../../source/application/01-application-core-sequence.md) |
| **Infrastructure** | brancher les ports et adapters, la composition root | [F4.4](../../source/application/04-infrastructure-composition-runtime.md) |
| **Production** | déployer, persister, observer, sécuriser, fiabiliser | [F5.1](../../source/production/01-runtime.md)→[F5.8](../../source/production/08-governance.md) |
| **Projection** | régénérer Glossaire, Catalogues, Handbook depuis la Source | [F5.8](../../source/production/08-governance.md) |
| **Publication** | publier après ratification (jamais l'inverse) | [PG-15](../../source/production/08-governance.md) |

**Bonne pratique.** *On ne saute jamais une étape* : le Boot le prouve pour la
machine ([R-5](../../source/production/01-runtime.md)), la Séquence pour l'acte
([A-2](../../source/application/01-application-core-sequence.md)).

---

## Chapitre D — Workflow quotidien (développer une fonctionnalité)

**But.** Ajouter une capacité sans violer une loi.

**Comment** (toujours en renvoyant à la Source) :

1. **Identifier le domaine** — un seul propriétaire de la vérité visée ([F2.2](../../source/constitution/02-context-map.md)).
2. **Lire les invariants** — ce qui doit rester vrai à chaque instant ([F2.6](../../source/constitution/05-rules-invariants-failure-modes.md)).
3. **Lire les responsabilités** — ce que le domaine fait / ne fait jamais ([F2.3](../../source/constitution/03-language-responsibilities-contracts.md)).
4. **Lire les contrats** — événements, commandes, requêtes publiés ([F2.5](../../source/constitution/04-bilingual-dictionary.md)).
5. **Créer le modèle** — l'Aggregate (unité minimale qui rend l'invariant vrai), Entities, VO, Factory si la naissance établit des invariants ([F3.1](../../source/domain/01-tactical-building-blocks.md)).
6. **Créer les tests** — l'unité sans doublure ; le cas d'usage par conformité à la Séquence ([F4.1 §10](../../source/application/01-application-core-sequence.md)).
7. **Vérifier les lois** — la Command traverse **exactement les dix pas** de la Séquence de Commande, dans l'ordre ([A-2](../../source/application/01-application-core-sequence.md)).
8. **Mettre à jour les projections** — Read Models, Glossaire, Catalogues régénérés depuis la Source ([S-4](../../source/production/02-persistence.md), [PG-6](../../source/production/08-governance.md)).

**Erreurs fréquentes.** Inventer un mot hors du Dictionnaire ; charger par
recherche métier au lieu de l'Identifier (R-A) ; publier avant de retenir
([A-4](../../source/application/01-application-core-sequence.md)).

**Bonne pratique.** *Un cas d'usage = une Command = un Application Service = une
unité = une transaction* ([A-1](../../source/application/01-application-core-sequence.md)).

---

## Chapitre E — Workflow Review

**But.** Refuser ce qui viole la Constitution, avec une checklist opposable.

**Checklist Review** (chaque case renvoie à la Source) :

- ✓ **Loi respectée ?** — la Séquence, les lois A/P/M/V/I ([F4.1](../../source/application/01-application-core-sequence.md)) ; les lois du Titre concerné.
- ✓ **Propriétaire respecté ?** — la vérité n'est écrite que par son unique propriétaire ([P1](../../source/constitution/06-architecture-constitution.md)).
- ✓ **Vocabulaire officiel ?** — aucun mot hors Glossaire, aucun terme réservé détourné ([Glossaire](../glossary/01-official-glossary.md), [Vocabulary Diff](../glossary/02-vocabulary-diff.md)).
- ✓ **Invariant cassé ?** — gardé à la source, sans porte ([F3.1](../../source/domain/01-tactical-building-blocks.md)).
- ✓ **Nouveau terme ?** — interdit hors Titre VII ; sinon dette lexicale ([PG-9](../../source/production/08-governance.md)).
- ✓ **Duplication ?** — une vérité écrite en deux lieux : l'un des deux devient une vue ([P1](../../source/constitution/06-architecture-constitution.md)).
- ✓ **Projection impactée ?** — toute projection reste reconstructible depuis la Source ([S-4](../../source/production/02-persistence.md)).

**Bonne pratique.** S'appuyer sur les **checklists de PR** déjà écrites dans la
Source ([F4.1 §12](../../source/application/01-application-core-sequence.md),
[F3.3 §11](../../source/domain/06-tactical-documentation-freeze.md)) — *la loi
rendue vérifiable*.

---

## Chapitre F — Workflow Architecture

**But.** Ajouter un bloc sans créer de règle.

**Comment** (les définitions appartiennent à [F3.1](../../source/domain/01-tactical-building-blocks.md)) :

- **Un Aggregate** — quand une vérité a un NON propre. Frontière = la **plus
  petite** qui rende l'invariant vrai ; référence les autres par Identifier seul ;
  une unité = une transaction. *Erreur : le God Aggregate (deux NON, une
  frontière) ; l'anémique (invariant gardé par personne).*
- **Une Policy** — quand une règle est **publiée d'avance** avec des paramètres du
  produit ; elle rend une **Decision motivée**, ses paramètres sont de la
  configuration. *Une Policy consulte des Specifications, jamais l'inverse.*
- **Une Projection** — dérivation déterministe de faits, **recalculable**, jamais
  persistée comme vérité, jamais source d'un refus d'acte ([P3](../../source/constitution/06-architecture-constitution.md)).
- **Un Process Manager** — quand il faut **retenir quelque chose entre deux faits**
  du domaine (sinon : chorégraphie). Il ne possède aucune vérité ; sa mémoire est
  sa position ([F4.2](../../source/application/02-process-managers.md)). *Erreur :
  la chorégraphie qui devient une orchestration clandestine.*
- **Un Adapter** — l'implémentation d'un **Port possédé par le domaine** ; il vit
  **derrière** le port, référencé par la seule composition root ; les types du
  dehors meurent à l'Adapter ([F4.4](../../source/application/04-infrastructure-composition-runtime.md)).

**Bonne pratique.** Nommer selon la **Naming Constitution** ([F3.1](../../source/domain/01-tactical-building-blocks.md),
[F2.5 §9](../../source/constitution/04-bilingual-dictionary.md)) : jamais
`-Manager`/`-Helper`/`-Util`/`-Service` nu.

---

## Chapitre G — Workflow Production

**But.** Appliquer les huit chapitres de Production comme un guide (jamais comme
une source seconde).

| Domaine | Le réflexe | Référence |
|---|---|---|
| **Runtime** | une instance dégradée **meurt et se remplace** ; jamais ne ressuscite | [R-4](../../source/production/01-runtime.md) |
| **Persistence** | tout dérivé est reconstructible ou meurt ; la validité se lit à la source | [S-4/S-5](../../source/production/02-persistence.md) |
| **Observability** | l'observabilité lit tout, ne possède rien, n'écrit nulle part | [O-1](../../source/production/03-observability.md) |
| **Security** | la sécurité **ferme une porte**, ne juge jamais un acte | [T-1](../../source/production/04-security.md) |
| **Reliability** | **Fiabilité > Disponibilité** : plutôt refuser que mentir | [RY-3](../../source/production/05-reliability.md) |
| **Scalability** | multiplier les mécanismes, jamais diviser une vérité | [SC-1](../../source/production/06-scalability.md) |
| **Operations** | une opération **exécute**, elle ne crée aucune vérité | [OP (F5.7)](../../source/production/07-operations.md) |
| **Governance** | la documentation **projette**, elle ne fonde jamais | [PG-2](../../source/production/08-governance.md) |

**Erreur fréquente.** Servir une projection périmée **sans le dire** (un fail-open
déguisé) — interdit ([RY-4](../../source/production/05-reliability.md)).

---

## Chapitre H — Questions fréquentes

- **Puis-je créer un nouveau terme ?** → **Non** — le Glossaire rassemble, il
  n'invente pas ; un mot nouveau naît dans une Constitution, par Titre VII
  ([PG-8/PG-9](../../source/production/08-governance.md)).
- **Puis-je modifier une loi ?** → **Seulement via le Titre VII** (sur
  démonstration supérieure — [F5.99 §6](../../source/production/09-grand-audit.md)).
- **Puis-je ajouter une projection ?** → **Oui** — si elle est reconstructible
  depuis la Source et jamais consultée comme vérité ([S-4](../../source/production/02-persistence.md)).
- **Puis-je modifier une projection ?** → **Oui, si la Source change** (la
  projection **suit** la Source ; une divergence est un défaut de la projection,
  jamais de la Source — [PG-3](../../source/production/08-governance.md)).
- **Puis-je faire un rollback après publication d'un fait ?** → **Non** — on
  compense vers l'avant ([loi 17](../../source/constitution/05-rules-invariants-failure-modes.md), [A-4](../../source/application/01-application-core-sequence.md)).
- **Un dashboard peut-il décider ?** → **Non** — il disparaît sans que le métier
  bouge ([O-8](../../source/production/03-observability.md)).
- **Une opération peut-elle rembourser / fermer un compte ?** → **Non** — ces
  actes appartiennent à leurs domaines ([F5.7](../../source/production/07-operations.md)).

---

## Chapitre I — Anti-patterns (rassemblés, jamais inventés)

Le Handbook **rassemble** les anti-patterns déjà écrits dans la Source et explique
**pourquoi ils existent** ; il n'en crée aucun. Tous meurent au même test : *qui
protège l'invariant, qui détient le NON, qui a constaté ?*

| Couche | Anti-patterns (source) | Pourquoi ils tuent |
|---|---|---|
| **Tactique** (15) | Aggregate anémique · God Aggregate · Entity intelligente · VO mutable · Repository métier · Projection persistée comme vérité · Cache de validité … ([F3.1 §Anti-Patterns](../../source/domain/01-tactical-building-blocks.md)) | un NON gardé par personne, ou une vérité écrite par tous |
| **Applicative** (8) | l'endpoint intelligent · le service bavard (App→App) · la rétention qui parle · la publication fantôme · l'identité ambiante · la Séquence permutée … ([F4.1 §Anti-Patterns](../../source/application/01-application-core-sequence.md)) | l'orchestrateur qui se met à décider |
| **Runtime** (7) | le Runtime intelligent · le Self-Healing métier · la résurrection d'instance · le manifeste législateur … ([F5.1 §22](../../source/production/01-runtime.md)) | un mécanisme qui prétend posséder |
| **Persistence** (8) | la base-intégration · le cache-vérité · la migration-qui-corrige · le réplica-menteur · l'UPDATE-effaceur … ([F5.2 §12](../../source/production/02-persistence.md)) | le stockage qui se croit propriétaire |
| **Observability** (8) | le dashboard-décideur · l'alerte-législatrice · la trace-preuve · l'AIOps-propriétaire … ([F5.3 §12](../../source/production/03-observability.md)) | l'observation qui gouverne |
| **Security** | la muraille · l'identité-permission · le certificat-identité · l'IdP-juge · la machine-personne … ([F5.4 §Anti-Patterns](../../source/production/04-security.md)) | la garde qui devient propriétaire |
| **Reliability** (8) | Availability First · Timeout métier · Consensus propriétaire · Split Brain accepté … ([F5.5 §12](../../source/production/05-reliability.md)) | la disponibilité qui prime la vérité |
| **Scalability** (8+) | le tenant-propriétaire · l'active-active de vérité · le fairness-métier · la cellule-propriétaire … ([F5.6 §7](../../source/production/06-scalability.md)) | la croissance qui déplace une vérité |

---

## Chapitre J — Checklists (référençant la Source)

**Développement** — □ un domaine, un propriétaire □ invariants lus □
responsabilités lues □ contrats lus □ unité minimale (R-A) □ tests unité +
conformité Séquence □ dix pas dans l'ordre □ projections régénérées.
*([F3.3 §11](../../source/domain/06-tactical-documentation-freeze.md), [F4.1 §12](../../source/application/01-application-core-sequence.md)).*

**Review** — □ loi □ propriétaire □ vocabulaire officiel □ invariant □ terme
nouveau (interdit) □ duplication □ projection impactée. *(Chapitre E.)*

**Architecture** — □ frontière minimale □ un NON par unité □ Policy publiée d'avance
□ projection recalculable □ PM seulement si mémoire entre faits □ Adapter derrière
le port □ Naming Constitution. *([F3.1](../../source/domain/01-tactical-building-blocks.md)).*

**Production** — □ instance qui meurt-et-se-remplace □ dérivé reconstructible □
observabilité sans écriture □ sécurité qui ferme une porte □ Fiabilité >
Disponibilité □ vérité à résidence unique □ opération sans vérité □ dette visible.
*([F5.1](../../source/production/01-runtime.md)→[F5.8](../../source/production/08-governance.md)).*

**Publication** — □ ratification **avant** publication □ Constitutional Diff nul □
Vocabulary Diff nul □ signé □ dettes inscrites. *([PG-15/PG-16](../../source/production/08-governance.md)).*

---

## Important — la nature du Handbook

Le Handbook **explique, guide, illustre, oriente — mais ne décide jamais.** Il n'a
aucun pouvoir éditorial (GOVERNANCE #6, règle N°33 : *une démonstration/projection
n'est jamais une autorité*). Toute règle vit dans la **Source** ; le Handbook n'en
est que le mode d'emploi. Une divergence Handbook ↔ Source est **toujours** un
défaut du Handbook (PG-3), corrigé par régénération.

---

## Provenance de projection (non normatif)

Projection de la **Source matérialisée** (F1 → F5, `docs/canon/source/`), jamais du
transcript (règle N°31 ; le transcript n'est plus une autorité). Le Handbook
répond exclusivement à *« comment appliquer la Constitution ? »* — il **ne
reformule aucune règle**, ne crée **aucune** loi, terme, propriétaire, décision ou
architecture ; chaque affirmation renvoie à son chapitre propriétaire par lien.
Les **anti-patterns** (Chapitre I) sont **rassemblés** des chapitres de la Source
([F3.1](../../source/domain/01-tactical-building-blocks.md),
[F4.1](../../source/application/01-application-core-sequence.md),
[F5.1](../../source/production/01-runtime.md)→[F5.6](../../source/production/06-scalability.md)),
jamais inventés. Les **énumérations exhaustives** (événements, commandes, lois,
identités, anti-patterns complets) relèvent des **Catalogues (Lot 4)** ; le
vocabulaire, du [Glossaire](../glossary/01-official-glossary.md) et du
[Vocabulary Diff](../glossary/02-vocabulary-diff.md). Ce document projette la
Source ; il ne la modifie jamais (PG-5, PG-8). Évolution : **Titre VII**.
