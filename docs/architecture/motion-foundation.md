# MOTION FOUNDATION

**Statut** : Référence officielle du langage du mouvement de Mentora.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun composant, aucune animation, aucun timing, aucune courbe, aucune durée, aucun code, aucun pseudo-code, aucune maquette. Cette fondation ne décrit aucune technique d'animation — elle décrit **le langage du mouvement dans Mentora**. Les implémentations techniques viendront plus tard.
**Filiation** : quatrième descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) — il réalise officiellement le pilier **Motion** (MSD-01 : il précise, ne redéfinit pas). Il respecte les fondations [Navigation](navigation-foundation.md) (dont les principes de transition NTR-01 → NTR-06), [Interaction](interaction-foundation.md) et [Design Language](design-language-foundation.md) ; P9.0 prévaut en cas de conflit. Les descendants Component, Accessibility et Responsive devront le respecter. Les durées et courbes concrètes appartiendront au Design System (MSD-03).
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par essence — le mouvement est le principal outil qui montre la continuité (§3.10, §9) : rien ne se téléporte, tout changement s'explique en se produisant.

---

## 1. Mission

**Mission en une phrase** : définir la manière dont le mouvement participe à l'expérience — quand bouger, pourquoi bouger, ce que chaque mouvement explique — et rien d'autre.

Il ne possède jamais : les plateformes métier, les données, les composants, les providers, les moteurs, la logique métier, les plateformes système.

---

## 2. Vision

Dans Mentora, **rien ne bouge sans raison**.

| Règle | Énoncé |
|---|---|
| MV-01 | Chaque mouvement possède une **intention** (§7 — liste fermée). |
| MV-02 | Chaque apparition possède une **explication**. |
| MV-03 | Chaque disparition possède une **justification**. |
| MV-04 | **Le mouvement explique. Il ne décore jamais** (PX-06). |

---

## 3. Les piliers du mouvement

Dix piliers. Tout mouvement dans Mentora appartient à exactement un pilier.

### 3.1 Entrance Motion

| | |
|---|---|
| **Mission** | Faire arriver — un élément qui apparaît dit d'où il vient et pourquoi maintenant. |
| **Responsabilités** | Définir l'arrivée des remontées, des cartes, des résultats : l'apparition situe la provenance et s'insère sans bousculer. |
| **Frontières** | Une apparition résulte d'un fait publié ou d'un geste — jamais d'une envie de vie à l'écran. |
| **Ce qu'il explique** | « ceci vient d'arriver, voilà d'où, voilà pourquoi. » |
| **Ce qu'il ne doit jamais faire** | surprendre (PX-04) ; pousser le contenu sous le doigt (RF-04 du Home) ; théâtraliser l'ordinaire. |

### 3.2 Exit Motion

