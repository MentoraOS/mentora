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

### AD-019 — Expert Booking Occupancy Read Ownership
**ACCEPTED.** ARCH-007 Wave 2C établit une frontière moderne, additive et
strictement en lecture seule : Booking possède les faits d’occupation dérivés
des réservations. Scheduling conserve l’interprétation des disponibilités, la
génération des créneaux, les règles de timezone, les conflits et la décision
finale de réservabilité.

La représentation Genesis `bookingDate|bookingTime` et les statuts
`pending`, `confirmed`, `paid` sont conservés sans normalisation ni nouvelle
sémantique. `lib/core/booking/` reste legacy et n’est pas migré par Wave 2C.
La dette de schéma temporel et l’intégration future avec Scheduling restent
explicitement hors périmètre.

Une réservation pertinente pour l’occupation dont `bookingDate` ou
`bookingTime` est absent, vide ou invalide fait échouer la lecture complète.
Elle n’est ni ignorée ni transformée en résultat partiel, afin d’éviter qu’un
créneau potentiellement occupé apparaisse disponible. La Presentation traite
alors l’occupation comme inconnue, distincte d’un résultat vide réussi, et
interdit la réservation. Il s’agit d’une politique de sûreté des lectures
Booking, pas d’une règle de conflit Scheduling.

## 3. Gouvernance

Toute nouvelle décision structurante doit :
- obtenir un identifiant AD ;
- décrire contexte et conséquence ;
- référencer les documents impactés ;
- préciser si elle remplace une décision existante.

**Status:** APPROVED
