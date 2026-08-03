# UNIVERSAL TOKEN REGISTRY

**Statut** : La **Constitution officielle des Tokens Mentora** — l'autorité unique de tous les Tokens. Premier livrable obligatoire de P11.9, réponse directe à la **condition C-01** du [Design System Architecture Audit](design-system-architecture-audit.md) (P11.8A).
**Portée** : Architecture fonctionnelle uniquement. Aucune technologie, aucun JSON, aucun ThemeData, aucun Flutter, aucun Figma, aucune API, aucune valeur, aucun Token technique, aucun nom technique. Ce document définit le **registre** — pas son contenu énuméré ni sa matérialisation.
**Préséance** : P9 → P10 → [Accessibility Foundation](accessibility-foundation.md) (**opposable**) → [Global Experience Foundation](global-experience-foundation.md) (**opposable**) → [Experience Preferences Foundation](experience-preferences-foundation.md) (transversale) → P11.0 → [Design Tokens System](design-tokens-system.md) (P11.8 — dont ce registre est l'organe d'autorité) → ce document. Il ne modifie aucun document existant ; il ne redéfinit rien (DSD-01) ; il opère sous les règles DTV/DTP/DTN/DTC/DTT/DTD du Design Tokens System.
**Continuité (MSD-02)** : le registre est la mémoire permanente des significations — rien ne s'y perd, jamais : ce qui y entre y demeure, au pire déprécié et tracé.

---

## §1 Mission

**Principe fondateur** :

> **« Un Token n'est jamais créé. Il est enregistré. »**

Le registre **n'invente jamais un Token**. Il **reconnaît officiellement** une signification déjà approuvée par les fondations et les systèmes P11.

**Le registre devient l'autorité unique de tous les Tokens Mentora** : ce qui n'y est pas enregistré n'existe pas ; ce qui y est enregistré fait foi pour toute implémentation, pour toujours.

---

## §2 Vision

| Règle | Énoncé |
|---|---|
| UTV-01 | **Un Token possède une identité permanente** : son nom, son origine et sa signification sont établis à l'enregistrement — pour la vie du produit. |
| UTV-02 | **Un Token ne change jamais de signification** (DTT-02) : vouloir dire autre chose, c'est enregistrer un Token nouveau et déprécier l'ancien — tracé. |
| UTV-03 | **Une implémentation peut évoluer** : valeurs, formats, technologies changent librement sous le même enregistrement (DTT-05). |
| UTV-04 | **Un Token demeure** : le registre est plus durable que tout ce qui le consomme. |
| UTV-05 | **Un Token supprimé n'est jamais effacé : il devient déprécié, avec traçabilité** — son histoire, ses relations et sa raison de dépréciation restent consultables pour toujours (§8). |

---

## §3 Les dix piliers

Dix piliers. Toute règle du registre appartient à exactement un pilier.

### 3.1 Token Identity

| | |
|---|---|
| **Mission** | Donner à chaque Token son identité permanente — unique, complète, inaltérable. |
| **Responsabilités** | Tenir la fiche d'identité officielle (§7) : nom, propriétaire, origine, signification, version, statut, relations, historique — huit attributs, tous obligatoires. |
| **Frontières** | L'identité reconnaît ; elle n'invente pas : la signification vient du système d'origine (§5). |
| **Ce qu'il produit** | le format d'identité du registre. |
| **Ce qu'il ne possède jamais** | une identité partielle ; une identité modifiable en silence (UTT-04). |

### 3.2 Semantic Ownership

| | |
|---|---|
| **Mission** | Garantir que chaque Token a exactement un propriétaire sémantique — le système qui a défini sa signification. |
| **Responsabilités** | Tenir la propriété : chaque enregistrement porte son système propriétaire (§5) ; toute évolution de signification passe par lui, jamais par le registre. |
| **Frontières** | Le registre garde ; le système possède. Un différend de signification remonte au propriétaire — le registre n'arbitre jamais le sens. |
| **Ce qu'il produit** | la liaison Token → système propriétaire, vérifiable. |
| **Ce qu'il ne possède jamais** | une signification en propre ; un Token sans propriétaire (UTG-01). |

### 3.3 Classification

