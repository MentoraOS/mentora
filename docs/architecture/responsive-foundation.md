# RESPONSIVE FOUNDATION

**Statut** : Référence officielle de la continuité d'expérience de Mentora. Ce document **clôt la série des descendants du MES**.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun breakpoint, aucune grille, aucun pixel, aucune taille d'écran, aucun code, aucun pseudo-code, aucune maquette. Cette fondation ne décrit aucune technique d'adaptation — elle décrit **la continuité officielle de l'expérience Mentora entre tous les appareils**. Les implémentations techniques viendront plus tard.
**Filiation** : septième et dernier descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) — il réalise officiellement le pilier **Responsiveness** (MSD-01 : il précise, ne redéfinit pas). Il respecte les six fondations descendantes précédentes ([Navigation](navigation-foundation.md), [Interaction](interaction-foundation.md), [Design Language](design-language-foundation.md), [Motion](motion-foundation.md), [Component](component-foundation.md)) et l'[Accessibility Foundation](accessibility-foundation.md) qui lui est opposable (AFR-02) ; P9.0 prévaut en cas de conflit.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par définition — elle est la continuité **entre appareils** : le travail reprend, les repères demeurent, l'expérience est une (MSV-05), partout.

---

## 1. Mission

**Mission en une phrase** : définir la manière dont **une même expérience** vit sur tous les appareils — ce qui s'adapte, ce qui ne change jamais — et rien d'autre.

Il ne possède jamais : les plateformes métier, les données, les composants, les providers, les moteurs, les plateformes système, la logique métier.

---

## 2. Vision

Dans Mentora, **l'expérience ne change jamais. Seule sa présentation évolue.**

| Règle | Énoncé |
|---|---|
| RSV-01 | Un expert **retrouve immédiatement son travail** — quel que soit l'appareil, quel que soit le contexte, quel que soit le support. |
| RSV-02 | Il n'existe qu'**une** expérience Mentora (MSV-05) ; les appareils en sont des fenêtres, jamais des variantes. |
| RSV-03 | Changer d'appareil ne demande jamais de réapprendre (Cross Platform Navigation). |
| RSV-04 | Un appareil accueille l'expérience. Il ne la redéfinit jamais (MSX-04). |

---

## 3. Les piliers du Responsive

Dix piliers. Toute règle d'adaptation appartient à exactement un pilier.

### 3.1 Experience Continuity

| | |
|---|---|
| **Mission** | Garantir que l'expérience est la même partout — le socle de tout le reste. |
| **Responsabilités** | Tenir l'invariant : mêmes plateformes, mêmes moments, mêmes intentions, mêmes règles sur chaque appareil. |
| **Frontières** | La continuité protège l'expérience définie par le MES et ses descendants ; elle n'en définit aucune. |
| **Ce qu'il garantit** | Mentora est reconnaissable et exerçable partout, à l'identique de sens. |
| **Ce qu'il ne possède jamais** | l'expérience elle-même ; une exception par appareil. |

### 3.2 Adaptive Layout

| | |
|---|---|
| **Mission** | Faire respirer la même expérience dans des espaces différents. |
| **Responsabilités** | Définir les dispositions permises : une colonne d'intentions sur mobile, liste + détail côte à côte quand l'espace le permet (MF-06) — toujours les mêmes contenus, autrement disposés. |
| **Frontières** | La disposition change ; la hiérarchie, l'ordre de sens et la densité maximale ne changent pas. Les mécanismes concrets appartiendront aux implémentations. |
| **Ce qu'il garantit** | l'espace disponible est utilisé pour la lisibilité — jamais pour la surcharge (DMF-05). |
| **Ce qu'il ne possède jamais** | les priorités ; les breakpoints ; les grilles. |

### 3.3 Content Priority

