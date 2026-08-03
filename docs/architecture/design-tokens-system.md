# DESIGN TOKENS SYSTEM

**Statut** : Référence officielle de tous les Tokens Mentora. Huitième descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md) — le point où le langage devient implémentable.
**Portée** : Architecture fonctionnelle uniquement. Aucune implémentation, aucun code, aucune valeur, aucune couleur, aucune taille, aucun pixel, aucune API, aucun package, aucune technologie. Ce document traduit **tous les systèmes P11 en langage universel** ; il ne dépend d'aucune technologie ; il est intemporel. Le Flutter Design Kit (P11.9) ne fera qu'implémenter ces Tokens.
**Préséance** : P9 → P10 → [Accessibility Foundation](accessibility-foundation.md) (**opposable**) → [Global Experience Foundation](global-experience-foundation.md) (**opposable**) → P11.0 → ce document (DSD-01 : il précise le pilier **Design Tokens**, il ne redéfinit rien). Il traduit — sans jamais les modifier ni redéfinir — le [Color System](color-system.md), le [Typography System](typography-system.md), le [Spacing System](spacing-system.md), l'[Elevation & Surface System](elevation-surface-system.md), l'[Iconography System](iconography-system.md), l'[Illustration System](illustration-system.md) et la [Component Library](component-library.md). **Seulement traduire.**
**Niveaux produits (DSD-02)** : le niveau **Tokens** de tous les systèmes amont — leur nomenclature officielle (§6, §7) ; les Implementations viendront de P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (le nom d'un Token porte la personnalité : précis, sobre, intemporel) et Documentation (chaque Token est traçable jusqu'à sa signification amont, §5).
**Continuité (MSD-02)** : le Token est la continuité même — la signification stable sous les valeurs qui changent, sur tout support, pour toujours.

---

## 1. Mission

**Un Token n'est jamais une valeur. Un Token est une signification officielle.**

Une valeur pourra évoluer. Le Token restera.

**Principe fondateur** :

> **« Une valeur change. Un Token demeure. »**

**Mission en une phrase** : nommer chaque signification des systèmes P11 d'un nom unique, stable et universel — le contrat que toute implémentation matérialisera sans jamais le posséder.

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| DTV-01 | **Une valeur ne possède jamais de signification.** Une valeur nue est muette — elle ne dit ni pourquoi, ni où, ni quand. |
| DTV-02 | **Un Token possède toujours une signification** : il cite le rôle, la loi ou le contrat amont qu'il nomme (§5) — un Token sans signification n'existe pas. |
| DTV-03 | **Deux valeurs différentes peuvent implémenter le même Token** : par thème, par contexte, par contraste renforcé, par appareil — la signification demeure, les valeurs varient (CSV-01, TSV-02). |
| DTV-04 | **Aucune valeur n'existe hors Token** (DSG-04) : toute valeur concrète du produit est la matérialisation d'un Token — une valeur orpheline est une violation d'architecture. |

---

## 3. Les onze piliers

