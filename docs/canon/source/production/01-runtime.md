---
doc: f5-01-runtime
title: F5.1 — Production Runtime & Deployment (état final ratifié)
type: source
titre: production
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 6A)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 6A"
sources_session:
  - "F5.1 — Production Runtime & Deployment Architecture (Runtime gardien de l'exécutabilité, six espèces d'exécutables, machine à neuf états, déploiement/rollback, lois R-1→R-10, 7 anti-patterns)"
  - "F5.1.99 — Production Runtime Constitutional Audit (cinq amendements : la Flotte ; la table des identités ExecutableId→ArtifactId→InstanceId ; la preuve d'artefact au Boot ; le lease optimisation-jamais-gardien ; les restes de crash = déchets)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F5.1, après les cinq
  amendements de F5.1.99. Ce chapitre possède la Constitution du Runtime de
  Production et les lois R-1→R-10. Règle N°17 : F5 possède la vision Production ;
  aucun chapitre antérieur n'en absorbe une responsabilité. Règle N°18 : le Grand
  Audit F5.99 (Lot 6E) vérifie et prouve — il ne modifie jamais le Runtime ; ses
  propriétés émergentes sont sa propriété exclusive (N°19). Scaffolding de
  session exclu. Titre VII pour toute évolution.
---

# F5.1 — Production Runtime & Deployment

> État **final ratifié** : F5.1 amendé des cinq articles de F5.1.99.

## §1–2. Runtime et Exécutable

**Le Runtime est le gardien de l'exécutabilité** : il ne possède ni vérité, ni décision, ni position, ni règle (héritage mécanique — les vérités ont leurs registres F3, les Decisions leurs unités, les positions leurs PM, et le Runtime n'a de type pour aucun). **L'Exécutable est une unité autonome** : son Root, son cycle, ses ressources, son identité — conséquence de F4.4.99 §1 (un Root **par exécutable**) + I-11. **Deux exécutables coopèrent par la vérité constitutionnelle** (faits publiés, registres) — jamais par mémoire, jamais par appel privé (P-10 étendu du parcours à la machine).

## §3. Les six espèces d'exécutables

