# INTERACTION FOUNDATION

**Statut** : Référence officielle de toutes les interactions de Mentora.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun composant, aucun code, aucune implémentation, aucune bibliothèque, aucun pseudo-code, aucune maquette. Cette fondation ne décrit ni des boutons, ni des animations, ni un framework — elle décrit **la manière dont Mentora répond aux actions de l'expert**.
**Filiation** : deuxième descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) — elle réalise officiellement les piliers **Interaction** et **Feedback** (MSD-01 : elle précise, ne redéfinit pas). Elle respecte la [NAVIGATION FOUNDATION](navigation-foundation.md) et P9.0 qui prévaut en cas de conflit. Elle servira de fondation aux documents Motion, Component, Accessibility et Responsive.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par ses interactions de reprise (§3.7), ses attentes interruptibles (§9), ses erreurs qui préservent le travail (§10) et ses interruptions qui figent sans détruire (§12).

---

## 1. Mission

**Mission en une phrase** : définir la manière dont Mentora répond aux actions de l'utilisateur — quand répondre, comment répondre, quand protéger, quand se taire — et rien d'autre.

Elle ne possède jamais : les plateformes métier, les données, les providers, les moteurs, les composants, la logique métier, les plateformes système.

---

## 2. Vision

Chaque action de l'expert mérite une réponse compréhensible du système.

| Règle | Énoncé |
|---|---|
| IV-01 | Le système **ne reste jamais silencieux** face à un acte. |
| IV-02 | Le système **ne surprend jamais** (PX-04). |
| IV-03 | Le système **ne dramatise jamais** : ni une erreur, ni un succès, ni une attente. |
| IV-04 | Le système **accompagne** ; il n'interrompt jamais inutilement (pilier Focus). |

---

## 3. Les types d'interaction

Dix types officiels. Toute interaction dans Mentora appartient à exactement un type.

### 3.1 Direct Interaction

| | |
|---|---|
| **Mission** | Le geste simple à effet immédiat : toucher, ouvrir, écarter, faire défiler. |
| **Responsabilités** | Répondre instantanément et visiblement ; l'effet est celui que le geste annonce. |
| **Frontières** | Réservée aux actions libres (§8) ; dès qu'un acte engage, un autre type prend la main. |
| **Ce qu'elle permet** | la fluidité du quotidien : la plupart des gestes sont directs. |
| **Ce qu'elle ne doit jamais faire** | déclencher un effet caché ou différé sans le dire ; exiger une précision de geste excessive. |

### 3.2 Guided Interaction

| | |
|---|---|
| **Mission** | Conduire pas à pas un acte en plusieurs temps (préparation, mise en place, réponse structurée). |
| **Responsabilités** | Montrer où l'on en est, ce qui reste, comment sortir ; conserver chaque pas accompli. |
| **Frontières** | Le guidage structure l'acte ; il ne décide jamais du contenu (la plateforme publie les étapes). |
| **Ce qu'elle permet** | accomplir sans se perdre ; reprendre au pas exact après interruption. |
| **Ce qu'elle ne doit jamais faire** | enfermer (PX-05) ; perdre un pas accompli ; transformer trois gestes en dix. |

### 3.3 Protected Interaction

| | |
|---|---|
| **Mission** | Encadrer les actes qui engagent (argent, réputation, enregistrement, environnement). |
| **Responsabilités** | Appliquer le niveau de protection publié (§8) : distance de sécurité, consentement, réversibilité dite. |
| **Frontières** | Le niveau de protection découle de la nature de l'acte publiée par sa plateforme — jamais d'un choix d'interface. |
| **Ce qu'elle permet** | agir sur l'important sans peur, parce que le système protège. |
| **Ce qu'elle ne doit jamais faire** | protéger l'anodin (fatigue) ; laisser passer l'irréversible sans consentement (UX-06). |

### 3.4 Confirmation Interaction

