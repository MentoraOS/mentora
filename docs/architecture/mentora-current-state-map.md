# Mentora Current-State Architecture Map

**Document status:** Baseline architecture audit  
**Sprint:** -1.1 — Architectural Truth and Official Module Registry  
**Scope:** Current repository state only. This document describes what exists; it does not yet prescribe the target architecture.

## 1. Repository overview

The repository is a Flutter application named `mentora`.

### 1.1 Source distribution

| Area | Dart files | Observation |
|---|---:|---|
| `lib/core` | 654 | Dominant area of the repository. Most platform, domain and engine logic is concentrated here. |
| `lib/screens` | 59 | Main presentation layer, mostly screen-oriented and directly connected to Firebase in several places. |
| `lib/features` | 23 | Used almost entirely by the Enterprise feature, following a more feature-first/clean-architecture style. |
| `lib/domain` | 3 | Small parallel domain area, separate from the numerous `lib/core/*/domains` directories. |
| `lib/presentation` | 2 | Minimal parallel presentation area. |
| `lib/widgets` | 3 | Small shared widget area. |
| `lib/theme` | 3 | Theme definitions and provider. |
| `lib/ai` | 1 | Isolated AI-related source. |
| `lib/config` | 1 | Small configuration area. |
| **Total `lib`** | **751** | The repository is strongly core-centric. |

### 1.2 Test distribution

| Area | Dart test files | Observation |
|---|---:|---|
| `test/architecture` | 132 | All discovered Dart tests are concentrated here. |
| Other unit test folders | 0 | No feature-specific unit test structure was found. |
| `integration_test` | 0 discovered | No Flutter integration-test suite was found in the repository snapshot. |

The current test strategy therefore emphasizes architecture and low-level behavior rather than complete user journeys.

### 1.3 Generated and local-state content included in the archive

The archive contains development and generated directories, including:

- `.dart_tool`
- `.idea`
- `build`
- `android/.gradle`
- `android/.kotlin`

These directories are not part of the product architecture but increase repository/archive noise and should not be used to assess source-code volume.

### 1.4 Project metadata

The package name is correctly set to `mentora`, but the project description remains the Flutter default:

```yaml
description: "A new Flutter project."
```

The declared application dependencies include:

- Flutter
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Agora RTC Engine
- Permission Handler
- Provider
- PDF and Printing
- Intl and Collection

The dependency set confirms that the current application combines product UI, Firebase-backed persistence/authentication, video consultation, document generation and a large internal platform core.

---

## 2. Application entry point

The application entry point is `lib/main.dart`.

### 2.1 Responsibilities currently handled by `main.dart`

The file currently performs all of the following:

1. Flutter binding initialization.
2. Firebase initialization.
3. Session bootstrap.
4. `MentoraOS` initialization.
5. `MentoraOS` startup.
6. Theme-provider creation.
7. Material application creation.
8. Authentication-state observation through `FirebaseAuth.instance`.
9. Direct Firestore lookup of the authenticated user.
10. Role-based routing between expert and client dashboards.
11. Login fallback behavior.
12. Splash-screen implementation and animation.
13. Onboarding navigation initiation.
14. Definition of global visual constants such as `navy` and `gold`.

### 2.2 Current architectural characteristics

`main.dart` is simultaneously:

- a process entry point;
- a composition root;
- an authentication adapter;
- a Firestore adapter;
- a role router;
- an application shell;
- a splash-screen implementation.

This is a factual description of the current state. It indicates that startup, infrastructure and presentation responsibilities are presently colocated.

### 2.3 Direct infrastructure access at startup

The entry point directly references:

```dart
FirebaseAuth.instance
FirebaseFirestore.instance
```

This means the application shell currently depends on Firebase concrete implementations instead of application-level contracts.

---

## 3. Product-oriented modules

The following modules represent or approximate Mentora's main user-facing value chain.

## 3.1 Booking

**Location:** `lib/core/booking`  
**Dart files:** 9

### Present structure

```text
booking/
├── domains/
├── engine/
├── models/
├── repositories/
├── services/
└── workflows/
```

### Present responsibilities

The module currently supports:

- a `Booking` model;
- booking statuses: `draft`, `pending`, `confirmed`, `locked`, `consumed`, `cancelled`, `expired`;
- creation, confirmation and cancellation;
- lookup by identifier;
- lookup by expert and client;
- in-memory persistence;
- time-range validation;
- overlap detection for the same expert;
- a create-booking workflow using the generic workflow core.

