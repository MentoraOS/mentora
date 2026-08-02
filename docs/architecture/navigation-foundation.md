# NAVIGATION FOUNDATION

**Statut** : Référence officielle de toute navigation dans Mentora.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucun composant, aucun code, aucune implémentation, aucune bibliothèque, aucun pseudo-code, aucune maquette. Cette fondation ne décrit pas un système technique — elle décrit **le langage officiel de déplacement dans Mentora**.
**Filiation** : premier descendant du [MENTORA EXPERIENCE SYSTEM FOUNDATION](mentora-experience-system-foundation.md) (piliers **Navigation** et **Focus** — MSD-01 : elle précise, ne redéfinit pas). Elle applique les règles NAV-01 → NAV-06 de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), qui prévaut en cas de conflit. Les descendants suivants (Interaction, Design Language, Motion, Component, Accessibility, Responsive) devront la respecter.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity par ses types Recovery (§3.10), ses contextes de reprise (§6), ses règles d'interruption (§9) et ses principes de continuité (§10).

---

## 1. Mission

**Mission en une phrase** : définir la manière dont l'utilisateur se déplace dans Mentora — comment on entre, comment on sort, comment on revient — et rien d'autre.

Elle ne possède jamais : les plateformes, les données, les composants, les providers, les moteurs, les plateformes système, la logique métier.

---

## 2. Vision

L'utilisateur ne navigue jamais au hasard.

| Règle | Énoncé |
|---|---|
| NV-01 | Chaque déplacement possède une **intention**. |
| NV-02 | Chaque transition possède une **raison**. |
| NV-03 | Chaque destination possède une **responsabilité** — on n'arrive jamais « quelque part », on arrive chez un propriétaire. |
| NV-04 | L'utilisateur comprend toujours : **où il est, d'où il vient, où il va, comment revenir** (PX-01 du MES). |

---

## 3. Les types de navigation

Dix types officiels. Tout déplacement dans Mentora appartient à exactement un type.

### 3.1 Primary Navigation

| | |
|---|---|
| **Mission** | Le déplacement racine entre les cinq plateformes. |
| **Responsabilités** | Porter la navigation à cinq entrées (MF-04), toujours accessible au pouce, jamais plus. |
| **Frontières** | Elle change de plateforme, jamais d'étape à l'intérieur d'une plateforme. |
| **Ce qu'elle permet** | rejoindre n'importe quelle plateforme en un geste, depuis presque partout. |
| **Ce qu'elle ne doit jamais faire** | disparaître sans raison immersive (§3.5) ; accueillir une sixième entrée ; devenir un menu. |

### 3.2 Secondary Navigation

| | |
|---|---|
| **Mission** | Le déplacement à l'intérieur d'une plateforme, entre ses domaines. |
| **Responsabilités** | Conduire de la surface d'entrée d'une plateforme vers ses domaines (niveau 1 → niveau 2). |
| **Frontières** | Elle reste dans la plateforme ; traverser une frontière relève de la Context Navigation. |
| **Ce qu'elle permet** | explorer les domaines d'une plateforme dans l'ordre de ses priorités. |
| **Ce qu'elle ne doit jamais faire** | créer des raccourcis cachés entre plateformes ; dépasser la profondeur autorisée (§7). |

### 3.3 Context Navigation

| | |
|---|---|
| **Mission** | La traversée **explicite et nommée** d'une frontière de plateforme (NAV-04). |
| **Responsabilités** | Porter les parcours de traversée officiels (message → consultation ; opportunité → action chez son propriétaire ; remontée Home → plateforme propriétaire). |
| **Frontières** | Toute traversée est un parcours déclaré ; le retour ramène au point de départ de la traversée. |
| **Ce qu'elle permet** | suivre une intention à travers les plateformes sans se perdre. |
| **Ce qu'elle ne doit jamais faire** | traverser silencieusement ; transformer une traversée en détour ; faire perdre le contexte d'origine. |

### 3.4 Temporary Navigation

| | |
|---|---|
| **Mission** | Le déplacement bref qui ne quitte pas vraiment : consulter, choisir, revenir. |
| **Responsabilités** | Porter les apartés courts (un détail, une précision, un choix) qui se referment d'un geste. |
| **Frontières** | Un aparté n'a pas de descendance : on n'y navigue pas plus loin, on en revient. |
| **Ce qu'elle permet** | vérifier sans perdre sa place. |
| **Ce qu'elle ne doit jamais faire** | devenir un empilement ; capturer l'utilisateur ; masquer la surface d'origine plus que nécessaire. |

