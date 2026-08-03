# ELEVATION & SURFACE SYSTEM

**Statut** : Référence officielle du langage de la profondeur et des surfaces de Mentora. Quatrième descendant officiel du [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md).
**Portée** : Architecture fonctionnelle uniquement. Aucune valeur, aucune ombre, aucune transparence, aucune opacité, aucune couleur, aucun rayon, aucun composant technique, aucun code, aucune implémentation. Ce document définit **le langage officiel de la profondeur et des surfaces** ; il traduit les piliers **Elevation** et **Surface** de la fondation ; les valeurs concrètes seront produites par les Design Tokens (P11.8) et implémentées par le Flutter Design Kit (P11.9).
**Préséance** : P9 → P10 → [Accessibility Foundation](accessibility-foundation.md) (**opposable**) → [Global Experience Foundation](global-experience-foundation.md) (**opposable**) → P11.0 → ce document (DSD-01 : il précise, il ne redéfinit rien). Il respecte le [Color System](color-system.md), le [Typography System](typography-system.md) et le [Spacing System](spacing-system.md) sans jamais redéfinir leurs règles.
**Niveaux produits (DSD-02)** : Principles et Standards (§8) ; les Tokens et Implementations viendront de P11.8 et P11.9.
**Transversalité (DSD-03)** : ce système sert Identity (la profondeur incarne le calme et la fiabilité — jamais le spectaculaire) et Documentation (chaque règle est traçable jusqu'à sa règle P10, §7).
**Continuité (MSD-02)** : les surfaces gardent leur place et leur sens à travers toute interruption — ce qui était devant se retrouve devant ; aucune couche ne surgit ni ne disparaît sans raison.

---

## 1. Mission

**L'élévation ne sert jamais à embellir. Elle explique. Elle protège. Elle hiérarchise. Elle guide.**

**Une surface n'est jamais un rectangle. C'est un espace de responsabilité.**

> **La profondeur est une information. Jamais une décoration.**

**Mission en une phrase** : définir ce que signifie être devant, derrière, au-dessus, contenu — et quelles responsabilités portent les surfaces — **sans jamais fixer une valeur graphique**.

---

## 2. Vision

Chaque surface possède une responsabilité. Chaque niveau possède une signification.

Le regard comprend **immédiatement** : ce qui est devant, ce qui est derrière, ce qui protège, ce qui attend, ce qui domine — **sans réflexion** (DPV-02 appliqué à la profondeur).

| Règle | Énoncé |
|---|---|
| ESV-01 | Toute surface porte une responsabilité — une surface sans responsabilité n'existe pas (MSV-04). |
| ESV-02 | Toute élévation porte une signification — une couche sans signification n'existe pas. |
| ESV-03 | **Plus haut ne signifie jamais plus important sans justification métier** : l'élévation découle d'un fait publié (modal exigé, immersion déclarée, attention qualifiée). |
| ESV-04 | La profondeur se comprend sans se percevoir (§3.8) : elle accompagne le sens, elle ne le porte jamais seule. |

---

## 3. Les dix piliers

Dix piliers. Toute règle de profondeur ou de surface appartient à exactement un pilier.

### 3.1 Surface Identity

| | |
|---|---|
| **Mission** | Faire que chaque surface soit une responsabilité — jamais une décoration. |
| **Responsabilités** | Définir l'identité des surfaces : ce qu'une surface est (un contenant d'intention — block, section, surface du Component Foundation), ce qu'elle doit à son contenu (le calme, l'effacement — rôles Surface/Background du Color System). |
| **Frontières** | La surface habille les niveaux de composition (CFL) ; elle n'en crée pas ; son expression concrète appartient aux Tokens. |
| **Ce qu'il garantit** | aucune surface gratuite : chaque cadre, chaque fond existe pour contenir une responsabilité. |
| **Ce qu'il ne possède jamais** | le contenu ; un cadre décoratif (DPV-03). |

### 3.2 Surface Hierarchy

| | |
|---|---|
| **Mission** | Faire que chaque surface exprime sa priorité — jamais une préférence graphique. |
| **Responsabilités** | Définir la subordination des surfaces entre elles : la surface principale de la question, ses sections, leurs blocks — la profondeur relative suit la hiérarchie publiée (DNV-02). |
| **Frontières** | La priorité vient des plateformes ; la hiérarchie de surface l'exprime, elle ne la crée pas. |
| **Ce qu'il garantit** | l'œil sait toujours quelle surface répond à la question (UX-02) et lesquelles la servent. |
| **Ce qu'il ne possède jamais** | la qualification de priorité ; deux surfaces principales (DNV-01). |

### 3.3 Elevation Semantics

| | |
|---|---|
| **Mission** | Donner à l'élévation ses significations — la couche traduit, jamais elle ne stylise. |
| **Responsabilités** | Définir les significations officielles d'être au-dessus : **l'aparté** (Temporary), **la décision** (Modal), **l'immersion** (la Salle), **le signalement** (l'attention qui attend son tour) — chacune une raison publiée, jamais une mode. |
| **Frontières** | Ce qui a le droit de passer devant vient de P10 (Navigation, Focus) ; l'élévation l'exprime (pilier Elevation de P11.0). |
| **Ce qu'il garantit** | être au-dessus signifie toujours la même chose ; aucune couche « pour faire joli ». |
| **Ce qu'il ne possède jamais** | le droit d'interrompre (Focus) ; l'empilement libre (jamais de décisions empilées — Modal). |

### 3.4 Content Containment

| | |
|---|---|
| **Mission** | Faire qu'une surface contienne une intention — jamais plusieurs responsabilités. |
| **Responsabilités** | Tenir la loi du contenant : **une surface répond à une question** (CFL-04) ; ce qui n'appartient pas à la question vit ailleurs ; les frontières du contenu sont les frontières de la surface. |
| **Frontières** | L'intention appartient aux familles de composants ; le contenant la borne, il ne la définit pas. |
| **Ce qu'il garantit** | jamais une surface fourre-tout ; jamais une intention à cheval sur deux surfaces (l'interdit « tronquer/fusionner » du Responsive — RSL). |
| **Ce qu'il ne possède jamais** | le contenu ; une surface à double responsabilité. |

### 3.5 Focus Surfaces

| | |
|---|---|
| **Mission** | Protéger l'attention par la surface — quand une tâche devient prioritaire, le reste s'efface. |
| **Responsabilités** | Définir la surface de concentration : l'acte protégé ou l'immersion isole son sujet ; **le reste s'efface naturellement — jamais brutalement** (Focus Motion : l'entrée est sereine). |
| **Frontières** | Ce qui mérite la concentration est publié (imminence, acte protégé, Salle) ; la surface le sert. |
| **Ce qu'il garantit** | pendant l'important, rien ne rivalise : l'effacement du reste est un acte de protection (Focus Space rendu en profondeur). |
| **Ce qu'il ne possède jamais** | les priorités ; un effacement qui cache une information due (DT-01). |

