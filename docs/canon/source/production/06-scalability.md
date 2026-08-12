---
doc: f5-06-scalability
title: F5.6 — Scalability, Capacity & Multi-Tenant (état final ratifié)
type: source
titre: production
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 6C)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 6C"
sources_session:
  - "F5.6 — Scalability, Capacity & Multi-Tenant Constitution (nature, concepts, quatorze procès, le théorème de résidence de vérité, isolation à quatre échelles, lois SC-1→SC-10, 8 anti-patterns)"
  - "F5.6.99 — Scalability Constitutional Audit (cinq amendements : démarcation résidence/localisation ; placement/migration de tenant = actes d'Exploitation ; « Capacity » = lecture physique ; le fairness mesure la physique ; aucune projection mondiale exacte)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F5.6, après les cinq
  amendements de F5.6.99. Ce chapitre possède la Constitution de la Scalabilité
  et les lois SC-1→SC-10 (préfixe SC- car S- est pris par F5.2 — loi 10). Thèse :
  la Scalabilité multiplie les mécanismes, elle ne divise jamais les vérités.
  Règle N°18 : le Grand Audit F5.99 (Lot 6E) vérifie sans modifier ; règle N°19 :
  la démonstration FORMELLE du théorème de résidence comme propriété émergente est
  élevée par F5.99 (Procès III), non anticipée ici comme justification.
  Scaffolding de session exclu. Titre VII pour toute évolution.
---

# F5.6 — Scalability, Capacity & Multi-Tenant

> État **final ratifié** : F5.6 amendé des cinq articles de F5.6.99. **Thèse** :
> *la Scalabilité multiplie les mécanismes ; elle ne divise jamais les vérités.*
>
> **Correction de préfixe (loi 10)** : `S-` est déjà pris (F5.2, Persistance) ;
> les lois de ce chapitre sont numérotées **`SC-1 → SC-10`** (SCale).

## §1. Nature de la Scalabilité

**La Scalabilité est une propriété d'invariance** : un système est scalable si sa Constitution reste vraie quand sa taille varie. Elle **ne possède rien** (test du pardon : la machinerie de croissance disparaît, les vérités restent où elles étaient, le système rapetisse sans mentir). Sa loi-sœur : *la Fiabilité préserve la vérité sous la panne ; la Scalabilité préserve la vérité sous la taille.* *(La caractérisation formelle comme propriété émergente est élevée par F5.99, Procès III ; ce chapitre en énonce les lois SC.)*

## §2. Les quatorze procès (synthèse)

Un tenant n'est jamais une frontière de propriété nouvelle · la montée en charge ne crée aucune vérité · l'élasticité ne décide jamais · l'auto-scaling ne devient jamais métier · le quota borne une ressource (technique) tandis qu'une limite d'offre est une Policy du produit · le fairness ne privilégie jamais un client · on distribue mondialement sans consensus global · une région n'est qu'un lieu de résidence · le cache Edge ne fait jamais autorité (projections datées) · le multi-tenant ne modifie aucun invariant · le sharding ne déplace aucune propriété · **la Cell Architecture est un mécanisme excellent** (un domaine de panne borné) jamais une autorité · les modèles de tenant/BD sont des mécanismes · **un milliard d'utilisateurs sans déplacer une vérité — le théorème (§3)**.

## §3. Le théorème central — la résidence de vérité

**Toute vérité a une résidence unique** : son registre vit dans **une** région propriétaire (celle de l'Organisation, de la personne, selon la résidence légale des données — F5.4 : matière personnelle). **Les autres régions n'en voient que des projections datées** (lues, jamais autoritaires ; la validité se lit à la résidence — S-5). **Absence de consensus global** : un invariant vit dans une frontière transactionnelle *locale à la résidence de son unité* — deux régions ne coécrivent jamais la même vérité, donc n'ont **rien à accorder** ; le split-brain inter-régional produit du double travail, jamais une double vérité (à l'échelle continentale). **Corollaire de croissance** : passer de 1 à 10⁹ utilisateurs = ajouter des cellules et des résidences ; chaque nouvelle vérité naît dans **une** résidence, jamais répartie. *Mentora se distribue par partition de propriétaires, jamais par réplication de vérités* — la Constitution reste vraie à toute échelle *parce qu'elle n'a jamais eu besoin que la planète soit d'accord.*

**Démarcation résidence / localisation** *(amendement F5.6.99)* : *une localisation sert des lectures datées ; elle ne tranche jamais un acte* — l'acte (pas 5/6 de la Séquence) revérifie toujours à la résidence (S-5). Le nombre de copies est libre, leur pouvoir est nul. **Aucune projection mondiale exacte n'existe** *(amendement F5.6.99)* : un « compteur mondial exact » exigerait le consensus global (interdit) — il est donc soit une **projection datée** (« environ N, à jour il y a t »), soit il n'existe pas ; toute projection porte sa date.

## §4. L'isolation de tenant — quatre échelles

