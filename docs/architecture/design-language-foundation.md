# DESIGN LANGUAGE FOUNDATION

**Statut** : Référence officielle de toute identité visuelle de Mentora.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun composant, aucun pixel, aucune couleur, aucune typographie, aucun spacing, aucun design Figma, aucun code, aucun pseudo-code, aucune maquette. Cette fondation ne décrit ni une charte graphique, ni une palette, ni des icônes — elle décrit **le langage visuel officiel de Mentora**.
**Filiation** : troisième descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) — il réalise officiellement le pilier **Visual Language** (MSD-01 : il précise, ne redéfinit pas). Il respecte la [NAVIGATION FOUNDATION](navigation-foundation.md) et l'[INTERACTION FOUNDATION](interaction-foundation.md) ; P9.0 prévaut en cas de conflit. Les descendants Motion, Component, Accessibility et Responsive devront le respecter. Le Design System concret (couleurs, typographies, styles) naîtra de cette fondation (MSD-03) — jamais en dehors.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par la stabilité de son langage — la même intention se lit toujours de la même façon, avant, pendant et après toute interruption ; aucun changement visuel sans raison (PX-07).

---

## 1. Mission

**Mission en une phrase** : définir la personnalité visuelle officielle de Mentora — comment le visuel hiérarchise, rythme, apaise et inspire confiance — et rien d'autre.

Il ne possède jamais : les plateformes métier, les données, les composants, les providers, les moteurs, la logique métier, les plateformes système.

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| DV-01 | Chaque élément visuel transmet une **intention**. Le design n'existe jamais pour décorer : **il existe pour expliquer**. |
| DV-02 | **Le calme prime toujours sur le spectaculaire.** |
| DV-03 | **La compréhension prime toujours sur l'effet.** |
| DV-04 | **La cohérence prime toujours sur l'originalité** (PX-08). |

---

## 3. Les piliers du langage visuel

Dix piliers. Toute règle visuelle appartient à exactement un pilier.

### 3.1 Visual Hierarchy

