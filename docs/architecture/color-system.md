# COLOR SYSTEM

**Statut** : Référence officielle du langage sémantique de la couleur de Mentora. Premier descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md).
**Portée** : Architecture fonctionnelle uniquement. Aucun HEX, aucun RGB, aucun HSL, aucune palette, aucune couleur finale, aucun thème, aucun token, aucun Figma, aucun code. Ce document définit **le langage sémantique officiel de la couleur** ; les valeurs concrètes seront produites plus tard par les Design Tokens (P11.8).
**Préséance** : P9 → P10 → P11.0 → ce document (DSD-01 : il précise le pilier **Color**, il ne redéfinit rien). L'[Accessibility Foundation](accessibility-foundation.md) lui est opposable (DSD-04). Il traduit les règles P10 qu'il cite explicitement (§7, DSM-01) — une traduction ne modifie jamais la règle (DSM-02).
**Niveaux produits (DSD-02)** : Principes et Standards (§9) ; les Tokens et Implementations viendront des descendants P11.8 et P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (la couleur incarne la personnalité — calme, précise, intemporelle) et Documentation (chaque rôle est traçable jusqu'à sa règle P10, §7).

---

## 1. Mission

**Mission en une phrase** : définir les rôles sémantiques de la couleur — leurs responsabilités, leurs frontières, leurs relations, leurs règles d'utilisation — **sans jamais choisir les valeurs finales**.

---

## 2. Vision

Dans Mentora, **une couleur n'existe jamais pour être belle. Une couleur existe pour transmettre une signification.**

| Règle | Énoncé |
|---|---|
| CSV-01 | **La signification est permanente. La valeur graphique pourra évoluer** (DSX-02). |
| CSV-02 | Toute couleur affichée porte un rôle sémantique de ce système — une couleur sans rôle n'existe pas (DSG-01). |
| CSV-03 | Un rôle traduit une règle P10 (§7) ; un rôle sans origine est rejeté (DSM-01). |
| CSV-04 | La couleur accompagne le sens ; elle ne le porte jamais seule (AFS-01, §8). |

---

## 3. Les piliers du Color System

Dix piliers. Tout rôle sémantique appartient à exactement un pilier.

### 3.1 Identity Colors

| | |
|---|---|
| **Mission** | Porter la présence de Mentora — sobre, professionnelle, intemporelle. |
| **Responsabilités** | Définir les rôles identitaires (Primary, Secondary, Supporting) : ce qui signe Mentora sans jamais crier. |
| **Frontières** | L'identité colore la présence, jamais le sens d'un état ou d'une donnée (piliers Semantic/State). |
| **Ce qu'il produit** | les rôles d'identité (§4.1). |
| **Ce qu'il ne possède jamais** | une signification d'état ; une urgence ; une valeur finale. |

### 3.2 Semantic Colors

| | |
|---|---|
| **Mission** | Donner un langage aux significations universelles : information, réussite, vigilance, gravité. |
| **Responsabilités** | Définir les rôles de signification (Information, Success, Warning, Critical, Neutral) — chacun réservé à ce qu'il signifie. |
| **Frontières** | La signification est déclenchée par un fait publié — jamais par un choix esthétique (DNV-02). |
| **Ce qu'il produit** | les rôles sémantiques (§4.2). |
| **Ce qu'il ne possède jamais** | le droit d'inventer une gravité (DT-04) ; un usage décoratif. |

### 3.3 State Colors

| | |
|---|---|
| **Mission** | Traduire les huit états officiels des composants (§8 du Component Foundation). |
| **Responsabilités** | Définir les rôles d'état (Unavailable, Disabled, Focus, Selection…) — chaque état visuellement distinct, jamais ambigu (AFS-02). |
| **Frontières** | Les états sont publiés ; la couleur les exprime avec au moins une autre forme (jamais seule — §8). |
| **Ce qu'il produit** | la traduction couleur des états (§5). |
| **Ce qu'il ne possède jamais** | un état nouveau ; un état menti (DEV-03). |

### 3.4 Interaction Colors

| | |
|---|---|
| **Mission** | Colorer l'agir : l'action possible, l'action principale, le focus, la sélection. |
| **Responsabilités** | Définir les rôles d'interaction (Action, Focus, Selection, Highlight) alignés sur les types et protections de l'Interaction Foundation. |
| **Frontières** | Une action sensible et au-delà se distingue (IPR) ; jamais une couleur qui banalise l'irréversible. |
| **Ce qu'il produit** | les rôles d'interaction (§4.4). |
| **Ce qu'il ne possède jamais** | le niveau de protection (publié) ; un déclenchement. |

### 3.5 Platform Colors

| | |
|---|---|
| **Mission** | Garantir qu'aucune plateforme n'a de couleur à elle. |
| **Responsabilités** | Tenir la règle : les plateformes utilisent exactement les mêmes rôles (§6) ; l'expression métier passe par le contenu, jamais par une palette locale (DR-01). |
| **Frontières** | Ce pilier est un interdit organisé — il ne produit aucun rôle nouveau. |
| **Ce qu'il produit** | la règle d'uniformité inter-plateformes (CSPL). |
| **Ce qu'il ne possède jamais** | une exception ; une « couleur de plateforme ». |

### 3.6 Trust Colors

| | |
|---|---|
| **Mission** | Colorer l'honnêteté : le vérifié, le déclaré, l'acquis, le prévisionnel, l'estimation. |
| **Responsabilités** | Définir les rôles de confiance (Verified, Declared, Prediction, Estimate) — les distinctions RT-04 et BV-04 rendues lisibles. |
| **Frontières** | La preuve appartient aux plateformes ; la couleur la signale, ne la remplace jamais (§8). |
| **Ce qu'il produit** | les rôles de confiance (§4.5). |
| **Ce qu'il ne possède jamais** | la vérification elle-même ; le droit de faire ressembler l'estimé au certain (DT-05). |

### 3.7 AI Colors

| | |
|---|---|
| **Mission** | Rendre l'IA reconnaissable — partout, toujours, d'un regard. |
| **Responsabilités** | Définir le rôle AI Suggestion : toute proposition IA est marquée comme telle (AE-04, AE-06), du Home à la Salle. |
| **Frontières** | Le rôle marque la provenance ; il ne qualifie ni la confiance (qualitative, publiée) ni l'importance. |
| **Ce qu'il produit** | le rôle IA (§4.5). |
| **Ce qu'il ne possède jamais** | le contenu des propositions ; un caractère pressant. |

### 3.8 Accessibility Colors

| | |
|---|---|
| **Mission** | Garantir que le système couleur reste perceptible par tous, dans tous les contextes. |
| **Responsabilités** | Porter les exigences opposables (§8) : contrastes suffisants (seuils chiffrés aux Tokens), variantes de contraste renforcé, survie au plein soleil et au sombre (AFC). |
| **Frontières** | Les seuils chiffrés appartiennent aux Design Tokens sous ces contraintes ; ce pilier fixe l'exigence. |
| **Ce qu'il produit** | les contraintes d'accessibilité du système (CSA). |
| **Ce qu'il ne possède jamais** | une « palette accessible » à part (AFV-01 : jamais un mode à part). |

### 3.9 Environment Colors

| | |
|---|---|
| **Mission** | Colorer le support : les fonds, les surfaces, les délimitations — le calme permanent. |
| **Responsabilités** | Définir les rôles d'environnement (Background, Surface, Outline, Divider, Foreground, Immersion, Navigation) : la scène discrète sur laquelle tout le reste se lit. |
| **Frontières** | L'environnement s'efface (DPV-05) ; il ne rivalise jamais avec le contenu. |
| **Ce qu'il produit** | les rôles d'environnement (§4.6). |
| **Ce qu'il ne possède jamais** | une signification d'état ; une présence qui distrait. |

### 3.10 Future Extensions

| | |
|---|---|
| **Mission** | Accueillir les significations de demain — sans jamais diluer celles d'aujourd'hui. |
| **Responsabilités** | Porter le protocole d'ajout : une nouvelle signification naît d'une règle P10 (existante ou révisée), reçoit son rôle par révision de ce document, puis ses valeurs par les Tokens. |
| **Frontières** | Une nouvelle **valeur** ne crée jamais une nouvelle **signification** (CSG-03). |
| **Ce qu'il produit** | le protocole d'extension (§13). |
| **Ce qu'il ne possède jamais** | un rôle « en réserve » ; une signification spéculative. |

---

## 4. Les rôles sémantiques

Vingt-sept rôles officiels. Chaque rôle : sa mission, quand il est utilisé, quand il est interdit, ce qu'il ne signifie jamais.

### 4.1 Rôles d'identité

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Primary** | la présence de Mentora ; l'action principale de la surface | l'unique action principale (MF-07) ; la signature discrète | plusieurs éléments par surface ; le décor | une urgence ; un état |
| **Secondary** | l'accompagnement de l'identité | les actions secondaires repliées ; les accents mesurés | rivaliser avec Primary | une hiérarchie d'information |
| **Supporting** | le soutien discret de l'identité | les périphéries identitaires rares | tout usage qui attire l'œil | une signification |

### 4.2 Rôles de signification

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Information** | un fait neutre qui informe (état Information) | informer sans solliciter | solliciter ; alerter | une action attendue |
| **Success** | un fait accompli et vérifié (IS) | confirmer sobrement un acte réussi | célébrer l'ordinaire (IS-04) ; décorer | une promesse ; un prévisionnel |
| **Warning** | une vigilance justifiée, publiée | l'attention qualifiée (famille Attention) | créer l'inquiétude sans fait (DT-04) | une urgence ; une erreur |
| **Critical** | la gravité réelle : erreur bloquante, alerte de sécurité | l'erreur expliquée (IE) ; l'alerte non écartable | dramatiser (IV-03) ; l'ordinaire | une simple attention |
| **Neutral** | l'absence de signification particulière | le contenu courant | remplacer un rôle signifiant | un état |

### 4.3 Rôles d'état

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Unavailable** | existe mais ne répond pas (IND-01) — fail closed | toute indisponibilité publiée | se confondre avec le vide ou le désactivé (AFS-02) | une erreur ; un zéro |
| **Disabled** | présent mais hors de portée maintenant | une capacité momentanément inapplicable | cacher une information due (DT-01) | une indisponibilité système |
| **Attention** | ceci attend ton regard (état Attention) | les remontées d'attention publiées | crier ; l'urgence (rôle Critical) | une obligation immédiate |
| **Focus** | l'élément qui reçoit l'interaction (un seul — état En focus) | marquer le focus, toujours perceptible (AFS) | plusieurs focus ; l'esthétique | une sélection |
| **Highlight** | la mise en évidence passagère : ce qui vient de changer (NCO-03) | signaler un changement à l'arrivée | durer ; décorer | une importance permanente |

### 4.4 Rôles d'interaction et de navigation

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Action** | on peut agir ici | toute commande disponible | les fausses affordances | l'action principale (Primary) |
| **Selection** | le choisi, encore modifiable (état En sélection) | montrer la sélection en cours | valoir engagement (un sélectionné n'est pas un soumis) | une validation |
| **Navigation** | le déplacement : où l'on est, où l'on peut aller | la navigation racine et ses repères | porter du contenu | une action métier |
| **Immersion** | l'enveloppe du plein écran (Salle Live) | l'immersion déclarée (NAV-05) | toute surface courante | une simple surface sombre/claire |

### 4.5 Rôles de confiance et d'IA

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Verified** | prouvé par une source (RT-04) | certifications vérifiées, faits sourcés | tout ce qui n'a pas sa preuve dépliable (RT-03) | une qualité ; un jugement |
| **Declared** | affirmé sans preuve — honnêtement | l'auto-déclaré (expertise déclarée) | se rapprocher visuellement de Verified | une fausseté (déclaré ≠ faux) |
| **Prediction** | le prévisionnel fondé sur l'engagé (BV-04) | les prévisions nommées prévisions | se mêler à l'acquis | un fait ; une promesse |
| **Estimate** | l'estimation incertaine, dite incertaine (AE-05) | toute valeur probable | ressembler à la certitude (DT-05) | un montant dû |
| **AI Suggestion** | ceci vient de l'IA (AE-04) | toute proposition IA, partout | marquer un fait ; presser | une décision ; une vérité |

### 4.6 Rôles d'environnement

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Background** | le fond général — le calme (DPV-05) | la scène de toute surface | attirer l'attention | un contenu |
| **Surface** | le support d'un block ou d'une section | envelopper les niveaux de composition | multiplier les fonds concurrents | une hiérarchie par la couleur seule |
| **Foreground** | le contenu premier sur son fond | textes et éléments porteurs | descendre sous les contrastes exigés (§8) | une emphase |
| **Outline** | la délimitation discrète | cadrer sans peser | dessiner pour décorer | une bordure d'état |
| **Divider** | la séparation des temps de lecture (Visual Rhythm) | séparer sections et groupes | hacher la lecture | une hiérarchie |

| Règle | Énoncé |
|---|---|
| CSR-01 | Un rôle par usage : deux rôles pour la même signification n'existent pas (l'équivalent couleur de CFU-02). |
| CSR-02 | Un usage hors rôle n'existe pas (CSV-02). |
| CSR-03 | Tout nouveau rôle s'ajoute par révision de ce document, via Future Extensions (§3.10). |

---

## 5. Les états — traduction officielle

Les huit états du Component Foundation reçoivent chacun leur langage couleur — **jamais une couleur arbitraire** :

| État (Component Foundation) | Rôle(s) couleur |
|---|---|
| Disponible | Neutral / Action (si actionnable) |
| Indisponible | Unavailable |
| Chargement (en attente) | Information — le travail réel, sans dramatisation |
| Erreur | Critical — locale, expliquée (IE) |
| Succès | Success — discret (IS-03) |
| Attention | Attention |
| Sélection | Selection |
| Focus | Focus |

| Règle | Énoncé |
|---|---|
| CSE-01 | Chaque état a son rôle ; aucun composant n'invente une couleur d'état. |
| CSE-02 | Deux états ne partagent jamais une expression identique (AFS-02). |
| CSE-03 | L'état s'exprime toujours par la couleur **et** au moins une autre forme (§8). |

---

## 6. Relation avec les plateformes

**Les plateformes utilisent exactement les mêmes rôles. Aucune plateforme ne possède sa propre palette.**

| Plateforme | Ses distinctions clés | Rôles qui les portent |
|---|---|---|
| Home | l'attention avant l'information ; le calme du vide | Attention, Information, Background |
| Consultation | l'imminence ; l'immersion ; la progression du cycle | Attention/Critical (selon gravité publiée), Immersion, Information |
| Business | l'acquis / l'en-attente / le prévisionnel ; l'inconnu jamais en zéro | Success, Prediction, Estimate, Unavailable |
| AI | la proposition citée, refusable | AI Suggestion — jamais un autre rôle pour l'IA |
| Reputation | le vérifié / le déclaré ; les preuves | Verified, Declared |
| Account | la sécurité grave mais calme | Critical (réel), Warning (recommandé), Neutral |

| Règle | Énoncé |
|---|---|
| CSPL-01 | Mêmes rôles partout — l'expression métier passe par le contenu (DR-01). |
| CSPL-02 | Aucune plateforme ne peut promouvoir un rôle (une attention Business n'est pas plus rouge qu'une attention Reputation). |
| CSPL-03 | Toute nouvelle plateforme reçoit les rôles tels quels (DSR-04). |

---

## 7. Relation avec le MES — les règles traduites

Chaque rôle traduit une règle P10, citée explicitement. **Une traduction ne modifie jamais la règle** (DSM-02).

| Règle P10 traduite | Traduction couleur |
|---|---|
| AE-04 / AE-06 — l'IA marquée, fait ≠ proposition | le rôle AI Suggestion, unique et partout |
| RT-04 — vérifié ≠ déclaré, jamais mêlés | les rôles Verified / Declared, jamais rapprochés |
| BV-04 / DT-05 — l'estimation jamais en certitude | les rôles Prediction / Estimate, distincts de l'acquis |
| IND-01 / IND-05 — l'indisponible distinct du vide, jamais un zéro | le rôle Unavailable |
| DEV-01→03 — les états cohérents, jamais menteurs | la table des états (§5) |
| DT-04 — jamais de fausse urgence | Critical réservé à la gravité publiée ; Warning à la vigilance justifiée |
| DPV-05 — le calme permanent | les rôles d'environnement effacés ; l'urgence calme |
| IV-03 / IE — jamais de dramatisation | Critical explique, ne crie pas |
| MF-07 — une action principale | Primary porte l'unique action principale |
| AFS-01→03 — perceptible, jamais ambigu, jamais caché | §8 tout entier |
| DIS-03 — l'écartable et le non-écartable | Attention (écartable) / Critical (non écartable pour la sécurité) |
| NCO-03 — le changement signalé | le rôle Highlight, passager |

| Règle | Énoncé |
|---|---|
| CSM-01 | Tout rôle cite sa règle P10 (DSM-01) ; un rôle sans origine est rejeté. |
| CSM-02 | Un manque de langage couleur découvert face à une règle P10 remonte en révision — jamais comblé silencieusement (DSM-03). |

---

## 8. Accessibility — opposable

| Règle | Énoncé |
|---|---|
| CSA-01 | **Une couleur ne porte jamais seule une information** (AFI-04) : chaque rôle s'accompagne d'au moins une autre forme (texte, forme, structure, état). |
| CSA-02 | Une couleur ne remplace jamais : **un état, un texte, une preuve, une icône, une hiérarchie.** |
| CSA-03 | Les contrastes exigés (Foreground sur ses fonds, états sur leurs surfaces) sont opposables ; les seuils chiffrés seront fixés par les Design Tokens sous ces contraintes. |
| CSA-04 | Chaque rôle survit aux contextes officiels (AFC) : plein soleil, sombre, contraste renforcé — par variantes de valeurs, jamais par changement de signification. |
| CSA-05 | Un conflit entre esthétique et accessibilité se résout pour l'accessibilité (AFR-02). |

---

## 9. Les niveaux

Six niveaux — la production couleur descend toujours (DSL-01) :

| Niveau | Mission | Responsabilité | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Identity** | l'expression de la personnalité | relier la couleur aux 8 qualités (§9 du Design Language) | les principes identitaires de la couleur | une valeur ; un état |
| **Semantic** | les significations | les rôles du §4 et leurs règles | les rôles nommés, leurs usages et interdits | une valeur ; un composant |
| **State** | les états traduits | la table du §5 | les liaisons état → rôle | un état nouveau |
| **Component** | la couleur en situation | l'application des rôles par famille de composants | les règles d'application par famille | un rôle nouveau ; une exception locale |
| **Token** | les valeurs nommées | (produit par P11.8) chaque rôle reçoit ses valeurs par thème | la nomenclature rôle → valeurs | une signification nouvelle |
| **Implementation** | la couleur dans la technologie | (produit par P11.9) la consommation fidèle des tokens | le code des kits | une valeur en dur ; un écart |

---

## 10. Les principes de confiance

| Règle | Une couleur |
|---|---|
| CST-01 | **ne ment jamais** : elle exprime l'état vrai, publié. |
| CST-02 | **ne dramatise jamais** (IV-03). |
| CST-03 | **ne manipule jamais** — aucun dark pattern chromatique (DT-03). |
| CST-04 | **ne crée jamais une fausse urgence** (DT-04). |
| CST-05 | **ne transforme jamais une estimation en certitude** (DT-05). |
| CST-06 | **ne remplace jamais une preuve** (CSA-02). |
| CST-07 | **reste intemporelle** : la signification ne suit pas les modes (DST-05). |

Ces principes sont **perpétuels**.

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| CSMF-01 | Le système couleur est pensé d'abord pour **le mobile** : lisible dans la main, au soleil, en mouvement. |
| CSMF-02 | Les autres appareils adaptent les valeurs (par les Tokens) — **jamais les significations**. |
| CSMF-03 | Un rôle illisible sur mobile est invalide partout (DSMF-03). |

---

## 12. Gouvernance

| Règle | Énoncé |
|---|---|
| CSG-01 | **Aucune nouvelle couleur n'existe hors du Color System** (DSG-01). |
| CSG-02 | **Toute nouvelle signification appartient au Color System** — par révision de ce document. |
| CSG-03 | **Une nouvelle valeur graphique ne crée jamais une nouvelle signification.** |
| CSG-04 | **Le langage sémantique est stable. Les valeurs évolueront.** |
| CSG-05 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux thèmes, Dark Mode, Light Mode | des jeux de **valeurs** par thème (Tokens) — les rôles et significations identiques dans tous les thèmes |
| Contrastes renforcés | des variantes de valeurs sous CSA-04 — jamais un mode à part |
| Nouvelles technologies, frameworks | des Implementations de plus (P11.9 et suivants) — le langage ignoré des technologies (DST-06) |
| Nouveaux appareils | les rôles tels quels, valeurs adaptées par contexte (Responsive) |
| Nouvelles significations | le protocole Future Extensions (§3.10) : règle P10 → rôle → valeurs |

| Règle | Énoncé |
|---|---|
| CSX-01 | Les dix piliers (§3), les vingt-sept rôles (§4) et les liaisons d'états (§5) sont l'invariant décennal. |
| CSX-02 | **Les significations restent identiques. Seules les valeurs évolueront** (CSV-01). |
| CSX-03 | Aucune extension ne peut affaiblir l'accessibilité (§8) ni la confiance (§10). |

---

## 14. Descendance

- **Les Design Tokens (P11.8) traduiront ce Color System** : chaque rôle recevra ses valeurs nommées, par thème, sous les contraintes du §8.
- **Le Flutter Design Kit (P11.9) implémentera ces tokens** — fidèlement.
- **Aucune implémentation ne pourra créer une nouvelle signification** (CSG-03).

---

## 15. Gouvernance du document

- Ce document est la **référence officielle** du langage sémantique de la couleur de Mentora — premier descendant du Design System.
- Toute vague d'implémentation cite le pilier, le rôle, le niveau et les règles (CSV/CSR/CSE/CSPL/CSM/CSA/CST/CSMF/CSG/CSX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le MES et ses descendants (Accessibility opposable), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md), puis ce document (DSD-01).
