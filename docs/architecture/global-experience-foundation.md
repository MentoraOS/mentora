# GLOBAL EXPERIENCE FOUNDATION (INTERNATIONAL BY DESIGN)

**Statut** : Fondation transversale **opposable** — exactement comme l'[Accessibility Foundation](accessibility-foundation.md). Elle ne remplace aucun document existant. Elle garantit que **Mentora naît internationale** — et non qu'elle sera adaptée à l'international plus tard.
**Portée** : Architecture fonctionnelle uniquement. Aucun code, aucun widget, aucune API, aucune implémentation, aucun package, aucun token, aucune couleur, aucune typographie, aucun pseudo-code, aucune maquette.
**Position dans la hiérarchie** — la hiérarchie officielle devient :

```
P9 — Product Architecture
↓
P10 — Mentora Experience System (+ descendants)
↓
Accessibility Foundation (opposable)
↓
Global Experience Foundation (opposable)
↓
P11 — Design System (+ descendants)
↓
Flutter Design Kit
```

Tous les descendants P11 — réalisés ([Color](color-system.md), [Typography](typography-system.md)) comme à venir — devront désormais respecter cette fondation. Un conflit avec un document aval se résout en faveur de cette fondation ou par révision documentaire explicite ; P9.0, P10 et l'Accessibility Foundation prévalent en amont.
**Continuité (MSD-02)** : cette fondation sert le pilier Continuity à l'échelle du monde — changer de pays, de langue ou de devise n'interrompt jamais l'expérience ni ne perd le travail.

---

## 1. Mission

La Global Experience Foundation définit **comment Mentora reste la même plateforme partout dans le monde**.

Elle ne traduit pas. Elle ne convertit pas. Elle ne localise pas.

Elle définit **les règles qui permettent à Mentora d'exister dans n'importe quel pays sans modifier son architecture**.

**Principe fondateur** :

> **L'expérience est mondiale. Seule sa présentation s'adapte.**

---

## 2. Vision

Un expert au Mali, au Sénégal, au Nigeria, au Maroc, en France, au Royaume-Uni, aux États-Unis, au Canada, au Brésil, au Danemark, au Japon, en Chine, en Corée, en Inde, aux Émirats ou en Australie utilise **exactement la même plateforme**.

| Ce qui change | Ce qui reste identique |
|---|---|
| l'appareil, le pays, la langue, la monnaie, le fuseau horaire, la culture | **l'expérience Mentora** : les plateformes, le cycle, les moments, les intentions, les règles |

| Règle | Énoncé |
|---|---|
| GEV-01 | Le monde est le cas nominal : aucun pays n'est « le pays par défaut ». |
| GEV-02 | Ce qui varie entre pays est une **présentation ou une configuration** — jamais une architecture. |
| GEV-03 | L'expert qui voyage retrouve son Mentora : son travail, ses repères, ses préférences (Continuity). |

---

## 3. Les treize piliers

Treize piliers. Toute règle d'internationalisation appartient à exactement un pilier. *(Le treizième — Experience Personalization — a été ajouté par révision explicite post-audit P11.8A, avant l'ouverture de P11.9.)*

### 3.1 International by Design

| | |
|---|---|
| **Mission** | Faire que l'international soit la conception — jamais l'adaptation. |
| **Responsabilités** | Tenir l'invariant fondateur : Mentora n'est jamais conçu pour un pays ; **un pays est une configuration, jamais une architecture** ; toute conception se vérifie contre plusieurs pays dès sa naissance. |
| **Frontières** | Ce pilier est le juge de paix des douze autres — il n'a pas de territoire propre : il a droit de regard sur tout (le pendant international de l'Inclusion). |
| **Ce qu'il garantit** | aucune refonte ne sera jamais nécessaire pour « passer international » : Mentora l'est de naissance. |
| **Ce qu'il ne possède jamais** | un pays de référence ; un cas « domestique ». |

### 3.2 Language & Localization

| | |
|---|---|
| **Mission** | Séparer les langues — chacune est une notion indépendante, jamais confondue. |
| **Responsabilités** | Définir les six notions officielles, **toutes indépendantes** : **Application Language** (la langue de l'interface), **Professional Language** (la langue de travail de l'expert), **Consultation Languages** (les langues parlées en séance — plusieurs), **AI Language** (la langue des productions IA — résumés exclus), **Summary Language** (la langue des résumés, choisie), **Notification Language** (la langue des notifications). |
| **Frontières** | La plateforme porte les notions ; les préférences vivent à l'Account Platform (Professional Preferences) ; les mécanismes de traduction aux systèmes (Translation). Une langue ne modifie jamais la logique (GE-03). |
| **Ce qu'il garantit** | un expert francophone peut servir un client anglophone, recevoir un résumé en français et des notifications en bambara demain — sans conflit de notions. |
| **Ce qu'il ne possède jamais** | une traduction ; une langue par défaut mondiale ; la fusion de deux notions. |

