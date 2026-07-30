# Mentora Architectural Overlap Register

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion  
**Sprint:** -1.1

## 1. Objectif

Recenser les chevauchements architecturaux et attribuer une décision explicite afin d'éviter les sources de vérité concurrentes.

## 2. Décisions

| ID | Chevauchement | Décision | Priorité |
|---|---|---|---|
| OV-001 | Booking / Scheduling | KEEP SEPARATE + ADAPTER | P0 |
| OV-002 | Booking / Consultation | KEEP SEPARATE | P0 |
| OV-003 | Consultation / Meeting | KEEP SEPARATE + ADAPTER | P0 |
| OV-004 | Booking / Payment | KEEP SEPARATE + ADAPTER | P0 |
| OV-005 | Booking / Pricing | KEEP SEPARATE ; Booking snapshot | P0 |
| OV-006 | Booking / Escrow | FREEZE + Financial execution | P0 |
| OV-007 | Payment / Financial | PUBLIC FINANCIAL GATEWAY | P0 |
| OV-008 | Financial / Escrow | MERGE conceptuellement dans Financial | P1 |
| OV-009 | Financial / Pricing | KEEP SEPARATE | P1 |
| OV-010 | Financial / PSP | PORT / ADAPTER | P0 |
| OV-011 | Automation / Workflow | KEEP SEPARATE ; Workflow FREEZE | P1 |
| OV-012 | Workflow / Business Process | DEPRECATE Business Process | P2 |
| OV-013 | Workflow / Phoenix | AUDIT Phoenix | P1 |
| OV-014 | Automation / Timer | KEEP SEPARATE | P1 |
| OV-015 | Generic Engines / Modules | AUDIT engine par engine | P1 |
| OV-016 | Identity / Authentication | PORT / ADAPTER | P0 |
| OV-017 | Identity / Permissions | KEEP SEPARATE | P1 |
| OV-018 | Identity / Expert | KEEP SEPARATE | P1 |
| OV-019 | Event systems | Canonicaliser les contrats | P0 |
| OV-020 | Notification / Automation | KEEP SEPARATE | P0 |
| OV-021 | Notification / channels | MIGRATE vers ports | P1 |
| OV-022 | core / features | Migration feature-first progressive | P1 |
| OV-023 | top-level domain / bounded domains | DEPRECATE generic domain | P2 |
| OV-024 | screens / feature presentation | MIGRATE progressivement | P1 |
| OV-025 | presentation / screens | MERGE conceptuellement | P2 |
| OV-026 | main.dart / Bootstrap | SINGLE COMPOSITION ROOT | P0 |
| OV-027 | DI / self-instantiation | CENTRALIZE construction | P0 |
| OV-028 | MentoraOS / Bootstrap / Phoenix | AUDIT + single startup authority | P1 |
| OV-029 | Repositories / Firestore direct | REMOVE direct access progressively | P0 |
| OV-030 | Multiple repositories | AUDIT by aggregate | P1 |
| OV-031 | Enterprise / Administration | DEFER Enterprise | P3 |
| OV-032 | Workspace / dashboards | DEFER | P3 |
| OV-033 | Learning / Consultation content | DEFER | P3 |
| OV-034 | AI / Discovery | DEFER + contract first | P3 |
| OV-035 | Shared / domain ownership | STRICT GOVERNANCE | P1 |

## 3. Règles P0

- Scheduling possède disponibilité/conflits ; Booking possède la réservation.
- Consultation possède le service ; Meeting reste technique.
- Payment est la frontière produit ; Financial exécute et comptabilise.
- PSP reste en Infrastructure.
- Un fait métier possède un événement canonique.
- `main.dart` migre vers un Composition Root unique.
- Aucun nouvel accès Firestore direct depuis Domain/Presentation.
- Aucun nouveau Business Process.
- Aucun nouveau moteur générique sans ADR.
- Financial reste gelé hors stabilisation et intégrations nécessaires.

## 4. Stratégie de résolution

Pas de refactor massif. Lorsqu'un use case touche un chevauchement :

1. identifier l'ID OV ;
2. confirmer le propriétaire ;
3. introduire/valider le contrat ;
4. empêcher toute nouvelle dépendance interdite ;
5. migrer uniquement le périmètre nécessaire ;
6. ajouter les tests ;
7. retirer le legacy devenu inutile.

**Status:** APPROVED
