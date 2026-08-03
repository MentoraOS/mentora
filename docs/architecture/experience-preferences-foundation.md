# EXPERIENCE PREFERENCES FOUNDATION

**Statut** : Fondation transversale — le **contrat officiel des préférences d'expérience de Mentora**. Elle ne remplace aucun document existant ; elle **relie** la [Global Experience Foundation](global-experience-foundation.md), l'[Account Platform Foundation](account-platform-foundation.md), le [Design System](mentora-design-system-foundation.md), le [Design Tokens System](design-tokens-system.md) et le futur Flutter Design Kit. Elle ne crée aucun système métier : elle formalise **le cycle de vie officiel des préférences utilisateur**. Les frontières existantes demeurent inchangées.
**Portée** : Architecture fonctionnelle uniquement. Aucune implémentation, aucun code, aucun Flutter, aucun Token concret.
**Filiation** : transversale — elle s'insère dans la hiérarchie existante sans la modifier : P9 → P10 → Accessibility (opposable) → Global Experience (opposable) → **cette fondation (transversale, reliante)** → P11 → implémentations. En cas de conflit, la hiérarchie existante prévaut ; cette fondation n'arbitre jamais contre elle.
**Question unique à laquelle elle répond** :

> **« Comment une préférence utilisateur traverse-t-elle toute l'architecture sans jamais modifier le métier ? »**

**Continuité (MSD-02)** : une préférence suit l'expert à travers toute interruption et tout changement d'appareil — le cycle de vie (§3) est la continuité des préférences.

---

## 1. Mission

**Principe fondateur** :

> **« Les préférences appartiennent à l'expert. Le métier appartient à Mentora. »**

**Mission en une phrase** : formaliser le cycle de vie complet d'une préférence — définition → propriétaire → persistance → synchronisation → résolution → matérialisation → gouvernance → évolution — pour que chaque préférence traverse l'architecture par un seul chemin officiel, sans jamais toucher le métier.

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| EPV-01 | Une préférence est **une intention de présentation** — jamais une donnée métier, jamais une implémentation. |
| EPV-02 | Toute préférence suit **le même cycle de vie** (§3) : il n'existe qu'un chemin, du choix de l'expert à sa matérialisation. |
| EPV-03 | Le cycle est **sans décision implicite** : chaque étape est déclarée, chaque résolution est une règle explicite (§4.5). |
| EPV-04 | **L'expérience évolue. Le métier demeure** — le principe final, opposé à toute dérive. |

---

## 3. Le cycle de vie officiel

```
Définition (Global Experience — la règle et l'intention)
   ↓
Propriétaire (un seul — Account Platform pour le stockage)
   ↓
Persistance (survit au redémarrage, à l'appareil, à la restauration)
   ↓
Synchronisation (suit l'expert, jamais l'appareil ; conflits résolus explicitement)
   ↓
Résolution (l'ordre de priorité officiel choisit la valeur effective)
   ↓
Matérialisation (Design System — exclusivement par les Tokens)
   ↓
Gouvernance (origine, traçabilité, réversibilité, balayages)
   ↓
Évolution (toute nouvelle préférence entre par ce même cycle)
```

Aucune préférence ne saute une étape. Aucune étape n'a deux propriétaires.

---

## 4. Les dix piliers

### 4.1 Preference Definition

| | |
|---|---|
| **Mission** | Définir ce qu'est une préférence — officiellement, une fois. |
| **Responsabilités** | Tenir la définition : **une préférence possède une intention. Jamais une implémentation** ; elle naît d'une règle de la Global Experience Foundation (pilier Experience Personalization) ; elle modifie la représentation, jamais la vérité (GE-19). |
| **Frontières** | La définition d'une préférence appartient à la Global Experience Foundation ; ce pilier formalise le format de définition (intention, valeurs officielles, règles), pas le contenu. |
| **Ce qu'il garantit** | aucune préférence floue : chaque préférence a son intention, ses valeurs officielles et sa règle d'origine. |
| **Ce qu'il ne possède jamais** | une préférence improvisée ; une préférence-implémentation (« activer le cache » n'est pas une préférence d'expérience). |

