# RC — Audit croisé & traçabilité (Phase 2A.5)

> L'audit final obligatoire des cinq documents RC-1→RC-5, menés comme UN
> ensemble : même vocabulaire, mêmes objets, mêmes propriétaires, mêmes lois.

## 1. Audit croisé

- ✓ **Aucune contradiction** : chaque objet de RC-1 porte le même nom, le même
  propriétaire et les mêmes lois dans RC-2 (ses erreurs), RC-3 (son
  observabilité), RC-4 (son entrée de dictionnaire), RC-5 (ses règles
  d'usage). Vérifications nominales : Outbox toujours QUALIFIÉE (de faits /
  de commandes) dans les cinq ; Journal ≠ Log partout ; Snapshot au seul sens
  F3.1.11 ; Failure/Exception/Refus jamais mélangés (les tableaux RC-2
  reprennent exactement les canaux des exécuteurs 1C-2/4/5).
- ✓ **Aucun doublon** : trois objets du mandat ont été REFUSÉS comme doublons
  et dissous (Projection Checkpoint ≡ Inbox de consommateur ; Retention Audit
  ≡ Journal+provenance+Fiche+Relevé d'accès) ou requalifiés en mécanisme
  (Replay Cursor — S-4/O-1) : RC-1 §6/§7/§11, repris à l'identique en RC-4 §4.
- ✓ **Aucun terme inventé** : RC-4 sépare [R2] (cités) et [ENG] (nés dans les
  lots, adossés à leur loi) ; Cursor/Checkpoint y sont marqués non-canoniques.
- ✓ **Aucune loi réécrite** : toute loi est CITÉE (verbatim ou référencée) —
  jamais paraphrasée en règle nouvelle ; RC-5 n'énonce que des règles à
  citation (les quatorze du mandat, toutes trouvées dans le Corpus).
- ✓ **Aucune responsabilité déplacée** : ports chez leurs consommateurs
  (F4.4 §3) ; publication au relais ; transactions au registre ; Policies au
  Root ; générations aux propriétaires de contrats ; santé au Runtime.
- ✓ **Références vérifiées** : toutes les citations proviennent des relectures
  intégrales de cette phase (agents F4.1/F4.2-F4.4/F2.5-F3.3 en 1C, F5.1-F5.4
  en 2A) et des fichiers canon relus directement.
- ✓ **Sections traçables** : table §2.

## 2. Tableau de traçabilité (Section → Chapitre R2 → Lois → Décisions)

| Section | Chapitre(s) R2 | Lois utilisées | Décisions prises |
|---|---|---|---|
| RC-1 §1-2 Snapshots | F3.1.11 · F5.2 §12 · F3.2-A | S-2, S-4, S-7, S-9 | photo à chaque rétention (delta=0) ; additive-only ; corruption=Exception |
| RC-1 §3 Fact Record | F3.3 §3 · F4.3 §4 · F5.2 | S-9, V-1/V-2/V-3, O-4, S-6 | identité=(AggregateId,sequence) ; append-only ; wire du propriétaire |
| RC-1 §4 Outbox Record | F4.3 §5/§7 · F4.99 §2/§6 | A-3, A-4, M-4, P-4 | enveloppe séparée du fait ; purge re-dérivable |
| RC-1 §5 Inbox Record | F4.3 §7 · F4.99 §1 | M-4, A-5, loi 15 | marque dans l'acte atomique de Réaction |
| RC-1 §6 Replay Cursor | F4.3 §8 · F4.2 §9 | O-1, S-4, F4.1.99 (mécanismes libres) | mécanisme rebuildable, nom non-canonique |
| RC-1 §7 Projection Checkpoint | F2.5 §6 · F4.3 §7 | M-4 ; STOP 1C-6 | DISSOUS dans l'Inbox ; aucun objet nouveau |
| RC-1 §8 Quarantaine | F4.3 §8 | M-8, O-5 | enveloppe+cause+bornes ; sortie=replay outillé |
| RC-1 §9 Migration Record | F5.1 §3 · F5.2 | S-7, T-21 | exécution par l'espèce Migration seule |
| RC-1 §10 Générations | F4.3 (V) · F4.4 §7 | V-1→V-6, S-4 | table dérivée, désaccord=pas de démarrage |
| RC-1 §11 Retention Audit | F4.1 §9 · F5.3 §2 · F5.2 §10 | A-10, O-4, S-10 | DISSOUS : Journal+provenance+Fiche+Relevé |
| RC-2 §0-9 | F4.1 · F5.1 · F5.2 · F5.3 | A-7, S-3, R-10, M-8, O-2/O-3 | catalogue des codes EXISTANTS + blueprint 2A-2 marqués « à naître » |
| RC-3 §0-7 | F5.3 · F4.1 §9 · F5.1 · F4.3 §8 | O-1→O-10, A-10, R-5/R-6, P-7 | par-pas des 3 Séquences ; dashboards=projections d'EXPLOITATION (STOP 1C-6 intact) |
| RC-4 §1-5 | F2.5 §9-11 · F3.1 · F4.4 §3 · F5.2 §12 · F5.3 §10 | naming constitution, réservations, I-4 | familles [R2]/[ENG] ; réservations opposables rappelées |
| RC-5 | F4.4 · F4.1 · F5.2 · F5.4 · F2.6 | I-4/I-5/I-7/I-8/I-12, A-3/A-4/A-6/A-9, S-2/S-3/S-5, loi 15, Titre VI | 14 règles, toutes à citation ; rituel en 6 pas |

## 3. Périmètre respecté

Aucun code, aucune classe, aucun package, aucun test, aucun lot gelé modifié.
Trois STOP-verdicts internes rendus (RC-1 §6/§7/§11) au lieu de compléter le
Corpus. Les décisions Titre VII pendantes restent pendantes (projections
1C-6, NoShowSettlementProcess 1C-5, motifs de refus de lecture 1C-4, foyer
des ids partagés 1B, famille Reason F2.5.2 §20).
