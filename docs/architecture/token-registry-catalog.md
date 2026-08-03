# TOKEN REGISTRY CATALOG

**Statut** : Le **dictionnaire canonique du Design System Mentora** — le catalogue officiel d'admission des Tokens. Deuxième livrable de P11.9. **Ce document ne crée rien** : il **admet officiellement** les Tokens déjà autorisés par les systèmes P11, sous la Constitution du [Universal Token Registry](universal-token-registry.md) (P11.9A).
**Portée** : Architecture fonctionnelle uniquement. Aucun Flutter, aucun ThemeData, aucun JSON, aucune valeur, aucun code, aucune implémentation, aucun renommage, aucun nouveau Token, aucun Token technique.
**Préséance** : celle du registre (P11.9A) — P9 → P10 → opposables → P11.0 → Design Tokens System (P11.8) → Universal Token Registry → ce catalogue. Aucun document existant n'est modifié.

**Convention d'admission** — pour éviter toute duplication, les attributs communs à un domaine sont portés une fois par son en-tête ; chaque entrée porte le reste :

| Attribut (UTC-01) | Où il est précisé |
|---|---|
| Domaine | la section du domaine (§D1 → §D10) |
| Origine officielle | l'en-tête du domaine (le document système et ses règles) |
| Propriétaire sémantique | l'en-tête du domaine |
| Statut | **Enregistré** pour toute entrée de ce catalogue (cycle §8 du registre : proposé par son système, accepté par cette instruction, enregistré par ce commit) — sauf mention contraire |
| Version | **1.0 — admission initiale** (datée par le commit de ce catalogue) pour toute entrée — sauf mention contraire |
| Groupe | la table de groupe dans le domaine |
| Nom (signification nommée) | la colonne Token — le nom sémantique établi par le système d'origine (UTC-03 : un rôle, jamais une valeur ni une technologie) |
| Signification | la colonne Signification — une phrase (UTC-05) |
| Relations | la colonne Relations (les quatre officielles : compose / décline / remplace / hérite — « — » sinon) |