### 3.6 Temporary Surfaces

| | |
|---|---|
| **Mission** | Régler la vie des surfaces passagères : **elles apparaissent, accomplissent leur mission, disparaissent.** |
| **Responsabilités** | Définir le cycle des surfaces temporaires (apartés — Temporary Navigation) : une mission unique, une durée bornée par elle, une fermeture d'un geste ; **jamais de trace fantôme, jamais de persistance cachée** (DIS-05 appliqué aux surfaces). |
| **Frontières** | L'ouverture résulte d'un geste ou d'un fait publié ; la fermeture rend exactement la surface d'origine (NB-04). |
| **Ce qu'il garantit** | une surface temporaire ne s'installe jamais ; ce qu'elle couvrait se retrouve intact. |
| **Ce qu'il ne possède jamais** | une descendance (l'aparté n'a pas d'enfants) ; un empilement d'apartés. |

### 3.7 Protected Surfaces

| | |
|---|---|
| **Mission** | Porter les décisions importantes — la surface comme enceinte de protection. |
| **Responsabilités** | Définir la surface des actes sensibles et au-delà : elle isole la décision, dit exactement ce qui est en jeu, n'offre que décider ou renoncer (Modal Navigation, Confirmation Interaction). **Son comportement découle du niveau de protection déjà défini par l'Interaction Foundation (IPR) — jamais d'invention locale.** |
| **Frontières** | Le niveau de protection est publié ; la surface protégée l'applique ; une seule à la fois, jamais empilée. |
| **Ce qu'il garantit** | l'irréversible se décide dans une enceinte : rien d'autre n'y parle, rien ne presse (IV-03). |
| **Ce qu'il ne possède jamais** | le niveau de protection ; un usage pour l'ordinaire (IPR-01). |

