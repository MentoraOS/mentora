# SPACING SYSTEM

**Statut** : Référence officielle du langage de l'espace de Mentora. Troisième descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md).
**Portée** : Architecture fonctionnelle uniquement. Aucune valeur, aucune unité, aucun pixel, aucun dp, aucun rem, aucun em, aucun token, aucun code, aucune implémentation. Ce document définit **le langage officiel de l'espace** ; les valeurs concrètes seront produites par les Design Tokens (P11.8) et implémentées par le Flutter Design Kit (P11.9).
**Préséance** : P9 → P10 → [Accessibility Foundation](accessibility-foundation.md) (**opposable**) → [Global Experience Foundation](global-experience-foundation.md) (**opposable**) → P11.0 → ce document (DSD-01 : il précise le pilier **Spacing**, il ne redéfinit rien). Il respecte le [Color System](color-system.md) et le [Typography System](typography-system.md) sans jamais redéfinir leurs règles.
**Niveaux produits (DSD-02)** : Principles et Standards (§8) ; les Tokens et Implementations viendront de P11.8 et P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (l'espace incarne le calme et la précision) et Documentation (chaque règle spatiale est traçable jusqu'à sa règle P10, §7).
**Continuité (MSD-02)** : la respiration est constante partout et toujours — le même rythme avant, pendant et après toute interruption, sur tout appareil, dans toute langue.

---

## 1. Mission

**Mission en une phrase** : définir comment l'espace devient un langage — ce qu'il explique, sépare, relie, hiérarchise et protège — **sans jamais fixer une valeur**.

L'espace ne remplit jamais un écran. **Il explique. Il sépare. Il relie. Il hiérarchise. Il protège l'attention.**

> **Le vide est une information. Pas une absence.**

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| SPV-01 | **Plus d'espace ≠ plus de vide, mais plus de compréhension.** |
| SPV-02 | **Le rythme visuel est une propriété du système. Jamais une décision graphique locale.** |
| SPV-03 | Tout espace affiché a une raison (MSV-04 appliqué au vide) : un espacement sans rôle n'existe pas. |
| SPV-04 | L'espace découle du sens — relation, hiérarchie, protection — jamais d'un goût (DNV-02 appliqué à l'espace). |

---

## 3. Les dix piliers

Dix piliers. Toute règle d'espace appartient à exactement un pilier.

### 3.1 Visual Rhythm

| | |
|---|---|
| **Mission** | Donner à la lecture son rythme — le regard avance naturellement. |
| **Responsabilités** | Définir la cadence verticale de la colonne de lecture (Visual Rhythm du Design Language) : des temps réguliers, prévisibles, constants de surface en surface. |
| **Frontières** | Le rythme structure la lecture ; il n'est jamais décoratif (DPV-03) ; les mesures appartiennent aux Tokens. |
| **Ce qu'il garantit** | lire Mentora a toujours la même respiration — la surprise rythmique n'existe pas (PX-04). |
| **Ce qu'il ne possède jamais** | le contenu ; une cadence par plateforme. |

### 3.2 Information Breathing

| | |
|---|---|
| **Mission** | Donner à chaque information son espace propre. |
| **Responsabilités** | Garantir que chaque information vit dans son air : **jamais compressée, jamais noyée** ; la contraction des surfaces calmes (EV-01) sans écrasement de ce qui reste. |
| **Frontières** | La respiration protège la lisibilité ; la sélection du contenu appartient aux plateformes. |
| **Ce qu'il garantit** | aucune information due n'étouffe — l'important a toujours la place de se dire. |
| **Ce qu'il ne possède jamais** | le droit de remplir (EV-04) ; le droit de compresser pour caser (DPV-07 prime). |

### 3.3 Component Separation

| | |
|---|---|
| **Mission** | Faire que deux composants différents se distinguent — par l'air entre eux. |
| **Responsabilités** | Définir la séparation entre composants : deux intentions différentes **respirent** — jamais collées, jamais confondues (CFE-02 servi par l'espace). |
| **Frontières** | La séparation exprime la différence d'intention ; l'intention appartient aux familles (Component Foundation). |
| **Ce qu'il garantit** | on ne confond jamais deux intentions faute d'air ; la frontière entre composants se perçoit sans se dessiner. |
| **Ce qu'il ne possède jamais** | la définition des composants ; un séparateur décoratif. |

### 3.4 Content Grouping

| | |
|---|---|
| **Mission** | Faire que l'espace exprime la relation. |
| **Responsabilités** | Définir la loi de proximité : **les éléments liés restent proches ; les éléments différents respirent davantage** — l'appartenance se lit sans cadre. |
| **Frontières** | La relation entre contenus est publiée (sections, intentions) ; l'espace la rend visible, il ne l'invente pas. |
| **Ce qu'il garantit** | le regard groupe juste : ce qui va ensemble se voit ensemble (Perception servie par la structure — AFI-04). |
| **Ce qu'il ne possède jamais** | la définition des groupes ; une proximité trompeuse (deux choses non liées jamais rapprochées). |

### 3.5 Hierarchy Spacing

| | |
|---|---|
| **Mission** | Faire que l'espace traduise la priorité. |
| **Responsabilités** | Définir la loi hiérarchique : **plus un contenu est important, plus son espace traduit sa priorité** — l'information principale respire davantage (DNV-01 servi par l'espace). |
| **Frontières** | **L'espace découle de la hiérarchie. Jamais d'un goût graphique** — la hiérarchie est publiée (DNV-02). |
| **Ce qu'il garantit** | l'œil trouve le principal aussi par l'air qui l'entoure — avant toute lecture (DPV-02). |
| **Ce qu'il ne possède jamais** | la qualification d'importance ; une emphase spatiale arbitraire. |

### 3.6 Interaction Space

| | |
|---|---|
| **Mission** | Donner au doigt la place d'agir juste. |
| **Responsabilités** | Définir l'espace d'interaction : **le doigt a toujours suffisamment d'espace** ; les cibles voisines se distinguent ; **les erreurs involontaires ne sont jamais provoquées par le système**. |
| **Frontières** | Les cibles atteignables sont une exigence d'accessibilité (pilier Interaction de l'Accessibility Foundation) ; les dimensions minimales appartiennent aux Tokens sous ces contraintes. |
| **Ce qu'il garantit** | un acte sensible n'est jamais déclenché par un doigt qui visait autre chose ; la distance de sécurité des actes critiques (IPR) existe aussi dans l'espace. |
| **Ce qu'il ne possède jamais** | les niveaux de protection (publiés) ; des cibles serrées pour gagner de la place. |

