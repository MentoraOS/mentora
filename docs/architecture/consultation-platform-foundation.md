# CONSULTATION PLATFORM FOUNDATION

**Statut** : Référence officielle — aucun développement futur concernant une consultation ne sera réalisé en dehors de cette architecture.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun pixel, aucune maquette, aucun code, aucun pseudo-code, aucune logique métier, aucun provider, aucune persistance.
**Filiation** : ce document réalise la « Consultation Platform » du §3.2 de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) et alimente le Home défini par [HOME PLATFORM FOUNDATION](home-platform-foundation.md). En cas de conflit, P9.0 prévaut.

---

## 1. Mission

La Consultation Platform n'est **pas un calendrier**. Elle n'est **pas une liste de rendez-vous**.

Elle est le **cœur opérationnel de Mentora** : elle pilote **tout le cycle de vie d'une consultation**, de la découverte à la fidélisation.

**Mission en une phrase** : organiser le cycle de vie de chaque consultation, publier ses états, et conduire l'expert d'une étape à la suivante — sans jamais posséder ce qui appartient à une autre plateforme.

La plateforme est organisée autour du **cycle de vie** et des **moments** vécus par l'expert. Jamais autour de pages, jamais autour de menus, jamais autour de composants techniques.

Le Home ne possède jamais les consultations : il reçoit uniquement les remontées publiées par cette plateforme (§7).

---

## 2. Le cycle de vie officiel

```
Découverte → Réservation → Préparation → Entrée en consultation
→ Consultation Live → Fin de consultation → Résumé → Suivi → Fidélisation
```

Règles du cycle :

| Règle | Énoncé |
|---|---|
| CY-01 | Toute consultation vit exactement dans une étape à la fois. L'étape courante est un fait publié, jamais une déduction d'interface. |
| CY-02 | Les transitions suivent l'ordre du cycle ; une étape ne se saute jamais silencieusement (une consultation annulée ou manquée sort du cycle par un état terminal explicite, elle ne « disparaît » pas). |
| CY-03 | Chaque étape a un propriétaire d'expérience unique : la Consultation Platform. Les mécanismes qu'elle mobilise appartiennent aux plateformes système (§4) — jamais l'inverse. |
| CY-04 | Fail closed : une étape dont les conditions ne sont pas prouvées ne s'ouvre pas (cohérent avec la Readiness Platform). |
| CY-05 | Les sorties d'une étape sont les seules entrées possibles de la suivante. Aucune donnée n'apparaît en cours de cycle sans provenance. |

### 2.1 Découverte

| | |
|---|---|
| **Mission** | Rendre l'expert trouvable et pertinent pour le bon client. |
| **Responsabilités** | Représenter la visibilité de l'expert dans le parcours client ; refléter la mise en relation. |
| **Frontières** | Le profil public appartient à la Reputation Platform ; la pertinence et la mise en relation appartiennent aux systèmes Search et Recommandation (via l'AI Platform pour l'expérience). La Découverte reflète, elle ne classe pas. |
| **Propriétaire** | Consultation Platform (expérience) ; Search / Recommandation (mécanisme). |
| **Entrées** | Un besoin client exprimé hors de la plateforme Expert. |
| **Sorties** | Une intention de réservation qualifiée. |

### 2.2 Réservation