### 3.8 Accessibility Elevation

| | |
|---|---|
| **Mission** | Faire que la hiérarchie se comprenne sans percevoir la profondeur. |
| **Responsabilités** | Porter l'exigence opposable : **la profondeur n'est jamais le seul moyen de comprendre une hiérarchie** (AFI-03/AFI-04) ; **une surface reste compréhensible sans perception de profondeur** — la structure, l'ordre et le texte disent la même chose ; les états des surfaces jamais ambigus (AFS-02). |
| **Frontières** | Les moyens concrets (contrastes de surfaces, indices non visuels) appartiennent aux Tokens sous ces contraintes ; l'Accessibility Foundation prévaut (AFR-02). |
| **Ce qu'il garantit** | qui ne voit pas les couches comprend quand même : qui est devant, ce qui attend, ce qui protège. |
| **Ce qu'il ne possède jamais** | une « profondeur accessible » à part (AFV-01) ; un sens porté par l'ombre seule. |

### 3.9 Global Adaptation

| | |
|---|---|
| **Mission** | Faire que la profondeur soit universelle — jamais locale. |
| **Responsabilités** | Porter l'exigence internationale : **toutes les cultures comprennent la hiérarchie** ; **aucune convention culturelle sur les couches** (GE-09) ; **LTR et RTL restent équivalents** (GE-07) — devant/derrière et début/fin sont des notions logiques, jamais géométriques. |
| **Frontières** | Le Elevation & Surface respecte intégralement la Global Experience Foundation (opposable) ; la direction est une configuration, jamais un cas particulier de surface. |
| **Ce qu'il garantit** | un expert de n'importe quel pays lit les mêmes couches avec le même sens. |
| **Ce qu'il ne possède jamais** | une métaphore de profondeur propre à une culture ; une surface « localisée ». |

### 3.10 Future Evolution

| | |
|---|---|
| **Mission** | Accueillir les appareils de demain — la représentation s'adapte, jamais la logique. |
| **Responsabilités** | Porter le protocole : **les futurs appareils adapteront la représentation, jamais la logique** (RSE-05) ; les significations d'élévation (§3.3) valent sur tout support, y compris là où la profondeur devient littérale (réalité mixte) ou temporelle (voice — §11). |
| **Frontières** | L'adaptation vit aux niveaux du Responsive Foundation (RSL — Immersion notamment) ; jamais une logique de couches par appareil. |
| **Ce qu'il garantit** | la même grammaire de profondeur du téléphone à la réalité mixte. |
| **Ce qu'il ne possède jamais** | un niveau de plus « parce que l'écran le permet » (ESMF-03). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Elevation & Surface System PEUT |
|---|---|
| ESP-01 | Définir les responsabilités des surfaces. |
| ESP-02 | Définir la hiérarchie des surfaces. |
| ESP-03 | Définir les significations de l'élévation. |
| ESP-04 | Définir le contenant d'intention. |
| ESP-05 | Définir les surfaces de concentration, temporaires et protégées. |
| ESP-06 | Définir les exigences d'accessibilité et d'internationalisation de la profondeur. |

