# MENTORA EXPERT PLATFORM V2 (Mobile First Architecture)

**Statut** : Référence officielle — tout développement de l'interface Expert doit s'inscrire dans cette architecture.
**Portée** : Architecture fonctionnelle et UX uniquement. Aucun écran, aucune maquette, aucun widget, aucun pixel, aucune couleur, aucun code.
**Rapport aux anciens écrans** : les écrans existants servent uniquement de référence fonctionnelle. Ils ne sont jamais reproduits. La V2 part d'une feuille blanche.

---

## 1. Vision générale

Mentora Expert V2 n'est pas une application : c'est le **système d'exploitation mobile de l'expert africain**.

Lorsqu'un expert ouvre Mentora, il comprend en **moins de cinq secondes** :

1. combien il va gagner aujourd'hui ;
2. quelle consultation arrive ensuite ;
3. quelles actions demandent son attention ;
4. quels messages sont importants ;
5. ce que l'IA lui recommande ;
6. où il peut améliorer son activité.

### Principe fondateur : l'information remonte, l'expert ne la cherche jamais

- La plateforme est **proactive** : chaque plateforme pousse vers la surface ce qui compte maintenant.
- L'expert **décide**, la plateforme **prépare**. Aucune donnée brute n'est présentée sans hiérarchie.
- Tout ce qui n'exige pas une décision de l'expert reste en retrait, accessible mais jamais imposé.

### Les cinq réponses en cinq secondes

Chacune des six questions de la vision est la responsabilité d'une plateforme précise (voir §3). L'écran d'entrée agrège leurs remontées — il ne possède aucune information en propre. C'est une règle de frontière, pas un choix de design : si une information doit être « cherchée », c'est que la plateforme responsable a échoué à la faire remonter.

---

## 2. Mobile First — règles constitutives

Le Desktop sera une **adaptation** du Mobile. Jamais l'inverse.

| Règle | Énoncé |
|---|---|
| MF-01 | Toute surface est conçue d'abord pour iPhone et Android. |
| MF-02 | Utilisation **à une main** : toute action primaire est atteignable par le pouce ; la zone haute de l'écran ne porte jamais d'action critique. |
| MF-03 | **Safe Area** respectée partout : aucune information ni action sous les encoches, barres système ou gestes de navigation. |
| MF-04 | La navigation racine est une **Bottom Navigation** — jamais un tiroir latéral, jamais un menu haut. |
| MF-05 | **Grands téléphones** : le contenu prioritaire vit dans la moitié basse ; le haut de l'écran est réservé au contexte et à la lecture. |
| MF-06 | **Responsive tablette** : les plateformes se réorganisent (liste + détail côte à côte) sans jamais créer de parcours spécifique tablette. Un seul modèle de navigation, deux dispositions. |
| MF-07 | Une seule action principale par surface. Les actions secondaires sont repliées. |
| MF-08 | Toute surface reste utilisable en connectivité dégradée : l'état affiché est toujours honnête (jamais de donnée inventée — fail closed, cohérent avec la Readiness Platform). |
| MF-09 | Les gestes systèmes (retour, home) ne sont jamais détournés. |
| MF-10 | Le Desktop reprend la même hiérarchie d'information et les mêmes frontières ; il n'obtient jamais de fonctionnalité absente du Mobile. |

---

## 3. Les cinq plateformes

L'architecture est organisée autour de **cinq plateformes**, chacune à responsabilité unique, chacune propriétaire exclusive de son domaine d'information. Aucune information n'appartient à deux plateformes.

### 3.1 Business Platform — « Ce que je gagne »

**Responsabilité unique** : la vérité financière de l'expert.

| Domaine | Contenu |
|---|---|
| Revenus | gains du jour, de la semaine, du mois ; évolution |
| Paiements | encaissements, statuts, litiges |
| Retraits | demandes, suivi, historique |
| Objectifs | cibles de revenu, progression |
| Croissance | tendances, leviers d'augmentation d'activité |

**Remontées** (ce que la plateforme pousse) : le gain du jour (réponse n°1 de la vision), tout paiement bloqué, tout objectif en risque.