### 3.3 Currency

| | |
|---|---|
| **Mission** | Séparer les monnaies — chaque rôle monétaire est distinct, aucune confusion. |
| **Responsabilités** | Définir les quatre notions officielles, **toutes indépendantes** : **Business Currency** (la monnaie de l'activité de l'expert), **Display Currency** (la monnaie d'affichage préférée), **Settlement Currency** (la monnaie de règlement effectif), **Local Currency** (la monnaie du lieu du client ou de l'expert). |
| **Frontières** | Les montants vrais appartiennent aux mécanismes financiers en forme canonique (ISO 4217 — §3.10) ; toute conversion affichée est une présentation datée et sourcée, jamais la vérité (GE-04) ; la lecture métier reste à la Business Platform. |
| **Ce qu'il garantit** | l'expert comprend toujours dans quelle monnaie il lit, gagne et est réglé — sans jamais qu'une conversion se déguise en fait (DT-05 appliqué aux devises). |
| **Ce qu'il ne possède jamais** | un taux de change (mécanisme) ; une conversion silencieuse ; une monnaie par défaut mondiale. |

### 3.4 Region

| | |
|---|---|
| **Mission** | Représenter le lieu — pays, région, indicatif, préférences régionales — comme des données, jamais comme du code. |
| **Responsabilités** | Définir les notions de lieu : pays de l'expert, région d'exercice, indicatif téléphonique, préférences régionales (formats hérités mais surchargeables) — **jamais codées en dur** (GE-12). |
| **Frontières** | Le lieu est une configuration lue par les plateformes ; aucune plateforme ne connaît un pays nommément (GE-11). |
| **Ce qu'il garantit** | ajouter un pays = ajouter une configuration (§3.12) — aucun code ne change. |
| **Ce qu'il ne possède jamais** | une liste fermée de pays ; une logique par pays. |

### 3.5 Time & Time Zone

| | |
|---|---|
| **Mission** | Faire que le temps soit vrai partout — une consultation entre Bamako et Tokyo a une seule vérité temporelle. |
| **Responsabilités** | Définir les notions : l'instant canonique (UTC — §3.10), le fuseau de l'expert, les formats d'affichage (24 h / 12 h selon préférence), l'heure d'été (propriété du fuseau, jamais un cas particulier). **Jamais d'heure locale stockée** : l'heure locale est un affichage. |
| **Frontières** | L'instant vrai appartient aux données canoniques ; le fuseau et le format à la configuration de l'expert ; l'agenda à la Consultation Platform. |
| **Ce qu'il garantit** | deux participants voient chacun leur heure locale du **même** instant — aucun rendez-vous manqué par confusion de fuseau. |
| **Ce qu'il ne possède jamais** | une heure locale comme vérité ; un fuseau par défaut mondial. |

### 3.6 Calendar

| | |
|---|---|
| **Mission** | Faire que le calendrier de l'expert soit le sien. |
| **Responsabilités** | Définir les notions adaptables : premier jour de semaine, week-end (variable selon les pays), jours fériés (par configuration régionale), calendriers régionaux en présentation. **Toujours adaptables** — jamais présumés. |
| **Frontières** | Les dates vraies restent canoniques (ISO 8601) ; l'agenda et les disponibilités appartiennent à leurs plateformes ; le calendrier configure la présentation et les repères. |
| **Ce qu'il garantit** | le week-end d'un expert aux Émirats n'est pas celui d'un expert en France — et Mentora le sait par configuration. |
| **Ce qu'il ne possède jamais** | un « lundi premier jour » universel ; des fériés codés en dur. |

### 3.7 Numbers & Formats

| | |
|---|---|
| **Mission** | Faire que les nombres se lisent dans les conventions de l'expert. |
| **Responsabilités** | Définir les notions : formats numériques, séparateurs (décimal, milliers), décimales (variables selon la devise), pourcentages — **jamais codés** : toujours dérivés des préférences régionales, surchargeables par l'expert. |
| **Frontières** | La valeur vraie est canonique ; le format est une présentation (GE-06) ; la lisibilité des nombres reste opposable (Readability). |
| **Ce qu'il garantit** | un montant se lit sans erreur d'interprétation, quel que soit le pays — jamais une virgule prise pour un point. |
| **Ce qu'il ne possède jamais** | un format universel ; une troncature qui altère la valeur. |

