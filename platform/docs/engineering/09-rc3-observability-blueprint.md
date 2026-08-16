# RC-3 — Observability Blueprint (Phase 2A.5)

> **Statut : documentaire.** L'observabilité officielle des trois Séquences et
> des actes d'outillage — organisée, jamais légiférée. Principe (F5.3, verbatim) :
> « *l'Observabilité décrit le système ; elle ne le gouverne jamais.* »

## 0. Les quatre objets d'émission (F5.3 §2 — la grille de tout ce document)

| Objet | Définition (verbatim) | Statut |
|---|---|---|
| **Journal** | « *réservé, applicatif, les pas des Séquences (F4.1) — **probant*** » | jamais échantillonné (F5.3 §9) |
| **Log** | « *le nom officiel de l'émission technique (Runtime, adapters, moteurs) — **perdable et borné*** » | échantillonnable |
| **Enveloppe** | « *le transport (F4.3)* » | portée par le Bus |
| **Relevé d'accès** | « *trace d'accès aux données protégées : enregistrement **probant*** » (régi par F5.4) | ne passe PAS le pardon |

**Lois communes** (F5.3 §2) : « *aucune matière, aucun secret (P7), corrélation
portée quand elle existe, horodatage de la couche émettrice.* » Interdits
partout : contenu métier, secrets, `SessionId` en télémétrie (réservé I&A),
échantillonner le probant. Les métriques « *ne sont jamais consultées par une
Séquence — aucun port de métrique n'existe dans la Séquence* » (O-3). La Trace
est « *une ombre échantillonnable* » (O-4) — l'audit se refait sans elle.

## 1. Séquence de Commande (10 pas) — qui émet quoi

| Pas | Journal (probant — implémenté 1C-2) | Log (technique) | Métrique dérivée | Trace |
|---|---|---|---|---|
| 1 Réception | record `advanced`/`exception` (code de violation en note) | — | taux d'exceptions par code | span racine (si échantillonné) |
| 2-3 Injections | records `advanced` (l'instant injecté date les records suivants) | — | — | attributs techniques |
| 4 Chargement | `advanced`/`failure` | l'adapter logue SES incidents moteur | latence (Timer adapter) | span enfant adapter |
| 5 Validités | `advanced`/`refused`/`failure` | — | taux de refus **par Reason** (« *métriques métier gratuites* », F4.1 §9) | — |
| 6 Acte | `advanced`/`refused` | — | idem | — |
| 7 RetourRefus | `refused` (la Reason en note — jamais la matière) | — | idem | — |
| 8 Rétention | `advanced`/`refused` (clé R-A)/`failure` | logs moteur adapter | latence TX ; taux de conflits de version | span adapter |
| 9 Publication | `advanced` (structurel) | — | — | — |
| 10 Réponse+Journal | `advanced`/`abandoned` (budget épuisé — témoin obligatoire) | — | taux d'abandons | fin du span |

## 2. Séquence de Lecture (6 pas — implémentée 1C-4)

Réception (`exception` possible) → Identité → **R-C** (`refused` avec la
Reason — le refus de droit est journalisé, jamais silencieux) → Lecture
(`refused` absence / `failure` — le record SANS horodatage : les six pas
n'ont pas de pas de temps, A-6 interdit l'horloge ambiante ; l'adapter du
puits peut estampiller côté stockage) → Réponse → Journal. Métriques : taux
de refus R-C par Reason, latence de lecture (adapter). Trace : span par
lecture, échantillonnable.

## 3. Séquence de Réaction (6 pas — implémentée 1C-5)

RéceptionDuFait (`duplicate` = NORMAL, métrique de re-livraison, niveau info)
→ Injections (UN instant) → Réaction (pure — rien à observer dedans : le
déterminisme EST le test, P-7) → RétentionAtomique (`failure` retryable) →
Relais (structurel ; le relais EXÉCUTABLE logue et mesure SES livraisons :
tentatives sur l'ENVELOPPE, jamais dans une position — P-4) → Journal
(`abandoned` au budget, témoin). Métrique de santé PM (F4.2 §12, verbatim) :
« *attentes échues non traitées — LA métrique de santé* » (future, avec l'Échéancier).

## 4. Boot (F5.1)

Le Boot « *démontre et ne sert jamais* » (R-5). Observé : le RAPPORT de
validation (toutes les preuves, agrégées, puis mort unique si échec) — émis
en Log technique structuré + verdict de santé `startup`. Interdits : servir
pendant la démonstration ; démarrer à moitié. Métriques : durée de boot,
compte de preuves. La machine à neuf états émet un Log par transition
(« *toute transition journalisée avec sa cause* » — au sens machine ; le mot
Journal reste réservé à l'applicatif).

## 5. Replay & Migration (outillage)

- **Replay** (F4.3 §8) : « *un acte d'outillage **journalisé**, à cible
  nommée… refusable par la cible* » — l'acte porte : qui, quelle cible,
  quelle plage, le refus éventuel. Il re-porte, ne crée rien.
- **Migration** (S-7) : exécutée par l'espèce Migration ; chaque application/
  renversement = Migration Record (RC-1 §9) + Log technique ; jamais un sens.
- **Quarantaine** (M-8) : parcage = Log + **Signal d'exploitation** obligatoire
  (« *rien ne meurt sans témoin* ») + métrique de profondeur de quarantaine.

## 6. Santé (R-6) & Dashboards (O-8)

Readiness = « *les trois Séquences sont exécutables ici* » ; Liveness =
le processus ; ni l'une ni l'autre ne jugent le métier (un taux de refus
n'est pas un signal de mort). Les tableaux : « *des vues composées de
projections **d'exploitation*** » (F5.3 §7) — le test du pardon à l'écran
(« *le tableau disparaît, le métier continue* ») ; « *aucune curation d'écran
ne devient une vérité* ». **Distinction tenue** : les projections
d'EXPLOITATION (dashboards, O-8) sont licites et à côté ; les projections
MÉTIER d'Agreement restent sous STOP 1C-6 — le flux « → Projection →
Dashboard » du mandat désigne les premières, jamais les secondes.

## 7. La hiérarchie de la preuve (F5.3 §10 — le mot de la fin)

« *Ce qui fait foi = les registres, les faits, les polices, le Journal
applicatif. L'observabilité (Logs, métriques, traces, tableaux, alertes) est
perdable, bornée, **jamais probante pour le métier**.* » Aucun flux de ce
document ne crée un pipeline nouveau : tout est lecture des trois Séquences
et des actes d'outillage existants.