### 3.7 Focus Space

| | |
|---|---|
| **Mission** | Protéger l'attention par le vide. |
| **Responsabilités** | Définir l'espace des moments importants : **lorsqu'une tâche est importante, l'espace élimine le bruit** — l'immersion épurée (Salle Live), les actes protégés isolés, une surface = un sujet (pilier Focus du Design Language). |
| **Frontières** | Ce qui mérite le focus est publié ; l'espace le sert, il ne le décide pas. |
| **Ce qu'il garantit** | l'attention est protégée physiquement : autour de l'important, le calme (DPV-05 rendu spatial). |
| **Ce qu'il ne possède jamais** | les priorités ; un vide théâtral sans sujet. |

### 3.8 Accessibility Space

| | |
|---|---|
| **Mission** | Faire de l'espace un droit — pour tous, dans tous les contextes. |
| **Responsabilités** | Porter l'exigence opposable : **un espace insuffisant est un défaut d'architecture, jamais un compromis graphique** ; l'espace survit à l'agrandissement du texte (TSA-06) et aux contextes réels (AFC : fatigue, mouvement, une main). |
| **Frontières** | Les seuils chiffrés appartiennent aux Tokens sous ces contraintes ; l'Accessibility Foundation prévaut sur toute esthétique (AFR-02). |
| **Ce qu'il garantit** | personne ne rate ni ne déclenche par erreur faute d'espace ; la lecture ne fatigue pas (TSA-01 servie). |
| **Ce qu'il ne possède jamais** | un « espacement accessible » à part (AFV-01) ; un arbitrage contre l'accessibilité. |

### 3.9 Global Adaptation

| | |
|---|---|
| **Mission** | Faire que la respiration soit mondiale. |
| **Responsabilités** | Porter l'exigence internationale : les textes anglais, français, allemand, arabe, japonais, coréen, russe, chinois **conservent la même respiration** ; **le système ne suppose jamais une longueur de texte** ; **le RTL est citoyen de première classe** (GE-07) — l'espace se pense en début/fin logiques, jamais en gauche/droite absolus. |
| **Frontières** | Le Spacing respecte intégralement la Global Experience Foundation (opposable) ; les langues et directions sont des configurations (GE-10), jamais des cas particuliers d'espacement. |
| **Ce qu'il garantit** | aucune langue n'étouffe, aucune ne déborde : la hiérarchie et la respiration survivent à toute traduction et à toute direction. |
| **Ce qu'il ne possède jamais** | une langue de référence ; un espacement « pour les langues longues ». |

### 3.10 Future Evolution

