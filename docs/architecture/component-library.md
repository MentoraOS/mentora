# COMPONENT LIBRARY

**Statut** : Référence officielle du langage des composants de Mentora — le catalogue contractuel de la bibliothèque. Septième descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md).
**Portée** : Architecture fonctionnelle uniquement. Aucun widget, aucun Material, aucun Cupertino, aucun Button/Card/Dialog/BottomSheet/AppBar/Scaffold, aucun package, aucun code, aucune implémentation. Ce document traduit le pilier **Components** de la fondation ; les Tokens seront définis en P11.8, les composants Flutter construits en P11.9.
**Préséance** : P9 → P10 → [Accessibility Foundation](accessibility-foundation.md) (**opposable**) → [Global Experience Foundation](global-experience-foundation.md) (**opposable**) → P11.0 → ce document (DSD-01 : il précise, il ne redéfinit rien). Il précise le [COMPONENT FOUNDATION](component-foundation.md) (P10) **sans jamais le redéfinir** : les dix familles d'intention (CF §3) et les six niveaux de composition (CFL) restent l'invariant — la bibliothèque les organise en catalogue (§8), elle ne les remplace pas. Il respecte les six systèmes P11 réalisés ([Color](color-system.md), [Typography](typography-system.md), [Spacing](spacing-system.md), [Elevation & Surface](elevation-surface-system.md), [Iconography](iconography-system.md), [Illustration](illustration-system.md)).
**Niveaux produits (DSD-02)** : Principles et Standards (§7) ; les Tokens et Implementations viendront de P11.8 et P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (le composant est le point où tous les langages se rejoignent — CFT-06) et Documentation (chaque contrat est traçable jusqu'à ses règles amont, §6).
**Continuité (MSD-02)** : un composant garde son comportement à travers toute interruption — l'état repris se rouvre dans le même contrat qu'à sa fermeture.

---

## 1. Mission

**Un composant n'est jamais un widget. Un composant est une responsabilité.**

Il possède : **une intention, un comportement, une hiérarchie, un langage, une relation. Jamais une implémentation.**

**Principe fondateur** :

> **« Un composant est une conversation entre l'expert et le système. »**

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| CLV-01 | Chaque composant possède **une responsabilité officielle. Jamais plusieurs. Jamais ambiguë. Jamais décorative. Jamais spécifique à une plateforme** (CFV-02, CFR-01). |
| CLV-02 | **Le composant sert l'expérience. Jamais la technologie** (DST-06). |
| CLV-03 | Tout composant appartient à une famille d'intention P10 (CFG-02) et à un chapitre du catalogue (§8). |
| CLV-04 | Un composant est un **contrat** (§13) : défini ici, matérialisé ailleurs, jamais inventé en aval. |

---

## 3. Les dix piliers

Dix piliers. Toute règle de la bibliothèque appartient à exactement un pilier.

### 3.1 Semantic Components

| | |
|---|---|
| **Mission** | Faire que chaque composant exprime **une seule intention. Jamais plusieurs** (CFV-01). |
| **Responsabilités** | Tenir l'atomicité contractuelle : un besoin à deux intentions se résout par composition (§3.3), jamais par un composant hybride. |
| **Frontières** | Les intentions viennent des familles P10 ; le pilier les contractualise, il n'en invente pas. |
| **Ce qu'il garantit** | lire le nom d'un composant, c'est savoir ce qu'il fait — et tout ce qu'il ne fait pas. |
| **Ce qu'il ne possède jamais** | un composant à double responsabilité ; une intention nouvelle (révision P10 requise). |

### 3.2 Behavior Consistency

| | |
|---|---|
| **Mission** | Tenir l'équation : **même intention, même comportement. Toujours. Sur toutes les plateformes** (PX-07). |
| **Responsabilités** | Garantir qu'un contrat a un seul comportement : les neuf états (§10), les réponses (Interaction), les mouvements (intentions Motion) — identiques partout, tout le temps. |
| **Frontières** | Le comportement est défini au contrat ; aucune implémentation ni plateforme ne le module (CFR-02). |
| **Ce qu'il garantit** | l'expert apprend un composant une fois — il le connaît partout. |
| **Ce qu'il ne possède jamais** | un comportement contextuel ; une variante d'équipe (CLG-04). |

### 3.3 Component Composition

| | |
|---|---|
| **Mission** | Faire que les composants **se composent. Jamais ne se mélangent.** |
| **Responsabilités** | Tenir la loi de composition : **une responsabilité, un composant** ; l'assemblage monte les niveaux (§7, CFL-01) ; la composition construit l'expérience, pas le composant (CFC-04). |
| **Frontières** | Les niveaux de composition sont ceux du Component Foundation (CFL) ; ce pilier les contractualise. |
| **Ce qu'il garantit** | tout besoin complexe s'exprime en assemblant des contrats simples — jamais en gonflant un contrat. |
| **Ce qu'il ne possède jamais** | un composant-fusion ; un saut de niveau caché (CFL-01). |

### 3.4 Interaction Components

| | |
|---|---|
| **Mission** | Contractualiser l'agir — les composants **respectent l'Interaction Foundation**. |
| **Responsabilités** | Définir les contrats d'action, de confirmation, de saisie, d'attente : chacun **applique** le niveau de protection publié — **ils ne décident jamais des niveaux de protection. Ils les appliquent** (IPR, IR-01). |
| **Frontières** | Les types et protections appartiennent à l'Interaction Foundation ; l'accusé et la réponse aux principes de feedback (IF). |
| **Ce qu'il garantit** | aucun composant ne rend un acte plus laxiste ni plus pénible que son niveau publié (IPR-05). |
| **Ce qu'il ne possède jamais** | un niveau de protection ; un déclenchement sans accusé. |

### 3.5 Information Components

| | |
|---|---|
| **Mission** | Contractualiser le dire — les composants **présentent**. |
| **Responsabilités** | Définir les contrats d'affichage : **ils ne calculent jamais, ne déduisent jamais — ils représentent** (HN-02 généralisé, CFN-02) ; un montant arrive avec sa lecture (BV-02), un inconnu reste inconnu (IND-05). |
| **Frontières** | Les faits appartiennent aux plateformes ; le contrat les affiche à leur niveau visuel (DNV), dans leurs rôles (Color, Typography). |
| **Ce qu'il garantit** | ce qui s'affiche est ce qui est publié — ni plus, ni moins, ni interprété. |
| **Ce qu'il ne possède jamais** | un calcul ; une déduction ; une donnée propre. |

### 3.6 Navigation Components

| | |
|---|---|
| **Mission** | Contractualiser le déplacement — les composants **transportent les parcours officiels**. |
| **Responsabilités** | Définir les contrats de navigation (entrées, traversées, retours, portes) : ils portent les dix types officiels — **ils ne créent jamais leur propre navigation** (NR-01, NG-04). |
| **Frontières** | Les trajets appartiennent à la Navigation Foundation ; les signes à l'Iconography (accompagnés de leur libellé). |
| **Ce qu'il garantit** | aucun composant ne cache un trajet ; aucun raccourci n'existe hors contrat. |
| **Ce qu'il ne possède jamais** | un trajet propre ; une destination. |

### 3.7 Trust Components

| | |
|---|---|
| **Mission** | Contractualiser l'honnêteté — les composants **respectent les preuves, les vérifications, les recommandations IA, les estimations, les avertissements**. |
| **Responsabilités** | Définir les contrats de confiance : le vérifié se déplie vers sa preuve (RT-03), l'IA arrive citée et refusable (AE-04, UX-09), l'estimé ne ressemble jamais au certain (DT-05) — **ils ne modifient jamais leur signification**. |
| **Frontières** | Les significations viennent des rôles Trust/AI (Color, Typography, Iconography) ; le contrat les assemble fidèlement. |
| **Ce qu'il garantit** | la confiance traverse le composant intacte — jamais amplifiée, jamais amoindrie. |
| **Ce qu'il ne possède jamais** | une preuve ; une vérification ; une signification altérée. |

### 3.8 Accessibility Components

| | |
|---|---|
| **Mission** | Faire que chaque contrat soit utilisable par tous. |
| **Responsabilités** | Porter l'exigence opposable : **chaque composant reste utilisable dans tous les contextes** officiels (AFC) ; chaque contrat définit son comportement aux six niveaux d'accès (Percevoir → Reprendre, AFL) ; cibles, alternatives et équivalents textuels de plein droit. |
| **Frontières** | Les critères concrets appartiennent aux Tokens/Implementations sous ces contraintes ; l'Accessibility Foundation prévaut (AFR-02). |
| **Ce qu'il garantit** | un composant inaccessible n'entre pas à la bibliothèque — c'est un défaut bloquant (AFL-02). |
| **Ce qu'il ne possède jamais** | une variante « accessible » à part (AFV-01) ; un état ambigu (AFS-02). |

### 3.9 Global Adaptation

| | |
|---|---|
| **Mission** | Faire que chaque contrat soit international de naissance. |
| **Responsabilités** | Porter l'exigence mondiale : **aucun composant ne suppose une langue, une devise, une culture, un format, un pays** (GE-02, GE-09, GE-11) ; tout contrat accueille les longueurs de texte variables (Spacing — Global Adaptation), les directions LTR/RTL (GE-07), les données canoniques présentées selon les préférences (GE-05/06). |
| **Frontières** | La bibliothèque respecte intégralement la Global Experience Foundation (opposable) ; les configurations arrivent par les plateformes, jamais dans le contrat. |
| **Ce qu'il garantit** | le même composant sert Bamako et Séoul sans variante. |
| **Ce qu'il ne possède jamais** | une hypothèse locale ; un composant « pour un marché ». |

### 3.10 Future Evolution

| | |
|---|---|
| **Mission** | Accueillir demain — **les composants évoluent. Le langage reste identique.** |
| **Responsabilités** | Porter le protocole : un nouveau contrat naît d'une intention P10 existante, entre dans un chapitre du catalogue (§8), définit ses neuf états (§10), ses comportements (§9) et ses six niveaux d'accès — par révision de ce document. |
| **Frontières** | Une intention nouvelle exige la révision du Component Foundation d'abord (CFU-03) ; jamais un contrat improvisé. |
| **Ce qu'il garantit** | le centième contrat parle la langue du premier. |
| **Ce qu'il ne possède jamais** | un contrat en réserve ; un composant spéculatif. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | La Component Library PEUT |
|---|---|
| CLP-01 | Définir les contrats de composants (intention, comportement, hiérarchie, langage, relation). |
| CLP-02 | Organiser le catalogue (§8) et les niveaux (§7). |
| CLP-03 | Définir les comportements (§9) et les états (§10) par contrat. |
| CLP-04 | Définir les exigences d'accessibilité et d'internationalisation par contrat. |
| CLP-05 | Définir le protocole d'ajout et d'évolution des contrats. |

### 4.2 Interdites

| Règle | La Component Library NE PEUT JAMAIS |
|---|---|
| CLN-01 | Posséder la logique métier — **le composant représente, dialogue, guide** ; il ne décide rien. |
| CLN-02 | Calculer ni déduire (CFN-02). |
| CLN-03 | Posséder les plateformes, les données, les providers, les moteurs. |
| CLN-04 | Décrire une implémentation — aucun widget, aucun framework (CFN-07). |
| CLN-05 | Inventer une intention (P10), un état (CF §8), un niveau de protection (IPR) ou une signification (systèmes P11). |
| CLN-06 | Remplacer le MES, le Component Foundation ou la fondation P11 — elle précise, rien de plus. |

---

## 5. Relations avec les plateformes

**Toutes utilisent les mêmes composants. Aucun composant propre à une plateforme** (CFR-01).

| Plateforme | Ce que la bibliothèque lui garantit |
|---|---|
| Home | les contrats de cartes d'intention, remontées et états vides — identiques pour toutes les remontées |
| Consultation | les contrats du cycle (progression, transition, immersion) — la Salle assemblée de contrats, jamais d'exceptions |
| Business | les contrats d'affichage financier (montant + lecture) et d'actes protégés — les mêmes que partout |
| AI | le contrat de proposition citée/refusable — un seul, pour toute l'IA |
| Reputation | les contrats de preuve dépliable et de signal — les mêmes signaux partout |
| Account | les contrats de réglage, de sécurité et de conversation — sans variantes |

| Règle | Énoncé |
|---|---|
| CLPL-01 | Un besoin de plateforme enrichit un contrat commun — pour toutes (CFU-04 : jamais un fork). |
| CLPL-02 | Un contrat ne connaît jamais la plateforme qui l'utilise (CFC-02). |
| CLPL-03 | Toute nouvelle plateforme reçoit le catalogue tel quel (DSR-04). |

---

## 6. Traduction du MES — les règles traduites

Chaque contrat traduit des règles amont, citées explicitement. **Une traduction ne modifie jamais la règle** (DSM-02).

| Règle amont traduite | Traduction en bibliothèque |
|---|---|
| Navigation Foundation — types officiels, NG-04 | Navigation Components (§3.6) : les contrats transportent, ne créent jamais |
| Interaction Foundation — types, IPR, IF | Interaction Components (§3.4) : appliquer les protections, accuser toujours |
| Design Language — DNV, DPV, états visuels | Information Components (§3.5) : présenter aux niveaux et rôles officiels |
| Motion Foundation — les 8 intentions (MI) | tout mouvement de composant sert une intention officielle — jamais pour vivre |
| Accessibility Foundation — AFL, AFS, AFC | Accessibility Components (§3.8) : six niveaux d'accès par contrat, opposable |
| Responsive Foundation — RSL, RSCO | Behavior Consistency (§3.2) : même contrat, présentations adaptées |
| Global Experience Foundation — GE-02/05/06/07/09/11 | Global Adaptation (§3.9) |
| Component Foundation — familles, CFL, CFS, CFU, CFC | l'ossature entière : la bibliothèque contractualise ce que P10 a défini |
| Color System — rôles et états (§4, §5) | chaque contrat consomme ses rôles — jamais une couleur arbitraire (CSE-01) |
| Typography System — rôles et hiérarchie (§4, §5) | chaque contrat écrit dans ses rôles — jamais un texte hors rôle (TSV-03) |
| Spacing System — lois spatiales | chaque contrat respire selon les lois — jamais un espacement local (SPG-01) |
| Elevation & Surface — significations et contenants | chaque contrat vit dans sa surface d'intention (Content Containment) |
| Iconography — significations et accompagnement (ICA) | chaque contrat signe dans le vocabulaire officiel — jamais une icône locale |
| Illustration — situations et états (ILE) | les contrats d'états vides et premiers pas accueillent l'illustration selon ses lois |

| Règle | Énoncé |
|---|---|
| CLM-01 | Tout contrat cite ses règles amont (DSM-01) ; un contrat sans origine est rejeté. |
| CLM-02 | Un manque découvert face à une règle amont remonte en révision — jamais comblé par un contrat improvisé (DSM-03, GE-15). |

---

## 7. Les niveaux

Dix niveaux — l'échelle unifiée : les six niveaux de composition du Component Foundation (CFL), prolongés par les niveaux de production du Design System (DSL). La production descend toujours ; la composition monte toujours.

| Niveau | Mission | Responsabilités | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Primitive** | l'atome (CFL) | être insécable et muet sur le métier | textes, formes, signes | un comportement ; un état métier |
| **Element** | la plus petite intention (CFL) | porter UNE intention d'UNE famille | des primitives | un autre element |
| **Block** | l'intention autoportante (CFL) | assembler des elements pour une seule intention | des elements | une navigation ; un autre block |
| **Section** | le temps de lecture (CFL) | ordonner des blocks selon les priorités publiées | des blocks | une action globale court-circuitante |
| **Surface** | la réponse à une question (CFL) | composer des sections en lecture verticale | des sections | une seconde question ; une autre surface |
| **Flow** | le parcours (CFL) | enchaîner des surfaces par la navigation officielle | des surfaces, des transitions | un raccourci hors navigation |
| **Pattern** | la réponse récurrente (DSL) | codifier les assemblages éprouvés (carte d'intention, confirmation, attente) | des compositions nommées | un pattern à usage unique ; un pattern contraire à une fondation |
| **Library** | le réutilisable fabriqué (DSL) | tenir le catalogue des contrats et leurs définitions complètes | les contrats, leurs états, leur documentation | un contrat hors famille ; un fork ; un doublon |
| **Token** | les valeurs nommées (DSL) | (produit par P11.8) chaque contrat reçoit ses valeurs | la nomenclature contrat → valeurs | une signification nouvelle |
| **Implementation** | la technologie (DSL) | (produit par P11.9) matérialiser fidèlement les contrats | le code des kits | une décision de design ; un composant hors catalogue |

| Règle | Énoncé |
|---|---|
| CLL-01 | Les six premiers niveaux appartiennent au Component Foundation (CFL — cités, non redéfinis) ; les quatre derniers à la production P11 (DSL). |
| CLL-02 | Un contrat se définit au niveau Library ; il se compose aux niveaux CFL ; il se matérialise aux niveaux Token/Implementation. |

---

## 8. Les familles officielles — le catalogue

Dix-neuf chapitres de catalogue. **Les familles expriment des intentions. Jamais des écrans.**

*Règle d'ancrage* : les **dix familles d'intention du Component Foundation restent l'invariant** (CFX-01) ; chaque chapitre du catalogue déclare son ancrage — le catalogue organise, il ne redéfinit pas.

| Chapitre | Intentions cataloguées | Ancrage P10 (CF §3) |
|---|---|---|
| **Display** | montrer un fait à son niveau | Information, Presentation |
| **Navigation** | entrer, revenir, traverser | Navigation |
| **Information** | dire, préciser, contextualiser | Information |
| **Action** | agir, une action principale | Action |
| **Selection** | choisir, défaire | Selection |
| **Input** | saisir sans jamais perdre | Input |
| **Confirmation** | consentir en connaissance | Confirmation |
| **Progress** | montrer l'avancement réel | Progression |
| **Attention** | signaler à l'intensité juste | Attention |
| **Immersion** | contenir l'acte total | Immersion |
| **Trust** | prouver, citer, distinguer | Information (+ rôles Trust) |
| **Business** | les contrats économiques (montant + lecture, objectif) | Information, Action, Progression |
| **Consultation** | les contrats du cycle (étape, imminence, porte de salle) | Information, Action, Immersion |
| **Communication** | converser, notifier | Information, Action, Attention |
| **System** | l'environnement (réglage, aide) | Information, Action, Selection |
| **Recovery** | reprendre, restituer | Information, Action |
| **AI** | proposer cité, accueillir/écarter | Information, Action (+ rôles AI) |
| **Security** | protéger, alerter, consentir | Attention, Confirmation |
| **Workspace** | le contexte d'espace de travail | Information, Selection |

| Règle | Énoncé |
|---|---|
| CLF-01 | Tout contrat appartient à exactement un chapitre, et chaque chapitre déclare son ancrage P10 — jamais d'intention orpheline. |
| CLF-02 | Un chapitre nouveau exige la révision de ce document ; une intention nouvelle exige d'abord celle du Component Foundation (CFU-03). |

---

## 9. Les comportements

Un composant : **apparaît, évolue, attend, répond, échoue, reprend, disparaît. Jamais de manière arbitraire.**

| Comportement | Règle contractuelle |
|---|---|
| **Apparaît** | par un fait publié ou un geste (Entrance Motion) — jamais par défaut, jamais sous le doigt (RF-04). |
| **Évolue** | par changement d'état publié, dans le même contrat (Context Motion) — jamais de mutation d'intention. |
| **Attend** | honnêtement (Waiting) : le travail réel, une issue toujours (IW). |
| **Répond** | toujours et immédiatement (IF-01/02) : l'accusé puis le résultat. |
| **Échoue** | localement, en expliquant, en préservant (IE) — l'échec ne mute jamais le contrat. |
| **Reprend** | au pas exact, contexte dit (Recovery) — jamais rejoué. |
| **Disparaît** | quand sa raison cesse (Exit, DIS) — sans trace fantôme. |

| Règle | Énoncé |
|---|---|
| CLB-01 | Les sept comportements sont définis par contrat — un comportement non défini est interdit (l'équivalent comportemental de CFS-03). |
| CLB-02 | Aucun comportement arbitraire : chaque comportement cite son intention de mouvement (MI) et sa réponse d'interaction. |

---

## 10. Les états

Neuf états officiels : **Disponible, Indisponible, Attente, Erreur, Succès, Attention, Sélection, Focus, Immersion.**

**Tous héritent du Component Foundation (CF §8) et de l'Elevation & Surface System (§7). Aucun nouvel état.**

| Règle | Énoncé |
|---|---|
| CLE-01 | Chaque contrat définit son comportement pour chacun des états qui le concernent — un état non défini est un état interdit (CFS-03). |
| CLE-02 | Les états s'expriment dans les rôles officiels (Color §5, Typography, Iconography States) — jamais une expression locale. |
| CLE-03 | L'Immersion n'appartient qu'aux contrats du chapitre Immersion — déclarée par la navigation (ESE-01). |

---

## 11. Les principes de confiance

| Règle | Les composants |
|---|---|
| CLT-01 | **ne mentent jamais** (CFT-01). |
| CLT-02 | **ne manipulent jamais** (CFT-04). |
| CLT-03 | **ne dramatisent jamais** (IV-03). |
| CLT-04 | **ne remplacent jamais une donnée** : le contrat affiche le publié, jamais un substitut. |
| CLT-05 | **ne remplacent jamais une preuve** (RT-03, CSA-02). |
| CLT-06 | **ne remplacent jamais une décision** : la décision reste à l'expert, toujours (AE-03, AIN-01 respectés au niveau du contrat). |
| CLT-07 | **restent intemporels** (DST-05). |

Ces principes sont **perpétuels**.

---

## 12. Mobile First

| Règle | Énoncé |
|---|---|
| CLMF-01 | **Chaque composant naît sur Mobile** : le contrat se définit dans la main, au pouce (DSMF-01). |
| CLMF-02 | **Desktop, tablette, TV, pliable sont des adaptations. Jamais des variantes** : le même contrat, présenté autrement (RSR-01). |
| CLMF-03 | Un contrat invalide sur Mobile est invalide partout (DSMF-03). |

---

## 13. Le composant comme contrat

**Un composant Mentora est un contrat.**

- **Lorsqu'un développeur Flutter implémente un composant, il n'invente rien. Il matérialise un contrat déjà défini.**
- **Lorsqu'un designer dessine un composant, il ne crée rien. Il représente ce contrat.**
- **Lorsqu'un Product Manager demande une évolution, il enrichit le contrat. Jamais l'implémentation.**

| Règle | Énoncé |
|---|---|
| CLC-01 | Le contrat précède toute matérialisation : rien ne se code, ne se dessine ni ne se spécifie hors d'un contrat du catalogue. |
| CLC-02 | Toute évolution passe par le contrat : l'implémentation et le design suivent — jamais l'inverse. |
| CLC-03 | Un écart entre une matérialisation et son contrat est un défaut de la matérialisation — le contrat fait foi. |
| CLC-04 | **Cette philosophie du contrat devient un pilier du Design System** : elle vaut pour tout descendant P11 et toute implémentation future. |

---

## 14. Gouvernance

| Règle | Énoncé |
|---|---|
| CLG-01 | **Aucun composant hors bibliothèque** (CFG-04, DSG-03). |
| CLG-02 | **Aucun fork** (CFU-04). |
| CLG-03 | **Aucune variante locale** (CFU-03). |
| CLG-04 | **Aucune équipe ne crée sa propre bibliothèque** (DSC-04). |
| CLG-05 | **Les violations deviendront des balayages exécutables** dès la première vague d'implémentation (composants hors catalogue, forks, variantes, comportements divergents : détectables et interdits). |

---

## 15. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Pliables, tablettes, desktop, TV | les mêmes contrats, présentations adaptées (RSL) — jamais des variantes |
| Wearables | le sous-ensemble essentiel des contrats (Information, Attention, Confirmation) — inchangés |
| Réalité mixte | les mêmes contrats dans l'espace ; l'Immersion garde ses lois |
| **Voice** | **un composant devient une interaction conversationnelle sans interface visuelle** : le contrat survit à l'écran — l'intention se dit (Information énonce, Confirmation demande l'accord explicite, Attention signale par le ton, Progress annonce l'avancement) ; **les mêmes intentions doivent survivre sans écran** — c'est le contrat (intention + comportement + états), et non sa forme visuelle, qui est l'invariant : chaque contrat définit son énoncé conversationnel au même titre que sa forme |
| Nouveaux appareils | le protocole Future Evolution (§3.10) |

| Règle | Énoncé |
|---|---|
| CLX-01 | Les dix piliers (§3), les dix-neuf chapitres (§8), les dix niveaux (§7) et les neuf états (§10) sont l'invariant décennal. |
| CLX-02 | **Les composants évoluent. Le langage reste identique.** |
| CLX-03 | Aucune extension ne peut affaiblir l'Accessibility Components (§3.8) ni la Global Adaptation (§3.9) — les deux opposables. |

---

## 16. Gouvernance du document

- Ce document est la **référence officielle** du catalogue contractuel des composants de Mentora — septième descendant du Design System, traduisant le pilier **Components**.
- **Conformité aux fondations opposables** : l'Accessibility Foundation est servie par Accessibility Components (§3.8 — chaque contrat utilisable dans tous les contextes, six niveaux d'accès par contrat, un composant inaccessible n'entre pas à la bibliothèque) et opposable (AFR-02, CLX-03) ; la Global Experience Foundation est servie par Global Adaptation (§3.9 — aucune hypothèse de langue, devise, culture, format ou pays ; LTR/RTL ; données canoniques présentées par préférences) et opposable de même (GE-15).
- Toute vague d'implémentation cite le pilier, le chapitre, le niveau, l'état et les règles (CLV/CLP/CLN/CLPL/CLM/CLL/CLF/CLB/CLE/CLT/CLMF/CLC/CLG/CLX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10 (dont le Component Foundation), puis les fondations opposables (Accessibility, Global Experience), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md), puis ce document (DSD-01).