| | |
|---|---|
| **Mission** | Ranger chaque Token à sa place — une place, une seule. |
| **Responsabilités** | Tenir la taxonomie officielle (§6) : chaque Token appartient à un Domain (son pilier P11.8) et à un Group (sa famille de signification) — jamais deux places, jamais aucune. |
| **Frontières** | La taxonomie suit les piliers du Design Tokens System (les onze) ; elle ne crée pas de catégorie propre. |
| **Ce qu'il produit** | la classification Domain → Group → Token. |
| **Ce qu'il ne possède jamais** | une catégorie orpheline ; un classement double. |

### 3.4 Registry Organization

| | |
|---|---|
| **Mission** | Faire que le registre entier soit navigable, cohérent et unique. |
| **Responsabilités** | Tenir l'organisation d'ensemble : un seul registre pour tout Mentora (UTX-02) ; l'ordre stable des Domains ; la complétude vérifiable (toute signification approuvée a son entrée — DTT-06). |
| **Frontières** | L'organisation range ; elle ne hiérarchise pas les significations entre elles. |
| **Ce qu'il produit** | la structure de consultation du registre. |
| **Ce qu'il ne possède jamais** | un second registre ; une section privée ou cachée. |

### 3.5 Versioning

| | |
|---|---|
| **Mission** | Faire que l'évolution soit une histoire — jamais un écrasement. |
| **Responsabilités** | Tenir le versionnement : toute évolution d'un enregistrement (précision de signification par le propriétaire, ajout de variante, changement de statut) produit une version nouvelle, datée, motivée — l'ancienne reste consultable. |
| **Frontières** | Le versionnement trace la fiche, jamais les valeurs (les valeurs vivent en aval, sous le même nom — UTV-03). |
| **Ce qu'il produit** | l'historique versionné de chaque Token. |
| **Ce qu'il ne possède jamais** | un écrasement ; une version anonyme ou non motivée. |

### 3.6 Deprecation

| | |
|---|---|
| **Mission** | Organiser la fin de vie — sans jamais effacer. |
| **Responsabilités** | Tenir la dépréciation (§8) : un Token déprécié est marqué, motivé, daté ; son successeur éventuel est lié (relation « remplacé par ») ; les implémentations sont averties par le statut — **jamais supprimé** (UTV-05). |
| **Frontières** | La décision de déprécier appartient au système propriétaire ; le registre l'exécute et la trace. |
| **Ce qu'il produit** | le protocole de dépréciation et d'archivage. |
| **Ce qu'il ne possède jamais** | un effacement ; une dépréciation silencieuse (UTT-05). |

### 3.7 Relationships

| | |
|---|---|
| **Mission** | Tenir les liens entre Tokens — explicites, nommés, traçables. |
| **Responsabilités** | Enregistrer les relations officielles : « compose » (un Token de contrat référence des Tokens sémantiques — Component Tokens), « décline » (une Variant sous un Token), « remplace / remplacé par » (dépréciation), « hérite » (une préférence héritée — EP-07) — aucune autre relation sans révision. |
| **Frontières** | Une relation relie des enregistrements ; elle ne crée jamais de signification (la composition appartient au contrat, pas au registre). |
| **Ce qu'il produit** | le graphe officiel des relations, acyclique. |
| **Ce qu'il ne possède jamais** | une relation implicite ; un cycle. |

### 3.8 Traceability

| | |
|---|---|
| **Mission** | Faire que toute question sur un Token ait une réponse documentée. |
| **Responsabilités** | Tenir la trace complète : qui a enregistré, quand, sur quelle origine ; qui a versionné, pourquoi ; qui a déprécié, au profit de quoi — la chaîne entière, de la règle amont à l'état courant (DTS-01 prolongé dans le temps). |
| **Frontières** | La trace décrit le registre ; elle n'embarque jamais un contenu métier ni une donnée utilisateur. |
| **Ce qu'il produit** | l'historique auditable de chaque enregistrement. |
| **Ce qu'il ne possède jamais** | un trou d'historique ; une action anonyme (UTG-06). |

### 3.9 Governance

| | |
|---|---|
| **Mission** | Faire respecter la Constitution — par des règles vérifiables. |
| **Responsabilités** | Tenir les interdits (§12) et leur détectabilité ; instruire les entrées (§8 : proposé → accepté → enregistré) ; refuser tout ce qui n'a pas d'origine (§5). |
| **Frontières** | La gouvernance applique ; les significations restent aux systèmes, les règles de nommage au Design Tokens System (DTC). |
| **Ce qu'il produit** | le processus d'admission et la table des violations. |
| **Ce qu'il ne possède jamais** | un pouvoir de création ; une exception d'admission. |