| | |
|---|---|
| **Mission** | Faire que le plus important se voie en premier — toujours. |
| **Responsabilités** | Ordonner visuellement selon les priorités **publiées** par les plateformes (PRI du Home, imminence d'abord) ; définir les niveaux visuels (§7) et leur coexistence. |
| **Frontières** | La hiérarchie visuelle exprime des priorités métier ; elle n'en crée jamais. |
| **Ce qu'il influence** | l'ordre de lecture de chaque surface ; la première seconde de compréhension. |
| **Ce qu'il ne possède jamais** | la qualification d'importance (propriété des plateformes) ; les moyens concrets (tailles, graisses — Design System). |

### 3.2 Visual Rhythm

| | |
|---|---|
| **Mission** | Donner à la lecture une respiration régulière et prévisible. |
| **Responsabilités** | Définir le rythme vertical (une colonne, des temps de lecture réguliers), la respiration entre les intentions, la constance des cadences d'une surface à l'autre. |
| **Frontières** | Le rythme structure la lecture ; les espacements concrets appartiennent au Design System. |
| **Ce qu'il influence** | la vitesse de lecture, la sensation d'ordre, la fatigue évitée. |
| **Ce qu'il ne possède jamais** | le contenu ; la densité (pilier voisin) ; les valeurs de spacing. |

### 3.3 Information Density

| | |
|---|---|
| **Mission** | Maîtriser combien — jamais plus de six éléments d'attention (UX-07). |
| **Responsabilités** | Définir la densité maximale par surface et par moment ; imposer la contraction des surfaces calmes (EV-01) ; interdire le remplissage (EV-04). |
| **Frontières** | La densité borne ce qui s'affiche simultanément ; le choix de ce qui s'affiche appartient aux plateformes. |
| **Ce qu'il influence** | chaque surface, chaque moment — la charge cognitive de l'expert. |
| **Ce qu'il ne possède jamais** | la sélection du contenu ; les priorités. |

### 3.4 Professional Tone

| | |
|---|---|
| **Mission** | Faire que Mentora parle visuellement comme un outil de travail sérieux. |
| **Responsabilités** | Définir le registre : sobriété, précision, vocabulaire visuel de métier (UX-10 appliqué au visuel) ; proscrire le ludique gratuit — **l'expert travaille, il ne joue jamais** (DPV-08). |
| **Frontières** | Le ton professionnel n'est pas de la froideur : il coexiste avec le ton émotionnel (§3.5) sans jamais céder au gadget. |
| **Ce qu'il influence** | toutes les surfaces, tous les états, toutes les célébrations (sobres — IS-04). |
| **Ce qu'il ne possède jamais** | les textes métier ; l'identité de marque concrète (Design System). |

### 3.5 Emotional Tone

| | |
|---|---|
| **Mission** | Faire ressentir juste : la confiance, le calme, la reconnaissance — sans manipulation. |
| **Responsabilités** | Définir les registres émotionnels permis (sérénité par défaut ; gravité mesurée pour la sécurité ; reconnaissance sobre pour les caps) et interdits (culpabilisation, pression, fausse urgence). |
| **Frontières** | L'émotion accompagne le fait publié ; elle ne l'amplifie jamais (BM-04 : jamais de culpabilisation ; IV-03 : jamais de dramatisation). |
| **Ce qu'il influence** | les moments sensibles : objectif en retard, activité en baisse, alerte de sécurité, réussite. |
| **Ce qu'il ne possède jamais** | le déclenchement d'un moment ; le contenu du message. |

### 3.6 Contrast

| | |
|---|---|
| **Mission** | Faire que la différence se voie — entre l'important et le reste, entre les états, entre le fait et la proposition. |
| **Responsabilités** | Définir les oppositions signifiantes : actif/inactif, fait/proposition IA (AE-06), acquis/prévisionnel (BV-04), vérifié/déclaré (RT-04) — chacune visuellement distincte, partout. |
| **Frontières** | Le contraste sert le sens ; le contraste décoratif est du bruit. Les valeurs concrètes (rapports, seuils) appartiennent au Design System sous contrainte d'accessibilité. |
| **Ce qu'il influence** | la lisibilité de toute distinction qui compte. |
| **Ce qu'il ne possède jamais** | les couleurs ; les seuils chiffrés d'accessibilité (Accessibility Foundation). |

### 3.7 Clarity

| | |
|---|---|
| **Mission** | Faire que **le regard comprenne avant de lire** (DPV-02). |
| **Responsabilités** | Définir l'exigence de compréhension immédiate (< 5 s, UX-01) ; éliminer le bruit visuel (DPV-03) ; imposer qu'une forme dise sa fonction. |
| **Frontières** | La clarté juge toute règle visuelle : ce qui n'aide pas à comprendre n'existe pas (MSV-04). |
| **Ce qu'il influence** | tous les piliers — la clarté est leur juge de paix. |
| **Ce qu'il ne possède jamais** | le contenu ; la simplification du métier lui-même (propriété des plateformes). |

### 3.8 Consistency

| | |
|---|---|
| **Mission** | Faire que la même intention se voie toujours de la même façon — partout, tout le temps. |
| **Responsabilités** | Garantir l'unité du langage sur les cinq plateformes (MSV-05) ; interdire les dialectes visuels par équipe ou par plateforme (NG-05 appliqué au visuel). |
| **Frontières** | La cohérence unifie l'expression ; la personnalité métier des plateformes (§5) s'exprime dans le contenu, jamais par un langage visuel divergent. |
| **Ce qu'il influence** | chaque nouvelle surface, chaque évolution. |
| **Ce qu'il ne possède jamais** | le droit de figer : la cohérence évolue par révision, jamais par exception. |

### 3.9 Focus

| | |
|---|---|
| **Mission** | Protéger visuellement l'attention : une surface, un sujet. |
| **Responsabilités** | Définir l'effacement de ce qui n'est pas le sujet ; la sobriété des périphéries ; le vide assumé comme un choix (EV-03) ; l'immersion sans distraction (Salle Live). |
| **Frontières** | Le focus visuel applique le pilier Focus du MES ; il ne décide jamais de ce qui mérite l'attention. |
| **Ce qu'il influence** | la Salle Live, les moments d'acte protégé, chaque surface à action principale unique (MF-07). |
| **Ce qu'il ne possède jamais** | les priorités ; les interruptions (Interaction Foundation). |

### 3.10 Trust

| | |
|---|---|
| **Mission** | Faire que l'honnêteté du système **se voie**. |
| **Responsabilités** | Définir l'expression visuelle du vrai : l'inconnu a un visage (jamais un zéro — IND-05), l'indisponible se distingue du vide (IND-01), l'estimation ne ressemble jamais à la certitude (DT-05), la preuve est visuellement dépliable (RT-03). |
| **Frontières** | Le visuel exprime l'honnêteté des faits publiés ; il ne vérifie rien lui-même. |
| **Ce qu'il influence** | tout ce qui touche l'argent, la sécurité, la réputation, l'IA. |
| **Ce qu'il ne possède jamais** | les faits ; les preuves ; les états (publiés par les plateformes). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Design Language PEUT |
|---|---|
| DP-01 | Définir les priorités visuelles. |
| DP-02 | Définir la hiérarchie. |
| DP-03 | Définir le rythme de lecture. |
| DP-04 | Définir la cohérence visuelle. |
| DP-05 | Définir le niveau de densité. |
| DP-06 | Définir les intentions visuelles. |
| DP-07 | Définir le langage graphique. |

### 4.2 Interdites

| Règle | Le Design Language NE PEUT JAMAIS |
|---|---|
| DN-01 | Décider. |
| DN-02 | Calculer. |
| DN-03 | Posséder les plateformes métier. |
| DN-04 | Posséder les données. |
| DN-05 | Posséder les composants. |
| DN-06 | Posséder les providers. |
| DN-07 | Posséder les moteurs. |
| DN-08 | Remplacer le MES — il précise son pilier Visual Language, rien de plus. |

---

## 5. Relation avec les plateformes

Chaque plateforme **conserve sa personnalité métier**. Le Design Language leur donne une **expression visuelle commune**. Jamais leur logique.

| Plateforme | Sa personnalité métier | Ce que le langage commun lui garantit |
|---|---|---|
| Home | la journée, en un regard | la colonne d'intentions calme ; l'imminence qui domine sans crier |
| Consultation | le travail, l'acte | la progression lisible du cycle ; l'immersion épurée de la Salle |
| Business | l'argent, expliqué | des montants toujours accompagnés de leur lecture (BV-02) ; l'inconnu jamais déguisé en zéro |
| AI | la proposition, citée | la proposition visuellement distincte du fait, partout (AE-04, AE-06) |
| Reputation | la confiance, prouvée | des signaux lisibles immédiatement ; des preuves dépliables ; le vérifié distinct du déclaré |
| Account | l'environnement, serein | la sécurité lisible sans alarmisme ; les réglages sobres |

| Règle | Énoncé |
|---|---|
| DR-01 | Une seule grammaire visuelle pour cinq plateformes : la personnalité s'exprime dans le contenu, jamais par un dialecte visuel. |
| DR-02 | Aucune plateforme ne peut renforcer visuellement sa propre importance : la hiérarchie inter-plateformes appartient au Home et à ses priorités publiées. |
| DR-03 | Toute nouvelle plateforme reçoit le langage tel quel (MSR-03). |

---

## 6. Les principes visuels

| Règle | Énoncé |
|---|---|
| DPV-01 | **Le plus important est toujours visible.** |
| DPV-02 | **Le regard comprend avant de lire.** |
| DPV-03 | **Le bruit visuel est éliminé** — tout élément sans responsabilité disparaît (MSV-04). |
| DPV-04 | **Une information importante ne se cache jamais** : ni sous un geste savant, ni sous un pli, ni sous un délai. |
| DPV-05 | **Le calme est permanent** — même l'urgence est calme : claire, pas hystérique. |
| DPV-06 | **La confiance est perceptible** : l'honnêteté se voit (§3.10). |
| DPV-07 | **La densité reste maîtrisée** (≤ 6 éléments d'attention). |
| DPV-08 | **L'expert travaille. Il ne joue jamais** : aucun mécanisme de jeu, aucune récompense artificielle, aucune gamification de l'activité professionnelle. |

Ces principes sont **perpétuels** : aucun descendant ni aucune extension ne peut les affaiblir.

---

## 7. Les niveaux visuels

Cinq niveaux officiels. Toute information affichée vit à exactement un niveau.

| Niveau | Définition | Exemple de nature |
|---|---|---|
| **Information principale** | la réponse à la question de la surface — une seule par surface | l'imminence, le gain du jour, le signal de confiance |
| **Information secondaire** | ce qui précise la principale sans rivaliser | la lecture d'un montant, l'heure d'une consultation |
| **Information complémentaire** | ce qui enrichit si l'on s'y attarde | l'historique, le détail dépliable |
| **Information contextuelle** | ce qui situe : où je suis, où j'en suis | l'étape du cycle, le moment de la journée |
| **Information exceptionnelle** | ce qui a le droit d'interrompre la lecture : sécurité, imminence | l'alerte non écartable |

| Règle | Énoncé |
|---|---|
| DNV-01 | **Coexistence** : une surface porte une principale, peu de secondaires, le reste se replie — jamais deux principales. |
| DNV-02 | **Hiérarchisation** : le niveau découle de la priorité publiée (PRI du Home, moments des plateformes) — jamais d'un choix esthétique. |
| DNV-03 | **Disparition** : une information descend de niveau puis disparaît quand sa raison d'être s'éteint (DIS du Home) ; jamais de trace fantôme. |
| DNV-04 | L'information exceptionnelle est rare par définition : si tout est exceptionnel, rien ne l'est (pilier Focus). |

---

## 8. Les états visuels

Huit états officiels. Tous cohérents, partout.

| État | Principe |
|---|---|
| **Visible** | l'état normal : lisible, à son niveau (§7). |
| **Masqué** | replié volontairement, retrouvable d'un geste — jamais perdu. |
| **Indisponible** | distinct du vide et du masqué : la chose existe mais ne répond pas (IND-01) ; sobre, sans alarme (IND-04). |
| **Chargement** | le travail réel se voit (IW-02) ; jamais décoratif, jamais menteur. |
| **Erreur** | locale, expliquée, sans dramatisation (IE) ; l'échec ne teinte jamais toute la surface (IND-03). |
| **Succès** | discret, proportionné (IS-03) ; il confirme et s'efface. |
| **Attention** | signale sans crier : l'attention se distingue de l'urgence ; elle attend son tour (Focus). |
| **Information** | neutre : elle informe sans solliciter. |

| Règle | Énoncé |
|---|---|
| DEV-01 | Tous les états restent **cohérents** : le même état se reconnaît sur toutes les plateformes (PX-07). |
| DEV-02 | **Aucun état ne dramatise** (IV-03). |
| DEV-03 | **Aucun état ne ment** : jamais un chargement sans travail, jamais un succès simulé, jamais un vide à la place d'un indisponible (IF-05, IF-06). |

---

## 9. La personnalité visuelle

Huit qualités fondamentales — chacune est une exigence, pas un adjectif :

| Qualité | Ce qu'elle exige |
|---|---|
| **Professionnelle** | un outil de travail, pas un divertissement : chaque élément sert l'exercice du métier (DPV-08). |
| **Calme** | la sérénité par défaut, même dans l'urgence (DPV-05) ; le silence visuel des surfaces sans actualité. |
| **Précise** | rien d'approximatif : ce qui s'affiche est exact, situé, daté ; l'à-peu-près visuel trahit la confiance. |
| **Épurée** | le minimum qui explique : tout ce qui peut disparaître sans perte de sens disparaît (DPV-03). |
| **Fiable** | la même chose au même endroit, toujours : la stabilité visuelle est une promesse tenue (Consistency). |
| **Accessible** | lisible par tous, dans toutes les conditions : l'élégance n'exclut jamais (opposable — Accessibility Foundation). |
| **Élégante** | la beauté par la justesse, jamais par l'ornement : l'élégance de Mentora est celle d'un geste précis. |
| **Intemporelle** | aucune mode : le langage doit être juste dans dix ans (§13) — ce qui est tendance aujourd'hui est daté demain. |

---

## 10. Les principes de confiance

| Règle | Le langage visuel |
|---|---|
| DT-01 | **ne cache jamais** : une information due est montrée (DPV-04). |
| DT-02 | **ne surcharge jamais** : la surcharge est une forme de dissimulation. |
| DT-03 | **ne manipule jamais** : aucun dark pattern — aucun choix visuel qui pousse l'expert contre son intérêt. |
| DT-04 | **ne crée jamais de faux sentiment d'urgence** : l'urgence visuelle est réservée aux urgences publiées (imminence, sécurité). |
| DT-05 | **ne transforme jamais une estimation en certitude** : le prévisionnel, le probable et le proposé gardent leur visage propre (BV-04, AE-05). |
| DT-06 | **respecte toujours les preuves** : une preuve se montre telle quelle (RT-05) ; le vérifié et le déclaré ne se confondent jamais. |
| DT-07 | **reste honnête** — en toute circonstance, sur tout support. |

Ces principes sont **perpétuels**.

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| DMF-01 | Le langage est pensé d'abord pour **le mobile** : une seule main, lecture verticale (MF-02, colonne d'intentions). |
| DMF-02 | **Compréhension immédiate** : la première seconde suffit pour savoir où regarder (DPV-02). |
| DMF-03 | **Une seule action principale** visuellement évidente par surface (MF-07). |
| DMF-04 | **Peu de bruit, peu de distraction** : le petit écran ne pardonne aucun élément inutile. |
| DMF-05 | **Desktop = adaptation. Jamais l'inverse** (MSMF-07) : plus d'espace n'autorise jamais plus de bruit. |

---

## 12. Gouvernance

| Règle | Énoncé |
|---|---|
| DG-01 | Toute nouvelle identité visuelle appartient à cette fondation. |
| DG-02 | Toute nouvelle hiérarchie appartient à cette fondation (§7). |
| DG-03 | Toute nouvelle densité appartient à cette fondation (§3.3). |
| DG-04 | Toute nouvelle famille graphique appartient à cette fondation ; le Design System concret en découle (MSD-03), jamais l'inverse. |
| DG-05 | Aucun dialecte visuel : une seule identité Mentora, sur toutes les plateformes, par toutes les équipes. |
| DG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux appareils, pliables, tablettes, desktop, web | mêmes niveaux, mêmes états, mêmes principes ; seules les dispositions changent (Responsive Foundation) |
| TV | la lecture à distance : hiérarchie et densité s'adaptent, la personnalité demeure |
| Wearables | l'essentiel seulement : une information principale, rien d'autre |
| Réalité mixte | les mêmes intentions dans l'espace ; le calme et la clarté y sont encore plus impératifs |
| Voice interfaces | le langage visuel a un frère vocal : mêmes niveaux d'information, mêmes principes d'honnêteté, dits au lieu d'être montrés |
| Nouveaux supports | reçoivent la personnalité telle quelle (§9) — **la personnalité visuelle reste identique** |

| Règle | Énoncé |
|---|---|
| DX-01 | Les dix piliers (§3), les cinq niveaux (§7) et les huit états (§8) sont l'invariant décennal. |
| DX-02 | Aucune extension ne peut affaiblir un principe visuel (DPV) ni un principe de confiance (DT). |
| DX-03 | L'intemporalité (§9) est opposable à toute évolution : une mode n'est jamais une raison. |

---

## 14. Gouvernance du document

- Ce document est la **référence officielle** de toute identité visuelle de Mentora. Il réalise le pilier **Visual Language** du MES.
- Toute vague d'implémentation cite le pilier, le niveau, l'état et les règles (DV/DP/DN/DR/DPV/DNV/DEV/DT/DMF/DG/DX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis les fondations [Navigation](navigation-foundation.md) et [Interaction](interaction-foundation.md), puis ce document (MSD-01).
