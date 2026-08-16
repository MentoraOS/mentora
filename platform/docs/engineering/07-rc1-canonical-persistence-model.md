# RC-1 — Canonical Persistence Model (Phase 2A.5)

> **Statut : documentaire — aucun code, aucun SQL, aucune table Prisma.**
> Le modèle CANONIQUE que tout moteur devra matérialiser (S-1 : « *le Registre
> est le contrat du propriétaire, le moteur un mécanisme* »). Autorité unique :
> le Corpus gelé (`docs/canon/`). Vocabulaire aligné sur RC-4.

## 0. Lois transversales du modèle

- **A-3** : rétention atomique (état + faits en Outbox), « *ne parle à personne* ».
- **S-2** : « *une unité chargée est entière ou n'est pas* » ; les dialectes meurent à l'adapter.
- **S-4** : « *tout dérivé passe le test du pardon — reconstruisible ou mort ; sans chemin de reconstruction écrit, présumé propriétaire donc illégal* ».
- **S-9** : structure des faits immuable ; jamais UPDATE, jamais DELETE de faits ; matière crypto-shreddable.
- **F5.2 §12** : « *reconstruction = **Snapshot privé + delta*** » ; mots réservés : Snapshot (tactique), Journal (application), Export (droit de la personne).
- **F3.3 §3** (grille de contenu des faits) : « *les faits portent identités, natures, instants, auteurs, provenances* » ; interdit partout : toute matière, tout secret (P7).
- **F4.99 §6** (taxonomie des identités) : `ActorRef · AggregateId · ActIdentity(CommandId) · EventIdentity · MessageId · CorrelationId · CausationId · ProcessId · SubjectKey`.

## 1. Aggregate Snapshot (générique)