### Current implementation characteristics

- `BookingDomain` coordinates repository access and validation.
- `BookingEngine` is a thin wrapper over the domain.
- `MemoryBookingRepository` is the only repository implementation found in this module.
- Booking state transitions are performed by constructing a new `Booking` object.
- The model has no price, currency, payment reference, cancellation policy, audit metadata or persistence version.
- The create workflow depends directly on `lib/core/workflow`.

### Current maturity observation

The module provides an initial booking domain foundation, but it does not yet represent a complete production booking lifecycle.

## 3.2 Scheduling

**Location:** `lib/core/scheduling`  
**Dart files:** 11

### Present responsibilities

The module contains concepts for:

- availability;
- availability rules;
- blocked periods;
- calendar slots;
- working hours and weekdays;
- timezone information;
- availability calculation;
- timezone calculation;
- scheduling orchestration.

### Current architecture

The module uses `domains`, `engine` and `models` directories. No dedicated repository directory was found in the current scheduling tree.

## 3.3 Consultation

**Location:** `lib/core/consultation`  
**Dart files:** 10

### Present responsibilities

The module contains:

- consultation model and type;
- consultation status;
- consultation result;
- domain and engine;
- state machine;
- repository contract;
- in-memory repository;
- create-consultation workflow.

The consultation module exists as a distinct concept from Booking and Meeting.

## 3.4 Meeting

**Location:** `lib/core/meeting`  
**Dart files:** 13

### Present responsibilities

The module contains:

- meeting model;
- meeting status;
- meeting provider;
- meeting result;
- meeting domain and engine;
- room service;
- token service;
- meeting state machine;
- repository contract;
- in-memory repository;
- create-meeting workflow.

Agora is used elsewhere in the screen layer, while this module defines provider and token abstractions at core level.

## 3.5 Payment

**Location:** `lib/core/payment`  
**Dart files:** 9

### Present responsibilities

The module contains:

- payment model;
- payment method;
- payment status;
- payment result;
- payment domain and engine;
- payment state machine;
- repository contract;
- in-memory repository.

This module is distinct from both `lib/core/financial` and `lib/core/engines/payment`.

## 3.6 Pricing

**Location:** `lib/core/pricing`  
**Dart files:** 7

Pricing is a standalone core module. It is currently separate from Booking and Financial, creating a three-way boundary among product pricing, payment intent and financial execution.

## 3.7 Escrow

**Location:** `lib/core/escrow`  
**Dart files:** 8

Escrow is represented as a standalone core module. Its in-memory repository includes nullable lookup behavior. The presentation layer also contains escrow-related screens for experts and clients.

## 3.8 Identity, session, roles and permissions

Identity-related responsibilities are distributed across several locations:

```text
lib/core/identity
lib/core/session
lib/core/roles
lib/core/permissions
lib/core/routing
```

`lib/core/identity` alone contains 19 Dart files and includes domains, engines, entities, models, repositories and token services.

The startup flow also accesses Firebase Authentication directly, so identity behavior currently exists both inside the core and inside the application entry/presentation flow.

## 3.9 Notification

**Location:** `lib/core/notification`  
**Dart files:** 18

The module includes:

- notification domain and engine;
- notification models;
- strategy registry;
- notification router;
- repository contract and memory repository;
- templates;
- booking-confirmed strategy and listener.

A separate notification model and notification repository also exist under `lib/core/events`, producing an overlap between events and notification concerns.

## 3.10 Enterprise

Enterprise capability exists in three substantial areas:

```text
lib/core/enterprise
lib/features/enterprise
lib/screens/enterprise
```

### Core Enterprise

`lib/core/enterprise` contains 31 Dart files for:

- organization;
- hierarchy;
- department;
- team;
- employee;
- workspace;
- projects;
- tasks;
- enterprise memberships, roles and permissions;
- statistics;
- an `AtlasEngine`.

Several repository implementations use hard-coded `mentora_demo` data or nullable placeholder behavior.

### Feature-first Enterprise

`lib/features/enterprise` contains 23 Dart files and uses a separate architecture:

```text
data/
domain/
presentation/
```

It includes enterprise invitations, members, use cases, workflows, controllers and Firestore repositories.

### Enterprise presentation

`lib/screens/enterprise` contains employee-learning, HR, finance and executive dashboard screens. Some UI actions remain marked with TODO comments.

Enterprise is therefore one of the most structurally developed product areas, despite being separate from Mentora's core booking-consultation journey.