Prolongeant l'Isolation à trois échelles de F5.5.99 : **(a) ressource** (Bulkhead, Runtime — contre le Noisy Neighbor) · **(b) instance** (Flotte) · **(c) zone/cellule** (Exploitation — le rayon de panne) · **(d) partition de données** (sharding par clé de tenant, sous S-8 — contre la Hot Partition, en respectant les clés R-A). Le Noisy Neighbor et la Hot Partition sont des **pathologies de mécanisme partagé** — soignées par isolement technique, **jamais** par préférence métier. **Le fairness mesure la physique, ne l'attribue jamais** *(amendement F5.6.99 : facturer plus de « pression système » aux non-Premium est une fraude au fairness — anti-pattern ; le signal physique est mesuré, jamais attribué selon le client)*.

**La Cellule** : un contenant à **deux choses, toutes deux des mécanismes** — un **rayon de panne** (isolation de zone) et un **périmètre de résidence** (les registres qui y vivent). **Le placement et la migration d'un tenant entre cellules sont des actes d'Exploitation tracés en Main courante** *(amendement F5.6.99)* — la cellule est un contenant, jamais un propriétaire.

## §5. Architectures concurrentes — jugées

*Database-per-Tenant / Shared Database / Shared Schema / Hybrid* : choix de mécanisme de partition, libres par Fiche de Registre (S-10), morts comme lois. *Cell Architecture* : mécanisme de première classe, jamais autorité. *Federation / Data Mesh* : absorbés (fédération de lectures ; propriété-par-domaine déjà nôtre). *Cloud Native / Kubernetes / Serverless / Edge / CDN-First* : topologies-mécanismes, mortes comme législateurs. **Global Active-Active** (la même vérité écrite en plusieurs régions) : **mort — c'est exactement ce que le théorème interdit** (consensus global + vérité à résidences multiples). *Multi-Region Active-Passive / Geo-Replication* : **vivants comme mécanismes de résilience** — la région passive garde des **copies** (backups, réplicas de lecture), jamais une seconde autorité. **La ligne de partage : partitionner les mécanismes est libre, répartir une vérité est mortel.**

## §6. Lois SC-1 → SC-10

- **SC-1** La Scalabilité est l'invariance de la Constitution sous la taille ; elle ne possède aucune vérité.
- **SC-2** Croître multiplie les mécanismes (instances, cellules, partitions, caches) ; cela ne crée jamais un propriétaire ni une vérité.
- **SC-3** Un tenant est une Organisation ou un contexte de Workspace — jamais un propriétaire nouveau ; « TenantId » est toujours un identifiant gelé.
- **SC-4** Toute vérité a une résidence unique ; les autres régions n'en voient que des projections datées ; la validité se lit à la résidence ; une localisation sert des lectures datées, elle ne tranche jamais un acte.
- **SC-5** Aucun consensus global n'est requis : les invariants vivent dans des frontières transactionnelles locales à leur résidence ; le split-brain produit du double travail, jamais une double vérité — à toute échelle.
- **SC-6** L'élasticité et l'auto-scaling suivent la charge technique, aveugles au métier ; scaler par valeur de client est interdit.
- **SC-7** La Capacity est une lecture physique ; le Quota borne une ressource (technique) ; une limite d'offre est une Policy du produit, jamais un quota ni le mot « Capacity ».
- **SC-8** Le fairness répartit les ressources aveuglément ; il mesure la physique, ne l'attribue jamais ; il ne privilégie jamais une personne.
- **SC-9** L'isolation de tenant a quatre échelles (ressource, instance, cellule, partition), toutes techniques ; les pathologies partagées se soignent par isolement, jamais par préférence métier.
- **SC-10** Active-Active d'une même vérité est interdit ; la distribution se fait par résidence unique et projections datées — Active-Passive et Geo-Replication sont des copies, jamais des autorités secondes.

## §7. Anti-Patterns (8 fiches)

Le tenant-propriétaire · l'active-active de vérité · le fairness-métier · l'autoscaling-métier · le quota-offre · l'Edge-vérité · le consensus-global-de-croissance · le noisy-neighbor-toléré · la cellule-propriétaire. *(Plus, par F5.6.99 : la fraude au fairness, la projection mondiale sans date.)*

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F5.6** (Scalabilité, lois SC-1→SC-10, le théorème de résidence) et **F5.6.99** (cinq amendements intégrés : **démarcation résidence/localisation** — une localisation ne tranche jamais un acte ; **placement/migration de tenant = actes d'Exploitation** tracés en Main courante, la cellule est un contenant ; **« Capacity » nu = lecture physique**, la capacité d'offre est une Policy ; **le fairness mesure la physique, ne l'attribue jamais** ; **aucune projection mondiale exacte** — toute projection porte sa date). **Règle N°18/N°19** : le Grand Audit F5.99 (Lot 6E) vérifie sans modifier ; la démonstration formelle du **théorème de résidence** comme propriété émergente est élevée par F5.99 (Procès III) — ici il gouverne via SC-4/SC-5, il n'est pas invoqué comme justification anticipée. Entrées de glossaire dues au Titre VII : la Résidence de vérité, le Tenant, la Cellule, le Quota vs la limite d'offre, le Fairness aveugle, l'Active-Passive. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
