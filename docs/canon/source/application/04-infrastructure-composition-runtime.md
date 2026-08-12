---
doc: f4-04-infrastructure-composition-runtime
title: F4.4 — Infrastructure, Composition Root & Runtime (état final ratifié)
type: source
titre: application
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 5C)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 5C"
sources_session:
  - "F4.4 — Infrastructure Boundaries, Composition Root & Runtime Architecture (définition, Root, Ports, Adapters, configuration, Runtime, frameworks, secrets, déploiement, lois I-1→I-10, 10 anti-patterns)"
  - "F4.4.99 — Infrastructure Constitutional Audit (Root unique par exécutable ; I-11 cycle de vie des ressources ; I-12 direction des Adapters ; critère permis/performance ; vérification de génération au boot ; partage boot/CI ; Adapter à deux interlocuteurs ; dumps au régime du coffre)"
  - "F4.99 — Grand Application Audit (consulté : lecture globale des couches en anneaux — vue de topologie, propriété du chapitre de clôture, Lot 5C ; n'altère aucune loi I)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F4.4, après les amendements de
  F4.4.99 (dont I-11 et I-12). Ce chapitre possède la Constitution de
  l'Infrastructure et les lois I-1→I-12. Règle N°15 démontrée : l'Infrastructure
  fournit capacités, points de composition et mécanismes ; elle n'absorbe jamais
  les séquences, les Process Managers, la circulation ni les lois métier. Le
  Grand Audit F4.99 n'altère aucune loi I ; sa lecture globale « anneaux et un
  côté » est une vue de topologie, propriété du chapitre de clôture (Lot 5C).
  Scaffolding de session exclu. Titre VII pour toute évolution.
---

# F4.4 — Infrastructure, Composition Root & Runtime

> État **final ratifié** : F4.4 amendé des articles de F4.4.99 (dont I-11 et I-12).
> **Règle N°15** : l'Infrastructure fournit les capacités, les points de
> composition et les mécanismes — elle n'absorbe jamais les séquences (ch. 01),
> les Process Managers (ch. 02), la circulation (ch. 03), ni les lois métier.

## 1. Définition constitutionnelle

L'Infrastructure est **le lieu où les abstractions deviennent exécutables** — et rien d'autre. **Elle possède** : les implémentations des Ports, les Adapters, le Composition Root, le Runtime (boot, arrêt, santé), la configuration technique, les frameworks, les fournisseurs, les ressources. **Elle ne possède jamais** : une vérité, un invariant, une Decision, une Policy, une Specification, un fait, une Command, une règle. **La dépendance pointe vers le centre, toujours** — la seule flèche qui ne s'inverse sous aucun prétexte.

## 2. Le Composition Root

**Le seul endroit du système où des types concrets existent.** Il construit la Policies (avec leurs paramètres produit), les Application Services, les définitions de Process Managers, les Dispatchers et leurs tables, les Adapters, les ACL, les génériques, l'Échéancier, les relais. **Il ne construit JAMAIS les Aggregates** — les unités naissent par des actes (Factories) et se reconstituent par leurs registres ; le Root assemble **la machinerie sans état**, jamais les vérités. **La règle du regard** : au-dessus du Root, on **reçoit** ses dépendances ; on ne les **cherche** jamais. **Unique par EXÉCUTABLE (amendement F4.4.99)** : Mentora aura plusieurs exécutables (l'application, les relais, l'Échéancier, les workers) — chacun **son** Root, complet, clos, validé ; « unique » = *unique par exécutable, jamais partagé, jamais distribué*.

## 3. Les Ports

**Le Port, contrat de capacité possédé par son consommateur** (domaine ou application), nommé par capacité (`<Capability>Port`). Implémenté par un Adapter, en dessous. **Son évolution appartient au propriétaire du Port — jamais l'implémenteur** : un Adapter qui impose son interface au domaine est l'inversion de dépendance inversée. **Le domaine ne connaît jamais une implémentation** (A-9). **Un Port ne connaît jamais un framework** (types du dictionnaire + valeurs pures). Un Port partagé entre deux consommateurs est un Shared Kernel au sous-sol — interdit (chaque consommateur son port, même vers la même capacité).

## 4. Les Adapters

**Ce qu'un Adapter traduit** : le dialecte vers le contrat, dans les deux sens (traduction vers le contrat légitimement à perte). **Ce qu'il ne crée jamais** : une **Decision**, un **Domain Event**, une **vérité**. **Deux interlocuteurs, et deux seulement (amendement F4.4.99)** : son fournisseur (en dialecte) et sa frontière (port ou dispatch) — rien d'autre n'existe pour lui. **Le glissement mortel fermé** : un Adapter qui appellerait un Aggregate ou un PM **directement** contournerait les pas 2-5 de la Séquence (identité non injectée, validités non vérifiées, transaction sans gardien) — interdit.

## 5. La Configuration — trois espèces, critère raffiné