---

## 4. Platform-oriented modules

## 4.1 Financial

**Location:** `lib/core/financial`  
**Dart files:** 293

Financial is the largest module in the repository by a wide margin.

### Present capability groups

The source tree includes, among others:

- domain abstractions;
- money and currency primitives;
- ledger accounts and entries;
- journal posting;
- journal queries;
- general ledger reporting;
- trial balance;
- settlements;
- fees;
- splits;
- financial transactions;
- transaction boundaries;
- pipelines;
- pipeline metrics;
- recovery engines and strategies;
- orchestration;
- runtime;
- workflow registry;
- persistence adapters, including Firestore settlement storage.

### Current implementation characteristics

The module demonstrates a high degree of architectural decomposition and test coverage relative to other product modules.

Current incomplete or constrained points identified in the source include:

- Firestore settlement repository methods returning `null` in some paths;
- unsupported settlement posting categories for affiliate and partner commissions;
- multiple nullable lookup methods across registries and reporting objects;
- in-memory implementations used throughout testing;
- overlap with `lib/core/engines/financial`.

### Current-state conclusion

Financial is architecturally much more mature and much larger than Booking, Consultation, Scheduling and Meeting combined.

## 4.2 Engines

**Location:** `lib/core/engines`  
**Dart files:** 64

This directory contains additional engines, including separate payment and financial implementations.

### Payment provider registry

`lib/core/engines/payment/registry/payment_provider_registry.dart` registers:

```dart
PaymentProviderType.mock: MockPaymentProvider()
```

The discovered provider implementation is a mock provider. No production PSP adapter was identified in the current registry.

### Financial engines

`lib/core/engines/financial` includes Firestore and in-memory ledger repositories, withdrawal handling and financial ledger factories. This overlaps conceptually with the much larger `lib/core/financial` module.

## 4.3 Automation

**Location:** `lib/core/automation`  
**Dart files:** 31

The module currently contains:

- domain models;
- registry;
- repository contracts and in-memory implementations;
- execution engine;
- execution context and result;
- executor contract;
- runtime;
- orchestrator;
- bootstrap;
- module composition.

Automation is implemented as a reusable platform subsystem and is currently under active test development.

## 4.4 Events

**Location:** `lib/core/events`  
**Dart files:** 18

The module contains:

- generic event models;
- Phoenix-specific event models;
- event context and metadata;
- event bus and engine;
- listeners;
- filters;
- event registry;
- event and notification repositories;
- event builder and dispatcher.

The use of Phoenix naming inside the generic events module creates a direct structural relationship with `lib/core/phoenix`.

## 4.5 Workflow

**Location:** `lib/core/workflow`  
**Dart files:** 12

The module defines:

- workflow abstraction;
- context;
- execution;
- result;
- state;
- event;
- exception;
- engine;
- middleware;
- pipeline;
- registry.

It is used by Booking, Consultation and Meeting create workflows. It also contains an employee-onboarding workflow.

## 4.6 Business process

**Location:** `lib/core/business_process`  
**Dart files:** 13

The module defines another generic process and pipeline abstraction, but its concrete implementation is focused on enterprise onboarding:

- create organization;
- create owner;
- create workspace;
- enterprise onboarding context, pipeline and process.

This capability overlaps in naming and behavior with Workflow and Enterprise.

## 4.7 Phoenix

**Location:** `lib/core/phoenix`  
**Dart files:** 17

Phoenix includes:

- bootstrap;
- orchestrator;
- execution engine and pipeline;
- orchestration rules and registries;
- booking execution context;
- booking pipeline builder;
- booking pricing step;
- booking payment step;
- booking orchestration service.

Phoenix therefore acts as a second orchestration layer around booking, pricing and payment, alongside Booking workflows and the generic Workflow core.

## 4.8 Shared, bootstrap and dependency injection

The repository includes:

```text
lib/core/shared
lib/core/bootstrap
lib/core/di
lib/core/services
lib/core/config
```

Dependency assembly is not fully centralized because concrete services are also created or accessed from `main.dart`, screen files and individual bootstrap classes.

## 4.9 Timer

`lib/core/timer` contains nine Dart files and an in-memory repository. This is a reusable time-based platform capability separate from Automation and Scheduling.

## 4.10 Learning and workspace

`lib/core/learning` and `lib/core/workspace` are substantial independent capabilities. Their repositories include Firestore or nullable placeholder behavior. They align more closely with the Enterprise learning area than with the booking-consultation core journey.

