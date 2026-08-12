---
doc: f5-05-reliability
title: F5.5 — Reliability Engineering (état final ratifié)
type: source
titre: production
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 6C)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 6C"
sources_session:
  - "F5.5 — Reliability Engineering Constitution (nature, Fiabilité > Disponibilité, mécanismes de survie, dégradation gracieuse, consensus/split-brain, reprise, Chaos ; lois RY-1→RY-10, 8 anti-patterns) — rédigée par le CTO"
  - "F5.5 — Revue de conformité du Conseil (Reliability owner = personne ; dégradation à deux moitiés ; RY-4 interdits = test structurel ; Brownout = dégradation)"
  - "F5.5.99 — Reliability Constitutional Audit (sept amendements : Isolation à trois échelles ; la Vérification 5e temps ; Recovery→Remplacement/Restauration/Reprise ; identités des politiques de fiabilité ; Load Shedding aveugle au métier ; dégradation à deux issues ; escalade hors politique)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F5.5, après la revue de
  conformité et les sept amendements de F5.5.99. Ce chapitre possède la
  Constitution de la Fiabilité et les lois RY-1→RY-10. Principe : la Fiabilité
  maintient la Constitution vraie, jamais le système vivant à tout prix
  (Fiabilité > Disponibilité). Règle N°18 : le Grand Audit F5.99 (Lot 6E) vérifie
  sans modifier ; règle N°19 : la démonstration FORMELLE de la propriété
  émergente (théorème du consensus) est élevée par F5.99 (Procès III), non
  anticipée ici comme justification. Le vocabulaire Recovery→Remplacement/
  Restauration/Reprise est un amendement Titre VII au Dictionnaire. Scaffolding
  de session exclu.
---

# F5.5 — Reliability Engineering

> État **final ratifié** : F5.5 amendé de la revue de conformité et des sept
> articles de F5.5.99. **Principe** : *la Fiabilité maintient la Constitution
> vraie, jamais le système vivant à tout prix* — hiérarchie irréversible :
> **Fiabilité > Disponibilité** (plutôt refuser que mentir, plutôt s'arrêter
> que violer).

## §1. Nature de la Fiabilité

La Fiabilité continue d'obéir à sa Constitution malgré les fautes ; elle **ne possède rien** (test du pardon : la couche disparaît, les vérités demeurent exactes — le système devient plus fragile, jamais faux). Elle orchestre des mécanismes déjà gelés. **Propriétaire : personne** *(précision de ratification — RY-2)*. *(La caractérisation formelle de la Fiabilité comme **propriété émergente** du Titre Production est établie par le Grand Audit F5.99, Procès I ; ce chapitre en énonce les lois RY.)*

## §2. Disponibilité contre Fiabilité — la hiérarchie sans exception

Disponibilité = *répondre* ; Fiabilité = *répondre juste*. Les quatre combinaisons : *disponible + fiable* (le but) · *disponible + faux* (interdit) · *indisponible + fiable* (acceptable) · *indisponible + faux* (catastrophe). **La Constitution choisit toujours Fiabilité avant Disponibilité** — loi irréversible. *Aucune exception* : répondre-faux reste toujours pire que ne-pas-répondre ; **servir une projection datée-et-avouée n'est pas répondre-faux** (c'est *vieux-mais-honnête*, P17).

## §3. Les mécanismes de survie

Retry · Timeout · Circuit Breaker · Bulkhead · Load Shedding · Brownout · Self Healing — **aucun n'est propriétaire ; tous sont des mécanismes** soumis aux lois existantes. Le Retry ne transforme jamais une Failure en Decision · le Timeout interrompt une attente, jamais un invariant · le Circuit Breaker interrompt un chemin, jamais une vérité · le Bulkhead isole des ressources, jamais des domaines · le Brownout retire du confort, jamais une capacité constitutionnelle · **le Load Shedding refuse par *pression technique* (file pleine, ancienneté, coût), jamais par *valeur de la requête*** *(amendement F5.5.99 : un shedding qui préserve les Premium est un autoscaling-métier, interdit)* · le Self Healing répare uniquement ce que l'Exploitation possède déjà.

## §4. La Dégradation gracieuse — deux propriétaires, deux issues licites

**Deux moitiés** *(précision de ratification)* : *quelles capacités peuvent être retirées* est déclaré par le **propriétaire métier** ; *quand déclencher le mode dégradé* (et en sortir) est un acte d'**Exploitation**, tracé en Main courante. **Le test de licéité (RY-4, structurel)** : une dégradation est licite **si et seulement si** elle laisse *tout refus intact et toute vérité exacte* — les interdits (servir un consentement périmé, inventer un solde, ignorer une révocation, casser un invariant) sont **les quatre visages du seul crime** (transformer un fail-closed en fail-open). **Deux issues licites** *(amendement F5.5.99)* : *retirer une capacité*, **ou** *servir daté-et-avoué* — une seule illicite : *servir faux en silence*.

## §5. Consensus, Quorum et Split Brain — le théorème central