| | |
|---|---|
| **Mission** | Garantir que ce qui est prioritaire le reste — sur tout écran, surtout le plus petit. |
| **Responsabilités** | Tenir l'ordre des priorités publiées (PRI du Home, moments des plateformes) sur toute disposition ; protéger le prioritaire quand l'espace se réduit (MF-05). |
| **Frontières** | Les priorités appartiennent aux plateformes ; ce pilier garantit leur survie à l'adaptation. |
| **Ce qu'il garantit** | réduire l'écran ne fait jamais disparaître l'essentiel — le secondaire se replie d'abord, l'essentiel jamais. |
| **Ce qu'il ne possède jamais** | la qualification de priorité ; le contenu. |

### 3.4 Interaction Continuity

| | |
|---|---|
| **Mission** | Garantir qu'une même action produit toujours le même résultat — partout. |
| **Responsabilités** | Tenir les types et niveaux de protection de l'Interaction Foundation sur toute modalité : le même acte, le même consentement, la même réponse. |
| **Frontières** | Les interactions appartiennent à l'Interaction Foundation ; ce pilier garantit leur constance inter-appareils. |
| **Ce qu'il garantit** | aucun appareil ne rend un acte plus dangereux ni plus laxiste (les protections ne se déclassent jamais — IPR-05). |
| **Ce qu'il ne possède jamais** | les types d'interaction ; les protections. |

### 3.5 Navigation Continuity

| | |
|---|---|
| **Mission** | Garantir que se déplacer reste identique — mêmes types, mêmes profondeurs, mêmes retours. |
| **Responsabilités** | Tenir les dix types, les profondeurs et les contextes de la Navigation Foundation partout (Cross Platform Navigation) ; seules les dispositions de la navigation s'adaptent. |
| **Frontières** | Les trajets appartiennent à la Navigation Foundation ; ce pilier garantit qu'aucun appareil n'en invente ni n'en retire. |
| **Ce qu'il garantit** | aucune destination absente d'un appareil ; aucun trajet propre à un appareil. |
| **Ce qu'il ne possède jamais** | les trajets ; les portes. |

### 3.6 Context Preservation

| | |
|---|---|
| **Mission** | Garantir que le contexte de travail survit au changement d'appareil. |
| **Responsabilités** | Définir la reprise inter-appareils : le parcours, l'étape, le travail en cours se retrouvent (Recovery, NCO-01) ; ce qui a changé se signale (NCO-03). |
| **Frontières** | Les états repris sont publiés par les plateformes ; les sessions techniques appartiennent aux systèmes ; ce pilier définit l'exigence, jamais le mécanisme. |
| **Ce qu'il garantit** | poser son téléphone et ouvrir sa tablette n'interrompt pas la journée de l'expert. |
| **Ce qu'il ne possède jamais** | les données du travail ; la synchronisation technique. |

### 3.7 Device Adaptation

| | |
|---|---|
| **Mission** | Accueillir les capacités et limites propres de chaque appareil — sans jamais trahir l'expérience. |
| **Responsabilités** | Définir comment un appareil exprime l'expérience avec ses moyens (toucher, télécommande, voix, regard) ; borner l'usage de ses capacités propres au service des intentions existantes. |
| **Frontières** | Une capacité d'appareil sert l'expérience définie ; elle ne crée jamais une fonctionnalité propre (RSE-02). |
| **Ce qu'il garantit** | chaque appareil donne le meilleur de lui-même — à l'intérieur du langage Mentora. |
| **Ce qu'il ne possède jamais** | une expérience par appareil ; une exclusivité d'appareil. |

### 3.8 Workspace Evolution

| | |
|---|---|
| **Mission** | Régler ce que l'espace disponible a le droit de changer — et rien d'autre. |
| **Responsabilités** | Définir les règles d'évolution de l'espace (§8) : plus d'espace = plus de respiration et de coexistence lisible ; jamais plus de complexité, jamais plus de fonctionnalités (RSE-01, RSE-02). |
| **Frontières** | L'espace évolue la disposition et la coexistence ; la densité maximale d'attention (≤ 6) et l'action principale unique demeurent. |
| **Ce qu'il garantit** | le grand écran est plus confortable — jamais plus chargé. |
| **Ce qu'il ne possède jamais** | de nouvelles surfaces ; de nouveaux parcours. |

