# ACCESSIBILITY FOUNDATION

**Statut** : Référence officielle de l'accessibilité de Mentora.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun code, aucune API, aucune implémentation, aucun pseudo-code, aucune maquette. Cette fondation ne décrit aucune technologie d'assistance ni aucun standard technique — elle décrit **le langage officiel de l'accessibilité dans Mentora**. Les implémentations techniques viendront plus tard.
**Filiation** : sixième descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) — il réalise officiellement le pilier **Accessibility** (MSD-01 : il précise, ne redéfinit pas). Le pilier est **transversal** : ses exigences sont opposables à tous les autres piliers et à toutes les fondations descendantes ([Navigation](navigation-foundation.md), [Interaction](interaction-foundation.md), [Design Language](design-language-foundation.md), [Motion](motion-foundation.md), [Component](component-foundation.md)) ; P9.0 prévaut en cas de conflit. Le futur Responsive Foundation devra respecter cette fondation.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par son pilier Recovery (§3.7) et son niveau Reprendre (§7) — l'accès à son travail survit à toute interruption, pour tous.

---

## 1. Mission

**Mission en une phrase** : définir la manière dont Mentora reste utilisable par **tous** les experts, dans **tous** les contextes — et rien d'autre.

Elle ne possède jamais : les plateformes métier, les données, les composants, les providers, les moteurs, les plateformes système, la logique métier.

---

## 2. Vision

Dans Mentora, **l'accessibilité n'est jamais une option**. Elle fait partie de l'expérience.

| Règle | Énoncé |
|---|---|
| AFV-01 | L'accessibilité n'est pas un mode : c'est **la** manière dont Mentora est conçu (jamais un mode à part — pilier Accessibility du MES). |
| AFV-02 | **Une interface accessible est une interface plus claire. Plus rapide. Plus fiable. Pour tout le monde** : chaque exigence d'accessibilité améliore l'expérience de tous. |
| AFV-03 | L'accessibilité se pense au moment de concevoir — jamais en rattrapage. |
| AFV-04 | Un expert empêché d'exercer par l'interface est un échec d'architecture — pas un cas particulier. |

---

## 3. Les piliers de l'accessibilité

Dix piliers. Toute exigence d'accessibilité appartient à exactement un pilier.

### 3.1 Perception

| | |
|---|---|
| **Mission** | Faire que tout ce qui compte puisse être perçu — quelles que soient les capacités sensorielles. |
| **Responsabilités** | Exiger que toute information essentielle existe sous plus d'une forme perceptible ; que rien d'important ne repose sur une seule dimension sensorielle (jamais la couleur seule, jamais le son seul, jamais le mouvement seul). |
| **Frontières** | La perception exige des formes multiples ; les moyens concrets (contrastes chiffrés, tailles) appartiendront au Design System sous ces contraintes. |
| **Ce qu'il garantit** | personne ne rate une information due parce qu'un sens lui manque ou lui fait défaut à cet instant. |
| **Ce qu'il ne possède jamais** | le contenu ; les seuils techniques. |

### 3.2 Compréhension

| | |
|---|---|
| **Mission** | Faire que tout se comprenne — sans prérequis, sans jargon, sans devinette. |
| **Responsabilités** | Exiger le langage de l'expert (UX-10), des intentions explicites (une forme dit sa fonction — Clarity), des conséquences annoncées avant les actes. |
| **Frontières** | La compréhension juge la formulation et la structure ; le contenu métier appartient aux plateformes. |
| **Ce qu'il garantit** | comprendre ne dépend ni du niveau technique, ni de la familiarité avec les conventions numériques. |
| **Ce qu'il ne possède jamais** | les textes métier ; la simplification du métier lui-même. |

### 3.3 Navigation

