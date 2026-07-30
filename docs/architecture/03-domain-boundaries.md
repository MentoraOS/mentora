# Mentora Domain Boundaries

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion  
**Sprint:** -1.1

## 1. Objectif

Définir les frontières officielles des domaines et garantir le **Single Owner Principle**.

## 2. Chaîne produit

```text
Identity → Discovery → Scheduling → Booking → Payment → Consultation → Review
```

Financial, Automation, Events, Meeting, Notification, Permissions et Observability supportent cette chaîne.

## 3. Ownership

### Identity
Possède utilisateur, compte, authentification, session, rôles et statut d'identité.  
Ne possède pas Booking, Payment, Consultation, Ledger ou Settlement.

### Expert
Possède le profil professionnel, expertise, services, tarifs et vérification.  
Référence Identity sans dupliquer le compte.

### Discovery
Possède recherche, filtres, catégories, classement et projections de découverte.  
Ne modifie jamais les agrégats sources.

### Scheduling
Possède calendrier, disponibilité, créneaux, périodes bloquées, timezone et conflits.  
Ne crée pas de Booking.

### Booking
Possède le cycle commercial de réservation : création, confirmation, annulation, expiration, no-show, prix accepté, client/expert et référence de créneau.

Événements principaux :
```text
BookingCreated
BookingConfirmed
BookingCancelled
BookingExpired
BookingPaymentRequested
BookingRefundRequested
BookingFulfilled
```

### Payment
Possède PaymentIntent, PaymentStatus, authorization, capture, failure et refund request côté produit.  
Ne possède pas Ledger ou Settlement.

### Consultation
Possède le cycle de service : préparation, présence, début, durée effective, fin, completion et no-show.

```text
ConsultationStarted
ConsultationCompleted
ConsultationCancelled
ConsultationNoShow
```

### Review
Possède note, commentaire, historique, éligibilité et modération.

### Financial
Possède Ledger, Settlement, transaction, commission, escrow financier, recovery, reconciliation et audit.  
Exécute les conséquences financières de faits métier ; ne possède ni Booking ni Consultation.

### Meeting
Possède room, provider session, token, connexion, reconnexion et fermeture technique.

```text
MeetingClosed != ConsultationCompleted
```

### Automation
Exécute des actions planifiées/différées. Ne crée aucune politique métier.

### Notification
Distribue les messages. Le domaine décide pourquoi ; Notification décide comment livrer.

### Events
Les domaines possèdent les faits. Events possède le mécanisme de transport/dispatch.

## 4. Single Owner Matrix

| Concept | Propriétaire |
|---|---|
| Identité | Identity |
| Profil expert | Expert |
| Disponibilité | Scheduling |
| Réservation | Booking |
| Paiement produit | Payment |
| Consultation | Consultation |
| Salle vidéo | Meeting |
| Ledger | Financial |
| Settlement | Financial |
| Notification | Notification |
| Avis | Review |

## 5. Flux officiel

```text
Discovery
→ Scheduling
→ BookingCreated
→ BookingPaymentRequested
→ PaymentAuthorized
→ BookingConfirmed
→ ConsultationStarted
→ ConsultationCompleted
→ SettlementCompleted
→ ReviewSubmitted
```

## 6. Règle fondamentale

Une règle métier possède un seul propriétaire. Les autres modules peuvent demander, écouter, consommer un contrat ou une projection ; ils ne réimplémentent jamais la règle.

**Status:** APPROVED