Onze piliers. Tout Token appartient à exactement un pilier. *(Le onzième — Appearance Tokens — a été ajouté par révision explicite post-audit P11.8A, avant l'ouverture de P11.9.)*

### 3.1 Identity Tokens

| | |
|---|---|
| **Mission** | Nommer l'identité — la présence de Mentora rendue consommable. |
| **Responsabilités** | Produire les Tokens des rôles identitaires (Primary, Secondary, Supporting du Color System ; la voix écrite de l'Identity Typography) — la signature du produit, nommée une fois. |
| **Frontières** | L'identité est définie par les systèmes amont ; le pilier la nomme, il ne la dessine pas. |
| **Ce qu'il produit** | la nomenclature des rôles identitaires. |
| **Ce qu'il ne possède jamais** | une valeur de marque ; un choix esthétique. |

### 3.2 Color Tokens

| | |
|---|---|
| **Mission** | Nommer les vingt-sept rôles sémantiques du Color System — chacun, exactement. |
| **Responsabilités** | Produire un Token par rôle (§4 du Color System) et par liaison d'état (§5) ; porter les jeux de valeurs par thème (clair, sombre, contraste renforcé) sous le même nom (DTV-03). |
| **Frontières** | Les rôles et leurs significations appartiennent au Color System (CSG-03 : une valeur ne crée jamais une signification) ; les contrastes exigés sont opposables (CSA-03). |
| **Ce qu'il produit** | la nomenclature rôle → valeurs par thème. |
| **Ce qu'il ne possède jamais** | un rôle nouveau ; une couleur sans rôle (CSV-02). |

### 3.3 Typography Tokens

| | |
|---|---|
| **Mission** | Nommer les vingt-sept rôles typographiques du Typography System. |
| **Responsabilités** | Produire un Token par rôle (§4 du Typography System) ; porter l'adaptabilité (taille ajustable sans casse de hiérarchie — TSA-06) sous le même nom. |
| **Frontières** | Les rôles et la hiérarchie appartiennent au Typography System (TSG-03 : une police ne crée jamais une signification). |
| **Ce qu'il produit** | la nomenclature rôle → valeurs typographiques. |
| **Ce qu'il ne possède jamais** | un rôle nouveau ; un texte hors rôle (TSV-03). |

### 3.4 Spacing Tokens

| | |
|---|---|
| **Mission** | Nommer les relations spatiales du Spacing System — les lois de respiration, mesurées. |
| **Responsabilités** | Produire les Tokens des relations officielles (lié/distinct, principal/secondaire, libre/protégé — niveau Relationship du Spacing) et des cadences du rythme. |
| **Frontières** | Les lois spatiales appartiennent au Spacing System (SPG-03 : une valeur ne crée jamais une loi) ; les espaces d'accessibilité sont opposables (Accessibility Space). |
| **Ce qu'il produit** | la nomenclature relation → mesures. |
| **Ce qu'il ne possède jamais** | une loi nouvelle ; un espacement local (SPG-01). |

### 3.5 Elevation Tokens

| | |
|---|---|
| **Mission** | Nommer les significations d'élévation — l'aparté, la décision, l'immersion, le signalement. |
| **Responsabilités** | Produire un Token par signification d'être au-dessus (§3.3 de l'Elevation & Surface System) ; jamais un Token de « hauteur » sans signification. |
| **Frontières** | Les significations appartiennent à l'Elevation & Surface System ; l'interdit d'empilement demeure au contrat. |
| **Ce qu'il produit** | la nomenclature signification → expression de profondeur. |
| **Ce qu'il ne possède jamais** | une couche nouvelle ; une élévation décorative. |

### 3.6 Surface Tokens

| | |
|---|---|
| **Mission** | Nommer les responsabilités de surface — les contenants, les fonds, les enveloppes. |
| **Responsabilités** | Produire les Tokens des surfaces d'intention (les enveloppes des niveaux de composition) et des rôles d'environnement (Background, Surface, Outline, Divider du Color System). |
| **Frontières** | Les responsabilités appartiennent à l'Elevation & Surface System ; le calme de la scène est un invariant (DPV-05). |
| **Ce qu'il produit** | la nomenclature surface → expression. |
| **Ce qu'il ne possède jamais** | une surface décorative ; un contenant à double responsabilité. |

### 3.7 Component Tokens

| | |
|---|---|
| **Mission** | Nommer ce que chaque contrat de la Component Library consomme — l'assemblage nommé. |
| **Responsabilités** | Produire les Tokens de contrat : pour chaque contrat du catalogue, la liste nommée de ce qu'il consomme (ses rôles, ses relations, ses surfaces, ses états) — la recette officielle, sans valeur propre. |
| **Frontières** | Les contrats appartiennent à la Component Library (le contrat fait foi — CLC-03) ; un Token de composant référence les Tokens des autres piliers, il n'en crée pas. |
| **Ce qu'il produit** | la nomenclature contrat → composition de Tokens. |
| **Ce qu'il ne possède jamais** | un contrat nouveau ; une valeur en propre (il compose, il ne définit pas). |

### 3.8 Interaction Tokens

| | |
|---|---|
| **Mission** | Nommer les exigences d'interaction — cibles, distances de sécurité, temps de réponse. |
| **Responsabilités** | Produire les Tokens des exigences publiées : la cible atteignable (Interaction Space), la distance de sécurité des actes critiques (IPR), l'immédiateté de l'accusé (IF-02) — des exigences nommées, jamais des comportements. |
| **Frontières** | Les types et protections appartiennent à l'Interaction Foundation ; les seuils d'accessibilité sont opposables. |
| **Ce qu'il produit** | la nomenclature exigence → seuils. |
| **Ce qu'il ne possède jamais** | un niveau de protection ; un comportement. |

### 3.9 Motion Tokens

| | |
|---|---|
| **Mission** | Nommer les intentions du mouvement — les huit, exactement. |
| **Responsabilités** | Produire les Tokens des intentions officielles du Motion Foundation (expliquer, guider, rassurer, préserver, attirer, accompagner, confirmer, montrer la continuité) : chaque intention reçoit son expression temporelle nommée — sous les contraintes perpétuelles de temps (MT-01 → MT-04). |
| **Frontières** | Les intentions appartiennent au Motion Foundation (MI-02 : une intention nouvelle exige sa révision) ; jamais un Token de durée sans intention. |
| **Ce qu'il produit** | la nomenclature intention → expression de mouvement. |
| **Ce qu'il ne possède jamais** | une neuvième intention ; une durée décorative. |

### 3.10 Future Tokens

| | |
|---|---|
| **Mission** | Accueillir les significations de demain — par le protocole, jamais par l'improvisation. |
| **Responsabilités** | Porter le protocole d'ajout : une nouvelle signification naît dans son système amont (révision), puis reçoit son Token ici (révision de ce document), puis ses valeurs — **dans cet ordre, toujours** (DSL-01). |
| **Frontières** | Ce pilier n'a aucun Token en propre : il est la porte d'entrée réglementée des autres. |
| **Ce qu'il produit** | le protocole d'extension de la nomenclature. |
| **Ce qu'il ne possède jamais** | un Token en réserve ; une signification spéculative ; un raccourci (une valeur d'abord, un sens ensuite — jamais). |

