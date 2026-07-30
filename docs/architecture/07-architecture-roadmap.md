# Mentora Architecture Roadmap

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion

## 1. Vision

Faire évoluer Mentora sans réécriture massive : stabiliser l'architecture, terminer le parcours produit, préparer la production, puis scaler.

```text
Phase 0 — Architecture Stabilization
Phase 1 — Core Product Completion
Phase 2 — Production Readiness
Phase 3 — Scalability
Phase 4 — Enterprise Expansion
```

## 2. Phase 0 — Stabilization

Livrables :
- Current State Map
- Module Registry
- Domain Boundaries
- Overlap Register
- Dependency Map
- Decision Log
- Architecture Roadmap
- Compliance Checklist
- enforcement progressif

Exit : tout développement connaît son propriétaire et ses dépendances autorisées.

## 3. Phase 1 — Core Product Completion

### Sprint 1 — Booking Core
Aggregate, repository, use cases, state transitions, events, tests.

### Sprint 2 — Scheduling Core
Availability, Slot Hold, Calendar, Conflict Detection, Timezone.

### Sprint 3 — Payment Integration
PaymentIntent, Authorization, Capture, Refund, Financial Gateway.

### Sprint 4 — Consultation Core
Lifecycle, Presence, Duration, Completion, Meeting integration.

### Sprint 5 — Review Core
Ratings, reviews, eligibility, moderation, history.

Exit Phase 1 :

```text
Discovery → Scheduling → Booking → Payment → Consultation → Settlement → Review
```

fonctionne de bout en bout.

## 4. Phase 2 — Production Readiness

Authentication hardening, Permissions, Observability, logs structurés, metrics, crash reporting, configuration, secrets, feature flags, backup/recovery, performance et audit.

## 5. Phase 3 — Scalability

Optimisations uniquement selon données réelles : caching, queues, read models, CQRS ciblé, pagination, search/indexation et optimisation Firestore.

## 6. Phase 4 — Expansion

Après maturité du cœur :
1. Enterprise
2. Workspace
3. Learning
4. AI

## 7. Migration Cycle

```text
Tests
→ Identifier dépendances
→ Créer/valider contrats
→ Migrer le périmètre utile
→ Format/analyze/tests
→ Retirer legacy devenu inutile
→ Mettre à jour documentation
```

## 8. Financial Strategy

`FREEZE`.

Autorisé : bugs, sécurité, tests, documentation, PSP, refactoring local nécessaire.  
Tout nouveau moteur/pipeline/orchestrateur/sous-domaine exige une décision CTO.

## 9. KPIs

- nouveaux cycles : 0
- nouveaux Firestore directs Presentation/Domain : 0
- SDK PSP Domain : 0
- Agora Consultation Domain : 0
- tests concernés : 100 % verts
- nouvelle violation P0 non enregistrée : 0

## 10. Definition of Done

Code formaté, analyse conforme au baseline, tests verts, frontières et dépendances conformes, contrats/événements documentés, aucune nouvelle dette P0 silencieuse.

**Status:** APPROVED