### 4.2 Preference Ownership

| | |
|---|---|
| **Mission** | Garantir qu'une préférence possède **exactement un propriétaire**. |
| **Responsabilités** | Tenir la répartition officielle : les **règles** appartiennent à la Global Experience Foundation ; le **stockage** appartient à l'Account Platform (Professional Preferences / Appearance) ; la **matérialisation** appartient au Design System — trois rôles, chacun unique, jamais confondus. |
| **Frontières** | Aucun propriétaire multiple, aucune ambiguïté : pour chaque question (« qui définit ? qui stocke ? qui matérialise ? »), une seule réponse. |
| **Ce qu'il garantit** | aucune préférence disputée ; aucune préférence orpheline (EP-01, §4.9). |
| **Ce qu'il ne possède jamais** | une copropriété ; une préférence stockée hors Account Platform. |

### 4.3 Preference Persistence

| | |
|---|---|
| **Mission** | Faire qu'une préférence survive — toujours. |
| **Responsabilités** | Définir l'exigence de survie : une préférence survit **au redémarrage, au changement d'appareil, au changement de plateforme, à la restauration** — sans modifier le métier ; la forme stockée est canonique (GE-05 appliqué aux préférences). |
| **Frontières** | Le mécanisme de stockage appartient aux systèmes derrière l'Account Platform (Settings) ; ce pilier fixe l'exigence, jamais le mécanisme. |
| **Ce qu'il garantit** | l'expert ne reconfigure jamais ce qu'il a déjà choisi (NCO-01 appliqué aux préférences). |
| **Ce qu'il ne possède jamais** | une préférence volatile ; une persistance qui embarque une donnée métier. |

### 4.4 Preference Synchronization

| | |
|---|---|
| **Mission** | Faire qu'une préférence **suive l'expert. Jamais l'appareil.** |
| **Responsabilités** | Définir la synchronisation : le même expert retrouve les mêmes préférences sur tous ses appareils (Multi Device du Responsive) ; **les conflits sont résolus selon des règles explicites — jamais implicitement** : le choix le plus récent de l'expert prévaut ; un conflit indécidable se présente à l'expert, jamais tranché en silence. |
| **Frontières** | Le transport technique appartient aux systèmes ; l'exception locale existe et se déclare : une préférence peut avoir une **déclinaison par appareil uniquement si sa définition le prévoit explicitement** (ex. la densité peut différer entre téléphone et tablette) — jamais par accident. |
| **Ce qu'il garantit** | changer d'appareil ne change pas l'expérience choisie (RSCO, GEV-03). |
| **Ce qu'il ne possède jamais** | une résolution silencieuse de conflit ; une préférence prisonnière d'un appareil. |

### 4.5 Preference Resolution

| | |
|---|---|
| **Mission** | Choisir la valeur effectivement utilisée — par un ordre officiel, jamais par accident. |
| **Responsabilités** | Définir l'ordre de priorité officiel de résolution : **1. le choix explicite de l'expert** (toujours premier — PE-04) ; **2. l'héritage déclaré** (une préférence régionale héritée de Pays/Région, surchargeable — GE §3.4) ; **3. le contexte système** (uniquement quand l'expert a choisi « System » — le choix de suivre le système est lui-même un choix explicite) ; **4. le défaut Mentora** (fail-safe : accessible, neutre, mondial — jamais un défaut de pays, GEV-01). **Aucune décision implicite.** |
| **Frontières** | La résolution choisit une valeur de présentation ; elle ne touche jamais une donnée canonique. |
| **Ce qu'il garantit** | pour toute préférence, à tout instant, la valeur effective est explicable en une phrase : « parce que l'expert / l'héritage / le système / le défaut ». |
| **Ce qu'il ne possède jamais** | un ordre variable ; une exception par préférence non déclarée dans sa définition. |

### 4.6 Preference Presentation