### 3.11 Appearance Tokens

| | |
|---|---|
| **Mission** | Nommer les préférences d'apparence de l'expert — le pont entre l'Experience Personalization (Global Experience Foundation §3.13, §5) et sa matérialisation. |
| **Responsabilités** | Produire les Tokens des sept préférences officielles : **Theme** (Light/Dark/System — des jeux de valeurs sous les mêmes noms sémantiques, DTV-03), **Accent** (Mentora Emerald officiel ; les accents futurs = des jeux de valeurs des rôles identitaires, jamais un Design System modifié), **Density** (Compact/Standard/Comfortable — déclinaisons des lois du Spacing), **Contrast** (Standard/High — variantes CSA-04), **Motion** (Full/Reduced/None — l'expression s'atténue, l'intention demeure), **Font Scale** (Small→Extra Large — TSA-06 opposable), **Reading Comfort** (extensions futures sans modification d'architecture). **Purement sémantiques — aucune valeur technique ici** ; la nomenclature effective relève du registre (C-01 de l'audit). |
| **Frontières** | Les règles appartiennent à la Global Experience Foundation (GEA-01→03, GE-16→19) ; le stockage à l'Account Platform ; **une préférence est toujours un jeu de valeurs sous des noms stables — jamais une signification nouvelle** (GE-18, GEA-01). |
| **Ce qu'il produit** | la nomenclature préférence → jeux de valeurs. |
| **Ce qu'il ne possède jamais** | une préférence nouvelle (révision GE d'abord) ; une vérité métier (GE-19) ; une logique de bascule. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Design Tokens System PEUT |
|---|---|
| DTP-01 | Nommer chaque signification des systèmes P11. |
| DTP-02 | Organiser la nomenclature en piliers (§3) et en niveaux (§6). |
| DTP-03 | Définir la convention officielle de nommage (§7). |
| DTP-04 | Porter les jeux de valeurs multiples sous un même nom (thèmes, contextes, contrastes — DTV-03). |
| DTP-05 | Définir la traçabilité Token → signification amont (§5). |
| DTP-06 | Définir le protocole d'ajout, de dépréciation et de retrait des Tokens. |
| DTP-07 | Définir les exigences que toute implémentation devra satisfaire (§13). |

