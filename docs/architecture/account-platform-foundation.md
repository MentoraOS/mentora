# ACCOUNT PLATFORM FOUNDATION

**Statut** : Référence officielle — aucun développement concernant la Account Platform ne sera réalisé en dehors de cette architecture.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucune maquette, aucun pixel, aucun code, aucun pseudo-code, aucune logique métier, aucun provider, aucune persistance.
**Filiation** : ce document réalise la « Account Platform » du §3.5 de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) et alimente le Home défini par [HOME PLATFORM FOUNDATION](home-platform-foundation.md), aux côtés des fondations [Consultation](consultation-platform-foundation.md), [Business](business-platform-foundation.md), [AI](ai-platform-foundation.md) et [Reputation](reputation-platform-foundation.md). En cas de conflit, P9.0 prévaut. Elle clôt la série des cinq plateformes.

---

## 1. Mission

La Account Platform n'est **pas une page Paramètres**. Elle n'est **pas un profil utilisateur**. Elle n'est **pas une plateforme d'activité**.

Elle représente **l'environnement professionnel de l'expert** : elle lui permet d'exercer son activité — elle ne fait jamais partie de son activité.

**Mission en une phrase** : représenter l'environnement de travail de l'expert (compte, préférences, sécurité, appareils, abonnement, relation avec Mentora) — entièrement modifiable sans jamais toucher l'activité.

Elle ne possède jamais : les consultations, les revenus, les paiements, la réputation, les recommandations IA, les plateformes système. Elle représente uniquement l'environnement de travail.

---

## 2. Vision

L'expert peut modifier **entièrement** son environnement de travail sans **jamais** modifier son activité.

Changer un appareil. Changer une langue. Modifier les notifications. Renforcer la sécurité. Changer un abonnement. Tout cela est possible — sans jamais modifier une consultation, un paiement, une réputation, une décision IA, une donnée métier.

| Règle | Énoncé |
|---|---|
| ACV-01 | L'environnement et l'activité sont **étanches** : aucune modification d'environnement n'altère une donnée métier. |
| ACV-02 | L'environnement est au service de l'activité : il la rend possible, il ne la contient jamais. |
| ACV-03 | Tout changement d'environnement est explicite, tracé et — lorsque c'est possible — réversible (PE-07). |
| ACV-04 | La sécurité de l'expert prime sur le confort : un risque ne se masque jamais (PE-06). |

---

## 3. Les domaines métier

Onze domaines fonctionnels. Chaque information d'environnement appartient à exactement un domaine.

*Note de filiation* : le domaine **Messages** figure ici parce que P9.0 (§3.5) et la Home Foundation (§5 — famille Conversation) l'attribuent à l'Account Platform ; l'omettre orphelinerait cette famille. Le domaine **Availability** ne possède que l'**environnement** de disponibilité : les disponibilités opérationnelles (plages ouvertes aux clients) restent à la Consultation Platform (P9.0 §3.2).

### 3.1 Account Identity

| | |
|---|---|
| **Mission** | Dire qui est titulaire du compte — et le prouver. |
| **Responsabilités** | Représenter l'identité de compte : coordonnées, langue, pays, état de vérification. |
| **Frontières** | L'identité **professionnelle** (métier, spécialités, présentation) appartient à la Reputation Platform. Le mécanisme d'authentification appartient aux systèmes Authentication/Identity. |
| **Propriétaire** | Account Platform (représentation) ; systèmes Authentication/Identity (mécanisme). |
| **Informations publiées** | — (domaine de gestion, aucune remontée Home). |

### 3.2 Professional Preferences

| | |
|---|---|
| **Mission** | Adapter Mentora à la façon de travailler de l'expert. |
| **Responsabilités** | Représenter les préférences professionnelles : langue de travail, langues de traduction par défaut, préférences d'assistance IA (activée, discrète, silencieuse), formats. |
| **Frontières** | Une préférence configure l'expérience ; elle ne modifie jamais une donnée métier (PE-08). Les préférences d'assistance ne pilotent pas l'IA : elles disent quand elle peut parler — l'AI Platform reste propriétaire de ses capacités. |
| **Propriétaire** | Account Platform. |
| **Informations publiées** | Préférences incomplètes. |

### 3.3 Security