---

## 5. Infrastructure dependencies

## 5.1 Firebase

Firebase or Firestore imports occur in:

- application startup;
- session bootstrap and repository;
- DI/bootstrap modules;
- financial ledger and withdrawal infrastructure;
- financial settlement infrastructure;
- workspace repositories;
- Enterprise feature data adapters;
- numerous screen files.

### Screen-level direct Firebase access

Direct Firebase/Firestore usage was identified in screens including:

- client dashboard;
- expert dashboard;
- expert agenda;
- expert detail;
- booking detail;
- my bookings;
- my payments;
- profile and edit profile;
- pre-consultation;
- session completion and session lists;
- withdrawal administration and history;
- expert escrow list;
- favorite experts.

This shows that a significant portion of the product UI currently integrates directly with infrastructure.

## 5.2 Agora

Agora is declared as a dependency and used in the video-call screen path. The core Meeting module also defines meeting provider and token concepts, but the exact end-to-end boundary between screen-level Agora integration and core meeting abstractions is not fully unified.

## 5.3 In-memory repositories

In-memory repository implementations exist across major modules, including:

- Booking;
- Consultation;
- Meeting;
- Payment;
- Escrow;
- Automation;
- Ledger;
- Timer;
- Notification.

They provide testability and prototypes but are not production persistence adapters.

## 5.4 Production payment provider

The registered payment provider identified in the source is a mock implementation. No production provider registry entry was found for a PSP such as PayDunya, CinetPay, Orange Money, Wave or Stripe.

---

## 6. Presentation structure

The presentation layer is currently distributed across:

```text
lib/main.dart
lib/screens
lib/features/enterprise/presentation
lib/presentation
lib/widgets
```

## 6.1 Main screen collection

`lib/screens` includes user-facing flows for:

- client and expert dashboards;
- expert discovery and profile;
- booking and booking success;
- booking details and history;
- payments and payment history;
- escrow and expert wallet;
- consultation preparation;
- waiting room and joining flow;
- video call;
- session completion;
- chat;
- notifications;
- profile editing;
- withdrawals;
- admin and financial dashboards;
- masterclass;
- enterprise employee, executive, finance and HR dashboards.

## 6.2 Presentation architecture variation

Most screens are flat files under `lib/screens`, while Enterprise uses a feature-first presentation structure with controllers and screens. This confirms that at least two presentation conventions coexist.

## 6.3 UI-to-core relationship

Several screens directly call Firebase rather than consistently using domain/application services. As a result, the UI layer currently contains both presentation behavior and data-access logic.

---

## 7. Testing structure

## 7.1 Current test focus

All 132 discovered Dart test files are under `test/architecture`.

The test suite strongly covers platform components such as:

- automation domain, registry, repository and context;
- financial ledger models and repositories;
- journal posting and reporting;
- transaction boundaries;
- financial runtime;
- financial recovery;
- settlement pipeline components;
- workflow and platform-level invariants.

## 7.2 Missing or underrepresented test categories

No separate test organization was found for:

- Booking feature behavior;
- Scheduling feature behavior;
- Consultation lifecycle;
- Meeting lifecycle;
- screen/widget behavior;
- Firebase adapter integration;
- Agora integration;
- real PSP integration;
- complete client booking journey;
- complete expert consultation journey;
- end-to-end payment-to-settlement journey.

## 7.3 Current test maturity imbalance

Financial and architecture-level components receive significantly more test investment than the primary product journey.

---

## 8. Architectural overlaps

The following overlaps exist in the current repository and require formal resolution in the module registry phase.

## 8.1 Payment-related overlap

```text
lib/core/payment
lib/core/engines/payment
lib/core/financial
lib/core/engines/financial
lib/core/escrow
lib/core/pricing
```

These areas collectively cover payment state, provider execution, ledger, settlement, escrow, fees and pricing, but there is no single documented public boundary among them.

## 8.2 Orchestration overlap

```text
lib/core/workflow
lib/core/business_process
lib/core/phoenix
lib/core/automation
lib/core/engines
```

All contain some combination of engine, pipeline, orchestration, rule, step, workflow or runtime concepts.

## 8.3 Booking journey overlap

```text
lib/core/booking
lib/core/scheduling
lib/core/consultation
lib/core/meeting
lib/core/phoenix/orchestrator
lib/screens/*booking*
lib/screens/*consultation*
lib/screens/*session*
```

