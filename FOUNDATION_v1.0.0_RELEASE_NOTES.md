# Foundation v1.0.0 — Release Notes

Première baseline architecturale gelée de Mentora.
Tag : `foundation-v1.0.0` — branche `arch-008-candidate`.

---

## Résumé des fondations

| Fondation | Contenu | Statut |
| --- | --- | --- |
| **Layout** | 21 formes officielles, 7 fondations internes (Layout, PageLike, Zoned, Principal, Collected, Regioned, Revealed), 1 assemblée unique, registre fermé des kinds | Terminée, gelée |
| **Navigation** | 11 voix (Route, Registry, Destination, Graph, Request, Policy, Resolution, State, Announcement, Coordinator, Session) — machine pure sans import framework | Fermée, gelée |
| **State** | 10 voix, CQRS de bout en bout (écriture : Mutation → Command → Reducer ; lecture : Snapshot → Projection → ReadModel → Query) — un seul producteur de l'état, prouvé par scan | Fermée, gelée |
| **Contracts** | 5 voix (Contract, Registry, Request, Resolution, Coordinator) — motif porteur-pur depuis R1 | Fermée, gelée |
| **Capabilities** | 5 voix, grammaire identique | Fermée, gelée |
| **Rules** | 5 voix, grammaire identique | Fermée, gelée |

## Chiffres

- **Formes de layout : 21** — Workspace, Dashboard, Navigation,
  SplitWorkspace, MasterDetail, Content, Section, List, Grid,
  TabbedContent, Form, Detail, Feed, Wizard, Settings, Analytics,
  Catalog, Timeline, Messaging, Authentication, SearchResults.
- **Voix de fondation : 36** — Navigation 11, State 10, Contracts 5,
  Capabilities 5, Rules 5.
- **Consommateurs purs figés par ensembles exacts** : Collected ×4
  (List, Catalog, Timeline, SearchResults), Principal ×3 (Form, Feed,
  Authentication), Zoned direct ×3 (Principal, Detail, Messaging).
- **Suite de tests : 3650 verts**, balayages Enterprise inclus.
- **`flutter analyze` : 222** (delta zéro sur toute la série ; les 222
  résident dans les couches legacy hors Foundation).

## Audit final

L'audit contradictoire F1.7.99 (lecture seule, sur ce même arbre) a
conclu : **aucune réduction architecturale restante dans
`lib/foundation`**, aucune mauvaise abstraction, aucune duplication
réelle côté fondation, aucun couplage caché, graphe d'imports vérifié
DAG sans cycle, refus à propriétaires uniques, objets-valeurs complets
(const, ==, hashCode, canonicalisation ; sémantique d'identité
documentée pour les rassemblements). Décision d'audit : **gel possible
— OUI**. Six réductions candidates ont été examinées et refusées avec
démonstration (fusion Zoned/Regioned, généralisation des refus
d'identité, généralisation des lots cinq-voix, fusion
Collected/Revealed, extraction du boilerplate du laboratoire,
suppression de Projection).

## État Git

- Baseline gelée : commit `b13da95` (F1.4.21 — SearchResults), arbre
  propre, `git diff --check` propre, branche `arch-008-candidate`,
  `main` intouché.
- Le tag `foundation-v1.0.0` est posé sur le commit de gel qui ajoute
  la Constitution et ces notes ; il devient la baseline architecturale
  immuable de toute version future de Mentora.

## Risques acceptés

1. La gouvernance de tests croît linéairement avec les suites (voir
   dette reportée) — traitée en F4 avant qu'elle ne devienne un
   chantier.
2. Le catalogue vivant (`playground_galleries.dart`) est un
   mono-fichier qui grandit à chaque forme ; une scission par famille
   sera un geste de laboratoire, sans impact de fondation.
3. Le fichier de style unique de la couche Layout accumulera les
   vocabulaires fermés ; long mais jamais ambigu — accepté par
   conception.
4. La baseline analyze (222) contient les infractions des couches
   legacy ; après leur migration (F2+), la référence devra être
   re-décidée pour appartenir à la Foundation seule.
5. Toute future demande de lot cinq-voix reposera la question de la
   généralisation ; la réponse ne change que si une machinerie — pas un
   motif — devient réellement commune.

## Dette reportée

**R2 uniquement** : bibliothèque de gouvernance des tests — `codeOf()`,
`dartFilesOf()` et le harnais `refuse()` sont copiés dans 25 fichiers
de suite, et deux forces de balayage coexistent (source brute dans les
suites anciennes, source dépouillée des commentaires dans les
récentes). Duplication réelle, côté test exclusivement, hors du
périmètre gelé. Décision CTO : reportée à **F4**.
