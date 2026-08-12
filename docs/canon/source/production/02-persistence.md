---
doc: f5-02-persistence
title: F5.2 — Persistence & Data Storage (état final ratifié)
type: source
titre: production
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 6A)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 6A"
sources_session:
  - "F5.2 — Persistence Architecture & Data Storage Constitution (Registre/Dépôt/moteur, Repository Ports, transactions, dérivés, sauvegardes/PITR, migrations, performance, sécurité des données, effacement légal, la Fiche de Registre, lois S-1→S-10, 8 anti-patterns)"
  - "F5.2.99 — Persistence Constitutional Audit (quatre amendements : Fiche de Registre à deux parties/deux propriétaires ; Readmitted 3e police du registre ; trois réservations de vocabulaire — Snapshot/Journal/Export ; reconstruction Snapshot+delta, partition max(unité, portée R-A))"
note: >-
  Reconstruction fidèle de l'état final ratifié de F5.2, après les quatre
  amendements de F5.2.99. Ce chapitre possède la Constitution de la Persistance
  et les lois S-1→S-10. Principe : la Persistance conserve la vérité, elle ne la
  possède jamais. Règle N°18 : le Grand Audit F5.99 (Lot 6E) vérifie sans
  modifier ; ses propriétés émergentes sont sa propriété exclusive. Les
  réservations de vocabulaire (Snapshot/Journal/Export) relèvent du Dictionnaire
  (F2.5) par Titre VII. Scaffolding de session exclu.
---

# F5.2 — Persistence & Data Storage

> État **final ratifié** : F5.2 amendé des quatre articles de F5.2.99.
> **Principe** : *la Persistance conserve la vérité ; elle ne la possède jamais.*

## §1. La nature de la Persistance

Le **Registre** est la mémoire contractuelle d'une vérité (le côté-contrat du Repository Port, possédé par le domaine — un registre par vérité, trente registres, chacun connaissant ses unités, ses clés R-A, sa rétention). Le **Dépôt** reste ce que F3 a gelé (l'unité de Storage — la garde de matière) : **le Registre garde des vérités, le Dépôt garde de la matière.** Le **moteur de stockage** est un mécanisme sous l'adapter. **La base de données ne possède jamais la vérité** (le test du NON : une base ne peut rien refuser pour des raisons de sens ; ce qui ne peut pas refuser ne possède pas).

## §2. Les Repository Ports

*DAO* mort comme concept de domaine ; *ORM* = **un outil de traduction, jamais un modèle** (l'ORM qui annote les objets du domaine est la contamination I-7 ; son dialecte — lazy-loading, sessions, proxies — meurt à la frontière ; une unité chargée est **entière** ou n'est pas) ; *Active Record* mort ; *Data Mapper* = le motif légitime de l'adapter (sous le port) ; *Unit of Work* = déjà possédée (le pas 8 de la Séquence, A-3) ; *Identity Map* légale **dans** une transaction, illégale au-delà (cache de validité, Titre VI). **Les dialectes meurent à l'adapter, tous ; le port ne parle que le dictionnaire.**

## §3. Les moteurs de stockage

Relationnels, documents, colonnes, clés-valeurs, graphes, recherche, objets : **tous des mécanismes remplaçables derrière les ports**. **Le polyglotte est libre par registre** (chaque registre choisit son moteur via sa Fiche, selon ses besoins — configuration technique révisable au Root). Deux interdits : un moteur ne sert jamais **deux domaines par le même schéma** ; un moteur de recherche n'est jamais un registre.

## §4. Les transactions (ACID rapporté à la Constitution)

**Atomicité** au service de la rétention (état + faits, une écriture). **Isolation** au service des clés R-A et de la lecture-de-ses-écritures (sérialisable-suffisant pour que deux rétentions concurrentes ne violent jamais une clé). **Cohérence** = clés + types du registre, jamais une règle métier. **Durabilité** = la promesse de la mémoire. Un conflit optimiste (deux Séquences, une version) est une **Failure transitoire, jamais une Decision**. Aucune transaction ne devient propriétaire d'un invariant. *(A-1 coïncide avec le NON : une transaction plus large protégerait ce que personne ne possède.)*

## §5. Projections, index, moteurs de recherche — le test du pardon

**Index** dérivés reconstruisibles → vivent. **Vues matérialisées** = projections persistées, vivent **si** recalculables et jamais consultées comme vérité. **Caches persistants** = projections datées, dites périmées (P17), jamais de validité. **Moteurs de recherche** = **projections externes derrière l'ACL** (reconstruites depuis les faits publiés, périssables, ré-hydratées par replay outillé). **Présomption (amendement F5.2.99)** : *un dérivé sans chemin de reconstruction écrit est présumé propriétaire — donc illégal.*