| | |
|---|---|
| **Mission** | Faire que se déplacer soit possible pour tous — quel que soit le moyen d'entrée. |
| **Responsabilités** | Exiger que tout trajet officiel (Navigation Foundation) soit accomplissable sans geste complexe ; que l'ordre de parcours suive l'ordre de sens ; que « où suis-je » soit toujours restituable. |
| **Frontières** | Les trajets appartiennent à la Navigation Foundation ; ce pilier exige leur praticabilité universelle. |
| **Ce qu'il garantit** | aucun endroit de Mentora n'est réservé à ceux qui peuvent accomplir un geste précis. |
| **Ce qu'il ne possède jamais** | les trajets eux-mêmes ; les profondeurs. |

### 3.4 Interaction

| | |
|---|---|
| **Mission** | Faire que chaque acte soit accomplissable par tous — et pardonnable par tous. |
| **Responsabilités** | Exiger des cibles atteignables, des alternatives à tout geste complexe, du temps suffisant (jamais de compte à rebours punitif), le droit à l'erreur (annuler, corriger). |
| **Frontières** | Les types et protections appartiennent à l'Interaction Foundation ; ce pilier exige leur accomplissement universel. |
| **Ce qu'il garantit** | agir ne demande jamais une précision, une vitesse ou une force particulières. |
| **Ce qu'il ne possède jamais** | les niveaux de protection ; les effets des actes. |

### 3.5 Feedback

| | |
|---|---|
| **Mission** | Faire que chaque réponse du système atteigne tout le monde. |
| **Responsabilités** | Exiger que tout accusé, résultat, erreur et succès soit perceptible sous plus d'une forme ; que l'intensité serve le sens, pas l'effet. |
| **Frontières** | Le contenu des réponses appartient à l'Interaction Foundation ; ce pilier exige leur perceptibilité universelle. |
| **Ce qu'il garantit** | personne n'agit dans le vide : la réponse arrive, perceptible, pour tous. |
| **Ce qu'il ne possède jamais** | les réponses elles-mêmes. |

### 3.6 Focus

| | |
|---|---|
| **Mission** | Faire que l'attention se place — et se voie — pour tous. |
| **Responsabilités** | Exiger qu'un seul élément reçoive le focus à la fois (état En focus), que le focus soit toujours perceptible, que son ordre suive le sens de lecture. |
| **Frontières** | Ce qui mérite l'attention appartient aux plateformes et au pilier Focus du MES ; ce pilier garantit que le focus se perçoit et se déplace pour tous. |
| **Ce qu'il garantit** | on sait toujours où l'on est dans la surface — même sans la voir. |
| **Ce qu'il ne possède jamais** | les priorités ; les interruptions. |

### 3.7 Recovery

| | |
|---|---|
| **Mission** | Faire que se tromper, être interrompu ou perdre le fil ne coûte jamais l'accès. |
| **Responsabilités** | Exiger que toute reprise (Recovery Navigation/Interaction) soit praticable par tous ; que l'erreur soit réparable sans expertise ; que rien d'essentiel ne dépende de la mémoire de l'utilisateur. |
| **Frontières** | La reprise appartient aux fondations Navigation et Interaction ; ce pilier exige son universalité. |
| **Ce qu'il garantit** | l'accès survit à l'erreur, à l'oubli et à l'interruption. |
| **Ce qu'il ne possède jamais** | les états repris ; les parcours. |

### 3.8 Context

| | |
|---|---|
| **Mission** | Faire que Mentora reste utilisable dans les contextes réels de l'expert — pas seulement au calme. |
| **Responsabilités** | Exiger l'utilisabilité dans les contextes officiels (§6) : une main, plein soleil, fatigue, stress, connexion dégradée ; imposer que le contexte le plus défavorable soit le cas de conception. |
| **Frontières** | Le contexte technique (réseau, appareil) appartient aux mécanismes ; ce pilier exige que l'expérience y survive honnêtement (MF-08). |
| **Ce qu'il garantit** | Mentora fonctionne dans la vraie vie — celle d'un expert pressé, fatigué, mal connecté. |
| **Ce qu'il ne possède jamais** | la détection du contexte ; les états réseau. |

