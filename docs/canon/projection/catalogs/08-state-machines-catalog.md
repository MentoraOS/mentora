---
doc: canon-catalog-08-state-machines
title: Catalogue des machines d'états
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F3.3 §8 — State Machine Catalogue (SEUL propriétaire des transitions ; 15 machines) — source/domain/06-tactical-documentation-freeze.md"
  - "F5.1 R-4, F5.3 O-9, F4.2 P-9 — machines de la Production & des Process — source/production/01,03 ; source/application/02"
note: >-
  INDEX des machines d'états. Projection déterministe de la Source. Chaque entrée :
  machine · transitions (initial → terminaux) · propriétaire · référence. Le
  State Machine Catalogue (F3.3 §8) est le SEUL propriétaire des transitions du
  domaine (une règle définie deux fois divergera). États terminaux irréversibles
  (R-B). Aucun contenu au-delà des transitions gelées. Évolution : Titre VII.
---

# Catalogue des machines d'états

**But.** Retrouver toute machine d'états et ses terminaux. **Portée.** Les 15
machines du domaine (F3.3 §8) + les machines de la Production et des Process.
**Index seul** : le détail vit dans la Source. Lois transversales : état initial
nommé, **terminaux irréversibles (R-B)**, aucune transition sans commande.

## A. Machines du domaine (F3.3 §8 — les 15)

| # | Machine | Transitions (initial → … → terminaux) | Domaine | Source |
|---|---------|----------------------------------------|---------|--------|
| 1 | `Agreement` | Requested → Accepted → Confirmed (⇄Rescheduled) → Cancelled \| Elapsed ; Requested → Rejected \| Lapsed ; Accepted → Lapsed | Engagement | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 2 | `Encounter` | Prepared → Opened → Closed \| Interrupted | Consultation | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 3 | `FollowUp` | Opened → Handled | Consultation | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 4 | `Review` | Published → Struck | Reputation | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 5 | `Account` | Active → Closed | Account | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 6 | `Subscription` | Active → Ended | Account | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 7 | `SupportRequest` | Opened → Handled | Account | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 8 | `Invitation` | Issued → Accepted \| Declined | Enterprise | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 9 | `Membership` | Active → Revoked | Enterprise | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 10 | `ConsentGrant` | Granted → Withdrawn \| Expired \| Invalidated | Consent | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 11 | `Conversation` | Open → Closed | Messaging | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 12 | `Credential` | Active → Revoked | Identity & Access | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 13 | `Session` | Active → Ended \| Revoked | Identity & Access | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 14 | `SettlementOrder` | Received → Executed \| Failed | Settlement | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |
| 15 | `Signal` / `Deposit` / `Production` | Remitted → Delivered \| Undeliverable / Stored → Destroyed / Requested → Delivered | Notification / Storage / Augmentation | [F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) |

*(Entities porteuses de cycle : `PayoutRecord` Requested → Completed \| Failed — F3.3 §8.)*

## B. Machines de la Production & des Process

| Machine | Transitions | Propriétaire | Source |
|---------|-------------|--------------|--------|
| Machine à neuf états du Runtime | Construction → Configuration → Validation → Warmup → Ready → Active → Draining → Shutdown → Destroyed (fermée, sans retour) | Runtime | [F5.1 §4-9, R-4](../../source/production/01-runtime.md) |
| Cycle de l'Incident | Ouvert → Maîtrisé → Résolu → Clos (réouverture = incident nouveau, R-B) | Exploitation | [F5.3 §10, O-9](../../source/production/03-observability.md) |
| Machine du Process Manager | quatre terminaux : `Completed`, `Compensated`, `Cancelled`, `Abandoned` | Process Manager | [F4.2 P-9](../../source/application/02-process-managers.md) |

## Références

[F3.3 §8](../../source/domain/06-tactical-documentation-freeze.md) (seul propriétaire des transitions du domaine) · [R-B](../../source/domain/06-tactical-documentation-freeze.md) · [F5.1 R-4](../../source/production/01-runtime.md) · [F5.3 O-9](../../source/production/03-observability.md) · [F4.2 P-9](../../source/application/02-process-managers.md).

## Notes

- Terminaux **irréversibles** (R-B : reprendre après un terminal = unité nouvelle à provenance citée). L'horloge n'entre jamais dans l'unité : les échéances (`Elapsed`, `Lapsed`, `Expired`, `RetentionActive`) se constatent sur un instant reçu en donnée (F3.1.99 §5).