## §6. Sauvegardes, restauration, désastre

**Qui possède l'histoire : les registres.** L'**Image de sauvegarde** *(vocabulaire réservé — amendement F5.2.99 ; « Snapshot » réservé à la voix tactique F3.1.11)* est une copie de mémoire (chiffrée, rétention bornée) ; la réplication un mécanisme de RPO/RTO. **La validité se lit au registre primaire** — un réplica en retard qui répond à `ConsentValidityQuery` est un cache de validité déguisé (interdit).

**La perte de queue — la Perte Déclarée** : *(1)* le **RPO est déclaré par registre** (sa Fiche) ; *(2)* l'**Inventaire de perte** confronte le registre restauré aux **preuves des pairs** (Outbox relayées, Inbox, Quarantaine, journaux corrélés) et borne la fenêtre exacte ; *(3)* la **Perte Déclarée** est un événement d'exploitation journalisé, annoncé aux propriétaires affectés **et aux acteurs identifiables** *(amendement F5.2.99 : « votre acte n'a pas survécu »)* — jamais silencieuse. Un fait jamais relayé avant le crash est *vraiment* perdu : l'aveu est la seule issue constitutionnelle (fabriquer est interdit, taire est mentir, RPO-zéro absolu est impossible à la perte de région).

**La Réadmission** *(amendement F5.2.99)* : un fait perdu dont la preuve existe chez les pairs peut être **réadmis** par un **fait de POLICE du registre** — le gardien réadmet (**`Readmitted`**, à provenance marquée), sur dossier d'Inventaire fourni par l'Exploitation, sous Gouvernance. La police des registres gagne son **troisième membre** : *Invalidated* (le vice), *Struck* (le retrait), **`Readmitted`** (le retour prouvé). *On ne re-fabrique jamais un fait sans preuve ; on ne laisse jamais mourir un fait prouvé.*

## §7. Les migrations

**Expand-contract, au service exclusif de V-1→V-6 et I-9** : étendre → migrer (le Migration Runtime, étapes réversibles, change-control) → contracter (mort dérivable V-5 appliquée aux formes). Le rollback de schéma suit la fenêtre de compatibilité (R-9). Renommage/suppression au stockage = changements de **forme privée**, indépendants des générations de contrats. **Interdit re-scellé** : *une migration ne corrige jamais une vérité* (la migration-qui-corrige est l'UPDATE-législateur en habits de cérémonie).

## §8. Les performances

**(1) La clé R-A définit la frontière minimale de partition** : le sharding ne sépare jamais les termes d'une clé déclarée ; **la carte tactique de F3 est déjà une carte de sharding**. Précision (amendement F5.2.99) : *partition = max(l'unité, la portée de la clé R-A) ; en l'absence de clé R-A, l'unité est la frontière.* **(2) Toute dénormalisation est une projection** (recalculable, datée, jamais consultée comme vérité).

## §9. La sécurité des données & l'effacement légal

Chiffrement en transit et au repos, rotation par enveloppe (clés au coffre — I-8), accès par le vestibule. **Les environnements inférieurs ne reçoivent jamais de vraies données** (dérivé anonyme par construction ; le masquage-après-copie est interdit). Rétention et destruction par registre, déclarées (Fiche).

**L'effacement légal — la séparation matière/clés/structure** : *(a)* les contenus personnels vivent en **Dépôts** — l'effacement les **détruit** (actes de garde tracés) ; *(b)* les données incorporées aux faits sont chiffrées **par clés de personne** — l'effacement **détruit les clés** (*crypto-shredding* : la matière devient illisible à jamais, détruite-en-effet, prouvablement) ; *(c)* la **structure des faits demeure** (identités opaques, natures, instants, provenances) — l'histoire reste auditable sans plus rien dire de la personne. Exécuté par l'`ErasureProcess` (F4.2), **en Commands de police tracées — jamais un UPDATE, jamais un DELETE de faits**. *(Un fait illisible est encore un fait : la matière n'a jamais été l'essence du fait.)*

## §10. La Fiche de Registre (amendement F5.2.99 : deux parties, deux propriétaires)

Chaque registre déclare, dans une **Fiche opposable** (vérifiée en CI, servie à l'exploitation) — **objet constitutionnel à deux parties** :

- **Partie de vérité** (appartient au **propriétaire du domaine**, nul autre ne la touche) : la vérité et son domaine, les **clés R-A**, la **rétention**, la **politique d'effacement**.
- **Partie d'exploitation** (appartient à l'**Exploitation, sous Gouvernance**) : le **moteur** (mécanisme remplaçable), le **RPO/RTO**, la **frontière de partition**, les dérivés reconstruisibles.

Le changement de moteur suit une chaîne sans ambiguïté : *l'Exploitation propose → la Gouvernance approuve la Fiche → le Root exécute → le domaine ne l'apprend jamais.* **Trente vérités, trente Fiches** — la Persistance entière devient énumérable, auditable, remplaçable pièce à pièce.

## §11. Lois S-1 → S-10

- **S-1** La Persistance conserve, ne possède jamais : le Registre est le contrat du propriétaire, le moteur un mécanisme, l'archive le même propriétaire ailleurs.
- **S-2** Un registre par vérité ; les dialectes meurent à l'adapter ; l'ORM est un outil, jamais un modèle ; une unité chargée est entière.
- **S-3** La transaction appartient à la Séquence ; le registre fournit l'atomicité état+faits et l'isolation des clés R-A ; un conflit de concurrence est une Failure, jamais une Decision.
- **S-4** Tout dérivé passe le test du pardon — reconstruisible ou mort ; sans chemin de reconstruction écrit, présumé propriétaire donc illégal.
- **S-5** La validité se lit où la lecture-de-ses-écritures est garantie — jamais sur un réplica en retard.
- **S-6** Le backup est une copie, la restauration un acte gouverné ; la perte de queue est une **Perte Déclarée** (RPO déclaré, Inventaire par les preuves des pairs, annonce aux propriétaires et acteurs) ; la **Réadmission** (`Readmitted`) d'un fait prouvé passe par la police, à provenance marquée ; rien n'est re-fabriqué sans preuve.
- **S-7** Les migrations sont expand-contract, réversibles par fenêtre, exécutées par le Migration Runtime — et ne touchent **jamais** le sens.
- **S-8** La performance n'achète jamais un invariant : la clé R-A borne la partition (max(unité, portée R-A)) ; toute dénormalisation est une projection.
- **S-9** La matière est destructible, la structure des faits immuable : l'effacement légal détruit dépôts et clés (crypto-shredding), en police tracée — jamais un UPDATE ; les vraies données ne quittent jamais la production.
- **S-10** Chaque registre porte sa **Fiche** opposable (deux parties, deux propriétaires) — vérifiée en CI.

## §12. Anti-Patterns (8 fiches)

La base-intégration · le schéma-modèle · le cache-vérité · la recherche-vérité · la migration-qui-corrige · le réplica-menteur · l'UPDATE-effaceur · l'event-store-propriétaire.

## §13. Architectures concurrentes — détruites

Database-First · ORM-First · Event Store propriétaire · Active Record · Shared Database · Database as Integration · Cache as Truth · Search as Truth · NoSQL/Vendor-First · Lakehouse First (mort comme propriétaire, **vivant comme étage analytique aval** nourri par les faits) · **Data Mesh** (cousin **absorbé** : sa propriété-par-domaine est notre loi depuis F2, ses data products sont nos faits publiés et projections à Fiche — Mentora implémente les principes du mesh, avec en plus le NON, les polices, le pardon). **Aucune survivante comme autorité.**

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F5.2** (Persistance, lois S-1→S-10) et **F5.2.99** (quatre amendements intégrés : **Fiche de Registre à deux parties/deux propriétaires** ; **`Readmitted`** troisième police du registre + Perte Déclarée annoncée aux acteurs ; **trois réservations de vocabulaire** — Snapshot (tactique F3.1.11) / Journal (application F4.1) / Export (droit de la personne P9.6), leurs doubles techniques renommés *Image de sauvegarde, journal de moteur, Copie d'exploitation* ; reconstruction = **Snapshot privé + delta**, partition = **max(unité, portée R-A)**, dérivé sans chemin de reconstruction présumé illégal). **Règle N°18** : le Grand Audit F5.99 (Lot 6E) vérifie sans modifier ce chapitre. Les réservations de vocabulaire sont des amendements Titre VII au Dictionnaire (F2.5) — inscrites ici comme faits de ce chapitre, canonisées au glossaire ultérieurement. Entrées de glossaire dues : le Registre, la Fiche de Registre, la Perte Déclarée, la Réadmission (`Readmitted`), le crypto-shredding. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
