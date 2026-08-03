# ICONOGRAPHY SYSTEM

**Statut** : Référence officielle du langage des icônes de Mentora. Cinquième descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md).
**Portée** : Architecture fonctionnelle uniquement. Aucune icône, aucun SVG, aucun pictogramme, aucune bibliothèque, aucun package, aucun code, aucune implémentation. Ce document définit **le langage officiel des icônes** ; il traduit le pilier **Iconography** de la fondation ; les composants utiliseront ensuite ce langage, les Tokens (P11.8) le nommeront, le Flutter Design Kit (P11.9) l'implémentera.
**Préséance** : P9 → P10 → [Accessibility Foundation](accessibility-foundation.md) (**opposable**) → [Global Experience Foundation](global-experience-foundation.md) (**opposable**) → P11.0 → ce document (DSD-01 : il précise, il ne redéfinit rien). Il respecte le [Color System](color-system.md), le [Typography System](typography-system.md), le [Spacing System](spacing-system.md) et l'[Elevation & Surface System](elevation-surface-system.md) sans jamais redéfinir leurs règles.
**Niveaux produits (DSD-02)** : Principles et Standards (§8) ; les Tokens et Implementations viendront de P11.8 et P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (l'icône incarne la précision et l'intemporalité) et Documentation (chaque signification est traçable jusqu'à sa règle P10, §7).
**Continuité (MSD-02)** : le vocabulaire iconographique est stable partout et toujours — la même intention porte le même signe avant, pendant et après toute interruption, sur tout support.

---

## 1. Mission

**Une icône n'est jamais un dessin. Une icône est un mot.**

Elle aide à comprendre. Elle confirme. Elle oriente. Elle rassure. **Elle n'explique jamais seule.**

> **Une icône remplace rarement un texte. Elle accompagne presque toujours un texte.**

**Mission en une phrase** : définir le vocabulaire pictographique officiel — significations, familles, relations, règles d'usage — **sans jamais dessiner une icône**.

---

## 2. Vision

Chaque icône possède **une signification officielle. Jamais plusieurs. Jamais ambiguë. Jamais culturelle. Jamais décorative.**

| Règle | Énoncé |
|---|---|
| ICV-01 | **Une icône existe parce qu'elle transmet une intention. Jamais parce qu'elle est jolie** (DPV-03). |
| ICV-02 | Une icône sans signification officielle n'existe pas (DSG appliqué : rien de concret hors système). |
| ICV-03 | Toute signification traduit une règle ou une intention P10 (§7) ; une signification sans origine est rejetée (DSM-01). |
| ICV-04 | La forme dit sa fonction (Clarity) : le signe ressemble à ce qu'il signifie — jamais un rébus. |

---

## 3. Les dix piliers

Dix piliers. Toute règle iconographique appartient à exactement un pilier.

### 3.1 Semantic Iconography

| | |
|---|---|
| **Mission** | Faire que chaque icône exprime **une seule idée. Jamais plusieurs.** |
| **Responsabilités** | Tenir la loi du mot : une icône = une signification atomique ; les idées composées s'expriment par composition (texte + icône), jamais par un signe surchargé. |
| **Frontières** | La signification vient d'une intention P10 ; le pilier la fixe, il ne l'invente pas. |
| **Ce qu'il garantit** | aucune icône polysémique : voir le signe, c'est savoir l'idée. |
| **Ce qu'il ne possède jamais** | un signe à double lecture ; une idée sans signe officiel qui s'exprimerait « à peu près ». |

### 3.2 Meaning Consistency

| | |
|---|---|
| **Mission** | Tenir l'équation : **une signification = une icône. Jamais deux.** |
| **Responsabilités** | Garantir l'unicité dans les deux sens : jamais deux icônes pour la même signification (CFU-02 appliqué) ; **une même icône ne change jamais de sens** — nulle part, jamais (PX-07). |
| **Frontières** | La cohérence vaut sur toutes les plateformes, tous les supports, toutes les époques du produit. |
| **Ce qu'il garantit** | l'expert apprend chaque signe une fois — pour toujours. |
| **Ce qu'il ne possède jamais** | un synonyme visuel ; un sens contextuel. |

### 3.3 Navigation Icons

| | |
|---|---|
| **Mission** | Orienter — les signes du déplacement. |
| **Responsabilités** | Définir les significations d'orientation : les entrées de plateformes, les retours, les traversées, les portes (Navigation Foundation) — **les icônes orientent, jamais elles ne remplacent la navigation**. |
| **Frontières** | Les trajets appartiennent à la Navigation Foundation ; l'icône les signe, accompagnée de son libellé (rôle Navigation du Typography System). |
| **Ce qu'il garantit** | on reconnaît une porte avant de lire son nom — et le nom est là (ICA-01). |
| **Ce qu'il ne possède jamais** | un trajet ; une entrée cachée derrière un signe seul (NG-04). |

### 3.4 Action Icons

| | |
|---|---|
| **Mission** | Annoncer l'agir — **une icône annonce une action. Jamais une conséquence.** |
| **Responsabilités** | Définir les significations d'action : le signe dit l'acte (accepter, écarter, répondre, retirer) — la conséquence est dite par le texte et la confirmation (Compréhension, IPR). |
| **Frontières** | L'acte et sa protection appartiennent à l'Interaction Foundation ; le signe l'annonce, le libellé le précise (jamais un acte sensible derrière une icône seule). |
| **Ce qu'il garantit** | aucun acte déclenché sur un signe mal compris : l'icône annonce, le texte engage. |
| **Ce qu'il ne possède jamais** | le déclenchement ; la promesse d'un résultat. |

### 3.5 State Icons

| | |
|---|---|
| **Mission** | Signer les états — **les états officiels du Component Foundation. Aucune invention.** |
| **Responsabilités** | Définir les signes des huit états (disponible, indisponible, attente, erreur, succès, attention, sélection, focus) — chacun aligné sur son rôle couleur (§5 du Color System) et exprimé avec au moins une autre forme. |
| **Frontières** | Les états sont publiés ; le signe les accompagne, jamais seul (CSA-01 étendu au signe). |
| **Ce qu'il garantit** | un état se reconnaît d'un coup d'œil — et se comprend sans le voir (§3.7). |
| **Ce qu'il ne possède jamais** | un état nouveau ; deux signes pour le même état. |

### 3.6 Trust Icons

| | |
|---|---|
| **Mission** | Signer l'honnêteté — chaque notion de confiance possède son langage. Jamais ambigu. |
| **Responsabilités** | Définir les signes de confiance : **les preuves, les vérifications, les certifications, les recommandations IA, les estimations, les avertissements, les informations** — chacun distinct, aligné sur les rôles Trust/AI du Color System (Verified, Declared, Prediction, Estimate, AI Suggestion). |
| **Frontières** | La preuve appartient aux plateformes ; le signe la signale et se déplie vers elle (RT-03) — il ne la remplace jamais (ICT-04). |
| **Ce qu'il garantit** | le vérifié, le déclaré, l'estimé et le proposé IA ne se confondent jamais — même d'un coup d'œil. |
| **Ce qu'il ne possède jamais** | la vérification ; un signe de confiance décoratif. |

### 3.7 Accessibility Iconography

| | |
|---|---|
| **Mission** | Faire que le signe n'exclue jamais. |
| **Responsabilités** | Porter l'exigence opposable : **une icône ne porte jamais seule une information** (AFI-04) ; **elle reste compréhensible avec ou sans vision** — chaque signe possède son équivalent textuel de plein droit ; les cibles iconiques respectent l'espace d'interaction (Interaction Space). |
| **Frontières** | Les moyens concrets (tailles minimales, alternatives) appartiennent aux Tokens sous ces contraintes ; l'Accessibility Foundation prévaut (AFR-02). |
| **Ce qu'il garantit** | qui ne voit pas les signes ne perd rien : le langage iconographique a un double parlé et écrit complet. |
| **Ce qu'il ne possède jamais** | une information exclusive au signe ; une icône-mystère à deviner. |

### 3.8 Global Neutrality

| | |
|---|---|
| **Mission** | Faire que chaque signe soit compris dans toutes les cultures. |
| **Responsabilités** | Porter l'exigence internationale (GE-09) : **aucun symbole ne suppose une culture locale ; aucune métaphore régionale** (gestes, animaux, objets à sens variable proscrits) ; **LTR et RTL ne changent jamais la signification** (GE-07) — les signes directionnels se pensent en début/fin logiques. |
| **Frontières** | L'Iconography respecte intégralement la Global Experience Foundation (opposable) ; un doute culturel se résout par le signe le plus universel — ou par le texte. |
| **Ce qu'il garantit** | un expert de Bamako, Séoul ou Riyad lit le même signe avec le même sens. |
| **Ce qu'il ne possède jamais** | un symbole à double lecture culturelle ; une icône « localisée ». |

### 3.9 Icon Relationships

| | |
|---|---|
| **Mission** | Faire des icônes **une famille. Jamais une collection.** |
| **Responsabilités** | Définir la parenté : les signes d'une même famille (§9) se ressemblent dans leur construction ; les signes apparentés (ouvrir/fermer, accepter/écarter) se répondent visuellement ; le langage reste cohérent dans son ensemble (Consistency). |
| **Frontières** | La grammaire formelle concrète (grille, trait) appartient aux Tokens ; ce pilier fixe la loi de parenté. |
| **Ce qu'il garantit** | le vocabulaire s'apprend comme une langue : connaître dix signes aide à lire le onzième. |
| **Ce qu'il ne possède jamais** | un signe étranger à la famille ; un mélange de styles (jamais une collection hétéroclite). |

### 3.10 Future Evolution

| | |
|---|---|
| **Mission** | Accueillir les signes de demain — le langage évolue, jamais la philosophie. |
| **Responsabilités** | Porter le protocole d'ajout : une nouvelle signification naît d'une intention P10, reçoit son signe unique par révision de ce document, entre dans une famille (§9) et respecte tous les piliers. |
| **Frontières** | **Les futures icônes respectent les mêmes règles** ; un besoin qui ne trouve ni famille ni signification est un signal de révision — jamais un signe improvisé. |
| **Ce qu'il garantit** | le centième signe parle la langue du premier. |
| **Ce qu'il ne possède jamais** | un signe en réserve ; une signification spéculative. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | L'Iconography System PEUT |
|---|---|
| ICP-01 | Définir les significations officielles. |
| ICP-02 | Définir les familles et les parentés. |
| ICP-03 | Définir les règles d'usage (accompagnement textuel, interdits). |
| ICP-04 | Définir les exigences d'accessibilité et de neutralité des signes. |
| ICP-05 | Définir le protocole d'ajout de signes. |

### 4.2 Interdites

| Règle | L'Iconography System NE PEUT JAMAIS |
|---|---|
| ICN-01 | Décider du métier — **il exprime uniquement les intentions**. |
| ICN-02 | Calculer. |
| ICN-03 | Posséder les plateformes, les données, les providers, les moteurs. |
| ICN-04 | Dessiner — aucun SVG, aucun tracé, aucune bibliothèque (Tokens/Implementations). |
| ICN-05 | Inventer une intention, un état ou un niveau de protection. |
| ICN-06 | Remplacer le MES ou la fondation P11 — il précise le pilier Iconography, rien de plus. |

---

## 5. Relations avec les plateformes

**Toutes utilisent exactement le même langage iconographique. Aucune plateforme ne crée ses propres icônes.**

| Plateforme | Ce que le langage des signes lui garantit |
|---|---|
| Home | les intentions des cartes signées d'un mot visuel ; l'écart d'un geste sur un signe connu |
| Consultation | les étapes du cycle et l'imminence signées sans ambiguïté ; la Salle sans signes décoratifs |
| Business | l'argent signé sobrement ; jamais un signe qui dramatise un montant |
| AI | toute proposition portant le signe IA unique (aligné sur AI Suggestion) |
| Reputation | le vérifié et le déclaré signés distinctement ; la preuve dépliable derrière son signe |
| Account | la sécurité signée gravement mais calmement ; les réglages signés simplement |

| Règle | Énoncé |
|---|---|
| ICPL-01 | Mêmes signes, mêmes sens partout — l'expression métier passe par le contenu (DR-01). |
| ICPL-02 | Aucune plateforme ne peut créer, détourner ou promouvoir un signe. |
| ICPL-03 | Toute nouvelle plateforme reçoit le vocabulaire tel quel (DSR-04). |

---

## 6. Traduction du MES — les règles traduites

Chaque règle iconographique traduit une règle amont, citée explicitement. **Une traduction ne modifie jamais la règle** (DSM-02).

| Règle amont traduite | Traduction iconographique |
|---|---|
| Design Language — Clarity (une forme dit sa fonction) | ICV-04 : le signe ressemble à ce qu'il signifie |
| Design Language — DPV-03 (bruit éliminé) | ICV-01 : jamais d'icône décorative |
| Design Language — Consistency / PX-07 | Meaning Consistency (§3.2) : un sens, un signe, partout, toujours |
| Interaction Foundation — Compréhension des actes / IPR | Action Icons (§3.4) : le signe annonce, le texte engage ; jamais un acte sensible sur un signe seul |
| Navigation Foundation — NG-04 (aucune navigation cachée) | Navigation Icons (§3.3) : jamais une porte derrière un signe seul |
| Component Foundation — les 8 états (CFS) | State Icons (§3.5) : les états signés sans invention |
| Component Foundation — CFU-02 (jamais deux pour une intention) | Meaning Consistency : jamais deux signes pour un sens |
| Accessibility Foundation — AFI-04 (plusieurs moyens de comprendre) | Accessibility Iconography (§3.7) : jamais un signe seul porteur, équivalent textuel de plein droit |
| Responsive Foundation — RSCO-05 (même langage partout) | le vocabulaire unique sur tout appareil |
| Global Experience Foundation — GE-07/GE-09 | Global Neutrality (§3.8) : aucun symbole culturel, directions logiques |
| Motion Foundation — MI (intentions du mouvement) | un signe peut être animé uniquement au service d'une intention officielle du mouvement — jamais pour vivre |
| Color System — rôles Trust/AI (§4.5) | Trust Icons (§3.6) : signes alignés sur les rôles, jamais en conflit |

| Règle | Énoncé |
|---|---|
| ICM-01 | Toute signification cite son origine amont (DSM-01) ; une signification sans origine est rejetée. |
| ICM-02 | Un manque découvert face à une règle amont remonte en révision — jamais comblé par un signe improvisé (DSM-03, GE-15). |

---

## 7. Règles d'accompagnement

| Règle | Énoncé |
|---|---|
| ICA-01 | **Une icône accompagne presque toujours un texte** : le signe + le mot, ensemble. |
| ICA-02 | Une icône seule n'est permise que pour les significations apprises du vocabulaire de base (navigation racine, états universels) — et son équivalent textuel reste accessible (§3.7). |
| ICA-03 | Jamais une icône seule pour : un acte sensible ou au-delà, une notion de confiance, un montant, une première rencontre avec une signification. |
| ICA-04 | Le texte prime en cas de doute : quand le signe risque l'ambiguïté, le mot parle (Global Neutrality). |

---

## 8. Les niveaux

Six niveaux — la production descend toujours (DSL-01) :

| Niveau | Mission | Responsabilités | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Identity** | le signe comme personnalité | relier le vocabulaire aux 8 qualités (précis, épuré, intemporel) | les principes identitaires des signes | un dessin ; un style de mode |
| **Semantic** | les significations | le registre officiel : signification ↔ intention P10 | les significations nommées, usages et interdits | un tracé ; un synonyme |
| **Relationship** | la parenté | les familles (§9) et les couples de signes qui se répondent | les lois de parenté et d'opposition | un signe orphelin |
| **Component** | le signe en situation | l'application par famille de composants (où un signe accompagne quoi) | les règles d'accompagnement par famille | une signification nouvelle ; une exception |
| **Token** | les signes nommés | (produit par P11.8) chaque signification reçoit son identifiant et son tracé de référence | la nomenclature signification → signe | un sens nouveau |
| **Implementation** | le signe dans la technologie | (produit par P11.9) la consommation fidèle | le code des kits | une icône hors registre ; un écart |

---

## 9. Les familles officielles

Dix familles. **Les familles expriment des intentions. Jamais des écrans.** Tout signe appartient à exactement une famille.

| Famille | Intentions signées |
|---|---|
| **Navigation** | entrer, revenir, traverser, ouvrir la porte d'une plateforme |
| **Actions** | agir : accepter, écarter, répondre, créer, modifier |
| **États** | les huit états officiels, signés |
| **Confiance** | vérifié, déclaré, preuve, estimation, avertissement, information |
| **Communication** | les conversations : message, notification, réponse |
| **Business** | l'économique : revenu, paiement, retrait, objectif |
| **Consultation** | le cycle : agenda, préparation, salle, résumé, suivi |
| **AI** | le signe IA unique et ses déclinaisons d'intention (proposition, insight, connaissance) |
| **Sécurité** | protéger : appareil, accès, alerte, confidentialité |
| **Système** | l'environnement : réglages, aide, support, langue |

| Règle | Énoncé |
|---|---|
| ICF-01 | Un signe par famille, une famille par signe ; les familles se reconnaissent à leur construction (Icon Relationships). |
| ICF-02 | Une nouvelle famille exige la révision de ce document — jamais une collection parallèle. |

---

## 10. Les principes de confiance

| Règle | Les icônes |
|---|---|
| ICT-01 | **ne mentent jamais** : le signe dit l'état vrai, publié. |
| ICT-02 | **ne manipulent jamais** — aucun signe qui pousse vers un choix (DT-03). |
| ICT-03 | **ne dramatisent jamais** (IV-03) : le signe d'alerte est grave, pas hystérique. |
| ICT-04 | **ne remplacent jamais une preuve** (CSA-02 étendu). |
| ICT-05 | **ne remplacent jamais une explication** : le signe annonce, le texte explique (ICA). |
| ICT-06 | **restent intemporelles** (DST-05) : aucun style de mode, aucun signe daté. |

Ces principes sont **perpétuels**.

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| ICMF-01 | **Une icône doit être immédiatement comprise sur Mobile** : petite, dans la main, en mouvement. |
| ICMF-02 | **Une icône incompréhensible sur téléphone est invalide partout** (DSMF-03). |
| ICMF-03 | Les cibles iconiques respectent l'espace du pouce (Interaction Space) — jamais un signe minuscule pour gagner de la place. |
| ICMF-04 | Les autres appareils adaptent la présentation des signes — jamais leur signification. |

---

## 12. Gouvernance

| Règle | Énoncé |
|---|---|
| ICG-01 | **Aucun écran ne crée ses propres icônes.** |
| ICG-02 | **Aucune équipe ne crée son propre vocabulaire** (DSC-04). |
| ICG-03 | Toute évolution appartient à ce système — par révision de ce document (Future Evolution). |
| ICG-04 | **Les violations deviendront des balayages exécutables** dès la première vague d'implémentation (icônes hors registre, signes locaux, détournements de sens : détectables et interdits). |

---

## 13. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Pliables, tablettes, desktop | mêmes signes, présentation adaptée (RSL) |
| TV | les signes lisibles à distance ; jamais un vocabulaire de plus |
| Wearables | le sous-ensemble essentiel : états, imminence, sécurité — signés à l'identique |
| Réalité mixte | les mêmes significations dans l'espace ; la parenté formelle demeure |
| **Voice** | **une icône devient une intention conversationnelle sans représentation visuelle** : la signification se dit — le signe « vérifié » devient l'énoncé de vérification, le signe IA devient l'annonce de provenance (« l'IA propose »), le signe d'alerte devient le ton et l'annonce de gravité. **Les mêmes significations survivent à l'absence d'écran** : le registre sémantique (§8, niveau Semantic) est la source commune du signe visuel et de son énoncé parlé. |
| Nouveaux appareils | le protocole Future Evolution (§3.10) |

| Règle | Énoncé |
|---|---|
| ICX-01 | Les dix piliers (§3), les dix familles (§9) et les six niveaux (§8) sont l'invariant décennal. |
| ICX-02 | **Le langage évolue. Jamais la philosophie.** |
| ICX-03 | Aucune extension ne peut affaiblir l'Accessibility Iconography (§3.7) ni la Global Neutrality (§3.8) — les deux opposables. |

---

## 14. Gouvernance du document

- Ce document est la **référence officielle** du langage des icônes de Mentora — cinquième descendant du Design System, traduisant le pilier **Iconography**.
- **Conformité aux fondations opposables** : l'Accessibility Foundation est servie par Accessibility Iconography (§3.7 — jamais un signe seul porteur d'information, équivalent textuel de plein droit, compréhensible avec ou sans vision) et opposable à tout arbitrage (AFR-02, ICX-03) ; la Global Experience Foundation est servie par Global Neutrality (§3.8 — aucun symbole culturel, aucune métaphore régionale, LTR/RTL sans changement de sens) et opposable de même (GE-15).
- Toute vague d'implémentation cite le pilier, la famille, le niveau et les règles (ICV/ICP/ICN/ICPL/ICM/ICA/ICF/ICT/ICMF/ICG/ICX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables (Accessibility, Global Experience), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md), puis ce document (DSD-01).