### 4.2 Interdites

| Règle | Le Elevation & Surface System NE PEUT JAMAIS |
|---|---|
| ESN-01 | Décider du contenu — **il décide uniquement de son organisation dans l'espace**. |
| ESN-02 | Calculer. |
| ESN-03 | Posséder les plateformes, les données, les providers, les moteurs. |
| ESN-04 | Posséder les composants — il les contient, il ne les définit pas. |
| ESN-05 | Fixer une valeur graphique (ombre, opacité, rayon — Tokens). |
| ESN-06 | Inventer un niveau de protection (IPR) ou un droit d'interruption (Focus). |
| ESN-07 | Remplacer le MES ou la fondation P11 — il précise les piliers Elevation et Surface, rien de plus. |

---

## 5. Relations avec les plateformes

**Toutes utilisent exactement les mêmes surfaces. Aucune plateforme ne possède sa propre profondeur.**

| Plateforme | Ce que le langage de surface lui garantit |
|---|---|
| Home | la colonne d'intentions sur une scène calme ; les cartes contenues, jamais empilées |
| Consultation | la Salle Live en surface d'immersion unique ; la préparation en surfaces contenues |
| Business | les décisions d'argent en surface protégée (IPR) ; jamais un montant flottant hors contenant |
| AI | les propositions dans leurs surfaces citées ; jamais une surface IA qui s'impose au-dessus du fait |
| Reputation | les preuves qui se déplient dans leur surface ; jamais un signal qui écrase le contenu |
| Account | la sécurité en surface qui isole quand il faut décider ; les réglages en surfaces sobres |

| Règle | Énoncé |
|---|---|
| ESPL-01 | Mêmes surfaces, mêmes significations partout — l'expression métier passe par le contenu (DR-01). |
| ESPL-02 | Aucune plateforme ne peut s'élever au-dessus d'une autre : la profondeur exprime des faits publiés, jamais un rang de plateforme. |
| ESPL-03 | Toute nouvelle plateforme reçoit le langage tel quel (DSR-04). |

---

## 6. Traduction du MES — les règles traduites

Chaque règle traduit une règle amont, citée explicitement. **Une traduction ne modifie jamais la règle** (DSM-02).

| Règle amont traduite | Traduction Elevation & Surface |
|---|---|
| Design Language — DNV-01/02 (une principale, hiérarchie publiée) | Surface Hierarchy (§3.2) |
| Design Language — DPV-03/05 (bruit éliminé, calme permanent) | Surface Identity (§3.1) : aucune surface gratuite ; la scène s'efface |
| Design Language — pilier Focus | Focus Surfaces (§3.5) |
| Component Foundation — CFL-04 (une surface = une question) | Content Containment (§3.4) |
| Component Foundation — famille Immersion | la surface d'immersion unique, sans navigation interne |
| Interaction Foundation — IPR (niveaux de protection) | Protected Surfaces (§3.7) : le comportement découle du niveau publié |
| Interaction Foundation — Confirmation (jamais empilée, IMF-05) | l'interdit d'empilement des surfaces de décision |
| Navigation Foundation — Temporary/Modal/Immersive (§3.4–3.6, ND-05) | Elevation Semantics (§3.3) : les trois significations d'être au-dessus |
| Navigation Foundation — NB-04 (le retour restitue) | Temporary Surfaces (§3.6) : la fermeture rend l'origine intacte |
| Motion Foundation — Focus Motion (entrer/sortir sereinement) | l'effacement naturel, jamais brutal (§3.5) |
| Motion Foundation — Exit (jamais de trace fantôme) | Temporary Surfaces : disparition complète |
| Responsive Foundation — RSL Immersion / RSE-01 | Future Evolution (§3.10) : représentation adaptée, logique intacte ; jamais plus de couches |
| Accessibility Foundation — AFI-03/04, AFS-02 | Accessibility Elevation (§3.8), opposable |
| Global Experience Foundation — GE-07/GE-09 | Global Adaptation (§3.9) : profondeur universelle, LTR/RTL équivalents |