The journey exists across multiple modules and presentation implementations, with no single application-layer coordinator serving as the canonical entry point.

## 8.4 Identity overlap

```text
lib/core/identity
lib/core/session
lib/core/roles
lib/core/permissions
lib/core/routing
lib/main.dart Firebase auth flow
```

Identity, authentication, role resolution and navigation are spread across platform and presentation layers.

## 8.5 Events and notification overlap

```text
lib/core/events
lib/core/notification
lib/core/phoenix
```

Events includes notification models and repositories, while Notification includes its own models, repository, strategies and listeners. Phoenix-specific event abstractions also appear inside Events.

## 8.6 Architectural-style overlap

The repository currently uses all of the following organizational styles:

- flat screens;
- `core/<module>/domains-engine-models`;
- feature-first clean architecture under Enterprise;
- top-level `domain` and `presentation` folders;
- generic engine collections;
- dedicated platform modules.

No single style currently governs the full repository.

---

## 9. Known incomplete implementations

The following incomplete or placeholder behaviors were identified in the current source snapshot.

### 9.1 Payment and financial

- The payment provider registry uses `MockPaymentProvider`.
- Affiliate commission settlement posting throws `UnsupportedError`.
- Partner commission settlement posting throws `UnsupportedError`.
- Firestore settlement repository contains nullable/unimplemented paths.
- Several financial registries and recovery strategies use nullable lookups.

### 9.2 Enterprise

- Multiple repositories use hard-coded `mentora_demo` records.
- Several repository lookups return `null` as placeholder behavior.
- Employee-learning quick actions contain TODO markers.

### 9.3 Notification

- `NotificationFactory` contains a nullable creation path.

### 9.4 Escrow, session, learning, timer and services

- In-memory escrow repository contains nullable lookup methods.
- Session repository contains nullable lookup methods.
- Learning repositories contain nullable lookup methods.
- Timer repository contains nullable lookup behavior.
- Cache service contains nullable lookup behavior.

### 9.5 Firebase platform support

`firebase_options.dart` throws `UnsupportedError` for unsupported target platforms. This is typical of generated Firebase configuration but means platform support depends on the configured targets.

### 9.6 Project identity

The `pubspec.yaml` project description remains the default Flutter placeholder.

---

## 10. Current-state conclusions

The present repository represents an ambitious platform-oriented Flutter system rather than a narrowly scoped booking application.

The observable current state is:

1. **Financial infrastructure dominates the codebase.**  
   Financial alone contains 293 Dart files, compared with 9 for Booking, 11 for Scheduling, 10 for Consultation and 13 for Meeting.

2. **The primary product journey exists, but is fragmented.**  
   Booking, Scheduling, Consultation, Meeting, Payment and Phoenix orchestration each contain parts of the journey.

3. **Multiple architectural styles coexist.**  
   Core-module architecture, feature-first architecture, flat screens and top-level domain/presentation folders are all present.

4. **The startup path is highly coupled.**  
   `main.dart` combines bootstrapping, Firebase, role resolution, routing, theme and splash presentation.

5. **UI infrastructure coupling is widespread.**  
   Many screens use Firebase or Firestore directly.

6. **The Financial Core is technically advanced but not connected to a production PSP.**  
   The provider registry currently exposes a mock provider, and some settlement categories remain unsupported.

7. **Testing is strong at platform level but weak at product-journey level.**  
   All tests are concentrated in `test/architecture`; no complete end-to-end booking journey suite was identified.

8. **Enterprise is disproportionately developed relative to Booking.**  
   Enterprise exists in core, feature and screen layers and includes learning and organizational capabilities.

9. **Orchestration concepts overlap.**  
   Workflow, Business Process, Phoenix, Automation and Engines all contain pipeline/orchestration abstractions.

10. **The repository requires an official module registry before further structural development.**  
    The next audit artifact must assign each module one official responsibility, status and boundary.

---

## Audit baseline summary

```text
Primary source files                 751 Dart files
Core source files                    654 Dart files
Architecture tests                   132 Dart files
Financial core                       293 Dart files
Booking core                           9 Dart files
Scheduling core                       11 Dart files
Consultation core                     10 Dart files
Meeting core                          13 Dart files
Automation core                       31 Dart files
Enterprise core                       31 Dart files
Production PSP registered              0 identified
Mock PSP registered                    1
Integration-test suite                 0 identified
```

**Next document:** `docs/architecture/02-module-registry.md`
