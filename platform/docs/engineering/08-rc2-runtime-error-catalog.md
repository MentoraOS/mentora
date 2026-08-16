# RC-2 — Runtime Error Catalog (Phase 2A.5)

> **Statut : documentaire.** Le catalogue des erreurs TECHNIQUES existantes ou
> autorisées par le Corpus. AUCUNE erreur métier n'est cataloguée ici : un
> refus métier est une **Décision motivée du domaine** (A-7 ; l'union des
> Reasons appartient au langage publié 1B) — jamais une « erreur ».

## 0. La loi des canaux (le classement avant le catalogue)

A-7, verbatim : « *le refus est une valeur transportée ; l'Exception un défaut
d'appelant ; la Failure un réessai — trois canaux, jamais mélangés.* »
S-3 : un conflit de concurrence est une **Failure, jamais une Decision**.
R-10 : « *toute défaillance de Runtime est une Failure — jamais une Decision,
jamais un Refusal.* » Les métriques dérivent des journaux (O-3) ; les niveaux
de log sont une convention d'ingénierie (le Corpus ne définit la sévérité que
pour les Alertes — F5.3).

Colonnes : **Code · Canal · Retryable · Journalisation · Métrique dérivée · Niveau log · Loi**.

## 1. Contrats / Réception (nés en 1B — canal Exception, défaut d'appelant)

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| CONTRACT.NOT_AN_OBJECT | Exception | non | record `exception` au pas 1 | taux par code | warn | pas 1 : « malformé → Exception, fin » |
| CONTRACT.FIELD_MISSING | Exception | non | idem | idem | warn | idem |
| CONTRACT.FIELD_TYPE | Exception | non | idem | idem | warn | idem |
| CONTRACT.FIELD_BLANK | Exception | non | idem | idem | warn | idem |
| CONTRACT.UNKNOWN_CONTRACT | Exception | non | idem (aussi émis par les 3 Dispatchers : table fermée) | idem | warn | F4.1 §6 ; M-5 |
| CONTRACT.VERSION_INCOMPATIBLE | Exception | non | idem | idem | warn | V-2 (lecteur tolérant, génération inconsommable) |

## 2. Séquence de Commande (kernel 1C-2)

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| SEQUENCE.RECEPTION | Exception (classe frontière) | non | `exception` pas 1 | taux | warn | A-7 |
| SEQUENCE.LOADING_FAILURE | Failure | **oui** (ré-entrée pas 4) | `failure` puis `abandoned` au budget | taux + tentatives | error | S-3/R-10 ; M-8 (borné) |
| SEQUENCE.VALIDITY_FAILURE | Failure | oui | idem | idem | error | loi 15 (la source n'a pas répondu ≠ a refusé) |
| SEQUENCE.RETENTION_FAILURE | Failure | oui | idem | idem | error | S-3 (conflit optimiste inclus, côté générique) |

## 3. Séquence de Lecture (kernel 1C-4) — jamais de retry par la Séquence

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| READ.RIGHTS_FAILURE | Failure | par l'appelant seul | `failure` + record Journal final | taux | error | R-10 ; la Lecture ne retry jamais (6 pas sans retry) |
| READ.READING_FAILURE | Failure | par l'appelant seul | idem | idem | error | idem |

## 4. Séquence de Réaction (kernel 1C-5)

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| REACTION.RECEPTION | Exception (classe frontière) | non | `exception` pas 1 | taux | warn | A-7 |
| REACTION.REACTION_FAILURE | Failure | oui (ré-entrée pas 3) | `failure`/`abandoned` | taux + tentatives | error | P-7 (rejeu déterministe) ; M-8 |
| REACTION.RETENTION_FAILURE | Failure | oui | idem | idem | error | S-3 |
| (duplicate) | — aucun code : issue `duplicate`, absorbée | — | record `duplicate` pas 1 | taux de re-livraison | info | M-4 (l'at-least-once est NORMAL, pas une erreur) |

## 5. Configuration (runtime-config, 2A-1) — mort du boot, fail closed

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| CONFIG.MISSING / TYPE / BOUNDS / CHOICE / BLANK | Failure de boot | **non — l'instance meurt** (rapport COMPLET puis mort, une fois) | rapport de validation du boot | néant (l'instance n'existe pas) | fatal | F4.4 §6/§7 : « configuration invalide » = mort immédiate ; « une seule erreur = pas de démarrage » |

## 6. Sécurité (runtime-security, 2A-1)

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| SECRET.UNKNOWN | Failure de boot | non — mort | rapport de boot (LE NOM seul — jamais une valeur) | néant | fatal | F4.4 §6 (« secret manquant ») ; I-8 |

## 7. Sérialisation (runtime-serialization, 2A-1)

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| SERIAL.UNSUPPORTED | Failure | non (défaut d'usage interne) | log technique | taux | error | valeurs pures aux ports (F4.4 §3) |
| SERIAL.CYCLE | Failure | non | idem | idem | error | idem |
| SERIAL.MALFORMED | Failure (ou Exception au pas 1 via les validateurs du contrat) | non | idem | idem | error | V-2 |

## 8. Persistance (Blueprint 2A-2 — codes autorisés, à naître AVEC l'implémentation)

| Code | Canal | Retryable | Journalisation | Métrique | Niveau | Loi |
|---|---|---|---|---|---|---|
| PERSIST.VERSION_CONFLICT | **Failure transitoire** | oui (le pipeline ré-entre au pas 4) | `failure` du pas 8 | taux de conflits | warn | F5.2 §4 verbatim ; S-3 |
| PERSIST.ENGINE_FAILURE | Failure | oui (borné) | idem | taux | error | R-10 |
| PERSIST.CORRUPTION | **Exception** + Signal d'exploitation | non | record + Signal (« rien ne meurt sans témoin ») | compteur | fatal | Blueprint §3.1 ; O-5 (l'Alerte nomme son runbook) |

Rappel structurel : la violation de **clé R-A** (TimeSlotUnavailable) et la
double naissance ne sont PAS ici — ce sont des **Décisions motivées** (refus),
propriété du langage publié.

## 9. Santé & Boot — des verdicts et des rapports, pas des codes

- **Santé** : `HealthStatus = healthy | unhealthy(reason)` — R-6 : ni l'une ni
  l'autre ne jugent le métier ; un check qui lève est décrit en verdict
  (R-10), jamais silencieux.
- **Boot** : les échecs de BootValidator sont des messages agrégés en UN
  rapport, puis l'instance meurt (R-5) ; une instance morte ne re-boot jamais
  (R-4). Pas de codes : des preuves nommées.

## 10. Règles d'extension du catalogue

Un code nouveau naît UNIQUEMENT : (a) avec l'implémentation qui le lève,
(b) dans un des trois canaux d'A-7, (c) avec sa loi citée, (d) journalisé
sans matière ni secret (O-2), (e) inscrit ici dans le même commit. Les codes
sont permanents — jamais renumérotés, jamais réutilisés (discipline VD/MENTORA).
