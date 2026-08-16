# RC-4 — Canonical Naming Convention (Phase 2A.5)

> **Statut : documentaire.** Le dictionnaire TECHNIQUE de la Phase 2 — aucun
> terme nouveau : chaque entrée cite son propriétaire. Deux familles :
> **[R2]** = terme du Corpus (le chapitre cité fait foi) ; **[ENG]** = nom
> d'ingénierie né dans un lot d'implémentation, qui matérialise une loi citée
> sans prétendre au Corpus. Le Dictionnaire bilingue (F2.5) reste le
> propriétaire du vocabulaire MÉTIER — ce document n'y touche pas.

## 1. Blocs et vérités [R2]

| Terme | Définition (propriétaire) | Autorisé | Interdit |
|---|---|---|---|
| Aggregate | l'unité de vérité, machine d'états, décisions (F3.1) | nu `<Truth>` | jamais construit par le Root (I-3) ; jamais dans un adapter |
| Factory | la porte de naissance, « refuse les naissances » (F3.1) | `<Truth>Factory` | consulter un port ; publier |
| **Snapshot** | **réservé** : photographie interne privée au registre (F3.1.11 ; réservation F5.2 §12) | la porte du domaine + la ligne du registre | tout autre sens — la copie de sauvegarde se dit *Image de sauvegarde* |
| Projection | dérivation déterministe de faits, recalculable, citée, jamais persistée comme vérité (F3.1/F2 Titre V) | lectures d'exploitation (F5.3) | devenir un fait (P3) ; refuser un acte ; **projections métier Agreement : STOP 1C-6** |
| Fact / Domain Event | né d'un acte ou d'une décision de son propriétaire (F2.2 loi 8) | participe passé, préfixe propriétaire | naître d'une dérivation ; porter matière/secret |
| Decision / Refusal / Reason | l'issue de toute Command ; le refus est une VALEUR motivée (P4, A-7) | l'union des Reasons au langage publié (1B) | un refus levé en exception ; « erreur métier » |
| Policy | règle PUBLIÉE d'avance, paramètres du PRODUIT, rend une Décision motivée (F3.1) | `<Truth><Rule>Policy`, construite au Root (F4.1 §4) | tout réglage technique nommé Policy (retry, rotation…) |
| Failure / Exception | Failure = incapacité technique retryable, une VALEUR ; Exception = défaut d'appelant (A-7, F3.1.14) | les trois canaux, jamais mélangés | convertir l'un en l'autre |

## 2. Circulation & persistance [R2]