**Produit** (paramètres des Policies) — publiée, versionnée, gouvernée par le métier. **Technique** (pools, timeouts, tailles de files) — au runtime. **Secrets** — au vestibule. **Critère raffiné (F4.4.99) — le permis contre la performance** : *une configuration est **produit** quand elle change ce que le produit **permet ou refuse** (bornes, durées, droits) ; elle est **technique** quand elle ne change que **comment vite et comment gros**, sans déplacer un permis.* **Feature Flags** : un flag qui change un comportement métier **est un paramètre de Policy** — publié, journalisé, jamais caché ; un flag de déploiement est technique. **Le flag caché qui gouverne du métier est un anti-pattern** (une règle sans propriétaire). Le hot-reload : légal pour la technique ; pour le produit, un changement de paramètre de Policy est un **acte journalisé**.

## 6. Le Runtime

**Boot** : *initialisation → construction (Root) → **validation** → ouverture*. **Readiness** : l'application ne répond qu'après validation complète ET relais/Échéancier ré-hydratés. **Liveness** : le processus vit tant que ses invariants d'exécution tiennent. **Shutdown** : drainage — fermer l'entrée, achever les Séquences en vol (courtes par A-3), laisser les relais reprendre au prochain boot (l'Outbox pardonne). **Redémarrage partiel interdit** : un exécutable redémarre entier (le « composant relancé à chaud » est une table rouverte). **Mourir immédiatement** : validation échouée, configuration invalide, table incohérente, secret manquant — **fail closed au boot : une application qui démarre à moitié ment déjà.**

## 7. La Validation du démarrage — la liste close

Avant le premier appel, le Runtime **démontre** : chaque Command a son porteur unique · chaque Query son lecteur et sa grille R-C · chaque abonnement pointe des faits existants · chaque Policy est construite avec ses paramètres valides · chaque Port a une implémentation · chaque ACL existe · chaque configuration est du bon type et dans ses bornes · chaque table dérivée se reconstruit sans reste · **chaque génération de contrat déclarée est servie** (vérification de génération, amendement F4.4.99 — un consommateur déclarant une génération que le publieur ne sert plus tue le boot). **Une seule erreur = pas de démarrage.** **Partage boot / CI (F4.4.99)** : le **boot** vérifie l'*exécutabilité* (tables cohérentes, tout câblé, tout typé) ; la **CI** vérifie la *conformité aux catalogues* (30 unités, 79 commandes, abonnements) — deux gardiens, deux moments, aucune redondance, aucun trou.

## 8. Les Frameworks

**Que possède un framework ? Des mécanismes.** Ce qu'il ne remplacera jamais : les lois, le langage, la Séquence, les tables et leurs propriétaires, les registres. **Le confinement** : aucun import de framework dans le domaine (loi déjà exécutable, scannée depuis F1.5) ; les types de framework meurent aux Adapters et au Root ; toute annotation de framework sur un objet du domaine est une contamination. La responsabilité la plus forte cherchée — **le rendu** (Flutter possède l'arbre de rendu) — est **un mécanisme, le plus gros de tous** : *« Flutter n'invente jamais. Flutter matérialise »* (P11.9.1). Ce qui vaut pour le plus puissant vaut pour tous : **des mécanismes, jamais des lois.**

## 9. Les Secrets

**Un secret n'a qu'un lieu, et tous les autres lieux n'en connaissent que le nom.** Chargés par le Root **par références** ; renouvelés par l'exploitation (rotation sans redéploiement). **Le domaine ne les voit JAMAIS** (il n'a même pas de type pour les contenir). Jamais dans un log, jamais dans un Domain Event, jamais mis en cache. **Dump mémoire (F4.4.99)** : artefact d'infrastructure à traitement **de niveau coffre** — chiffré, rétention bornée, accès vestibule.

## 10. L'Infrastructure externe & le Déploiement

Base, cache, broker, garde, e-mail, SMS, paiement, monitoring : **possédés par personne**, remplaçables sans deuil — un Adapter nouveau au Root, rien d'autre ne bouge ; leurs dialectes meurent aux Adapters, leurs pannes deviennent des `Failure`. **Déploiement** : le domaine, la Constitution et le Runtime (hors configuration technique et câblage) restent **identiques au bit près** au-dessus du Root. **Deux lois** : *(a)* les migrations de schéma suivent **expand-contract** (V-2 appliquée au stockage) ; *(b)* **un rollback ne roule que des binaires — jamais des faits** (loi 17). Canary : deux versions du binaire coexistent, tenable **parce que** V-2 (additif) et I-9 (expand-contract) le garantissent — le déploiement hérite du versionnement.

## 11–13. Observabilité & Testabilité

Trois registres, zéro contamination : au Runtime (logs techniques, métriques, santé) ; à l'application (le journal des Séquences, l'audit) ; au transport (enveloppes, files, Quarantaine) — chacun chez soi, la clé de corrélation les relie en lecture d'outillage. **Testabilité** : sans infrastructure (domaine zéro doublure ; Application Services et PM doublures de ports ; Policies/Specifications valeurs) ; avec — les **tests de contrat** (chaque Adapter prouvé contre son fournisseur, par frontière, en CI : le seul lieu du réel) ; **boot tests** (le Root se teste en démarrant) ; **composition tests** (les tables dérivées comparées aux catalogues).

