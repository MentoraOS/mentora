# HOME PLATFORM FOUNDATION — TODAY OPERATING CENTER

**Statut** : Référence officielle — toute évolution de la Home Platform doit s'inscrire dans cette architecture. Aucun développement de la Home Platform n'est autorisé en dehors.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran Flutter, aucun widget, aucun pixel, aucune couleur, aucun pseudo-code, aucune maquette, aucune logique métier.
**Filiation** : ce document réalise le §4.2 (« écran d'entrée Aujourd'hui ») de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), qu'il ne contredit jamais. En cas de doute, P9.0 prévaut.

---

## 1. Mission exacte du Home

Le Home n'est **pas un Dashboard**. Il n'affiche pas des statistiques : il affiche **la journée de l'expert**.

C'est le **Centre Opérationnel Quotidien** (Today Operating Center) : la surface unique où, en moins de cinq secondes, l'expert comprend :

1. ce qui arrive **maintenant** ;
2. ce qui arrive **ensuite** ;
3. ce qui nécessite son **attention** ;
4. ce qui lui **rapporte de l'argent** ;
5. ce que **l'IA lui recommande** ;
6. où il en est dans ses **objectifs**.

L'information remonte automatiquement. L'expert ne cherche jamais.

**Mission en une phrase** : orchestrer la remontée des informations produites par les plateformes propriétaires, dans l'ordre où la journée de l'expert les rend importantes.

---

## 2. Responsabilités autorisées

| Règle | Le Home PEUT |
|---|---|
| HM-01 | Agréger des remontées déjà produites par les plateformes propriétaires. |
| HM-02 | Ordonner ces remontées selon les priorités d'affichage (§6) et le moment de la journée (§11). |
| HM-03 | Conduire vers la plateforme propriétaire en un geste (le Home est une porte, jamais une destination). |
| HM-04 | Afficher les états honnêtes d'une remontée : présente, vide, indisponible (§9, §10). |
| HM-05 | Faire disparaître une remontée devenue sans objet (§8). |

---

## 3. Responsabilités interdites

| Règle | Le Home NE PEUT JAMAIS |
|---|---|
| HN-01 | Posséder une donnée : aucune consultation, aucun revenu, aucun message, aucune IA, aucun avis, aucune Masterclass. |
| HN-02 | Calculer quoi que ce soit : aucun agrégat, aucune somme, aucune moyenne, aucune tendance. Ce qui s'affiche arrive déjà calculé par la plateforme propriétaire. |
| HN-03 | Décider quoi que ce soit : aucun seuil, aucune règle métier, aucune interprétation. |
| HN-04 | Déclencher une action métier : le Home conduit vers la plateforme qui agit ; il n'agit jamais lui-même. |
| HN-05 | Connaître un provider, une persistance, une IA, un moteur, un vendor ou tout mécanisme système (cohérent avec FR-06 de P9.0). |
| HN-06 | Reformuler une information : la remontée s'affiche telle que publiée, citée depuis sa plateforme. |
| HN-07 | Devenir une plateforme métier : toute capacité qui dépasse l'agrégation appartient à une des cinq plateformes de P9.0. |

Le Home est une **plateforme d'agrégation**. Jamais une plateforme métier.

---

## 4. Informations pouvant remonter

Seules ces familles d'informations peuvent remonter au Home — chacune publiée par sa plateforme propriétaire, jamais produite par le Home :

| Famille | Contenu remonté | Question de la vision servie |
|---|---|---|
| Imminence | la consultation en cours ou qui commence bientôt, son état de préparation | « maintenant », « ensuite » |
| Attention | toute action en attente d'une décision de l'expert (avis à répondre, paiement bloqué, préparation incomplète, échéance) | « attention » |
| Revenu du jour | le gain du jour et son état, tel que publié | « argent » |
| Progression | l'état des objectifs tel que publié (atteint, en cours, en retard) | « objectifs » |
| Recommandation | la recommandation IA du moment, citée comme venant de l'IA | « IA » |
| Conversation | les messages importants, tels que qualifiés par leur plateforme | « attention » |
| Annonce | les nouveautés importantes de la plateforme Mentora | — (secondaire, jamais prioritaire) |

Toute autre information est **interdite de remontée** tant que ce document n'est pas révisé.

---

## 5. Plateformes propriétaires

| Remontée | Propriétaire unique |
|---|---|
| Imminence, préparation | Consultation Platform |
| Revenu du jour, progression des objectifs | Business Platform |
| Recommandation, améliorations | AI Platform |
| Avis à traiter, échéances de certification | Reputation Platform |
| Messages importants, annonces, alertes de sécurité | Account Platform |

Règle **HP-01** : une remontée sans propriétaire identifié n'existe pas. Le Home refuse par construction toute information orpheline (fail closed).

Règle **HP-02** : le Home affiche la provenance implicitement par la conduite (le geste mène à la plateforme propriétaire) — jamais par un vocabulaire technique.

---

## 6. Priorités d'affichage

Ordre de priorité **absolu** (du plus haut au plus bas) :