| Terme | Définition (propriétaire) | Autorisé | Interdit |
|---|---|---|---|
| Envelope | le transport : MessageId, CorrelationId, CausationId, tentatives, horodatage, trace (F4.3 §5 ; M-3) | fabriquée à la rétention/au gateway | contaminer un fait ; champ métier interprétable |
| **Outbox** | mot nu **banni** (F4.99 §2) : dire **Outbox de faits** (pas 8, Commande) ou **Outbox de commandes** (pas 4, Réaction) | les deux formes qualifiées | « Outbox » nu dans un texte officiel |
| Inbox | le registre PAR CONSOMMATEUR des identités de faits traités (F4.3 §7, M-4) | une par consommateur | partagée ; par domaine ; l'identifiant `inbox` est aussi frappé par MENTORA0001 (sens Conversations) — nommer les registres autrement en code |
| Relay | l'exécutable qui porte les Outbox vers le Bus, at-least-once (F5.1 §3 ; A-4) | espèce d'exécutable | publication inline par un service |
| Quarantaine | le parcage borné au-delà des retries, journalisé, signalé (F4.3 §8, M-8) | transport/exploitation | posséder une vérité |
| Replay | acte d'outillage journalisé, à cible nommée, refusable — « il re-porte » (F4.3 §8) | re-livraison outillée | réhydratation d'état ; replay « libre » |
| **Journal** | **réservé** : l'émission applicative PROBANTE, les pas des Séquences (A-10, F5.3 §2 ; réservation F5.2 §12) | les 3 ports de Journal (1C-2/4/5) | le log moteur (dire *journal de moteur*) ; l'échantillonner |
| Log | l'émission TECHNIQUE, perdable et bornée (F5.3 §2) | Runtime/adapters/moteurs | matière, secret, valeur probante métier |
| **Export** | **réservé** : le droit de la personne (P9.6 ; F5.2 §12) | ce seul sens | « exporter » des métriques/données techniques (dire *sink*, *Copie d'exploitation*) |

## 3. Application & composition [R2]

| Terme | Définition (propriétaire) | Autorisé | Interdit |
|---|---|---|---|
| Port | contrat de capacité **possédé par son consommateur** (F4.4 §3, I-4) | `<Capability>Port` chez le consommateur | port partagé (« Shared Kernel au sous-sol ») ; framework dans un port |
| Adapter | l'implémentation à une frontière, deux interlocuteurs (F4.4, I-4/I-12) | `<Provider><Capability>Adapter` | créer fait/Decision/vérité ; être vu au-dessus du Root (A-9) |
| Provider | le fournisseur externe dans le nom d'un Adapter (F2.5 §9) | préfixe d'Adapter | — |
| Dispatcher | route et refuse, table fermée, ne pense pas (F4.1 §6, A-8) | Command/Query/ReactionDispatch (implémentés) | logique métier ; découverte dynamique ; réflexion qui cache la table |
| Application Service | le gardien d'exécution d'UN cas d'usage, « ennuyeux » (F4.1 §1/§7) | `<UseCase>ApplicationService` | « Handler » côté commande ; App→App |
| Composition (Root) | le seul lieu de types concrets, unique par exécutable (F4.4 §2, I-2) | `composeAgreement` + le Root de l'exécutable | service locator ; second foyer de composition |
| Runtime | le gardien de l'exécutabilité — ne possède ni vérité ni règle (F5.1 R-1) | la famille `runtime-*` | héberger du métier ou des ports métier |
| Health | Readiness = les trois Séquences ; Liveness = le processus (R-6) | verdicts fail closed | juger le métier |

## 4. Noms d'ingénierie [ENG] — nés dans les lots, adossés à leurs lois

| Terme | Né en | Matérialise | Garde-fou |
|---|---|---|---|
| Executor (Sequence/Read/Reaction) | 1C-2/4/5 | L'exécuteur unique des pas gelés (A-2 ; F4.99 §1) | ne jamais en créer un 4e (« aucun quatrième chemin ») |
| Step / Stage | 1C-2 | les pas gelés et leurs classes | jamais un pas absent de R2 |
| Definition (Sequence/Read/Reaction) | 1C-2/4/5 | « le domaine est injecté dans le pipeline » | la prise, jamais le moteur |
| Builder | 1C-2/5 | « la composition compose » (I-2/I-3) | fail closed |
| Carrier | 1C-7 | « un porteur par Command/Query/fait » (A-1/A-8, M-5) | table fermée |
| Container (RuntimeContainer) | 2A-1 | le cycle de vie possédé (F5.1 §4, I-11) | ni resolve() ni get() — jamais un service locator |
| Sink (Log/Metrics/Span) | 2A-1 | « les puits interchangeables » (O-10) | jamais nommé Exporter (Export réservé) |
| Machinery | 1C-3 | « le Root assemble la machinerie » (F4.4 §2) | injectée, jamais cherchée |
| View (AgreementStateView) | 1C-4 | la ligne de Read Model — « le domaine ne sort jamais » | jamais l'unité |
| Cursor / Checkpoint | RC-1 §6-7 | **non canoniques** : mécanisme rebuildable (S-4) / dissous dans l'Inbox | ne jamais les élever en objets du modèle |
| Bootstrap | 2A-1 | le Boot de F5.1 (démontre, ne sert jamais) | jamais de migration au boot |
| Metric | 2A-1 | lectures d'exploitation (O-3) | jamais dans une Séquence |
| Trace / TraceId / SpanId | 2A-1 | l'ombre échantillonnable ; « dialectes » (F5.3 §10) | jamais domaine ; jamais `SessionId` |

## 5. Réservations qui frappent le code (rappel opposable)

`Snapshot`·`Journal`·`Export` (F5.2 §12) — sens uniques ci-dessus. `Session`/
`Credential` (I&A), `Expired`/`Withdrawn` (Consent), `Rejected` (Engagement),
`Participant` (Consultation), `Deposit` (Storage), `Proof` (Reputation),
`Calendar` (interdit nu en Account), `Principal` (Foundation), quintette du
refus (Rejected/Refused/Declined/Dismissed/Denied) — F2.5 §10-11, appliqués
par MENTORA0001. `Nonce`/`Salt` : mécanismes crypto, jamais dans une vérité
(F5.4 §10). « Replica » banni (F5.1 §17).