| | |
|---|---|
| **Mission** | Obtenir un accord explicite au moment exact où l'acte bascule. |
| **Responsabilités** | Dire exactement ce qui va se passer, son caractère réversible ou non, et attendre l'accord (Modal Navigation). |
| **Frontières** | Une confirmation est un instant, pas un parcours ; elle n'ajoute jamais une deuxième validation inutile (IMF-05). |
| **Ce qu'elle permet** | l'irréversible en confiance. |
| **Ce qu'elle ne doit jamais faire** | presser ; culpabiliser le renoncement ; se déclencher deux fois pour le même acte. |

### 3.5 Feedback Interaction

| | |
|---|---|
| **Mission** | La réponse du système à tout acte : reçu, en cours, fait, impossible. |
| **Responsabilités** | Accuser chaque geste ; refléter l'état vrai (fail closed) ; distinguer l'accusé (immédiat) du résultat (quand il arrive). |
| **Frontières** | Le feedback dit ce qui s'est passé ; il n'enjolive ni n'invente (IF-05, IF-06). |
| **Ce qu'elle permet** | la confiance : chaque geste compte, et ça se voit. |
| **Ce qu'elle ne doit jamais faire** | simuler ; répondre à la place du mécanisme ; noyer l'important sous les accusés. |

### 3.6 Waiting Interaction

| | |
|---|---|
| **Mission** | Rendre l'attente honnête et vivable (§9). |
| **Responsabilités** | Annoncer qu'un travail est en cours, sa nature, sa durée si elle est connue ; permettre de faire autre chose quand c'est possible. |
| **Frontières** | L'attente reflète le travail réel ; jamais d'attente décorative, jamais de progression inventée. |
| **Ce qu'elle permet** | patienter en confiance, ou vaquer et revenir. |
| **Ce qu'elle ne doit jamais faire** | bloquer sans nécessité ; afficher une progression fausse ; laisser une attente sans issue (§9). |

### 3.7 Recovery Interaction