1. **Ce qui commence maintenant** (consultation en cours ou imminente) ;
2. **Ce qui demande votre attention** (décisions en attente) ;
3. **Vos revenus aujourd'hui** ;
4. **Votre progression / votre prochain objectif** ;
5. **Les recommandations IA** ;
6. **Les nouveaux messages** ;
7. Les nouveautés importantes (uniquement s'il reste de la place).

| Règle | Énoncé |
|---|---|
| PRI-01 | Maximum **six éléments prioritaires** simultanés (UX-07 de P9.0). Le septième attend. |
| PRI-02 | L'imminence ne peut jamais être masquée par autre chose. |
| PRI-03 | Une remontée d'attention passe toujours devant une remontée d'information. |
| PRI-04 | Les annonces ne prennent jamais une des six places si une remontée métier attend. |
| PRI-05 | À priorité égale, la plus récente d'abord. |

---

## 7. Règles de rafraîchissement

| Règle | Énoncé |
|---|---|
| RF-01 | Le Home reflète l'état publié par les plateformes ; il ne sollicite jamais un système pour fabriquer de la fraîcheur. |
| RF-02 | Le retour au Home (ouverture, retour de plateforme, retour d'arrière-plan) présente un état à jour des remontées publiées. |
| RF-03 | L'imminence se rafraîchit en continu pendant qu'elle est affichée — c'est la seule remontée à exigence temps réel. |
| RF-04 | Un rafraîchissement ne réorganise jamais la surface sous le doigt de l'expert : les changements de priorité s'appliquent à la prochaine lecture, sauf imminence (PRI-02). |
| RF-05 | Aucune remontée n'affiche une valeur périmée comme fraîche : une remontée qui ne peut être actualisée bascule en état indisponible (§10). |

---

## 8. Règles de disparition

| Règle | Énoncé |
|---|---|
| DIS-01 | Une remontée disparaît quand sa raison d'être disparaît : consultation terminée, décision prise, message lu, objectif recalculé. |
| DIS-02 | C'est la plateforme propriétaire qui retire sa remontée ; le Home ne « ferme » jamais une information de sa propre initiative. |
| DIS-03 | L'expert peut écarter une remontée non critique d'un geste ; l'écart est respecté (elle ne revient pas pour la même raison). Les remontées d'imminence et de sécurité ne sont pas écartables. |
| DIS-04 | Une disparition n'est jamais une perte : l'information reste accessible dans sa plateforme propriétaire. |
| DIS-05 | Aucune remontée fantôme : ce qui n'a plus d'objet ne reste jamais affiché. |

---

## 9. États vides

Le vide est un état **conçu**, jamais un accident (UX-04 de P9.0).

| Règle | Énoncé |
|---|---|
| EV-01 | Une famille sans contenu ne réserve pas d'espace : le Home se contracte, il ne montre pas des coquilles vides. |
| EV-02 | La journée sans aucune remontée est un moment à part entière (§11 — « journée calme ») : le Home l'assume et oriente vers ce qui construit l'activité (disponibilités, réputation), sans jamais culpabiliser. |
| EV-03 | Le vide dit la vérité : « rien ne demande votre attention » est un message de confiance, pas un écran blanc. |
| EV-04 | Aucun contenu de remplissage : pas de statistiques décoratives, pas de contenu inventé pour meubler. |

---

## 10. États indisponibles

Fail closed, cohérent avec FR-05 de P9.0 et la Readiness Platform.

| Règle | Énoncé |
|---|---|
| IND-01 | Une remontée dont la plateforme propriétaire ne répond pas s'affiche comme **indisponible** — jamais comme vide, jamais avec une valeur par défaut. |
| IND-02 | Rien n'est inventé : aucun montant estimé, aucun état supposé, aucune donnée en cache présentée comme fraîche. |
| IND-03 | L'indisponibilité d'une famille n'affecte jamais les autres : le Home dégrade localement, jamais globalement. |
| IND-04 | L'indisponibilité est sobre : elle informe sans alarmer et propose la seule action utile (réessayer / ouvrir la plateforme). |
| IND-05 | Ce qui touche l'argent affiche l'indisponibilité explicitement — jamais un zéro à la place d'un inconnu. |

---

## 11. Les Moments — le Home change selon le contexte

Le Home n'est **pas une disposition fixe de widgets**. Il est organisé autour des **moments de la journée de l'expert**. Le moment détermine ce qui remonte en tête et la tonalité de la surface.

| Moment | Ce qui domine |
|---|---|
| **Avant la première consultation** | l'imminence et la préparation ; la journée en un coup d'œil |
| **Entre deux consultations** | la suivante et son échéance ; ce qui peut être traité dans l'intervalle (attention, messages) |
| **Après une consultation** | les suites à donner (résumé à valider, action en attente) ; puis la suivante |
| **Fin de journée** | le bilan du jour publié par Business ; la préparation de demain |
| **Journée sans consultation** | ce qui construit l'activité : disponibilités à ouvrir, réputation, recommandations de croissance |
| **Weekend** | le calme assumé ; uniquement ce que l'expert a choisi de voir hors semaine |
| **Vacances** | le strict minimum : sécurité et messages critiques ; tout le reste se tait |
| **Objectif atteint** | la reconnaissance du fait, publiée par Business ; puis retour au moment courant |
| **Objectif en retard** | la progression remonte d'un cran, accompagnée des recommandations IA — sans culpabilisation (UX de confiance) |

| Règle | Énoncé |
|---|---|
| MO-01 | Le moment est un **contexte d'ordonnancement**, jamais une règle métier : le Home ne calcule pas le moment, il applique le moment publié par les plateformes propriétaires (l'agenda dit « entre deux consultations », Business dit « objectif atteint »). |
| MO-02 | Un seul moment actif à la fois ; les moments d'exception (objectif atteint / en retard) colorent le moment courant, ils ne le remplacent pas. |
| MO-03 | Les priorités du §6 restent absolues dans tous les moments : un moment réordonne à l'intérieur des règles, jamais contre elles. |
| MO-04 | Un moment inconnu ou indisponible retombe sur l'ordonnancement par défaut du §6 (fail closed). |
| MO-05 | Tout nouveau moment s'ajoute par révision de ce document, jamais par cas particulier dans une implémentation. |

---

## 12. Les Cartes d'Intention — jamais des cartes techniques

Le Home s'exprime en **cartes d'intention** : chaque carte répond à une intention de l'expert, jamais à une structure technique.

Vocabulaire canonique des intentions :

- **Ce qui commence bientôt.**
- **Ce qui demande votre attention.**
- **Vos revenus aujourd'hui.**
- **Votre progression.**
- **Votre prochain objectif.**
- **Les recommandations IA.**
- **Les nouveaux messages.**
- **Les nouveautés importantes.**

| Règle | Énoncé |
|---|---|
| CI-01 | Une carte = une intention = une question de l'expert. Jamais « une carte par table de données ». |
| CI-02 | Une carte porte au plus une action principale, qui conduit à la plateforme propriétaire (HM-03). |
| CI-03 | Le langage des cartes est celui de l'expert (UX-10 de P9.0) : jamais un nom de module, de moteur ou de vendor. |
| CI-04 | Une carte cite sa remontée telle quelle (HN-06) ; l'intention encadre, elle ne réinterprète pas. |
| CI-05 | Les intentions sont extensibles : une nouvelle intention naît d'une révision de ce document et se rattache à une famille du §4 et à un propriétaire du §5. |

---

## 13. Mobile First

Le Home respecte **intégralement** les règles MF-01 → MF-10 de P9.0. En particulier :

| Règle | Application au Home |
|---|---|
| HMF-01 | Une seule main : l'intention prioritaire et son action vivent dans la zone du pouce. |
| HMF-02 | Bottom Navigation : le Home est la surface d'entrée ; il ne remplace jamais la navigation racine et n'en ajoute aucune autre. |
| HMF-03 | Safe Area intégrale. |
| HMF-04 | **Lecture verticale** : une seule colonne d'intentions, dans l'ordre des priorités ; jamais de grille dense. |
| HMF-05 | Aucune surcharge : maximum six éléments prioritaires (PRI-01), hiérarchie immédiate, cinq secondes de lecture (UX-01). |
| HMF-06 | Tablette et Desktop : même colonne d'intentions, même ordre, disposition adaptée — jamais un Home différent. |

---

## 14. Gouvernance

Le Home :

- ne possède aucune donnée ;
- ne calcule rien ;
- ne décide rien ;
- ne déclenche aucune action métier ;
- ne connaît aucun provider ;
- ne connaît aucune persistance ;
- ne connaît aucune IA ;
- ne connaît aucun moteur.

Il agrège uniquement des informations déjà produites par leurs plateformes propriétaires.

Ces interdits ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation de la Home Platform — même discipline que le reste de l'architecture Enterprise.

---

## 15. Extensibilité — pensé pour dix ans

| Règle | Énoncé |
|---|---|
| EX-01 | Toute future plateforme peut exposer une remontée au Home **sans modifier l'architecture du Home** : il suffit de publier une remontée conforme aux familles du §4 (ou d'ajouter une famille par révision documentaire) avec un propriétaire unique. |
| EX-02 | Le Home ne connaît jamais la liste fermée des plateformes : il connaît des remontées, des priorités et des moments. Une plateforme de plus est invisible pour son architecture. |
| EX-03 | Les moments (§11) et les intentions (§12) sont les deux seuls axes d'extension du Home. Tout besoin qui ne s'exprime ni en moment ni en intention n'appartient pas au Home. |
| EX-04 | Aucune extension ne peut réintroduire un calcul, une décision ou une possession de donnée dans le Home (HN-01 → HN-07 sont perpétuels). |

---

## 16. Gouvernance du document

- Ce document est la **référence officielle** de la Home Platform. Aucun développement de la Home Platform hors de cette architecture.
- Toute vague d'implémentation Home cite les règles (HM/HN/HP/PRI/RF/DIS/EV/IND/MO/CI/HMF/EX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), P9.0 prévaut et ce document est révisé.
