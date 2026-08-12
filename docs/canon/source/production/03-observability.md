---
doc: f5-03-observability
title: F5.3 — Observability, Telemetry & Operational Intelligence (état final ratifié)
type: source
titre: production
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 6B)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 6B"
sources_session:
  - "F5.3 — Observability, Telemetry & Operational Intelligence Constitution (nature, Journal/Log/Enveloppe, métriques/SLI/SLO, traces, intelligence opérationnelle, alerting, tableaux, gouvernance ; la Main courante ; lois O-1→O-10, 8 anti-patterns)"
  - "F5.3.99 — Observability Constitutional Audit (sept amendements : Pipeline de télémétrie ; l'Incident unité d'exploitation ; la Main courante = Registre d'exploitation ; le Relevé d'accès ; table des identités + Catalogue des métriques ; le Sampling ; le Runbook)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F5.3, après les sept
  amendements de F5.3.99. Ce chapitre possède la Constitution de l'Observabilité
  et les lois O-1→O-10. Principe : l'Observabilité décrit le système, elle ne le
  gouverne jamais. Règle N°18 : le Grand Audit F5.99 (Lot 6E) vérifie sans
  modifier ; ses propriétés émergentes sont sa propriété exclusive. Le Relevé
  d'accès est transmis à F5.4 comme sa première pièce. Scaffolding de session
  exclu. Titre VII pour toute évolution.
---

# F5.3 — Observability, Telemetry & Operational Intelligence

> État **final ratifié** : F5.3 amendé des sept articles de F5.3.99.
> **Principe** : *l'Observabilité décrit le système ; elle ne le gouverne jamais.*

## §1. Nature de l'Observabilité

**L'Observabilité est la projection intégrale de l'état du système** : elle lit tout, **ne possède rien** (chaque artefact passe le test du pardon), et n'a **aucun droit d'écriture** nulle part. La fédération en lecture est sa définition entière. Ce qui ne passe pas le pardon n'est pas de l'observabilité : c'est une vérité égarée.

## §2. Les couches d'émission — quatre objets (le 4e né de F5.3.99)

- **le Journal** — réservé, **applicatif**, les pas des Séquences (F4.1) — **probant**.
- **le Log** — le nom officiel de l'émission **technique** (Runtime, adapters, moteurs) — **perdable et borné**.
- **l'Enveloppe** — le transport (F4.3).
- **le Relevé d'accès** *(amendement F5.3.99)* — la trace d'accès aux données protégées : **enregistrement probant** (rétention longue, gouverné) — il **ne passe pas le pardon** (le perdre exige un pardon juridique) ; son traitement complet appartient à **F5.4** (chapitre 04). *Quatre objets — le quatrième se cachait dans le troisième.*

Lois communes : **aucune matière, aucun secret** (P7), corrélation portée quand elle existe, horodatage de la couche émettrice. Les « événements techniques » sont des **Logs structurés**, jamais des Domain Events.

## §3. Metrics, SLI, SLO, Error Budgets

**Toutes les métriques sont des lectures d'exploitation** (y compris les taux de Reasons) — *dérivées des journaux et des faits, jamais consultées par une Séquence* (structurellement : aucun port de métrique n'existe dans la Séquence — I-1). **SLI/SLO** = promesses d'exploitation déclarées (par exécutable et par registre — les Fiches). **L'Error Budget** = un instrument de **cadence** (il gouverne la prudence des déploiements — politique de Flotte) — il **ne touche jamais une Command, une Policy, un refus**.

## §4. Tracing, Correlation, Timeline

**La Trace est l'ombre échantillonnable d'un passage** (reconstruite depuis les Enveloppes : CorrelationId, CausationId). **La chaîne éternelle n'est pas la trace** : c'est la provenance des faits (F3) et la corrélation des journaux (F4.1) — l'audit se refait **sans traces**. Le **Profiling** = des ombres de ressources, au Runtime.

## §5. Operational Intelligence

**Des propositions à l'Exploitation** — citées, incertitude dite (la grammaire AE, appliquée à l'outillage). **La frontière Alert → Automation** est fermée par construction : une automatisation n'agit que sur **les droits de l'Exploitation** (table de souveraineté F5.1.99) ; le chemin vers le métier est fermé par la liste close des émetteurs de Commands (M-10). **L'AIOps propriétaire** (qui décide) est mort ; l'IA qui *propose* aux opérateurs est la bienvenue, citée.

## §6. Alerting & Incident Detection

**Le Signal reste au produit** (la Notification, aux personnes) ; **l'Alerte** est le mot officiel de l'exploitation (aux opérateurs et automatisations de Flotte) — deux canaux, zéro croisement. **Lois de l'Alerte** : une alerte **constate et nomme son runbook** (une alerte sans runbook est du bruit — interdite), alerte sur des **symptômes**, porte une sévérité, est **actionnable ou n'existe pas**. Elle ne commande jamais.

## §7. Dashboards & Operational Views

Les tableaux sont des **vues composées de projections d'exploitation** — mécanismes-puits. **Le test du pardon appliqué à l'écran** : le tableau disparaît, le métier continue. **Aucune curation d'écran ne devient une vérité** : ce qui doit durer migre vers la Main courante (un fait d'exploitation) ou vers une citation datée — jamais un état du dashboard.

## §8. Profiling, Capacity Planning & Cost Intelligence

Le profil (ressources), la capacité (propositions de dimensionnement, citées), le coût (projection financière — **jamais un signal de confiance, jamais une entrée du métier** ; *le coût ne module jamais un refus*). Le forecast obéit à la loi des projections.

## §9. Le Pipeline de télémétrie (amendement F5.3.99)