### 3.8 Cultural Neutrality

| | |
|---|---|
| **Mission** | Faire que rien dans Mentora ne présuppose une culture. |
| **Responsabilités** | Tenir l'exigence sur toutes les productions P11 : **aucune couleur, aucune icône, aucune illustration, aucun texte ne suppose une culture** — pas de métaphore locale, pas de geste signifiant dans un seul monde, pas de symbole à double lecture. Le système reste neutre ; la chaleur vient du métier, pas du folklore. |
| **Frontières** | La neutralité s'impose aux systèmes Color/Typography/Iconography/Illustration (opposable) ; elle ne stérilise pas le contenu de l'expert, qui reste sa parole. |
| **Ce qu'il garantit** | aucun expert ne se sent étranger chez Mentora ; aucun symbole n'offense ni n'exclut. |
| **Ce qu'il ne possède jamais** | une culture de référence ; un droit de censure sur le contenu des experts. |

### 3.9 Direction (LTR / RTL)

| | |
|---|---|
| **Mission** | Faire de LTR et RTL des **citoyens de première classe** — jamais une adaptation tardive. |
| **Responsabilités** | Définir l'exigence : toute surface, toute hiérarchie, toute navigation et tout composant se conçoivent bidirectionnels dès la naissance ; l'ordre de sens est logique (début → fin), jamais géométrique (gauche → droite) ; les rôles P11 s'expriment dans les deux directions sans perte. |
| **Frontières** | La direction est une présentation dérivée de la langue d'interface ; les invariants (hiérarchie, priorités, profondeurs) ne changent pas avec elle (GE-07). |
| **Ce qu'il garantit** | le jour où une langue RTL s'active, rien ne se refond : tout était prêt. |
| **Ce qu'il ne possède jamais** | un « mode RTL » rattrapé ; une surface conçue en gauche-droite absolu. |

### 3.10 Canonical Data

| | |
|---|---|
| **Mission** | Une seule vérité pour chaque donnée — la forme canonique. |
| **Responsabilités** | Tenir le principe fondamental : **toutes les données sont stockées dans leur forme canonique ; l'affichage dépend uniquement des préférences de l'expert.** Les canons officiels : **UTC** pour les instants, **ISO 8601** pour les dates, **ISO 4217** pour les devises, **Unicode** pour tout texte (GE-08). **Jamais de vérité locale.** |
| **Frontières** | Le canon appartient aux mécanismes de données ; la présentation aux piliers d'affichage ; ce pilier fixe la loi, pas le stockage. |
| **Ce qu'il garantit** | une donnée a le même sens à Bamako et à Séoul ; aucune ambiguïté ne dort dans le stockage (fail closed informationnel). |
| **Ce qu'il ne possède jamais** | une donnée formatée comme vérité ; un canon par pays. |

### 3.11 Regulatory Adaptation

| | |
|---|---|
| **Mission** | Faire que la conformité locale se branche — sans modifier les plateformes. |
| **Responsabilités** | Définir l'exigence d'accueil : TVA, GST, Sales Tax, retenue à la source, règles de facturation, obligations de conformité — chacune arrive comme **configuration réglementaire** derrière les mécanismes financiers ; les plateformes métier n'en connaissent que les faits publiés (un montant, sa lecture). |
| **Frontières** | Les règles fiscales appartiennent aux mécanismes (Financial/Payment) ; la Business Platform les lit ; aucune règle réglementaire ne traverse dans une plateforme (BN-08 étendu). |
| **Ce qu'il garantit** | ouvrir un pays à la fiscalité différente n'ouvre pas un chantier d'architecture. |
| **Ce qu'il ne possède jamais** | un calcul fiscal ; une règle codée dans une plateforme. |

### 3.12 Future Countries

| | |
|---|---|
| **Mission** | Faire de l'ouverture d'un pays un événement de configuration — jamais d'architecture. |
| **Responsabilités** | Porter le protocole d'ouverture : un nouveau pays déclare sa configuration (langues, monnaies, fuseau(x), calendrier, formats, direction, réglementation) — **et rien d'autre**. L'arrivée d'un pays n'ajoute jamais une nouvelle architecture (GE-12). |
| **Frontières** | Si un pays exige davantage qu'une configuration, c'est un signal de révision de cette fondation — jamais un cas particulier dans le code. |
| **Ce qu'il garantit** | le centième pays coûte ce qu'a coûté le deuxième : une configuration. |
| **Ce qu'il ne possède jamais** | un pays « spécial » ; une dérogation architecturale. |