### 3.9 Readability

| | |
|---|---|
| **Mission** | Faire que lire soit facile — pour tous les yeux, toutes les langues de l'expert, tous les niveaux de lecture. |
| **Responsabilités** | Exiger la lisibilité (taille adaptable, lignes courtes, hiérarchie nette), des textes courts et directs, des nombres et dates lisibles dans les conventions de l'expert. |
| **Frontières** | Les règles typographiques concrètes appartiendront au Design System sous ces contraintes ; les textes métier aux plateformes. |
| **Ce qu'il garantit** | lire Mentora ne fatigue pas et n'exclut pas. |
| **Ce qu'il ne possède jamais** | les polices ; les tailles ; les contenus. |

### 3.10 Inclusion

| | |
|---|---|
| **Mission** | Faire que personne ne soit laissé dehors — par conception. |
| **Responsabilités** | Porter les principes d'inclusion (§9) ; exiger que toute nouvelle capacité soit pensée pour tous dès sa conception ; interdire toute expérience à deux vitesses. |
| **Frontières** | L'inclusion est le juge de paix des neuf autres piliers — elle n'a pas de territoire propre : elle a droit de regard sur tout. |
| **Ce qu'il garantit** | l'égalité d'accès à l'exercice du métier. |
| **Ce qu'il ne possède jamais** | un « mode accessible » séparé (AFV-01). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | L'Accessibility Foundation PEUT |
|---|---|
| AFP-01 | Définir les principes d'accès. |
| AFP-02 | Définir les comportements universels. |
| AFP-03 | Définir la compréhension. |
| AFP-04 | Définir les règles de lisibilité. |
| AFP-05 | Définir les priorités. |
| AFP-06 | Définir les aides. |
| AFP-07 | Définir les comportements inclusifs. |

### 4.2 Interdites

| Règle | L'Accessibility Foundation NE PEUT JAMAIS |
|---|---|
| AFN-01 | Décider. |
| AFN-02 | Calculer. |
| AFN-03 | Posséder les plateformes métier. |
| AFN-04 | Posséder les données. |
| AFN-05 | Posséder les composants. |
| AFN-06 | Posséder Flutter. |
| AFN-07 | Posséder les APIs. |
| AFN-08 | Remplacer le MES — elle précise son pilier Accessibility, rien de plus. |

---

## 5. Relation avec les plateformes

**Toutes les plateformes deviennent accessibles grâce aux mêmes principes. Aucune plateforme ne définit ses propres règles.**

| Plateforme | Ce que l'accessibilité y garantit en particulier |
|---|---|
| Home | la journée se perçoit et se comprend en un regard — ou en une écoute ; les remontées s'écartent sans précision de geste |
| Consultation | l'entrée en salle, l'acte et la sortie sont praticables dans le stress d'une consultation imminente ; l'imminence est perceptible sous plusieurs formes |
| Business | l'argent se lit sans ambiguïté ; les actes financiers sont accomplissables sans précision ni vitesse ; l'inconnu ne se confond jamais avec un montant |
| AI | accueillir et écarter une proposition sont aussi simples l'un que l'autre, pour tous ; la provenance IA est perceptible sous plusieurs formes |
| Reputation | les signaux de confiance se perçoivent sans dépendre d'une seule forme ; répondre à un avis est praticable en mobilité |
| Account | la sécurité se comprend sans expertise ; les actes protégés laissent le temps ; rien d'essentiel ne dépend de la mémoire |

| Règle | Énoncé |
|---|---|
| AFR-01 | Les principes sont uniques et transversaux : aucune plateforme n'a de règles d'accessibilité propres. |
| AFR-02 | Une exigence d'accessibilité prime sur une préférence esthétique — toujours (l'accessible est opposable, §9 du Design Language). |
| AFR-03 | Toute nouvelle plateforme reçoit la fondation telle quelle (MSR-03). |

