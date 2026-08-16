# RC-6 — Runtime Decision Matrix (Phase 2A.5 — clôture)

> **Statut : documentaire — le document de clôture de la Runtime Foundation.**
> Chaque ligne CONSTATE : soit un comportement implémenté dans les lots gelés
> (cité par lot), soit une loi du Corpus (citée). Aucune ligne n'imagine.
> Vocabulaire : RC-4. Codes d'erreur : RC-2. Objets : RC-1. Émissions : RC-3.

## 0. Légende et défauts (valent pour TOUTE ligne, sauf mention contraire)

- **Canal** : `Refus` (Décision métier motivée, VALEUR) · `Exception` (défaut
  d'appelant) · `Failure` (technique, VALEUR) · `—` (issue normale). Jamais
  mélangés (A-7).
- **Défauts implicites** : pas d'impact Boot/Readiness/Liveness/Shutdown ;
  pas d'écriture Outbox/Inbox ; Trace = span échantillonnable si le trafic
  l'est (O-4) ; Métrique = taux dérivé des journaux (O-3) ; Log = côté
  adapter/runtime seulement ; ni Signal ni escalade. Seules les DÉVIATIONS
  sont notées.
- **Journal** : le record probant du pas concerné (A-10) — sans matière, sans
  secret (O-2).
- **Retry** : uniquement technique, borné (M-8), jamais métier.
- Un refus est « *une exécution RÉUSSIE du contrat* » (1C-1) — jamais une erreur.

## 1. Séquence de Commande (comportements constatés — kernel 1C-2, services 1C-3, dispatch 1C-7)

| Situation | Canal | Retry/Abandon | Journal | Déviations & lois |
|---|---|---|---|---|
| Commande valide, exécutée | — (`executed`) | non | les 10 pas `advanced` | **Outbox de faits écrite au pas 8** (A-3) ; le relais publiera (A-4). Loi : A-1→A-10 |
| Commande inconnue (aucun porteur) | Exception (`CONTRACT.UNKNOWN_CONTRACT`) | non | aucun (aucune Séquence n'a démarré — le dispatch n'a pas de journal propre) | Log du gateway ; F4.1 §6 (table fermée) |
| Identité d'acte absente/blanche | Exception (`CONTRACT.FIELD_MISSING` commandId) | non | aucun | le Dispatch « exige l'identité d'acte » AVANT de router (F4.1 §3/§6) |
| Payload invalide / violation de contrat | Exception (codes CONTRACT.*) | non | record `exception` au pas 1, fin | « malformé → Exception, fin » ; lecteur tolérant V-2 (champ inconnu ≠ violation) |
| Refus métier (validités, acte, machine) | **Refus** (Reason de l'union 1B) | non — jamais | `refused` + RetourRefus + Journal final ; **ni rétention, ni fait, ni Publication** | pas 7 ; A-4 (la publication LIT la rétention) |
| Unité inconnue (Identifier inhabité) | **Refus** `TransitionUnavailable` | non | idem | 1C-3 : la machine n'offre aucune transition depuis le néant ; motivé, jamais silence (F2.6) |
| Unité en état terminal | **Refus** `TransitionUnavailable` | non | idem | R-B : re-tenter = nouvelle unité à provenance citée |
| Double naissance (même Identifier) | **Refus** `TransitionUnavailable` | non | idem | R-B (1C-3) ; à 2A-2 : unique(AggregementId) le produit structurellement |
| Clé R-A violée à la rétention (créneau) | **Refus** `TimeSlotUnavailable` (structurel) | non | `refused` au pas 8 + Journal final | R-A : la règle au domaine, la clé au registre, le refus à la Décision |
| Conflit de version optimiste | **Failure** (`SEQUENCE.RETENTION_FAILURE` ; 2A-2 : `PERSIST.VERSION_CONFLICT`) | **oui** — ré-entrée pas 4 ; budget épuisé → `abandoned` (témoin) | `failure` puis `abandoned` | S-3/F5.2 §4 : « *une Failure transitoire, jamais une Decision* » ; métrique : taux de conflits |
| Failure technique (chargement/validités/rétention) | Failure (codes SEQUENCE.*) | oui, borné (M-8) ; puis abandon journalisé | `failure`/`abandoned` | S-3, R-10 ; Log adapter ; l'appelant/transport peut re-soumettre (l'identité d'acte déduplique) |
| Commande dupliquée (re-soumission, même CommandId) | produit de l'« effet unique » | — | — | **A-5** : « *at-least-once + Inbox + clés R-A ; exactly-once ne se promet pas, il se PRODUIT* » — le rejeu échoue sur les trois étages (version, clés, unicités) ; matérialisation pleine à 2A-2 |
| « Publication impossible » | **pas une situation de Séquence** | — | — | le pas 9 est STRUCTUREL (1C-2) ; l'échec de LIVRAISON appartient au relais : transport borné → Quarantaine + Signal (M-8) — voir §3/§5 |
| Exception interne (défaut d'appelant dans un port : SequenceExecutionException) | Exception — **remonte BRUTE** | non | le pas en cours ne « catch » pas | A-7 : « *jamais convertie* » (testé 1C-5 channels.spec) |

## 2. Séquence de Lecture (kernel + query side 1C-4)

| Situation | Canal | Retry | Journal | Déviations & lois |
|---|---|---|---|---|
| Query valide, ayant droit | — (`answered`) | non | les 6 pas | réponse = mapping pur, parties STRIPPÉES (« l'état ⊘ les conditions à des tiers », F3.3 §5) |
| Query inconnue (ListAgreement…) | Exception (`CONTRACT.UNKNOWN_CONTRACT`) | non | aucun (pas de lecteur) | table fermée (F4.1 §6) ; aucune lecture non ratifiée n'existe |
| Payload invalide | Exception | non | `exception` pas 1, fin | pas 1 |
| Droit manquant (R-C) | **Refus** `RightMissing` | non | `refused` pas 3 + Journal ; **la lecture ne tourne JAMAIS** | « *refuse motivé si le droit manque* » (F4.1 §5) ; métrique : taux par Reason |
| Rien de lisible (Read Model absent) | **Refus** `AgreementUnavailable` | non | `refused` pas 4 + Journal | motivé, jamais silence (F2.6) |
| Failure de lecture / de la source de droits | Failure (READ.*) | **jamais par la Séquence** — l'appelant re-demande | `failure` + Journal | les 6 pas n'ont pas de retry ; une lecture est idempotente ; M-8 au transport |
| Réplica en retard interrogé pour une validité | **interdit par construction** | — | — | S-5 : « *jamais sur un réplica en retard* » — les ports de lecture frappent le primaire (Blueprint §3.9) |

## 3. Séquence de Réaction (kernel 1C-5)

| Situation | Canal | Retry/Abandon | Journal | Déviations & lois |
|---|---|---|---|---|
| Fait consommé avec réaction | — (`reacted`) | non | les 6 pas | **Inbox marquée + position + Outbox de commandes, UNE écriture** (pas 4) |
| Fait déjà consommé (duplicate Inbox) | — (`duplicate`, absorbé) | non | `duplicate` pas 1 | M-4 ; l'at-least-once est NORMAL ; métrique de re-livraison (info) |
| Payload de fait invalide | Exception | non | `exception` pas 1 | pas 1 |
| Failure position/rétention | Failure (REACTION.*) | oui — ré-entrée pas 3 (rejeu pur, P-7) ; budget → abandon journalisé | `failure`/`abandoned` | S-3, M-8 ; « *la reprise re-livre, ne re-décide pas* » |
| Budget épuisé | `abandoned` + témoin | — | `abandoned` | M-8 : « *rien ne meurt sans témoin* » ; la re-livraison transport pourra retenter plus tard |
| « Failure relay » | **pas une situation de Séquence** | — | — | le pas 5 est structurel ; l'échec de livraison du relais = transport : retries bornés avec backoff → **Quarantaine + Signal** (M-8, F4.3 §8) |
| Message au-delà des bornes | → **Quarantaine** | replay outillé seulement | Log + **Signal d'exploitation** (escalade opérateur, O-5) | « *parqué, journalisé, signale… un poison ne bloque jamais la file* » |
| Exception d'appelant dans un port | Exception, brute | non | — | A-7 |

## 4. Boot (bootstrap 2A-1 ; lois F5.1/F4.4)

Colonnes propres : **Boot continue ? · Readiness · Émissions**.

| Situation | Boot | Readiness/Liveness | Émissions & lois |
|---|---|---|---|
| Toutes preuves rendues | continue : Construction→…→Active | Ready APRÈS validation complète ET relais/Échéancier ré-hydratés (F4.4 §6) | Log par transition d'état ; durée de boot |
| Configuration invalide (CONFIG.*) | **REFUSÉ — mort immédiate**, rapport COMPLET puis mort unique | jamais Ready | « *fail closed au boot : une application qui démarre à moitié ment déjà* » (F4.4 §6) ; R-5 |
| Secret absent (SECRET.UNKNOWN) | REFUSÉ — mort (le NOM au rapport, jamais une valeur) | jamais Ready | F4.4 §6 ; I-8 |
| Génération de contrat non servie / « version incompatible » | REFUSÉ — mort | jamais Ready | F4.4 §7/F4.4.99 : « *tue le boot* » (loi citée ; matérialisation avec les adapters) |
| Migration en retard / schéma incompatible | REFUSÉ — mort (le boot VALIDE, ne migre jamais) | jamais Ready | S-7 + Blueprint §3.11 ; l'espèce Migration corrige, puis une instance NEUVE boote |
| Module KO (construct/start lève) | REFUSÉ — la défaillance est une Failure ; l'instance meurt | jamais Ready | R-10 ; R-4 (elle ne re-valide pas : une neuve naît) |
| Health KO au démarrage (startup probe) | l'instance ne sert pas | Readiness unhealthy (fail closed) | R-6 ; 2A-1 health |
| Clock/Logger/dépendance absente à l'assemblage | REFUSÉ **à l'assemblage** (les builders sont fail closed — 1C-2/1C-5/2A-1) | — | I-2 ; F4.4 §7 : « *chaque Port a une implémentation* » |
| Instance morte re-bootée | **IMPOSSIBLE** — invariant levé | — | R-4 : « *jamais ne ressuscite* » (testé 2A-1) |

## 5. Replay (lois F4.3 §8 ; RC-1 §6 — aucun code encore : lignes 100 % loi)

| Situation | Verdict | Émissions & lois |
|---|---|---|
| Replay demandé | acte d'OUTILLAGE : journalisé, **à cible nommée**, borné à « re-porter » | « *il ne crée rien, il re-porte* » ; jamais un arrosage |
| Replay refusé par la cible | fin — le refus est un droit de la cible | « *refusable par la cible* » (F4.3.99) |
| Replay interrompu | inoffensif : re-livraison ultérieure ; les Inbox dédupliquent | M-4/A-5 (l'at-least-once absorbe) |
| Replay terminé | acte journalisé clos | — |
| Replay « impossible/incompatible » (génération morte, cible inconnue) | refusé — une cible qui ne consomme plus une génération ne peut pas la recevoir | V-5 (mort dérivable des consommateurs déclarés) |
| « Cursor » invalide/perdu | **non-événement** : mécanisme rebuildable depuis les statuts d'Outbox | RC-1 §6 ; S-4 ; O-1 (pardon) |
| Rejouer l'ÉTAT d'une unité | **n'existe pas** | la reconstruction est « Snapshot privé + delta » (F5.2 §12) — jamais un replay |

## 6. Migration (lois S-7/F5.1 ; RC-1 §9 — lignes 100 % loi)

| Situation | Verdict | Lois |
|---|---|---|
| Migration réussie | Migration Record appliqué ; expand-contract ; le SENS n'a pas bougé | S-7 ; espèce Migration seule |
| Migration interrompue | reprise ou renversement DANS la fenêtre ; jamais un état demi-migré servi (le boot des Applications refuse un schéma incohérent) | S-7 (« réversibles par fenêtre ») ; F4.4 §7 |
| Rollback | retour à un binaire **compatible en générations** ; les faits et positions continuent | R-9 ; « le rollback rolls binaries never facts » |
| Checksum/artefact invalide | mort au boot (preuve d'artefact) | R-5/F5.1 §18 ; T-21 |
| Snapshot incompatible (rupture de format) | migration expand-contract des lignes — structure, jamais le sens ; additive sinon | RC-1 §1 ; S-7 |
| Version/génération inconnue | boot tué (générations vérifiées) | F4.4 §7 |

## 7. Runtime (lois F5.1)

| Situation | Verdict | Lois |
|---|---|---|
| Process démarré | la machine à 9 états, sans retour | F5.1 §4 (implémentée 2A-1) |
| Shutdown demandé (SIGTERM/SIGINT) | **Drainage** : fermer l'entrée, achever les Séquences en vol (courtes par A-3), drain/dispose en ORDRE INVERSE, Destroyed | R-8 ; F4.4 §6 (« l'Outbox pardonne » : les relais reprennent au prochain boot) |
| Crash / OOM | **Failure, jamais une Decision** ; l'instance meurt, la Flotte remplace ; **les restes = déchets, jamais hérités** | R-10 ; R-4 ; F5.1 §19 |
| Restart | il n'existe pas de « restart » : une instance NEUVE naît (identités InstanceId nouvelles) | R-4 ; « redémarrage partiel interdit » (F4.4 §6) |
| Instance dégradée | verdict de Liveness → remplacement (une des trois voix) ; jamais de re-validation | R-4 ; F5.1 §14 |

## 8. Sécurité (lois F5.4/F4.4 ; R-C — le domaine I&A n'est pas construit : lignes 100 % loi)

| Situation | Verdict | Émissions & lois |
|---|---|---|
| Secret manquant au boot | mort du boot (§4) | I-8 |
| Preuve/secret expiré en vie | la rotation appartient à l'exploitation (« *rotation sans redéploiement* ») ; une traversée sans preuve valide est **refusée** — la confiance se démontre à CHAQUE traversée | T-2 ; T-18 (« *toute preuve cryptographique est rotative ; l'identité demeure* ») |
| Credential invalide | refus au vestibule des personnes (I&A — domaine gelé, non construit) ; jamais une Exception métier | T-3 (« *l'authentification établit, l'autorisation refuse — chez le propriétaire* ») |
| Permission refusée / accès interdit | **Refus motivé au Dispatch** (R-C, grille des ayants droit) — implémenté côté lecture (`RightMissing`, 1C-4) | A-8 ; F4.1 §5 |
| Accès à des données protégées | **Relevé d'accès** (probant, rétention longue — il ne passe PAS le pardon) | F5.3 §2/T-23 |
| Tentative non autorisée répétée | refus (valeurs) + le Relevé trace ; l'anomalie opérationnelle devient **Alerte** actionnable (symptôme, runbook, sévérité) | O-5 ; T-22 (les défenses gardent les traversées, jamais les décisions métier) |

## 9. Observabilité — quand produit-on quoi (synthèse de RC-3)

| Artefact | Produit quand | Jamais |
|---|---|---|
| **Journal** | à CHAQUE pas exécuté des trois Séquences (implémenté) | échantillonné ; porteur de matière/secret |
| **Log** | événements techniques du Runtime/adapters/moteurs (transitions d'état, incidents moteur) | vérité probante métier ; secret |
| **Métrique** | dérivée des journaux et faits (taux par Reason/code, latences, conflits, re-livraisons, profondeur de quarantaine) | consultée par une Séquence (O-3) |
| **Trace** | span par exécution SI échantillonné ; propagation par enveloppe | probante ; `SessionId` |
| **Signal** (exploitation) | quarantaine, abandon de parcours (P-8), corruption détectée | vers les personnes (les Signals-personnes = Notification, domaine) |
| **Alerte** | symptôme opérationnel actionnable : nomme son runbook, porte sa sévérité | législatrice ; bruit |
| **Dashboard** | vues de projections d'EXPLOITATION (pardon à l'écran) | curation devenue vérité ; projections métier (STOP 1C-6) |
| **Fiche** | à la naissance de chaque registre, vérifiée en CI | modifiée sans gouvernance |
| **Relevé d'accès** | à chaque accès aux données protégées | perdu sans pardon juridique |

## 10. Synthèse transversale — la matrice unique

| Situation | Canal | Retry | Journal | Log | Métrique | Trace | Outbox/Inbox | Replay/Quarantaine | Signal | Loi |
|---|---|---|---|---|---|---|---|---|---|---|
| Exécution nominale (Commande) | — | — | 10 pas | — | latences | span | Outbox de faits écrite | — | — | A-1..A-10 |
| Refus métier (tout point) | Refus | jamais | refusé+final | — | taux/Reason | span | aucune écriture | — | — | A-7, pas 7 |
| Contrat violé / inconnu / sans identité d'acte | Exception | jamais | pas 1 (si Séquence entamée) | gateway | taux/code | span | — | — | — | pas 1 ; F4.1 §3/§6 |
| Failure technique en Séquence | Failure | borné puis abandon TÉMOIGNÉ | failure/abandoned | adapter | taux+tentatives | span | — | — | abandon PM → Signal (P-8) | S-3, R-10, M-8 |
| Conflit optimiste | Failure transitoire | oui (pas 4) | failure | adapter | taux conflits | span | — | — | — | F5.2 §4 |
| Clé R-A / naissance double / terminal / inconnu | Refus structurel | jamais | refusé | — | taux/Reason | span | — | — | — | R-A, R-B |
| Re-livraison d'un fait | — (duplicate) | — | duplicate | — | taux re-livraison | — | Inbox déjà marquée | — | — | M-4, A-5 |
| Livraison au-delà des bornes | transport | non | — | oui | profondeur | — | — | **Quarantaine** ; sortie = replay outillé | **oui** | M-8, F4.3 §8 |
| Lecture sans droit / sans matière | Refus | jamais | refusé+final | — | taux/Reason | span | — | — | — | R-C ; F2.6 |
| Boot : toute preuve manquante | mort de l'instance | non — une NEUVE naît | — | rapport complet | — | — | — | — | Alerte exploitation | R-4, R-5, F4.4 §6-7 |
| Crash/OOM/dégradation | Failure d'exécution | remplacement par la Flotte | — | oui | — | — | l'Outbox pardonne | — | selon Alerte | R-10, R-4, R-8 |
| Corruption (photo, ligne de fait) | Exception | non | record | oui | compteur | — | — | récupération = acte gouverné (S-6) | **oui** | Blueprint §3 ; S-6 |
| Replay outillé | acte journalisé | — | l'acte | oui | volumes | — | relit l'Outbox/faits | refusable par la cible | — | F4.3 §8 |
| Migration | acte de l'espèce Migration | fenêtre réversible | — | oui | durée | — | — | — | — | S-7, R-9 |

## 11. Audit final & traçabilité

**Cohérences vérifiées** : ✓ RC-1 (mêmes objets : Outbox/Inbox/Quarantaine/
Records — les lignes des §1/§3/§5 pointent les fiches RC-1) ; ✓ RC-2 (chaque
code cité existe au catalogue, même canal, même retryabilité) ; ✓ RC-3 (les
colonnes d'émission reprennent les quatre objets et leurs interdits) ; ✓ RC-4
(vocabulaire strict : Outbox qualifiée, Journal/Log distincts, aucun terme
nouveau — « restart », « cursor » traités comme non-concepts) ; ✓ RC-5 (les
lignes adapters renvoient aux quatorze règles) ; ✓ Phases 1A/1B/1C (chaque
comportement « constaté » cite son lot et est couvert par un test vert) ;
✓ aucune contradiction ; ✓ aucune règle nouvelle (les situations sans Corpus
ont reçu des verdicts « pas une situation » / « n'existe pas » / « non-
événement » au lieu d'un comportement inventé) ; ✓ aucune responsabilité
déplacée ; ✓ aucune duplication (ce document INDEXE les cinq autres, il ne
les recopie pas — loi documentaire F3.3).

**Traçabilité (Section → Chapitre R2 → Lois → Décisions constatées)** :

| Section | Chapitre(s) | Lois | Décisions constatées |
|---|---|---|---|
| §1 Commande | F4.1 · F3.2-A · F5.2 | A-1→A-10, R-A, R-B, S-3, A-5 | comportements des lots 1C-2/1C-3/1C-7 ; « publication impossible » = relais (M-8) ; dedup = les trois étages d'A-5 |
| §2 Lecture | F4.99 §1 · F4.1 §5 · F3.3 §5 | R-C, loi 15, S-5, F2.6 | comportements 1C-4 ; jamais de retry de Séquence ; primaire seul |
| §3 Réaction | F4.99 §1 · F4.2 · F4.3 | M-4, M-8, P-7, P-8, S-3 | comportements 1C-5 ; duplicate=normal ; quarantaine+Signal |
| §4 Boot | F5.1 · F4.4 §6-7 | R-4, R-5, R-6, I-2, I-8 | comportements 2A-1 ; générations/migration = lois citées, matérialisation aux adapters |
| §5 Replay | F4.3 §8 | M-8, V-5, S-4, O-1 | 100 % loi ; « rejouer l'état n'existe pas » (F5.2 §12) |
| §6 Migration | F5.2 · F5.1 | S-7, R-9, T-21 | 100 % loi + RC-1 §9 |
| §7 Runtime | F5.1 | R-4, R-8, R-10 | shutdown 2A-1 constaté ; « restart » = instance neuve |
| §8 Sécurité | F5.4 · F4.1 §5 · F5.3 §2 | T-2, T-3, T-18, T-22, T-23, R-C, I-8 | 100 % loi (I&A non construit) ; RightMissing constaté (1C-4) |
| §9-10 Synthèses | F5.3 · tous | O-1→O-10 + toutes ci-dessus | index croisé, zéro contenu neuf |