### 4.2 Interdites

| Règle | Les Tokens NE PEUVENT JAMAIS |
|---|---|
| DTN-01 | Créer une règle. |
| DTN-02 | Créer une couleur — les rôles appartiennent au Color System. |
| DTN-03 | Créer une animation — les intentions appartiennent au Motion Foundation. |
| DTN-04 | Créer un composant — les contrats appartiennent à la Component Library. |
| DTN-05 | Modifier ou redéfinir une signification amont — **ils traduisent uniquement** (DSM-02). |
| DTN-06 | Posséder une technologie — aucun format, aucun outil, aucune plateforme technique dans le contrat. |
| DTN-07 | Porter une logique — un Token nomme, il ne calcule ni ne décide jamais. |
| DTN-08 | Exister en double — deux Tokens pour la même signification sont une violation (l'équivalent de CFU-02). |

---

## 5. Traduction des systèmes

La table officielle : comment chaque système devient Tokens. **Chaque traduction cite ses règles officielles — et ne les modifie jamais** (DSM-01, DSM-02).

| Système amont | Ce qui devient Token | Règles citées |
|---|---|---|
| Color System | les 27 rôles sémantiques et les liaisons d'états | CSR-01 (un rôle par usage), CSE-01 (jamais une couleur d'état inventée), CSG-03/CSG-04 (les valeurs évoluent, le langage est stable), CSA-03/04 (contrastes et variantes opposables) |
| Typography System | les 27 rôles de lecture et la hiérarchie | TSR-01, TSH-01→04 (hiérarchie stricte, survivante), TSA-06 (adaptable sans casse), TSG-03 |
| Spacing System | les relations spatiales et les cadences | SPV-02 (le rythme est système), niveau Relationship (échelles relatives), SPG-01/03 |
| Elevation & Surface System | les significations d'élévation et les responsabilités de surface | ESV-02/03 (une couche = une signification publiée), ESE-01 (un état ne déplace pas), ESMF-03 (jamais plus de couches) |
| Iconography System | le registre signification → signe (chaque signification, son identifiant, son tracé de référence) | ICV-02, ICF-01 (un signe par famille), ICA (l'accompagnement), ICM-01 |
| Illustration System | le registre situation → image (chaque situation, sa référence) et les narrations (niveau Narrative) | ILV-04 (jamais sans situation), ILE (apparition/disparition), ILF-01 |
| Component Library | les compositions de contrat (ce que chaque contrat consomme) et les exigences par état | CLC-01→03 (le contrat fait foi), CLE-01/02 (états dans les rôles officiels), CLB (comportements cités) |

| Règle | Énoncé |
|---|---|
| DTS-01 | Toute entrée de la nomenclature cite sa règle amont ; une entrée sans origine est rejetée (DSM-01). |
| DTS-02 | Un manque découvert en traduisant remonte en révision du système amont — jamais comblé ici (DSM-03, GE-15). |

---

## 6. Les niveaux

Six niveaux officiels — la production descend toujours (DSL-01) :

| Niveau | Mission | Responsabilité | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Identity** | la nomenclature de la personnalité | nommer ce qui signe Mentora | les Tokens identitaires | une valeur de marque ; un style |
| **Semantic** | la nomenclature des significations | nommer chaque rôle, loi, signification et situation des systèmes amont | les Tokens sémantiques — le cœur du contrat | une valeur ; une technologie |
| **System** | la nomenclature des jeux | organiser les jeux de valeurs (thèmes, contrastes, contextes) sous les noms sémantiques | les déclinaisons nommées d'un même Token | un nom nouveau par thème (le nom est unique, les jeux varient) |
| **Component** | la nomenclature des contrats | nommer ce que chaque contrat consomme (recettes) | les Tokens de composition | une valeur propre ; un contrat nouveau |
| **Platform** | la nomenclature par famille d'appareils | porter les adaptations officielles (Responsive : les six niveaux d'adaptation) sous les mêmes noms | les déclinaisons par contexte d'appareil | un Token par appareil ; une exclusivité |
| **Implementation** | la matérialisation | (produit par P11.9 et suivants) consommer fidèlement la nomenclature | le code des kits, la correspondance Token → technologie | un Token nouveau ; un renommage ; un écart |