| | |
|---|---|
| **Mission** | Borner l'effet d'une préférence — la présentation, rien d'autre. |
| **Responsabilités** | Tenir la frontière d'effet : une préférence ne change que **l'affichage, la présentation, l'expérience** ; jamais **les données, les plateformes, les responsabilités, les décisions métier** (GE-06, GE-18, GE-19). |
| **Frontières** | La vérité reste canonique (GE-05) ; la logique reste aux plateformes ; les significations restent aux systèmes P11 (un thème = des valeurs, jamais des sens). |
| **Ce qu'il garantit** | deux experts aux préférences opposées vivent la même logique métier, les mêmes protections, les mêmes vérités. |
| **Ce qu'il ne possède jamais** | un effet métier ; une préférence qui filtre une information due (DT-01). |

### 4.7 Preference Accessibility

| | |
|---|---|
| **Mission** | Garantir qu'aucune préférence ne réduit l'accessibilité. |
| **Responsabilités** | Tenir l'exigence opposable : toute préférence reste compatible avec l'Accessibility Foundation ; les préférences d'accessibilité (Font Scale, Contrast, Motion, Reading Comfort) **augmentent** l'accès — aucune combinaison de préférences ne peut descendre sous les seuils opposables (AFR-02) ; le défaut Mentora (§4.5) est accessible par construction. |
| **Frontières** | Les seuils appartiennent à l'Accessibility Foundation et aux Tokens ; ce pilier interdit leur contournement par préférence. |
| **Ce qu'il garantit** | aucun réglage ne peut rendre Mentora inutilisable par celui qui l'a réglé — ni par un autre contexte (AFC). |
| **Ce qu'il ne possède jamais** | une préférence « esthétique » qui prime l'accessibilité ; un mode dégradé caché. |

### 4.8 Preference Security

| | |
|---|---|
| **Mission** | Protéger les préférences — et protéger Mentora des préférences. |
| **Responsabilités** | Définir la double protection : les **préférences sensibles** (langues des contenus professionnels, région, devises d'affichage) sont des données personnelles protégées (Privacy de l'Account Platform) ; et **aucune préférence ne peut affaiblir la sécurité, la confidentialité ou les protections métier** — les niveaux IPR, les consentements, les alertes non écartables sont hors de portée de toute préférence (GE-18). |
| **Frontières** | Les mécanismes de sécurité appartiennent aux systèmes Security ; la réversibilité s'arrête où la sécurité commence (EP-09). |
| **Ce qu'il garantit** | personnaliser n'expose jamais ; personnaliser ne désarme jamais. |
| **Ce qu'il ne possède jamais** | une préférence qui atténue une protection ; une préférence qui masque une alerte de sécurité. |

### 4.9 Preference Governance

