# AI PLATFORM FOUNDATION

**Statut** : Référence officielle — aucun développement concernant la AI Platform ne sera réalisé en dehors de cette architecture.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucune maquette, aucun pixel, aucun code, aucun pseudo-code, aucune logique métier, aucun provider, aucune persistance.
**Filiation** : ce document réalise la « AI Platform » du §3.3 de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) et alimente le Home défini par [HOME PLATFORM FOUNDATION](home-platform-foundation.md), aux côtés de [CONSULTATION PLATFORM FOUNDATION](consultation-platform-foundation.md) et [BUSINESS PLATFORM FOUNDATION](business-platform-foundation.md). En cas de conflit, P9.0 prévaut.

---

## 1. Mission

La AI Platform n'est **pas un chatbot**. Elle n'est **pas ChatGPT**. Elle n'est **pas un écran de conversation**.

Elle est le **copilote professionnel permanent de l'expert**.

Elle accompagne. Elle explique. Elle prépare. Elle recommande. Elle synthétise. Elle aide. **Elle ne décide jamais.**

**Mission en une phrase** : représenter fonctionnellement toutes les capacités d'assistance intelligente de Mentora, au service des décisions de l'expert — jamais à leur place.

Elle ne possède jamais : les consultations, les paiements, la réputation, les paramètres, les messages, les plateformes système. Elle possède uniquement **l'accompagnement intelligent**.

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| AIV-01 | L'IA travaille **avec** l'expert. Elle ne travaille jamais **à sa place**. |
| AIV-02 | Elle accompagne toutes les plateformes ; elle n'en possède aucune. |
| AIV-03 | Elle ne possède jamais une décision métier : toute action reste un choix explicite de l'expert (FR-03, UX-09 de P9.0). |
| AIV-04 | Elle représente uniquement les capacités professionnelles d'assistance de Mentora — jamais leur mécanique. |
| AIV-05 | Elle est l'**unique surface UX de l'IA** : aucune capacité IA ne s'expose ailleurs autrement qu'en remontée citée (FR-03 de P9.0). |

---

## 3. Les domaines métier

Dix domaines fonctionnels. Chaque capacité d'assistance appartient à exactement un domaine.

### 3.1 Professional Copilot

| | |
|---|---|
| **Mission** | Être la présence d'ensemble : le copilote qui connaît le contexte professionnel du moment et fait converger les autres domaines. |
| **Responsabilités** | Représenter « ce que l'IA a pour vous maintenant » ; ordonner les apports des autres domaines selon le moment professionnel (§6). |
| **Frontières** | Le Copilot orchestre l'expérience des domaines IA ; il n'exécute rien lui-même et ne parle jamais aux mécanismes. |
| **Propriétaire** | AI Platform. |
| **Informations publiées** | Conseil important ; préparation recommandée. |

### 3.2 Assistant