---

## 7. Convention officielle de nommage

La philosophie — sans écrire de Tokens techniques :

| Règle | Énoncé |
|---|---|
| DTC-01 | **Un Token décrit un rôle. Jamais une valeur.** Le nom dit à quoi ça sert — jamais ce que ça vaut. |
| DTC-02 | **Jamais une couleur dans un nom** : un nom qui contient une teinte meurt avec elle. |
| DTC-03 | **Jamais une taille dans un nom** : un nom qui contient une grandeur ment dès qu'elle change. |
| DTC-04 | **Jamais une technologie dans un nom** : le nom survit aux frameworks (DST-06). |
| DTC-05 | Le nom se construit du général au particulier : le pilier, puis la signification, puis la déclinaison — lisible par un humain, stable pour une machine. |
| DTC-06 | Le nom est unique et permanent : renommer est une décision de gouvernance avec dépréciation tracée — jamais un correctif. |
| DTC-07 | **Le nom doit survivre pendant dix ans** : tout nom se juge à cette aune avant d'entrer à la nomenclature. |

---

## 8. Confiance

| Règle | Les Tokens |
|---|---|
| DTT-01 | **ne mentent jamais** : le nom dit exactement la signification amont — ni plus, ni moins. |
| DTT-02 | **ne changent jamais de signification** : un Token qui voudrait dire autre chose est un Token nouveau (et l'ancien se déprécie, tracé). |
| DTT-03 | **restent stables** : la nomenclature est une promesse faite à toutes les implémentations. |
| DTT-04 | **restent intemporels** (DST-05) : aucune mode dans les noms ni dans les significations. |
| DTT-05 | **une implémentation peut évoluer. Jamais le contrat** : les valeurs, les formats et les outils changent librement sous le même nom. |
| DTT-06 | ne cachent jamais une signification : toute signification amont a son Token — un manque est une dette déclarée (DSV-02). |
| DTT-07 | ne servent jamais deux maîtres : un Token, une signification, une origine (DTN-08). |

Ces principes sont **perpétuels**.

---

## 9. Mobile First

| Règle | Énoncé |
|---|---|
| DTMF-01 | **Tout Token naît pour Mobile** : sa première déclinaison de valeurs est mobile (DSMF-01). |
| DTMF-02 | **Puis s'adapte. Jamais l'inverse** : les déclinaisons Platform (§6) partent du mobile (RSMF-02). |
| DTMF-03 | Un Token dont la déclinaison mobile échoue est invalide partout (DSMF-03). |
| DTMF-04 | Aucun Token réservé aux grands écrans : une signification vaut partout ou n'existe pas (RSE-02). |

---

## 10. International By Design

Les Tokens survivent au monde entier **sans jamais changer de nom** :

| Ce qui varie | Ce qui ne varie jamais |
|---|---|
| les langues (les 6 notions — GE-13) | le nom du Token et sa signification |
| la direction (LTR/RTL — GE-07) | les noms se pensent en début/fin logiques — jamais un nom « gauche/droite » |
| les devises (les 4 notions — GE-13) | les Tokens de format monétaire nomment des rôles de présentation — jamais une devise |
| les formats (nombres, dates — GE-10) | les Tokens de format nomment des conventions configurables — jamais un format codé |
| les pays (GE-12) | aucun Token par pays : un pays est une configuration, jamais une nomenclature |
| les cultures (GE-09) | aucun nom culturel, aucune métaphore locale dans la nomenclature |
| les fuseaux horaires (GE-14) | les Tokens temporels nomment des rôles d'affichage — la vérité reste canonique (GE-05) |

| Règle | Énoncé |
|---|---|
| DTI-01 | La nomenclature est mondiale : un seul jeu de noms pour tous les pays, toutes les langues, toutes les directions. |
| DTI-02 | Les variations internationales sont des **jeux de valeurs** (niveau System/Platform) — jamais des noms nouveaux. |
| DTI-03 | La Global Experience Foundation est opposable à toute entrée de la nomenclature (GE-15). |

---

## 11. Gouvernance

| Règle | Énoncé |
|---|---|
| DTG-01 | **Aucune valeur brute** hors Token. |
| DTG-02 | **Aucune couleur brute** hors Token. |
| DTG-03 | **Aucune taille brute** hors Token. |
| DTG-04 | **Aucune durée brute** hors Token. |
| DTG-05 | **Aucune opacité brute** hors Token. |
| DTG-06 | **Aucun rayon brut** hors Token. |
| DTG-07 | **Aucune police brute** hors Token. |
| DTG-08 | **Toutes ces violations devront devenir détectables automatiquement** : dès la première vague d'implémentation, des balayages exécutables traquent toute valeur en dur — même discipline que le reste de l'architecture Enterprise. |

---

## 12. Extensibilité

| Règle | Énoncé |
|---|---|
| DTX-01 | **Flutter, Web, Desktop, Android, iOS, Wearables, Voice, Mixed Reality utiliseront exactement les mêmes Tokens. Seule leur matérialisation changera.** |
| DTX-02 | Une nouvelle technologie est une Implementation de plus (§6) — la nomenclature l'ignore (DTN-06). |
| DTX-03 | Une nouvelle modalité (Voice : les significations s'énoncent ; Mixed Reality : elles s'espacent) consomme les mêmes Tokens sémantiques — la signification survit à la forme (les niveaux Narrative et Semantic amont le garantissent). |
| DTX-04 | Les onze piliers (§3), les six niveaux (§6) et la convention de nommage (§7) sont l'invariant décennal *(révisé post-audit P11.8A : +Appearance Tokens)* ; aucune extension ne peut affaiblir la confiance (§8) ni l'International By Design (§10). |

---

## 13. Descendance

**Le Flutter Design Kit (P11.9) sera uniquement une implémentation.**

| Règle | Énoncé |
|---|---|
| DTD-01 | **Il ne créera aucun Token.** |
| DTD-02 | **Il ne modifiera aucun Token.** |
| DTD-03 | **Il ne renommera aucun Token.** |
| DTD-04 | **Il matérialisera uniquement le contrat** : chaque Token de la nomenclature, fidèlement, dans sa technologie — un écart est un défaut de l'implémentation, jamais du contrat (CLC-03 généralisé). |
| DTD-05 | Toute implémentation future (Web, Desktop, autres) entre sous les mêmes règles DTD-01 → DTD-04. |
| DTD-06 | *(révision post-audit P11.8A)* **Toute préférence utilisateur sera implémentée exclusivement à travers les Appearance Tokens (§3.11). Aucune logique d'implémentation ne contournera le Design System.** |

---

## 14. Gouvernance du document

- Ce document est la **référence officielle** de tous les Tokens Mentora — huitième descendant du Design System, traduisant le pilier **Design Tokens**. Il rend impossible toute implémentation incohérente : ce qui n'est pas dans la nomenclature n'existe pas ; ce qui y est ne se matérialise que fidèlement.
- **Conformité aux fondations opposables** : l'Accessibility Foundation est servie par les contraintes opposables portées dans chaque pilier (contrastes CSA, espaces d'interaction, adaptabilité TSA-06 — les seuils nommés ici, opposables partout) ; la Global Experience Foundation est servie par la section International By Design (§10 — la nomenclature mondiale, unique, sans nom culturel ni local) et opposable à toute entrée (DTI-03, GE-15).
- Toute vague d'implémentation cite le pilier, le niveau et les règles (DTV/DTP/DTN/DTS/DTC/DTT/DTMF/DTI/DTG/DTX/DTD) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables (Accessibility, Global Experience), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md) et les systèmes amont qu'il traduit, puis ce document (DSD-01).