| | |
|---|---|
| **Mission** | Faire que toute préférence soit gouvernée — de sa naissance à sa fin. |
| **Responsabilités** | Tenir le registre : toute préférence **possède une origine** (sa règle GE), **un propriétaire** (§4.2), **une persistance** (§4.3), **une matérialisation** (ses Tokens), **une traçabilité** (qui a changé quoi, quand — sans contenu métier, cohérent avec l'observabilité sans données utilisateur). **Une préférence orpheline est interdite.** |
| **Frontières** | La gouvernance décrit et vérifie ; elle ne crée pas de préférence. |
| **Ce qu'il garantit** | pour toute préférence, les cinq questions (origine, propriétaire, persistance, matérialisation, trace) ont chacune une réponse — vérifiable. |
| **Ce qu'il ne possède jamais** | une préférence non traçable ; une trace qui embarque un contenu. |

### 4.10 Future Preferences

| | |
|---|---|
| **Mission** | Accueillir les préférences de demain — sans modifier l'architecture. |
| **Responsabilités** | Porter le protocole : une nouvelle préférence naît d'une règle GE (révision), reçoit son propriétaire, sa persistance, sa résolution, ses Tokens — **toute nouvelle préférence suit obligatoirement le même cycle de vie** (EP-10) ; Reading Comfort, futurs thèmes, futures modalités entrent par cette porte. |
| **Frontières** | Une préférence qui ne peut pas suivre le cycle n'est pas une préférence d'expérience — c'est un signal de révision, jamais une exception. |
| **Ce qu'il garantit** | la centième préférence traverse l'architecture comme la première. |
| **Ce qu'il ne possède jamais** | une préférence en réserve ; un raccourci de cycle. |

---

## 5. Relations officielles

| Fondation / Système | Rôle dans le cycle | Ce qui ne change pas |
|---|---|---|
| **Global Experience Foundation** | **définit les règles** (internationales et de personnalisation — pilier 3.13, GE-16→19, GEA) | ses frontières ; son opposabilité |
| **Account Platform** | **stocke les préférences** (Professional Preferences / Appearance ; organisation des Paramètres §12) | ses 11 domaines ; aucune frontière déplacée |
| **Design System** | **définit leur langage** (rôles, lois, contrats — les significations stables sous les préférences) | ses invariants ; GE-18 |
| **Design Tokens** | **les matérialisent sémantiquement** (Appearance Tokens §3.11 ; jeux de valeurs sous noms stables) | DTV, DTD ; le registre C-01 |
| **Flutter Design Kit** | **les implémente** — exclusivement à travers les Tokens (DTD-06) | il ne définit, ne modifie, ne renomme rien |

**Le métier n'est jamais impacté** : aucune plateforme métier n'apparaît dans ce tableau — c'est le contrat.

---

## 6. Exemples officiels — le pipeline unique

Toutes les préférences suivent **exactement le même pipeline** :

| Préférence | Définition (GE) | Propriétaire du stockage | Résolution | Matérialisation |
|---|---|---|---|---|
| **Theme** | GE §5 (Light/Dark/System) | Account — Appearance | choix expert > « System » choisi > défaut | Appearance Tokens (jeux de valeurs, GE-18) |
| **Accent Color** | GE §5 (Mentora Emerald + futurs) | Account — Appearance | choix expert > défaut officiel | jeux de valeurs des rôles identitaires |
| **Font Scale** | GE §5 (Small→Extra Large) | Account — Appearance | choix expert > défaut | Tokens sous TSA-06 (opposable) |
| **Motion** | GE §5 (Full/Reduced/None) | Account — Appearance | choix expert > contexte système déclaré > défaut | expression atténuée, intentions conservées |
| **Langue** (×6 notions) | GE §3.2 | Account — Professional Preferences | choix expert par notion > héritage région > défaut neutre | présentation ; la logique jamais (GE-03) |
| **Fuseau horaire** | GE §3.5 | Account — Professional Preferences | choix expert > héritage région | affichage ; l'instant reste UTC (GE-14) |
| **Devise** (×4 notions) | GE §3.3 | Account — Professional Preferences | choix expert par notion > héritage région | présentation datée ; la vérité jamais (GE-04) |
| **Calendrier** | GE §3.6 | Account — Professional Preferences | choix expert > héritage région | présentation ; les dates restent ISO 8601 |

Huit préférences, un seul pipeline : **définition GE → stockage Account → résolution officielle → matérialisation Tokens.** Aucune exception.

---

## 7. Les règles d'architecture

| Règle | Énoncé |
|---|---|
| EP-01 | **Toute préférence possède un propriétaire unique** (par rôle : règles GE, stockage Account, matérialisation Design System). |
| EP-02 | **Une préférence ne modifie jamais une règle métier.** |
| EP-03 | **Une préférence ne possède jamais une plateforme.** |
| EP-04 | **Une préférence suit toujours l'expert. Jamais l'appareil** (les déclinaisons par appareil n'existent que déclarées dans la définition). |
| EP-05 | **Toute préférence est matérialisée exclusivement par le Design System.** |
| EP-06 | **Aucune implémentation ne contourne les Tokens** (DTD-06). |
| EP-07 | **Une préférence reste indépendante des autres sauf règle explicite** (GE-16 ; l'héritage régional est la seule dépendance déclarée — surchargeable). |
| EP-08 | **Toute préférence est traçable** — sans jamais tracer un contenu. |
| EP-09 | **Toute préférence est réversible lorsqu'elle ne touche pas la sécurité** (PE-07). |
| EP-10 | **Toute nouvelle préférence respecte ce cycle de vie** — sans exception, pour toujours. |

Ces règles sont **perpétuelles**.

---

## 8. Mobile First

| Règle | Énoncé |
|---|---|
| EPMF-01 | **Le Mobile demeure la référence** : toute préférence se définit et se règle d'abord sur téléphone. |
| EPMF-02 | **Les préférences suivent l'expert sur tous les appareils** (EP-04). |
| EPMF-03 | **Jamais une préférence spécifique Desktop. Jamais une préférence spécifique Android. Jamais une préférence spécifique iOS** : une préférence est une intention d'expérience — l'appareil et l'OS sont des contextes de matérialisation, jamais des territoires de préférences. |

---

## 9. Gouvernance

Futures règles exécutables — **toutes ces situations devront devenir détectables automatiquement** dès la première vague d'implémentation :

| Violation détectable | Règle violée |
|---|---|
| Préférence sans propriétaire | EP-01, §4.2 |
| Préférence sans persistance | §4.3 |
| Préférence sans Token | EP-05, §4.9 |
| Préférence hors Account Platform | §4.2 |
| Préférence hors Global Experience (sans règle d'origine) | §4.1, §4.9 |
| Préférence non traçable | EP-08 |
| Préférence non réversible (hors sécurité) | EP-09 |
| Résolution implicite ou ordre contourné | §4.5 |
| Préférence à effet métier | EP-02, §4.6 |

| Règle | Énoncé |
|---|---|
| EPG-01 | Une préférence qui viole une ligne du tableau ci-dessus n'entre pas en production — défaut bloquant. |
| EPG-02 | Les balayages se livrent avec le code qui introduit chaque préférence (S-03 de l'audit, généralisé). |

---

## 10. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouveaux appareils | des contextes de matérialisation de plus — le cycle inchangé (EP-04, EPMF-03) |
| Nouveaux thèmes | des jeux de valeurs de plus sous les mêmes Tokens (GEA-01) |
| Nouvelles préférences | le protocole Future Preferences (§4.10) : règle GE → propriétaire → persistance → résolution → Tokens |
| Nouvelles modalités (Voice, Mixed Reality) | les préférences valent par modalité de matérialisation — l'intention est unique, ses expressions multiples |
| Nouveaux systèmes d'affichage | des Implementations de plus, sous DTD — le cycle les ignore |

**Principe final** :

> **« L'expérience évolue. Le métier demeure. »**

| Règle | Énoncé |
|---|---|
| EPX-01 | Les dix piliers (§4) et le cycle de vie (§3) sont l'invariant décennal. |
| EPX-02 | Aucune extension ne peut affaiblir la Preference Accessibility (§4.7) ni la Preference Security (§4.8). |
| EPX-03 | Aucune extension ne modifie jamais une plateforme métier (EP-02, EP-03). |

---

## 11. Gouvernance du document

- Ce document est le **contrat officiel des préférences d'expérience** de Mentora — fondation transversale reliante (P11.G2).
- **Conformité aux fondations opposables** : l'Accessibility Foundation est servie par Preference Accessibility (§4.7 — aucune préférence ne réduit l'accessibilité, le défaut est accessible par construction) ; la Global Experience Foundation est la source de toute définition de préférence (§4.1, §5) — les deux restent opposables à cette fondation comme à tout l'aval.
- Toute vague d'implémentation cite le pilier, l'étape du cycle et les règles (EPV/EP/EPMF/EPG/EPX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit : P9.0 prévaut, puis P10, puis les fondations opposables (Accessibility, Global Experience), puis cette fondation pour le cycle de vie des préférences, puis P11 et ses implémentations.
