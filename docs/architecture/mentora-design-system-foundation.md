# MENTORA DESIGN SYSTEM FOUNDATION

**Statut** : Référence officielle du Design System de Mentora. Ce document ouvre le chapitre P11.
**Portée** : Architecture fonctionnelle uniquement. Aucun design, aucun écran, aucun widget, aucun composant Flutter, aucun token, aucun pixel, aucune couleur, aucune typographie, aucun code, aucun pseudo-code, aucune maquette, aucun Figma. Ce document ne décrit aucune valeur concrète — il décrit **le système officiel qui permettra d'implémenter l'identité de Mentora**.
**Préséance** : la hiérarchie officielle est **P9 → P10 → P11**. En cas de conflit : [P9.0](mentora-expert-platform-v2.md) prévaut, puis le [MES](mentora-experience-system-foundation.md) et ses sept descendants (l'[Accessibility Foundation](accessibility-foundation.md) restant opposable — AFR-02), puis ce document, puis ses propres descendants (§12).
**Filiation** : le Design System est **la conséquence** du MES (MSD-03) : le MES et ses descendants définissent l'expérience ; le Design System la rend implémentable. Jamais l'inverse.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par la stabilité du système — les mêmes standards, tokens et patterns partout, pour toujours, sur tout support.

---

## 1. Mission

Le Design System n'est **pas une bibliothèque graphique**.

Le Design System est **le langage concret issu du Mentora Experience System** :

> **Le MES définit pourquoi. Le Design System définit comment.**

**Mission en une phrase** : transformer les règles du MES et de ses descendants en un système concret réutilisable — standards, tokens, patterns, bibliothèques — sans jamais rien décider de l'expérience elle-même.

Il ne possède jamais : les plateformes métier, les plateformes système, les données, les providers, les moteurs, la logique métier, les décisions fonctionnelles.

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| DSV-01 | Le produit devient **cohérent. Jamais décoratif. Jamais arbitraire** : chaque choix concret se justifie par une règle P10. |
| DSV-02 | Un choix concret sans règle amont n'existe pas ; une règle amont sans traduction concrète est une dette déclarée. |
| DSV-03 | Le Design System est **un** : une identité, un langage, une manière de concevoir (§8). |
| DSV-04 | Il reste **indépendant des technologies** : le système précède ses implémentations (DST-06). |

---

## 3. Les piliers du Design System

Douze piliers. Toute production concrète du Design System appartient à exactement un pilier.

### 3.1 Identity

| | |
|---|---|
| **Mission** | Incarner concrètement la personnalité visuelle définie par le Design Language (§9 — professionnelle, calme, précise, épurée, fiable, accessible, élégante, intemporelle). |
| **Responsabilités** | Produire l'identité de marque appliquée au produit : les principes d'expression concrets dont tous les autres piliers découlent. |
| **Frontières** | L'identité applique la personnalité définie en P10 ; elle ne la redéfinit jamais. |
| **Ce qu'il produit** | les principes identitaires concrets du produit. |
| **Ce qu'il ne possède jamais** | la personnalité elle-même (Design Language) ; le marketing hors produit. |

### 3.2 Color

| | |
|---|---|
| **Mission** | Donner au langage visuel ses couleurs — au service du sens, jamais du décor. |
| **Responsabilités** | Produire le système de couleurs : rôles sémantiques (hiérarchie, états, distinctions signifiantes du pilier Contrast) avant valeurs ; sous contrainte d'accessibilité opposable. |
| **Frontières** | Les distinctions à exprimer viennent de P10 (fait/proposition, vérifié/déclaré, les 8 états) ; jamais la couleur seule porteuse de sens (AFS-01). |
| **Ce qu'il produit** | le futur Color System (P11.1) : rôles, gammes, règles d'usage. |
| **Ce qu'il ne possède jamais** | le droit d'inventer une distinction ; une couleur sans rôle. |

### 3.3 Typography

| | |
|---|---|
| **Mission** | Donner au langage sa voix écrite — lisible pour tous, hiérarchique par construction. |
| **Responsabilités** | Produire le système typographique : rôles de texte alignés sur les cinq niveaux visuels (§7 du Design Language), sous contraintes de Readability. |
| **Frontières** | La hiérarchie vient de P10 ; la typographie l'incarne, elle ne la crée pas. |
| **Ce qu'il produit** | le futur Typography System (P11.2) : rôles, échelles, règles d'usage. |
| **Ce qu'il ne possède jamais** | les textes ; les niveaux d'information. |

### 3.4 Spacing

| | |
|---|---|
| **Mission** | Donner au rythme visuel sa mesure — la respiration devient système. |
| **Responsabilités** | Produire le système d'espacement : la cadence régulière du Visual Rhythm, la contraction des surfaces calmes, la cohérence des respirations partout. |
| **Frontières** | Le rythme et la densité maximale viennent de P10 ; l'espacement les mesure, il ne les discute pas. |
| **Ce qu'il produit** | le futur Spacing System (P11.3) : échelle, règles de composition. |
| **Ce qu'il ne possède jamais** | la densité (bornée par P10) ; la disposition (Responsive). |

### 3.5 Elevation

| | |
|---|---|
| **Mission** | Donner de la profondeur au sens : ce qui est au-dessus l'est pour une raison. |
| **Responsabilités** | Produire le système d'élévation : qui passe devant quoi (modal, immersion, attention) — traduction des règles de Focus et des types de navigation superposés (Temporary, Modal). |
| **Frontières** | Ce qui a le droit de passer devant vient de P10 ; l'élévation l'exprime. |
| **Ce qu'il produit** | le futur Elevation & Surface System (P11.4, part élévation). |
| **Ce qu'il ne possède jamais** | le droit d'interrompre (Focus) ; l'empilement libre (jamais de modals empilés). |

### 3.6 Surface

| | |
|---|---|
| **Mission** | Donner leurs fonds et leurs cadres aux surfaces — le calme du support. |
| **Responsabilités** | Produire le système de surfaces : les fonds, les délimitations, les enveloppes des niveaux de composition (block, section, surface). |
| **Frontières** | Les niveaux de composition viennent du Component Foundation ; la surface les habille. |
| **Ce qu'il produit** | le futur Elevation & Surface System (P11.4, part surfaces). |
| **Ce qu'il ne possède jamais** | la structure (Presentation) ; le contenu. |

### 3.7 Iconography

| | |
|---|---|
| **Mission** | Donner au langage ses pictogrammes — une forme dit sa fonction (Clarity). |
| **Responsabilités** | Produire le système d'icônes : un vocabulaire pictographique unique, chaque icône attachée à une intention, jamais décorative, jamais seule porteuse du sens (AFI-04). |
| **Frontières** | Les intentions viennent des familles de composants ; l'icône les signe. |
| **Ce qu'il produit** | le futur Iconography System (P11.5). |
| **Ce qu'il ne possède jamais** | une icône sans intention ; deux icônes pour la même intention (CFU-02 appliqué). |

### 3.8 Illustration

| | |
|---|---|
| **Mission** | Donner un visage aux moments qui le méritent — états vides, accueils, caps — avec la sobriété du ton professionnel. |
| **Responsabilités** | Produire le système d'illustration : quand illustrer (les états conçus — vide, premier accès), quand ne jamais illustrer (jamais de remplissage — EV-04, jamais de décor — DPV-03). |
| **Frontières** | Le registre émotionnel vient du Design Language (Emotional Tone) ; l'illustration l'incarne sans jamais dramatiser. |
| **Ce qu'il produit** | le futur Illustration System (P11.6). |
| **Ce qu'il ne possède jamais** | le droit de meubler ; le ludique gratuit (DPV-08). |

### 3.9 Components

| | |
|---|---|
| **Mission** | Réaliser concrètement les dix familles et six niveaux du Component Foundation. |
| **Responsabilités** | Produire la bibliothèque de composants : chaque composant concret réalise une famille, définit ses huit états, respecte les protections et les trois langages (CFT-06). |
| **Frontières** | Les familles, niveaux et états viennent du Component Foundation ; la bibliothèque les fabrique, elle n'en invente pas. |
| **Ce qu'il produit** | la future Component Library (P11.7). |
| **Ce qu'il ne possède jamais** | une famille nouvelle ; un composant hors famille (CFG-02) ; un fork (CFU-04). |

### 3.10 Design Tokens

| | |
|---|---|
| **Mission** | Nommer chaque décision concrète — une seule source de vérité pour chaque valeur. |
| **Responsabilités** | Produire le système de tokens : chaque valeur concrète (rôle de couleur, pas d'échelle, mesure) existe une fois, nommée par son rôle, consommée partout — jamais de valeur en dur hors token. |
| **Frontières** | Un token nomme une décision prise par son pilier ; il ne décide rien. |
| **Ce qu'il produit** | les futurs Design Tokens (P11.8) : la nomenclature et le registre. |
| **Ce qu'il ne possède jamais** | des valeurs orphelines ; deux tokens pour la même décision. |

### 3.11 Flutter Kit

| | |
|---|---|
| **Mission** | Implémenter le système dans la technologie du produit — la première implémentation, jamais la définition. |
| **Responsabilités** | Produire le kit d'implémentation : la traduction fidèle des tokens, composants et patterns dans la technologie de l'app. |
| **Frontières** | Le kit consomme le système ; il n'y introduit rien (RSV du système : indépendant des technologies — une autre implémentation doit rester possible à tout moment). |
| **Ce qu'il produit** | le futur Flutter Design Kit (P11.9). |
| **Ce qu'il ne possède jamais** | une décision de design ; un composant absent de la bibliothèque ; un écart « technique » au système. |

### 3.12 Documentation

| | |
|---|---|
| **Mission** | Faire que le système s'apprenne, se consulte et se respecte — la mémoire vivante du Design System. |
| **Responsabilités** | Produire la documentation d'usage : chaque standard, token, pattern et composant documenté avec sa règle P10 d'origine, ses usages permis et interdits. |
| **Frontières** | La documentation décrit le système ; elle ne le modifie jamais (une évolution passe par la gouvernance, §11). |
| **Ce qu'il produit** | la référence d'usage du système, traçable jusqu'aux fondations. |
| **Ce qu'il ne possède jamais** | une règle propre ; un exemple qui contredit une fondation. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Design System PEUT |
|---|---|
| DSP-01 | Transformer les règles du MES. |
| DSP-02 | Définir les langages graphiques. |
| DSP-03 | Définir les systèmes de conception. |
| DSP-04 | Définir les standards visuels. |
| DSP-05 | Définir les tokens. |
| DSP-06 | Définir les bibliothèques. |
| DSP-07 | Définir les conventions. |

### 4.2 Interdites

| Règle | Le Design System NE PEUT JAMAIS |
|---|---|
| DSN-01 | Décider — de l'expérience, des priorités, du métier. |
| DSN-02 | Calculer. |
| DSN-03 | Posséder les plateformes. |
| DSN-04 | Posséder les données. |
| DSN-05 | Posséder les providers. |
| DSN-06 | Posséder les moteurs. |
| DSN-07 | Remplacer le MES — le Design System traduit, il ne redéfinit jamais. |

---

## 5. Relation avec le MES

**Chaque pilier du MES possède une traduction concrète dans le Design System. Jamais l'inverse.**

| Fondation P10 | Sa traduction concrète en P11 |
|---|---|
| Navigation Foundation | les patterns concrets des dix types de navigation et de leurs dispositions |
| Interaction Foundation | les composants d'action, de confirmation et de feedback aux cinq niveaux de protection |
| Design Language Foundation | Identity, Color, Typography, Spacing — la personnalité rendue mesurable |
| Motion Foundation | les réalisations concrètes des huit intentions du mouvement (durées et courbes sous contrainte MT) |
| Component Foundation | la Component Library : dix familles, six niveaux, huit états — fabriqués |
| Accessibility Foundation | les seuils, tailles et alternatives concrets — opposables à tous les autres piliers |
| Responsive Foundation | les dispositions concrètes des six niveaux d'adaptation, par contexte d'appareil |

| Règle | Énoncé |
|---|---|
| DSM-01 | Toute production P11 cite la règle P10 qu'elle traduit ; une production sans origine est rejetée (DSV-02). |
| DSM-02 | Une traduction ne peut ni affaiblir ni étendre la règle qu'elle traduit — elle la rend concrète, c'est tout. |
| DSM-03 | Un manque découvert en traduisant remonte en révision P10 — jamais comblé silencieusement en P11. |

---

## 6. Relation avec les plateformes

**Les plateformes utilisent le Design System. Le Design System ne connaît jamais leur logique.**

| Règle | Énoncé |
|---|---|
| DSR-01 | Les six plateformes (Home, Consultation, Business, AI, Reputation, Account) consomment le même système — aucune n'en possède une variante (CFR-01). |
| DSR-02 | Le Design System ignore le métier : il fournit des rôles, des patterns et des composants ; les plateformes y versent leur contenu. |
| DSR-03 | Un besoin de plateforme qui manque au système enrichit le système — pour toutes (jamais une exception locale). |
| DSR-04 | Toute nouvelle plateforme reçoit le système tel quel (MSR-03). |

---

## 7. Les niveaux du Design System

Six niveaux officiels. Toute production du système vit à exactement un niveau.

| Niveau | Mission | Responsabilité | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Principes** | relier le système aux fondations | porter les règles P10 applicables et leurs conséquences concrètes | les principes d'application, la traçabilité vers P10 | une règle nouvelle ; une valeur |
| **Standards** | fixer les décisions de conception | établir les choix officiels par pilier (rôles de couleur, échelles, registres) | les décisions nommées et justifiées | une valeur en dur sans nom ; une décision sans origine P10 |
| **Tokens** | nommer chaque valeur | donner à chaque décision son identifiant unique consommable | la nomenclature, le registre des valeurs | une logique ; un comportement ; deux noms pour une valeur |
| **Patterns** | assembler les réponses récurrentes | codifier les compositions éprouvées (une carte d'intention, une confirmation, une attente) | des assemblages de composants et de tokens | un pattern à usage unique ; un pattern contraire à une fondation |
| **Libraries** | fabriquer le réutilisable | produire les bibliothèques officielles (composants, icônes, illustrations) | les éléments fabriqués, leurs huit états, leur documentation | un élément hors famille ; un fork ; un doublon d'intention |
| **Implementations** | porter le système dans les technologies | traduire fidèlement (Flutter d'abord, autres ensuite) | le code des kits, la correspondance token→technologie | une décision de design ; un écart au système ; une exclusivité technologique |

| Règle | Énoncé |
|---|---|
| DSL-01 | La production descend toujours : Principes → Standards → Tokens → Patterns → Libraries → Implementations. Jamais l'inverse. |
| DSL-02 | Chaque niveau ne consomme que les niveaux au-dessus de lui. |
| DSL-03 | Un changement à un niveau se propage vers le bas — jamais un correctif local en aval d'une décision amont. |

---

## 8. Les principes de cohérence

| Règle | Énoncé |
|---|---|
| DSC-01 | **Une seule identité.** |
| DSC-02 | **Un seul langage.** |
| DSC-03 | **Une seule manière de concevoir.** |
| DSC-04 | **Aucune équipe ne crée son propre système** — ni palette locale, ni composant maison, ni convention parallèle. |
| DSC-05 | **Toute évolution appartient au Design System** : un besoin nouveau enrichit le système pour tous, par sa gouvernance (§11). |

---

## 9. Les principes de confiance

| Règle | Le Design System |
|---|---|
| DST-01 | **reste honnête** : il traduit les principes d'honnêteté de P10 (DT, IF, CFT) en moyens concrets — jamais en façade. |
| DST-02 | **reste cohérent** : la même décision partout (DSC). |
| DST-03 | **reste prévisible** : un standard établi ne change pas sans gouvernance. |
| DST-04 | **reste réutilisable** : tout ce qu'il produit sert toutes les plateformes. |
| DST-05 | **reste intemporel** : aucune mode (§9 du Design Language — l'intemporalité est opposable). |
| DST-06 | **reste indépendant des technologies** : le système survit à ses implémentations. |

Ces principes sont **perpétuels**.

---

## 10. Mobile First

| Règle | Énoncé |
|---|---|
| DSMF-01 | Le Design System est conçu d'abord pour **le mobile** : chaque standard, token et composant naît sur téléphone. |
| DSMF-02 | **Toutes les décisions naissent du mobile. Les autres appareils adaptent. Jamais l'inverse** (RSMF-02, MSMF-07). |
| DSMF-03 | Un standard invalide sur mobile est invalide partout. |

---

## 11. Gouvernance

| Règle | Énoncé |
|---|---|
| DSG-01 | **Toute nouvelle couleur appartient au Design System.** |
| DSG-02 | **Toute nouvelle typographie appartient au Design System.** |
| DSG-03 | **Tout nouveau composant appartient au Design System.** |
| DSG-04 | **Tout nouveau token appartient au Design System.** |
| DSG-05 | **Toute nouvelle bibliothèque appartient au Design System.** |
| DSG-06 | Rien de concret n'existe hors du système : une valeur, un composant ou une convention hors système est une violation d'architecture. |
| DSG-07 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 12. Descendance documentaire

Les documents suivants **découleront directement** de cette fondation — chacun précise un pilier **sans jamais redéfinir la fondation** :

| Document descendant | Pilier(s) précisé(s) |
|---|---|
| P11.1 — Color System | Color |
| P11.2 — Typography System | Typography |
| P11.3 — Spacing System | Spacing |
| P11.4 — Elevation & Surface System | Elevation, Surface |
| P11.5 — Iconography System | Iconography |
| P11.6 — Illustration System | Illustration |
| P11.7 — Component Library | Components |
| P11.8 — Design Tokens | Design Tokens |
| P11.9 — Flutter Design Kit | Flutter Kit |

| Règle | Énoncé |
|---|---|
| DSD-01 | Un descendant précise, il ne redéfinit pas (le MSD-01 du chapitre P11). |
| DSD-02 | Chaque descendant déclare les règles P10 qu'il traduit (DSM-01) et les niveaux (§7) qu'il produit. |
| DSD-03 | Les piliers Identity et Documentation sont transversaux : chaque descendant doit dire comment il les sert. |
| DSD-04 | L'Accessibility Foundation reste opposable à chaque descendant (AFR-02). |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Flutter, Web, Desktop, nouveaux frameworks | de nouvelles Implementations (§7) du même système — le niveau Implementations est le seul qui les connaisse |
| Tablettes, TV, wearables, réalité mixte | les standards s'appliquent par les contextes du Responsive Foundation |
| Voice | les tokens et patterns ont des équivalents sonores — mêmes rôles, autre modalité |
| Nouveaux supports | reçoivent le système tel quel, par le protocole Future Devices |

| Règle | Énoncé |
|---|---|
| DSX-01 | Les douze piliers (§3) et les six niveaux (§7) sont l'invariant décennal. |
| DSX-02 | **Le système reste identique. Seules les implémentations évoluent.** |
| DSX-03 | Aucune extension ne peut affaiblir la cohérence (DSC) ni la confiance (DST). |

---

## 14. Gouvernance du document

- Ce document est la **référence officielle** du Design System de Mentora et ouvre le chapitre P11.
- La hiérarchie de préséance est établie : **P9 → P10 → P11** — et à l'intérieur de P11 : cette fondation → ses descendants (§12).
- Toute vague P11 cite le pilier, le niveau et les règles (DSV/DSP/DSN/DSM/DSR/DSL/DSC/DST/DSMF/DSG/DSD/DSX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