---

## 6. Les contextes d'utilisation

Dix contextes officiels. **Le contexte le plus défavorable est le cas de conception.**

| Contexte | Exigences |
|---|---|
| **Une seule main** | tout l'essentiel au pouce (MF-02) ; jamais deux mains requises pour un acte du quotidien |
| **Faible luminosité** | lisible sans éblouir ; rien ne disparaît dans le sombre |
| **Forte luminosité** | lisible en plein soleil ; les distinctions survivent à l'écran délavé |
| **Fatigue** | comprendre ne demande pas d'effort ; les gestes restent simples ; les erreurs pardonnent |
| **Stress** | l'imminence et la sécurité restent claires quand l'esprit est ailleurs ; l'urgence est calme (DPV-05) |
| **Connexion dégradée** | l'état honnête (MF-08) ; consulter reste possible ; rien ne se perd |
| **Interruption** | figer et reprendre sans coût (NI, Recovery) |
| **Voice** | l'essentiel se dit et s'entend : mêmes niveaux d'information, mêmes protections |
| **Wearable** | l'essentiel seulement, perceptible d'un regard |
| **Petit écran** | rien d'essentiel sacrifié : la hiérarchie protège le prioritaire (MF-05) |

| Règle | Énoncé |
|---|---|
| AFC-01 | Une surface qui échoue dans un contexte officiel n'est pas terminée. |
| AFC-02 | Tout nouveau contexte s'ajoute par révision de ce document. |

---

## 7. Les niveaux d'accessibilité

Six niveaux — chacun garantit un droit, dans l'ordre du parcours de tout acte :

| Niveau | Ce qu'il garantit |
|---|---|
| **Percevoir** | l'information due m'atteint, sous une forme que je peux recevoir. |
| **Comprendre** | je sais ce que c'est, ce que ça implique, ce que je peux faire. |
| **Agir** | je peux accomplir l'acte, avec mes moyens, à mon rythme. |
| **Confirmer** | je sais que mon acte est pris en compte, et ce qu'il a produit. |
| **Retrouver** | je peux revenir à ce que je cherchais — rien d'important ne m'est caché ni perdu. |
| **Reprendre** | après une erreur ou une interruption, je continue — sans recommencer, sans pénalité. |

| Règle | Énoncé |
|---|---|
| AFL-01 | Tout parcours de Mentora garantit les six niveaux, dans tous les contextes officiels (§6). |
| AFL-02 | Un niveau manquant sur un parcours est un défaut bloquant — pas une amélioration future. |

---

## 8. Les états accessibles

Les huit états des composants (§8 du Component Foundation) sont soumis à trois exigences :

| Règle | Énoncé |
|---|---|
| AFS-01 | **Tous les états restent perceptibles** — disponible, indisponible, erreur, succès, attente, attention, focus, sélection : chacun sous plus d'une forme (jamais la couleur seule). |
| AFS-02 | **Jamais ambigus** : deux états différents ne peuvent pas se percevoir pareil ; l'indisponible ne se confond ni avec le vide ni avec le désactivé. |
| AFS-03 | **Jamais cachés** : un état qui change se signale ; un état durable reste constatable à tout moment. |

---

## 9. Les principes d'inclusion

| Règle | Énoncé |
|---|---|
| AFI-01 | **Aucune discrimination** : l'expérience ne présuppose ni capacité, ni âge, ni équipement haut de gamme. |
| AFI-02 | **Aucune exclusion** : aucun parcours, aucune information, aucun acte réservé à ceux qui voient, entendent, ou touchent d'une façon donnée. |
| AFI-03 | **Aucune dépendance à une seule capacité** : rien d'essentiel ne repose sur un seul sens, un seul geste, une seule aptitude. |
| AFI-04 | **Toujours plusieurs moyens de comprendre** : la forme, le texte, la structure — jamais un seul canal porteur du sens. |
| AFI-05 | **Toujours plusieurs moyens d'agir** : tout acte a une alternative au geste qui le porte le plus naturellement. |