### 3.13 Experience Personalization

| | |
|---|---|
| **Mission** | Définir toutes les préférences personnelles qui modifient **uniquement la présentation** de l'expérience — sans jamais modifier la logique métier. |
| **Responsabilités** | Posséder le registre des préférences personnelles : les six langues (application, professionnelle, consultations, résumés IA, recommandations IA, notifications — §3.2), les quatre devises (Business, affichage, règlement, locale — §3.3), le fuseau horaire, le calendrier, les formats numériques, le format des dates, le format des heures, le premier jour de semaine, **l'apparence et les préférences visuelles** (sous-domaine Appearance, §5). |
| **Frontières** | Ce pilier définit les règles ; l'Account Platform stocke les préférences (aucune modification de frontière) ; le Design System les matérialise (Appearance Tokens). Il ne possède jamais : les plateformes métier, les paiements, les consultations, la réputation, les recommandations IA. |
| **Ce qu'il garantit** | chaque expert vit Mentora dans sa langue, sa devise, son heure, son apparence — et retrouve exactement la même logique métier que tous les autres. |
| **Ce qu'il ne possède jamais** | une vérité métier (GE-19) ; une préférence qui en modifie implicitement une autre (GE-16). |

**Principe officiel** :

> **« L'expérience appartient à l'expert. Le métier appartient à Mentora. »**

---

## 4. Les règles

| Règle | Énoncé |
|---|---|
| GE-01 | **Mentora est International by Design.** |
| GE-02 | **Une fonctionnalité ne dépend jamais d'un pays.** |
| GE-03 | **Une langue ne modifie jamais la logique.** |
| GE-04 | **Une devise ne modifie jamais la vérité** : la conversion est une présentation datée, jamais un fait. |
| GE-05 | **Toutes les données sont canoniques** (UTC, ISO 8601, ISO 4217, Unicode). |
| GE-06 | **La localisation est une présentation.** |
| GE-07 | **LTR et RTL sont équivalents** — citoyens de première classe. |
| GE-08 | **Unicode est obligatoire** — tout texte, tout nom, toute saisie. |
| GE-09 | **Aucune hypothèse culturelle** — dans aucune production, à aucun niveau. |
| GE-10 | **Les adaptations sont configurées** — jamais codées. |
| GE-11 | **Les plateformes ignorent les pays.** |
| GE-12 | **Les pays configurent.** Ils n'architecturent jamais. |
| GE-13 | Les six notions de langue (§3.2) et les quatre notions de monnaie (§3.3) sont indépendantes — toute fusion est une violation. |
| GE-14 | Jamais d'heure locale stockée ; l'heure locale est un affichage (§3.5). |
| GE-15 | Un manque international découvert dans un document aval remonte en révision — jamais comblé par un cas particulier (DSM-03 étendu). |
| GE-16 | **Toutes les préférences personnelles sont indépendantes les unes des autres. Aucune préférence n'en modifie implicitement une autre.** |
| GE-17 | **Changer la langue ne change jamais : la devise, le calendrier, le fuseau, l'apparence.** |
| GE-18 | **Changer le thème ne change jamais : les couleurs sémantiques, les niveaux de protection, les responsabilités, les plateformes.** |
| GE-19 | **La personnalisation ne possède jamais une vérité métier. Elle ne modifie que la représentation.** |

Ces règles sont **perpétuelles** ; la liste s'enrichit par révision de ce document *(GE-16 → GE-19 ajoutées par la révision post-audit P11.8A)*.

---

## 5. Le sous-domaine Appearance

Sous-domaine officiel du pilier Experience Personalization. **Propriété : l'Account Platform le stocke (aucune modification de frontière — il vit sous Professional Preferences) ; cette fondation en définit les règles ; le Design System le matérialise (Appearance Tokens, P11.8 §3.11).**