| | |
|---|---|
| **Mission** | Accueillir les appareils de demain sans nouvelle logique d'espace. |
| **Responsabilités** | Porter le protocole : **un nouvel appareil ne crée jamais une nouvelle logique d'espacement — il adapte uniquement la présentation** (RSE-05 appliqué à l'espace) ; les niveaux d'adaptation du Responsive Foundation règlent ce qui peut changer. |
| **Frontières** | Une adaptation d'espace vit au niveau Disposition/Densité du Responsive (RSL) ; jamais une philosophie par appareil. |
| **Ce qu'il garantit** | la même grammaire spatiale du téléphone à la réalité mixte. |
| **Ce qu'il ne possède jamais** | une logique par appareil ; une densité accrue parce que l'écran grandit (RSE-01). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Spacing System PEUT |
|---|---|
| SPP-01 | Définir le rythme de lecture. |
| SPP-02 | Définir la respiration des informations. |
| SPP-03 | Définir les séparations et les groupements. |
| SPP-04 | Définir l'espace hiérarchique. |
| SPP-05 | Définir l'espace d'interaction et de focus. |
| SPP-06 | Définir les exigences spatiales d'accessibilité et d'internationalisation. |

### 4.2 Interdites

| Règle | Le Spacing System NE PEUT JAMAIS |
|---|---|
| SPN-01 | Décider du contenu — **il décide uniquement de son organisation spatiale**. |
| SPN-02 | Calculer. |
| SPN-03 | Posséder les plateformes, les données, les providers, les moteurs. |
| SPN-04 | Posséder les composants — il les espace, il ne les définit pas. |
| SPN-05 | Fixer une valeur, une unité, une taille (Tokens). |
| SPN-06 | Remplacer le MES ou la fondation P11 — il précise le pilier Spacing, rien de plus. |

---

## 5. Relations avec les plateformes

**Toutes utilisent exactement le même langage spatial. Aucune plateforme ne possède son propre spacing.**

| Plateforme | Ce que le langage spatial lui garantit |
|---|---|
| Home | la colonne d'intentions respire ; le vide calme des journées sans actualité est un état conçu, pas un trou |
| Consultation | l'imminence entourée d'air ; la Salle Live épurée par l'espace (Focus Space) |
| Business | les montants jamais serrés ; la lecture d'un chiffre a sa place (BV-02 servi) |
| AI | les propositions distinctes des faits aussi par l'espace ; l'écart d'un geste a sa cible large |
| Reputation | les signaux lisibles d'un regard ; les preuves dépliées sans entassement |
| Account | la sécurité isolée du réglage courant ; les actes protégés à distance des actes libres |

| Règle | Énoncé |
|---|---|
| SPPL-01 | Même grammaire spatiale partout — l'expression métier passe par le contenu (DR-01). |
| SPPL-02 | Aucune plateforme ne se serre ni ne s'aère à part : la cadence est système. |
| SPPL-03 | Toute nouvelle plateforme reçoit le langage tel quel (DSR-04). |

---

## 6. Traduction du MES — les règles traduites

Chaque règle spatiale traduit une règle P10 (ou opposable), citée explicitement. **Une traduction ne modifie jamais la règle** (DSM-02).

| Règle amont traduite | Traduction spatiale |
|---|---|
| Design Language — Visual Rhythm | le pilier Visual Rhythm (§3.1) : la cadence système |
| Design Language — DPV-05 (le calme permanent) | Focus Space (§3.7) : le calme rendu physique |
| Design Language — DPV-07 / UX-07 (≤ 6 éléments) | Information Breathing (§3.2) : jamais compresser pour caser |
| Design Language — DNV-01/02 (une principale, hiérarchie publiée) | Hierarchy Spacing (§3.5) : l'espace découle de la hiérarchie |
| Design Language — EV-01/EV-04 (contraction, jamais de remplissage) | Information Breathing : le vide honnête, jamais meublé |
| Component Foundation — CFE-02/03 (composants distincts, indépendants) | Component Separation (§3.3) |
| Component Foundation — CFL (niveaux de composition) | Content Grouping (§3.4) : la proximité suit la composition |
| Interaction Foundation — IPR (niveaux de protection) | Interaction Space (§3.6) : la distance de sécurité spatiale |
| Interaction Foundation — IMF-03 (cibles au pouce) | Interaction Space : le doigt a toujours sa place |
| Navigation Foundation — NAV-05 / Immersive | Focus Space : l'immersion épurée |
| Motion Foundation — MC (continuité) | la respiration constante à travers les transitions |
| Responsive Foundation — RSE-01/RSL (l'espace n'ajoute pas de complexité) | Future Evolution (§3.10) et Global Adaptation |
| Accessibility Foundation — piliers Interaction/Readability/Context | Accessibility Space (§3.8), opposable |
| Global Experience Foundation — GE-07/GE-09/GE-10 | Global Adaptation (§3.9) : RTL première classe, aucune hypothèse de langue |

| Règle | Énoncé |
|---|---|
| SPM-01 | Toute règle spatiale cite sa règle amont (DSM-01) ; une règle sans origine est rejetée. |
| SPM-02 | Un manque découvert face à une règle amont remonte en révision — jamais comblé silencieusement (DSM-03, GE-15). |