| Règle | Énoncé |
|---|---|
| ESM-01 | Toute règle cite sa règle amont (DSM-01) ; une règle sans origine est rejetée. |
| ESM-02 | Un manque découvert face à une règle amont remonte en révision — jamais comblé silencieusement (DSM-03, GE-15). |

---

## 7. Les états des surfaces

Les surfaces représentent les états **sans jamais modifier la signification déjà définie** dans les fondations précédentes (Component Foundation §8, Color System §5) :

| État | Comment la surface le représente |
|---|---|
| **Disponible** | la surface normale, à sa place dans la hiérarchie. |
| **Indisponible** | la surface reste en place et se dit indisponible (rôle Unavailable) — elle ne s'enfonce pas, ne disparaît pas (IND-01 : distinct du vide). |
| **Attente** | la surface montre le travail réel en son sein (IW-02) — elle ne se voile pas entièrement sans nécessité (IW-03). |
| **Erreur** | l'erreur vit dans la surface concernée — locale, jamais toute la scène (IND-03, IE-07). |
| **Succès** | la surface confirme sobrement, sans monter d'un niveau (IS-03 — le succès ne surélève pas). |
| **Attention** | le signalement attend à son niveau (Focus) — l'attention ne crée pas de couche, elle colore sa surface (rôle Attention). |
| **Focus** | la surface au focus se distingue sans s'élever — le focus est un état, pas une élévation. |
| **Immersion** | la seule bascule totale : la surface d'immersion couvre tout, par sa porte unique (NAV-05). |

| Règle | Énoncé |
|---|---|
| ESE-01 | Un état ne change jamais la place d'une surface dans la hiérarchie — sauf l'immersion, déclarée par la navigation. |
| ESE-02 | Deux états ne se représentent jamais pareil sur une surface (AFS-02). |
| ESE-03 | Aucun état de surface n'invente une signification : tout vient des fondations citées. |

---

## 8. Les niveaux

Six niveaux — la production descend toujours (DSL-01) :

| Niveau | Mission | Responsabilités | Contient | Ne contient jamais |
|---|---|---|---|---|
| **Identity** | la profondeur comme personnalité | relier surfaces et élévation aux 8 qualités (calme, fiable, épuré) | les principes identitaires de la profondeur | une valeur ; une ombre |
| **Semantic** | les significations | les significations d'élévation (§3.3) et les responsabilités de surface | les règles nommées des piliers | une couche décorative |
| **Hierarchy** | l'ordre des surfaces | la subordination officielle (principale, sections, blocks ; apartés, décisions, immersion) | les relations de profondeur relatives | une profondeur absolue ; un rang de plateforme |
| **Surface** | la surface en situation | l'application par famille et niveau de composition (CFL) | les règles d'application par famille | une règle nouvelle ; une exception locale |
| **Token** | les valeurs nommées | (produit par P11.8) chaque signification reçoit son expression | la nomenclature signification → valeurs | une signification nouvelle |
| **Implementation** | la profondeur dans la technologie | (produit par P11.9) la consommation fidèle | le code des kits | une valeur en dur ; un écart |

---

## 9. Les principes de confiance

| Règle | La profondeur |
|---|---|
| EST-01 | **ne ment jamais** : être au-dessus dit une vraie raison publiée. |
| EST-02 | **ne dramatise jamais** (IV-03) : une surface protégée est calme, pas théâtrale. |
| EST-03 | **ne manipule jamais** : jamais une couche qui pousse vers un choix (DT-03). |
| EST-04 | **ne cache jamais** : couvrir n'est jamais soustraire une information due (DT-01) ; ce qui est couvert se retrouve intact. |
| EST-05 | **ne surprend jamais** (PX-04) : une surface n'apparaît que d'un geste ou d'un fait annoncé. |
| EST-06 | **protège toujours l'attention** (pilier Focus). |
| EST-07 | **reste intemporelle** (DST-05) : aucune mode de relief. |