**Mentora ne fonde jamais ses invariants sur un consensus global.** Chasse exhaustive : unicité de créneau (R-A) · un abonnement actif (R-A) · effet unique (Inbox) · porte du refus définitif (frontière du Ledger) · somme du FundsLedger (frontière transactionnelle d'une unité) — **aucun invariant de Mentora ne repose sur un accord global** : tous vivent dans une frontière transactionnelle locale ou une clé de registre. Quorum, Leader, Lease, Election sont des **optimisations d'exécution**, jamais des gardiens. **Le Split-Brain produit du double travail, jamais une double vérité** (RY-7), *parce que* la vérité est protégée sous le niveau où le cerveau se scinde. *(La démonstration formelle de ce théorème comme propriété émergente est élevée par F5.99 Procès III ; ici il gouverne via RY-6/RY-7.)*

## §6. La reprise après panne — cinq temps

**Détection** (F5.3) → **Isolation** (F5.5, trois échelles §7) → **Restauration** (F5.2) → **Réconciliation** (les propriétaires) → **Vérification** *(cinquième temps, amendement F5.5.99 : prouver que le système est de nouveau constitutionnel — invariants tenus, clés R-A cohérentes, aucune projection restée fausse — **fail closed avant le retour au service**, cousine du Boot qui prouve)*. Aucun mécanisme ne saute une étape.

## §7. L'Isolation à trois échelles (amendement F5.5.99)

Trois actes distincts, trois propriétaires : **(a) isoler une ressource** (pool, thread — le Bulkhead) → **Runtime** ; **(b) isoler une instance** (la retirer du service) → **Flotte** (F5.1) ; **(c) isoler une zone/région** (couper un domaine de panne entier) → **Exploitation**, sur politique déclarée, tracée en Main courante. **La Fiabilité n'isole rien elle-même — elle orchestre** ces trois mécanismes possédés ailleurs.

## §8. Chaos Engineering & Auto-Recovery

**Le Chaos est une démonstration** (déclarée, gouvernée, bornée, journalisée, annulable) — il ne touche que les mécanismes, jamais les vérités/propriétaires/politiques ; une expérience *découvre* une faiblesse (qui devient une `VulnerabilityId`/`RiskId` gouvernée). **L'Auto-Recovery** applique une politique déclarée, ne modifie aucune vérité, ne prend aucune décision métier, est journalisé ; **hors du périmètre exact de sa politique déclarée, toute automatisation s'arrête et escalade — elle ne devine jamais** *(amendement F5.5.99 : une politique qui improvise est une décision autonome anonyme, anticonstitutionnelle)*.

## §9. Vocabulaire « Recovery » tranché (amendement F5.5.99)

« Recovery » nu est **banni** ; trois mots réservés — **le Remplacement** (Flotte, F5.1 : une instance morte, une neuve) · **la Restauration** (Persistance, F5.2 : backup, PITR, Perte Déclarée) · **la Reprise** (Fiabilité, F5.5 : les cinq temps). La collision dormait dans trois chapitres à la fois.

## §10. Identités (amendement F5.5.99)

Constitutionnelles (objets gouvernés, versionnés, signés — comme les politiques de sécurité) : `ChaosExperimentId`, `FaultInjectionId`, `ReprisePlanId`, et les **politiques de fiabilité gouvernées** (`ReliabilityPolicyId`, `DegradationPolicyId`, `IsolationPolicyId`, `LoadSheddingPolicyId`). Les paramètres techniques (`CircuitBreaker`, `Brownout`) **restent dans les Fiches** — *gouverné → identité ; configuration → Fiche.*

## §11. Lois RY-1 → RY-10

- **RY-1** La Fiabilité maintient la Constitution vraie, jamais le système vivant.
- **RY-2** La Fiabilité ne possède aucune vérité (propriétaire : personne).
- **RY-3** La disponibilité ne prime jamais la vérité.
- **RY-4** Toute dégradation retire des capacités, jamais des lois (licite ssi tout refus reste intact et toute vérité exacte ; deux issues : retirer, ou servir daté-et-avoué).
- **RY-5** Retry, Timeout, Circuit Breaker, Bulkhead, Brownout sont des mécanismes, jamais des propriétaires ; le Load Shedding refuse par pression technique, jamais par valeur de requête.
- **RY-6** Le consensus n'est jamais gardien d'un invariant métier.
- **RY-7** Le Split Brain ne peut produire qu'un double travail, jamais une double vérité.
- **RY-8** Toute reprise suit : Détection → Isolation (trois échelles) → Restauration → Réconciliation → **Vérification** (fail closed avant retour au service).
- **RY-9** Le Chaos Engineering démontre la Constitution ; il ne la met jamais entre parenthèses.
- **RY-10** Toute récupération automatique applique une politique déclarée, jamais une décision autonome ; hors périmètre, elle escalade.

## §12. Anti-Patterns (8 fiches)

Availability First · Retry infini · Timeout métier · Circuit Breaker législateur · Brownout des invariants · Consensus propriétaire · Self Healing autonome · Split Brain accepté.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F5.5** (rédigée par le CTO), **sa revue de conformité** (Reliability owner = personne ; dégradation à deux moitiés ; RY-4 interdits = test structurel ; Brownout = dégradation) et **F5.5.99** (sept amendements : **Isolation à trois échelles** ; la **Vérification** 5e temps ; **Recovery → Remplacement/Restauration/Reprise** ; identités des politiques de fiabilité ; Load Shedding aveugle au métier ; dégradation à deux issues ; escalade hors politique). **Règle N°24** : la revue et l'audit ne sont pas des sources autonomes — leur contenu reste rattaché à F5.5. **Règle N°18/N°19** : le Grand Audit F5.99 (Lot 6E) vérifie sans modifier ; la démonstration formelle du **théorème du consensus** comme propriété émergente est élevée par F5.99 (Procès III) — ici le théorème gouverne via RY-6/RY-7, il n'est pas invoqué comme justification anticipée. Le vocabulaire Recovery est un amendement Titre VII au Dictionnaire. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