**Frontières** : ne connaît ni l'agenda, ni les avis, ni l'IA. Elle publie des faits financiers ; elle ne recommande rien (les recommandations de croissance sont formulées par l'AI Platform à partir des faits publiés par la Business Platform).

### 3.2 Consultation Platform — « Mon travail »

**Responsabilité unique** : le temps de l'expert et le déroulement des consultations.

| Domaine | Contenu |
|---|---|
| Agenda | la prochaine consultation, la journée en cours |
| Calendrier | vue temporelle complète |
| Disponibilités | plages ouvertes, exceptions, absences |
| Historique | consultations passées et leurs suites |
| Salle Live | l'entrée unique vers la consultation en cours (adossée aux plateformes Session, Experience et Readiness existantes) |

**Remontées** : la prochaine consultation (réponse n°2), toute consultation imminente, toute préparation incomplète (readiness fail closed : rien n'est « prêt » tant que ce n'est pas prouvé).

**Frontières** : ne calcule aucun revenu, n'affiche aucun avis, ne produit aucun résumé. La Salle Live est une **porte** : la plateforme y conduit, elle n'implémente rien de la consultation elle-même.

### 3.3 AI Platform — « Mon copilote »

**Responsabilité unique** : l'intelligence au service de l'expert.

| Domaine | Contenu |
|---|---|
| Assistant | dialogue et aide contextuelle |
| Résumés | synthèses de consultations |
| Suggestions | prochaines actions proposées |
| Insights | lectures de l'activité |
| Recommandations | mises en relation et priorités recommandées |

**Remontées** : la recommandation du moment (réponse n°5), les pistes d'amélioration (réponse n°6).

**Frontières** : l'AI Platform **propose, ne décide jamais** ; toute action reste un choix explicite de l'expert. Elle consomme les faits publiés par les autres plateformes ; elle n'en possède aucun. Côté système, elle est l'unique surface UX du Gateway IA existant — aucune autre plateforme ne parle à l'IA.

### 3.4 Reputation Platform — « Ce que je vaux »

**Responsabilité unique** : l'image publique et l'autorité de l'expert.

| Domaine | Contenu |
|---|---|
| Profil | identité publique, spécialités, présentation |
| Avis | retours clients, réponses |
| Certifications | diplômes, validations, badges |
| Masterclass | contenus d'autorité de l'expert |
| Audience | portée, visibilité, communauté |

**Remontées** : tout avis nécessitant une réponse (contribue à la réponse n°3), toute certification arrivant à échéance.

**Frontières** : ne touche ni aux revenus ni à l'agenda. La réputation influence la croissance, mais la lecture de cette influence appartient à l'AI Platform.

### 3.5 Account Platform — « Mon compte »

**Responsabilité unique** : la relation entre l'expert et Mentora.

| Domaine | Contenu |
|---|---|
| Messages | conversations avec les clients |
| Notifications | centre de notifications unifié |
| Paramètres | préférences, langue, appareil |
| Sécurité | authentification, sessions, confidentialité |
| Support | aide, contact, incidents |

**Remontées** : les messages importants (réponse n°4), toute alerte de sécurité.

**Frontières** : les messages sont de la conversation, jamais de la consultation ; dès qu'un échange devient une consultation, il traverse la frontière vers la Consultation Platform par un parcours explicite.

---

## 4. Navigation

### 4.1 Structure racine

- **Bottom Navigation à cinq entrées**, une par plateforme. C'est l'unique navigation racine (MF-04).
- L'ordre des entrées suit la fréquence d'usage attendue : Consultation, Business, AI, Reputation, Account. *(L'ordre est un choix de configuration, la structure à cinq entrées est une règle.)*
- La surface d'entrée de chaque plateforme est son **tableau de remontées** : ce qui demande attention d'abord, le reste ensuite.

### 4.2 L'écran d'entrée (« Aujourd'hui »)

- La première surface affichée à l'ouverture est l'agrégat des remontées des cinq plateformes — les six réponses de la vision, dans cet ordre de priorité : gains du jour, prochaine consultation, actions en attente, messages importants, recommandation IA, amélioration.
- Cet agrégat **ne possède rien** : chaque élément est rendu par sa plateforme et y reconduit en un geste.
- Cinq secondes de lecture maximum : six éléments, jamais plus.

### 4.3 Règles de navigation

| Règle | Énoncé |
|---|---|
| NAV-01 | Profondeur maximale : trois niveaux (plateforme → domaine → détail). |
| NAV-02 | Toute surface est accessible en trois gestes maximum depuis l'ouverture. |
| NAV-03 | Le retour ramène toujours au niveau précédent de la même plateforme — jamais de saut implicite entre plateformes. |
| NAV-04 | Les traversées de frontière (ex. message → consultation) sont des parcours **explicites et nommés**, jamais des raccourcis cachés. |
| NAV-05 | La Salle Live est une surface **plein écran hors navigation** : on y entre par la Consultation Platform, on en sort vers elle. Aucune Bottom Navigation en consultation. |
| NAV-06 | Une notification conduit toujours à la surface de la plateforme propriétaire, jamais à une surface intermédiaire. |

---

## 5. Frontières — règles d'architecture

| Règle | Énoncé |
|---|---|
| FR-01 | Une information appartient à exactement une plateforme. Toute autre plateforme qui l'affiche la **cite** (remontée), elle ne la possède pas. |
| FR-02 | Aucune plateforme n'appelle les mécanismes internes d'une autre. Les échanges passent par des remontées publiées et des parcours de traversée explicites. |
| FR-03 | L'AI Platform est la seule surface UX de l'IA. Aucun composant IA dispersé dans les autres plateformes ; les autres plateformes affichent des remontées IA, citées comme telles. |
| FR-04 | La Salle Live s'adosse exclusivement aux plateformes système existantes (Session, Experience, Readiness). La V2 n'en réimplémente rien. |
| FR-05 | Fail closed partout : une information indisponible s'affiche comme indisponible. Aucune valeur par défaut optimiste, aucun état inventé. |
| FR-06 | Les plateformes système (AI Gateway, Recording, Readiness, Booking, Payment…) restent invisibles : la V2 n'expose jamais un nom technique, un vendor ou un mécanisme interne. |
| FR-07 | Aucun écran, composant ou parcours ne peut être développé hors des cinq plateformes. Toute nouvelle capacité commence par se rattacher à une plateforme — ou justifie une révision de ce document. |

---

## 6. Règles UX

| Règle | Énoncé |
|---|---|
| UX-01 | **Cinq secondes** : toute surface répond à sa question principale en moins de cinq secondes de lecture. |
| UX-02 | **Hiérarchie stricte** : une surface = une question principale, une action principale. |
| UX-03 | **Proactivité** : ce qui demande attention remonte ; ce qui n'en demande pas reste en retrait. Jamais l'inverse. |
| UX-04 | **Honnêteté des états** : chargement, indisponibilité, erreur et vide sont des états conçus, distincts et assumés. |
| UX-05 | **Aucune impasse** : toute surface propose une sortie claire (action, retour, aide). |
| UX-06 | **Confiance** : tout ce qui touche l'argent, la réputation ou l'enregistrement affiche l'état exact et demande un consentement explicite — aucune action irréversible en un seul geste. |
| UX-07 | **Sobriété cognitive** : jamais plus de six éléments d'attention simultanés sur une surface. |
| UX-08 | **Continuité** : interrompre un parcours (appel entrant, changement d'app) ne perd jamais le travail de l'expert. |
| UX-09 | **L'IA propose** : toute suggestion IA est identifiée comme telle, refusable en un geste, et son refus est respecté (cohérent avec les invariants consentement/refus du système). |
| UX-10 | **Langage expert** : le vocabulaire est celui du métier de l'expert, jamais celui de la technique. |

---

## 7. Extensions futures

L'architecture accueille ces extensions **sans révision des frontières** — chacune a déjà sa plateforme d'attache :

| Extension | Plateforme d'attache |
|---|---|
| Multi-devises, nouveaux moyens de paiement et retraits locaux | Business |
| Équipes et cabinets (plusieurs experts) | Business + Account |
| Consultations de groupe, files d'attente | Consultation |
| Partage d'écran et nouveaux checkers de préparation | Consultation (via la Readiness Platform, extensible par construction) |
| Nouveaux copilotes IA (préparation de séance, suivi client) | AI |
| Marketplace de Masterclass, abonnements d'audience | Reputation |
| Programmes de certification partenaires | Reputation |
| Modes hors ligne renforcés, multi-appareils | Account |
| Desktop (adaptation) | toutes — même hiérarchie, mêmes frontières (MF-10) |

Règle d'extension : **une extension qui ne trouve pas sa plateforme d'attache est un signal de révision de ce document, jamais un prétexte à construire hors architecture.**

---

## 8. Gouvernance du document

- Ce document est la **référence officielle** de l'interface Expert. Aucun écran ne se développe en dehors.
- Toute vague d'implémentation V2 cite la plateforme et les règles (MF/NAV/FR/UX) qu'elle réalise.
- Les règles de ce document ont vocation à devenir des **règles exécutables** (balayages de gouvernance) au fur et à mesure que les surfaces V2 naissent — même discipline que le reste de l'architecture Enterprise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