### 3.10 Future Registry

| | |
|---|---|
| **Mission** | Accueillir dix ans de Tokens — par le même processus, toujours. |
| **Responsabilités** | Porter le protocole d'avenir : de nouveaux Domains n'apparaissent que si le Design Tokens System gagne un pilier (révision P11.8) ; de nouvelles origines que si un système naît en amont (§5) ; le registre grandit, sa Constitution demeure. |
| **Frontières** | Le registre n'anticipe pas : aucun emplacement réservé, aucune entrée spéculative (l'équivalent de Future Tokens). |
| **Ce qu'il produit** | le protocole d'extension du registre. |
| **Ce qu'il ne possède jamais** | une entrée en réserve ; un raccourci d'admission. |

---

## §4 Responsabilités

### 4.1 Autorisées

| Règle | Le registre PEUT |
|---|---|
| UTP-01 | **Enregistrer** — reconnaître une signification approuvée. |
| UTP-02 | **Organiser** — le registre unique, navigable. |
| UTP-03 | **Classer** — Domain, Group, place unique. |
| UTP-04 | **Tracer** — l'historique complet de chaque entrée. |
| UTP-05 | **Versionner** — l'évolution comme histoire, jamais comme écrasement. |
| UTP-06 | **Déprécier** — la fin de vie organisée, jamais l'effacement. |
| UTP-07 | Lier — les relations officielles entre enregistrements (§3.7). |
| UTP-08 | Refuser — toute entrée sans origine, sans propriétaire ou dupliquée. |

### 4.2 Interdites

| Règle | Le registre NE PEUT JAMAIS |
|---|---|
| UTN-01 | **Créer** un Token (§1 : il enregistre, il ne crée pas). |
| UTN-02 | **Traduire** — la traduction des systèmes appartient au Design Tokens System (P11.8). |
| UTN-03 | **Implémenter** — la matérialisation appartient aux kits (DTD). |
| UTN-04 | **Posséder Flutter** — ni aucune technologie (DTN-06). |
| UTN-05 | Modifier une signification — elle appartient à son système (UTV-02). |
| UTN-06 | Supprimer — jamais (UTV-05). |
| UTN-07 | Renommer en silence — un renommage est une dépréciation + un enregistrement, tracés (UTT-05). |
| UTN-08 | Admettre une exception — le processus d'admission est le même pour tous, pour toujours. |

---

## §5 Traduction des systèmes — les origines officielles

Le registre reçoit **uniquement** des Tokens provenant de :

| Origine officielle | Ce qu'elle apporte au registre |
|---|---|
| [Color System](color-system.md) | les rôles sémantiques et liaisons d'états |
| [Typography System](typography-system.md) | les rôles de lecture et la hiérarchie |
| [Spacing System](spacing-system.md) | les relations spatiales et cadences |
| [Elevation & Surface System](elevation-surface-system.md) | les significations d'élévation et responsabilités de surface |
| [Iconography System](iconography-system.md) | le registre signification → signe |
| [Illustration System](illustration-system.md) | le registre situation → image et narrations |
| [Component Library](component-library.md) | les compositions de contrat |
| **Appearance** ([GE §5](global-experience-foundation.md), [Tokens §3.11](design-tokens-system.md)) | les préférences d'apparence — jeux de valeurs sous noms stables |
| **Interaction** ([Tokens §3.8](design-tokens-system.md)) | les exigences d'interaction nommées |
| **Motion** ([Tokens §3.9](design-tokens-system.md)) | les huit intentions et leurs expressions |

**Aucune autre origine.**

| Règle | Énoncé |
|---|---|
| UTS-01 | Une entrée dont l'origine manque **retourne vers le système concerné** (DSM-03, DTS-02) — **jamais un Token créé directement**. |
| UTS-02 | Une origine nouvelle exige d'abord la naissance de son système en amont, puis la révision de cette table. |

---

## §6 Les niveaux

