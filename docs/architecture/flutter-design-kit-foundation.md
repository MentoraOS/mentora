# FLUTTER DESIGN KIT FOUNDATION

**Statut** : L'architecture officielle du Flutter Design Kit — **la première implémentation autorisée du [Universal Token Registry](universal-token-registry.md)**. Ouvre l'implémentation du Design System après satisfaction complète de la condition C-01 (Constitution P11.9A + [Catalogue](token-registry-catalog.md) P11.9B — 172 Tokens admis).
**Portée** : Architecture uniquement. Aucun widget, aucun ThemeData, aucun ColorScheme, aucun code, aucune API, aucun package, aucun exemple Dart, aucune implémentation, aucun composant métier. Ce document définit **comment** le Kit matérialisera — jamais **quoi** (le quoi appartient au registre).
**Préséance** : P9 → P10 → opposables (Accessibility, Global Experience) → Experience Preferences Foundation → P11.0 → Design Tokens System (P11.8, dont **DTD-01→06 s'imposent intégralement à ce Kit**) → Universal Token Registry (P11.9A) → Token Registry Catalog (P11.9B) → **ce document**. Il ne modifie aucun document existant.
**Continuité (MSD-02)** : le Kit matérialise la continuité définie en amont — mêmes contrats, mêmes états, mêmes reprises ; il n'y ajoute rien, il n'en retire rien.

---

## §1 Mission

**Principe fondateur** :

> **« Flutter n'invente jamais. Flutter matérialise. »**

Le Flutter Design Kit est la **première implémentation officielle du Design System Mentora**.

**Il ne définit rien. Il applique tout** : chaque Token du catalogue, chaque contrat de la bibliothèque, chaque loi des systèmes — matérialisés fidèlement, sous DTD-01→06.

---

## §2 Vision

| Règle | Énoncé |
|---|---|
| FDV-01 | **Flutter est une matérialisation** — un rendu du contrat dans une technologie, rien de plus. |
| FDV-02 | **Le Design System reste l'autorité** : le Kit obéit, il ne négocie pas. |
| FDV-03 | **Les Tokens restent la seule source** : tout ce que le Kit rend provient d'un Token admis au catalogue (TRC-07). |
| FDV-04 | **Flutter ne connaît jamais les significations** : le sens appartient aux systèmes ; le Kit reçoit des noms et rend des valeurs. |
| FDV-05 | **Flutter reçoit uniquement des contrats** — jamais une intention à interpréter, jamais un choix à faire (CLC-01 : le contrat précède toute matérialisation). |
| FDV-06 | **Toute divergence est un défaut Flutter** : un écart entre le rendu et le contrat se corrige côté Kit — le contrat fait foi, toujours (CLC-03, DTD-04). |

---

## §3 Les douze piliers

Douze piliers. Toute règle du Kit appartient à exactement un pilier.

### 3.1 Design Kit Identity

| | |
|---|---|
| **Mission** | Faire que le Kit soit reconnaissable comme LA matérialisation officielle — unique, complète, fidèle. |
| **Responsabilités** | Tenir l'unicité : un seul Kit officiel pour Flutter ; sa complétude (tout Token admis a sa matérialisation ou une dette déclarée) ; sa fidélité (FDV-06). |
| **Frontières** | L'identité du produit appartient au pilier Identity du Design System ; le Kit la porte, il ne la possède pas. |
| **Ce qu'il matérialise** | l'existence même du contrat dans la technologie : le point d'entrée unique de toute interface Mentora. |
| **Ce qu'il ne possède jamais** | un second kit ; une version parallèle ; une identité propre. |

### 3.2 Token Consumption

| | |
|---|---|
| **Mission** | Faire que le Kit consomme les Tokens — exclusivement, intégralement, fidèlement. |
| **Responsabilités** | Tenir le canal unique (§8) : toute valeur rendue provient d'un Token du catalogue ; la correspondance nom → matérialisation est totale et vérifiable ; aucune valeur en dur (DTG-01→07). |
| **Frontières** | Le Kit consomme ; il ne crée, ne modifie, ne renomme jamais (DTD-01→03). |
| **Ce qu'il matérialise** | la correspondance officielle Token → rendu. |
| **Ce qu'il ne possède jamais** | une valeur orpheline ; un raccourci hors registre (FDG-09). |

### 3.3 Theme Architecture

| | |
|---|---|
| **Mission** | Matérialiser les jeux de valeurs — Light, Dark, System, contrastes — sous les mêmes noms. |
| **Responsabilités** | Porter l'architecture des thèmes : un thème est **un jeu de valeurs par Token** (DTV-03, GE-18) ; changer de thème ne change jamais un nom ni une signification ; la bascule est instantanée et complète. |
| **Frontières** | Les thèmes existants et futurs sont déclarés au niveau Appearance du catalogue ; le Kit les rend, il n'en invente pas. |
| **Ce qu'il matérialise** | les Variants de thème du registre. |
| **Ce qu'il ne possède jamais** | un thème local ; une couleur sémantique modifiée par thème (GE-18). |

### 3.4 Appearance Engine

| | |
|---|---|
| **Mission** | Matérialiser les 7 préférences d'apparence admises (§D8 du catalogue) — sous le cycle des préférences. |
| **Responsabilités** | Rendre Theme, Accent (Mentora Emerald officiel), Density, Font Scale, Motion Preference, Contrast, Reading Comfort — **exclusivement à travers les Appearance Tokens** (DTD-06, EP-05/06) ; appliquer la résolution officielle (§4.5 de l'Experience Preferences Foundation) sans jamais la décider. |
| **Frontières** | Les règles appartiennent à la GE Foundation ; le stockage à l'Account Platform ; le Kit applique la valeur résolue. |
| **Ce qu'il matérialise** | l'effet visuel de chaque préférence, instantané et réversible. |
| **Ce qu'il ne possède jamais** | une préférence propre ; une logique de résolution ; un contournement (FDG-09). |

### 3.5 Component Engine

| | |
|---|---|
| **Mission** | Matérialiser les contrats de la Component Library — les 19 compositions admises et leurs contrats à venir. |
| **Responsabilités** | Rendre chaque contrat : son intention, ses 7 comportements (CLB), ses 9 états (CLE), sa composition de Tokens (relation « compose » du catalogue) — **le développeur matérialise, il n'invente rien** (CLC). |
| **Frontières** | Les contrats appartiennent à la bibliothèque ; un besoin nouveau remonte au contrat — jamais un composant local (FDG-10). |
| **Ce qu'il matérialise** | la bibliothèque vivante des composants Mentora. |
| **Ce qu'il ne possède jamais** | un composant hors catalogue ; un fork ; un état inventé. |

### 3.6 Layout Engine

| | |
|---|---|
| **Mission** | Matérialiser l'espace et les surfaces — les lois du Spacing et de l'Elevation & Surface. |
| **Responsabilités** | Rendre les relations spatiales (§D3), les significations d'élévation et contenants (§D4), les six niveaux d'adaptation du Responsive (RSL) — la disposition change, la structure jamais. |
| **Frontières** | Les lois appartiennent aux systèmes ; les niveaux d'adaptation au Responsive Foundation ; le Kit dispose, il ne réordonne jamais contre les priorités publiées. |
| **Ce qu'il matérialise** | la respiration, les contenants et les dispositions officielles. |
| **Ce qu'il ne possède jamais** | un espacement brut (FDG-03) ; une couche locale ; un breakpoint signifiant. |

### 3.7 Motion Engine

| | |
|---|---|
| **Mission** | Matérialiser les huit intentions du mouvement — sous les contraintes de temps perpétuelles. |
| **Responsabilités** | Rendre chaque intention admise (§D10) avec son expression, déclinée par Motion Preference (Full/Reduced/None) ; jamais un mouvement sans intention (MI-01), jamais un retard d'action (MT-03). |
| **Frontières** | Les intentions appartiennent au Motion Foundation ; les durées concrètes sont des Variants sous les Tokens Motion. |
| **Ce qu'il matérialise** | le mouvement qui explique — et son atténuation respectueuse. |
| **Ce qu'il ne possède jamais** | une animation brute (FDG-04) ; une durée brute (FDG-05) ; une neuvième intention. |

### 3.8 Accessibility Engine

| | |
|---|---|
| **Mission** | Matérialiser l'accessibilité opposable — les seuils, les alternatives, les six niveaux d'accès. |
| **Responsabilités** | Rendre les exigences admises (§D9 : cible atteignable, distance de sécurité, immédiateté, temps suffisant) et les contraintes des origines (contrastes, adaptabilité TSA-06, équivalents textuels) ; garantir Percevoir → Reprendre (AFL) sur chaque composant matérialisé. |
| **Frontières** | Les exigences appartiennent à l'Accessibility Foundation (opposable — AFR-02) ; le Kit les rend mesurables et les mesure. |
| **Ce qu'il matérialise** | l'accessibilité vérifiable — le passage du contractuel au mesurable (maturité 3 → 4 de l'audit). |
| **Ce qu'il ne possède jamais** | un seuil propre ; un arbitrage contre l'accessibilité ; un mode accessible séparé (AFV-01). |

### 3.9 International Engine

| | |
|---|---|
| **Mission** | Matérialiser l'International By Design — le monde entier par les moteurs, jamais en dur. |
| **Responsabilités** | Rendre les configurations (GE-10) : les six langues, les quatre devises, fuseau, calendrier, formats, direction — **tous par les moteurs officiels (§7), jamais directement** (FDI) ; les données restent canoniques, l'affichage suit les préférences résolues. |
| **Frontières** | Les notions appartiennent à la GE Foundation (opposable) ; les préférences au cycle EP ; le Kit rend la présentation. |
| **Ce qu'il matérialise** | le même Mentora à Bamako, Séoul et Copenhague — par configuration. |
| **Ce qu'il ne possède jamais** | une chaîne codée en dur (GEG-04) ; un format figé ; une hypothèse de pays, de langue ou de devise (FDG). |

### 3.10 Platform Adaptation

| | |
|---|---|
| **Mission** | Matérialiser les contextes d'appareils — une architecture, des rendus. |
| **Responsabilités** | Rendre les dix contextes du Responsive (téléphone la référence, pliable, tablette, desktop, web, TV, wearable…) par les six niveaux d'adaptation (RSL) — **jamais une architecture spécifique** (FDX-02). |
| **Frontières** | Les contextes et invariants appartiennent au Responsive Foundation ; le Kit adapte la présentation, jamais l'expérience (RSV-04). |
| **Ce qu'il matérialise** | les dispositions par contexte, sous les mêmes contrats. |
| **Ce qu'il ne possède jamais** | un parcours par appareil ; une capacité hors Mobile (RSE-02) ; un kit par plateforme. |

### 3.11 Developer Experience

| | |
|---|---|
| **Mission** | Faire que la voie officielle soit la voie facile — le contrat plus simple que le contournement. |
| **Responsabilités** | Organiser le Kit pour que consommer un Token soit l'évidence et qu'une valeur brute soit une friction ; documenter chaque matérialisation avec son Token et sa règle d'origine (Documentation transversale) ; livrer les balayages avec le code (S-03, FDG). |
| **Frontières** | L'expérience développeur sert la fidélité ; elle ne crée jamais un raccourci qui affaiblit le contrat. |
| **Ce qu'il matérialise** | la discipline rendue naturelle : le chemin conforme est le chemin court. |
| **Ce qu'il ne possède jamais** | une API de contournement « pour aller vite » ; une exception de confort. |

### 3.12 Future Implementations

| | |
|---|---|
| **Mission** | Préparer les implémentations suivantes — en restant remplaçable. |
| **Responsabilités** | Tenir la séparation contrat/rendu si nette que Web, Desktop natif ou toute technologie future entre par le même chemin (DTD-05) ; le Kit Flutter est le premier, jamais le modèle — **le registre est le modèle**. |
| **Frontières** | Les implémentations futures entrent sous DTD-01→04 ; ce pilier n'anticipe aucune technologie. |
| **Ce qu'il matérialise** | la preuve par l'exemple qu'une implémentation est un consommateur — pas une autorité. |
| **Ce qu'il ne possède jamais** | une exclusivité ; un privilège de premier arrivé ; une dépendance du contrat envers Flutter (DST-06). |

---

## §4 Responsabilités

### 4.1 Autorisées

| Règle | Le Flutter Design Kit PEUT |
|---|---|
| FDP-01 | **Consommer** — les Tokens du catalogue, exclusivement. |
| FDP-02 | **Matérialiser** — chaque contrat, fidèlement. |
| FDP-03 | **Assembler** — les composants selon les niveaux de composition (CFL). |
| FDP-04 | **Composer** — les patterns et surfaces à partir des contrats. |
| FDP-05 | **Injecter** — les valeurs résolues (thème, préférences, contexte) dans les rendus. |
| FDP-06 | **Adapter** — la présentation par contexte d'appareil (RSL). |
| FDP-07 | Mesurer — l'accessibilité et la fidélité de ses rendus (Accessibility Engine). |
| FDP-08 | Livrer ses balayages — avec chaque vague de code (S-03). |

### 4.2 Interdites

| Règle | Le Flutter Design Kit NE PEUT JAMAIS |
|---|---|
| FDN-01 | **Créer** — ni Token, ni règle, ni signification, ni contrat (DTD-01). |
| FDN-02 | **Décider** — ni priorité, ni protection, ni résolution de préférence. |
| FDN-03 | **Renommer** (DTD-03). |
| FDN-04 | **Traduire** — la traduction appartient à P11.8 ; le Kit matérialise l'aval. |
| FDN-05 | **Calculer** — aucune logique métier, aucune dérivation de signification. |
| FDN-06 | Contourner le registre — aucune valeur hors Token (DTD-06, FDG-09). |
| FDN-07 | Diverger — un écart au contrat est un défaut du Kit (FDV-06). |
| FDN-08 | Faire autorité — pour quiconque, jamais : le Kit est un consommateur. |

---

## §5 Relations officielles

```
Universal Token Registry        (l'autorité — P11.9A)
        ↓
Token Registry Catalog          (les 172 admissions — P11.9B)
        ↓
Design Tokens                   (le contrat de traduction — P11.8)
        ↓
Flutter Design Kit              (la matérialisation — ce document)
        ↓
Flutter Components              (les contrats rendus)
        ↓
Mentora Screens                 (les surfaces et parcours des plateformes)
```

| Règle | Énoncé |
|---|---|
| FDR-01 | **Le flux est strictement descendant. Jamais l'inverse** : un écran ne parle jamais aux Tokens directement (il consomme des composants), un composant ne parle jamais au registre (il consomme des Tokens matérialisés), rien en aval ne remonte jamais une définition. |
| FDR-02 | Tout besoin découvert en aval remonte par la gouvernance documentaire (système d'origine → registre → catalogue) — jamais par le code. |

---

## §6 Architecture officielle

| Couche | Mission | Responsabilité | Frontières |
|---|---|---|---|
| **Foundation** | le socle du Kit : l'entrée unique, la discipline | établir le point d'accès officiel et les règles de consommation | ne contient aucun rendu ; aucune valeur |
| **Theme** | les jeux de valeurs | porter les thèmes et contrastes comme Variants sous noms stables | jamais une signification ; jamais un nom nouveau |
| **Tokens** | la correspondance | matérialiser chaque Token admis vers sa forme technique | la seule couche qui connaisse les valeurs ; invisible au-dessus |
| **Components** | les contrats rendus | matérialiser les compositions du catalogue avec leurs états et comportements | jamais un composant hors contrat ; jamais une valeur directe |
| **Patterns** | les assemblages éprouvés | rendre les réponses récurrentes (carte d'intention, confirmation, attente) | jamais un pattern contraire à une fondation |
| **Features** | les surfaces des plateformes | composer les surfaces et parcours des six plateformes à partir des patterns et composants | jamais une logique métier dans le rendu ; les plateformes publient, les features affichent |
| **Applications** | l'app assemblée | assembler les features en produit ; porter la navigation officielle | jamais un raccourci inter-couches |

La construction descend (Foundation → Applications) ; **chaque couche ne consomme que la couche immédiatement inférieure** (l'équivalent de CFL-02/DSL-02 pour l'implémentation).

---

## §7 Les huit moteurs

Chaque moteur **consomme des Tokens. Jamais autre chose.**

| Moteur | Ce qu'il consomme (catalogue) | Ce qu'il rend |
|---|---|---|
| **Theme Engine** | les Variants de thème (Color, Scène — §D1, §D4) | la bascule Light/Dark/System, complète et instantanée |
| **Appearance Engine** | les 7 préférences (§D8) | l'effet de chaque préférence résolue |
| **Typography Engine** | les 27 rôles (§D2) | la hiérarchie de lecture, adaptable sans casse |
| **Spacing Engine** | les relations et cadences (§D3) | la respiration officielle, déclinée par densité |
| **Motion Engine** | les 8 intentions (§D10) | le mouvement qui explique, décliné par préférence |
| **Accessibility Engine** | les exigences (§D9) et contraintes opposables | les seuils mesurés, les alternatives, les six niveaux d'accès |
| **International Engine** | les configurations résolues (langues, devises, formats, direction) | la présentation mondiale — données canoniques, affichage préféré |
| **Component Engine** | les compositions (§D7) et tous les Tokens qu'elles composent | les contrats vivants |

| Règle | Énoncé |
|---|---|
| FDE-01 | Un moteur consomme des Tokens — jamais une valeur libre, jamais un autre moteur en court-circuit. |
| FDE-02 | Tout rendu passe par un moteur ; un rendu hors moteur est une violation (FDG-01). |

---

## §8 Consommation des Tokens

| Règle | Énoncé |
|---|---|
| FDT-01 | **Un composant ne lit jamais une valeur. Il lit uniquement un Token.** |
| FDT-02 | **Le Token pointe ensuite vers sa matérialisation** — la couche Tokens (§6) est la seule à connaître les valeurs. |
| FDT-03 | **Flutter ignore la signification. Flutter reçoit uniquement le contrat** (FDV-04/05). |
| FDT-04 | La chaîne est vérifiable de bout en bout : rendu → Token → fiche du catalogue → règle d'origine (la traçabilité du registre prolongée dans le code). |
| FDT-05 | Une valeur introuvable est un défaut bloquant — jamais une valeur de secours en dur (fail closed). |
| FDT-06 | Un Token déprécié se signale à la consommation — la migration est guidée, jamais silencieuse (§8 du registre). |
| FDT-07 | Les Variants se résolvent par les moteurs (thème, préférence, contexte) — jamais par le composant. |
| FDT-08 | Aucun cache, aucune copie locale de valeur ne survit à sa source — la correspondance est vivante. |

---

## §9 Mobile First

| Règle | Énoncé |
|---|---|
| FDMF-01 | **Le téléphone reste la référence** : chaque matérialisation naît, se teste et se valide d'abord sur téléphone (DSMF, DTMF-01). |
| FDMF-02 | **Le Desktop est une adaptation. Jamais une autre implémentation** : mêmes moteurs, mêmes couches, mêmes contrats — d'autres dispositions. |
| FDMF-03 | Une matérialisation invalide sur téléphone est invalide partout (DSMF-03). |
| FDMF-04 | Aucun rendu réservé aux grands écrans (RSE-02). |
| FDMF-05 | Le doute d'adaptation se tranche par « que fait le Mobile ? » (RSMF-04). |

---

## §10 International By Design

| Règle | Énoncé |
|---|---|
| FDI-01 | **RTL** : la bidirectionnalité est native — début/fin logiques partout, jamais un rattrapage (GE-07). |
| FDI-02 | **Language** : les six notions résolues par le cycle EP, rendues par l'International Engine — jamais une chaîne en dur. |
| FDI-03 | **Currency** : les quatre notions rendues comme présentations datées — la vérité reste canonique (GE-04/05). |
| FDI-04 | **Date, Timezone, Formats** : affichés selon les préférences résolues — jamais d'heure locale stockée, jamais un format figé (GE-14, GE-10). |
| FDI-05 | **Appearance** : les préférences mondiales par l'Appearance Engine — mêmes Tokens partout. |
| FDI-06 | **Tous passent par les moteurs officiels (§7). Jamais directement par Flutter** — un accès direct est une violation (FDG). |

---

## §11 Gouvernance

Table officielle des violations — **toutes devront devenir des balayages exécutables**, livrés avec le code de chaque vague (FDP-08) :

| Règle | Violation détectable |
|---|---|
| FDG-01 | **ThemeData hors moteur** — tout thème construit hors du Theme Engine. |
| FDG-02 | **Color brute** — toute couleur littérale hors de la couche Tokens (DTG-02). |
| FDG-03 | **Padding brut** — tout espacement littéral hors Spacing Engine (DTG-03). |
| FDG-04 | **Animation brute** — tout mouvement sans intention consommée (DTG). |
| FDG-05 | **Duration brute** — toute durée littérale hors Motion Engine (DTG-04). |
| FDG-06 | **Typography brute** — tout style de texte hors rôles (DTG-07). |
| FDG-07 | **Widget utilisant une valeur** — toute valeur lue ailleurs que par un Token (FDT-01). |
| FDG-08 | **Composant ignorant un Token** — un contrat rendu sans sa composition du catalogue. |
| FDG-09 | **Bypass du registre** — toute consommation hors catalogue (TRC-07). |
| FDG-10 | **Fork local** — tout composant, thème ou moteur parallèle (CLG-02, DSC-04). |

---

## §12 Extensibilité

| Règle | Énoncé |
|---|---|
| FDX-01 | **Flutter Web, Flutter Desktop, Android, iOS, Foldables, Tablettes, TV, Wearables utilisent exactement la même architecture. Jamais une architecture spécifique.** |
| FDX-02 | Un contexte d'appareil est un rendu de plus par Platform Adaptation (§3.10) — jamais un kit, une couche ou un moteur de plus. |
| FDX-03 | Une technologie future (hors Flutter) entre par sa propre implémentation sous DTD-05 — ce Kit ne lui lègue rien d'autre que l'exemple. |
| FDX-04 | Les douze piliers (§3), les sept couches (§6) et les huit moteurs (§7) sont l'invariant du Kit ; leur révision est documentaire, jamais technique. |
| FDX-05 | Aucune extension ne peut affaiblir la consommation exclusive (§8), l'accessibilité mesurée (§3.8) ni l'International By Design (§10). |

---

## §13 Validation finale

L'architecture de la première implémentation est établie : douze piliers, sept couches, huit moteurs, dix violations détectables — tous au service d'un seul devoir : **matérialiser fidèlement les 172 Tokens admis et les contrats qui les composent**, sous DTD-01→06.

**Principe final** :

> **« Flutter est remplaçable. Le Design System ne l'est pas.**
> **Parce que Flutter est une technologie. Mentora est une architecture. »**

---

*Gouvernance du document : toute modification est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation. En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables, puis P11.8/P11.9A/P11.9B, puis ce document — et le contrat fait foi contre toute matérialisation (FDV-06).*
