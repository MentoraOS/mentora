---
doc: f4-05-grand-application-audit
title: F4.99 — Grand Application Constitutional Audit (synthèse, état final ratifié)
type: source
titre: application
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 5C)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 5C"
sources_session:
  - "F4.99 — Grand Application Constitutional Audit (les trois Séquences, la Séquence de Réaction et la Séquence de Lecture, la distinction Outbox de faits / de commandes, les annotations A-5/A-9/P-3, le noyau des sept méta-principes, la topologie en anneaux, la table des vingt propriétaires, les neuf identités, le Handbook 32 fiches, la 32e fiche)"
note: >-
  Reconstruction fidèle de l'état final ratifié. Ce chapitre est le chapitre de
  CLÔTURE de F4 : conformément aux règles N°13 et N°16, il possède UNIQUEMENT la
  synthèse et les méta-propriétés — il ne réécrit, ne résume, ne remplace aucun
  chapitre 01-04. Il possède exclusivement : les trois Séquences (dont Réaction
  et Lecture, nées ici), le noyau des sept méta-principes, la topologie en
  anneaux, la distinction Outbox de faits / de commandes, les annotations
  A-5/A-9/P-3 (les lois restant propriété de leurs chapitres — règle N°14), et la
  32e fiche d'anti-pattern. Scaffolding de session exclu. Titre VII pour toute
  évolution.
---

# F4.99 — Grand Application Constitutional Audit

> **Chapitre de clôture du Titre F4.** Il ne possède que la **synthèse** : les
> vues globales, les méta-principes, la topologie, les annotations. Les lois et
> mécanismes demeurent propriété de leurs chapitres (01 Séquence de Commande,
> 02 Process Managers, 03 Circulation, 04 Infrastructure).

## 1. Les trois Séquences — la clef de voûte

Le Grand Audit a trouvé le silence que les quatre chapitres supposaient sans le nommer : *qui garde l'exécution d'une consommation ?* La réponse complète l'édifice.