| Niveau | Définition |
|---|---|
| **Registry** | le registre entier — unique pour tout Mentora, l'autorité (§1). |
| **Domain** | le territoire d'une origine officielle (§5) : Color, Typography, Spacing, Elevation & Surface, Iconography, Illustration, Component, Appearance, Interaction, Motion — **dix Domains, un par origine, ni plus ni moins tant que la table des origines ne change pas** (UTS-02). |
| **Group** | la famille de significations dans un Domain (ex. : les rôles d'état, les rôles de confiance) — héritée des systèmes d'origine, jamais inventée. |
| **Token** | l'enregistrement : une signification reconnue, avec sa fiche d'identité complète (§7). |
| **Variant** | la déclinaison déclarée d'un Token (par thème, par contraste, par contexte d'appareil) — **sous le même nom** (DTV-03), jamais un Token nouveau. |
| **Implementation** | la matérialisation dans une technologie — **une implémentation n'entre jamais directement dans le registre** : elle le consomme, en aval, sous DTD. |

La consultation descend (Registry → Variant) ; l'admission monte toujours par l'origine (§5) — jamais par l'implémentation.

---

## §7 Convention d'identité

Chaque Token enregistré possède **huit attributs obligatoires** :

| Attribut | Définition |
|---|---|
| **Nom** | l'identifiant unique et permanent — construit sous les règles de nommage du Design Tokens System (DTC-01→07) ; **le nom doit survivre dix ans**. |
| **Propriétaire** | le système qui possède la signification (§3.2). |
| **Origine** | la règle amont citée (le rôle, la loi, le contrat — DTS-01). |
| **Signification** | ce que le Token veut dire — en une phrase, dans le langage des fondations. |
| **Version** | l'état courant de la fiche, daté et motivé (§3.5). |
| **Statut** | l'étape du cycle de vie (§8). |
| **Relations** | les liens officiels (§3.7). |
| **Historique** | la trace complète depuis l'enregistrement (§3.8). |

| Règle | Énoncé |
|---|---|
| UTC-01 | Les huit attributs sont obligatoires — une fiche incomplète n'entre pas. |
| UTC-02 | Le nom est unique dans tout le registre — pour toujours (même déprécié, un nom ne se réattribue jamais). |
| UTC-03 | Le nom décrit un rôle, jamais une valeur, une couleur, une taille ni une technologie (DTC-01→04). |
| UTC-04 | Le propriétaire et l'origine sont vérifiables — un lien mort est une violation. |
| UTC-05 | La signification tient en une phrase ; si elle en demande deux, ce sont deux Tokens. |
| UTC-06 | La version et le statut sont toujours à jour — la fiche dit l'état vrai (DTT-01 appliqué au registre lui-même). |
| UTC-07 | Les relations sont déclarées des deux côtés — jamais un lien unilatéral. |
| UTC-08 | **Le nom doit survivre dix ans** — tout nom se juge à cette aune avant l'enregistrement (DTC-07). |

---

## §8 Cycle de vie

```
Proposé  →  Accepté  →  Enregistré  →  Utilisé  →  Versionné  →  Déprécié  →  Archivé
```

| Étape | Définition |
|---|---|
| **Proposé** | le système d'origine soumet une signification approuvée chez lui ; la fiche est instruite (§3.9). |
| **Accepté** | la gouvernance vérifie : origine, propriétaire, unicité, nom décennal — l'admission est prononcée. |
| **Enregistré** | la fiche entre au registre ; le nom est réservé pour toujours. |
| **Utilisé** | des implémentations le consomment ; des relations peuvent s'y attacher. |
| **Versionné** | la fiche évolue par versions datées et motivées — jamais écrasée. |
| **Déprécié** | la fin de vie est prononcée par le propriétaire : marquée, motivée, successeur lié — les implémentations migrent à leur rythme, averties. |
| **Archivé** | l'entrée quitte l'usage courant mais reste consultable intégralement — **jamais supprimé.** |

| Règle | Énoncé |
|---|---|
| UTL-01 | Aucune étape ne se saute ; aucun état hors cycle n'existe. |
| UTL-02 | Chaque transition est tracée : qui, quand, pourquoi. |
| UTL-03 | **Jamais supprimé** — l'archive est la dernière étape, pas l'effacement (UTV-05). |

---

## §9 Confiance