> **Le Pipeline de télémétrie** (collecte, transport, stockage, purge) est un **outillage d'Exploitation** — configuration technique, mécanismes libres ; l'émission neutre reste à nous (O-10), les puits interchangeables. *(Le propriétaire oublié, trouvé.)*

**Le Sampling** *(amendement F5.3.99)* : une **politique d'exploitation déclarée** (ce qui est toujours conservé, ce qui est échantillonné, à quel taux) — **licite sur le perdable seul** ; échantillonner le Journal, le Relevé d'accès, les Alertes ou la Main courante est **illégal** (ils sont probants).

## §10. Operational Governance & Auditability

**La hiérarchie de la preuve** : ce qui fait foi = **les registres, les faits, les polices, le Journal applicatif** (immuables, gouvernés). L'observabilité (Logs, métriques, traces, tableaux, alertes) est **perdable, bornée, jamais probante pour le métier**.

**L'Incident** *(amendement F5.3.99)* — **une unité de vérité D'EXPLOITATION** : un propriétaire (l'Exploitation), un cycle **`Ouvert → Maîtrisé → Résolu → Clos`** (quatre états, le dernier terminal), des décisions (sévérité, clôture par le commandant d'incident), une histoire, une identité (`IncidentId`). *La nuance qui sauve le principe de F5* : la Production ne possède aucune vérité *métier*, mais les vérités *d'exploitation* existent (la Fiche, la Main courante) — elles ne commandent jamais le produit et obéissent aux mêmes grammaires (**la réouverture n'existe pas : un incident rouvert est un incident NOUVEAU à provenance, R-B appliquée à l'exploitation**).

**La Main courante = le Registre d'exploitation** *(amendement F5.3.99)* : la mémoire des **actes d'exploitation** (restaurations, replays, gels, silences d'alertes, bascules de moteur, Réadmissions), **des Incidents**, des Pertes Déclarées et des dossiers de Réadmission — possédée par l'Exploitation, gouvernée, à rétention longue, probante **pour la gouvernance opérationnelle** (qui a fait quoi sur la machine — distincte du Journal, qui a exécuté quoi dans le produit). **Tout silence d'alerte est un acte tracé** en Main courante.

**Le Runbook** *(amendement F5.3.99)* : un **document gouverné, versionné** (catégorie des documents de gouvernance, comme les ADR) ; la version utilisée est **citée dans l'incident** (provenance) ; l'améliorer à chaud crée une version nouvelle notée. **Identités** (amendement) : `AlertId`, `IncidentId`, `RunbookId`, et le **Catalogue des noms de métriques** (un nom de métrique est un mot du vocabulaire d'exploitation) ; `TraceId`/`SpanId` sont des dialectes ; `SessionId` **réservé à I&A** (collision interdite en télémétrie).

## §11. Lois O-1 → O-10

- **O-1** L'Observabilité lit tout, ne possède rien, n'écrit nulle part ; chaque artefact passe le test du pardon.
- **O-2** Trois couches, trois mots : le Journal (application), le Log (technique), l'Enveloppe (transport) — aucune matière, aucun secret. *(Plus le Relevé d'accès, probant — §2.)*
- **O-3** Métriques, SLI, SLO à l'Exploitation ; l'Error Budget gouverne des cadences, jamais des Commands ; aucune métrique n'entre dans une Séquence.
- **O-4** La Trace est une ombre échantillonnable ; la chaîne éternelle est la provenance des faits et la corrélation des journaux — l'audit se refait sans traces.
- **O-5** Une Alerte constate un symptôme, nomme son runbook, porte sa sévérité, et prévient — opérateurs par l'Alerte, jamais les personnes ; actionnable ou inexistante.
- **O-6** L'automatisation n'agit que sur les droits de l'Exploitation via politiques déclarées ; le chemin vers le métier est fermé par la liste close des émetteurs.
- **O-7** L'intelligence opérationnelle propose — citée, incertitude dite ; jamais une Decision, une Policy, un fait, un refus.
- **O-8** Les tableaux sont des vues ; toute curation durable est un fait de la Main courante, jamais un état d'écran.
- **O-9** La preuve = registres, faits, polices, Journal ; l'observabilité est perdable et bornée ; **la Main courante d'exploitation** trace les actes d'exploitation ; **l'Incident** est une unité d'exploitation.
- **O-10** L'émission télémétrique est neutre et nous appartient ; les plateformes (et le Pipeline) sont des mécanismes interchangeables — aucun vendor ne possède la télémétrie.

## §12. Anti-Patterns (8 fiches)

Le dashboard-décideur · l'alerte-législatrice · le log-base-de-données · la trace-preuve · l'AIOps-propriétaire · la métrique-dans-la-Command · l'alerte-bruit · le vendor-télémétrie.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F5.3** (Observabilité, lois O-1→O-10, la Main courante) et **F5.3.99** (sept amendements intégrés : **Pipeline de télémétrie** ; **l'Incident** unité d'exploitation (Ouvert→Maîtrisé→Résolu→Clos, R-B) ; **la Main courante = Registre d'exploitation** ; **le Relevé d'accès** probant, transmis à F5.4 ; la table des identités + Catalogue des métriques, `SessionId` réservé ; **le Sampling** licite sur le perdable seul ; **le Runbook** document gouverné). **Règle N°18** : le Grand Audit F5.99 (Lot 6E) vérifie sans modifier ce chapitre. Entrées de glossaire dues au Titre VII : le Log, l'Alerte, la Main courante d'exploitation, l'Incident, le Pipeline de télémétrie, le Relevé d'accès, SLI/SLO/Error Budget. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.