| | |
|---|---|
| **Mission** | Faire partir — une disparition reste compréhensible et sans perte. |
| **Responsabilités** | Définir le départ des éléments sans objet (DIS du Home) : la sortie dit où c'est parti (traité, écarté, terminé) et que rien n'est perdu (DIS-04). |
| **Frontières** | La disparition exécute une décision publiée (retrait par le propriétaire, écart par l'expert) — le mouvement ne supprime jamais de lui-même. |
| **Ce qu'il explique** | « ceci n'a plus d'objet — et voilà ce qu'il en reste. » |
| **Ce qu'il ne doit jamais faire** | évaporer sans explication ; faire perdre le contexte ; punir l'écart d'une hésitation visuelle. |

### 3.3 Transition Motion

| | |
|---|---|
| **Mission** | Relier deux surfaces — le déplacement se vit comme un trajet, pas comme un remplacement. |
| **Responsabilités** | Donner un mouvement distinct à chaque nature de déplacement (NTR-03) : avancer, revenir, traverser une frontière, entrer en immersion — chacun se reconnaît. |
| **Frontières** | La transition sert la Navigation Foundation ; elle n'invente jamais un trajet que la navigation n'a pas défini. |
| **Ce qu'il explique** | « voilà d'où tu viens, voilà où tu arrives » (NTR-01). |
| **Ce qu'il ne doit jamais faire** | téléporter (MC-03) ; retarder l'arrivée (MT-03) ; se ressembler dans les deux sens (l'aller et le retour se distinguent). |

### 3.4 Attention Motion

| | |
|---|---|
| **Mission** | Attirer le regard — uniquement vers ce qui le mérite. |
| **Responsabilités** | Définir le signal discret vers l'important publié (imminence, sécurité, attention) ; une seule sollicitation à la fois (pilier Focus). |
| **Frontières** | Le mouvement attire vers ce que les plateformes ont qualifié — jamais vers le décor, le bruit, la publicité ou une information secondaire (§8). |
| **Ce qu'il explique** | « regarde ici, maintenant — c'est justifié. » |
| **Ce qu'il ne doit jamais faire** | s'agiter en boucle ; crier (l'urgence est calme, DPV-05) ; solliciter pour l'ordinaire. |

### 3.5 Continuous Motion

| | |
|---|---|
| **Mission** | Dire discrètement qu'un état dure — la séance en cours, l'enregistrement actif. |
| **Responsabilités** | Définir la présence sobre des états continus (le REC discret) : perceptible sans distraire, constant sans lasser. |
| **Frontières** | L'état continu est publié par sa plateforme ; le mouvement le rend perceptible, jamais envahissant (Continuous Interaction). |
| **Ce qu'il explique** | « c'est toujours en cours. » |
| **Ce qu'il ne doit jamais faire** | distraire pendant l'acte (Salle Live épurée) ; disparaître alors que l'état dure ; simuler une activité inexistante. |

### 3.6 Waiting Motion

| | |
|---|---|
| **Mission** | Rendre l'attente visible et honnête. |
| **Responsabilités** | Définir la présence du travail en cours (Waiting Interaction, §9 de l'Interaction Foundation) : le mouvement reflète un travail réel (IW-02). |
| **Frontières** | Jamais de progression inventée, jamais de mouvement d'attente décoratif — l'attente courte n'a pas de mise en scène. |
| **Ce qu'il explique** | « le système travaille — voilà où ça en est. » |
| **Ce qu'il ne doit jamais faire** | mentir sur l'avancement ; hypnotiser ; masquer l'issue de sortie (IW-01). |

### 3.7 Recovery Motion

| | |
|---|---|
| **Mission** | Accompagner la reprise — retrouver son contexte se voit. |
| **Responsabilités** | Définir la restitution : au retour, ce qui était là se réinstalle de façon reconnaissable ; ce qui a changé pendant l'absence se signale en arrivant (NCO-03). |
| **Frontières** | La reprise restitue l'état publié (Recovery Navigation/Interaction) ; le mouvement montre la restitution, il ne la fabrique pas. |
| **Ce qu'il explique** | « te revoilà — voilà ton contexte, et voilà ce qui a changé. » |
| **Ce qu'il ne doit jamais faire** | rejouer visuellement ce qui n'a pas été rejoué ; présenter le changé comme inchangé. |

### 3.8 Confirmation Motion

| | |
|---|---|
| **Mission** | Sceller un acte — la confirmation se ressent au moment exact. |
| **Responsabilités** | Définir la ponctuation des actes : l'accusé d'un geste (IF-02), le scellé d'un consentement, l'effet visible d'un succès (IS-01). |
| **Frontières** | La ponctuation est proportionnée au niveau de protection (§8 de l'Interaction Foundation) : l'ordinaire est discret, l'important est net — jamais de fête (IS-04). |
| **Ce qu'il explique** | « c'est pris en compte — c'est fait. » |
| **Ce qu'il ne doit jamais faire** | célébrer l'ordinaire ; retarder la suite (IS-05) ; confirmer visuellement ce qui n'est pas confirmé (IF-06). |

### 3.9 Focus Motion

| | |
|---|---|
| **Mission** | Installer et défaire la concentration — entrer dans l'immersion, en sortir proprement. |
| **Responsabilités** | Définir la bascule vers le plein écran (Salle Live) : le reste s'efface, l'acte s'installe ; à la sortie, le monde revient sans brutalité. |
| **Frontières** | L'immersion est déclarée par la navigation (Immersive) ; le mouvement l'habille, il ne la déclenche pas. |
| **Ce qu'il explique** | « maintenant, il n'y a plus que ça » — puis « c'est terminé, te revoilà. » |
| **Ce qu'il ne doit jamais faire** | claquer (l'entrée en séance est sereine) ; laisser l'immersion se rompre visuellement pendant l'acte. |

### 3.10 Context Motion

| | |
|---|---|
| **Mission** | Montrer les changements de contexte — un moment remplace un autre et ça se comprend. |
| **Responsabilités** | Définir la bascule des moments (le Home change de moment, une étape du cycle succède à une autre) : le changement s'explique en se produisant, l'ancien cède la place sans disparaître brutalement. |
| **Frontières** | Le moment est publié par sa plateforme (MO-01 du Home) ; le mouvement rend la bascule perceptible, il ne la décide pas. |
| **Ce qu'il explique** | « le contexte a changé — voilà le nouveau, voilà ce qu'est devenu l'ancien. » |
| **Ce qu'il ne doit jamais faire** | réorganiser sous le doigt (RF-04) ; enchaîner deux bascules sans respiration ; faire douter de ce qui est le présent. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Motion Foundation PEUT |
|---|---|
| MP-01 | Définir les intentions du mouvement. |
| MP-02 | Définir les changements de contexte. |
| MP-03 | Définir les transitions. |
| MP-04 | Définir les apparitions. |
| MP-05 | Définir les disparitions. |
| MP-06 | Définir les changements d'état. |
| MP-07 | Définir les mouvements d'attention. |
| MP-08 | Définir la continuité visuelle. |

### 4.2 Interdites

| Règle | Le Motion Foundation NE PEUT JAMAIS |
|---|---|
| MN-01 | Décider. |
| MN-02 | Calculer. |
| MN-03 | Posséder les plateformes métier. |
| MN-04 | Posséder les données. |
| MN-05 | Posséder les composants. |
| MN-06 | Posséder les providers. |
| MN-07 | Posséder les moteurs. |
| MN-08 | Remplacer le MES — il précise son pilier Motion, rien de plus. |

---

## 5. Relation avec les plateformes

Chaque plateforme **publie des changements**. Le Motion Foundation définit uniquement **comment ces changements deviennent perceptibles**. Jamais leur logique.

| Plateforme | Changements publiés | Mouvement qui les rend perceptibles |
|---|---|---|
| Home | remontées qui arrivent et partent, moments qui basculent | Entrance/Exit pour les cartes ; Context pour les moments ; jamais sous le doigt |
| Consultation | étapes du cycle, imminence, entrée/sortie de Salle | Transition d'étape ; Attention pour l'imminence ; Focus pour l'immersion |
| Business | faits financiers, caps d'objectifs | Entrance sobre des faits ; Confirmation nette des actes d'argent ; jamais de spectacle autour des montants |
| AI | propositions qui arrivent, s'acceptent, s'écartent | Entrance citée ; Exit respectueux de l'écart (sans hésitation visuelle) |
| Reputation | avis, preuves, progressions | Entrance des faits datés ; reconnaissance sobre des caps |
| Account | sécurité, appareils, environnement | Attention mesurée pour la sécurité (grave, pas paniquée) ; Confirmation des actes protégés |

| Règle | Énoncé |
|---|---|
| MR-01 | Un mouvement traduit un changement publié ou un geste — il n'existe pour aucune autre cause. |
| MR-02 | Le même type de changement bouge de la même façon sur toutes les plateformes (PX-07). |
| MR-03 | Toute nouvelle plateforme reçoit le langage du mouvement tel quel (MSR-03). |

---

## 6. Les moments du mouvement

| Moment | Mission |
|---|---|
| **Entrée** | installer une surface ou un élément : situer la provenance, sans bousculer. |
| **Sortie** | libérer : dire où c'est parti, sans perte. |
| **Découverte** | laisser explorer : le mouvement suit le geste, jamais l'inverse. |
| **Transition** | relier : le trajet se comprend (§3.3). |
| **Confirmation** | sceller : l'acte pris en compte se ressent (§3.8). |
| **Attente** | montrer le travail réel (§3.6). |
| **Reprise** | restituer : le contexte revient reconnaissable (§3.7). |
| **Interruption** | figer proprement : ce qui s'arrête le montre, sans casse (NI-01). |
| **Retour** | revenir : le chemin inverse se reconnaît comme un retour (NB-01). |
| **Fin** | clore : l'achèvement se voit, la suite s'ouvre naturellement. |

| Règle | Énoncé |
|---|---|
| MM-01 | Chaque moment a son mouvement défini ; aucun moment ne bouge « comme un autre » par commodité. |
| MM-02 | Tout nouveau moment s'ajoute par révision de ce document. |

---

## 7. Les intentions du mouvement

Huit intentions officielles. **Aucune autre intention n'existe** : un mouvement qui ne sert aucune de ces intentions est interdit.

| Intention | Le mouvement sert à |
|---|---|
| **Expliquer** | rendre un changement compréhensible en le montrant. |
| **Guider** | conduire le regard et le geste vers la suite naturelle. |
| **Rassurer** | dire que le système a entendu, travaille, a fini. |
| **Préserver le contexte** | montrer que rien ne se perd — que l'on vient de quelque part. |
| **Attirer l'attention** | signaler ce qui mérite le regard, maintenant (§8). |
| **Accompagner** | suivre le geste de l'expert, sans résistance ni zèle. |
| **Confirmer** | sceller un acte au moment exact. |
| **Montrer la continuité** | relier l'avant et l'après — jamais de téléportation. |

| Règle | Énoncé |
|---|---|
| MI-01 | Tout mouvement déclare son intention ; un mouvement sans intention est supprimé. |
| MI-02 | Une intention nouvelle exige la révision de ce document — jamais un cas particulier. |

---

## 8. Le mouvement et l'attention

| Règle | Énoncé |
|---|---|
| MA-01 | Le mouvement attire **uniquement ce qui mérite l'attention** — qualifié par les plateformes, arbitré par le pilier Focus. |
| MA-02 | **Jamais le décor.** |
| MA-03 | **Jamais le bruit.** |
| MA-04 | **Jamais la publicité.** |
| MA-05 | **Jamais une information secondaire** : ce qui n'est pas prioritaire ne bouge pas pour se faire voir. |
| MA-06 | Une seule sollicitation de mouvement à la fois : deux appels simultanés s'annulent en cacophonie. |

---

## 9. Les changements d'état et la continuité

| Règle | Énoncé |
|---|---|
| ME-01 | Une apparition **explique** ; elle **ne surprend jamais** (PX-04). |
| ME-02 | Une disparition **reste compréhensible** ; elle **ne fait jamais perdre le contexte**. |
| ME-03 | Une transition **préserve toujours la continuité** (NTR-05). |
| MC-01 | Le mouvement **préserve toujours le contexte**. |
| MC-02 | Le mouvement **explique toujours les changements** — un état qui change sans mouvement compréhensible est un état qui ment par omission. |
| MC-03 | Le mouvement **ne donne jamais l'impression de téléporter l'utilisateur**. |
| MC-04 | Le mouvement **reste toujours prévisible** : la même cause produit le même mouvement (PX-07). |

---

## 10. Le mouvement et le temps

| Règle | Le mouvement |
|---|---|
| MT-01 | **ne ralentit jamais le travail.** |
| MT-02 | **n'interrompt jamais inutilement.** |
| MT-03 | **ne retarde jamais une action** : l'expert n'attend jamais la fin d'un mouvement pour agir. |
| MT-04 | **reste toujours au service de l'expert** — jamais du spectacle. |
| MT-05 | Les durées concrètes appartiennent au futur Design System (MSD-03) — sous contrainte perpétuelle de MT-01 → MT-04. |

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| MMF-01 | Le mouvement est pensé d'abord pour **le mobile** : une seule main, le mouvement suit le pouce. |
| MMF-02 | **Transitions naturelles** : elles prolongent le geste, jamais ne le contrarient. |
| MMF-03 | **Aucun mouvement inutile** : le petit écran ne pardonne aucune agitation. |
| MMF-04 | **Aucune distraction** — surtout en séance (Focus Motion). |
| MMF-05 | **Desktop = adaptation. Jamais l'inverse** (MSMF-07) : plus d'espace n'autorise jamais plus de mouvement. |

---

## 12. Gouvernance

| Règle | Énoncé |
|---|---|
| MG-01 | Tout nouveau mouvement appartient à une intention officielle (§7). |
| MG-02 | Toute nouvelle transition appartient à cette fondation (§3.3, §6). |
| MG-03 | Toute nouvelle apparition appartient à cette fondation (§3.1). |
| MG-04 | Toute nouvelle disparition appartient à cette fondation (§3.2). |
| MG-05 | **Aucun mouvement décoratif. Aucun mouvement gratuit** (MV-04). |
| MG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Pliables, tablettes, desktop, web | mêmes intentions, mêmes piliers ; les trajets s'adaptent à la disposition (Responsive Foundation) |
| TV | le mouvement à distance : plus lisible, jamais plus spectaculaire |
| Wearables | l'essentiel : Attention et Confirmation seulement — pas de place pour le reste |
| Réalité mixte | le mouvement dans l'espace : les intentions demeurent, la continuité y devient vitale (jamais de téléportation, MC-03) |
| Voice | le « mouvement » devient rythme et enchaînement sonores : mêmes intentions (expliquer, rassurer, confirmer), autre modalité |
| Nouveaux paradigmes | de nouvelles réalisations des huit intentions ; une neuvième intention exige la révision de ce document |

| Règle | Énoncé |
|---|---|
| MX-01 | Les dix piliers (§3) et les huit intentions (§7) sont l'invariant décennal. |
| MX-02 | **Les intentions du mouvement restent identiques. Seules les implémentations évolueront.** |
| MX-03 | Aucune extension ne peut affaiblir les règles de temps (MT), d'attention (MA) ni de continuité (MC). |

---

## 14. Gouvernance du document

- Ce document est la **référence officielle** du langage du mouvement de Mentora. Il réalise le pilier **Motion** du MES.
- Toute vague d'implémentation cite le pilier, le moment, l'intention et les règles (MV/MP/MN/MR/MM/MI/MA/ME/MC/MT/MMF/MG/MX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis les fondations [Navigation](navigation-foundation.md), [Interaction](interaction-foundation.md) et [Design Language](design-language-foundation.md), puis ce document (MSD-01).