| Rubrique | Contenu |
|---|---|
| Responsabilité | La **photographie interne de reconstitution** d'UNE unité — « *privée au registre* », « *jamais un contrat ; une donnée servie* » (F3.1.11). |
| Propriétaire | Le registre du domaine propriétaire (le domaine possède la porte `fromSnapshot`/`snapshot`, l'adapter possède la ligne). |
| Justification R2 | F3.1.11 ; F5.2 §12 (la formule de reconstruction) ; S-2 (unité entière). |
| Structure logique | `AggregateId` · `version` (concurrence optimiste, F5.2 §4) · `payload` = VersionedPayload{formatVersion, photo canonique} · `checksum`. |
| Invariants | Une photographie par unité, la plus récente fait foi ; écrite DANS la transaction de rétention (delta = 0 par construction — Blueprint 2A-2 §1) ; ne traverse JAMAIS un port. |
| Contraintes/Index | unique(`AggregateId`) ; l'index de tout parcours du catalogue déclaré (R-A). |
| Versionnement | `formatVersion` (VersionedPayload) ; évolution **additive seulement** (esprit V-2). |
| Checksum | obligatoire ; faux → **Exception** + Signal (jamais un `none` menteur). |
| Évolution/Migration | rupture de format = migration expand-contract (S-7), exécutée par l'espèce Migration — structure, jamais le sens. |
| Suppression | suit la vie de l'unité et la police d'effacement de la Fiche (S-9/S-10) ; la matière incorporée est chiffrée par clés de personne (crypto-shredding). |

## 2. Agreement Snapshot (instance)

L'instance Agreement du §1, dont la forme logique est la porte gelée de 1A
(`AgreementSnapshot`) : identité (`AgreementId`), parties (`ClientId`,
`ExpertId`), conditions (`OfferId`), créneau, état de machine (7 états, 4
terminaux + horodatages d'état), replanifications, `version`. Propriétaire :
le registre Agreement. Justification : F3.2-A (l'unité gelée) + F3.1.11. Tout
le reste = §1. **Aucun champ nouveau n'est créé ici** — la photo reflète
l'unité gelée, rien d'autre.

## 3. Fact Record (le flux de faits)

| Rubrique | Contenu |
|---|---|
| Responsabilité | La ligne append-only d'UN fait retenu — la provenance éternelle (O-4 : « *la chaîne éternelle… c'est la provenance des faits* ») ; source de la Réadmission (S-6) et du replay-outillage. |
| Propriétaire | Le registre du domaine propriétaire du fait (M-4 : « *toute publication naît d'une Outbox de propriétaire* » — le fait est constaté chez lui). |
| Justification R2 | F3.3 §3 (grille de contenu) ; S-9 (immuabilité) ; F5.2 §12 (le « delta » de la formule). |
| Structure logique | `EventIdentity` = (`AggregateId`, `sequence`) · `type` (nom du dictionnaire) · `payload` wire (langage publié 1B, sérialisation du propriétaire — V-1) · `occurredAtMs` · provenance. |
| Invariants | append-only ; ordre garanti **par sujet d'unité seulement** (F4.3 §4) ; écrit DANS la transaction de rétention ; jamais de matière, jamais de secret (P7). |
| Contraintes/Index | unique(`AggregateId`, `sequence`) = idempotence structurelle ; index de relecture par sujet. |
| Versionnement | `contractVersion` du fait (générations du propriétaire, V-1/V-2). |
| Checksum | par ligne ; faux → Exception + Signal ; récupération = acte gouverné (S-6 : Perte Déclarée, Réadmission par la police, « *rien n'est re-fabriqué sans preuve* »). |
| Évolution | additive (V-2) ; suppression/renommage = contrat NOUVEAU (V-3). |
| Suppression | **n'existe pas** (S-9) ; l'effacement légal détruit les clés de personne, la structure demeure (identités opaques, natures, instants, provenances). |

## 4. Outbox Record (l'Outbox de faits)

| Rubrique | Contenu |
|---|---|
| Responsabilité | Ce que le RELAIS portera au routage : l'enveloppe + le fait wire, né atomiquement avec l'état (A-3) ; « *la publication lit la rétention — jamais l'inverse, jamais avant* » (A-4). |
| Propriétaire | Le registre du propriétaire (« Outbox de faits », F4.99 §2 — le mot nu est banni) ; la LECTURE appartient au relais (exécutable Relay, F5.1 §3). |
| Justification R2 | M-4 ; A-3/A-4 ; F4.3 §5 (le contenu de l'enveloppe). |
| Structure logique | ENVELOPPE (F4.3 §5, verbatim) : `MessageId`, `CorrelationId`, `CausationId`, tentatives de livraison, horodatage de transport, trace — **jamais un champ métier interprétable** · `payload` wire · statut (pending → porté) · `EventIdentity` (le même fait re-livré : même EventIdentity, nouveau MessageId — F4.99 §6). |
| Invariants | insérée DANS la transaction de rétention ; aucune publication directe, jamais ; les tentatives de livraison vivent ICI, jamais dans une position (P-4/F4.2.99). |
| Contraintes/Index | index (statut, ordre d'insertion) pour la lecture du relais ; ordre par sujet d'unité seul. |
| Évolution/Suppression | une ligne portée peut être purgée par rétention bornée déclarée à la Fiche (l'Outbox est un mécanisme de portage ; la provenance éternelle est le Fact Record) — S-4 : dérivé au chemin de reconstruction écrit (re-dérivable du Fact Record). |

## 5. Inbox Record (par consommateur)

| Rubrique | Contenu |
|---|---|
| Responsabilité | Le registre des identités de faits traités d'UN consommateur — la déduplication de l'at-least-once (loi 15 : « *exactly-once… mythe interdit* »). |
| Propriétaire | **Chaque consommateur, jamais un domaine** (F4.3 §7, verbatim : « *Inbox par consommateur : la seule… deux consommateurs partageraient une mémoire* »). |
| Justification R2 | M-4 ; F4.99 pas 4 de la Réaction (« *marque d'Inbox + position + commandes émises, une écriture* »). |
| Structure logique | `EventIdentity` traitée (+ le cas échéant la position du parcours et l'Outbox de commandes, retenues dans LE MÊME acte). |
| Invariants | la marque naît dans la rétention atomique de la Réaction — jamais avant, jamais séparément. |
| Contraintes/Index | unique(consommateur, `EventIdentity`). |
| Suppression | rétention bornée déclarée ; perdable au prix d'une re-consommation idempotente (le pardon passe — les clés R-A et l'idempotence aval garantissent l'effet unique, A-5). |

## 6. Replay Cursor — mécanisme, PAS un objet canonique

**Verdict** : le Corpus ne nomme aucun « Replay Cursor ». Deux choses existent :
le **replay** (acte d'outillage journalisé, à cible nommée, refusable — F4.3
§8 : « *il ne crée rien, il re-porte* ») et la **reprise du relais** (« *après
commande émise → relais reprend* », F4.2 §9). La position de lecture d'un
relais est donc un **mécanisme libre** (F4.1.99), encadré par : O-1 (test du
pardon — la perdre n'exige aucun pardon : elle se recalcule des statuts de
l'Outbox) et S-4 (chemin de reconstruction écrit : « rejouer les pending »).
Elle ne possède rien, ne fait foi de rien, n'apparaît dans aucun contrat.
**Le nom « Replay Cursor » est un nom d'ingénierie, pas un terme du Corpus**
(voir RC-4) — il ne désigne qu'une optimisation de lecture rebuildable.

## 7. Projection Checkpoint — DISSOUS (STOP 1C-6 maintenu)

**Verdict** : aucun objet nouveau n'est descriptible. Les projections
Agreement sont sous STOP constitutionnel (1C-6 : sources non écrites,
propriétaires en conflit — décisions Titre VII pendantes). ET l'objet demandé
se **dissout** dans un objet canonique existant : un futur consommateur de
projection sera un consommateur de faits publiés (Séquence de Réaction) — sa
« position de rattrapage » **est son Inbox de consommateur** (§5 ; M-4). Le
jour où le CTO ratifie les projections, AUCUN objet de persistance nouveau
n'est requis : Inbox + relecture du Fact Record suffisent par construction.
Décrire ici un « checkpoint » de plus serait créer un doublon d'Inbox — interdit.

## 8. Quarantine Record

| Rubrique | Contenu |
|---|---|
| Responsabilité | Le message parqué au-delà des bornes de retry — « *parqué, journalisé, et signale l'exploitation (rien ne meurt sans témoin) ; un poison message ne bloque jamais la file des autres* » (F4.3 §8). |
| Propriétaire | Le transport/l'exploitation — **la Quarantaine n'a aucune vérité** (le pardon passe ; rétention bornée, jamais silencieuse — F4.3). |
| Justification R2 | M-8 (« *les retries sont bornés ; au-delà : Quarantaine + Signal* ») ; F4.3 §8. |
| Structure logique | l'enveloppe complète + le payload tel que reçu · la cause technique (code RC-2) · le compteur de tentatives · l'horodatage de parcage. |
| Invariants | jamais mutée ; sa sortie est un **replay outillé** (à cible nommée, refusable) ou une purge de rétention bornée, journalisées. |
| Contraintes/Index | par consommateur/file ; index de rétention. |
| Suppression | rétention bornée déclarée ; purge journalisée. |

## 9. Migration Record

| Rubrique | Contenu |
|---|---|
| Responsabilité | La comptabilité du mécanisme de migration : quelle migration expand-contract appliquée, quand, réversible jusqu'où (« *réversibles par fenêtre* », S-7). |
| Propriétaire | L'exploitation, sous change-control ; EXÉCUTION par l'espèce Migration (F5.1 §3 : « *ne touche jamais le sens* »). |
| Justification R2 | S-7 ; F4.4 §7/CI (le boot vérifie l'exécutabilité, la CI la conformité). |
| Structure logique | identifiant de migration · fenêtre · état (appliquée/renversée) · provenance d'artefact (T-21 : la chaîne signée). |
| Invariants | ordonnée, append-only ; jamais exécutée au boot d'une Application ; jamais un sens métier. |
| Suppression | non — c'est l'histoire du mécanisme (bornée par la vie du schéma). |

## 10. Schema Generation (générations déclarées)

| Rubrique | Contenu |
|---|---|
| Responsabilité | Le registre DÉRIVÉ des générations : côté contrats, « *chaque génération de contrat déclarée est servie* » se prouve au boot (F4.4 §7/F4.4.99) ; côté photos, le `formatVersion` du VersionedPayload. |
| Propriétaire | Chaque PROPRIÉTAIRE de contrat possède ses générations (V-1) ; la table dérivée est reconstruisible (M-5 : « *le routage est une projection* » — même régime). |
| Justification R2 | V-1→V-6 ; F4.4 §7 ; S-4. |
| Invariants | additive (V-2) ; suppression/renommage = contrat nouveau (V-3) ; la mort d'une génération est DÉRIVABLE des consommateurs déclarés (V-5) ; désaccord au boot = pas de démarrage. |

## 11. Retention Audit — DISSOUS (aucun objet nouveau)

**Verdict** : le Corpus ne connaît pas d'objet « Retention Audit », et il
possède déjà TOUTES les pièces probantes de la rétention : (a) le **Journal
applicatif** — le record du pas 8 de chaque Séquence, corrélé, probant
(A-10 ; F5.3 §2 : le Journal est l'émission probante) ; (b) la **provenance
des faits** (O-4) portée par le Fact Record ; (c) la **Fiche de Registre**
(S-10) qui déclare rétention et politique d'effacement, vérifiée en CI ;
(d) le **Relevé d'accès** (F5.3 §2, probant, régi par F5.4) pour l'accès aux
données protégées. Créer un cinquième objet serait dupliquer le Journal —
« *une vérité documentaire = un catalogue ; les autres la référencent* »
(F3.3). L'audit de rétention EST la lecture croisée de (a)+(b)+(c)+(d).

## 12. Synthèse des verdicts

| Objet du mandat | Verdict |
|---|---|
| Aggregate/Agreement Snapshot, Fact Record, Outbox Record, Inbox Record, Quarantine Record, Migration Record, Schema Generation | **Décrits** — chaque rubrique cousue à sa loi. |
| Replay Cursor | **Mécanisme libre** encadré (O-1/S-4) ; nom d'ingénierie, pas un terme du Corpus. |
| Projection Checkpoint | **Dissous** dans l'Inbox de consommateur (M-4) ; STOP 1C-6 maintenu. |
| Retention Audit | **Dissous** dans Journal (A-10) + provenance (O-4) + Fiche (S-10) + Relevé d'accès (F5.3). |