| | |
|---|---|
| **Mission** | Répondre et aider, en séance comme hors séance. |
| **Responsabilités** | Représenter le dialogue d'aide contextuel ; porter l'assistance en consultation (surface fournie au Live). |
| **Frontières** | Le mécanisme appartient à la plateforme système Assistant (via l'AI Gateway) ; en séance, la surface vit dans la Salle Live (plateformes Session/Experience) — l'AI Platform en définit l'expérience, jamais l'assemblage. |
| **Propriétaire** | AI Platform (expérience) ; système Assistant (mécanisme). |
| **Informations publiées** | — (l'assistance ne remonte pas au Home ; elle se vit en contexte). |

### 3.3 Summary

| | |
|---|---|
| **Mission** | Restituer l'essentiel de chaque consultation, prêt à valider. |
| **Responsabilités** | Représenter les résumés produits, leur état (prêt, validé) ; conduire à la validation. |
| **Frontières** | La production appartient au système Summary (toujours en dernier à l'arrêt de séance) ; la présentation dans le cycle appartient à la Consultation Platform (étape Résumé) — l'AI Platform possède l'expérience de la capacité, pas l'étape. |
| **Propriétaire** | AI Platform (capacité) ; système Summary (mécanisme) ; Consultation Platform (étape du cycle). |
| **Informations publiées** | Résumé disponible *(publication portée par la Consultation Platform dans le cycle — voir AIS-04)*. |

### 3.4 Translation

| | |
|---|---|
| **Mission** | Abolir la barrière de langue entre l'expert et son client. |
| **Responsabilités** | Représenter la traduction et les sous-titres configurés ; leur état. |
| **Frontières** | Le mécanisme appartient au système Translation ; la surface en séance vit dans la Salle Live. |
| **Propriétaire** | AI Platform (capacité) ; système Translation (mécanisme). |
| **Informations publiées** | — (capacité de séance, aucune remontée Home). |

### 3.5 Action Items

| | |
|---|---|
| **Mission** | Faire que rien de ce qui a été dit d'important ne se perde. |
| **Responsabilités** | Représenter les actions relevées en consultation ; leur priorité proposée ; conduire vers leur traitement (étape Suivi). |
| **Frontières** | Le relevé appartient au système Action Items ; le traitement des suites appartient à la Consultation Platform (Suivi). L'IA propose la priorité, l'expert la décide. |
| **Propriétaire** | AI Platform (capacité) ; système Action Items (mécanisme) ; Consultation Platform (traitement). |
| **Informations publiées** | Action prioritaire. |

### 3.6 Recommendations

| | |
|---|---|
| **Mission** | Proposer la bonne chose au bon moment — mise en relation, priorité, prochain geste professionnel. |
| **Responsabilités** | Représenter les recommandations produites, leur raison, leur confiance qualitative (jamais un score chiffré) ; recueillir l'accueil de l'expert (accepté, écarté). |
| **Frontières** | Le mécanisme appartient au système Recommendation (qui n'invente jamais un expert ni une donnée) ; les opportunités économiques formulées ici sont portées au Home par la Business Platform (cadre économique — BEX de P9.3). |
| **Propriétaire** | AI Platform. |
| **Informations publiées** | Nouvelle recommandation. |

### 3.7 Insights

| | |
|---|---|
| **Mission** | Donner à l'expert une lecture de son activité qu'il n'aurait pas vue seul. |
| **Responsabilités** | Représenter les lectures produites (dynamiques, causes probables, signaux faibles), toujours distinguées des faits. |
| **Frontières** | Les faits appartiennent à leurs plateformes (Business, Consultation, Reputation) ; l'insight les lit, les cite et ne les modifie jamais. Une lecture incertaine est présentée incertaine (AE-05). |
| **Propriétaire** | AI Platform. |
| **Informations publiées** | Suggestion d'amélioration. |

### 3.8 Knowledge

| | |
|---|---|
| **Mission** | Mettre le savoir utile à portée de l'expert, au moment où il sert. |
| **Responsabilités** | Représenter les connaissances contextuelles (pratiques, repères, savoirs métier) proposées par l'assistance. |
| **Frontières** | Le savoir proposé est cité avec sa source ; il ne se substitue jamais au jugement professionnel de l'expert. Les contenus d'autorité de l'expert (Masterclass) appartiennent à la Reputation Platform. |
| **Propriétaire** | AI Platform. |
| **Informations publiées** | Connaissance utile. |

### 3.9 Productivity

| | |
|---|---|
| **Mission** | Faire gagner du temps professionnel sans jamais prendre la main. |
| **Responsabilités** | Représenter les préparations proposées (avant consultation), les rappels intelligents, les gestes évités. |
| **Frontières** | La préparation prouvée appartient à la Readiness Platform ; l'agenda appartient à la Consultation Platform. La Productivity prépare et rappelle ; elle n'agit jamais seule (AE-08). |
| **Propriétaire** | AI Platform. |
| **Informations publiées** | Préparation recommandée *(portée avec le Copilot)*. |

### 3.10 Learning

| | |
|---|---|
| **Mission** | Faire que l'assistance s'améliore avec l'expert — apprendre de ses décisions validées. |
| **Responsabilités** | Représenter ce que l'assistance a retenu des choix validés (recommandation acceptée, résumé corrigé, priorité ajustée) ; rendre ce retenu consultable et corrigeable. |
| **Frontières** | La mémoire mécanique appartient au système Memory ; rien n'est retenu d'un contenu privé (invariant Mentora : le privé ne traverse jamais) ; seules les décisions **validées** nourrissent l'apprentissage — jamais les brouillons, jamais les refus au-delà du fait du refus. |
| **Propriétaire** | AI Platform (capacité) ; système Memory (mécanisme). |
| **Informations publiées** | — (l'apprentissage est silencieux ; il se constate, ne se notifie pas). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | La AI Platform PEUT |
|---|---|
| AIP-01 | Accompagner. |
| AIP-02 | Expliquer. |
| AIP-03 | Résumer. |
| AIP-04 | Traduire. |
| AIP-05 | Proposer. |
| AIP-06 | Rappeler. |
| AIP-07 | Recommander. |
| AIP-08 | Préparer. |
| AIP-09 | Mettre en évidence. |
| AIP-10 | Apprendre à partir des décisions validées (et uniquement d'elles). |

### 4.2 Interdites

| Règle | La AI Platform NE PEUT JAMAIS |
|---|---|
| AIN-01 | Décider. |
| AIN-02 | Valider. |
| AIN-03 | Refuser. |
| AIN-04 | Réaliser un paiement. |
| AIN-05 | Modifier une consultation. |
| AIN-06 | Remplacer l'expert. |
| AIN-07 | Posséder une plateforme métier. |
| AIN-08 | Déclencher une action irréversible. |
| AIN-09 | Posséder les moteurs IA — ils appartiennent aux plateformes système. |
| AIN-10 | Connaître les vendors IA — aucun nom de moteur, de modèle ou de fournisseur dans l'expérience ni dans l'architecture de la plateforme (le Gateway est l'unique frontière technique, invisible). |

---

## 5. Relation avec les plateformes

### 5.1 Plateformes métier

| Plateforme | Ce que l'AI Platform lui apporte | Ce qu'elle ne fait jamais |
|---|---|---|
| Home Platform | ses remontées du §7, citées comme venant de l'IA | posséder l'agrégation |
| Consultation Platform | préparation proposée, assistance de séance, résumé, actions relevées — au service du cycle | modifier le cycle, décider une étape |
| Business Platform | prévisions probables, leviers, opportunités formulées — portées par Business dans leur cadre économique | posséder un fait financier, décider un paiement |
| Reputation Platform | lectures d'audience, aide à la réponse aux avis — proposées | répondre à la place de l'expert, modifier le profil |
| Account Platform | mise en évidence des messages importants — qualification proposée | envoyer un message, posséder la conversation |

### 5.2 Plateformes système

Les plateformes système **restent propriétaires de leur logique**. L'AI Platform représente uniquement les capacités.

| Plateforme système | Ce qu'elle possède |
|---|---|
| AI Gateway | l'accès unique aux capacités IA — la seule frontière technique |
| Summary | la production des résumés |
| Assistant | le mécanisme d'assistance |
| Translation | le mécanisme de traduction |
| Action Items | le relevé des actions |
| Recommendation | la production des recommandations |
| Memory | la mémoire mécanique |
| Recording | l'enregistrement consenti |
| Session | l'orchestration de séance (ordre de démarrage/arrêt) |
| Experience | les surfaces de la Salle |

| Règle | Énoncé |
|---|---|
| AIS-01 | L'AI Platform ne parle jamais à un moteur, un provider ou un vendor : toute capacité passe par sa plateforme système, elle-même derrière le Gateway. |
| AIS-02 | Aucun nom technique dans l'expérience (UX-10) : l'expert vit une assistance, jamais une architecture. |
| AIS-03 | Une capacité indisponible se présente indisponible — fail closed, localement, sans dégrader les autres (moment « Assistance indisponible », §6). |
| AIS-04 | Quand une capacité IA sert une étape d'un cycle métier (résumé → étape Résumé), la publication au Home appartient au propriétaire du cycle ; l'AI Platform fournit la capacité, pas la remontée d'étape. |
| AIS-05 | Toute nouvelle capacité système s'expose à travers un domaine existant (§3) ; sinon, c'est ce document qu'on révise. |

---

## 6. Les moments IA

La plateforme est organisée autour de **moments professionnels**. Jamais des états techniques.

| Moment | Ce que vit l'expert | Ce qui domine |
|---|---|---|
| **Préparer une consultation** | « Aide-moi à être prêt » | la préparation proposée : contexte client, points saillants, rappels |
| **Consultation en cours** | « Assiste-moi sans me distraire » | l'assistance de séance, sobre, dans la Salle Live |
| **Résumé prêt** | « Montre-moi l'essentiel » | le résumé à lire, corriger, valider |
| **Action importante détectée** | « Ne me laisse pas oublier » | l'action relevée et sa priorité proposée |
| **Recommandation disponible** | « Propose-moi » | la recommandation, sa raison, l'accueil en un geste |
| **Nouvelle connaissance** | « Apprends-moi utile » | le savoir contextuel, cité |
| **Opportunité détectée** | « Montre-moi où m'améliorer » | le levier formulé, porté ensuite par Business dans son cadre économique |
| **Aucune recommandation** | « Rien à proposer » | le calme assumé : l'IA se tait quand elle n'a rien d'utile (EV-03 du Home) |
| **Assistance indisponible** | « L'IA ne répond pas » | l'indisponibilité honnête, locale, sans alarme (IND-04 du Home) |

| Règle | Énoncé |
|---|---|
| AIM-01 | Un moment IA découle du contexte professionnel publié par les plateformes métier — jamais d'un état technique de moteur. |
| AIM-02 | Le moment détermine ce que le Copilot met en tête et l'action principale unique (MF-07). |
| AIM-03 | « Aucune recommandation » est un moment de première classe : l'IA ne meuble jamais (EV-04 du Home). |
| AIM-04 | « Assistance indisponible » est fail closed : rien n'est simulé, rien n'est promis. |
| AIM-05 | Tout nouveau moment s'ajoute par révision de ce document, jamais par cas particulier d'implémentation. |

---

## 7. Les informations publiées vers le Home

La AI Platform est le **propriétaire exclusif** de ces remontées. Aucune autre plateforme ne pourra jamais les publier.

| Remontée | Contenu | Famille Home (§4 Home Foundation) |
|---|---|---|
| **Conseil important** | le conseil du Copilot pour maintenant | Recommandation |
| **Nouvelle recommandation** | une recommandation produite, avec sa raison | Recommandation |
| **Action prioritaire** | une action relevée jugée prioritaire (proposée) | Attention |
| **Suggestion d'amélioration** | un insight actionnable sur l'activité | Recommandation |
| **Connaissance utile** | un savoir contextuel pertinent maintenant | Recommandation |
| **Préparation recommandée** | une préparation proposée avant une échéance | Attention |

*Note de frontière (AIS-04)* : « Résumé disponible » est publié par la Consultation Platform (étape de son cycle) ; « Opportunité importante » est publiée par la Business Platform (cadre économique). L'AI Platform fournit la capacité derrière ces remontées ; elle ne les publie pas.

| Règle | Énoncé |
|---|---|
| APU-01 | Toute remontée IA est citée comme venant de l'IA (UX-09) et refusable en un geste ; le refus est respecté (DIS-03 du Home). |
| APU-02 | Toute remontée porte sa raison : jamais une proposition sans explication (AE-01). |
| APU-03 | La plateforme retire elle-même ses remontées devenues sans objet (DIS-02 du Home). |
| APU-04 | Une capacité indisponible ne publie rien — jamais une remontée simulée (IND-02 du Home). |
| APU-05 | Toute nouvelle remontée s'ajoute par révision conjointe de ce document et de la Home Foundation. |

---

## 8. Mobile First

La plateforme respecte **intégralement** les règles MF-01 → MF-10 de P9.0. En particulier :

| Règle | Application |
|---|---|
| AMF-01 | Une main : accueillir ou écarter une proposition se fait dans la zone du pouce, en un geste. |
| AMF-02 | Lecture verticale : le Copilot d'abord, les domaines ensuite. |
| AMF-03 | Une action principale par surface : accepter, écarter, ouvrir — jamais plusieurs à la fois. |
| AMF-04 | Aucune surcharge : jamais plus de six propositions simultanées (UX-07) ; l'IA se tait plutôt que d'encombrer. |
| AMF-05 | Une IA toujours compréhensible : chaque proposition comprise en moins de cinq secondes (UX-01) — sinon elle est reformulée par son domaine, pas allongée. |
| AMF-06 | Une IA toujours refusable : aucun parcours ne force le passage par une proposition IA. |

---

## 9. Principes d'éthique

| Règle | L'IA |
|---|---|
| AE-01 | **explique toujours** : toute proposition porte sa raison. |
| AE-02 | **propose toujours** : jamais d'acte, toujours une proposition. |
| AE-03 | **n'impose jamais** : l'écart d'une proposition est aussi simple que son accueil. |
| AE-04 | **reste transparente** : ce qui vient de l'IA est marqué comme venant de l'IA, partout, toujours. |
| AE-05 | **ne cache jamais une incertitude** : une confiance faible se dit ; une lecture probable se présente probable. |
| AE-06 | **distingue toujours un fait d'une recommandation** : les faits appartiennent aux plateformes, les propositions à l'IA — jamais mêlés. |
| AE-07 | **respecte toujours la décision humaine** : un refus est définitif pour sa raison ; il n'est jamais re-proposé à l'identique. |
| AE-08 | **ne travaille jamais seule** : aucune chaîne d'actions autonome ; chaque étape significative repasse par l'expert. |

Ces principes sont **perpétuels** : aucune extension (§11) ne peut les affaiblir.

---

## 10. Gouvernance

| Règle | Énoncé |
|---|---|
| AG-01 | Une recommandation possède toujours une source. |
| AG-02 | Une proposition est toujours traçable (cohérent avec l'observabilité système : trace sans contenu, jamais de donnée utilisateur). |
| AG-03 | Aucune décision métier n'est déplacée vers l'IA. |
| AG-04 | Les moteurs IA restent invisibles. Les vendors restent invisibles. Le Gateway reste invisible. |
| AG-05 | L'architecture IA reste interchangeable : tout moteur se remplace derrière le Gateway sans que la AI Platform change. |
| AG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise. |

---

## 11. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux modèles IA, nouveaux providers | derrière le Gateway, invisibles (AG-05) — la plateforme ne change pas |
| Nouveaux copilotes, assistants spécialisés | des spécialisations du Copilot et de l'Assistant — mêmes domaines, mêmes règles |
| Agents métier | des capacités qui **proposent des plans** ; chaque étape significative reste validée par l'expert (AE-08) |
| Mémoire longue durée | extension du domaine Learning, mécanisme Memory — les invariants de confidentialité demeurent |
| Raisonnement avancé | qualité interne des mécanismes ; l'expérience ne change que par ses domaines |
| Voice AI, Vision AI | de nouvelles modalités d'entrée/sortie des capacités existantes — pas de nouveau domaine par modalité |
| IA locale, IA cloud | un lieu d'exécution, invisible par construction (AIN-10) |
| Nouveaux domaines professionnels | de nouveaux contextes pour les mêmes capacités ; un nouveau domaine fonctionnel exige la révision de ce document |

| Règle | Énoncé |
|---|---|
| AEX-01 | Les dix domaines (§3) sont l'invariant décennal : les extensions les enrichissent ; en ajouter ou en retirer exige une révision de ce document. |
| AEX-02 | Toute extension nomme son domaine d'attache et sa plateforme système propriétaire avant tout développement. |
| AEX-03 | Aucune extension ne peut réintroduire une possession interdite (AIN-01 → AIN-10) ni affaiblir un principe d'éthique (AE-01 → AE-08). |
| AEX-04 | Une extension qui exécute au lieu de proposer n'appartient pas à la AI Platform. |

---

## 12. Gouvernance du document

- Ce document est la **référence officielle** de la AI Platform. Aucun développement la concernant en dehors.
- Toute vague d'implémentation cite le domaine, le moment et les règles (AIV/AIP/AIN/AIS/AIM/APU/AMF/AE/AG/AEX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), P9.0 prévaut ; les remontées se révisent conjointement avec la [HOME PLATFORM FOUNDATION](home-platform-foundation.md) (APU-05).