| Règle | Le registre garantit |
|---|---|
| UTT-01 | **Jamais deux Tokens pour la même signification** (DTN-08). |
| UTT-02 | **Jamais une signification pour deux Tokens** — l'unicité vaut dans les deux sens. |
| UTT-03 | **Jamais de duplication** — ni de nom, ni de sens, ni de fiche. |
| UTT-04 | **Jamais de renommage silencieux** — renommer = déprécier + enregistrer, tracés (UTN-07). |
| UTT-05 | **Jamais de suppression** (UTV-05, UTL-03). |
| UTT-06 | **Toujours traçable** — chaque fiche, chaque transition, chaque relation (§3.8). |
| UTT-07 | Le registre dit toujours l'état vrai : une fiche ne ment jamais sur son statut (fail closed : dans le doute, l'entrée n'est pas admise). |
| UTT-08 | Ces garanties sont **perpétuelles** — aucune extension ne peut les affaiblir. |

---

## §10 Mobile First

| Règle | Énoncé |
|---|---|
| UTMF-01 | **Le registre ignore les appareils** : un Token appartient au système — **jamais au Mobile, jamais au Desktop**. |
| UTMF-02 | Les déclinaisons d'appareils sont des Variants déclarées (§6) sous le même nom — jamais des enregistrements distincts. |
| UTMF-03 | Le Mobile First vit en aval : la première déclinaison de valeurs naît mobile (DTMF-01) — le registre n'en sait rien et n'a pas à le savoir. |
| UTMF-04 | Aucun Domain, Group ou Token « par appareil » n'est admissible (RSE-02 appliqué au registre). |

---

## §11 International By Design

| Règle | Énoncé |
|---|---|
| UTI-01 | **Un Token ne dépend jamais d'une langue** — aucun nom, aucune signification liés à une langue (GE-03). |
| UTI-02 | **Un Token ne dépend jamais d'un pays ni d'une devise** — aucun enregistrement « pour un marché » (GE-11, GE-12). |
| UTI-03 | **Un Token ne dépend jamais d'un fuseau ni d'une culture** — aucune métaphore locale dans les noms ni les significations (GE-09, GE-14). |
| UTI-04 | **Toutes les adaptations passent par les valeurs. Jamais par le Token** (DTI-02) : les Variants déclinent, l'enregistrement demeure. |
| UTI-05 | La Global Experience Foundation est opposable à toute admission (DTI-03, GE-15). |

---

## §12 Gouvernance

Table officielle des violations — **toutes devront devenir des balayages exécutables** dès la première vague d'implémentation :

| Règle | Violation détectable |
|---|---|
| UTG-01 | **Token sans propriétaire.** |
| UTG-02 | **Token sans origine** (règle amont manquante ou lien mort). |
| UTG-03 | **Token sans système** (hors des dix origines officielles du §5). |
| UTG-04 | **Token dupliqué** (nom ou signification — UTT-01/02/03). |
| UTG-05 | **Token renommé** (hors protocole déprécier + enregistrer — UTT-04). |
| UTG-06 | **Token sans historique** (trou de trace, transition anonyme). |
| UTG-07 | **Token sans statut** (hors cycle de vie du §8). |
| UTG-08 | **Token orphelin** (enregistré mais sans consommateur déclaré ni relation — signalé pour instruction : soit une dette d'implémentation, soit un candidat à dépréciation ; jamais ignoré). |

---

## §13 Extensibilité

| Règle | Énoncé |
|---|---|
| UTX-01 | **Flutter, Web, Desktop, Android, iOS, Wearables, Voice, Mixed Reality utilisent exactement le même registre. Jamais un registre spécifique** (DTX-01). |
| UTX-02 | Il n'existe qu'**un** registre — pour toutes les technologies, toutes les modalités, tous les temps. |
| UTX-03 | Une nouvelle technologie est un consommateur de plus — le registre ne la connaît pas (UTN-04) ; une nouvelle modalité consomme les mêmes enregistrements (DTX-03). |
| UTX-04 | Les dix piliers (§3), les six niveaux (§6), la convention d'identité (§7) et le cycle de vie (§8) sont l'invariant décennal ; aucune extension ne peut affaiblir la confiance (§9) ni l'International By Design (§11). |

---

## §14 Validation finale

Ce document répond à la condition **C-01** de l'audit P11.8A : le cadre d'autorité du registre est établi — l'énumération des fiches (l'admission effective des Tokens des dix origines) peut désormais s'instruire sous cette Constitution, avant toute matérialisation.

**Principe final** :

> **« Une implémentation peut disparaître. Le registre demeure.**
> **Parce que les technologies changent. Les significations, elles, restent. »**

---

*Gouvernance du document : toute modification est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation. En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables, puis le Design Tokens System (P11.8), puis ce registre.*