### 3.9 Multi Device

| | |
|---|---|
| **Mission** | Faire vivre l'expert sur plusieurs appareils — comme un seul Mentora. |
| **Responsabilités** | Définir la cohérence simultanée : le même état publié partout (RSCO-04) ; l'appareil actif reçoit l'attention, les autres restent silencieux (Focus) ; un acte engagé sur un appareil ne se rejoue pas sur un autre. |
| **Frontières** | Les appareils connectés appartiennent à l'Account Platform (Devices) ; les états aux plateformes ; ce pilier définit l'expérience de la simultanéité. |
| **Ce qu'il garantit** | plusieurs appareils, zéro confusion : jamais deux vérités, jamais deux sollicitations pour le même fait. |
| **Ce qu'il ne possède jamais** | la gestion des appareils ; la session technique. |

### 3.10 Future Devices

| | |
|---|---|
| **Mission** | Accueillir les appareils qui n'existent pas encore — sans révision d'architecture. |
| **Responsabilités** | Définir le protocole d'accueil d'un nouveau support : nommer son contexte (§6), ses moyens (Device Adaptation), son sous-ensemble d'intentions s'il est contraint (comme les wearables) — et recevoir tout le reste tel quel. |
| **Frontières** | Un nouvel appareil entre par ce protocole ; il n'entre jamais par une expérience dédiée. |
| **Ce qu'il garantit** | dans dix ans, le prochain support portera la même expérience Mentora (MSX-04). |
| **Ce qu'il ne possède jamais** | le droit de redéfinir quoi que ce soit. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Responsive Foundation PEUT |
|---|---|
| RSP-01 | Définir l'adaptation. |
| RSP-02 | Définir les priorités d'adaptation. |
| RSP-03 | Définir la continuité. |
| RSP-04 | Définir les changements de disposition. |
| RSP-05 | Définir les comportements multi-appareils. |
| RSP-06 | Définir les règles d'évolution de l'espace disponible. |

### 4.2 Interdites

| Règle | Le Responsive Foundation NE PEUT JAMAIS |
|---|---|
| RSN-01 | Décider. |
| RSN-02 | Calculer. |
| RSN-03 | Posséder les plateformes métier. |
| RSN-04 | Posséder les données. |
| RSN-05 | Posséder les composants. |
| RSN-06 | Posséder Flutter. |
| RSN-07 | Posséder les APIs. |
| RSN-08 | Remplacer le MES — il précise son pilier Responsiveness, rien de plus. |

---

## 5. Relation avec les plateformes

**Toutes les plateformes vivent la même expérience. Seule leur présentation évolue. Jamais leur logique. Jamais leur responsabilité.**

| Plateforme | Ce qui s'adapte | Ce qui ne bouge jamais |
|---|---|---|
| Home | la disposition de la colonne d'intentions | les remontées, leurs priorités, les six éléments maximum |
| Consultation | la disposition de l'agenda et du cycle ; la Salle occupe tout, partout | le cycle, l'imminence d'abord, la porte unique de la Salle |
| Business | la coexistence des domaines quand l'espace le permet | la lecture des montants, les protections d'argent |
| AI | la place des propositions | la citation IA, l'accueil/écart au même coût |
| Reputation | la coexistence signaux + preuves | la primauté des signaux, le dépliage vers les preuves |
| Account | la disposition des réglages | la primauté de la sécurité, les protections |

| Règle | Énoncé |
|---|---|
| RSR-01 | Aucune plateforme n'a de version par appareil : elle a une expérience, plusieurs présentations. |
| RSR-02 | Une remontée, un moment, une protection valent à l'identique sur tout appareil. |
| RSR-03 | Toute nouvelle plateforme reçoit la fondation telle quelle (MSR-03). |

---

## 6. Les contextes d'appareils

