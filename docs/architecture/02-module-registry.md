# Mentora Architecture Module Registry

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion  
**Sprint:** -1.1 — Vérité architecturale et registre officiel des modules

## 1. Objectif

Ce document définit officiellement les responsabilités, frontières, priorités et statuts des modules de Mentora.

Principe : **un module = une responsabilité explicite ; une règle métier = un propriétaire.**

## 2. Statuts

| Statut | Signification |
|---|---|
| KEEP | Conserver |
| STABILIZE | Tester, corriger et documenter avant évolution |
| FREEZE | Pas de nouvelle capacité hors corrections, sécurité et intégration requise |
| MIGRATE | Migration progressive |
| MERGE | Fusion vers un propriétaire cible |
| DEPRECATE | Aucun nouvel usage |
| REMOVE | Suppression planifiée |
| DEFER | Hors priorité actuelle |
| AUDIT | Responsabilité à clarifier |

## 3. Product Domains

### Identity
Responsabilité : identité, authentification, session, compte et rôles.  
Statut : **STABILIZE**. Priorité : **HIGH**.

### Expert
Responsabilité : profil professionnel, expertise, services, tarifs, vérification.  
Statut : **KEEP**. Priorité : **HIGH**.

### Discovery
Responsabilité : recherche, filtres, catégories, classement et découverte.  
Statut : **KEEP**. Priorité : **HIGH**.

### Scheduling
Responsabilité : disponibilités, créneaux, conflits, calendrier et fuseaux horaires.  
Statut : **KEEP**. Priorité : **CRITICAL**.  
Interdit : créer une réservation, gérer Payment ou Ledger.

### Booking
Responsabilité : création, confirmation, annulation, expiration, no-show de réservation, prix accepté et intentions de paiement/remboursement.  
Statut : **KEEP**. Priorité : **CRITICAL**.  
Décision : **domaine primaire de Mentora**.  
Interdit : Ledger, Settlement internals, Firestore direct, Agora.

### Payment
Responsabilité : PaymentIntent, authorization, capture, failure et refund côté produit.  
Statut : **KEEP**. Priorité : **CRITICAL**.  
Interdit : devenir un second Ledger/Settlement.

### Consultation
Responsabilité : préparation, présence métier, début, durée, fin, completion et no-show.  
Statut : **KEEP**. Priorité : **CRITICAL**.  
Interdit : PSP, Ledger, token vidéo.

### Review
Responsabilité : notes, avis, historique et modération.  
Statut : **PLANNED**. Priorité : **MEDIUM**.

## 4. Platform Capabilities

### Financial
Ledger, Settlement, transactions, commission, escrow financier, recovery, reconciliation et audit.  
Statut : **FREEZE**.  
Autorisé : corrections, sécurité, tests, documentation et intégrations PSP nécessaires.

### Automation
Automatisations événementielles, différées et récurrentes.  
Statut : **STABILIZE**.  
Ne décide jamais à la place du domaine métier.

### Events
Publication, dispatch et consommation des événements canoniques.  
Statut : **KEEP**.

### Notification
Distribution Push/SMS/Email/In-App.  
Statut : **KEEP**. Aucune décision métier.

### Meeting
Room, token, Agora/WebRTC et présence technique.  
Statut : **KEEP**. Consultation reste propriétaire du service métier.

### Workflow
Statut : **FREEZE**. Aucun nouveau moteur générique.

### Business Process
Statut : **DEPRECATE**. Migration progressive.

### Phoenix
Statut : **AUDIT**. Aucune nouvelle responsabilité avant clarification.

## 5. Deferred

Enterprise, Workspace, Learning et AI : **DEFER** jusqu'à stabilisation du cœur produit.

## 6. Dépendance officielle

```text
Product Domains
    ↓
Platform Capabilities
    ↓
Infrastructure
```

## 7. Priorités

**P0 :** Booking, Scheduling, Payment, Consultation.  
**P1 :** Identity, Notification, Review et gouvernance plateforme.  
**P2 :** Analytics, Administration.  
**P3 :** Enterprise, Workspace, Learning, AI.

## 8. Décision CTO

Mentora est une plateforme de réservation et de consultation. Booking est le domaine primaire. Les moteurs techniques servent la chaîne produit et ne la remplacent pas.

**Status:** APPROVED