- **Séquence de Commande** (dix pas) — propriété du chapitre 01. *Inchangée* : ce chapitre ne fait que l'englober dans une vue plus large (règle N°12).
- **Séquence de Réaction** (six pas, **née ici**) — pour toute consommation de fait (Process Manager ou handler) : *1. Réception du fait (Inbox — déduplication par identité de fait) → 2. Injections (corrélation propagée, instant si requis) → 3. Réaction (fonction pure : position/mapping → commandes) → 4. Rétention atomique (marque d'Inbox + position + commandes émises, une écriture) → 5. Relais (dispatch des commandes, at-least-once) → 6. Journal.*
- **Séquence de Lecture** (six pas, **née ici**) : *réception → identité → R-C → lecture → réponse → journal.*

> **Loi de clôture — les trois chemins.** *Toute exécution dans Mentora est l'une des TROIS Séquences — Commande (10 pas), Réaction (6 pas), Lecture (6 pas). Il n'existe aucun quatrième chemin d'exécution.*

## 2. La distinction Outbox de faits / Outbox de commandes

L'homonymie débusquée entre deux chapitres : l'Outbox de la Séquence de Commande (pas 8) retient des **faits** (du propriétaire) ; la boîte de réaction du PM/handler (pas 4 de la Réaction) retient des **commandes** émises — même mécanisme, deux contenus, un seul mot (la violation de la loi 10).

> **Amendement de langue (propriété de ce chapitre).** **Outbox de faits** (domaine, pas 8 de la Séquence de Commande) et **Outbox de commandes** (pas 4 de la Séquence de Réaction) — le mot nu « Outbox » est banni des textes officiels, la qualification obligatoire.

## 3. Les annotations des lois dérivées (règle N°14 : la loi reste chez son propriétaire)

Le Grand Audit constate, sans réécrire ni déplacer, que trois lois sont **dérivées** — il n'en possède que l'annotation :

- **A-5** (propriété du chapitre 01) dérive de **M-4 + R-A** — l'effet unique est la somme des trois étages.
- **A-9** (propriété du chapitre 01) dérive de **I-2 + I-7**.
- **P-3** (propriété du chapitre 02) dérive de **F3.1.5** — seul le constatant publie.

Marquées *dérivées-mais-retenues* : un réviseur les oppose sans refaire la dérivation. **Contradictions : zéro.**

## 4. Le noyau des sept méta-principes (couche d'enseignement)

Les 48 lois d'exécution (A, P, M, V, I) restent le **statut opposable** ; sept méta-principes les régénèrent et forment la **couche d'enseignement** :

1. **Le NON à la source.**
2. **Les trois Séquences.**
3. **L'enveloppe distincte du fait.**
4. **Le test du pardon.**
5. **Les tables closes vérifiées au boot.**
6. **Propriétés gelées, mécanismes libres.**
7. **Rien ne meurt sans témoin.**

Deux étages, aucun doublon de rôle : le noyau enseigne, les 48 lois opposent.

## 5. La topologie en anneaux (vue globale — règle N°12)

La liste linéaire (Infrastructure→Application→Domain→Runtime…) suggère une **pile — c'est faux**. La topologie réelle est **des anneaux et un côté** :

```
            [ Infrastructure ]   ← Root, Runtime, Adapters, frameworks, fournisseurs
          ┌────────────────────┐
          │   [ Application ]   │  ← les trois Séquences, les ports
          │  ┌──────────────┐  │
          │  │  [ Domaine ]  │  │  ← ne connaît rien
          │  └──────────────┘  │
          └────────────────────┘
   Transport = un service de l'anneau externe (tuyaux muets)
   Outillage (Échéancier, relais, Quarantaine, observabilité) = à CÔTÉ (projections)
```

Le **Domaine** au centre (ne connaît rien) ; l'**Application** autour ; l'**Infrastructure** à l'extérieur ; le **Transport** est un service de l'anneau externe ; l'**Outillage** est **à côté**, fait de projections, jamais entre les anneaux. Aucune inversion dans F4 — seule la *représentation* en pile était fautive ; les anneaux étaient déjà la loi vécue (I-1).

## 6. Les vingt propriétaires

Table de synthèse (chaque concept d'exécution, un propriétaire, zéro dispute) : Decision/Refusal → l'unité (et la Factory à la naissance) · Failure → le mécanisme qui a échoué · Policy/Specification → le domaine · Aggregate → le domaine · Domain Service → n'existe pas (zéro dans les quinze) · Application Service → l'application · PM → l'application (définition), personne (vérité) · Dispatcher → l'application (tables dérivées) · Adapter → l'infrastructure · Bus → personne (muet) · Runtime/Root → l'infrastructure, un par exécutable · Outbox de faits → le propriétaire du registre · Outbox de commandes → le PM/handler · Inbox → chaque consommateur · Échéancier → projection (personne) · ACL → le commanditaire de la frontière · Port → son consommateur · Framework → rien (mécanismes).

## 7. Les neuf identités

`ActorRef` (qui agit) · `AggregateId` (l'unité) · `ActIdentity` (déduplication de commande) · `EventIdentity` (déduplication de fait) · `MessageId` (l'occurrence de transport — un même fait re-livré : même EventIdentity, nouveau MessageId) · `CorrelationId` (le geste d'origine) · `CausationId` (la cause immédiate) · `ProcessId` (le sujet de parcours) · `SubjectKey` (la clé opaque d'ordre, **copie dérivée** d'AggregateId). **Zéro doublon, une responsabilité chacune.**

## 8. Le graphe des dépendances

Personne/Surfaces → Dispatchers → Séquences → Domaine (centre) ; Domaine → rien ; Application → ports ; entrants → Dispatch seul (I-12) ; sortants → fournisseurs seuls (I-12) ; outillage → projections reconstruisibles ; Root → tout, connu de rien. **Orienté vers le centre, acyclique, sans dépendance implicite** — la seule flèche discutée (Notification→Joignabilité) reste l'unique exception écrite, sanctionnée depuis F2.

## 9. Les dix-huit architectures

*Clean, Hexagonal, Onion* : **des cousines, pas des rivales** — F4 respecte leur unique loi (la dépendance vers le centre) et ajoute ce qu'elles n'ont jamais dit : le refus-valeur, les trois Séquences, le test du pardon, les tables closes, le versionnement — *F4 est une Clean Architecture rendue démontrable.* *DDD classique* : notre parent. *CQRS* : adopté là où il paie, refusé comme religion. *Mediator, Saga-floue, Workflow Engine, ESB, SOA, Event-Bus-First, Framework-First, Infrastructure-First, Microservices-First, Plugin, Service Locator, Reflection-First* : re-détruits. *Serverless* : une topologie de déploiement, licite pour des exécutables à Root complet et boot validé par instance. **Aucune ne survit comme supérieure ; trois survivent comme ancêtres honorés.**

## 10. Le Handbook F4 — 32 fiches

Les 35 fiches des quatre chapitres fusionnées : doublons supprimés (*App→App* = *service bavard* ; *identité ambiante* + *horloge globale* + *contexte global* → une famille unique, **« l'Ambiant »** ; *orchestrateur omniscient* renvoyé à sa fiche F3) → **31 fiches canoniques**, plus **la 32e, née de ce chapitre** :

> **« le quatrième chemin »** — symptôme : une exécution qui n'est ni Commande, ni Réaction, ni Lecture (un cron qui écrit, un script qui répare, un endpoint qui « fait juste ») ; cause : l'urgence ; réfutation : §1 — trois Séquences, aucun autre chemin ; solution : toute exécution rejoint sa Séquence, y compris l'outillage.

**32 fiches, le Handbook est clos.**

## 11. Décision constitutionnelle

*Architecture d'exécution supérieure ?* **NON** — dix-huit rejouées, trois reconnues ancêtres. *Loi redondante ?* **Trois dérivées, marquées, retenues.** *Loi manquante ?* **UNE — trouvée et adoptée** : la Séquence de Réaction (et sa sœur de Lecture). *Responsabilité mal placée ?* **NON** (table des vingt). *Dépendance cachée ?* **NON** (anneaux acycliques). *Architecture plus simple ?* **NON.** *Plus démontrable ?* **NON — c'est sa définition même.**

> **F4 — Domain Interaction & Application Architecture, ainsi amendé, est déclaré ENTIÈREMENT ET CONSTITUTIONNELLEMENT GELÉ.**

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir de la source de session **F4.99** (le Grand Application Audit). **Règles N°13 et N°16 appliquées** : ce chapitre de clôture possède **uniquement** la synthèse et les méta-propriétés — il ne réécrit, ne résume, ne remplace aucun chapitre 01-04. Il possède exclusivement : les **trois Séquences** (Réaction et Lecture nées ici ; la Séquence de Commande reste propriété du chapitre 01, inchangée — règle N°12), le **noyau des sept méta-principes**, la **topologie en anneaux**, la distinction **Outbox de faits / Outbox de commandes**, les **annotations A-5/A-9/P-3** (les lois restant propriété de leurs chapitres — règle N°14), la **table des vingt propriétaires**, les **neuf identités**, le **graphe acyclique**, les **dix-huit architectures**, et le **Handbook (32 fiches)** dont la 32e (« le quatrième chemin »). Le scaffolding de session (Phase 0, scores, État Git, STOP) n'est pas reproduit.