| Règle | Énoncé |
|---|---|
| TRC-01 | Aucun Token n'est admis sans origine officielle (UTS-01) ; toute entrée de ce catalogue cite son système et ses règles. |
| TRC-02 | Aucun doublon (UTT-01/02/03) : l'unicité a été vérifiée entre domaines — les homonymies inter-domaines (ex. « Attention » couleur / signe / état) sont des Tokens distincts car leurs Domaines et significations diffèrent, liés par leurs origines communes en amont. |
| TRC-03 | Aucune signification ambiguë : chaque signification tient en une phrase, dans le langage des fondations. |
| TRC-04 | Les **Variants** (thèmes, contrastes, contextes d'appareil, échelles) ne sont pas des entrées : elles se déclinent sous le nom admis (relation « décline », niveau Variant du registre). |

---

## §D1 — Domaine Color

**Origine officielle** : [Color System](color-system.md) (§4 — les 27 rôles ; §5 — les liaisons d'états). **Propriétaire sémantique** : Color System. **Statut/Version** : Enregistré / 1.0.

**Groupe : Rôles d'identité**

| Token | Signification | Relations |
|---|---|---|
| Primary | la présence de Mentora ; l'unique action principale de la surface | décline : accents (Appearance §D8) |
| Secondary | l'accompagnement de l'identité | — |
| Supporting | le soutien discret de l'identité | — |

**Groupe : Rôles de signification**

| Token | Signification | Relations |
|---|---|---|
| Information | un fait neutre qui informe | — |
| Success | un fait accompli et vérifié, confirmé sobrement | — |
| Warning | une vigilance justifiée, publiée | — |
| Critical | la gravité réelle : erreur bloquante, alerte de sécurité | — |
| Neutral | l'absence de signification particulière | — |

**Groupe : Rôles d'état**

| Token | Signification | Relations |
|---|---|---|
| Unavailable | existe mais ne répond pas — fail closed, distinct du vide | — |
| Disabled | présent mais hors de portée maintenant | — |
| Attention (couleur) | ceci attend ton regard — sans crier | — |
| Focus (couleur) | l'élément qui reçoit l'interaction — un seul | — |
| Highlight | la mise en évidence passagère de ce qui vient de changer | — |

**Groupe : Rôles d'interaction et de navigation**

| Token | Signification | Relations |
|---|---|---|
| Action (couleur) | on peut agir ici | — |
| Selection (couleur) | le choisi, encore modifiable | — |
| Navigation (couleur) | le déplacement : où l'on est, où l'on peut aller | — |
| Immersion (couleur) | l'enveloppe du plein écran | — |

**Groupe : Rôles de confiance et d'IA**

| Token | Signification | Relations |
|---|---|---|
| Verified | prouvé par une source | — |
| Declared | affirmé sans preuve — honnêtement | — |
| Prediction | le prévisionnel fondé sur l'engagé | — |
| Estimate | l'estimation incertaine, dite incertaine | — |
| AI Suggestion (couleur) | ceci vient de l'IA — partout, toujours | — |

**Groupe : Rôles d'environnement**

| Token | Signification | Relations |
|---|---|---|
| Background | le fond général — le calme | décline : thèmes (Appearance §D8) |
| Surface (couleur) | le support d'un block ou d'une section | décline : thèmes |
| Foreground | le contenu premier sur son fond | décline : thèmes |
| Outline | la délimitation discrète | — |
| Divider | la séparation des temps de lecture | — |

*Les liaisons d'états (§5 du Color System) sont des relations d'usage amont, non des entrées.* **27 Tokens admis.**

---

## §D2 — Domaine Typography

**Origine officielle** : [Typography System](typography-system.md) (§4 — les 27 rôles ; §5 — la hiérarchie). **Propriétaire sémantique** : Typography System. **Statut/Version** : Enregistré / 1.0.

**Groupe : Rôles de structure**

| Token | Signification | Relations |
|---|---|---|
| Display | la plus grande voix : un fait rare qui domine tout | — |
| Hero | l'information principale de la surface — une seule | — |
| Page Title | le nom de l'endroit : où je suis | — |
| Section Title | le nom d'un temps de lecture | — |
| Surface Title | le nom d'une surface secondaire ou d'un aparté | — |
| Block Title | le nom d'une carte d'intention | — |

**Groupe : Rôles de corps**

| Token | Signification | Relations |
|---|---|---|
| Body | le texte courant : ce qui se lit | décline : échelles (Font Scale, §D8) |
| Label | le nom court d'une chose | — |
| Supporting | la précision qui accompagne sans rivaliser | — |
| Caption | la légende : ce qui décrit un élément | — |
| Hint | l'aide au moment utile : ce qui est attendu | — |
| Metadata | la donnée de contexte : qui, où, combien | — |
| Timestamp | le quand : daté, exact | — |
| Footnote | la note marginale rare | — |
| Legal | l'obligation : ce que le droit exige — lisible | — |

**Groupe : Rôles de données et d'états**

| Token | Signification | Relations |
|---|---|---|
| Value | la valeur qui compte — jamais nue, jamais un zéro pour un inconnu | — |
| Status | l'état écrit : ce qui est, maintenant | — |
| Empty State (texte) | le vide assumé : « rien ne demande votre attention » | — |
| Loading (texte) | le travail en cours, honnête | — |

**Groupe : Rôles d'interaction**

| Token | Signification | Relations |
|---|---|---|
| Action (texte) | le libellé d'un acte : dit ce qui va se passer | — |
| Navigation (texte) | le libellé d'un déplacement : où l'on va | — |
| Message | la parole d'une conversation — jamais reformulée | — |

**Groupe : Rôles de signification**

| Token | Signification | Relations |
|---|---|---|
| AI Suggestion (texte) | l'écrit de l'IA, cité comme tel, avec sa raison | — |
| Verification | l'écrit du prouvé, avec sa preuve dépliable | — |
| Warning (texte) | la vigilance écrite, justifiée | — |
| Critical (texte) | la gravité écrite : explique sans culpabiliser | — |
| Success (texte) | la réussite écrite, sobre | — |

**27 Tokens admis.**

---

## §D3 — Domaine Spacing

**Origine officielle** : [Spacing System](spacing-system.md) (§3 — les lois ; §7 — le niveau Relationship). **Propriétaire sémantique** : Spacing System. **Statut/Version** : Enregistré / 1.0.

**Groupe : Relations spatiales**

| Token | Signification | Relations |
|---|---|---|
| Proximité liée | les éléments liés restent proches — l'appartenance se lit sans cadre | — |
| Séparation distincte | deux intentions différentes respirent — jamais collées | — |
| Respiration hiérarchique | l'information principale respire davantage — l'espace traduit la priorité | — |
| Contraction calme | la surface sans actualité se contracte — sans écraser ce qui reste | — |

**Groupe : Cadences**

| Token | Signification | Relations |
|---|---|---|
| Cadence verticale | le rythme régulier de la colonne de lecture — constant partout | décline : densités (Density, §D8) |
| Respiration d'intention | le temps de pause entre deux intentions | décline : densités |

**Groupe : Exigences d'espace**

| Token | Signification | Relations |
|---|---|---|
| Espace de focus | autour de l'important, le calme — le vide qui protège l'attention | — |
| Aire de saisie | l'espace où la parole de l'expert se recueille sans étouffer | — |

**8 Tokens admis.**

---

## §D4 — Domaine Elevation & Surface

**Origine officielle** : [Elevation & Surface System](elevation-surface-system.md) (§3.3 — les significations d'élévation ; §3.1/3.4 — les responsabilités de surface). **Propriétaire sémantique** : Elevation & Surface System. **Statut/Version** : Enregistré / 1.0.

**Groupe : Significations d'élévation**

| Token | Signification | Relations |
|---|---|---|
| Aparté | l'au-dessus bref : consulter, choisir, revenir — sans descendance | — |
| Décision | l'enceinte de protection d'un acte sensible et au-delà — une seule à la fois | — |
| Immersion (élévation) | le plein écran total : la Salle — par sa porte unique | — |
| Signalement | l'attention qui attend son tour — à son niveau, sans couche | — |

**Groupe : Responsabilités de surface**

| Token | Signification | Relations |
|---|---|---|
| Contenant de block | l'enveloppe d'une intention autoportante | — |
| Contenant de section | l'enveloppe d'un temps de lecture | — |
| Contenant de surface | l'enveloppe de la réponse à une question | — |
| Scène | le support d'ensemble qui s'efface — le calme du fond | décline : thèmes (§D8) |

**8 Tokens admis.**

---

## §D5 — Domaine Iconography

**Origine officielle** : [Iconography System](iconography-system.md) (§9 — les dix familles et leurs intentions signées). **Propriétaire sémantique** : Iconography System. **Statut/Version** : Enregistré / 1.0. *(Chaque Token est une signification signée : le tracé de référence viendra au niveau Variant/production — jamais ici.)*

| Groupe (famille) | Tokens admis (signification signée) | Relations |
|---|---|---|
| Navigation | Entrer · Revenir · Traverser · Porte de plateforme | — |
| Actions | Accepter · Écarter · Répondre · Créer · Modifier | — |
| États | Disponible (signe) · Indisponible (signe) · Attente (signe) · Erreur (signe) · Succès (signe) · Attention (signe) · Sélection (signe) · Focus (signe) | — |
| Confiance | Vérifié (signe) · Déclaré (signe) · Preuve · Estimation (signe) · Avertissement (signe) · Information (signe) | — |
| Communication | Message (signe) · Notification · Réponse | — |
| Business | Revenu · Paiement · Retrait · Objectif | — |
| Consultation | Agenda · Préparation · Salle · Résumé · Suivi | — |
| AI | Signe IA · Proposition · Insight · Connaissance | — |
| Sécurité | Appareil · Accès · Alerte · Confidentialité | — |
| Système | Réglages · Aide · Support · Langue (signe) | — |

**47 Tokens admis** (Navigation 4, Actions 5, États 8, Confiance 6, Communication 3, Business 4, Consultation 5, AI 4, Sécurité 4, Système 4).

---

## §D6 — Domaine Illustration

**Origine officielle** : [Illustration System](illustration-system.md) (§8 — les douze familles ; §3.2 — les situations officielles). **Propriétaire sémantique** : Illustration System. **Statut/Version** : Enregistré / 1.0. *(Chaque Token est une situation illustrée avec sa narration — l'image de référence viendra au niveau Variant/production.)*

**Groupe : Situations de contexte (famille Context/Empty State)**

| Token | Signification | Relations |
|---|---|---|
| Pas de consultation aujourd'hui | la journée calme, assumée — invite à construire | — |
| Profil incomplet | le manque qui affaiblit la confiance — invite à compléter | — |
| Paiement en attente | l'argent en chemin — l'état exact, sans euphémisme | — |
| Aucune donnée disponible | le vide honnête — jamais masqué | — |
| Connexion interrompue | l'état réseau honnête — rien n'est perdu | — |
| Première utilisation | l'arrivée — Mentora se présente sobrement | — |

**Groupe : Contextes de famille**

| Token | Signification | Relations |
|---|---|---|
| Accueil (Welcome) | l'arrivée dans Mentora | — |
| Mise en place (Onboarding) | le premier accès guidé | — |
| Découverte de parcours (Learning) | l'apprentissage — à durée de vie bornée | — |
| Accompagnement (Guidance) | le moment délicat, humanisé | — |
| Activité naissante (Business) | avant les premiers revenus | — |
| Cycle naissant (Consultation) | l'agenda vide, la découverte de la préparation | — |
| Copilote découvert (AI) | la rencontre avec l'assistance ; le calme sans proposition | — |
| Confiance naissante (Trust) | le profil à construire, la première preuve | — |
| Environnement (System) | maintenance annoncée, interruption système | — |
| Attention accompagnée | l'attention non critique, humanisée — jamais la sécurité | — |
| Reprise (Recovery) | le contexte retrouvé, sereinement | — |

**17 Tokens admis.**

---

## §D7 — Domaine Component Library

**Origine officielle** : [Component Library](component-library.md) (§8 — les dix-neuf chapitres ; §13 — le composant comme contrat). **Propriétaire sémantique** : Component Library. **Statut/Version** : Enregistré / 1.0. *(Chaque Token est la **composition de contrat** d'un chapitre : la recette nommée de ce que ses contrats consomment — relation « compose » vers les Tokens sémantiques des autres domaines. Les contrats individuels s'admettront par versionnement de ces compositions au fil du catalogue de la bibliothèque.)*

| Token (composition de chapitre) | Signification | Relations |
|---|---|---|
| Composition Display | montrer un fait à son niveau | compose : rôles Color/Typography |
| Composition Navigation | entrer, revenir, traverser | compose : Navigation (couleur, texte, signes) |
| Composition Information | dire, préciser, contextualiser | compose : rôles d'information |
| Composition Action | agir — une action principale | compose : Primary, Action, Cible atteignable |
| Composition Selection | choisir, défaire | compose : Selection (couleur), états |
| Composition Input | saisir sans jamais perdre | compose : Hint, Aire de saisie |
| Composition Confirmation | consentir en connaissance | compose : Décision, Legal, Distance de sécurité |
| Composition Progress | montrer l'avancement réel | compose : Loading, Information |
| Composition Attention | signaler à l'intensité juste | compose : Attention (couleur, signe), Signalement |
| Composition Immersion | contenir l'acte total | compose : Immersion (couleur, élévation) |
| Composition Trust | prouver, citer, distinguer | compose : Verified, Declared, Preuve |
| Composition Business | les contrats économiques | compose : Value, Supporting, rôles Business (signes) |
| Composition Consultation | les contrats du cycle | compose : rôles Consultation (signes), Status |
| Composition Communication | converser, notifier | compose : Message (texte, signe), Notification |
| Composition System | l'environnement : réglage, aide | compose : rôles Système (signes) |
| Composition Recovery | reprendre, restituer | compose : Reprise (illustration), Status |
| Composition AI | proposer cité, accueillir/écarter | compose : AI Suggestion (couleur, texte), Signe IA |
| Composition Security | protéger, alerter, consentir | compose : Critical, Alerte, Décision |
| Composition Workspace | le contexte d'espace de travail | compose : rôles Information, Selection |

**19 Tokens admis.**

---

## §D8 — Domaine Appearance

**Origine officielle** : [Global Experience Foundation §5](global-experience-foundation.md) (GEA-01→03) et [Design Tokens System §3.11](design-tokens-system.md). **Propriétaire sémantique** : Global Experience Foundation (règles) — stockage Account Platform, sous le cycle de l'[Experience Preferences Foundation](experience-preferences-foundation.md). **Statut/Version** : Enregistré / 1.0.

| Token (préférence) | Signification | Relations |
|---|---|---|
| Theme | le mode d'apparence choisi — Light, Dark ou System | décline : jeux de valeurs par thème (Color, Scène) |
| Accent | la couleur d'accent choisie — **Mentora Emerald, l'accent officiel** ; accents futurs par déclinaison | décline : jeux de valeurs de Primary/Secondary/Supporting |
| Density | la densité de présentation — Compact, Standard, Comfortable | décline : Cadence verticale, Respiration d'intention |
| Font Scale | l'échelle de texte — Small, Standard, Large, Extra Large | décline : rôles Typography (sans casse de hiérarchie) |
| Motion Preference | l'expression du mouvement — Full, Reduced, None | décline : expressions des intentions Motion (§D10) |
| Contrast | le niveau de contraste — Standard, High Contrast | décline : jeux de valeurs Color sous CSA-04 |
| Reading Comfort | le confort de lecture — extensions futures (Focus Reading, Dyslexia Friendly, Low Vision) | décline : futures déclinaisons — **statut Enregistré, déclinaisons en attente de révision GE** |

**7 Tokens admis.**

---

## §D9 — Domaine Interaction

**Origine officielle** : [Design Tokens System §3.8](design-tokens-system.md), sur les exigences de l'[Interaction Foundation](interaction-foundation.md) (IPR, IF) et de l'[Accessibility Foundation](accessibility-foundation.md). **Propriétaire sémantique** : Interaction Foundation (exigences), nommées par le Design Tokens System. **Statut/Version** : Enregistré / 1.0.

| Token | Signification | Relations |
|---|---|---|
| Cible atteignable | l'espace minimal garanti à tout geste — pour tous, au pouce | — |
| Distance de sécurité | l'éloignement garanti des actes critiques de tout geste voisin | — |
| Immédiateté de l'accusé | le délai maximal de la réponse « reçu » du système | — |
| Temps suffisant | le droit au temps : jamais de compte à rebours punitif | — |

**4 Tokens admis.**

---

## §D10 — Domaine Motion

**Origine officielle** : [Design Tokens System §3.9](design-tokens-system.md), sur les huit intentions fermées du [Motion Foundation](motion-foundation.md) (MI) — sous les contraintes perpétuelles de temps (MT). **Propriétaire sémantique** : Motion Foundation (intentions), nommées par le Design Tokens System. **Statut/Version** : Enregistré / 1.0.

| Token (intention) | Signification | Relations |
|---|---|---|
| Expliquer | rendre un changement compréhensible en le montrant | décline : Motion Preference (§D8) |
| Guider | conduire le regard et le geste vers la suite naturelle | décline : Motion Preference |
| Rassurer | dire que le système a entendu, travaille, a fini | décline : Motion Preference |
| Préserver le contexte | montrer que rien ne se perd — que l'on vient de quelque part | décline : Motion Preference |
| Attirer l'attention | signaler ce qui mérite le regard, maintenant | décline : Motion Preference |
| Accompagner | suivre le geste de l'expert, sans résistance ni zèle | décline : Motion Preference |
| Confirmer | sceller un acte au moment exact | décline : Motion Preference |
| Montrer la continuité | relier l'avant et l'après — jamais de téléportation | décline : Motion Preference |

**8 Tokens admis.**

---

## Récapitulatif d'admission

| Domaine | Tokens admis |
|---|---|
| Color | 27 |
| Typography | 27 |
| Spacing | 8 |
| Elevation & Surface | 8 |
| Iconography | 47 |
| Illustration | 17 |
| Component Library | 19 |
| Appearance | 7 |
| Interaction | 4 |
| Motion | 8 |
| **Total** | **172** |

| Règle | Énoncé |
|---|---|
| TRC-05 | Ces 172 admissions constituent la version 1.0 du dictionnaire canonique — toutes Enregistrées, toutes tracées par le commit de ce catalogue. |
| TRC-06 | Toute admission future suit le cycle du registre (P11.9A §8) et s'ajoute par révision de ce catalogue — jamais ailleurs. |
| TRC-07 | Aucune implémentation ne consomme un Token hors de ce catalogue (DTD, UTX) ; un besoin non couvert retourne à son système d'origine (UTS-01). |

---

*Gouvernance du document : ce catalogue est l'instrument d'admission du registre — toute modification est une décision d'architecture explicite, tracée. En cas de conflit : la Constitution (P11.9A) prévaut, puis les systèmes d'origine, puis ce catalogue.*