| | |
|---|---|
| **Mission** | Transformer une intention en engagement ferme et honnête entre le client et l'expert. |
| **Responsabilités** | Représenter la demande, l'acceptation, le créneau retenu et les conditions ; refléter le statut de l'engagement. |
| **Frontières** | Le mécanisme de réservation appartient au système Booking (source de vérité de l'engagement) ; l'encaissement appartient au système Payment et sa lecture financière à la Business Platform. La Réservation n'affiche jamais un engagement non confirmé comme confirmé. |
| **Propriétaire** | Consultation Platform (expérience) ; Booking (mécanisme). |
| **Entrées** | L'intention issue de la Découverte ; les disponibilités publiées par l'expert. |
| **Sorties** | Une consultation planifiée, datée, engagée. |

### 2.3 Préparation

| | |
|---|---|
| **Mission** | Garantir que tout est prouvé prêt avant l'entrée — réseau, permissions, caméra, microphone, IA, enregistrement. |
| **Responsabilités** | Conduire l'expert à travers la préparation ; représenter l'état de préparation ; exiger la preuve avant l'entrée. |
| **Frontières** | Les vérifications appartiennent à la Readiness Platform (moteur, checkers, fail closed : rien n'est prêt tant que ce n'est pas prouvé). La Préparation ne vérifie rien elle-même. |
| **Propriétaire** | Consultation Platform (expérience) ; Readiness Platform (mécanisme). |
| **Entrées** | Une consultation planifiée dont l'échéance approche. |
| **Sorties** | Une préparation prouvée — ou un empêchement explicite, jamais silencieux. |

### 2.4 Entrée en consultation

| | |
|---|---|
| **Mission** | Faire franchir la porte de la Salle Live au bon moment, dans de bonnes conditions. |
| **Responsabilités** | Représenter l'imminence ; ouvrir la porte quand la préparation est prouvée ; publier l'imminence vers le Home. |
| **Frontières** | La Salle est assemblée par les plateformes Session et Experience ; le consentement d'enregistrement appartient à la Recording Platform (double accord, refus définitif). L'Entrée conduit, elle n'assemble pas. |
| **Propriétaire** | Consultation Platform (expérience) ; Session / Experience / Recording (mécanismes). |
| **Entrées** | Une préparation prouvée ; l'heure venue. |
| **Sorties** | L'expert dans la Salle Live. |

### 2.5 Consultation Live

| | |
|---|---|
| **Mission** | Laisser l'expert exercer, assisté sans être distrait. |
| **Responsabilités** | Représenter l'état « en cours » ; publier ce fait vers le Home ; garantir la sortie propre. |
| **Frontières** | Tout le Live appartient aux plateformes système : Session (orchestration IA de séance), Experience (surfaces visuelles), Recording (enregistrement consenti), Translation (sous-titres), Assistant (aide), Action Items (relevés). La Salle Live est **plein écran hors navigation** (NAV-05 de P9.0) ; la Consultation Platform n'y implémente rien. |
| **Propriétaire** | Plateformes système (mécanismes) ; Consultation Platform (continuité de l'expérience avant/après). |
| **Entrées** | L'entrée franchie. |
| **Sorties** | Une consultation terminée, proprement close. |

### 2.6 Fin de consultation

| | |
|---|---|
| **Mission** | Clore proprement : rien ne se perd, rien ne reste ouvert. |
| **Responsabilités** | Représenter la clôture ; déclencher la bascule vers l'après (résumé, suites) ; publier la fin. |
| **Frontières** | L'arrêt ordonné des services de séance appartient à la Session Platform (ordre inverse, résumé toujours en dernier). La lecture financière de la consultation appartient à la Business Platform. |
| **Propriétaire** | Consultation Platform (expérience) ; Session Platform (mécanisme d'arrêt). |
| **Entrées** | La sortie de la Salle Live. |
| **Sorties** | Une consultation close, en attente de son résumé. |

### 2.7 Résumé

| | |
|---|---|
| **Mission** | Restituer à l'expert l'essentiel de la consultation, prêt à valider. |
| **Responsabilités** | Représenter la disponibilité du résumé ; conduire à sa lecture et sa validation ; publier « résumé disponible ». |
| **Frontières** | La production du résumé appartient à la Summary Platform (via l'AI Gateway) ; l'expérience de l'IA appartient à l'AI Platform. Le Résumé de la Consultation Platform présente, il ne génère pas. |
| **Propriétaire** | Consultation Platform (expérience) ; Summary / AI Gateway (mécanismes). |
| **Entrées** | Une consultation close. |
| **Sorties** | Un résumé validé — et les actions relevées transmises au Suivi. |

### 2.8 Suivi

| | |
|---|---|
| **Mission** | Transformer la consultation en continuité de soin ou de conseil — rien ne tombe dans l'oubli. |
| **Responsabilités** | Représenter les suites à donner (actions, engagements, prochaine échéance) ; conduire leur traitement ; publier « suivi à effectuer ». |
| **Frontières** | Les relevés d'actions appartiennent à l'Action Items Platform ; les échanges avec le client appartiennent à l'Account Platform (messages) ; une nouvelle consultation repart par la Réservation. |
| **Propriétaire** | Consultation Platform (expérience) ; Action Items (mécanisme). |
| **Entrées** | Le résumé validé et ses actions. |
| **Sorties** | Des suites traitées — ou une nouvelle consultation engagée. |

### 2.9 Fidélisation

| | |
|---|---|
| **Mission** | Faire d'un client servi un client qui revient. |
| **Responsabilités** | Représenter la relation dans la durée (historique, récurrence) ; conduire vers la reprise de rendez-vous. |
| **Frontières** | Les leviers de fidélisation recommandés appartiennent à l'AI Platform ; la réputation qui en résulte appartient à la Reputation Platform ; la valeur financière appartient à la Business Platform. |
| **Propriétaire** | Consultation Platform (expérience). |
| **Entrées** | Un suivi accompli. |
| **Sorties** | Une nouvelle Découverte ou Réservation — le cycle recommence. |

---

## 3. Responsabilités

### 3.1 Autorisées

| Règle | La Consultation Platform PEUT |
|---|---|
| CP-01 | Organiser le cycle de vie (§2) et en garantir les transitions. |
| CP-02 | Publier les états d'une consultation (étape courante, imminence, préparation, en cours, close, résumé disponible, suivi en attente). |
| CP-03 | Exposer au Home les informations du §7 — et uniquement celles-là. |
| CP-04 | Conduire l'expert d'une étape à la suivante, en un geste par transition. |
| CP-05 | Représenter la progression d'une consultation dans son cycle. |

### 3.2 Interdites

| Règle | La Consultation Platform NE PEUT JAMAIS |
|---|---|
| CN-01 | Calculer les revenus — la vérité financière appartient à la Business Platform. |
| CN-02 | Posséder les paiements — mécanisme Payment, lecture Business. |
| CN-03 | Posséder les recommandations IA — AI Platform. |
| CN-04 | Posséder la réputation — Reputation Platform. |
| CN-05 | Posséder les paramètres — Account Platform. |
| CN-06 | Posséder les messages — Account Platform. |
| CN-07 | Décider — elle organise et conduit ; les décisions restent à l'expert, les mécanismes aux plateformes système. |
| CN-08 | Reformuler — toute information est citée telle que publiée par sa source de vérité. |
| CN-09 | Posséder les plateformes système — elle les orchestre dans l'expérience métier, jamais dans leur logique. |

---

## 4. Dialogue avec les plateformes système

Les plateformes système déjà construites **restent propriétaires de leur logique**. La Consultation Platform ne fait que les orchestrer dans l'expérience métier — elles restent **invisibles pour l'utilisateur** (FR-06 de P9.0).

| Plateforme système | Ce qu'elle possède | Où la Consultation Platform la mobilise |
|---|---|---|
| Consultation Session Platform | l'assemblage et l'orchestration de séance (démarrage ordonné, arrêt inverse, résumé toujours dernier) | Entrée, Live, Fin |
| Consultation Experience Platform | les surfaces visuelles de la Salle | Entrée, Live |
| Readiness Platform | la preuve de préparation (moteur + checkers, fail closed) | Préparation, Entrée |
| Recording Platform | le consentement double et l'enregistrement | Entrée, Live |
| Summary Platform | la production du résumé | Résumé |
| Translation Platform | les sous-titres et la traduction | Live |
| Assistant Platform | l'aide en séance | Live |
| Action Items Platform | les relevés d'actions | Live, Suivi |
| AI Gateway | l'accès unique aux capacités IA | jamais directement — toujours à travers les plateformes ci-dessus |

| Règle | Énoncé |
|---|---|
| SY-01 | La Consultation Platform ne parle jamais à l'AI Gateway, à un provider, à un adapter ou à un vendor. Elle mobilise des plateformes, jamais des mécanismes. |
| SY-02 | Aucun nom technique de plateforme système n'apparaît dans l'expérience (UX-10 de P9.0) : l'expert vit une consultation, pas une architecture. |
| SY-03 | Une capacité système indisponible dégrade localement l'étape concernée (fail closed, explicite) — jamais le cycle entier. |
| SY-04 | Toute nouvelle plateforme système s'intègre par une étape existante du cycle ; si aucune étape ne convient, c'est ce document qu'on révise. |

---

## 5. Les moments d'une consultation

L'expérience est organisée autour des **moments vécus par l'expert** — jamais autour d'une navigation technique.

| Moment | Ce que vit l'expert | Étape(s) du cycle |
|---|---|---|
| **Consultation imminente** | « Ça commence bientôt » — l'échéance domine tout | Préparation → Entrée |
| **Préparation** | « Suis-je prêt ? » — la preuve s'établit, ce qui manque est explicite | Préparation |
| **Salle ouverte** | « Je peux entrer » — la porte est là, un geste suffit | Entrée |
| **Consultation en cours** | « J'exerce » — plein écran, zéro distraction | Live |
| **Consultation terminée** | « C'est clos » — la bascule vers l'après est immédiate et sereine | Fin |
| **Résumé disponible** | « L'essentiel m'attend » — lire, corriger, valider | Résumé |
| **Suivi en attente** | « Il me reste à faire » — les suites sont nommées, datées, actionnables | Suivi |
| **Client fidélisé** | « Il revient » — la relation continue, le cycle recommence | Fidélisation |

| Règle | Énoncé |
|---|---|
| MC-01 | Un seul moment actif par consultation ; le moment découle de l'étape publiée (CY-01), jamais d'un état d'interface. |
| MC-02 | Le moment détermine ce qui remonte en tête et l'action principale unique (MF-07 de P9.0). |
| MC-03 | Les moments alimentent les Moments du Home (§11 de la Home Foundation) : c'est cette plateforme qui publie « entre deux consultations », « après une consultation » — le Home applique, ne calcule pas (MO-01). |
| MC-04 | Tout nouveau moment s'ajoute par révision de ce document, jamais par cas particulier d'implémentation. |

---

## 6. Mobile First

La plateforme respecte **intégralement** les règles MF-01 → MF-10 de P9.0. En particulier :

| Règle | Application |
|---|---|
| CMF-01 | Une seule main : l'action de transition (préparer, entrer, valider, traiter) vit dans la zone du pouce. |
| CMF-02 | Lecture verticale : la journée puis le cycle se lisent de haut en bas, sans grille dense. |
| CMF-03 | Navigation simple : plateforme → domaine (agenda, calendrier, disponibilités, historique) → détail — trois niveaux maximum (NAV-01). |
| CMF-04 | Actions prioritaires : une seule action principale par surface, dictée par le moment (MC-02). |
| CMF-05 | Hiérarchie immédiate : l'imminence d'abord, toujours (cohérent avec PRI-02 du Home). |
| CMF-06 | Aucune surcharge : jamais plus de six éléments d'attention simultanés (UX-07). |
| CMF-07 | La Salle Live est plein écran hors navigation (NAV-05) ; on y entre et on en sort par cette plateforme uniquement. |

---

## 7. Les informations publiées vers le Home

La Consultation Platform est le **propriétaire exclusif** de ces remontées. Aucune autre plateforme ne pourra jamais les publier.

| Remontée | Contenu | Famille Home (§4 Home Foundation) |
|---|---|---|
| **Prochaine consultation** | la suivante, datée | Imminence |
| **Consultation imminente** | celle qui commence — la seule remontée temps réel (RF-03 du Home) | Imminence |
| **Préparation requise** | une préparation incomplète avant échéance | Attention |
| **Consultation en cours** | le fait « en séance », publié pendant le Live | Imminence |
| **Résumé disponible** | un résumé en attente de validation | Attention |
| **Suivi à effectuer** | des suites en attente de traitement | Attention |

| Règle | Énoncé |
|---|---|
| PUB-01 | Toute remontée est un fait publié du cycle (CY-01) — jamais une interprétation. |
| PUB-02 | La plateforme retire elle-même ses remontées devenues sans objet (DIS-02 du Home). |
| PUB-03 | Une remontée indisponible est publiée indisponible — jamais estimée (IND-02 du Home). |
| PUB-04 | Toute nouvelle remontée s'ajoute par révision conjointe de ce document et de la Home Foundation (famille + propriétaire). |

---

## 8. Gouvernance

| Règle | Énoncé |
|---|---|
| CG-01 | Une consultation possède toujours un propriétaire : la Consultation Platform pour son cycle, les plateformes système pour leurs mécanismes. |
| CG-02 | Chaque information possède une **seule source de vérité**. Aucune duplication. |
| CG-03 | Aucun calcul transversal : ce qui se calcule se calcule chez son propriétaire. |
| CG-04 | Aucune logique métier hors de son propriétaire. |
| CG-05 | Les plateformes système restent invisibles pour l'utilisateur ; la Consultation Platform expose uniquement une expérience métier cohérente. |
| CG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise. |

---

## 9. Extensibilité

L'architecture accueille les années futures **sans remise en cause** :

| Extension | Comment elle s'insère |
|---|---|
| Consultations de groupe | le cycle est identique ; l'étape Live accueille plusieurs participants — le cycle ne change pas |
| Co-animation | plusieurs experts dans la même consultation ; la propriété du cycle reste unique |
| Organisations, entreprises, cabinets, hôpitaux, universités | un contexte d'appartenance s'ajoute à la consultation ; le cycle, les moments et les remontées restent les mêmes |
| Classes virtuelles | un mode de Live supplémentaire derrière l'étape Live ; Entrée et Fin inchangées |
| Multi-intervenants | généralisation de la co-animation ; les rôles se déclarent, le cycle demeure |
| Nouveaux modes Live | de nouveaux mécanismes derrière la même porte (Entrée) et la même clôture (Fin) |

| Règle | Énoncé |
|---|---|
| CEX-01 | Le cycle de vie (§2) est l'invariant décennal : les extensions enrichissent les étapes, elles n'en ajoutent ni n'en retirent sans révision de ce document. |
| CEX-02 | Toute extension nomme son étape d'attache et son propriétaire de mécanisme avant tout développement. |
| CEX-03 | Aucune extension ne peut réintroduire une possession interdite (CN-01 → CN-09 sont perpétuels). |
| CEX-04 | La Readiness Platform étant extensible par construction (nouveaux checkers), tout nouveau prérequis d'entrée s'y ajoute — jamais dans cette plateforme. |

---

## 10. Gouvernance du document

- Ce document est la **référence officielle** de la Consultation Platform. Aucun développement concernant une consultation en dehors.
- Toute vague d'implémentation cite l'étape du cycle, le moment et les règles (CY/CP/CN/SY/MC/CMF/PUB/CG/CEX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) ou la [HOME PLATFORM FOUNDATION](home-platform-foundation.md), P9.0 prévaut, puis ce document et la Home Foundation se révisent conjointement (PUB-04).