Dix contextes officiels — chacun dit **ce qui change** et **ce qui ne change jamais** :

| Contexte | Ce qui change | Ce qui ne change jamais |
|---|---|---|
| **Téléphone** | rien — c'est la référence (§10) | tout : il définit l'expérience |
| **Téléphone pliable** | la disposition suit l'état plié/déplié, sans rupture de contexte | le parcours en cours, les priorités, la navigation |
| **Tablette** | liste + détail coexistent (MF-06) | mêmes surfaces, mêmes trajets — jamais un parcours de plus |
| **Desktop** | plus de coexistence lisible, les gestes deviennent pointeur et clavier | adaptation du Mobile (MSMF-07) — jamais un autre produit |
| **Web** | le support d'accès | l'expérience entière — le web n'est pas une version allégée |
| **TV** | lecture à distance, interaction par télécommande | la hiérarchie, le calme, les niveaux d'information |
| **Wearable** | le sous-ensemble essentiel : imminence, sécurité, accusés | les protections — le sensible et au-delà renvoient à un appareil complet |
| **Voice** | la modalité : dit et entendu | les intentions, les niveaux d'information, les consentements explicites |
| **Réalité mixte** | la spatialisation des surfaces | les familles de composants, les portes d'immersion, la continuité |
| **Nouveaux appareils** | leur contexte se déclare par le protocole (§3.10) | tout le reste |

| Règle | Énoncé |
|---|---|
| RSC-01 | Un contexte décrit une présentation — jamais une expérience. |
| RSC-02 | Tout nouveau contexte s'ajoute par révision de ce document, via le protocole Future Devices. |

---

## 7. Les niveaux d'adaptation

Six niveaux officiels — pour chacun : ce qui peut évoluer, ce qui reste invariant, ce qui est interdit.