---

## 7. Les niveaux

Six niveaux — la production spatiale descend toujours (DSL-01) :

| Niveau | Mission | Responsabilités | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Identity** | l'espace comme personnalité | relier la respiration aux 8 qualités (calme, épuré, précis) | les principes identitaires de l'espace | une valeur ; une mesure |
| **Semantic** | les significations de l'espace | les lois du langage : respiration, séparation, groupement, hiérarchie, protection | les règles nommées des piliers | une unité ; un composant |
| **Relationship** | l'espace entre les choses | les relations officielles (lié/distinct, principal/secondaire, libre/protégé) et leur expression spatiale relative | les échelles relatives de relation | une distance absolue |
| **Component** | l'espace en situation | l'application des lois par famille et niveau de composition | les règles d'application par famille | une règle nouvelle ; une exception locale |
| **Token** | les valeurs nommées | (produit par P11.8) chaque relation reçoit ses mesures | la nomenclature relation → valeurs | une signification nouvelle |
| **Implementation** | l'espace dans la technologie | (produit par P11.9) la consommation fidèle | le code des kits | une valeur en dur ; un écart |

---

## 8. Les principes de confiance

| Règle | Le Spacing |
|---|---|
| SPT-01 | **ne ment jamais** : la proximité dit une vraie relation, l'air dit une vraie différence. |
| SPT-02 | **ne manipule jamais** : jamais un espacement qui pousse le doigt vers un choix (DT-03 spatial). |
| SPT-03 | **ne surcharge jamais** (DT-02). |
| SPT-04 | **ne cache jamais** : l'espace ne repousse jamais une information due hors de portée (DT-01). |
| SPT-05 | **protège toujours l'attention** (pilier Focus). |
| SPT-06 | **reste intemporel** (DST-05). |

Ces principes sont **perpétuels**.

---

## 9. Mobile First

| Règle | Énoncé |
|---|---|
| SPMF-01 | **Le Mobile reste la référence** : la respiration se définit sur téléphone, dans la main (DSMF-01). |
| SPMF-02 | **Un spacing qui échoue sur Mobile échoue partout** (DSMF-03). |
| SPMF-03 | **Plus d'espace écran ne signifie jamais plus d'informations** (RSE-01, RSE-02) : le grand écran respire davantage, il ne se remplit pas. |

---

## 10. Gouvernance

| Règle | Énoncé |
|---|---|
| SPG-01 | **Aucun écran ne définit son propre spacing** : tout espace vient du système. |
| SPG-02 | **Toute évolution appartient au Spacing System** — par révision de ce document. |
| SPG-03 | Une nouvelle valeur (Tokens) ne crée jamais une nouvelle loi spatiale (l'équivalent de CSG-03). |
| SPG-04 | **Les violations deviendront des balayages exécutables** dès la première vague d'implémentation (valeurs en dur, espacements locaux : détectables et interdits). |

---

## 11. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Pliables, tablettes, desktop | la même grammaire, dispositions adaptées (RSL — Disposition/Densité) |
| TV | la respiration à distance : plus d'air, jamais plus de contenu |
| Wearables | l'essentiel seul, avec son air minimal vital (Accessibility Space opposable) |
| Réalité mixte | l'espace devient littéral : les lois de relation et de protection valent en trois dimensions |
| Voice | la respiration devient temporelle : les silences structurent comme l'espace (mêmes lois, autre modalité) |
| Nouveaux appareils | le protocole Future Evolution (§3.10) : présentation adaptée, philosophie identique |

| Règle | Énoncé |
|---|---|
| SPX-01 | Les dix piliers (§3) et les six niveaux (§7) sont l'invariant décennal. |
| SPX-02 | La philosophie de l'espace reste identique sur tout support ; seules les présentations évoluent. |
| SPX-03 | Aucune extension ne peut affaiblir l'Accessibility Space (§3.8) ni la Global Adaptation (§3.9) — les deux opposables. |

---

## 12. Gouvernance du document

- Ce document est la **référence officielle** du langage de l'espace de Mentora — troisième descendant du Design System.
- **Conformité aux fondations opposables** : l'Accessibility Foundation est servie par le pilier Accessibility Space (§3.8) et opposable à tout arbitrage (SPX-03) ; la Global Experience Foundation est servie par le pilier Global Adaptation (§3.9 — RTL première classe, aucune hypothèse de langue) et opposable de même.
- Toute vague d'implémentation cite le pilier, le niveau et les règles (SPV/SPP/SPN/SPPL/SPM/SPT/SPMF/SPG/SPX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables (Accessibility, Global Experience), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md), puis ce document (DSD-01).
