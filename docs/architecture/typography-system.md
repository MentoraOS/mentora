# TYPOGRAPHY SYSTEM

**Statut** : Référence officielle du langage sémantique de la typographie de Mentora. Deuxième descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md).
**Portée** : Architecture fonctionnelle uniquement. Aucune police, aucune famille typographique, aucune taille, aucune graisse, aucune hauteur de ligne, aucun pixel, aucun point, aucun CSS, aucun token, aucun Figma, aucun code. Ce document définit **le langage sémantique officiel de la typographie** ; les valeurs concrètes seront définies plus tard par les Design Tokens (P11.8).
**Préséance** : P9 → P10 → P11.0 → ce document (DSD-01 : il précise le pilier **Typography**, il ne redéfinit rien). L'[Accessibility Foundation](accessibility-foundation.md) lui est opposable (DSD-04). Il traduit les règles P10 qu'il cite explicitement (§6, DSM-01) — une traduction ne modifie jamais la règle (DSM-02).
**Niveaux produits (DSD-02)** : Principes et Standards (§9) ; les Tokens et Implementations viendront de P11.8 et P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (la typographie incarne la personnalité — précise, épurée, intemporelle) et Documentation (chaque rôle est traçable jusqu'à sa règle P10, §6).

---

## 1. Mission

**Mission en une phrase** : définir les rôles de lecture — leurs responsabilités, leurs hiérarchies, leurs relations, leurs règles d'utilisation — **sans jamais choisir une police**.

---

## 2. Vision

Dans Mentora, **la typographie ne sert jamais à décorer. Elle sert à guider la lecture.**

| Règle | Énoncé |
|---|---|
| TSV-01 | Chaque niveau de texte possède une **responsabilité** ; chaque responsabilité possède une **signification**. |
| TSV-02 | **La forme pourra évoluer. La signification restera permanente** (CSV-01 appliqué au texte). |
| TSV-03 | Tout texte affiché porte un rôle typographique de ce système — un texte sans rôle n'existe pas (DSG-02). |
| TSV-04 | Tout rôle traduit une règle P10 (§6) ; un rôle sans origine est rejeté (DSM-01). |

---

## 3. Les piliers du Typography System

Dix piliers. Toute règle typographique appartient à exactement un pilier.

### 3.1 Identity Typography

| | |
|---|---|
| **Mission** | Donner à Mentora sa voix écrite — professionnelle, précise, intemporelle. |
| **Responsabilités** | Définir les principes d'expression typographique de l'identité : la sobriété qui signe, jamais l'ornement. |
| **Frontières** | L'identité s'exprime dans la constance, pas dans la fantaisie ; le choix concret des polices appartient aux Tokens sous ces principes. |
| **Ce qu'il produit** | les principes identitaires de la voix écrite. |
| **Ce qu'il ne possède jamais** | une police ; un effet décoratif (DPV-03). |

### 3.2 Reading Hierarchy

| | |
|---|---|
| **Mission** | Faire que **le regard comprenne avant de lire** (DPV-02) — par la seule structure des textes. |
| **Responsabilités** | Définir l'ordre de lecture : les rôles de titre et leur subordination (§5) ; une seule information principale par surface (DNV-01). |
| **Frontières** | La hiérarchie traduit les cinq niveaux visuels du Design Language ; elle n'en invente pas. |
| **Ce qu'il produit** | la hiérarchie officielle de lecture (§5). |
| **Ce qu'il ne possède jamais** | la priorité des contenus (publiée) ; deux informations principales. |

### 3.3 Semantic Typography

| | |
|---|---|
| **Mission** | Donner un langage écrit aux significations : l'état, la gravité, la provenance. |
| **Responsabilités** | Définir les rôles signifiants (Status, Warning, Critical, Success, AI Suggestion, Verification) — alignés sur les rôles couleur homonymes (§4 du Color System), exprimés ensemble, jamais par la couleur seule (CSA-01). |
| **Frontières** | La signification est déclenchée par un fait publié ; le rôle l'écrit, il ne la crée pas. |
| **Ce qu'il produit** | les rôles signifiants (§4.5). |
| **Ce qu'il ne possède jamais** | une gravité inventée (DT-04) ; une dramatisation (IV-03). |

### 3.4 Information Density

| | |
|---|---|
| **Mission** | Maîtriser la quantité de texte — l'écran dit peu, et bien. |
| **Responsabilités** | Définir les exigences de concision par rôle : les textes courts et directs (Readability), le détail replié plutôt qu'étalé, jamais plus de six éléments d'attention (DPV-07). |
| **Frontières** | La densité borne la forme ; la sélection du contenu appartient aux plateformes. |
| **Ce qu'il produit** | les règles de concision par rôle. |
| **Ce qu'il ne possède jamais** | le contenu ; le droit de tronquer une information due (DT-01). |

### 3.5 Reading Rhythm

| | |
|---|---|
| **Mission** | Donner à la lecture sa respiration — régulière, verticale, prévisible. |
| **Responsabilités** | Définir la cadence des rôles dans la colonne de lecture (Visual Rhythm) : l'alternance titres/corps, les temps de pause, la constance de surface en surface. |
| **Frontières** | Le rythme structure ; les espacements concrets appartiennent au Spacing System (P11.3) et aux Tokens. |
| **Ce qu'il produit** | les règles de cadence de lecture. |
| **Ce qu'il ne possède jamais** | les mesures ; la disposition (Responsive). |

### 3.6 Accessibility Typography

| | |
|---|---|
| **Mission** | Garantir que lire Mentora ne fatigue jamais et n'exclut jamais (Readability). |
| **Responsabilités** | Porter les exigences opposables : lisibilité dans tous les contextes (AFC), taille adaptable sans casse de hiérarchie, lignes courtes, compréhension sans jargon (AFI-04 : le texte est l'une des formes multiples du sens). |
| **Frontières** | Les seuils concrets appartiennent aux Tokens sous ces contraintes ; ce pilier fixe l'exigence. |
| **Ce qu'il produit** | les contraintes d'accessibilité typographique (§8). |
| **Ce qu'il ne possède jamais** | une « typographie accessible » à part (AFV-01). |

### 3.7 Interaction Typography

| | |
|---|---|
| **Mission** | Écrire l'agir : ce qui est actionnable se lit comme actionnable. |
| **Responsabilités** | Définir les rôles d'interaction (Action, Navigation) : le libellé d'un acte dit l'acte (Compréhension — les conséquences annoncées), au niveau de protection près (IPR). |
| **Frontières** | Le déclenchement et la protection appartiennent à l'Interaction Foundation ; le rôle les écrit lisiblement. |
| **Ce qu'il produit** | les rôles d'interaction (§4.4). |
| **Ce qu'il ne possède jamais** | l'acte ; une fausse affordance. |

### 3.8 Platform Typography

| | |
|---|---|
| **Mission** | Garantir qu'aucune plateforme n'a de hiérarchie à elle. |
| **Responsabilités** | Tenir la règle : le même langage typographique partout (§7) ; l'expression métier passe par le contenu (DR-01). |
| **Frontières** | Ce pilier est un interdit organisé — il ne produit aucun rôle nouveau. |
| **Ce qu'il produit** | la règle d'uniformité inter-plateformes (TSPL). |
| **Ce qu'il ne possède jamais** | une exception ; une « voix de plateforme ». |

### 3.9 Future Extensions

| | |
|---|---|
| **Mission** | Accueillir les rôles de demain — sans diluer ceux d'aujourd'hui. |
| **Responsabilités** | Porter le protocole d'ajout : une nouvelle signification écrite naît d'une règle P10, reçoit son rôle par révision de ce document, puis ses valeurs par les Tokens. |
| **Frontières** | Une nouvelle **police** ne crée jamais une nouvelle **signification** (TSG-03). |
| **Ce qu'il produit** | le protocole d'extension (§13). |
| **Ce qu'il ne possède jamais** | un rôle en réserve ; une signification spéculative. |

### 3.10 Documentation

| | |
|---|---|
| **Mission** | Faire que le langage typographique s'apprenne et se respecte. |
| **Responsabilités** | Documenter chaque rôle : sa règle P10 d'origine, ses usages permis et interdits, ses liaisons couleur (§4 du Color System). |
| **Frontières** | La documentation décrit ; elle ne modifie jamais (gouvernance §12). |
| **Ce qu'il produit** | la référence d'usage, traçable jusqu'aux fondations. |
| **Ce qu'il ne possède jamais** | une règle propre ; un exemple contraire à une fondation. |

---

## 4. Les rôles typographiques

Vingt-sept rôles officiels. Chaque rôle : sa mission — ce qu'il signifie, quand il est utilisé, quand il est interdit, ce qu'il ne signifie jamais.

### 4.1 Rôles de structure

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Display** | la plus grande voix : un fait rare qui domine tout | les moments d'exception (information exceptionnelle) | l'ordinaire ; plusieurs par surface | une décoration ; un titre courant |
| **Hero** | l'information principale de la surface (DNV-01) | la réponse à la question de la surface (le gain du jour, l'imminence) | deux Hero par surface | un simple titre |
| **Page Title** | le nom de l'endroit : où je suis (PX-01) | titrer une surface | porter l'information principale (Hero) | un contenu |
| **Section Title** | le nom d'un temps de lecture | titrer une section | hacher la lecture en sur-titrant | une information |
| **Surface Title** | le nom d'une surface secondaire ou d'un aparté | titrer un détail, un aparté (Temporary) | rivaliser avec Page Title | une hiérarchie nouvelle |
| **Block Title** | le nom d'une carte d'intention | titrer un block (CI) | doubler le contenu du block | l'intention elle-même |

### 4.2 Rôles de corps

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Body** | le texte courant : ce qui se lit | tout contenu principal lu | les longues masses non structurées | un titre ; une valeur |
| **Label** | le nom court d'une chose | nommer un champ, une donnée, un réglage | faire des phrases | une explication |
| **Supporting** | la précision qui accompagne sans rivaliser (information secondaire) | préciser une principale (la lecture d'un montant — BV-02) | porter l'essentiel | une information autonome |
| **Caption** | la légende : ce qui décrit un élément | légender preuves, contenus, images | commenter le décoratif | un contenu principal |
| **Hint** | l'aide au moment utile : ce qui est attendu | guider une saisie (Input), lever un doute | culpabiliser ; noyer | une erreur ; une règle |
| **Metadata** | la donnée de contexte : qui, où, combien | contextualiser sobrement | rivaliser avec le contenu | une information principale |
| **Timestamp** | le quand : daté, exact | dater faits, remontées, preuves (RPU-01) | l'à-peu-près quand l'exact est dû | une durée estimée |
| **Footnote** | la note marginale rare | la précision périphérique | devenir un canal d'information due (DT-01) | un avertissement |
| **Legal** | l'obligation : ce que le droit exige | mentions et consentements écrits (IPR-04) | se cacher ; être illisible | du décor administratif |

### 4.3 Rôles de données et d'états

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Value** | la valeur qui compte : montant, mesure, quantité | tout chiffre porteur (avec sa lecture — BV-02) | un chiffre sans lecture ; un zéro pour un inconnu (IND-05) | une estimation non dite (DT-05) |
| **Status** | l'état écrit : ce qui est, maintenant | dire un état publié (les 8 états) | supposer ; enjoliver (DEV-03) | un souhait |
| **Empty State** | le vide assumé : « rien ne demande votre attention » (EV-03) | les états vides conçus | meubler (EV-04) | un échec ; un manque |
| **Loading** | le travail en cours, honnête (IW-02) | l'attente annoncée | masquer une attente inconnue (dite inconnue) | une promesse de résultat |

### 4.4 Rôles d'interaction

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **Action** | le libellé d'un acte : dit ce qui va se passer | toute commande (l'acte annoncé — Compréhension) | les libellés vagues (« OK ») sur du sensible | une description ; une promesse |
| **Navigation** | le libellé d'un déplacement : où l'on va | entrées, traversées, retours | déguiser une action en navigation | un acte métier |
| **Message** | la parole d'une conversation | les messages (Account) et leurs aperçus | reformuler la parole d'autrui (HN-06 étendu) | un contenu système |

### 4.5 Rôles de signification

| Rôle | Mission — ce qu'il signifie | Utilisé quand | Interdit quand | Ne signifie jamais |
|---|---|---|---|---|
| **AI Suggestion** | l'écrit de l'IA, cité comme tel (AE-04) | toute proposition IA, avec sa raison (APU-02) | se fondre dans le fait (AE-06) | une vérité ; une décision |
| **Verification** | l'écrit du prouvé (RT-04) | ce qui est vérifié, avec sa preuve dépliable | s'appliquer au déclaré | un jugement de valeur |
| **Warning** | la vigilance écrite, justifiée | l'attention qualifiée | l'inquiétude sans fait (DT-04) | une urgence |
| **Critical** | la gravité écrite : erreur, sécurité | l'erreur expliquée (IE-01) ; l'alerte réelle | dramatiser ; culpabiliser (IE-02) | une simple attention |
| **Success** | la réussite écrite, sobre | confirmer un acte accompli (IS-01) | célébrer l'ordinaire (IS-04) | une promesse |

| Règle | Énoncé |
|---|---|
| TSR-01 | Un rôle par usage : deux rôles pour la même signification n'existent pas (CFU-02 appliqué). |
| TSR-02 | Un texte hors rôle n'existe pas (TSV-03). |
| TSR-03 | Tout nouveau rôle s'ajoute par révision de ce document, via Future Extensions (§3.9). |

---

## 5. Hiérarchie de lecture

**Le regard doit comprendre avant de lire** (DPV-02). La hiérarchie traduit les cinq niveaux visuels du Design Language (§7) :

| Niveau visuel (Design Language) | Rôles qui le portent |
|---|---|
| Information principale | Hero (une seule — DNV-01) ; Display pour l'exceptionnel |
| Information secondaire | Supporting, Value avec sa lecture |
| Information complémentaire | Body, Caption, Metadata, Footnote |
| Information contextuelle | Page Title, Section Title, Timestamp, Status |
| Information exceptionnelle | Display, Critical |

| Règle | Énoncé |
|---|---|
| TSH-01 | **Une seule information principale** par surface — un seul Hero (DNV-01). |
| TSH-02 | La subordination est stricte : un rôle inférieur ne domine jamais visuellement un rôle supérieur, quel que soit le contenu. |
| TSH-03 | La hiérarchie découle des priorités publiées (DNV-02) — jamais d'un choix esthétique. |
| TSH-04 | La hiérarchie survit à l'adaptation : sur tout appareil, le même ordre de lecture (Content Priority). |

---

## 6. Relation avec le MES — les règles traduites

Chaque rôle traduit une règle P10, citée explicitement. **Une traduction ne modifie jamais la règle** (DSM-02).

| Règle P10 traduite | Traduction typographique |
|---|---|
| DPV-02 — le regard comprend avant de lire | la hiérarchie de lecture (§5) |
| DNV-01 — une seule principale | le rôle Hero, unique par surface (TSH-01) |
| UX-10 / Compréhension — le langage de l'expert | tous les rôles : jargon proscrit, actes annoncés |
| BV-02 — un montant jamais seul | Value toujours accompagné de Supporting |
| IND-05 — jamais un zéro pour un inconnu | Value interdit pour l'inconnu ; Status l'écrit |
| AE-04 / AE-06 — l'IA citée, fait ≠ proposition | le rôle AI Suggestion |
| RT-04 — vérifié ≠ déclaré | le rôle Verification, réservé au prouvé |
| DT-05 — l'estimation jamais en certitude | l'estimé se dit dans son écriture, jamais en Value nu |
| EV-03 / EV-04 — le vide assumé, jamais meublé | le rôle Empty State |
| IW-02 — l'attente honnête | le rôle Loading |
| IE-01 / IE-02 — l'erreur explique, sans culpabiliser | le rôle Critical en erreur |
| IS-01 / IS-04 — le succès sobre | le rôle Success |
| DIS/RPU — les faits datés | le rôle Timestamp |
| Readability / AFI-04 — lisible, le texte comme forme du sens | les contraintes du §8 |

| Règle | Énoncé |
|---|---|
| TSM-01 | Tout rôle cite sa règle P10 (DSM-01) ; un rôle sans origine est rejeté. |
| TSM-02 | Un manque découvert face à une règle P10 remonte en révision — jamais comblé silencieusement (DSM-03). |

---

## 7. Relation avec les plateformes

**Toutes utilisent exactement le même langage typographique. Aucune plateforme ne possède sa propre hiérarchie.**

| Plateforme | Ce que le langage commun lui garantit |
|---|---|
| Home | la colonne d'intentions : Block Titles + contenus, un Hero de journée |
| Consultation | l'imminence en Hero quand elle domine ; le cycle en Status et Timestamps |
| Business | les montants en Value + Supporting, jamais nus ; le prévisionnel écrit comme tel |
| AI | toute proposition en AI Suggestion, avec sa raison |
| Reputation | le prouvé en Verification ; les avis en Message, cités intacts |
| Account | la sécurité en Critical/Warning selon la gravité publiée ; le Legal lisible |

| Règle | Énoncé |
|---|---|
| TSPL-01 | Mêmes rôles partout — l'expression métier passe par le contenu (DR-01). |
| TSPL-02 | Aucune plateforme ne peut promouvoir un rôle ni en créer un. |
| TSPL-03 | Toute nouvelle plateforme reçoit le langage tel quel (DSR-04). |

---

## 8. Accessibility — opposable

| Règle | Énoncé |
|---|---|
| TSA-01 | **La typographie ne fatigue jamais** : lignes courtes, textes directs, hiérarchie nette (Readability). |
| TSA-02 | **Elle reste lisible** dans tous les contextes officiels (AFC) : plein soleil, sombre, mouvement, petite taille d'écran. |
| TSA-03 | **Compréhensible** : le langage de l'expert, jamais de jargon (UX-10) ; les conséquences annoncées avant les actes. |
| TSA-04 | **Prévisible** : le même rôle se lit de la même façon partout (PX-07). |
| TSA-05 | **Jamais décorative** (DPV-03). |
| TSA-06 | La taille est adaptable sans casser la hiérarchie ni masquer d'information (les seuils aux Tokens, sous cette contrainte). |
| TSA-07 | Un conflit entre esthétique et accessibilité se résout pour l'accessibilité (AFR-02). |

---

## 9. Les niveaux

Six niveaux — la production typographique descend toujours (DSL-01) :

| Niveau | Mission | Responsabilité | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Identity** | la voix écrite de la personnalité | relier la typographie aux 8 qualités | les principes identitaires | une police ; une valeur |
| **Semantic** | les significations écrites | les rôles du §4 et leurs règles | les rôles nommés, usages et interdits | une taille ; un composant |
| **Reading** | la hiérarchie et le rythme | la hiérarchie (§5) et la cadence (§3.5) | les subordinations, les cadences | une priorité de contenu |
| **Component** | le texte en situation | l'application des rôles par famille de composants | les règles d'application par famille | un rôle nouveau ; une exception |
| **Token** | les valeurs nommées | (produit par P11.8) chaque rôle reçoit ses valeurs | la nomenclature rôle → valeurs | une signification nouvelle |
| **Implementation** | le texte dans la technologie | (produit par P11.9) la consommation fidèle | le code des kits | une valeur en dur ; un écart |

---

## 10. Les principes de confiance

| Règle | Une typographie |
|---|---|
| TST-01 | **ne manipule jamais** (DT-03). |
| TST-02 | **ne dramatise jamais** (IV-03). |
| TST-03 | **ne crée jamais une fausse urgence** (DT-04). |
| TST-04 | **ne cache jamais une information** — ni par la taille, ni par le repli, ni par l'illisible (DT-01). |
| TST-05 | **ne transforme jamais une estimation en certitude** (DT-05). |
| TST-06 | **reste intemporelle** (DST-05). |

Ces principes sont **perpétuels**.

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| TSMF-01 | Le système typographique est conçu d'abord pour **le mobile** : lisible dans la main, en mouvement, d'un pouce. |
| TSMF-02 | **Une hiérarchie illisible sur mobile est invalide partout** (DSMF-03). |
| TSMF-03 | Les autres appareils adaptent les valeurs (par les Tokens) — jamais les rôles ni la hiérarchie. |

---

## 12. Gouvernance

| Règle | Énoncé |
|---|---|
| TSG-01 | **Aucun texte n'existe hors du Typography System** (TSV-03). |
| TSG-02 | **Toute nouvelle hiérarchie appartient au Typography System** — par révision de ce document. |
| TSG-03 | **Une nouvelle police ne crée jamais une nouvelle signification.** |
| TSG-04 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouvelles polices | des **valeurs** (Tokens) — les rôles et significations identiques |
| Dark Mode, Light Mode | des jeux de valeurs par thème — la hiérarchie inchangée |
| Nouvelles technologies, frameworks | des Implementations de plus — le langage les ignore (DST-06) |
| Nouveaux appareils | les rôles tels quels, valeurs adaptées par contexte (Responsive) ; la hiérarchie survit partout (TSH-04) |
| Nouvelles significations écrites | le protocole Future Extensions (§3.9) : règle P10 → rôle → valeurs |

| Règle | Énoncé |
|---|---|
| TSX-01 | Les dix piliers (§3), les vingt-sept rôles (§4) et la hiérarchie (§5) sont l'invariant décennal. |
| TSX-02 | **Les significations restent identiques. Seules les implémentations évolueront** (TSV-02). |
| TSX-03 | Aucune extension ne peut affaiblir l'accessibilité (§8) ni la confiance (§10). |

---

## 14. Descendance

- **Les Design Tokens (P11.8) traduiront ce Typography System** : chaque rôle recevra ses valeurs nommées sous les contraintes du §8.
- **Le Flutter Design Kit (P11.9) implémentera ces tokens** — fidèlement.
- **Aucune implémentation ne pourra créer une nouvelle signification** (TSG-03).

---

## 15. Gouvernance du document

- Ce document est la **référence officielle** du langage sémantique de la typographie de Mentora — deuxième descendant du Design System.
- Toute vague d'implémentation cite le pilier, le rôle, le niveau et les règles (TSV/TSR/TSH/TSM/TSPL/TSA/TST/TSMF/TSG/TSX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le MES et ses descendants (Accessibility opposable), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md), puis ce document (DSD-01).
