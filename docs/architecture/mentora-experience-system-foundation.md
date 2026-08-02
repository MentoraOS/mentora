# MENTORA EXPERIENCE SYSTEM FOUNDATION

**Statut** : Référence officielle de toute expérience utilisateur de Mentora. Ce document ouvre le chapitre P10.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucune maquette, aucun pixel, aucun code, aucun composant, aucune couleur, aucune typographie, aucune animation détaillée, aucun pseudo-code.
**Filiation** : le MES sert les fondations P9 — [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) (qui prévaut en cas de conflit), [Home](home-platform-foundation.md), [Consultation](consultation-platform-foundation.md), [Business](business-platform-foundation.md), [AI](ai-platform-foundation.md), [Reputation](reputation-platform-foundation.md), [Account](account-platform-foundation.md). Il ne les remplace jamais.
**Descendance** : les documents Navigation Foundation, Interaction Foundation, Design Language Foundation, Motion Foundation, Component Foundation, Accessibility Foundation et Responsive Foundation découleront directement de cette fondation (§10).

---

## 1. Mission

Le MES n'est **pas un Design System**. Il n'est **pas une bibliothèque de composants**. Il n'est **pas une charte graphique**.

Le MES est le **système officiel qui définit comment un expert vit Mentora** : les comportements, les interactions, les transitions, les règles visuelles, les priorités, les états, les gestes, les animations, les composants — en tant que règles d'expérience.

**Le Design System sera une conséquence du MES.** Jamais l'inverse.

**Mission en une phrase** : définir l'expérience utilisateur officielle de Mentora — et uniquement elle.

Il ne possède jamais : les plateformes métier, les règles métier, les données, les providers, les moteurs, les plateformes système.

---

## 2. Vision

Mentora doit donner l'impression d'utiliser **un système professionnel**. Jamais une succession d'écrans.

| Règle | Énoncé |
|---|---|
| MSV-01 | L'utilisateur **ne navigue pas : il progresse naturellement**. Les surfaces s'enchaînent parce que la journée s'enchaîne. |
| MSV-02 | Chaque interaction possède une **intention**. |
| MSV-03 | Chaque mouvement possède une **raison**. |
| MSV-04 | Chaque élément possède une **responsabilité** — un élément sans responsabilité n'existe pas. |
| MSV-05 | L'expérience est **une** : cinq plateformes, un seul système vécu. |

---

## 3. Les piliers du MES

Dix piliers fondateurs. Toute règle d'expérience appartient à exactement un pilier.

### 3.1 Navigation

| | |
|---|---|
| **Mission** | Faire que l'expert sache toujours où il est et comment avancer — sans y penser. |
| **Responsabilités** | Définir la structure de déplacement : racine à cinq entrées (Bottom Navigation, MF-04), profondeur, retours, traversées de frontière explicites, surfaces plein écran (Salle Live). |
| **Frontières** | La navigation applique les règles NAV-01 → NAV-06 de P9.0 ; elle ne décide jamais quelle information remonte (propriété des plateformes). |
| **Ce qu'il influence** | tout enchaînement de surfaces ; l'orientation permanente de l'utilisateur. |
| **Ce qu'il ne possède jamais** | le contenu des surfaces ; les priorités métier ; les remontées. |

### 3.2 Interaction

| | |
|---|---|
| **Mission** | Définir comment l'expert agit : gestes, saisies, confirmations. |
| **Responsabilités** | Définir le vocabulaire des gestes (toucher, glisser, écarter, maintenir), la zone du pouce, les confirmations d'actes importants (UX-06), l'écart d'une proposition en un geste. |
| **Frontières** | L'interaction déclenche des intentions ; l'effet appartient à la plateforme propriétaire. Les gestes système ne sont jamais détournés (MF-09). |
| **Ce qu'il influence** | chaque action de l'utilisateur, sa sûreté et sa rapidité. |
| **Ce qu'il ne possède jamais** | la décision ; l'action métier elle-même ; la validation d'un acte irréversible sans consentement. |

### 3.3 Visual Language

| | |
|---|---|
| **Mission** | Faire que tout se lise immédiatement — la hiérarchie avant l'esthétique. |
| **Responsabilités** | Définir les règles de hiérarchie visuelle : ce qui domine, ce qui s'efface, la lecture verticale, la densité maximale (≤ 6 éléments prioritaires), la distinction fait / proposition IA (AE-06). |
| **Frontières** | Le langage visuel définit des règles de lecture ; les couleurs, typographies et styles concrets appartiendront au Design Language Foundation (descendant), conséquence de ces règles. |
| **Ce qu'il influence** | toute surface ; la vitesse de compréhension (< 5 s, UX-01). |
| **Ce qu'il ne possède jamais** | le contenu ; les priorités métier (publiées par les plateformes) ; les pixels. |