Ces principes sont **perpétuels**.

---

## 10. Mobile First

| Règle | Énoncé |
|---|---|
| ESMF-01 | **Le Mobile reste la référence** : la hiérarchie de surfaces se définit sur téléphone (DSMF-01). |
| ESMF-02 | **Une hiérarchie qui échoue sur Mobile échoue partout** (DSMF-03). |
| ESMF-03 | **Plus d'espace ne crée jamais plus de couches. Le Desktop n'ajoute jamais de nouveaux niveaux** (RSE-01/02 appliqués à la profondeur). |
| ESMF-04 | Sur petit écran, la profondeur reste sobre : peu de couches simultanées, jamais d'empilement (ND-05 : hors profondeur ne veut pas dire nombreux). |

---

## 11. Gouvernance

| Règle | Énoncé |
|---|---|
| ESG-01 | **Aucun écran ne définit sa propre profondeur.** |
| ESG-02 | **Aucune équipe ne crée ses propres surfaces** (DSC-04). |
| ESG-03 | Toute évolution appartient à ce système — par révision de ce document. |
| ESG-04 | **Les violations deviendront des balayages exécutables** dès la première vague d'implémentation (couches locales, élévations arbitraires, empilements : détectables et interdits). |

---

## 12. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Pliables, tablettes, desktop | mêmes significations, représentation adaptée (RSL) — jamais un niveau de plus |
| TV | la hiérarchie lisible à distance ; les surfaces protégées gardent leur enceinte |
| Wearables | une seule surface à la fois : la hiérarchie devient séquence |
| Réalité mixte | la profondeur devient littérale : les significations (§3.3) valent dans l'espace réel — l'enceinte de décision, l'immersion, l'aparté y gardent leurs lois |
| **Voice** | **la profondeur devient une priorité conversationnelle** : ce qui serait « devant » parle en premier ; l'enceinte protégée devient un tour de parole exclusif (la confirmation s'énonce seule, rien ne l'interrompt) ; l'aparté devient une parenthèse dite et refermée ; l'immersion devient le sujet unique de la conversation |
| Nouveaux appareils | le protocole Future Evolution (§3.10) : représentation adaptée, logique identique |

| Règle | Énoncé |
|---|---|
| ESX-01 | Les dix piliers (§3), les significations d'élévation (§3.3) et les six niveaux (§8) sont l'invariant décennal. |
| ESX-02 | La philosophie de profondeur reste identique sur tout support ; seules les représentations évoluent. |
| ESX-03 | Aucune extension ne peut affaiblir l'Accessibility Elevation (§3.8) ni la Global Adaptation (§3.9) — les deux opposables. |

---

## 13. Gouvernance du document

- Ce document est la **référence officielle** du langage de la profondeur et des surfaces de Mentora — quatrième descendant du Design System, traduisant les piliers **Elevation** et **Surface**.
- **Conformité aux fondations opposables** : l'Accessibility Foundation est servie par Accessibility Elevation (§3.8 — la profondeur jamais seul moyen de comprendre, une surface compréhensible sans perception de profondeur) et opposable à tout arbitrage (AFR-02, ESX-03) ; la Global Experience Foundation est servie par Global Adaptation (§3.9 — aucune convention culturelle sur les couches, LTR/RTL équivalents, profondeur universelle) et opposable de même (GE-15).
- Toute vague d'implémentation cite le pilier, le niveau, l'état et les règles (ESV/ESP/ESN/ESPL/ESM/ESE/EST/ESMF/ESG/ESX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables (Accessibility, Global Experience), puis le [MENTORA DESIGN SYSTEM FOUNDATION](mentora-design-system-foundation.md), puis ce document (DSD-01).
