# Mentora Architecture Decision Log

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion  
**Sprint:** -1.1

## 1. Purpose

Registre officiel des décisions structurantes. Une décision remplacée doit être marquée `SUPERSEDED` et référencer sa remplaçante.

Statuts : `PROPOSED`, `ACCEPTED`, `SUPERSEDED`, `DEPRECATED`, `REJECTED`.

## 2. Decisions

### AD-001 — Product First
**ACCEPTED.** La roadmap est recentrée sur le parcours réservation/consultation.

### AD-002 — Financial Core Freeze
**ACCEPTED.** Financial est gelé hors bugs, sécurité, tests, documentation et intégrations PSP nécessaires.

### AD-003 — Product Domains / Platform Capabilities
**ACCEPTED.** Identity, Expert, Discovery, Scheduling, Booking, Payment, Consultation et Review sont des domaines produit. Financial, Automation, Events, Notification, Meeting, Permissions et Observability sont des capacités de plateforme.

### AD-004 — Booking Ownership
**ACCEPTED.** Booking possède le cycle de réservation.

### AD-005 — Scheduling Ownership
**ACCEPTED.** Scheduling possède disponibilités, créneaux, timezone et conflits.

### AD-006 — Consultation Ownership
**ACCEPTED.** Consultation possède l'exécution métier du service.

### AD-007 — Meeting Is Technical
**ACCEPTED.** Meeting possède la vidéo technique ; sa fermeture ne vaut pas completion métier.

### AD-008 — Payment Product Boundary
**ACCEPTED.** Payment possède intent/authorization/capture/refund côté produit ; Ledger/Settlement restent Financial.

### AD-009 — Financial Platform
**ACCEPTED.** Financial possède Ledger, Settlement, commission, transactions, recovery, reconciliation et audit.

### AD-010 — Canonical Events
**ACCEPTED.** Un fait métier = un événement canonique immutable nommé au passé.

### AD-011 — Single Owner Principle
**ACCEPTED.** Une règle métier = un propriétaire.

### AD-012 — Financial Gateway
**ACCEPTED.** Les domaines produit accèdent à Financial uniquement via sa frontière publique.

### AD-013 — Progressive Migration
**ACCEPTED.** Aucun Big Bang Refactor ; migration incrémentale protégée par tests.

### AD-014 — Single Composition Root
**ACCEPTED.**

```text
main.dart → AppBootstrap → AppContainer → MentoraApp
```

### AD-015 — Infrastructure Isolation
**ACCEPTED.** Firebase, Firestore, Agora et SDK PSP restent hors Domain.

### AD-016 — Architecture Tests
**ACCEPTED.** Les règles critiques deviennent progressivement des tests CI.

### AD-017 — Deferred Enterprise Scope
**ACCEPTED.** Enterprise, Workspace, Learning et AI sortent de la roadmap immédiate.

### AD-018 — Official Product Flow
**ACCEPTED.**

```text
Discovery → Scheduling → Booking → Payment → Consultation → Settlement → Review
```

## 3. Gouvernance

Toute nouvelle décision structurante doit :
- obtenir un identifiant AD ;
- décrire contexte et conséquence ;
- référencer les documents impactés ;
- préciser si elle remplace une décision existante.

**Status:** APPROVED