## 14. Le cycle de vie des ressources (I-11) et la direction des Adapters (I-12)

- **I-11 — cycle de vie des ressources (F4.4.99)** : *toute ressource a un propriétaire-composant (l'Adapter possède ses connexions et clients, le runtime ses workers et files) ; le Runtime orchestre des crochets (**construire → démarrer → drainer → libérer**), naissance dans l'ordre des dépendances, mort dans l'ordre **inverse** ; l'enregistrement au cycle de vie est une **condition d'assemblage** — un composant non enregistré ne peut pas exister — rien d'orphelin, par construction.*
- **I-12 — direction des Adapters (F4.4.99)** : *il existe deux espèces et deux seulement — les **Adapters entrants** (driving : HTTP, Échéancier, brokers entrants — leur unique bouche est le **Dispatch**, jamais un port de domaine) et les **Adapters sortants** (driven : ils **implémentent** des ports et parlent aux fournisseurs — **ils ne dispatchent jamais** ; un sortant qui commande a décidé, et un adapter ne décide pas ; son rapport remonte par son port, et c'est un handler déclaré qui commande). Sous I-2 + I-12, le graphe est **acyclique par construction** : entrants → Dispatch → Séquences → ports → sortants → fournisseurs — aucune arête retour possible.*

## 15. Lois I-1 → I-12

- **I-1** La dépendance pointe vers le centre ; l'Infrastructure connaît tout, n'est connue de rien.
- **I-2** Un seul lieu de types concrets : le Root ; au-dessus, on reçoit, on ne cherche jamais.
- **I-3** Le Root construit la machinerie, jamais les vérités.
- **I-4** Un Port appartient à son consommateur et ignore les frameworks ; un Adapter sert une seule frontière et ne crée ni fait, ni Decision, ni vérité.
- **I-5** Trois configurations : produit (Policy publiée), technique (runtime), secret (coffre) ; la bascule se juge au **permis contre la performance** ; aucun flag caché ne gouverne du métier.
- **I-6** Le boot valide tout (liste close, dont les générations de contrats) et meurt sinon — fail closed avant le premier appel.
- **I-7** Aucun import de framework dans le domaine ; les annotations de framework sont des contaminations ; tout est scanné.
- **I-8** Un secret n'a qu'un lieu ; ailleurs, seulement son nom ; dumps au régime du coffre.
- **I-9** Les environnements ne changent que la configuration technique et le câblage ; expand-contract au stockage ; le rollback roule des binaires, jamais des faits.
- **I-10** Le réel ne se teste qu'aux contrats d'Adapters ; le Root se teste en bootant ; les tables se vérifient contre les catalogues (boot = exécutabilité, CI = conformité).
- **I-11** Toute ressource a un propriétaire-composant ; le Runtime ordonne naissances et morts (ordre inverse) ; l'enregistrement est une condition d'assemblage.
- **I-12** Adapters entrants → Dispatch seul ; Adapters sortants → ports seuls ; le graphe est acyclique par construction.

## 16–17. Checklists & Anti-Patterns (10 fiches)

**Checklists** : nouveau Port · nouvel Adapter · nouveau fournisseur · nouvelle configuration · nouveau framework · nouveau secret · nouveau composant runtime · nouveau Composition Root. **Anti-Patterns (10 fiches)** : Framework God · Service Locator ambiant · Adapter intelligent · Secret dans le domaine · Configuration métier cachée · Singleton global · Runtime propriétaire · Infrastructure qui décide · Boot incomplet · Framework contaminant.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F4.4** (Infrastructure, Composition Root, Runtime, lois I-1→I-10) et **F4.4.99** (amendements intégrés : Root unique par exécutable ; **I-11** cycle de vie des ressources ; **I-12** direction des Adapters ; critère de configuration permis/performance ; vérification de génération au boot ; partage boot/CI ; Adapter à deux interlocuteurs ; dumps mémoire au régime du coffre). **Règle N°15 démontrée** : l'Infrastructure fournit capacités, points de composition et mécanismes, sans jamais absorber les séquences, les Process Managers, la circulation ni les lois métier — la dépendance pointe vers le centre, la seule flèche qui ne s'inverse jamais. **Portée du Grand Audit F4.99** : sa lecture des couches « en anneaux et un côté » est une **vue de topologie** (méta-propriété), propriété du chapitre de clôture (Lot 5C) ; F4.99 n'altère aucune loi I. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