| | |
|---|---|
| **Mission** | Protéger l'accès à l'activité de l'expert. |
| **Responsabilités** | Représenter l'état de sécurité du compte : méthode d'accès, facteurs actifs, sessions ouvertes, événements récents ; conduire au renforcement. |
| **Frontières** | Les mécanismes (authentification, facteurs, détection) appartiennent aux systèmes Authentication/Security. La plateforme représente l'état exact — un risque ne se masque jamais (PE-06), fail closed. |
| **Propriétaire** | Account Platform (représentation) ; systèmes Security (mécanisme). |
| **Informations publiées** | Action de sécurité recommandée ; alerte de sécurité. |

### 3.4 Privacy

| | |
|---|---|
| **Mission** | Donner à l'expert la maîtrise de ses données. |
| **Responsabilités** | Représenter les consentements, la visibilité des données, les droits (accès, export, suppression) ; conduire à leur exercice. |
| **Frontières** | Les invariants de confidentialité de Mentora (le privé ne traverse jamais ; consentement d'enregistrement double et définitif) sont des règles système : la Privacy les représente et les honore, elle ne peut jamais les affaiblir. |
| **Propriétaire** | Account Platform. |
| **Informations publiées** | — (domaine de gestion, aucune remontée Home). |

### 3.5 Notifications

| | |
|---|---|
| **Mission** | Faire que Mentora prévienne juste : ni trop, ni trop peu. |
| **Responsabilités** | Représenter le centre de notifications unifié et les règles de réception choisies (canaux, moments, silences). |
| **Frontières** | Le contenu d'une notification appartient à sa plateforme d'origine ; l'acheminement appartient au système Notification. Une notification conduit toujours à la surface propriétaire (NAV-06 de P9.0). |
| **Propriétaire** | Account Platform (centre et règles) ; plateformes d'origine (contenu). |
| **Informations publiées** | Notification importante. |

### 3.6 Messages

| | |
|---|---|
| **Mission** | Porter les conversations entre l'expert et ses clients. |
| **Responsabilités** | Représenter les conversations, leur importance (qualification proposée par l'IA, citée), les réponses. |
| **Frontières** | Les messages sont de la **conversation**, jamais de la consultation : dès qu'un échange devient une consultation, il traverse vers la Consultation Platform par un parcours explicite (NAV-04 de P9.0). L'IA met en évidence, ne répond jamais seule. |
| **Propriétaire** | Account Platform. |
| **Informations publiées** | Message important. |

### 3.7 Availability

| | |
|---|---|
| **Mission** | Représenter l'environnement de disponibilité : le rythme de travail choisi. |
| **Responsabilités** | Représenter le cadre : jours et heures de travail habituels, fuseau, absences et mode vacances. |
| **Frontières** | Les **disponibilités opérationnelles** (plages ouvertes aux clients, exceptions d'agenda) appartiennent à la Consultation Platform (P9.0 §3.2) : ce domaine représente le cadre d'environnement et **conduit** vers la Consultation Platform pour l'opérationnel. Le mode vacances alimente le moment « Vacances » du Home (§11 Home Foundation). |
| **Propriétaire** | Account Platform (cadre) ; Consultation Platform (opérationnel). |
| **Informations publiées** | Disponibilités à compléter (cadre non configuré — conduit vers l'opérationnel). |

### 3.8 Devices

| | |
|---|---|
| **Mission** | Faire que l'expert travaille sereinement depuis n'importe quel appareil. |
| **Responsabilités** | Représenter les appareils connectés, leur dernière activité ; conduire à la déconnexion d'un appareil. |
| **Frontières** | La session technique appartient aux systèmes Session/Security. Un appareil inconnu est un fait de sécurité : il remonte (§7), jamais silencieux. |
| **Propriétaire** | Account Platform (représentation) ; systèmes Session/Security (mécanisme). |
| **Informations publiées** | Nouvel appareil connecté. |

### 3.9 Subscription

| | |
|---|---|
| **Mission** | Dire clairement ce que l'expert a souscrit auprès de Mentora, et où il en est. |
| **Responsabilités** | Représenter l'abonnement (formule, échéance, état), conduire au changement et au renouvellement. |
| **Frontières** | L'encaissement appartient aux mécanismes financiers ; la **lecture économique de l'activité** appartient à la Business Platform. L'abonnement est une relation expert↔Mentora — jamais un revenu de l'expert. Tout changement suit UX-06 (consentement explicite, jamais irréversible en un geste). |
| **Propriétaire** | Account Platform (représentation) ; mécanismes financiers (encaissement). |
| **Informations publiées** | Abonnement à renouveler. |

### 3.10 Support

| | |
|---|---|
| **Mission** | Faire que l'expert ne soit jamais seul face à un problème. |
| **Responsabilités** | Représenter l'aide, les demandes en cours, leur état ; conduire au contact. |
| **Frontières** | La résolution appartient au système Support ; la plateforme représente l'état exact des demandes — jamais d'optimisme (« en cours » signifie en cours). |
| **Propriétaire** | Account Platform (représentation) ; système Support (mécanisme). |
| **Informations publiées** | Support disponible (réponse arrivée) ; support en attente. |

### 3.11 Workspace

| | |
|---|---|
| **Mission** | Représenter l'espace de travail : le contexte dans lequel l'expert exerce. |
| **Responsabilités** | Représenter l'espace courant (indépendant aujourd'hui ; équipe, cabinet, organisation demain), ses appartenances, son contexte actif. |
| **Frontières** | L'espace est un **contexte d'environnement** : il ne possède aucune donnée métier ; les plateformes métier lisent le contexte actif pour présenter la bonne activité (mon activité / celle de mon équipe — BEX de P9.3). |
| **Propriétaire** | Account Platform. |
| **Informations publiées** | — (domaine de contexte, aucune remontée Home). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | La Account Platform PEUT |
|---|---|
| ACP-01 | Représenter l'identité du compte. |
| ACP-02 | Représenter les préférences professionnelles. |
| ACP-03 | Représenter l'environnement de disponibilité (le cadre — l'opérationnel reste à la Consultation Platform). |
| ACP-04 | Représenter la sécurité. |
| ACP-05 | Représenter la confidentialité. |
| ACP-06 | Représenter les appareils. |
| ACP-07 | Représenter l'abonnement. |
| ACP-08 | Représenter le support. |
| ACP-09 | Publier les informations d'environnement destinées au Home (§7). |

### 4.2 Interdites

| Règle | La Account Platform NE PEUT JAMAIS |
|---|---|
| ACN-01 | Créer une consultation — Consultation Platform. |
| ACN-02 | Réaliser un paiement — mécanismes financiers. |
| ACN-03 | Calculer un revenu — Business Platform. |
| ACN-04 | Modifier la réputation — Reputation Platform. |
| ACN-05 | Recommander un expert — système Recommendation (via l'AI Platform). |
| ACN-06 | Décider — elle représente et conduit ; les décisions restent à l'expert. |
| ACN-07 | Posséder les plateformes métier. |
| ACN-08 | Connaître les moteurs IA. |
| ACN-09 | Connaître les providers — aucun vendor, aucun nom technique (FR-06 de P9.0). |
| ACN-10 | Posséder les plateformes système. |

---

## 5. Relation avec les plateformes

### 5.1 Plateformes métier

| Plateforme | Relation | Frontière |
|---|---|---|
| Home Platform | reçoit les remontées du §7 ; le mode vacances alimente son moment « Vacances » | le Home ne possède jamais l'environnement |
| Consultation Platform | lit le cadre de disponibilité et le contexte d'espace ; reçoit la conduite vers l'opérationnel | les disponibilités opérationnelles restent chez elle |
| Business Platform | lit le contexte d'espace (mon activité / mon équipe) | l'abonnement n'est jamais un revenu de l'expert |
| AI Platform | lit les préférences d'assistance (quand l'IA peut parler) ; propose la qualification des messages, citée | les préférences ne pilotent pas les capacités IA |
| Reputation Platform | l'identité de compte ici, l'identité professionnelle là-bas | aucune donnée de réputation dans l'environnement |

### 5.2 Plateformes système

| Plateforme système | Ce qu'elle possède | Ce que la Account Platform en fait |
|---|---|---|
| Authentication | le mécanisme d'accès | représente la méthode et l'état, ne vérifie jamais elle-même |
| Identity | l'identité technique du compte | représente, ne crée pas |
| Session | les sessions techniques des appareils | reflète, conduit à la déconnexion |
| Notification | l'acheminement des notifications | représente le centre et les règles de réception |
| Security | la détection et la protection | reflète l'état exact, conduit au renforcement |
| Support | la résolution des demandes | représente l'état, conduit au contact |
| Settings | la conservation des préférences | représente, sans connaître le mécanisme |

| Règle | Énoncé |
|---|---|
| ACS-01 | Chaque plateforme reste propriétaire de sa logique ; la Account Platform représente uniquement l'environnement professionnel. |
| ACS-02 | Aucun nom technique dans l'expérience (UX-10). |
| ACS-03 | Un mécanisme indisponible dégrade localement le domaine concerné — explicitement, fail closed ; la sécurité indisponible se dit indisponible, jamais supposée saine. |
| ACS-04 | Tout nouveau mécanisme d'environnement s'intègre par un domaine existant (§3) ; sinon, c'est ce document qu'on révise. |

---

## 6. Les moments du compte

La plateforme est organisée autour des **moments de l'environnement professionnel**. Jamais des états techniques.

| Moment | Ce que vit l'expert | Ce qui domine |
|---|---|---|
| **Premier accès** | « J'installe mon environnement » | la mise en place guidée : identité, sécurité, préférences, cadre de disponibilité |
| **Nouvel appareil** | « C'est bien moi ? » | le fait, la vérification, la déconnexion en un geste si ce n'est pas lui |
| **Sécurité renforcée** | « Je suis mieux protégé » | la reconnaissance du renforcement ; l'état exact |
| **Abonnement modifié** | « Mon contrat a changé » | le nouvel état, daté, réversible selon les conditions |
| **Disponibilité modifiée** | « Mon rythme a changé » | le cadre mis à jour ; la conduite vers l'opérationnel (Consultation) |
| **Préférence mise à jour** | « Mentora s'adapte » | la confirmation sobre ; la réversibilité |
| **Nouvelle notification importante** | « On me prévient » | le contenu cité, la conduite vers la plateforme d'origine |
| **Support en attente** | « On s'occupe de moi ? » | l'état exact de la demande |
| **Maintenance** | « Mentora se prépare » | l'information honnête : quoi, quand, quel impact |
| **Aucune action nécessaire** | « Tout est en ordre » | le calme assumé — message de confiance (EV-03 du Home) |

| Règle | Énoncé |
|---|---|
| ACM-01 | Un moment du compte est un fait d'environnement daté — jamais un état technique exposé. |
| ACM-02 | Le moment détermine ce qui remonte en tête et l'action principale unique (MF-07). |
| ACM-03 | Les moments de sécurité priment sur tous les autres moments du compte. |
| ACM-04 | Tout nouveau moment s'ajoute par révision de ce document, jamais par cas particulier d'implémentation. |

---

## 7. Les informations publiées vers le Home

La Account Platform est le **propriétaire exclusif** de ces remontées. Aucune autre plateforme ne pourra jamais les publier.

| Remontée | Contenu | Famille Home (§4 Home Foundation) |
|---|---|---|
| **Nouvel appareil connecté** | un accès depuis un appareil inconnu — vérifier ou déconnecter | Attention |
| **Action de sécurité recommandée** | un renforcement disponible ou nécessaire | Attention |
| **Alerte de sécurité** | un risque avéré — non écartable (DIS-03 du Home) | Attention |
| **Abonnement à renouveler** | une échéance de la relation avec Mentora | Attention |
| **Notification importante** | une notification qualifiée importante, citant sa plateforme d'origine | Attention |
| **Message important** | une conversation qui mérite l'attention (qualification IA, citée) | Conversation |
| **Support disponible** | une réponse du support est arrivée | Attention |
| **Disponibilités à compléter** | un cadre de disponibilité non configuré (conduit vers l'opérationnel) | Attention |
| **Préférences incomplètes** | un environnement pas encore adapté | Attention |
| **Annonce Mentora** | une nouveauté importante de la plateforme | Annonce |

| Règle | Énoncé |
|---|---|
| ACPU-01 | Toute remontée est un fait d'environnement daté et sourcé — jamais une interprétation. |
| ACPU-02 | La plateforme retire elle-même ses remontées devenues sans objet (DIS-02 du Home). |
| ACPU-03 | Les remontées de sécurité ne sont pas écartables (DIS-03 du Home) ; les autres le sont, et l'écart est respecté. |
| ACPU-04 | Un état indisponible est publié indisponible — la sécurité n'est jamais supposée saine (IND-02 du Home). |
| ACPU-05 | Toute nouvelle remontée s'ajoute par révision conjointe de ce document et de la Home Foundation. |

---

## 8. Mobile First

La plateforme respecte **intégralement** les règles MF-01 → MF-10 de P9.0. En particulier :

| Règle | Application |
|---|---|
| ACMF-01 | Une main : vérifier un appareil, renforcer la sécurité, répondre à un message — l'action vit dans la zone du pouce. |
| ACMF-02 | Lecture verticale : ce qui protège d'abord, ce qui configure ensuite. |
| ACMF-03 | Une action principale par surface (MF-07). |
| ACMF-04 | Aucune surcharge : jamais plus de six éléments d'attention (UX-07). |
| ACMF-05 | Comprises en moins de cinq secondes (UX-01) — y compris un état de sécurité. |
| ACMF-06 | **L'environnement reste simple à gérer** : les réglages rares se replient ; les gestes fréquents (messages, notifications) restent immédiats. |

---

## 9. Principes de l'environnement

| Règle | L'environnement |
|---|---|
| PE-01 | **reste indépendant de l'activité** : le modifier ne modifie jamais l'activité (ACV-01). |
| PE-02 | **protège toujours l'expert** : en cas de doute, la protection prime. |
| PE-03 | **reste transparent** : tout état d'environnement est consultable et exact. |
| PE-04 | **respecte toujours les choix de l'utilisateur** : un choix fait est appliqué, partout, durablement. |
| PE-05 | **ne modifie jamais les données métier**. |
| PE-06 | **ne masque jamais un risque de sécurité** : un risque se montre, même inconfortable. |
| PE-07 | **reste réversible lorsque cela est possible** : l'irréversible est explicite et confirmé (UX-06). |
| PE-08 | **sépare toujours les préférences des données professionnelles** : une préférence configure, une donnée professionnelle appartient à sa plateforme. |

Ces principes sont **perpétuels** : aucune extension (§11) ne peut les affaiblir.

---

## 10. Gouvernance

| Règle | Énoncé |
|---|---|
| ACG-01 | Une préférence possède toujours un **propriétaire** (l'expert, dans son espace). |
| ACG-02 | Une information possède toujours une **source**. |
| ACG-03 | Les plateformes métier restent indépendantes : l'environnement les sert, il ne les traverse pas. |
| ACG-04 | Les plateformes système restent invisibles. Les providers restent invisibles. |
| ACG-05 | L'environnement ne devient jamais une plateforme métier. |
| ACG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise. |

---

## 11. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux appareils | le domaine Devices |
| Nouvelles préférences, nouveaux paramètres | le domaine Professional Preferences (ou le domaine compétent) |
| Nouveaux abonnements | le domaine Subscription |
| Nouvelles organisations, espaces de travail, équipes, cabinets, entreprises | le domaine Workspace — un contexte de plus, les plateformes métier lisent le contexte actif |
| SSO | les systèmes Authentication/Identity, représentés par Account Identity — invisibles par construction |
| Authentification multifacteur, passkeys | le domaine Security, mécanismes systèmes |
| Nouveaux mécanismes de sécurité | le domaine Security — l'état représenté, le mécanisme invisible |

| Règle | Énoncé |
|---|---|
| ACEX-01 | Les onze domaines (§3) sont l'invariant décennal : les extensions les enrichissent ; en ajouter ou en retirer exige une révision de ce document. |
| ACEX-02 | Toute extension nomme son domaine d'attache et son mécanisme propriétaire avant tout développement. |
| ACEX-03 | Aucune extension ne peut réintroduire une possession interdite (ACN-01 → ACN-10) ni affaiblir un principe d'environnement (PE-01 → PE-08). |
| ACEX-04 | Un nouvel espace de travail (équipe, cabinet, entreprise) est toujours un **contexte** : jamais un déplacement de propriété des données métier. |

---

## 12. Gouvernance du document

- Ce document est la **référence officielle** de la Account Platform. Aucun développement la concernant en dehors.
- Toute vague d'implémentation cite le domaine, le moment et les règles (ACV/ACP/ACN/ACS/ACM/ACPU/ACMF/PE/ACG/ACEX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), P9.0 prévaut ; les remontées se révisent conjointement avec la [HOME PLATFORM FOUNDATION](home-platform-foundation.md) (ACPU-05).
