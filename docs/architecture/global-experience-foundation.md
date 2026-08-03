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

## 3. Les douze piliers

Douze piliers. Toute règle d'internationalisation appartient à exactement un pilier.

### 3.1 International by Design

| | |
|---|---|
| **Mission** | Faire que l'international soit la conception — jamais l'adaptation. |
| **Responsabilités** | Tenir l'invariant fondateur : Mentora n'est jamais conçu pour un pays ; **un pays est une configuration, jamais une architecture** ; toute conception se vérifie contre plusieurs pays dès sa naissance. |
| **Frontières** | Ce pilier est le juge de paix des onze autres — il n'a pas de territoire propre : il a droit de regard sur tout (le pendant international de l'Inclusion). |
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

Ces règles sont **perpétuelles** ; la liste s'enrichit par révision de ce document.

---

## 5. Mobile First

| Règle | Énoncé |
|---|---|
| GEMF-01 | **Le Mobile reste la référence mondiale** : dans chaque pays, l'expérience naît sur téléphone, dans la main (MSMF-07, RSMF-01). |
| GEMF-02 | **L'internationalisation ne change jamais Mobile First** : une langue, une direction ou un format ne dégrade jamais l'usage à une main, la lecture verticale ni la hiérarchie. |
| GEMF-03 | Les contextes réels du monde entier sont des contextes de conception (AFC) : connexion dégradée, appareils modestes, plein soleil — le contexte le plus défavorable reste le cas nominal. |

---

## 6. Gouvernance

| Règle | Énoncé |
|---|---|
| GEG-01 | **Toutes les futures fondations devront citer cette Global Experience Foundation** — comme elles citent l'Accessibility Foundation. |
| GEG-02 | Cette fondation est **opposable** aux descendants P11 (réalisés et à venir) et à toute implémentation : un conflit se résout en sa faveur ou par révision documentaire explicite. |
| GEG-03 | Les documents P11 déjà réalisés (Color, Typography) lui sont conformes par construction (rôles sémantiques sans culture, significations sans pays) ; toute non-conformité découverte se traite par GE-15. |
| GEG-04 | **Toute violation deviendra un balayage exécutable** dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise (chaînes codées en dur, formats figés, hypothèses de fuseau : détectables et interdits). |

---

## 7. Extensibilité — pensé pour dix ans

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
| GEX-01 | Les douze piliers (§3) et les règles GE (§4) sont l'invariant décennal. |
| GEX-02 | **Aucune extension géographique, monétaire, linguistique ou réglementaire ne modifie l'architecture.** |
| GEX-03 | Aucune extension ne peut affaiblir la neutralité culturelle (§3.8) ni les données canoniques (§3.10). |

---

## 8. Gouvernance du document

- Ce document est la **fondation transversale opposable** de l'internationalisation de Mentora — au même niveau d'exigence que P9, P10 et P11.
- Toute vague d'implémentation cite le pilier et les règles (GEV/GE/GEMF/GEG/GEX) qu'elle réalise ou respecte.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10 et l'Accessibility Foundation, puis **cette fondation**, puis P11 et ses descendants, puis les implémentations.