### 3.5 Immersive Navigation

| | |
|---|---|
| **Mission** | Le plein écran des moments qui exigent tout : la Salle Live (NAV-05). |
| **Responsabilités** | Faire entrer par une porte unique (l'Entrée du cycle), suspendre la Primary Navigation, garantir la sortie propre vers la plateforme d'origine. |
| **Frontières** | L'immersion est réservée aux moments déclarés par leur plateforme (consultation en cours) ; jamais un choix de style. |
| **Ce qu'elle permet** | l'exercice sans distraction — zéro navigation pendant l'acte. |
| **Ce qu'elle ne doit jamais faire** | s'ouvrir sans préparation prouvée ; se fermer brutalement ; laisser l'utilisateur sans issue de secours claire. |

### 3.6 Modal Navigation

| | |
|---|---|
| **Mission** | L'arrêt volontaire du flux pour une décision qui ne peut pas attendre ni se faire ailleurs. |
| **Responsabilités** | Porter les consentements et confirmations d'actes importants (UX-06 : argent, réputation, enregistrement, irréversible). |
| **Frontières** | Un modal exige une décision et n'offre que ça : décider ou renoncer explicitement. |
| **Ce qu'elle permet** | protéger l'utilisateur au moment exact du choix. |
| **Ce qu'elle ne doit jamais faire** | servir de raccourci d'affichage ; s'empiler ; bloquer sans issue (PX-05) ; presser l'utilisateur. |

### 3.7 Back Navigation

| | |
|---|---|
| **Mission** | Revenir — toujours possible, toujours prévisible. |
| **Responsabilités** | Ramener au niveau précédent de la même plateforme (NAV-03) ; refermer l'aparté ; clore la traversée vers son origine. |
| **Frontières** | Le retour est défini au §8 ; les gestes système de retour ne sont jamais détournés (MF-09). |
| **Ce qu'elle permet** | explorer sans crainte : on peut toujours revenir. |
| **Ce qu'elle ne doit jamais faire** | sauter entre plateformes ; détruire un travail sans confirmation ; surprendre. |

### 3.8 Deep Navigation

| | |
|---|---|
| **Mission** | Arriver directement au bon endroit depuis un point d'entrée externe ou une remontée. |
| **Responsabilités** | Porter l'atterrissage direct (notification → surface propriétaire, NAV-06 ; remontée Home → plateforme) en **reconstruisant le contexte** : l'utilisateur arrive avec un « où suis-je » et un retour cohérents. |
| **Frontières** | L'atterrissage respecte les profondeurs (§7) ; il n'ouvre jamais une surface interdite (préparation non prouvée → fail closed). |
| **Ce qu'elle permet** | aller droit au but sans traverser tout le système. |
| **Ce qu'elle ne doit jamais faire** | déposer l'utilisateur sans contexte ni retour ; contourner une porte (l'Entrée en consultation, un consentement). |

### 3.9 Cross Platform Navigation

| | |
|---|---|
| **Mission** | La même philosophie de déplacement sur chaque format et appareil. |
| **Responsabilités** | Garantir que les types, profondeurs, retours et contextes sont identiques partout ; seules les dispositions changent (MF-06, MF-10). |
| **Frontières** | Aucun parcours spécifique par appareil ; le pilier Responsiveness règle la disposition, jamais la structure. |
| **Ce qu'elle permet** | changer d'appareil sans réapprendre Mentora. |
| **Ce qu'elle ne doit jamais faire** | créer une navigation Desktop différente ; offrir une destination absente du Mobile. |

### 3.10 Recovery Navigation

| | |
|---|---|
| **Mission** | Reprendre — après une interruption, une coupure, une absence. |
| **Responsabilités** | Ramener l'utilisateur là où son parcours s'était arrêté (UX-08), avec son contexte reconstruit ; proposer la reprise, jamais l'imposer quand le moment a changé. |
| **Frontières** | La reprise s'appuie sur les états publiés par les plateformes ; elle ne restaure jamais un état périmé comme actuel. |
| **Ce qu'elle permet** | ne jamais recommencer inutilement (NCO-01). |
| **Ce qu'elle ne doit jamais faire** | rejouer une action ; reprendre dans une surface devenue invalide (consultation close → l'après, pas la salle). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | La Navigation Foundation PEUT |
|---|---|
| NP-01 | Organiser les déplacements. |
| NP-02 | Définir les parcours. |
| NP-03 | Définir les transitions. |
| NP-04 | Définir les profondeurs. |
| NP-05 | Définir les changements de contexte. |
| NP-06 | Définir les retours. |
| NP-07 | Définir les parcours interrompus. |
| NP-08 | Définir la continuité. |

### 4.2 Interdites

| Règle | La Navigation Foundation NE PEUT JAMAIS |
|---|---|
| NN-01 | Posséder une plateforme métier. |
| NN-02 | Décider. |
| NN-03 | Calculer. |
| NN-04 | Posséder les données. |
| NN-05 | Connaître les providers. |
| NN-06 | Connaître les moteurs. |
| NN-07 | Posséder la logique métier. |
| NN-08 | Remplacer le MES — elle précise ses piliers Navigation et Focus, rien de plus. |

---

## 5. Relation avec les plateformes

Chaque plateforme reste **propriétaire de son contenu**. La Navigation Foundation définit uniquement **comment on y entre, comment on en sort, comment on y revient**.

| Plateforme | Entrer | Sortir / revenir |
|---|---|---|
| Home | surface d'ouverture (niveau 0) ; on y revient par la Primary Navigation | on en sort par une remontée (Context) vers la plateforme propriétaire |
| Consultation | par la Primary Navigation ou une remontée d'imminence ; la Salle Live par sa porte unique (Immersive) | la sortie de Salle revient toujours à la Consultation Platform |
| Business | par la Primary Navigation ou une remontée (revenu, retrait, opportunité) | un retrait traverse vers son mécanisme par un parcours explicite et confirmé (Modal) |
| AI | par la Primary Navigation ou une remontée citée IA | l'écart d'une proposition referme sans détour |
| Reputation | par la Primary Navigation ou une remontée (avis, échéance) | répondre à un avis reste dans la plateforme ; l'aide IA arrive citée, sans traversée |
| Account | par la Primary Navigation ou une remontée (sécurité, message) | un message qui devient consultation traverse explicitement (Context) vers la Consultation Platform |

| Règle | Énoncé |
|---|---|
| NR-01 | Une plateforme déclare ses portes (entrées, sorties, traversées) ; la navigation les porte, elle n'en invente jamais. |
| NR-02 | Toute arrivée dans une plateforme atterrit sur une surface dont la plateforme est propriétaire — jamais sur un intermédiaire (NAV-06). |
| NR-03 | Aucun contenu de plateforme ne migre dans la navigation : la navigation transporte, elle n'affiche pas. |

---

## 6. Les contextes de navigation

| Contexte | Mission |
|---|---|
| **Navigation quotidienne** | le rythme normal : Home → plateformes → retours, au fil des moments de la journée. |
| **Navigation urgente** | l'imminence ou la sécurité prend la main (Focus) : le chemin le plus court vers ce qui n'attend pas — jamais plus d'un geste. |
| **Navigation immersive** | la Salle Live : tout est suspendu sauf l'acte (§3.5). |
| **Navigation de reprise** | revenir après une absence : le contexte se reconstruit, la reprise se propose (§3.10). |
| **Navigation interrompue** | l'interruption survient en route : le parcours se fige proprement, prêt à reprendre (§9). |
| **Navigation ponctuelle** | l'aparté : consulter et revenir (§3.4). |
| **Navigation système** | l'environnement s'impose brièvement (authentification, maintenance annoncée) : honnête, bornée, réversible dès que possible. |
| **Navigation exceptionnelle** | un événement rare (alerte de sécurité non écartable) : un seul chemin clair, aucune distraction. |
| **Navigation terminée** | le parcours s'achève : la sortie est propre, l'arrivée est le prochain moment naturel — jamais un cul-de-sac (PX-05). |
| **Navigation impossible** | la destination n'est pas disponible (préparation non prouvée, capacité indisponible) : fail closed, l'empêchement est expliqué, l'alternative est proposée. |

| Règle | Énoncé |
|---|---|
| NC-01 | Un contexte découle des faits publiés (imminence, interruption, indisponibilité) — jamais d'un état technique exposé. |
| NC-02 | Un seul contexte domine à la fois ; l'urgence et la sécurité priment (ACM-03, pilier Focus). |
| NC-03 | Tout nouveau contexte s'ajoute par révision de ce document. |

---

## 7. Les profondeurs

Les niveaux officiels — la profondeur maximale est **trois niveaux sous la racine** (NAV-01) :

| Niveau | Définition | Exemple de nature |
|---|---|---|
| **Niveau 0** | la racine : le Home et la Primary Navigation | l'entrée du système |
| **Niveau 1** | la surface d'entrée d'une plateforme | le tableau des remontées d'une plateforme |
| **Niveau 2** | un domaine de la plateforme | l'agenda, les revenus, les avis |
| **Niveau 3** | un détail du domaine | une consultation, un paiement, un avis |

| Règle | Énoncé |
|---|---|
| ND-01 | Toute surface est accessible en trois gestes maximum depuis l'ouverture (NAV-02). |
| ND-02 | Le niveau 3 est la profondeur **terminale** : aucun niveau 4 — un besoin plus profond est un aparté (Temporary) ou une traversée (Context), jamais un enfoncement. |
| ND-03 | Le retour remonte d'un niveau à la fois, dans la même plateforme (NAV-03). |
| ND-04 | Un atterrissage direct (Deep) à un niveau 2 ou 3 **reconstruit le contexte** : les niveaux supérieurs existent pour le retour, même si l'utilisateur ne les a pas traversés. |
| ND-05 | La Salle Live (Immersive) et les modals sont **hors profondeur** : on n'y descend pas, on y entre et on en sort. |

---

## 8. Le retour

| Règle | Énoncé |
|---|---|
| NB-01 | **Ce qu'est un retour** : revenir au niveau précédent du même parcours, avec son état retrouvé — jamais un simple dépilement technique. |
| NB-02 | **Quand il est possible** : toujours, sauf pendant un acte qui ne se coupe pas en deux (une décision modale en cours, la clôture d'une consultation). |
| NB-03 | **Quand il est interdit** : au milieu d'un acte irréversible confirmé ; en sortie d'immersion sans clôture propre — la sortie de Salle passe par la fin de l'acte, jamais par un retour discret. |
| NB-04 | **Retrouver son contexte** : le retour restitue la surface d'origine dans l'état où on l'a quittée (défilement, saisie, sélection) — sinon il le dit. |
| NB-05 | **Ne jamais perdre le travail** : un retour qui abandonnerait une saisie en cours demande confirmation (UX-06) ; le travail se conserve plutôt qu'il ne se perd. |
| NB-06 | Le geste de retour système fait toujours ce que le retour Mentora ferait (MF-09) — jamais autre chose. |

---

## 9. Les interruptions

Le système préserve **toujours** le contexte.

| Interruption | Comportement officiel |
|---|---|
| **Consultation entrante** | l'imminence prend la main (Focus) ; le parcours en cours se fige proprement ; après l'acte, la reprise est proposée. |
| **Notification** | elle n'interrompt jamais visuellement un acte ; elle attend son tour (Focus) et conduit ensuite chez son propriétaire (NAV-06). |
| **Appel** | l'expérience se fige ; au retour, la reprise reprend le parcours exact (UX-08). |
| **Perte réseau** | l'état devient honnête (MF-08) : ce qui est indisponible se dit indisponible ; le parcours reste consultable ; rien ne se perd. |
| **Authentification** | l'environnement s'impose (Navigation système) ; le parcours attend derrière, intact. |
| **Maintenance** | annoncée par l'Account Platform (moment Maintenance) ; jamais une surprise ; la reprise est garantie. |
| **Mise à jour** | jamais bloquante en cours d'acte ; proposée aux moments calmes. |
| **Reprise** | la Recovery Navigation (§3.10) : contexte reconstruit, moment réévalué, reprise proposée. |

| Règle | Énoncé |
|---|---|
| NI-01 | Aucune interruption ne détruit un parcours : elle le fige. |
| NI-02 | Aucune interruption n'interrompt un acte protégé (consultation en cours, décision modale) hors urgence de sécurité. |
| NI-03 | Après toute interruption, la reprise est **proposée** ; si le moment a changé, le nouveau moment prime et l'ancien parcours reste accessible. |

---

## 10. Les principes de continuité

| Règle | Énoncé |
|---|---|
| NCO-01 | L'utilisateur **ne recommence jamais inutilement**. |
| NCO-02 | Une plateforme **retrouve toujours son état**. |
| NCO-03 | Les changements restent **compréhensibles** : ce qui a changé pendant l'absence se signale, jamais ne se camoufle. |
| NCO-04 | Le parcours reste **cohérent** : d'où je viens et où je vais survivent à toute interruption. |
| NCO-05 | **La continuité prévaut toujours** — sur la nouveauté, sur la fraîcheur, sur la commodité d'implémentation. |

---

## 11. Mobile First

| Règle | Énoncé |
|---|---|
| NMF-01 | La navigation est pensée d'abord pour **le pouce** : une seule main (MF-02). |
| NMF-02 | La navigation principale est accessible **immédiatement**, en permanence hors immersion. |
| NMF-03 | Le retour est **naturel** : geste système, jamais détourné. |
| NMF-04 | **Peu de profondeur** : trois niveaux, trois gestes (§7). |
| NMF-05 | Les transitions sont **rapides** : elles accompagnent, jamais ne retardent (pilier Motion). |
| NMF-06 | **Aucun détour inutile** : le chemin le plus court est le chemin officiel. |
| NMF-07 | **Desktop = adaptation. Jamais l'inverse** (MSMF-07). |

---

## 12. Les transitions

| Règle | Une transition |
|---|---|
| NTR-01 | **explique** : elle montre d'où l'on vient et où l'on arrive. |
| NTR-02 | **ne surprend jamais** : elle résulte d'un geste ou d'un fait annoncé (PX-04). |
| NTR-03 | **respecte le contexte** : entrer en immersion, traverser une frontière et revenir en arrière ne se ressemblent pas — chacun a sa transition. |
| NTR-04 | **respecte l'utilisateur** : jamais de mouvement qui retarde l'action (PX-06). |
| NTR-05 | **préserve la continuité** : ce qui était là reste retrouvable. |
| NTR-06 | **n'efface jamais le parcours** : une transition ne détruit ni l'historique ni le contexte. |

*(Les courbes, durées et réalisations concrètes appartiennent au Motion Foundation, descendant du MES.)*

---

## 13. Gouvernance

| Règle | Énoncé |
|---|---|
| NG-01 | Toute nouvelle navigation appartient à l'un des dix types officiels (§3) ; sinon, c'est ce document qu'on révise. |
| NG-02 | Toute nouvelle transition respecte cette fondation (§12). |
| NG-03 | Toute nouvelle profondeur respecte cette fondation (§7) — le niveau 3 reste terminal. |
| NG-04 | **Aucun parcours parallèle. Aucune navigation cachée.** |
| NG-05 | Aucun comportement différent selon les équipes : une seule navigation Mentora. |
| NG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation. |

---

## 14. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouvelles plateformes | reçoivent les dix types tels quels ; leurs portes se déclarent (NR-01) |
| Nouveaux appareils, pliables, tablettes, desktop, web | Cross Platform Navigation : mêmes types, dispositions adaptées |
| TV, automobile | les contextes s'adaptent (urgence, immersion) ; la philosophie demeure |
| Wearables | l'essentiel seulement : navigation urgente et remontées — jamais la profondeur |
| Voice | les mêmes intentions de déplacement, dites au lieu d'être touchées ; mêmes portes, mêmes interdits |
| Réalité mixte | de nouvelles dispositions des mêmes types ; l'immersion y garde ses règles de porte et de sortie |
| Nouveaux paradigmes | de nouvelles modalités dans les types existants ; un nouveau type exige la révision de ce document |

| Règle | Énoncé |
|---|---|
| NX-01 | Les dix types (§3) sont l'invariant décennal. |
| NX-02 | La philosophie de navigation reste identique sur tout appareil (NV-01 → NV-04 partout). |
| NX-03 | Aucune extension ne peut affaiblir les profondeurs (§7), le retour (§8) ni la continuité (§10). |

---

## 15. Gouvernance du document

- Ce document est la **référence officielle** de toute navigation dans Mentora.
- Toute vague d'implémentation cite le type, le contexte, la profondeur et les règles (NV/NP/NN/NR/NC/ND/NB/NI/NCO/NMF/NTR/NG/NX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis le [MES](mentora-experience-system-foundation.md), puis ce document (MSD-01).