| | |
|---|---|
| **Mission** | Reprendre un acte interrompu — au pas exact, avec son contexte. |
| **Responsabilités** | Proposer la reprise (jamais l'imposer), restituer le travail conservé, dire ce qui a changé entretemps (NCO-03). |
| **Frontières** | S'appuie sur la Recovery Navigation ; ne rejoue jamais un acte, ne restaure jamais un état périmé comme actuel. |
| **Ce qu'elle permet** | ne jamais recommencer inutilement (NCO-01). |
| **Ce qu'elle ne doit jamais faire** | reprendre dans un contexte devenu invalide ; écraser ce qui a changé pendant l'absence. |

### 3.8 Error Interaction

| | |
|---|---|
| **Mission** | Répondre à l'échec — expliquer, préserver, proposer une suite (§10). |
| **Responsabilités** | Dire ce qui n'a pas marché en langage d'expert (UX-10), conserver le travail, proposer l'action utile. |
| **Frontières** | L'erreur reste locale dès que possible (IND-03) ; sa cause appartient au mécanisme, sa réponse à cette fondation. |
| **Ce qu'elle permet** | échouer sans dégât et repartir. |
| **Ce qu'elle ne doit jamais faire** | culpabiliser ; détruire des données ; dramatiser ; exposer un vocabulaire technique. |

### 3.9 Success Interaction

| | |
|---|---|
| **Mission** | Confirmer la réussite — sobrement (§11). |
| **Responsabilités** | Dire que c'est fait, montrer l'effet, ouvrir la suite naturelle. |
| **Frontières** | La reconnaissance des grands moments (objectif atteint) appartient aux plateformes qui les publient ; le succès d'interaction reste discret. |
| **Ce qu'elle permet** | continuer sans friction. |
| **Ce qu'elle ne doit jamais faire** | célébrer l'ordinaire ; interrompre le flux pour applaudir ; retarder la suite. |

### 3.10 Continuous Interaction

| | |
|---|---|
| **Mission** | Accompagner les actes qui durent : la consultation en cours, un enregistrement, une saisie longue. |
| **Responsabilités** | Maintenir un état discret et vrai (le REC discret, la séance en cours), garantir le geste de sortie propre, protéger l'acte des interruptions (NI-02). |
| **Frontières** | L'acte appartient à sa plateforme ; l'interaction maintient la conscience de l'état sans distraire (pilier Focus). |
| **Ce qu'elle permet** | exercer longuement en confiance. |
| **Ce qu'elle ne doit jamais faire** | distraire pendant l'acte ; masquer qu'un état continu est actif ; rendre la sortie ambiguë. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | L'Interaction Foundation PEUT |
|---|---|
| IP-01 | Définir les réponses du système. |
| IP-02 | Définir les confirmations. |
| IP-03 | Définir les attentes. |
| IP-04 | Définir les validations. |
| IP-05 | Définir les interruptions. |
| IP-06 | Définir les retours. |
| IP-07 | Définir les protections. |
| IP-08 | Définir les comportements utilisateur attendus. |

### 4.2 Interdites

| Règle | L'Interaction Foundation NE PEUT JAMAIS |
|---|---|
| IN-01 | Décider. |
| IN-02 | Calculer. |
| IN-03 | Posséder les plateformes métier. |
| IN-04 | Posséder les données. |
| IN-05 | Posséder les providers. |
| IN-06 | Posséder les moteurs. |
| IN-07 | Posséder la logique métier. |
| IN-08 | Remplacer le MES — elle précise ses piliers Interaction et Feedback, rien de plus. |

---

## 5. Relation avec les plateformes

Chaque plateforme **publie des intentions**. L'Interaction Foundation définit uniquement **comment le système répond**. Jamais ce qu'il décide.

| Plateforme | Intentions publiées | Réponse d'interaction |
|---|---|---|
| Home | ouvrir une remontée, écarter une carte | Direct ; l'écart respecté (DIS-03) |
| Consultation | avancer dans le cycle, entrer en salle, clore | Guided pour la préparation ; Protected pour l'entrée ; Continuous pendant l'acte ; Confirmation pour la clôture |
| Business | consulter, ajuster un objectif, retirer | Direct pour lire ; Protected + Confirmation pour l'argent (jamais irréversible en un geste) |
| AI | accueillir ou écarter une proposition | Direct dans les deux sens — accepter et refuser coûtent le même geste (AE-03) |
| Reputation | répondre à un avis, compléter le profil | Guided pour la réponse ; le travail préservé à chaque pas |
| Account | vérifier un appareil, renforcer la sécurité, régler | Protected pour la sécurité ; Direct pour les réglages réversibles (PE-07) |

| Règle | Énoncé |
|---|---|
| IR-01 | La nature d'un acte (libre, important, sensible, irréversible, critique) est **publiée par sa plateforme** ; l'interaction applique la protection correspondante (§8), jamais l'inverse. |
| IR-02 | Aucune réponse d'interaction ne modifie une donnée : elle transmet l'intention au propriétaire et reflète son résultat. |
| IR-03 | Les réponses sont identiques pour une même nature d'acte, quelle que soit la plateforme (PX-07). |

---

## 6. Les moments d'interaction

| Moment | Mission |
|---|---|
| **Découverte** | laisser explorer sans risque : tout geste de découverte est sans conséquence et réversible. |
| **Sélection** | rendre le choix clair : ce qui est sélectionné se voit, se change, se défait. |
| **Validation** | recueillir l'accord au bon niveau de protection (§8) — ni plus, ni moins. |
| **Modification** | montrer ce qui change, conserver ce qui était, permettre de revenir. |
| **Annulation** | rendre le renoncement simple et sans reproche ; ce qui est annulé est dit. |
| **Attente** | tenir l'utilisateur informé du travail en cours (§9). |
| **Succès** | confirmer sobrement et ouvrir la suite (§11). |
| **Erreur** | expliquer, préserver, proposer (§10). |
| **Reprise** | restituer l'acte interrompu au pas exact (§3.7). |
| **Fin** | clore proprement : l'acte terminé le dit, et la suite naturelle s'offre (Navigation terminée). |

| Règle | Énoncé |
|---|---|
| IM-01 | Chaque moment a une réponse définie ; aucun moment ne laisse l'utilisateur sans réponse (IV-01). |
| IM-02 | Tout nouveau moment s'ajoute par révision de ce document. |

---

## 7. Les retours du système

| Règle | Énoncé |
|---|---|
| IRS-01 | **Quand répondre** : à chaque acte, immédiatement — l'accusé d'abord, le résultat quand il arrive. |
| IRS-02 | **Comment répondre** : dans le langage de l'expert (UX-10), au bon endroit (près de l'acte), à la bonne intensité (proportionnée à l'enjeu). |
| IRS-03 | **Quand rester silencieux** : jamais face à un acte ; silencieux seulement quand rien n'a été demandé — le système ne parle pas pour meubler (EV-04). |
| IRS-04 | **Quand rassurer** : pendant l'attente, après une interruption, autour d'un acte protégé. |
| IRS-05 | **Quand expliquer** : à chaque erreur, à chaque empêchement (fail closed expliqué), à chaque changement survenu pendant l'absence. |
| IRS-06 | **Quand demander confirmation** : aux niveaux sensible et au-delà (§8) — jamais en dessous. |
| IRS-07 | **Quand accompagner** : sur les actes en plusieurs temps (Guided) et les actes qui durent (Continuous). |
| IRS-08 | Le système répond toujours avec **honnêteté**. Jamais avec dramatisation (IV-03). |

---

## 8. Les niveaux de protection

Cinq niveaux officiels. Le niveau d'un acte est **publié par sa plateforme** (IR-01).

| Niveau | Définition | Réponse exigée |
|---|---|---|
| **Action libre** | sans conséquence ou trivialement réversible (lire, ouvrir, écarter) | Direct — aucune friction |
| **Action importante** | engage un contenu ou un tiers, réversible (répondre à un avis, ajuster un objectif) | l'acte se voit avant de partir ; l'annulation reste simple |
| **Action sensible** | touche l'argent, la réputation publique, l'environnement de sécurité — réversible avec coût | Confirmation explicite : quoi, effet, réversibilité dite |
| **Action irréversible** | ne se défait pas (clôture définitive, suppression, consentement d'enregistrement) | Consentement explicite (UX-06) ; jamais en un geste ; le caractère définitif est dit avant |
| **Action critique** | irréversible + portée de sécurité ou légale (refus d'enregistrement — définitif ; déconnexion d'appareil inconnu) | Consentement explicite + distance de sécurité ; jamais interrompue une fois engagée (NB-03) |

| Règle | Énoncé |
|---|---|
| IPR-01 | **Quand protéger** : dès le niveau sensible. En dessous, la protection est une nuisance (IMF-04). |
| IPR-02 | **Quand confirmer** : sensible et au-delà — une fois, jamais deux (IMF-05). |
| IPR-03 | **Quand ne jamais interrompre** : un acte critique engagé va à son terme (hors urgence de sécurité supérieure). |
| IPR-04 | **Quand exiger un consentement explicite** : irréversible et critique — le consentement dit exactement ce qui est consenti (double accord d'enregistrement : chacun consent, aucun ne présume de l'autre). |
| IPR-05 | Un niveau ne se déclasse jamais pour la commodité ; il ne se surclasse jamais pour le spectacle. |

---

## 9. Les attentes

Le système **ne laisse jamais l'utilisateur dans l'incertitude**.

| Attente | Comportement officiel |
|---|---|
| **Attente courte** | l'accusé suffit ; le résultat suit dans le même souffle — aucune mise en scène. |
| **Attente moyenne** | le travail s'annonce (quoi) ; l'utilisateur voit que ça avance. |
| **Attente longue** | le travail s'annonce avec sa nature et, si connue, sa durée ; l'utilisateur peut vaquer — le résultat le retrouvera (Deep/Recovery). |
| **Attente inconnue** | l'honnêteté d'abord : durée inconnue se dit inconnue ; jamais une progression inventée ; une issue existe toujours (annuler, revenir). |
| **Traitement terminé** | le résultat rejoint l'utilisateur où il est, sans le brusquer (Focus) ; s'il a vaqué, la remontée le lui dit. |
| **Traitement interrompu** | l'interruption se dit, le travail conservé se dit, la reprise se propose (§3.7). |

| Règle | Énoncé |
|---|---|
| IW-01 | Toute attente a une issue : jamais d'attente-prison (PX-05). |
| IW-02 | La progression affichée reflète le travail réel — jamais décorative (fail closed). |
| IW-03 | Une attente n'empêche que ce qu'elle doit : le reste du système reste vivant (IND-03). |

---

## 10. Les erreurs

| Règle | Une erreur |
|---|---|
| IE-01 | **explique** : ce qui n'a pas marché, en langage d'expert. |
| IE-02 | **ne culpabilise jamais** : le système échoue, l'utilisateur n'a pas « mal fait ». |
| IE-03 | **propose une suite** : réessayer, autrement, ou plus tard — toujours une action utile. |
| IE-04 | **respecte le contexte** : elle apparaît près de l'acte, à l'intensité de l'enjeu. |
| IE-05 | **préserve le travail** : la saisie, la sélection, le pas accompli survivent à l'échec. |
| IE-06 | **ne détruit jamais les données.** |
| IE-07 | **reste locale dès que possible** : un domaine en échec ne condamne pas la surface (IND-03). |
| IE-08 | **Fail closed** : en cas de doute sur l'issue d'un acte, le système présente l'état non fait — jamais un succès supposé. |

---

## 11. Les succès

| Règle | Un succès |
|---|---|
| IS-01 | **confirme** : c'est fait, et l'effet se voit. |
| IS-02 | **rassure** : sur l'important, il redit l'essentiel (montant parti, consentement pris). |
| IS-03 | **reste discret** : proportionné à l'acte. |
| IS-04 | **ne célèbre jamais inutilement** : les grands moments appartiennent aux plateformes (objectif atteint — Business) ; l'interaction ne fabrique pas de fête. |
| IS-05 | **permet naturellement de continuer** : la suite s'offre, le flux ne s'arrête pas. |

---

## 12. Les interruptions

Une interruption **ne détruit jamais le contexte** (NI-01, appliqué à l'acte en cours).

| Interruption | Comportement d'interaction |
|---|---|
| **Notification** | n'interrompt jamais un acte ; attend son tour (Focus). |
| **Appel** | l'acte se fige au pas exact ; la reprise restitue tout (§3.7). |
| **Consultation** | l'imminence prend la main ; l'acte en cours se fige proprement ; la reprise attend après. |
| **Authentification** | l'acte attend derrière, intact ; rien ne se rejoue. |
| **Maintenance** | annoncée ; aucun acte protégé ne démarre si la maintenance ne peut le laisser finir. |
| **Perte réseau** | l'acte local continue quand il peut ; ce qui exige le réseau se fige honnêtement (MF-08) ; rien ne se perd. |
| **Mise à jour** | jamais pendant un acte ; proposée aux moments calmes. |
| **Reprise** | Recovery Interaction : le pas exact, le contexte dit, ce qui a changé signalé. |

| Règle | Énoncé |
|---|---|
| II-01 | Un acte critique engagé n'est interrompu par rien, hors urgence de sécurité supérieure (IPR-03). |
| II-02 | Toute interruption qui fige un acte le dit — l'utilisateur sait que son travail attend. |

---

## 13. Les principes de feedback

| Règle | Le système |
|---|---|
| IF-01 | **répond toujours.** |
| IF-02 | **répond rapidement** : l'accusé est immédiat, même quand le résultat prend du temps. |
| IF-03 | **répond honnêtement.** |
| IF-04 | **ne cache jamais une incertitude** (AE-05 appliqué à toute réponse). |
| IF-05 | **n'invente jamais un état.** |
| IF-06 | **ne simule jamais une réussite. Ne simule jamais un échec.** |
| IF-07 | **respecte toujours le contexte** : la réponse arrive où l'acte a eu lieu, à l'intensité de l'enjeu. |
| IF-08 | Ces principes sont **perpétuels** : aucun descendant ni aucune extension ne peut les affaiblir. |

---

## 14. Mobile First

| Règle | Énoncé |
|---|---|
| IMF-01 | Les interactions sont pensées pour **le pouce** : une seule main (MF-02). |
| IMF-02 | Une seule action principale par surface (MF-07). |
| IMF-03 | Les cibles des actes importants vivent dans la zone du pouce ; jamais un acte critique en bord d'écran haut. |
| IMF-04 | **Peu de confirmations** : la protection au bon niveau, jamais au-dessus (IPR-01) — jamais de fatigue. |
| IMF-05 | **Jamais de double validation inutile** : un acte, une confirmation au plus. |
| IMF-06 | **Desktop = adaptation. Jamais l'inverse** (MSMF-07). |

---

## 15. Gouvernance

| Règle | Énoncé |
|---|---|
| IG-01 | Toute nouvelle interaction appartient à un type officiel (§3) ; sinon, c'est ce document qu'on révise. |
| IG-02 | Tout nouveau feedback appartient à cette fondation (§7, §13). |
| IG-03 | Toute nouvelle confirmation appartient à cette fondation (§8). |
| IG-04 | **Aucune interaction parallèle.** Aucun comportement différent selon les équipes : une seule interaction Mentora (PX-07). |
| IG-05 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 16. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Voice interaction | les mêmes types et niveaux de protection, dits au lieu d'être touchés ; un consentement vocal reste un consentement explicite (IPR-04) |
| Assistants IA | leurs propositions passent par les types existants — accueillir/écarter en Direct, agir en Protected ; jamais d'acte autonome (AE-08) |
| Wearables | l'essentiel : accusés brefs, actes libres seulement ; le sensible et au-delà renvoient à un appareil complet |
| TV, automobile | des modalités adaptées (distance, attention partagée) ; l'automobile n'accueille jamais un acte au-delà d'important |
| Réalité mixte | de nouveaux gestes pour les mêmes types ; les niveaux de protection demeurent |
| Nouveaux périphériques, nouveaux gestes | de nouvelles entrées vers les types existants (§3) |
| Nouveaux paradigmes | de nouvelles modalités dans les types existants ; un nouveau type exige la révision de ce document |

| Règle | Énoncé |
|---|---|
| IX-01 | Les dix types (§3) et les cinq niveaux de protection (§8) sont l'invariant décennal. |
| IX-02 | Les principes de feedback (IF) et les règles d'erreur (IE) valent sur toute modalité, présente ou future. |
| IX-03 | Aucune extension ne peut affaiblir une protection ni ajouter une friction sans enjeu. |

---

## 17. Gouvernance du document

- Ce document est la **référence officielle** de toutes les interactions de Mentora. Il réalise les piliers **Interaction** et **Feedback** du MES.
- Toute vague d'implémentation cite le type, le moment, le niveau de protection et les règles (IV/IP/IN/IR/IM/IRS/IPR/IW/IE/IS/II/IF/IMF/IG/IX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis la [NAVIGATION FOUNDATION](navigation-foundation.md), puis ce document (MSD-01).