Ces principes sont **perpétuels**.

---

## 10. Les principes de confiance

| Règle | L'accessibilité |
|---|---|
| AFT-01 | **ne cache jamais** : rendre accessible n'est jamais un prétexte pour retirer de l'information. |
| AFT-02 | **ne complique jamais** : l'accessibilité simplifie — une aide qui complique n'en est pas une. |
| AFT-03 | **ne ralentit jamais** : l'accessible est aussi le plus rapide (AFV-02). |
| AFT-04 | **respecte toujours la dignité** : aucune aide stigmatisante, aucun traitement « à part ». |
| AFT-05 | **respecte toujours le contrôle de l'expert** : les aides se proposent, ne s'imposent pas ; les choix d'assistance sont respectés partout (PE-04). |
| AFT-06 | **ne crée jamais d'obstacle inutile** : toute friction se justifie par une protection (IPR-01) — jamais par une contrainte d'accessibilité mal conçue. |

Ces principes sont **perpétuels**.

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| AFMF-01 | L'accessibilité est pensée d'abord pour **le mobile** : une seule main, le pouce (MF-02). |
| AFMF-02 | **Lecture verticale** : l'ordre de lecture est l'ordre de sens — pour les yeux comme pour toute autre forme de parcours. |
| AFMF-03 | **Gestes simples** : aucun geste complexe sans alternative (AFI-05). |
| AFMF-04 | **Compréhension immédiate** : < 5 s pour tous, pas seulement pour les habitués (UX-01). |
| AFMF-05 | **Desktop = adaptation. Jamais l'inverse** (MSMF-07) : l'accessibilité mobile n'est jamais dégradée au profit d'un autre format. |

---

## 12. Gouvernance

| Règle | Énoncé |
|---|---|
| AFG-01 | Toute nouvelle règle d'accessibilité appartient à cette fondation. |
| AFG-02 | Toute nouvelle aide appartient à cette fondation. |
| AFG-03 | Toute nouvelle interaction respecte cette fondation — l'accessibilité est opposable à toute conception (AFR-02). |
| AFG-04 | Toute nouvelle plateforme applique cette fondation telle quelle. |
| AFG-05 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Flutter, Web, Desktop | des implémentations des mêmes principes — les techniques d'assistance concrètes arrivent avec elles, sous ces contraintes |
| TV | percevoir et comprendre à distance ; les six niveaux (§7) valent à trois mètres |
| Wearables | l'essentiel perceptible d'un regard ; jamais un canal unique |
| Voice | un moyen d'accès de première classe — pas une aide annexe : mêmes niveaux, mêmes protections |
| Réalité mixte | les principes d'inclusion y précèdent toute conception : l'espace n'exclut pas |
| Nouveaux appareils | reçoivent les piliers, les contextes et les niveaux tels quels |

| Règle | Énoncé |
|---|---|
| AFX-01 | Les dix piliers (§3), les dix contextes (§6) et les six niveaux (§7) sont l'invariant décennal. |
| AFX-02 | **Les principes restent identiques. Seules les implémentations évolueront.** |
| AFX-03 | Aucune extension ne peut affaiblir l'inclusion (AFI) ni la confiance (AFT). |

---

## 14. Gouvernance du document

- Ce document est la **référence officielle** de l'accessibilité de Mentora. Il réalise le pilier **Accessibility** du MES — transversal et opposable à toutes les fondations.
- Toute vague d'implémentation cite le pilier, le contexte, le niveau et les règles (AFV/AFP/AFN/AFR/AFC/AFL/AFS/AFI/AFT/AFMF/AFG/AFX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis cette fondation est opposable aux autres descendants (AFR-02) — un conflit avec eux se résout en faveur de l'accessibilité ou par révision documentaire explicite.
