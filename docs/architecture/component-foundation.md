# COMPONENT FOUNDATION

**Statut** : Référence officielle du langage des composants de Mentora.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget Flutter, aucun package, aucun design Figma, aucun pixel, aucun code, aucun pseudo-code, aucune maquette. Cette fondation ne décrit aucun composant technique — elle décrit **le langage officiel des composants de Mentora**. Les implémentations viendront plus tard.
**Filiation** : cinquième descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) — il réalise officiellement le pilier **Components** (MSD-01 : il précise, ne redéfinit pas). Il respecte les fondations [Navigation](navigation-foundation.md), [Interaction](interaction-foundation.md), [Design Language](design-language-foundation.md) et [Motion](motion-foundation.md) ; P9.0 prévaut en cas de conflit. Les descendants Accessibility et Responsive devront le respecter. Les composants concrets naîtront du Design System (MSD-03) — jamais en dehors de ce langage.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par la stabilité de son vocabulaire — le même composant dit la même chose partout et toujours ; un état interrompu se rouvre dans le même langage qu'à sa fermeture.

---

## 1. Mission

**Mission en une phrase** : définir le langage officiel des composants — les familles, les niveaux de composition, les états, les règles de réutilisation — et rien d'autre.

Il ne possède jamais : les plateformes métier, les données, les composants Flutter, les providers, les moteurs, les plateformes système, la logique métier.

---

## 2. Vision

Dans Mentora, **un composant n'existe jamais pour lui-même**.

| Règle | Énoncé |
|---|---|
| CFV-01 | Chaque composant représente une **intention** (CI-01 du Home généralisé). |
| CFV-02 | Chaque composant possède une **responsabilité** — une seule (MSV-04). |
| CFV-03 | Chaque composant appartient à une **famille** (§3) — un composant sans famille n'existe pas. |
| CFV-04 | **Le composant est un mot. Les écrans sont des phrases. Les plateformes sont des conversations.** Le langage se parle du mot vers la conversation — jamais l'inverse. |

---

## 3. Les familles officielles

Dix familles. Tout composant de Mentora appartient à exactement une famille.

### 3.1 Information

| | |
|---|---|
| **Mission** | Dire un fait — à son niveau visuel, avec son honnêteté. |
| **Responsabilités** | Porter les faits publiés (un montant et sa lecture, une échéance, un signal de confiance) ; respecter les niveaux visuels (§7 du Design Language) et l'honnêteté des états (Trust). |
| **Frontières** | L'information affiche ; elle ne sollicite pas (famille Attention) et n'agit pas (famille Action). |
| **Ce qu'elle représente** | « voilà ce qui est. » |
| **Ce qu'elle ne possède jamais** | le fait lui-même (publié par sa plateforme) ; une action cachée. |

### 3.2 Action

| | |
|---|---|
| **Mission** | Permettre d'agir — l'action principale unique, et les secondaires repliées. |
| **Responsabilités** | Porter les intentions d'agir ; refléter le niveau de protection publié (§8 de l'Interaction Foundation) ; accuser chaque déclenchement (IF-02). |
| **Frontières** | L'action transmet l'intention au propriétaire ; l'effet appartient à la plateforme (IR-02). |
| **Ce qu'elle représente** | « voilà ce que tu peux faire ici. » |
| **Ce qu'elle ne possède jamais** | la décision ; l'effet ; deux responsabilités à la fois. |

### 3.3 Navigation

| | |
|---|---|
| **Mission** | Permettre de se déplacer — selon les types officiels de la Navigation Foundation. |
| **Responsabilités** | Porter les portes (entrées de plateformes, traversées explicites, retours) ; dire toujours où l'on est (PX-01). |
| **Frontières** | Elle porte les trajets définis par la Navigation Foundation ; elle n'en invente jamais (NR-01). |
| **Ce qu'elle représente** | « voilà où tu es, voilà où tu peux aller. » |
| **Ce qu'elle ne possède jamais** | le contenu des destinations ; un trajet caché (NG-04). |