| Niveau | Peut évoluer | Reste invariant | Interdit |
|---|---|---|---|
| **Disposition** | l'agencement des sections et surfaces dans l'espace | l'ordre de sens, la hiérarchie, la lecture verticale comme colonne de référence | réordonner contre les priorités publiées |
| **Densité** | la respiration, la coexistence de sections | le maximum de six éléments d'attention, l'action principale unique | densifier parce que l'espace le permet |
| **Surface** | la coexistence de plusieurs surfaces visibles (liste + détail) | une surface = une question (CFL-04) ; la surface répond entière ou pas du tout | tronquer une surface ; en fusionner deux |
| **Navigation** | la disposition de la navigation (position, forme d'accès) | les types, profondeurs, retours et portes officiels | un trajet, une entrée ou un raccourci propre à un appareil |
| **Interaction** | la modalité du geste (toucher, pointeur, télécommande, voix) | les types d'interaction et les niveaux de protection | déclasser une protection sur un appareil ; exiger une modalité sans alternative (AFI-05) |
| **Immersion** | la forme du plein écran selon le support | la porte unique, l'absence de navigation interne, la sortie propre | une immersion partielle ; une immersion sans porte |

| Règle | Énoncé |
|---|---|
| RSL-01 | Toute adaptation se déclare à un niveau officiel ; une adaptation hors niveau n'existe pas. |
| RSL-02 | L'invariant d'un niveau est opposable à toute implémentation, sur tout appareil, pour toujours. |

---

## 8. Les principes de continuité et d'évolution

### 8.1 Continuité

| Règle | Énoncé |
|---|---|
| RSCO-01 | **Le travail reprend toujours** (NCO-01, étendu aux appareils). |
| RSCO-02 | **Le contexte est conservé** : parcours, étape, saisie — d'un appareil à l'autre. |
| RSCO-03 | **L'utilisateur retrouve immédiatement ses repères** : mêmes plateformes, mêmes intentions, mêmes mots. |
| RSCO-04 | **Une même action produit toujours le même résultat.** |
| RSCO-05 | **Une même intention utilise toujours le même langage** (CFU-01, partout). |

### 8.2 Évolution

| Règle | Énoncé |
|---|---|
| RSE-01 | **Plus d'espace ne signifie jamais plus de complexité.** |
| RSE-02 | **Plus d'espace ne crée jamais de nouvelles fonctionnalités** : aucune capacité n'existe sur un appareil sans exister sur Mobile (pilier Responsiveness du MES). |
| RSE-03 | **Desktop ne devient jamais un autre produit.** |
| RSE-04 | **La tablette n'invente jamais un nouveau parcours.** |
| RSE-05 | **Les appareils accueillent l'expérience. Ils ne la redéfinissent jamais** (RSV-04). |

Ces principes sont **perpétuels**.

---

## 9. Les principes de confiance

| Règle | Le Responsive |
|---|---|
| RST-01 | **ne cache jamais** : adapter n'est jamais retirer une information due (AFT-01). |
| RST-02 | **ne surprend jamais** : le changement d'appareil ne produit aucun comportement inattendu (PX-04). |
| RST-03 | **ne change jamais le comportement** : mêmes réponses, mêmes protections, mêmes états. |
| RST-04 | **ne change jamais les responsabilités** : les frontières P9 valent sur tout appareil. |
| RST-05 | **ne change jamais les plateformes** : cinq plateformes, partout. |
| RST-06 | **ne change jamais le langage** : navigation, interaction, visuel, mouvement, composants — un seul langage, sur tout support. |

Ces principes sont **perpétuels**.

---

## 10. Mobile First

| Règle | Énoncé |
|---|---|
| RSMF-01 | **Le Mobile est la référence officielle** : l'expérience se définit sur téléphone, dans la main, au pouce. |
| RSMF-02 | **Toutes les adaptations naissent du Mobile** : on adapte depuis la référence, jamais vers elle. |
| RSMF-03 | **Desktop est une adaptation. Jamais une référence. Jamais une origine** (MSMF-07). |
| RSMF-04 | Un doute d'adaptation se tranche par la question : « que fait le Mobile ? » — la réponse Mobile est la réponse. |

---

## 11. Gouvernance

| Règle | Énoncé |
|---|---|
| RSG-01 | Toute nouvelle adaptation appartient à cette fondation (§7). |
| RSG-02 | Toute nouvelle disposition appartient à cette fondation (§3.2, §7). |
| RSG-03 | Toute nouvelle stratégie multi-appareil appartient à cette fondation (§3.9). |
| RSG-04 | **Aucun appareil ne possède sa propre expérience.** |
| RSG-05 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 12. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux téléphones, nouveaux pliables | le contexte Téléphone / Pliable, tel quel |
| Tablettes, desktop, web | leurs contextes officiels (§6) — des présentations, jamais des produits |
| TV, wearables, voice, réalité mixte | leurs contextes officiels, avec leurs sous-ensembles déclarés |
| Interfaces futures | le protocole Future Devices (§3.10) : nommer le contexte, les moyens, le sous-ensemble — recevoir tout le reste |

| Règle | Énoncé |
|---|---|
| RSX-01 | Les dix piliers (§3), les dix contextes (§6) et les six niveaux (§7) sont l'invariant décennal. |
| RSX-02 | **L'expérience reste identique. Les présentations évolueront. Jamais les principes.** |
| RSX-03 | Aucune extension ne peut affaiblir la continuité (RSCO), l'évolution bornée (RSE) ni la confiance (RST). |

---

## 13. Gouvernance du document

- Ce document est la **référence officielle** de la continuité d'expérience de Mentora. Il réalise le pilier **Responsiveness** du MES et **clôt la série des sept descendants**.
- Toute vague d'implémentation cite le pilier, le contexte, le niveau et les règles (RSV/RSP/RSN/RSR/RSC/RSL/RSCO/RSE/RST/RSMF/RSG/RSX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis l'[Accessibility Foundation](accessibility-foundation.md) (opposable, AFR-02), puis les autres descendants, puis ce document (MSD-01).