| Préférence | Valeurs officielles | Règle |
|---|---|---|
| **Theme Mode** | Light, Dark, System | des jeux de valeurs de Tokens — jamais un changement de signification (GE-18, CSX du Color System) |
| **Accent Color** | **Mentora Emerald — la couleur officielle de Mentora** ; plusieurs accents futurs prévus | un accent est un jeu de valeurs des rôles identitaires — le Design System ne se modifie pas pour un accent nouveau |
| **Density** | Compact, Standard, Comfortable | des déclinaisons des lois du Spacing — la densité maximale d'attention (≤ 6) et les espaces d'accessibilité restent opposables |
| **Font Scale** | Small, Standard, Large, Extra Large | l'adaptabilité sans casse de hiérarchie (TSA-06) — opposable |
| **Motion Preference** | Full, Reduced, None | les intentions du mouvement demeurent ; seule leur expression s'atténue — l'information portée par le mouvement reste disponible autrement (AFI-04) |
| **Contrast** | Standard, High Contrast | des variantes de valeurs sous CSA-04 — jamais un mode à part (AFV-01) |
| **Reading Comfort** | extension future : Focus Reading, Dyslexia Friendly, Low Vision | prévu **sans modification d'architecture** : des jeux de valeurs supplémentaires sous les mêmes rôles |

| Règle | Énoncé |
|---|---|
| GEA-01 | Toute préférence d'apparence est un **jeu de valeurs de Tokens** — jamais une signification nouvelle, jamais une logique. |
| GEA-02 | Les préférences d'apparence respectent GE-16 (indépendantes) et GE-18 (le thème ne change jamais le sens). |
| GEA-03 | Une nouvelle préférence d'apparence s'ajoute par révision de cette fondation, puis reçoit ses Tokens — jamais l'inverse (l'ordre Future Tokens). |

---

## 6. Mobile First

| Règle | Énoncé |
|---|---|
| GEMF-01 | **Le Mobile reste la référence mondiale** : dans chaque pays, l'expérience naît sur téléphone, dans la main (MSMF-07, RSMF-01). |
| GEMF-02 | **L'internationalisation ne change jamais Mobile First** : une langue, une direction ou un format ne dégrade jamais l'usage à une main, la lecture verticale ni la hiérarchie. |
| GEMF-03 | Les contextes réels du monde entier sont des contextes de conception (AFC) : connexion dégradée, appareils modestes, plein soleil — le contexte le plus défavorable reste le cas nominal. |

---

## 7. Gouvernance

| Règle | Énoncé |
|---|---|
| GEG-01 | **Toutes les futures fondations devront citer cette Global Experience Foundation** — comme elles citent l'Accessibility Foundation. |
| GEG-02 | Cette fondation est **opposable** aux descendants P11 (réalisés et à venir) et à toute implémentation : un conflit se résout en sa faveur ou par révision documentaire explicite. |
| GEG-03 | Les documents P11 déjà réalisés (Color, Typography) lui sont conformes par construction (rôles sémantiques sans culture, significations sans pays) ; toute non-conformité découverte se traite par GE-15. |
| GEG-04 | **Toute violation deviendra un balayage exécutable** dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise (chaînes codées en dur, formats figés, hypothèses de fuseau : détectables et interdits). |

---

## 8. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux pays | le protocole Future Countries (§3.12) : une configuration |
| Nouvelles monnaies | une entrée ISO 4217 de plus ; les quatre notions (§3.3) inchangées |
| Nouveaux calendriers | une présentation calendaire de plus (§3.6) ; les dates canoniques inchangées |
| Nouvelles langues | une configuration de plus par notion de langue (§3.2) ; la direction prête (§3.9) |
| Nouvelles réglementations | une configuration réglementaire de plus (§3.11) ; les plateformes intactes |
| Nouveaux systèmes de paiement | un mécanisme de plus derrière la Payment Platform ; la Settlement Currency le décrit |

| Règle | Énoncé |
|---|---|
| GEX-01 | Les treize piliers (§3) et les règles GE (§4) sont l'invariant décennal *(révisé post-audit P11.8A : +Experience Personalization, +GE-16→19)*. |
| GEX-02 | **Aucune extension géographique, monétaire, linguistique ou réglementaire ne modifie l'architecture.** |
| GEX-03 | Aucune extension ne peut affaiblir la neutralité culturelle (§3.8) ni les données canoniques (§3.10). |

---

## 9. Gouvernance du document

- Ce document est la **fondation transversale opposable** de l'internationalisation de Mentora — au même niveau d'exigence que P9, P10 et P11.
- Toute vague d'implémentation cite le pilier et les règles (GEV/GE/GEMF/GEG/GEX) qu'elle réalise ou respecte.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10 et l'Accessibility Foundation, puis **cette fondation**, puis P11 et ses descendants, puis les implémentations.