### 3.4 Selection

| | |
|---|---|
| **Mission** | Permettre de choisir — clairement, réversiblement. |
| **Responsabilités** | Porter les choix (une option, une plage, un élément d'une liste) ; montrer l'état choisi ; permettre de défaire (moment Sélection). |
| **Frontières** | La sélection prépare une intention ; elle ne l'exécute pas — l'exécution appartient à la famille Action. |
| **Ce qu'elle représente** | « voilà ce que tu as choisi — tu peux encore changer. » |
| **Ce qu'elle ne possède jamais** | l'engagement (un choix sélectionné n'est pas un choix soumis). |

### 3.5 Input

| | |
|---|---|
| **Mission** | Recueillir — la parole de l'expert, sans jamais la perdre. |
| **Responsabilités** | Porter la saisie (texte, valeur, réponse structurée) ; préserver le travail à tout instant (IE-05, NB-05) ; dire ce qui est attendu et ce qui manque. |
| **Frontières** | L'input recueille ; la validation du sens appartient au propriétaire métier ; la protection au niveau publié. |
| **Ce qu'elle représente** | « exprime-toi — rien ne sera perdu. » |
| **Ce qu'elle ne possède jamais** | l'interprétation de la saisie ; sa persistance (mécanismes). |

### 3.6 Confirmation

| | |
|---|---|
| **Mission** | Sceller — l'accord explicite au moment exact (Confirmation Interaction). |
| **Responsabilités** | Porter les consentements et confirmations (sensible et au-delà, IPR-02) ; dire exactement ce qui va se passer et sa réversibilité ; offrir le renoncement sans reproche. |
| **Frontières** | Une confirmation par acte, jamais deux (IMF-05) ; réservée aux niveaux qui l'exigent (IPR-01). |
| **Ce qu'elle représente** | « es-tu sûr ? — voilà exactement ce que ça engage. » |
| **Ce qu'elle ne possède jamais** | la décision ; la banalisation (jamais pour l'ordinaire). |

### 3.7 Attention

| | |
|---|---|
| **Mission** | Signaler — ce qui mérite le regard, qualifié par sa plateforme. |
| **Responsabilités** | Porter les signalements (attention, alerte, imminence) à l'intensité juste (l'attention se distingue de l'urgence — état Attention du Design Language) ; respecter l'écartable et le non-écartable (DIS-03). |
| **Frontières** | Elle signale ce que les plateformes ont qualifié (MA-01) ; elle n'invente jamais une urgence (DT-04). |
| **Ce qu'elle représente** | « ceci mérite ton regard. » |
| **Ce qu'elle ne possède jamais** | la qualification d'importance ; le contenu signalé. |

### 3.8 Progression

| | |
|---|---|
| **Mission** | Montrer où l'on en est — d'un travail, d'un parcours, d'un objectif. |
| **Responsabilités** | Porter l'avancement réel (IW-02 : jamais inventé) : l'attente en cours, le pas du parcours guidé, la progression d'objectif publiée. |
| **Frontières** | La progression reflète un état publié ; elle ne calcule rien (CFN-02) et ne promet rien. |
| **Ce qu'elle représente** | « voilà le chemin parcouru — voilà ce qui reste. » |
| **Ce qu'elle ne possède jamais** | l'estimation maquillée en certitude (DT-05) ; la pression (jamais de culpabilisation). |

### 3.9 Presentation

| | |
|---|---|
| **Mission** | Structurer — donner un cadre lisible aux contenus sans rien leur ajouter. |
| **Responsabilités** | Porter la structure des surfaces (regroupement, séparation, respiration — Visual Rhythm) ; faire coexister les niveaux visuels (DNV-01). |
| **Frontières** | La présentation organise ; elle ne hiérarchise pas d'elle-même (la hiérarchie découle des priorités publiées, DNV-02). |
| **Ce qu'elle représente** | « voilà comment ça se range. » |
| **Ce qu'elle ne possède jamais** | le contenu ; une responsabilité d'affichage d'information (famille Information). |

### 3.10 Immersion

| | |
|---|---|
| **Mission** | Contenir l'acte total — la Salle Live et ses surfaces. |
| **Responsabilités** | Porter le plein écran hors navigation (NAV-05, Immersive Navigation) : l'acte, ses états continus discrets (REC), sa sortie propre. |
| **Frontières** | L'immersion est déclarée par sa plateforme et sa navigation ; ses surfaces internes restent gouvernées par les plateformes système (Experience). |
| **Ce qu'elle représente** | « il n'y a plus que ça, le temps qu'il faut. » |
| **Ce qu'elle ne possède jamais** | le contenu de l'acte ; une navigation interne (aucune Bottom Navigation en immersion). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | Le Component Foundation PEUT |
|---|---|
| CFP-01 | Définir les familles. |
| CFP-02 | Définir les responsabilités. |
| CFP-03 | Définir les intentions. |
| CFP-04 | Définir les comportements communs. |
| CFP-05 | Définir les relations entre composants. |
| CFP-06 | Définir la composition. |
| CFP-07 | Définir les règles de réutilisation. |

### 4.2 Interdites

| Règle | Le Component Foundation NE PEUT JAMAIS |
|---|---|
| CFN-01 | Décider. |
| CFN-02 | Calculer. |
| CFN-03 | Posséder les plateformes métier. |
| CFN-04 | Posséder les données. |
| CFN-05 | Posséder les providers. |
| CFN-06 | Posséder les moteurs. |
| CFN-07 | Décrire Flutter — aucun framework, aucun widget, aucun package. |
| CFN-08 | Remplacer le MES — il précise son pilier Components, rien de plus. |

---

## 5. Relation avec les plateformes

**Toutes les plateformes utilisent les mêmes familles. Aucune plateforme ne crée ses propres composants.**

Une plateforme exprime **son métier**. Le Component Foundation exprime **son langage**.

| Plateforme | Son métier s'exprime… | …dans le langage commun |
|---|---|---|
| Home | les remontées, les moments | Information + Attention dans une Presentation en colonne |
| Consultation | le cycle, l'imminence, la Salle | Progression du cycle, Action de transition, Immersion pour le Live |
| Business | les faits économiques, les objectifs | Information avec lecture, Progression d'objectif, Confirmation pour l'argent |
| AI | les propositions citées | Information citée IA + Action d'accueil/écart au même coût (AE-03) |
| Reputation | les preuves, les signaux | Information dépliable vers ses preuves (RT-03), Input pour les réponses |
| Account | l'environnement, la sécurité | Information d'état exact, Confirmation pour les actes protégés |

| Règle | Énoncé |
|---|---|
| CFR-01 | Aucun composant spécifique à une plateforme : le besoin d'une plateforme enrichit une famille commune, pour toutes. |
| CFR-02 | Un composant ne connaît jamais la plateforme qui l'utilise (CFC-02) ; la plateforme fournit le contenu, le composant fournit la forme d'intention. |
| CFR-03 | Toute nouvelle plateforme reçoit les familles telles quelles (MSR-03). |

---

## 6. Les niveaux de composition

Six niveaux officiels. Toute réalisation d'interface vit à exactement un niveau.

| Niveau | Mission | Responsabilité | Peut contenir | Ne peut jamais contenir |
|---|---|---|---|---|
| **Primitive** | le matériau de base : un texte, une forme, une icône d'intention | être insécable et muet sur le métier | rien — c'est l'atome | un comportement ; un état métier |
| **Element** | le plus petit composant à intention : une action, un fait affiché | porter UNE intention d'UNE famille | des primitives | un autre element ; une composition |
| **Block** | une intention complète et autoportante : une carte d'intention, une saisie avec son cadre | assembler des elements au service d'une seule intention | des elements, des primitives | une navigation ; un autre block |
| **Section** | un temps de lecture d'une surface : un groupe d'intentions liées | ordonner des blocks selon les priorités publiées | des blocks | une action globale qui court-circuite ses blocks |
| **Surface** | une réponse complète à une question de l'expert (UX-02) | composer des sections en une lecture verticale unique | des sections, la navigation de la surface | une seconde question principale ; une autre surface |
| **Flow** | un parcours : plusieurs surfaces reliées par la navigation | enchaîner des surfaces selon un trajet officiel (Navigation Foundation) | des surfaces, des transitions | un raccourci hors navigation ; un état propre caché |

| Règle | Énoncé |
|---|---|
| CFL-01 | La composition monte toujours : primitive → element → block → section → surface → flow. Jamais l'inverse, jamais un saut qui cache un niveau. |
| CFL-02 | Chaque niveau ne connaît que le niveau immédiatement inférieur. |
| CFL-03 | L'intention se fixe au niveau element/block ; les niveaux supérieurs orchestrent des intentions, ils n'en créent pas de nouvelles. |
| CFL-04 | Une surface répond à une question, un flow à un parcours — jamais plus (UX-02, NV-01). |

---

## 7. Les relations entre composants

| Règle | Énoncé |
|---|---|
| CFE-01 | Les composants **coopèrent** : chacun apporte son intention à la phrase commune. |
| CFE-02 | Ils **ne se remplacent jamais** : une Information ne devient pas une Action sous prétexte de place. |
| CFE-03 | Ils **restent indépendants** : aucun composant ne dépend de l'état interne d'un autre. |
| CFE-04 | Ils **composent une intention. Jamais une implémentation** : la composition se pense en langage d'expérience, pas en arbre technique. |

---

## 8. Les états des composants

Huit états officiels, cohérents dans tout Mentora — alignés sur les états visuels du Design Language et les réponses de l'Interaction Foundation :

| État | Principe |
|---|---|
| **Disponible** | prêt à servir son intention. |
| **Indisponible** | existe mais ne répond pas — distinct du vide, sans alarme (IND-01, IND-04) ; fail closed. |
| **En attente** | le travail réel se voit (IW-02). |
| **En erreur** | locale, expliquée, travail préservé (IE). |
| **En succès** | discret, proportionné (IS-03). |
| **En attention** | signale sans crier ; attend son tour (Focus). |
| **En sélection** | le choisi se voit et se défait (moment Sélection). |
| **En focus** | l'élément qui reçoit l'interaction se distingue — un seul à la fois. |

| Règle | Énoncé |
|---|---|
| CFS-01 | Les états restent **cohérents dans tout Mentora** : le même état se reconnaît partout (DEV-01, PX-07). |
| CFS-02 | Aucun état ne dramatise, aucun état ne ment (DEV-02, DEV-03). |
| CFS-03 | Tout composant définit son comportement pour chacun des huit états — un état non défini est un état interdit. |

---

## 9. Les principes de réutilisation

| Règle | Énoncé |
|---|---|
| CFU-01 | **Un composant officiel est utilisé partout** : même intention, même composant, sur les cinq plateformes. |
| CFU-02 | **Il n'existe jamais deux composants pour la même intention.** |
| CFU-03 | **Une nouvelle intention crée une nouvelle famille** (par révision de ce document) — **jamais une variante cachée.** |
| CFU-04 | **Jamais un fork** : un besoin local enrichit le composant commun ou n'existe pas. |

---

## 10. Les principes de composition

| Règle | Énoncé |
|---|---|
| CFC-01 | **Un composant ne connaît jamais la logique métier.** |
| CFC-02 | **Un composant ne connaît jamais une plateforme.** |
| CFC-03 | **Un composant reste autonome** : il porte son intention avec ce qu'on lui donne, sans rien aller chercher. |
| CFC-04 | **La composition construit l'expérience. Pas le composant** : c'est l'assemblage — section, surface, flow — qui exprime le métier ; le composant reste un mot du dictionnaire. |

---

## 11. Les principes de confiance

| Règle | Les composants |
|---|---|
| CFT-01 | **restent honnêtes** — l'état affiché est l'état vrai. |
| CFT-02 | **ne cachent jamais l'information** (DT-01, DPV-04). |
| CFT-03 | **ne simulent jamais** (IF-05, IF-06). |
| CFT-04 | **ne manipulent jamais** — aucun dark pattern au niveau du composant non plus (DT-03). |
| CFT-05 | **respectent toujours les niveaux de protection** (§8 de l'Interaction Foundation). |
| CFT-06 | **respectent toujours l'Interaction Foundation, le Design Language Foundation et le Motion Foundation** — un composant est le point où les trois langages se rejoignent. |

Ces principes sont **perpétuels**.

---

## 12. Mobile First

| Règle | Énoncé |
|---|---|
| CFMF-01 | Les composants sont conçus d'abord pour **le mobile** : une seule main, cibles au pouce. |
| CFMF-02 | **Une seule responsabilité. Une seule intention** par composant — le petit écran l'exige doublement. |
| CFMF-03 | **Peu de bruit** : un composant qui décore est supprimé (DPV-03). |
| CFMF-04 | **Lecture immédiate** : chaque composant se comprend au premier regard (DPV-02). |
| CFMF-05 | **Desktop = adaptation. Jamais l'inverse** (MSMF-07) : les mêmes composants, disposés autrement — jamais des composants de plus. |

---

## 13. Gouvernance

| Règle | Énoncé |
|---|---|
| CFG-01 | Toute nouvelle famille appartient à cette fondation (révision documentaire). |
| CFG-02 | Tout nouveau composant appartient à une famille (§3). |
| CFG-03 | Toute nouvelle composition respecte les niveaux (§6). |
| CFG-04 | **Aucun composant isolé. Aucun composant orphelin. Aucun composant spécifique à une plateforme** (CFR-01). |
| CFG-05 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 14. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Flutter, Web, Desktop, nouveaux frameworks | des implémentations du même langage — les familles ne bougent pas (CFN-07 : le langage ignore le framework) |
| Tablettes, TV | les mêmes composants, dispositions adaptées (Responsive Foundation) |
| Wearables | le sous-ensemble essentiel : Information, Attention, Confirmation — rien d'autre n'y a de place |
| Voice | les familles ont une voix : dire un fait (Information), demander un accord (Confirmation), signaler (Attention) — mêmes intentions, autre modalité |
| Réalité mixte | les mêmes familles dans l'espace ; l'Immersion y retrouve ses règles de porte et de sortie |
| Nouveaux paradigmes | de nouvelles réalisations des familles existantes ; une nouvelle famille exige la révision de ce document |

| Règle | Énoncé |
|---|---|
| CFX-01 | Les dix familles (§3), les six niveaux (§6) et les huit états (§8) sont l'invariant décennal. |
| CFX-02 | **Les familles restent identiques. Les implémentations évolueront. Jamais le langage.** |
| CFX-03 | Aucune extension ne peut affaiblir la réutilisation (CFU) ni la confiance (CFT). |

---

## 15. Gouvernance du document

- Ce document est la **référence officielle** du langage des composants de Mentora. Il réalise le pilier **Components** du MES.
- Toute vague d'implémentation cite la famille, le niveau, l'état et les règles (CFV/CFP/CFN/CFR/CFL/CFE/CFS/CFU/CFC/CFT/CFMF/CFG/CFX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis les fondations [Navigation](navigation-foundation.md), [Interaction](interaction-foundation.md), [Design Language](design-language-foundation.md) et [Motion](motion-foundation.md), puis ce document (MSD-01).