### 3.4 Motion

| | |
|---|---|
| **Mission** | Faire que le mouvement explique — jamais qu'il décore. |
| **Responsabilités** | Définir quand un mouvement est permis : accompagner une transition, montrer une provenance, confirmer un acte. Définir quand il est interdit : distraire, meubler, retarder. |
| **Frontières** | Le Motion définit des intentions de mouvement ; les courbes et durées concrètes appartiendront au Motion Foundation (descendant). Aucune animation ne distrait (PX-06). |
| **Ce qu'il influence** | les transitions entre surfaces et états ; la sensation de continuité. |
| **Ce qu'il ne possède jamais** | le déclenchement (une interaction ou un fait métier) ; le contenu transporté. |

### 3.5 Feedback

| | |
|---|---|
| **Mission** | Faire que chaque acte reçoive une réponse honnête et immédiate. |
| **Responsabilités** | Définir les réponses du système : accusé d'un geste, progression d'un travail, réussite, échec, indisponibilité — tous les états honnêtes (UX-04, fail closed). |
| **Frontières** | Le Feedback dit ce qui s'est passé ; il n'enjolive jamais (un échec est un échec), n'invente jamais (rien de simulé). |
| **Ce qu'il influence** | la confiance de l'utilisateur dans chaque geste. |
| **Ce qu'il ne possède jamais** | le résultat lui-même ; la décision de réessayer (proposée, jamais forcée). |

### 3.6 Components

| | |
|---|---|
| **Mission** | Faire que la même intention se vive toujours de la même façon. |
| **Responsabilités** | Définir les familles de composants d'expérience par intention (carte d'intention, remontée, action principale, état vide, état indisponible…) et leurs règles de comportement. |
| **Frontières** | Le pilier définit des intentions de composants ; leur réalisation concrète appartiendra au Component Foundation (descendant), conséquence du MES. Une carte est une intention, jamais une structure technique (CI-01 du Home). |
| **Ce qu'il influence** | la cohérence de toutes les surfaces de toutes les plateformes. |
| **Ce qu'il ne possède jamais** | le contenu des composants ; le code ; les widgets. |

### 3.7 Accessibility

| | |
|---|---|
| **Mission** | Faire que chaque expert puisse exercer — quelles que soient ses capacités, son appareil, sa connexion. |
| **Responsabilités** | Définir les exigences : lisibilité, cibles atteignables, alternatives aux gestes complexes, compréhension sans couleur seule, tolérance aux connexions dégradées (MF-08). |
| **Frontières** | L'accessibilité est une exigence transversale opposable à tous les piliers ; les critères techniques détaillés appartiendront à l'Accessibility Foundation (descendant). |
| **Ce qu'il influence** | tous les piliers — aucune règle d'expérience n'est valide si elle exclut. |
| **Ce qu'il ne possède jamais** | une surface dédiée : l'accessibilité est partout, jamais un mode à part. |

### 3.8 Responsiveness

| | |
|---|---|
| **Mission** | Faire que la même expérience s'adapte à chaque écran — sans jamais se dédoubler. |
| **Responsabilités** | Définir les règles d'adaptation : Mobile d'abord, une colonne d'intentions, réorganisation tablette (liste + détail), Desktop = adaptation (MF-06, MF-10), grands téléphones (MF-05). |
| **Frontières** | Un seul modèle d'expérience, des dispositions multiples ; jamais un parcours spécifique par appareil. Les points de rupture concrets appartiendront au Responsive Foundation (descendant). |
| **Ce qu'il influence** | chaque surface sur chaque format. |
| **Ce qu'il ne possède jamais** | des fonctionnalités par appareil : aucune capacité n'existe sur Desktop sans exister sur Mobile. |

### 3.9 Focus

