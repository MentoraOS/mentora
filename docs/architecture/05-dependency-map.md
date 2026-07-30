# Mentora Dependency Map

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion  
**Sprint:** -1.1

## 1. Objectif

Définir la direction officielle des dépendances de Mentora.

```text
Presentation
    ↓
Application
    ↓
Domain

Infrastructure
    ↓
Contracts owned inward
```

## 2. Règles globales

### Domain
Peut dépendre de ses propres types, primitives Shared approuvées et contrats métier.  
Interdit : Flutter, Firebase, Firestore, Agora, SDK PSP, UI, repositories concrets et internals d'autres domaines.

### Application
Peut dépendre du Domain, contrats publics inter-domaines, gateways plateforme, repositories abstraits, Events et Clock.  
Interdit : SDKs et implémentations Infrastructure concrètes.

### Presentation
Peut dépendre des controllers/use cases/view models.  
Interdit : Firestore, FirebaseAuth, PSP adapters, Ledger/Settlement internals.

### Infrastructure
Implémente les contrats internes et peut utiliser les SDK externes.  
Ne définit aucune politique métier.

## 3. Règles critiques

- Aucun cycle entre modules.
- Un module expose une API publique limitée.
- Un fait métier possède un événement canonique.
- Shared ne contient pas de logique métier.
- Production dependencies sont assemblées dans un Composition Root.

## 4. Dépendances produit

### Booking
Autorisé : Identity refs, Expert refs, Scheduling contracts, Pricing contracts, Payment contracts, Events, Notification intent, Automation, Shared, Clock, persistence contracts.  
Interdit : Financial internals, Ledger, Settlement, Agora, Firestore concret, UI.

### Scheduling
Autorisé : Identity/Expert IDs, time primitives, Events, persistence contracts, Clock.  
Interdit : Booking internals, Payment, Financial, Consultation, Meeting.

### Payment
Autorisé : Booking payment request contracts, Financial Gateway, Events, Money primitives, persistence contracts.  
Interdit : Ledger/Settlement internals, PSP SDKs, Booking internals.

### Consultation
Autorisé : Booking public contracts, Meeting public contracts, Events, Notification/Automation contracts, Clock.  
Interdit : Financial internals, Ledger, Settlement, Agora SDK, Booking internals.

### Review
Autorisé : Consultation completion read contract, IDs, Events et persistence.  
Interdit : Payment, Financial et internals des autres domaines.

## 5. Platform

### Financial
Public entry point : `MentoraFinancialGateway`.  
Aucun produit ne doit importer `financial/ledger/*`, `settlement/internal/*`, `pipeline/internal/*` ou `runtime/internal/*`.

### Automation
Peut dépendre de Events, Scheduler, Notification, Observability et persistence contracts.  
Ne dépend pas des internals produit.

### Meeting
Expose des contrats de room/token/presence ; Agora reste en Infrastructure.

### Notification
Expose Push/SMS/Email/In-App ports ; les SDKs restent en Infrastructure.

## 6. Communication

**Synchronous contract** lorsqu'une décision immédiate est requise :

```text
Booking → Scheduling.validateSlot()
Booking → Pricing.quote()
Payment → Financial.authorize()
Consultation → Meeting.createRoom()
```

**Event** lorsqu'un fait a déjà eu lieu :

```text
BookingConfirmed
PaymentCaptured
ConsultationCompleted
SettlementCompleted
```

## 7. Flux officiel

```text
Presentation
→ Booking Application
→ Scheduling / Pricing contracts
→ Booking
→ Payment
→ Financial Gateway
→ PSP Adapter

BookingConfirmed
→ Consultation
→ Meeting contract

ConsultationCompleted
→ Financial Settlement

SettlementCompleted
→ Review eligibility
```

## 8. Composition Root

```text
main.dart
  → AppBootstrap
  → AppContainer
  → MentoraApp
```

Les implémentations concrètes sont sélectionnées uniquement au niveau composition.

## 9. Enforcement

Tests d'architecture à introduire progressivement :

```text
domain_must_not_import_flutter_test
domain_must_not_import_firebase_test
presentation_must_not_import_firestore_test
booking_must_not_import_financial_internals_test
consultation_must_not_import_agora_test
payment_must_not_import_psp_sdk_test
no_circular_module_dependency_test
```

**Status:** APPROVED