Des **missions, pas des lois** : *Application* (sert les trois Séquences aux personnes), *Relay* (porte les Outbox de faits et de commandes vers le Bus), *Scheduler* (l'Échéancier), *Worker* (Réactions et Séquences hors du chemin des personnes), *Migration* (expand-contract, sous change-control — **ne touche jamais le sens**), *Maintenance* (police et reprises — **pas de quatrième chemin**). L'exécutable « mixte » est mort comme obligation (deux missions, deux cycles de drainage), toléré en développement local.

## §4–9. Cycle de vie, Boot, Readiness, Liveness, Warmup, Drainage

**La machine à neuf états, fermée et sans retour** : *Construction → Configuration → Validation → Warmup → Ready → Active → Draining → Shutdown → Destroyed*. **Aucun retour** — une instance dégradée ne re-valide pas : elle meurt et une neuve naît (R-B appliquée aux machines). **Le Boot démontre, ne sert jamais** (liste close de F4.4 §7 + générations, projections, relais, Échéancier). **Readiness = « les trois Séquences sont exécutables ici »** (dérivée : Commande/Réaction/Lecture sont les seuls chemins). **Liveness ne juge jamais le métier** (un taux de refus n'est pas un signal de mort). **Warmup reconstruit, n'invente jamais** (la famille des projections d'outillage reconstruisibles). **Drainage** : possible **parce que** A-3 rend les Séquences courtes et P-7 les Réactions atomiques — *le drainage protège la Constitution, jamais la disponibilité : la disponibilité se rachète par des instances, jamais par des vérités.*

## §10–12. Déploiement et Rollback

**Remplacement mécanique** : binaire, Root, Runtime — rien d'autre (le domaine identique au bit près, I-9). **Six stratégies survivent comme mécanismes** (Blue/Green, Rolling, Canary, Recreate, Shadow, Serverless) parce que les propriétés qui les rendent sûres sont déjà gelées : coexistence par **V-2 + I-9** ; Shadow **ne commande jamais** (lecture/comparaison seulement) ; Serverless — un cold start est un Boot entier ou un mensonge. **Rollback** : logiciel, jamais historique (loi 17) ; borne — on ne revient jamais à un binaire dont la **génération de contrats** n'est plus compatible.

## §13–15. Multi-instance, Défaillances, Partage des rôles

**Multi-instance** : n instances, zéro partage technique, une seule chose commune — la vérité constitutionnelle ; la concurrence est **déjà résolue** par R-A + Inbox + transactions d'unité — le Runtime n'ajoute aucune coordination. **Défaillances** : crash, OOM, restart, pertes — **toutes des Failures, jamais des Decisions** ; le métier reste inchangé *parce qu'il n'a jamais su*. **Partage des rôles** : l'Infrastructure possède les mécanismes, le Root les assemble, le Runtime les orchestre, le domaine les ignore.

## §16. La Flotte (amendement F5.1.99)

> **La Flotte** est l'ensemble des instances d'un exécutable, gouvernée par des politiques techniques déclarées (compte désiré, placement, remplacement), **possédée par l'Exploitation**, exécutée par des mécanismes libres (orchestrateurs). Elle ne possède **aucune vérité** (son état-désiré est de la configuration technique reconstruisible) ; elle possède **un seul acte : le remplacement**.

Deux concepts, deux propriétaires : **l'Instance** vit sa machine à neuf états ; **la Flotte** décide combien vivent et où. Rolling, blue/green, canary, autoscaling, crash, failover, perte de zone : *des cadences du même acte unique — remplacer*, sous trois voix (verdict de Liveness, politique de Flotte, ordre d'Exploitation journalisé).

## §17. La table des identités (amendement F5.1.99)

> **`ExecutableId`** (la mission nommée, une des six espèces) → **`ArtifactId`** (l'artefact immuable de fabrication, **à provenance de source** — quel commit, quelle chaîne l'a produit) → **`InstanceId`** (l'occurrence vivante).

« Replica » est **banni** (synonyme nu d'instance — loi 10). La **provenance opérationnelle** (mission → artefact → instance → instant) rejoint les chaînes d'audit ; elle répond à la question décennale : *quel artefact exact tournait à cet instant ?*

## §18. Le Boot — la preuve d'artefact (amendement F5.1.99)

À la liste close du Boot s'ajoute **l'intégrité et la provenance de l'artefact** (signature, provenance de l'`ArtifactId`), **fail closed** — le trou de la chaîne d'approvisionnement fermé : les validations internes prouvaient que *ce binaire* est cohérent, jamais que c'est *le bon binaire*.

## §19. Le lease et les restes de crash (amendements F5.1.99)

- **Le lease** : un bail d'exclusivité technique (un relais leader) est **licite comme optimisation, jamais comme gardien** — *aucun invariant métier ne repose jamais sur un lease* ; en split-brain, les clés R-A, les Inbox et les transactions garantissent l'effet unique — le lease évite du travail en double, il n'empêche jamais une vérité en double (déjà impossible plus bas).
- **Les restes d'un crash** (fichiers temporaires, sockets) sont des **déchets, jamais des héritages** — collectés par le mécanisme du nœud, **jamais réutilisés** par une instance suivante (une instance qui reprendrait les ressources d'une morte ressusciterait un état — R-4 violée).

## §20. Lois R-1 → R-10

- **R-1** Le Runtime est le gardien de l'exécutabilité : il ne possède ni vérité, ni décision, ni position, ni règle — il possède des exécutables, leurs cycles, leurs ressources.
- **R-2** Un exécutable est une unité autonome : Root, cycle, ressources, identité — jamais partagés ; deux exécutables coopèrent par la vérité constitutionnelle.
- **R-3** Les espèces diffèrent par leur mission, jamais par leurs lois — Migration ne touche jamais le sens, Maintenance n'a pas de quatrième chemin.
- **R-4** Le cycle de vie est une machine fermée à neuf états, sans retour : une instance dégradée meurt et se remplace — jamais ne ressuscite.
- **R-5** Le Boot démontre et ne sert jamais ; une seule preuve manquante et il meurt (dont **la preuve d'artefact** — intégrité + provenance).
- **R-6** Readiness = aptitude aux trois Séquences ; Liveness = existence du processus ; ni l'une ni l'autre ne jugent le métier.
- **R-7** Le Warmup ne reconstruit que des projections d'outillage passant le test du pardon — il n'invente jamais.
- **R-8** Le drainage protège la Constitution, jamais la disponibilité : la disponibilité s'achète en instances, jamais en vérités.
- **R-9** Le déploiement remplace des binaires ; le rollback revient à un binaire **compatible en générations** — l'histoire, les faits et les positions continuent.
- **R-10** Toute défaillance de Runtime est une Failure — jamais une Decision, jamais un Refusal.

*(Propriétaires nés de l'audit : la **Flotte** — nombre, placement, remplacement ; la **table des identités** ExecutableId→ArtifactId→InstanceId.)*

## §21. Architectures concurrentes — détruites

Runtime distribué · Hot Reload métier · Shared Runtime · Runtime intelligent · Self-Healing métier · Framework propriétaire · Serverless-first · Kubernetes-first / Nomad / Docker / VM (topologies-mécanismes, mortes comme législateurs, libres comme outils) · Runtime magique · Service Mesh / Orchestrateur propriétaires — **toutes mortes comme autorité ; toutes peuvent servir**. Une seule survit : **le gardien muet de l'exécutabilité, à neuf états, sans intelligence.**

## §22. Anti-Patterns (7 fiches)

Le Runtime intelligent · le Hot Reload métier · le Shared Runtime · le Self-Healing métier · la résurrection d'instance · le drainage sacrifié · le manifeste législateur.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F5.1** (Production Runtime, lois R-1→R-10, machine à neuf états, six espèces) et **F5.1.99** (cinq amendements intégrés : **la Flotte** ; la **table des identités** ExecutableId→ArtifactId→InstanceId, « replica » banni ; la **preuve d'artefact au Boot** ; le **lease** optimisation-jamais-gardien ; les restes de crash = déchets jamais hérités). **Règle N°18** : le Grand Audit F5.99 (Lot 6E) vérifiera et prouvera sans modifier ce chapitre ; ses propriétés émergentes (identité de la flotte, résidence, etc.) sont sa **propriété exclusive** (N°19) et n'y sont pas anticipées. Entrées de glossaire dues au Titre VII : la Flotte, `ArtifactId`, la preuve d'artefact. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