| | |
|---|---|
| **Mission** | Protéger l'attention de l'expert — son bien le plus rare. |
| **Responsabilités** | Définir ce qui a le droit d'interrompre (l'imminence, la sécurité), ce qui attend son tour (PRI du Home), le silence des surfaces calmes (l'IA se tait, EV-03/EV-04), le plein écran sans distraction de la Salle Live. |
| **Frontières** | Le Focus arbitre l'attention selon les priorités **publiées** par les plateformes ; il ne crée jamais une priorité. |
| **Ce qu'il influence** | les interruptions, les notifications à l'écran, la sobriété de chaque moment. |
| **Ce qu'il ne possède jamais** | la qualification d'importance (propriété des plateformes) ; le contenu des interruptions. |

### 3.10 Continuity

| | |
|---|---|
| **Mission** | Faire que rien ne se perde et que tout reprenne — l'expérience survit aux interruptions. |
| **Responsabilités** | Définir la reprise : un parcours interrompu (appel, changement d'app, coupure) reprend où il s'était arrêté (UX-08) ; les transitions entre moments de la journée se font sans rupture ; le travail en cours n'est jamais perdu. |
| **Frontières** | La continuité d'expérience s'appuie sur les états publiés par les plateformes ; elle ne stocke jamais elle-même une donnée métier. |
| **Ce qu'il influence** | chaque interruption, chaque reprise, chaque enchaînement de moments. |
| **Ce qu'il ne possède jamais** | les données du travail en cours (propriété des plateformes) ; la session technique (systèmes). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le MES PEUT |
|---|---|
| MSP-01 | Organiser l'expérience. |
| MSP-02 | Définir les comportements. |
| MSP-03 | Définir les interactions. |
| MSP-04 | Définir les transitions. |
| MSP-05 | Définir les priorités visuelles. |
| MSP-06 | Définir les gestes. |
| MSP-07 | Définir les états. |
| MSP-08 | Définir la cohérence de navigation. |

### 4.2 Interdites

| Règle | Le MES NE PEUT JAMAIS |
|---|---|
| MSN-01 | Posséder une plateforme métier. |
| MSN-02 | Décider. |
| MSN-03 | Calculer. |
| MSN-04 | Posséder les données. |
| MSN-05 | Posséder les providers. |
| MSN-06 | Posséder les moteurs. |
| MSN-07 | Posséder la logique métier. |
| MSN-08 | Remplacer les fondations P9 — le MES décrit comment leurs expériences se vivent, jamais ce qu'elles sont. |

---

## 5. Relation avec les plateformes

Le MES décrit uniquement **leur expérience**. Jamais leur logique.

| Plateforme | Ce que le MES lui apporte | Ce qu'il ne touche jamais |
|---|---|---|
| Home Platform | l'expérience de l'agrégation : la colonne d'intentions, les moments vécus sans rupture, le calme des états vides | les remontées, leurs priorités, leurs familles |
| Consultation Platform | l'expérience du cycle : progresser d'étape en étape naturellement, l'imminence qui domine, la Salle plein écran | le cycle de vie, ses étapes, ses états |
| Business Platform | l'expérience de la lecture économique : la hiérarchie des montants, l'honnêteté visuelle des inconnus | les faits financiers, les objectifs, les moments économiques |
| AI Platform | l'expérience de la proposition : citée, comprise en cinq secondes, refusable en un geste | les capacités, les propositions, l'éthique IA (AE) |
| Reputation Platform | l'expérience de la confiance : signaux lisibles immédiatement, preuves dépliables en un geste | les preuves, les signaux, les principes de confiance (RT) |
| Account Platform | l'expérience de l'environnement : la sécurité lisible, les réglages simples, les gestes fréquents immédiats | l'environnement, la sécurité, les principes PE |

| Règle | Énoncé |
|---|---|
| MSR-01 | Une plateforme publie **quoi** ; le MES définit **comment ça se vit**. La frontière ne se traverse dans aucun sens. |
| MSR-02 | Un conflit entre une règle MES et une fondation P9 se résout par P9.0, puis par révision documentaire — jamais par un cas particulier d'implémentation. |
| MSR-03 | Toute nouvelle plateforme reçoit le MES tel quel : l'expérience est une (MSV-05). |

---

## 6. Les principes d'expérience

| Règle | Énoncé |
|---|---|
| PX-01 | L'utilisateur comprend toujours **où il est**. |
| PX-02 | L'utilisateur comprend toujours **ce qui est prioritaire**. |
| PX-03 | L'utilisateur comprend toujours **la prochaine action**. |
| PX-04 | **Aucun écran ne surprend** : tout arrive d'un geste ou d'un fait annoncé. |
| PX-05 | **Aucun écran ne bloque** : toute surface a une sortie (UX-05). |
| PX-06 | **Aucune animation ne distrait** : le mouvement explique ou n'existe pas. |
| PX-07 | **Aucun comportement ne change sans raison** : la même intention se vit toujours de la même façon, partout. |
| PX-08 | **La cohérence est plus importante que l'originalité.** |

Ces principes sont **perpétuels** : aucun document descendant (§10) ne peut les affaiblir.

---

## 7. Mobile First — principe fondateur

Le Mobile First n'est pas une contrainte du MES : il en est un **principe fondateur**, hérité de P9.0 (MF-01 → MF-10) et opposable à chaque pilier.

| Règle | Énoncé |
|---|---|
| MSMF-01 | Une seule main : toute expérience se vit au pouce. |
| MSMF-02 | Lecture verticale. |
| MSMF-03 | Une seule action principale par surface. |
| MSMF-04 | Moins de six éléments prioritaires. |
| MSMF-05 | Navigation au pouce ; Safe Area intégrale. |
| MSMF-06 | Continuité à travers les interruptions. |
| MSMF-07 | **Desktop = adaptation du Mobile. Jamais l'inverse.** |

---

## 8. Gouvernance

Le MES devient la **référence officielle de toute expérience utilisateur**.

| Règle | Énoncé |
|---|---|
| MSG-01 | Aucune nouvelle interaction ne peut être créée sans appartenir au MES. |
| MSG-02 | Aucune animation, aucun geste, aucune navigation, aucun composant, aucun état, aucune transition en dehors du MES. |
| MSG-03 | Toute règle d'expérience appartient à exactement un pilier (§3) ; une règle sans pilier n'existe pas. |
| MSG-04 | Toute vague d'implémentation d'expérience cite le pilier et les règles (MSV/MSP/MSN/MSR/PX/MSMF/MSG/MSX) qu'elle réalise. |
| MSG-05 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise. |

---

## 9. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouvelles plateformes | reçoivent le MES tel quel (MSR-03) — l'expérience est une |
| Nouveaux appareils, pliables, tablettes, desktop, web | le pilier Responsiveness — un modèle, des dispositions |
| TV, automobile | des dispositions et interactions adaptées par les piliers Responsiveness et Interaction — jamais un second système d'expérience |
| Réalité mixte | de nouveaux rendus des mêmes intentions — les piliers demeurent, leurs règles s'étendent par révision |
| Wearables | la remontée essentielle seulement (Focus) : l'imminence et la sécurité d'abord |
| Voice interaction | une modalité d'interaction de plus (pilier Interaction) — les mêmes intentions, dites au lieu d'être touchées |
| Nouveaux paradigmes d'interaction | de nouvelles modalités dans les piliers existants ; un nouveau pilier exige la révision de ce document |

| Règle | Énoncé |
|---|---|
| MSX-01 | Les dix piliers (§3) sont l'invariant décennal : les extensions les enrichissent ; en ajouter ou en retirer exige une révision de ce document. |
| MSX-02 | Toute extension nomme son pilier d'attache avant tout développement. |
| MSX-03 | Aucune extension ne peut affaiblir un principe d'expérience (PX-01 → PX-08) ni le Mobile First (MSMF). |
| MSX-04 | Un nouvel appareil n'apporte jamais une expérience nouvelle : il accueille l'expérience Mentora. |

---

## 10. Descendance documentaire

Les documents suivants **découleront directement** de cette fondation — chacun réalise un ou plusieurs piliers, aucun ne peut contredire le MES :

| Document descendant | Pilier(s) réalisé(s) |
|---|---|
| Navigation Foundation | Navigation, Focus |
| Interaction Foundation | Interaction, Feedback |
| Design Language Foundation | Visual Language |
| Motion Foundation | Motion |
| Component Foundation | Components |
| Accessibility Foundation | Accessibility |
| Responsive Foundation | Responsiveness |

| Règle | Énoncé |
|---|---|
| MSD-01 | Un descendant précise, il ne redéfinit pas : toute règle MES reste opposable telle quelle. |
| MSD-02 | Le pilier Continuity est transversal : chaque descendant doit dire comment il le sert. |
| MSD-03 | Le Design System concret (couleurs, typographies, composants codés) naîtra des descendants — jamais directement du MES, jamais en dehors. |

---

## 11. Gouvernance du document

- Ce document est la **référence officielle** du Mentora Experience System et ouvre le chapitre P10.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) ou une fondation P9, P9.0 prévaut (MSR-02).
